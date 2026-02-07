local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

---------------------------------------------------------------------------
-- Trinket Module — Gladiator's Medallion tracker
--
-- Shows the unit's PvP trinket (Gladiator's Medallion) and tracks its
-- cooldown.  The element is hidden entirely outside PvP instances.
--
-- Detection:
--   Player  → SecureCall(IsPlayerSpell, SPELL_ID).  Works out of combat
--             (arena gates haven't opened yet), returns false in combat
--             (safe fallback — by then we already know).
--   Others  → show placeholder in PvP instances; confirmed when we see
--             them use it via UNIT_SPELLCAST_SUCCEEDED.
--
-- States:
--   HIDDEN      – not in PvP instance, or player confirmed no medallion
--   PLACEHOLDER – in PvP instance, medallion not yet confirmed
--   READY       – medallion confirmed, available (icon + glow)
--   COOLDOWN    – medallion used, on cooldown (icon + swipe, no glow)
--
-- Usage tracking:
--   UNIT_SPELLCAST_SUCCEEDED provides spellID directly as an event arg
--   (NOT from C_UnitAuras), so it is safe to compare — no secret values.
--
-- Glow behaviour:
--   Glows when the trinket is confirmed and available for use.
--   Stops glowing when on cooldown.
---------------------------------------------------------------------------

local MEDALLION_SPELL_ID = 336126 -- Gladiator's Medallion
local MEDALLION_COOLDOWN = 120    -- 2 minutes

---------------------------------------------------------------------------
-- Frame builder
---------------------------------------------------------------------------
function addon:CreateTrinket(frame, panelHeight, options)
    if not frame then return nil end

    local modCfg = self.config.modules.trinket
    if not modCfg.enabled then return nil end

    options = options or {}
    local spacing = options.spacing or 2
    local height = options.height or math.floor((panelHeight * 0.66) - (spacing / 2))
    local width = height -- square

    local trinket = CreateFrame("Frame", nil, frame)
    trinket:SetPoint(
        options.anchor or "TOPRIGHT",
        options.relativeTo or frame,
        options.relativePoint or "TOPRIGHT",
        options.offsetX or 0,
        options.offsetY or 0
    )
    trinket:SetSize(width, height)

    -- Placeholder icon (desaturated, shown before detection)
    local placeholder = trinket:CreateTexture(nil, "BACKGROUND")
    placeholder:SetAllPoints(trinket)
    placeholder:SetTexture("Interface\\Icons\\" .. modCfg.placeholderIcon)
    placeholder:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    placeholder:SetDesaturated(true)
    placeholder:SetAlpha(modCfg.placeholderOpacity)
    trinket.Placeholder = placeholder

    -- Active icon (full-colour medallion, shown when detected)
    local icon = trinket:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(trinket)
    icon:SetTexture("Interface\\Icons\\ability_pvp_gladiatormedallion")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:Hide()
    trinket.Icon = icon

    -- Cooldown swipe overlay
    local cooldown = CreateFrame("Cooldown", nil, trinket, "CooldownFrameTemplate")
    cooldown:SetAllPoints(trinket)
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:EnableMouse(false)
    cooldown.noCooldownCount = not modCfg.showCooldownNumbers
    cooldown:SetHideCountdownNumbers(not modCfg.showCooldownNumbers)
    trinket.Cooldown = cooldown

    -- Proc glow (animated flipbook border)
    if modCfg.showGlow then
        local gc = modCfg.glowColor
        local procGlow = CreateFrame("Frame", nil, trinket)
        procGlow:SetSize(trinket:GetWidth() * 1.4, trinket:GetHeight() * 1.4)
        procGlow:SetPoint("CENTER")

        local procLoop = procGlow:CreateTexture(nil, "ARTWORK")
        procLoop:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
        procLoop:SetAllPoints(procGlow)
        procLoop:SetAlpha(0)

        if gc then
            procLoop:SetDesaturated(true)
            procLoop:SetVertexColor(gc.r, gc.g, gc.b)
        end

        procGlow.ProcLoopFlipbook = procLoop

        local procLoopAnim = procGlow:CreateAnimationGroup()
        procLoopAnim:SetLooping("REPEAT")

        local alpha = procLoopAnim:CreateAnimation("Alpha")
        alpha:SetChildKey("ProcLoopFlipbook")
        alpha:SetDuration(0.001)
        alpha:SetOrder(0)
        alpha:SetFromAlpha(1)
        alpha:SetToAlpha(1)

        local flip = procLoopAnim:CreateAnimation("FlipBook")
        flip:SetChildKey("ProcLoopFlipbook")
        flip:SetDuration(1)
        flip:SetOrder(0)
        flip:SetFlipBookRows(6)
        flip:SetFlipBookColumns(5)
        flip:SetFlipBookFrames(30)

        procGlow.ProcLoop = procLoopAnim
        procGlow:Hide()
        trinket.ProcGlow = procGlow
    end

    addon:AddBorder(trinket)

    -- Internal state
    trinket.hasMedallion = nil   -- nil = unknown, true = confirmed, false = confirmed no
    trinket.onCooldown = false
    trinket.cooldownStart = nil

    -- Start hidden until we know we're in a PvP instance
    trinket:Hide()

    frame.Trinket = trinket
    return trinket
end

---------------------------------------------------------------------------
-- Visual state helpers
---------------------------------------------------------------------------

--- Show the placeholder (in PvP, but medallion not yet confirmed).
local function ShowTrinketPlaceholder(element)
    element:Show()
    element.Icon:Hide()
    if element.Placeholder then
        element.Placeholder:Show()
        element.Placeholder:SetDesaturated(true)
    end
    if element.Cooldown then element.Cooldown:Hide() end
    if element.ProcGlow then
        element.ProcGlow.ProcLoop:Stop()
        element.ProcGlow:Hide()
    end
end

--- Trinket is confirmed and available — show icon with glow, no cooldown.
local function ShowTrinketReady(element)
    element:Show()
    element.Icon:Show()
    if element.Placeholder then element.Placeholder:Hide() end
    if element.Cooldown then element.Cooldown:Hide() end

    if element.ProcGlow then
        element.ProcGlow:Show()
        element.ProcGlow.ProcLoop:Play()
    end

    element.onCooldown = false
end

--- Trinket was just used — show icon with cooldown swipe, no glow.
local function ShowTrinketOnCooldown(element, startTime, duration)
    element:Show()
    element.Icon:Show()
    if element.Placeholder then element.Placeholder:Hide() end

    if element.Cooldown and duration > 0 then
        element.Cooldown:SetCooldown(startTime, duration)
        element.Cooldown:Show()
    end

    if element.ProcGlow then
        element.ProcGlow.ProcLoop:Stop()
        element.ProcGlow:Hide()
    end

    element.onCooldown = true
end

--- Not in PvP or player confirmed no medallion — hide entirely.
local function HideTrinket(element)
    element:Hide()
    element.Icon:Hide()
    if element.Placeholder then element.Placeholder:Show() end
    if element.Cooldown then element.Cooldown:Hide() end
    if element.ProcGlow then
        element.ProcGlow.ProcLoop:Stop()
        element.ProcGlow:Hide()
    end
    element.onCooldown = false
    element.cooldownStart = nil
end

---------------------------------------------------------------------------
-- Instance helpers
---------------------------------------------------------------------------
local function IsInPvPInstance()
    local _, instanceType = IsInInstance()
    return instanceType == "arena" or instanceType == "pvp"
end

---------------------------------------------------------------------------
-- oUF element callbacks
---------------------------------------------------------------------------

local function Update(self, event, unit, castGUID, spellID)
    local element = self.Trinket
    if not element then return end

    -- UNIT_SPELLCAST_SUCCEEDED: detect trinket usage
    -- spellID is a secret value for non-player units, so guard the comparison
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if not issecretvalue(spellID) and spellID == MEDALLION_SPELL_ID then
            element.hasMedallion = true
            element.cooldownStart = GetTime()
            ShowTrinketOnCooldown(element, element.cooldownStart, MEDALLION_COOLDOWN)

            -- Schedule transition back to ready when cooldown expires
            C_Timer.After(MEDALLION_COOLDOWN, function()
                if element.hasMedallion and element.cooldownStart then
                    local elapsed = GetTime() - element.cooldownStart
                    if elapsed >= MEDALLION_COOLDOWN - 0.5 then
                        ShowTrinketReady(element)
                    end
                end
            end)
        end
        return
    end

    -- Not in PvP — hide completely
    if not IsInPvPInstance() then
        element.hasMedallion = nil
        HideTrinket(element)
        return
    end

    -- In PvP instance: determine medallion status
    if element.hasMedallion == nil then
        -- Unknown — try to detect
        if UnitIsUnit(self.unit, "player") then
            -- SecureCall works out of combat (arena hasn't started yet);
            -- returns false during combat (safe — we already know by then)
            local hasSpell = addon:SecureCall(IsPlayerSpell, MEDALLION_SPELL_ID)
            if hasSpell then
                element.hasMedallion = true
            elseif hasSpell == false and not InCombatLockdown() then
                -- Definitively no medallion (out of combat, reliable result)
                element.hasMedallion = false
            end
            -- If SecureCall returned false during combat, stay unknown (nil)
        end
        -- For non-player units we can't check — stays nil (placeholder)
    end

    -- Render appropriate state
    if element.hasMedallion == false then
        -- Player confirmed no medallion
        HideTrinket(element)
    elseif element.hasMedallion == true then
        -- Confirmed has medallion — show ready or cooldown
        if element.onCooldown and element.cooldownStart then
            local elapsed = GetTime() - element.cooldownStart
            if elapsed >= MEDALLION_COOLDOWN then
                ShowTrinketReady(element)
            end
        elseif not element.onCooldown then
            ShowTrinketReady(element)
        end
    else
        -- Unknown (non-player units) — show placeholder
        ShowTrinketPlaceholder(element)
    end
end

local function Enable(self)
    local element = self.Trinket
    if not element then return end

    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", Update, true)
    self:RegisterEvent("ARENA_OPPONENT_UPDATE", Update, true)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", Update, true)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", Update, true)

    -- Initial check
    Update(self, "Enable")
    return true
end

local function Disable(self)
    local element = self.Trinket
    if not element then return end

    HideTrinket(element)
    self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
    self:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", Update)
    self:UnregisterEvent("ARENA_OPPONENT_UPDATE", Update)
    self:UnregisterEvent("GROUP_ROSTER_UPDATE", Update)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
end

oUF:AddElement("Trinket", Update, Enable, Disable)