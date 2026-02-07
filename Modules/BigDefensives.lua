local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

local FILTER = "HELPFUL|BIG_DEFENSIVE|CANCELABLE"
local MAX_SCAN = 40

function addon:CreateBigDefensives(frame, panelHeight, options)
    local modCfg = self.config.modules.bigDefensives
    return self:CreateBigAuraFrame(frame, modCfg, panelHeight, "BigDefensives", "buff", options)
end

---------------------------------------------------------------------------
-- oUF element: BigDefensives
-- Uses the server-side "HELPFUL|BIG_DEFENSIVE" filter to find major
-- defensive CDs (Ice Block, Shield Wall, etc.).
-- Takes the first result (Blizzard's internal priority ordering).
-- Uses data.icon pass-through and C_UnitAuras.GetAuraDuration for timing.
---------------------------------------------------------------------------

local function Update(self, event, unit)
    if self.unit ~= unit then return end

    local element = self.BigDefensives
    if not element then return end

    if element.PreUpdate then
        element:PreUpdate(unit)
    end

    -- Scan for big defensives (CANCELABLE excludes permanent passive buffs)
    local firstData = nil
    local matchCount = 0

    for i = 1, MAX_SCAN do
        local data = C_UnitAuras.GetAuraDataByIndex(unit, i, FILTER)
        if not data then break end
        matchCount = matchCount + 1
        if not firstData then
            firstData = data
        end
    end

    if firstData then
        -- Get safe DurationObject — its fields are secret, so pass it
        -- directly to BigAuraShow which uses SetCooldownFromDurationObject()
        local durationInfo = C_UnitAuras.GetAuraDuration(unit, firstData.auraInstanceID)

        -- data.icon is a secret value but can be passed directly to SetTexture
        element.Icon:SetTexture(firstData.icon)

        addon:BigAuraShow(
            element,
            firstData.icon,
            unit,
            firstData.auraInstanceID,
            durationInfo, -- DurationObject (not numeric start/duration)
            nil,
            matchCount
        )
    else
        addon:BigAuraHide(element)
    end

    if element.PostUpdate then
        element:PostUpdate(unit, firstData)
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