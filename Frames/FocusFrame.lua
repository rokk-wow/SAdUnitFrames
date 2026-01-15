local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.focus = addon.unitFrames.focus or {}

function addon.unitFrames.focus:removePortrait()
    addon:debug("Removing focus portrait")
end

function addon.unitFrames.focus:setClassColor()
    addon:debug("Setting focus frame class color")
end

function addon.unitFrames.focus:addBorder()
    addon:debug("Adding focus frame border")
end

function addon.unitFrames.focus:adjustText()
    addon:debug("Adjusting focus frame text")
end

function addon.unitFrames.focus:updateTexture()
    addon:debug("Updating focus frame texture")
end