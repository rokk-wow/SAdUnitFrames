local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.target = addon.unitFrames.target or {}

function addon.unitFrames.target:removePortrait()
    addon:debug("Removing target portrait")
end

function addon.unitFrames.target:setClassColor()
    addon:debug("Setting target frame class color")
end

function addon.unitFrames.target:addBorder()
    addon:debug("Adding target frame border")
end

function addon.unitFrames.target:adjustText()
    addon:debug("Adjusting target frame text")
end

function addon.unitFrames.target:updateTexture()
    addon:debug("Updating target frame texture")
end