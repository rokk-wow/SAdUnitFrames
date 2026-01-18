local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.focustarget = addon.unitFrames.focustarget or {}

function addon.unitFrames.focustarget:removePortrait()
    addon:Debug("Removing focus target portrait")
end

function addon.unitFrames.focustarget:setClassColor()
    addon:Debug("Setting focus target frame class color")
end

function addon.unitFrames.focustarget:addBorder()
    addon:Debug("Adding focus target frame border")
end

function addon.unitFrames.focustarget:addBackground()
    addon:Debug("Adding focus target frame background")
end

function addon.unitFrames.focustarget:adjustText()
    addon:Debug("Adjusting focus target frame text")
end

function addon.unitFrames.focustarget:adjustManaBar()
    addon:Debug("Adjusting focus target mana bar position")
end

function addon.unitFrames.focustarget:hideManaText()
    addon:Debug("Hiding focus target mana text")
end

function addon.unitFrames.focustarget:updateTexture()
    addon:Debug("Updating focus target frame texture")
end

function addon.unitFrames.focustarget:adjustPosition()
    addon:Debug("Adjusting focus target frame position")
end

