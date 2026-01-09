--[[ Patch to stretch the book covers to set aspect-ratio ]]
--

-- stylua: ignore start
--========================== Edit your preferences here ======================================================
local aspect_ratio = 2 / 3          -- width / height
local stretch_limit_percentage = 50 -- Max percentage to stretch beyond original size
local fill = false                  -- if true, covers will fit the full grid cell
--============================================================================================================
-- stylua: ignore end

local ImageWidget = require("ui/widget/imagewidget")
local Size = require("ui/size")
local userpatch = require("userpatch")

local function patchBookCoverRoundedCorners(plugin)
    local MosaicMenu = require("mosaicmenu")
    local MosaicMenuItem = userpatch.getUpValue(MosaicMenu._updateItemsBuildUI, "MosaicMenuItem")
	
    if MosaicMenuItem.patched_stretched_covers then
        return
    end
    MosaicMenuItem.patched_stretched_covers = true
	
    local local_ImageWidget
    local n = 1
    while true do
        local name, value = debug.getupvalue(MosaicMenuItem.update, n)
        if not name then
            break
        end
        if name == "ImageWidget" then
            local_ImageWidget = value
            break
        end
        n = n + 1
    end    
    if not local_ImageWidget then
        return
    end  
    local setupvalue_n = n
	
    -- Store instance-specific data
    local instance_data = {}   
    -- Get the original init method
    local orig_MosaicMenuItem_init = MosaicMenuItem.init    
    -- Override init to store dimensions per instance
    MosaicMenuItem.init = function(self)
        -- Generate a unique ID for this instance
        local instance_id = tostring(self):match("0x(%x+)") or tostring(self)        
        if self.width and self.height then
            -- Store dimensions for this specific instance
            local border_size = Size.border.thin
            local underline_h = 1  -- Default from original code            
            -- Calculate available space for the image
            instance_data[instance_id] = {
                max_img_w = self.width - 2 * border_size,     -- Available width inside border
                max_img_h = self.height - 2 * border_size,    -- Available height inside border
                border_size = border_size,
                underline_h = underline_h,
                cell_width = self.width,
                cell_height = self.height
            }
        end       
		
        -- Call original init
        if orig_MosaicMenuItem_init then
            orig_MosaicMenuItem_init(self)
        end
    end
	
    -- Create custom ImageWidget subclass
    local StretchingImageWidget = local_ImageWidget:extend({})    
    StretchingImageWidget.init = function(self)
        -- Get instance ID
        local instance_id = nil
        local parent = self.parent
        while parent do
            local parent_id = tostring(parent):match("0x(%x+)")
            if parent_id and instance_data[parent_id] then
                instance_id = parent_id
                break
            end
            parent = parent.parent
        end        
        if not instance_id then
            -- Fallback: try to find any instance data
            for id, _ in pairs(instance_data) do
                instance_id = id
                break
            end
        end   
		
        if instance_id and instance_data[instance_id] then
            local data = instance_data[instance_id]
            local max_img_w = data.max_img_w
            local max_img_h = data.max_img_h            
            -- Reset scale factor
            self.scale_factor = nil            
            -- Set stretch limit
            self.stretch_limit_percentage = stretch_limit_percentage            
            -- Calculate dimensions based on aspect ratio
            local ratio = fill and (max_img_w / max_img_h) or aspect_ratio            
            if max_img_w / max_img_h > ratio then
                -- Cell is wider than target ratio - use full height
                self.height = max_img_h
                self.width = max_img_h * ratio
            else
                -- Cell is taller than target ratio - use full width
                self.width = max_img_w
                self.height = max_img_w / ratio
            end
        end     
		
        -- Call original ImageWidget init if it exists
        if local_ImageWidget.init then
            local_ImageWidget.init(self)
        end
    end
	
    -- Replace the local ImageWidget with our custom one
    debug.setupvalue(MosaicMenuItem.update, setupvalue_n, StretchingImageWidget)
end
userpatch.registerPatchPluginFunc("coverbrowser", patchBookCoverRoundedCorners)
