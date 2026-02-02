local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.TargetTarget = addon.unitFrames.TargetTarget or {}

function addon.unitFrames.TargetTarget:TargetTarget()
    print("TargetTarget.")
end