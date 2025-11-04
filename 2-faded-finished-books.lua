--[[
User patch for Cover Browser plugin to add faded look for finished books in mosaic view
]]--

--========================== Edit your preferences here ================================
local fading_amount = 0.66 --Set your desired value from 0 to 1.
--======================================================================================


--========================== Do not modify this section ================================
local userpatch = require("userpatch")
local logger = require("logger")


local function patchCoverBrowserFaded(plugin)
    -- Grab Cover Grid mode and the individual Cover Grid items
    local MosaicMenu = require("mosaicmenu")
    local MosaicMenuItem = userpatch.getUpValue(MosaicMenu._updateItemsBuildUI, "MosaicMenuItem")
    
    if not MosaicMenuItem then
        logger.err("MosaicMenuItem not found - faded look patch may not work correctly")
        return
    end

    -- Store original MosaicMenuItem paintTo method
    local originalMosaicMenuItemPaintTo = MosaicMenuItem.paintTo
    
    -- Override paintTo method to add faded look for finished books
    function MosaicMenuItem:paintTo(bb, x, y)
        -- First, call the original paintTo method to draw the cover normally
        originalMosaicMenuItemPaintTo(self, bb, x, y)
        
        -- Get the cover image widget (target)
        local target = self.cover_image or self[1]
        
        -- ==== ADD faded look to finished books ====
        if target and target.dimen and self.status == "complete" then
            -- Calculate cover position and dimensions
            local fx = x + math.floor((self.width - target.dimen.w) / 2)
            local fy = y + math.floor((self.height - target.dimen.h) / 2)
            local fw, fh = target.dimen.w, target.dimen.h
            
            -- Apply faded effect
            bb:lightenRect(fx, fy, fw, fh, fading_amount)
        end
    end

    -- Alternative: Also patch the init method to debug status field
    local originalMosaicMenuItemInit = MosaicMenuItem.init
    
    function MosaicMenuItem:init(item)
        originalMosaicMenuItemInit(self, item)
    end
    logger.info("Cover Browser faded look patch applied successfully")
end

userpatch.registerPatchPluginFunc("coverbrowser", patchCoverBrowserFaded)

--======================================================================================