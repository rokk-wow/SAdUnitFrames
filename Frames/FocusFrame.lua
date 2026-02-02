local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.FocusFrame = addon.unitFrames.FocusFrame or {}

function addon.unitFrames.FocusFrame:FocusFrame()
    print("FocusFrame.")
end