local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.Pet = addon.unitFrames.Pet or {}

function addon.unitFrames.Pet:Pet()
    print("Pet.")
end