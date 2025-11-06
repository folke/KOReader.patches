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
    
    -- Store original MosaicMenuItem paintTo method
    local origMosaicMenuItemPaintTo = MosaicMenuItem.paintTo
    
    function MosaicMenuItem:paintTo(bb, x, y)
		-- Paint normally first
		origMosaicMenuItemPaintTo(self, bb, x, y)

		-- Try to locate the same "target" the base code uses
		local target = nil
		-- Base file uses self[1][1][1] as the sub-widget cover container
		if self[1] and self[1][1] and self[1][1][1] then
			target = self[1][1][1]
		end

		-- Fade only finished books
		if target and self.status == "complete" then
			-- Compute outer frame rect (same anchoring math as base code)
			-- x/y is the top-left of the cell; target is centered inside
			local has_wh = (target.width and target.height)
			local has_dimen = (target.dimen and target.dimen.w and target.dimen.h)

			local tw = has_wh and target.width  or (has_dimen and target.dimen.w) or self.width
			local th = has_wh and target.height or (has_dimen and target.dimen.h) or self.height

			-- Centered position, snapped to integers
			local fx = x + math.floor((self.width  - tw) / 2)
			local fy = y + math.floor((self.height - th) / 2)

			-- Apply the fade
			bb:lightenRect(fx, fy, tw, th, fading_amount)
		end
	end
    local origMosaicMenuItemInit = MosaicMenuItem.init
    function MosaicMenuItem:init(item)
        origMosaicMenuItemInit(self, item)
    end
end
userpatch.registerPatchPluginFunc("coverbrowser", patchCoverBrowserFaded)