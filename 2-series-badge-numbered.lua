--[[ Patch to add series indicator to the right side of the book cover ]]
--
local Font = require("ui/font")
local FrameContainer = require("ui/widget/container/framecontainer")
local TextWidget = require("ui/widget/textwidget")
local userpatch = require("userpatch")
local Screen = require("device").screen
local BD = require("ui/bidi")
local Blitbuffer = require("ffi/blitbuffer")
local logger = require("logger")

-- stylua: ignore start
--========================== [[Edit your preferences here]] ================================
local font_size = 11                                       -- Adjust from 0 to 1
local border_thickness = 1                                 -- Adjust from 0 to 5
local border_corner_radius = 9                             -- Adjust from 0 to 20
local text_color = Blitbuffer.colorFromString("#000000")   -- Choose your desired color
local border_color = Blitbuffer.colorFromString("#000000") -- Choose your desired color
local background_color = Blitbuffer.COLOR_GRAY_E           -- Choose your desired color
--==========================================================================================
-- stylua: ignore end

local function patchAddSeriesIndicator(plugin)
    local MosaicMenu = require("mosaicmenu")
    local MosaicMenuItem = userpatch.getUpValue(MosaicMenu._updateItemsBuildUI, "MosaicMenuItem")

    if MosaicMenuItem.patched_series_badge then
        return
    end
    MosaicMenuItem.patched_series_badge = true

    local BookInfoManager = require("bookinfomanager")

    -- Store original methods
    local orig_MosaicMenuItem_init = MosaicMenuItem.init
    local orig_MosaicMenuItem_paint = MosaicMenuItem.paintTo

    -- Override init to compute series info once
    function MosaicMenuItem:init()
        orig_MosaicMenuItem_init(self)

        -- Only compute series info if not a directory or deleted file
        if self.is_directory or self.file_deleted then
            return
        end

        -- Get book info and check for series
        local bookinfo = BookInfoManager:getBookInfo(self.filepath, false)
        if bookinfo and bookinfo.series and bookinfo.series_index and bookinfo.series_index ~= 0 then
            self.series_index = bookinfo.series_index
        end
    end

    function MosaicMenuItem:paintTo(bb, x, y)
        -- Call original paintTo
        orig_MosaicMenuItem_paint(self, bb, x, y)

        -- Draw series badge if applicable
        if not self.series_index then
            return
        end

        -- Only draw if we have series info
        local target = self[1][1][1]
        if not target or not target.dimen then
            return
        end

        -- Get book info
        local series_text = TextWidget:new({
            text = "#" .. self.series_index,
            face = Font:getFace("cfont", font_size),
            bold = true,
            fgcolor = text_color,
        })

        local series_badge = FrameContainer:new({
            linesize = Screen:scaleBySize(2),
            radius = Screen:scaleBySize(border_corner_radius),
            color = border_color,
            bordersize = border_thickness,
            background = background_color,
            padding = Screen:scaleBySize(2),
            margin = 0,
            series_text,
        })

        -- Calculate position once
        local d_w = math.ceil(target.dimen.w / 5)
        local d_h = math.ceil(target.dimen.h / 10)

        local ix, iy = 0, 0

        if BD.mirroredUILayout() then
            ix = -math.floor(d_w) -- Half outside on left side
            if not self.overflow_checked then
                local x_overflow_left = x - target.dimen.x + ix
                if x_overflow_left > 0 then
                    self.refresh_dimen = self[1].dimen:copy()
                    self.refresh_dimen.x = self.refresh_dimen.x - x_overflow_left
                    self.refresh_dimen.w = self.refresh_dimen.w + x_overflow_left
                end
                self.overflow_checked = true
            end
        else
            ix = target.dimen.w - math.floor(d_w) -- Half outside on right side
            if not self.overflow_checked then
                local x_overflow_right = target.dimen.x + ix + d_w - x - self.dimen.w
                if x_overflow_right > 0 then
                    self.refresh_dimen = self[1].dimen:copy()
                    self.refresh_dimen.w = self.refresh_dimen.w + x_overflow_right
                end
                self.overflow_checked = true
            end
        end

        -- Calculate badge position (relative to target)
        local series_badge_size = series_badge:getSize()
        local badge_x = target.dimen.x + ix + (d_w - series_badge_size.w) / 2
        local badge_y = target.dimen.y + iy + (d_h - series_badge_size.h) / 2

        -- Paint the cached badge
        series_badge:paintTo(bb, badge_x, badge_y)
    end
end

userpatch.registerPatchPluginFunc("coverbrowser", patchAddSeriesIndicator)
