local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.FocusTarget = addon.unitFrames.FocusTarget or {}

function addon.unitFrames.FocusTarget:FocusTarget()
    print("FocusTarget.")
end