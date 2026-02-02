local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.sadCore.savedVarsGlobalName = "SAdUnitFrames_Settings_Global"
addon.sadCore.savedVarsPerCharName = "SAdUnitFrames_Settings_Char"
addon.sadCore.compartmentFuncName = "SAdUnitFrames_Compartment_Func"
addon.activeChatFilters = {}

addon.vars = {
    borderWidth = 2,
    manaBarOffsetY = 2,
    borderColor = "#000000FF",
    backgroundColor = "#000000AA",
}

function addon:Initialize()
    self.author = "Rôkk-Wyrmrest Accord"

    local textures = {
        {value = "Blizzard", label = "Blizzard (Default)"},
        {value = "Minimalist", label = "Minimalist"},
        {value = "Flat", label = "Flat"},
        {value = "Glamour", label = "Glamour"},
        {value = "Smooth", label = "Smooth"},
        {value = "LiteStep", label = "LiteStep"},
        {value = "Perl", label = "Perl"},
        {value = "Charcoal", label = "Charcoal"},
        {value = "Otravi", label = "Otravi"},
        {value = "Aluminium", label = "Aluminium"},
        {value = "BantoBar", label = "BantoBar"},
        {value = "Bumps", label = "Bumps"},
        {value = "Cilo", label = "Cilo"},
        {value = "Cloud", label = "Cloud"},
        {value = "Gloss", label = "Gloss"},
        {value = "Graphite", label = "Graphite"},
        {value = "Healbot", label = "Healbot"},
        {value = "Round", label = "Round"},
        {value = "Ruben", label = "Ruben"},
        {value = "Skewed", label = "Skewed"},
        {value = "Smoothv2", label = "Smooth v2"},
        {value = "Steel", label = "Steel"},
    }

    self:AddSettingsPanel("frameStyle", {
        title = "frameStyleTitle",
        controls = {
            {
                type = "header",
                name = "frameStyleHeader"
            },
            {
                type = "dropdown",
                name = "statusbarTexture",
                default = "Smooth",
                options = textures,
                onValueChange = self.updateAllFrames
            },
        }
    })
    



    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.onPlayerEnteringWorld)   
    self:RegisterEvent("PLAYER_TARGET_CHANGED", self.onPlayerTargetChanged)    
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", self.onPlayerFocusChange)    
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", self.onPlayerSpecChange)
    self:RegisterEvent("UNIT_AURA", self.onUnitAura)
end

function addon:onPlayerEnteringWorld()
end

function addon:onPlayerTargetChanged()
end

function addon:onPlayerFocusChange()
end

function addon:onPlayerSpecChange()
end

function addon:onUnitAura()
end

function addon:UpdateAllFrames()
    self:UpdatePlayerFrame()
    self:UpdateFocusFrame()
    self:UpdateFocusTargetFrame()
    self:UpdatePetFrame()
    self:UpdateTargetFrame()
    self:UpdateTargetTargetFrame()
end

function addon:UpdatePlayerFrame()
    for key, value in pairs(addon.unitFrames.Player) do
        if type(value) == "function" then
            value(addon.unitFrames.Player)
        end
    end
end

function addon:UpdateFocusFrame()
    for key, value in pairs(addon.unitFrames.FocusFrame) do
        if type(value) == "function" then
            value(addon.unitFrames.FocusFrame)
        end
    end
end

function addon:UpdateFocusTargetFrame()
    for key, value in pairs(addon.unitFrames.FocusTarget) do
        if type(value) == "function" then
            value(addon.unitFrames.FocusTarget)
        end
    end
end

function addon:UpdatePetFrame()
    for key, value in pairs(addon.unitFrames.Pet) do
        if type(value) == "function" then
            value(addon.unitFrames.Pet)
        end
    end
end

function addon:UpdateTargetFrame()
    for key, value in pairs(addon.unitFrames.Target) do
        if type(value) == "function" then
            value(addon.unitFrames.Target)
        end
    end
end

function addon:UpdateTargetTargetFrame()
    for key, value in pairs(addon.unitFrames.TargetTarget) do
        if type(value) == "function" then
            value(addon.unitFrames.TargetTarget)
        end
    end
end

