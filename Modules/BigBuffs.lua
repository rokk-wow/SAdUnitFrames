---------------------------------------------------------------------------
-- BigBuffs.lua
-- Shows the highest-priority "important" offensive buff on a unit.
--
-- CURRENT APPROACH (layered, disabled in config):
--   Pre-creates 40 hidden layer frames.  Iterates all HELPFUL auras,
--   passes data.icon → SetTexture() (secret pass-through), then uses
--   SetAlphaFromBoolean(C_Spell.IsSpellImportant(data.spellId)) so only
--   "important" layers become visible.  Drawback: Lua cannot read the
--   secret alpha, so glow, accurate count, and tooltip are unreliable.
--
-- PREFERRED APPROACH (pending in-game verification):
--   Use the new "HELPFUL|IMPORTANT" server-side filter (added Beta 9,
--   Feb 2026).  This mirrors the BigDefensives pattern — iterate
--   GetAuraDataByIndex() with the filter, take the first match, use
--   data.icon pass-through and GetAuraDuration() for safe timing.
--   Glow, count, and tooltip all work correctly because we know the
--   match from the filter result (no secret boolean involved).
--
-- TODO: Test "HELPFUL|IMPORTANT" in-game.  If it returns expected
--   offensive CDs/procs, rewrite Update() to use the clean pattern
--   and remove the layered infrastructure.
--
-- Sources:
--   - Patch 12.0.0 Planned API Changes, Beta 9 (Feb 3 2026):
--     "Added a new IMPORTANT filter type for Aura APIs"
--   - warcraft.wiki.gg/wiki/Patch_12.0.0/Planned_API_changes
---------------------------------------------------------------------------
local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

local MAX_AURAS = 40

function addon:CreateBigBuffs(frame, panelHeight, options)
    local modCfg = self.config.modules.bigBuffs
    local element = self:CreateBigAuraFrame(frame, modCfg, panelHeight, "BigBuffs", "buff", options)
    if not element then return nil end

    -- Pre-create layered slots for secret-safe display.
    -- Each layer is an icon + cooldown pair whose alpha is driven by
    -- SetAlphaFromBoolean(C_Spell.IsSpellImportant(data.spellId)).
    -- Only "important" auras become visible; the rest sit at alpha 0.
    -- Layers stack so the topmost visible one is what the player sees.
    element.layers = {}
    for i = 1, MAX_AURAS do
        local layerFrame = CreateFrame("Frame", nil, element)
        layerFrame:SetAllPoints()
        layerFrame:SetFrameLevel(element:GetFrameLevel() + i)

        local layerIcon = layerFrame:CreateTexture(nil, "ARTWORK")
        layerIcon:SetAllPoints()
        layerIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        local layerCD = CreateFrame("Cooldown", nil, layerFrame, "CooldownFrameTemplate")
        layerCD:SetAllPoints()
        layerCD:SetDrawEdge(false)
        layerCD:SetReverse(true)
        layerCD:EnableMouse(false)
        layerCD.noCooldownCount = not modCfg.showCooldownNumbers
        layerCD:SetHideCountdownNumbers(not modCfg.showCooldownNumbers)

        layerFrame:Hide()

        element.layers[i] = {
            Frame = layerFrame,
            Icon = layerIcon,
            Cooldown = layerCD,
        }
    end

    -- Proc glow should render above all layers
    if element.ProcGlow then
        element.ProcGlow:SetFrameLevel(element:GetFrameLevel() + MAX_AURAS + 1)
    end

    -- Count text should render above everything
    if element.Count then
        element.Count:SetDrawLayer("OVERLAY", 7)
    end

    return element
end

---------------------------------------------------------------------------
-- oUF element: BigBuffs
-- Shows the highest-stacked "important" helpful aura on the unit.
-- Uses C_Spell.IsSpellImportant() with SetAlphaFromBoolean() to handle
-- secret boolean values without ever reading them in Lua.
---------------------------------------------------------------------------

local function Update(self, event, unit)
    if self.unit ~= unit then return end

    local element = self.BigBuffs
    if not element then return end

    if element.PreUpdate then
        element:PreUpdate(unit)
    end

    -- Hide the shared icon/cooldown from CreateBigAuraFrame —
    -- we use per-layer icons instead
    element.Icon:Hide()
    if element.Cooldown then element.Cooldown:Hide() end

    local used = 0

    for i = 1, MAX_AURAS do
        local data = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
        if not data then break end

        used = used + 1
        local layer = element.layers[used]
        if not layer then break end

        -- Secret pass-through: icon texture
        layer.Icon:SetTexture(data.icon)

        -- Safe timing via GetAuraDuration
        local durationInfo = C_UnitAuras.GetAuraDuration(unit, data.auraInstanceID)
        local start = durationInfo and durationInfo:GetStartTime()
        local duration = durationInfo and durationInfo:GetTotalDuration()

        if start and duration and duration > 0 then
            layer.Cooldown:SetCooldown(start, duration)
            layer.Cooldown:Show()
        else
            layer.Cooldown:Hide()
        end

        -- Secret boolean pass-through: show only if important
        local isImportant = C_Spell.IsSpellImportant(data.spellId)
        layer.Frame:SetAlphaFromBoolean(isImportant)
        layer.Frame:Show()

        -- Store auraInstanceID on the layer for tooltip
        layer.auraInstanceID = data.auraInstanceID
    end

    -- Hide unused layers
    for i = used + 1, MAX_AURAS do
        local layer = element.layers[i]
        if layer then
            layer.Frame:Hide()
        end
    end

    -- We cannot read the secret alpha to know how many layers are truly
    -- visible (important), so we always show the placeholder.  When an
    -- important aura IS active its layer (higher frame level) naturally
    -- covers the placeholder.
    if element.Placeholder then element.Placeholder:Show() end

    -- Glow: we can't reliably know if any layer is important from Lua,
    -- so we hide the shared glow.  Per-layer glow could be added later.
    if element.ProcGlow then
        element.ProcGlow.ProcLoop:Stop()
        element.ProcGlow:Hide()
    end

    element.activeAuraInstanceID = used > 0 and element.layers[1].auraInstanceID or nil
    element.activeUnit = used > 0 and unit or nil

    -- Count display (shared BigAura count label)
    if element.Count then
        if used >= 2 then
            element.Count:SetText(used)
            element.Count:Show()
        else
            element.Count:Hide()
        end
    end

    if element.PostUpdate then
        element:PostUpdate(unit, nil)
    end
end

local function Enable(self)
    local element = self.BigBuffs
    if element then
        self:RegisterEvent("UNIT_AURA", Update)
        return true
    end
end

local function Disable(self)
    local element = self.BigBuffs
    if element then
        -- Hide all layers
        for i = 1, MAX_AURAS do
            local layer = element.layers[i]
            if layer then layer.Frame:Hide() end
        end
        addon:BigAuraHide(element)
        self:UnregisterEvent("UNIT_AURA", Update)
    end
end

oUF:AddElement("BigBuffs", Update, Enable, Disable)