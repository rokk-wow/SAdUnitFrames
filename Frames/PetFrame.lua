local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.pet = addon.unitFrames.pet or {}

function addon.unitFrames.pet:removePortrait()
    addon:debug("Removing pet portrait")
end

function addon.unitFrames.pet:setClassColor()
    addon:debug("Setting pet frame class color")
end

function addon.unitFrames.pet:addBorder()
    addon:debug("Adding pet frame border")
end

function addon.unitFrames.pet:adjustText()
    addon:debug("Adjusting pet frame text")
end

function addon.unitFrames.pet:updateTexture()
    addon:debug("Updating pet frame texture")
end