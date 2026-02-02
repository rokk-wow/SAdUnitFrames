local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.Player = addon.unitFrames.Player or {}

function addon.unitFrames.Player:Player()
    print("Player.")
end