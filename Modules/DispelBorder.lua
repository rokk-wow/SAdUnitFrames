local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

---------------------------------------------------------------------------
-- DispelBorder Module
--
-- Shows a colored border around the health bar of friendly units that have
-- a dispellable debuff.  Border color matches the debuff type (Magic,
-- Curse, Disease, Poison, etc.) and is configurable in Config.lua.
--
-- Detection:
--   C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, colorCurve)
--   is secret-safe and returns a color mapped from the aura's dispel type.
--   The color curve has NO entry for DispelType.None (index 0), so
--   non-dispellable auras return nil — giving us a clean signal.
--
-- Color pass-through:
--   The returned color may contain secret values internally, so we NEVER
--   read or compare the RGBA components.  Instead we pass them directly
--   to SetBackdropBorderColor (which calls SetVertexColor internally,
--   a known secret-safe pass-through).
---------------------------------------------------------------------------

-- Build a dispelColorCurve from our config colors for GetAuraDispelTypeColor.
-- Intentionally omits DispelType.None so non-dispellable auras return nil.
local dispelColorCurve

local function EnsureDispelColorCurve()
    if dispelColorCurve then return end

    local modCfg = addon.config.modules.dispelBorder
    dispelColorCurve = C_CurveUtil.CreateColorCurve()
    dispelColorCurve:SetType(Enum.LuaCurveType.Step)

    local typeMap = {
        Magic   = oUF.Enum.DispelType.Magic,
        Curse   = oUF.Enum.DispelType.Curse,
        Disease = oUF.Enum.DispelType.Disease,
        Poison  = oUF.Enum.DispelType.Poison,
        Bleed   = oUF.Enum.DispelType.Bleed,
        Enrage  = oUF.Enum.DispelType.Enrage,
    }

    for name, enumVal in pairs(typeMap) do
        local c = modCfg.debuffTypeColors[name]
        if c then
            dispelColorCurve:AddPoint(enumVal, CreateColor(c.r, c.g, c.b, 1))
        end
    end
end

---------------------------------------------------------------------------
-- Frame builder
---------------------------------------------------------------------------
function addon:CreateDispelBorder(frame, options)
    if not frame or not frame.Health then
        return nil
    end

    local modCfg = self.config.modules.dispelBorder
    if not modCfg.enabled then return nil end

    options = options or {}
    local borderSize = options.borderSize or modCfg.borderSize or 3

    local dispelBorder = CreateFrame("Frame", nil, frame.Health, "BackdropTemplate")
    dispelBorder:SetPoint("TOPLEFT", frame.Health, "TOPLEFT", borderSize - 1, -(borderSize - 1))
    dispelBorder:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -(borderSize - 1), borderSize - 1)
    dispelBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = borderSize,
    })
    dispelBorder:SetBackdropBorderColor(1, 1, 1, 1)
    dispelBorder:SetFrameLevel(frame.Health:GetFrameLevel() + 5)
    dispelBorder:Hide()

    frame.DispelBorder = dispelBorder

    return dispelBorder
end

---------------------------------------------------------------------------
-- oUF element callbacks
---------------------------------------------------------------------------

local function Update(self, event, unit)
    if unit and self.unit ~= unit then return end

    local element = self.DispelBorder
    if not element then return end

    unit = self.unit
    if not unit or not UnitExists(unit) then
        element:Hide()
        return
    end

    -- Only show on friendly units
    if not UnitIsFriend("player", unit) then
        element:Hide()
        return
    end

    EnsureDispelColorCurve()

    local foundColor = nil

    -- Iterate all harmful auras on the unit
    local slots = {C_UnitAuras.GetAuraSlots(unit, "HARMFUL")}
    for i = 2, #slots do -- slot 1 is continuationToken
        local data = C_UnitAuras.GetAuraDataBySlot(unit, slots[i])
        if data and data.auraInstanceID then
            -- Skip auras that Blizzard doesn't consider raid-relevant
            -- (e.g. Temporal Displacement / Bloodlust exhaustion).
            -- IsAuraFilteredOutByInstanceID returns true when the aura
            -- does NOT match the filter, so we skip those.
            if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HARMFUL|RAID") then
                -- GetAuraDispelTypeColor maps the aura's dispel type through our
                -- curve.  No curve entry exists for None (type 0), so pcall
                -- catches the nil/error case for non-dispellable auras.
                local ok, color = pcall(
                    C_UnitAuras.GetAuraDispelTypeColor,
                    unit, data.auraInstanceID, dispelColorCurve
                )

                if ok and color then
                    foundColor = color
                    break -- show the first dispellable debuff's color
                end
            end
        end
    end

    if foundColor then
        -- Pass color directly to widget — secret-safe pass-through
        element:SetBackdropBorderColor(foundColor:GetRGBA())
        element:Show()
    else
        element:Hide()
    end
end

local function Enable(self)
    local element = self.DispelBorder
    if not element then return end

    self:RegisterEvent("UNIT_AURA", Update)

    -- Initial check
    Update(self, "Enable")
    return true
end

local function Disable(self)
    local element = self.DispelBorder
    if not element then return end

    element:Hide()
    self:UnregisterEvent("UNIT_AURA", Update)
end

oUF:AddElement("DispelBorder", Update, Enable, Disable)