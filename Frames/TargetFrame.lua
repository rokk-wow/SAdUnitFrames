local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.Target = addon.unitFrames.Target or {}

function addon.unitFrames.Target:Target()
    print("Target.")
end