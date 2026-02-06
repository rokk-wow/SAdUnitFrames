local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreateBigDefensives(frame, panelHeight, options)
    local modCfg = self.config.modules.bigDefensives
    return self:CreateBigAuraFrame(frame, modCfg, panelHeight, "BigDefensives", "buff", options)
end

---------------------------------------------------------------------------
-- oUF element: BigDefensives
-- TODO: Implement aura-based update with a priority defensive list
---------------------------------------------------------------------------

local function Update(self, event, unit)
    if self.unit ~= unit then return end

    local element = self.BigDefensives
    if not element then return end

    if element.PreUpdate then
        element:PreUpdate(unit)
    end

    -- TODO: Scan unit auras for priority defensives and show the highest priority one
    -- For now, element stays in placeholder state

    if element.PostUpdate then
        element:PostUpdate(unit, nil)
    end
end

local function Enable(self)
    local element = self.BigDefensives
    if element then
        self:RegisterEvent("UNIT_AURA", Update)
        return true
    end
end

local function Disable(self)
    local element = self.BigDefensives
    if element then
        addon:BigAuraHide(element)
        self:UnregisterEvent("UNIT_AURA", Update)
    end
end

oUF:AddElement("BigDefensives", Update, Enable, Disable)