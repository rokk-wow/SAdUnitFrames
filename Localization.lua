local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

-- English
addon.locale.enEN = {
    arenaTitle = "Arena",
    frameStyleTitle = "Frame Style",
    frameStyleHeader = "Appearance",
    statusbarTexture = "Bar Texture",
    borderColor = "Border Color",
    backgroundColor = "Background Color",
    enabledFramesTitle = "Enabled Frames",
    enablePlayerFrame = "Enable Player Frame",
    enableTargetFrame = "Enable Target Frame",
    enablePetFrame = "Enable Pet Frame",
    enableFocusFrame = "Enable Focus Frame",
    disableFrameTitle = "Disable Frame",
    disableFrameMessage = "Disabling a frame requires a UI reload to take effect.",
    disableFrameConfirm = "Reload UI",
    disableFrameCancel = "Cancel",
}

-- Spanish
addon.locale.esES = {
    arenaTitle = "Arena",
}

addon.locale.esMX = addon.locale.esES

-- Portuguese
addon.locale.ptBR = {
    arenaTitle = "Arena",
}

-- French
addon.locale.frFR = {
    arenaTitle = "Arène",
}

-- German
addon.locale.deDE = {
    arenaTitle = "Arena",
}

-- Russian
addon.locale.ruRU = {
    arenaTitle = "Арена",
}
