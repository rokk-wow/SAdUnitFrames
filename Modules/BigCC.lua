local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreateBigCC(frame, panelHeight, options)
    local modCfg = self.config.modules.bigCC
    return self:CreateBigAuraFrame(frame, modCfg, panelHeight, "BigCC", "debuff", options)
end

---------------------------------------------------------------------------
-- oUF element: BigCC
-- Uses C_LossOfControl API to find and display the highest-priority CC
---------------------------------------------------------------------------

local function Update(self, event, unit)
    if self.unit ~= unit then return end

    local element = self.BigCC
    if not element then return end

    if element.PreUpdate then
        element:PreUpdate(unit)
    end

    -- Find highest priority CC via C_LossOfControl
    local highestPriorityCC = nil
    local highestPriority = -1

    local count = C_LossOfControl.GetActiveLossOfControlDataCountByUnit(unit)
    for i = 1, count do
        local locData = C_LossOfControl.GetActiveLossOfControlDataByUnit(unit, i)
        if locData and locData.priority and locData.priority > highestPriority then
            highestPriority = locData.priority
            highestPriorityCC = locData
        end
    end

    -- Get the actual aura data to confirm the aura still exists
    local auraData = nil
    if highestPriorityCC and highestPriorityCC.auraInstanceID then
        auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, highestPriorityCC.auraInstanceID)
    end

    if auraData then
        -- Show active CC — use C_LossOfControl fields (safe for addon code)
        addon:BigAuraShow(
            element,
            highestPriorityCC.iconTexture,
            unit,
            highestPriorityCC.auraInstanceID,
            highestPriorityCC.startTime or 0,
            highestPriorityCC.duration or 0
        )
    else
        addon:BigAuraHide(element)
    end

    if element.PostUpdate then
        element:PostUpdate(unit, auraData)
    end
end

local function Enable(self)
    local element = self.BigCC
    if element then
        self:RegisterEvent("UNIT_AURA", Update)
        return true
    end
end

local function Disable(self)
    local element = self.BigCC
    if element then
        addon:BigAuraHide(element)
        self:UnregisterEvent("UNIT_AURA", Update)
    end
end

oUF:AddElement("BigCC", Update, Enable, Disable)