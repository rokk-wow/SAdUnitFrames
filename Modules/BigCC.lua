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
-- Player unit:  C_LossOfControl API (provides safe fields + priority).
-- Other units:  HARMFUL|CROWD_CONTROL aura filter + DurationObject.
--               Bleeds are excluded (CROWD_CONTROL filter is broader than
--               expected and can include bleed effects).
---------------------------------------------------------------------------

-- Color curve with only the Bleed dispel type — used to detect and skip bleeds.
-- If GetAuraDispelTypeColor returns a hit on this curve, the aura is a bleed.
local bleedCurve

local function EnsureBleedCurve()
    if bleedCurve then return end
    bleedCurve = C_CurveUtil.CreateColorCurve()
    bleedCurve:SetType(Enum.LuaCurveType.Step)
    bleedCurve:AddPoint(oUF.Enum.DispelType.Bleed, CreateColor(1, 0, 0, 1))
end

local function IsBleed(unit, auraInstanceID)
    EnsureBleedCurve()
    local ok, color = pcall(C_UnitAuras.GetAuraDispelTypeColor, unit, auraInstanceID, bleedCurve)
    return ok and color ~= nil
end

--- Player path – C_LossOfControl gives us safe iconTexture, startTime, duration.
local function UpdatePlayer(self, element, unit)
    local highestPriorityCC = nil
    local highestPriority = -1
    local matchCount = 0

    local count = C_LossOfControl.GetActiveLossOfControlDataCountByUnit(unit)
    for i = 1, count do
        local locData = C_LossOfControl.GetActiveLossOfControlDataByUnit(unit, i)
        if locData then
            matchCount = matchCount + 1
            if locData.priority and locData.priority > highestPriority then
                highestPriority = locData.priority
                highestPriorityCC = locData
            end
        end
    end

    local auraData = nil
    if highestPriorityCC and highestPriorityCC.auraInstanceID then
        auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, highestPriorityCC.auraInstanceID)
    end

    if auraData then
        addon:BigAuraShow(
            element,
            highestPriorityCC.iconTexture,
            unit,
            highestPriorityCC.auraInstanceID,
            highestPriorityCC.startTime or 0,
            highestPriorityCC.duration or 0,
            matchCount
        )
    else
        addon:BigAuraHide(element)
    end

    return auraData
end

--- Non-player path – iterate HARMFUL|CROWD_CONTROL auras.
--- Bleeds are excluded. Icon is passed through (secret-safe), cooldown via DurationObject.
local function UpdateOther(self, element, unit)
    local matchCount = 0
    local firstSlot = nil

    local slots = { C_UnitAuras.GetAuraSlots(unit, "HARMFUL|CROWD_CONTROL") }
    for i = 2, #slots do
        local data = C_UnitAuras.GetAuraDataBySlot(unit, slots[i])
        if data and not IsBleed(unit, data.auraInstanceID) then
            matchCount = matchCount + 1
            if not firstSlot then
                firstSlot = slots[i]
            end
        end
    end

    if firstSlot then
        local data = C_UnitAuras.GetAuraDataBySlot(unit, firstSlot)
        if data then
            local durationObj = C_UnitAuras.GetAuraDuration(unit, data.auraInstanceID)
            -- DurationObject mode: pass durationObj as 5th arg, nil 6th
            addon:BigAuraShow(
                element,
                data.icon,               -- secret pass-through to SetTexture
                unit,
                data.auraInstanceID,
                durationObj,             -- DurationObject → SetCooldownFromDurationObject
                nil,                     -- nil duration triggers DurationObject path
                matchCount
            )
            return data
        end
    end

    addon:BigAuraHide(element)
    return nil
end

local function Update(self, event, unit)
    if self.unit ~= unit then return end

    local element = self.BigCC
    if not element then return end

    if element.PreUpdate then
        element:PreUpdate(unit)
    end

    local auraData
    if UnitIsUnit(unit, "player") then
        auraData = UpdatePlayer(self, element, unit)
    else
        auraData = UpdateOther(self, element, unit)
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