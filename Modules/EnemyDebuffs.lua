local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

---------------------------------------------------------------------------
-- EnemyDebuffs – shows all hostile (HARMFUL) debuffs on the unit.
--
-- Leverages oUF's built-in Debuffs element (elements/auras.lua) which
-- handles aura tracking, button recycling, cooldowns via DurationObject,
-- tooltips via SetUnitDebuffByAuraInstanceID, and sorting.
-- All rendering is secret-value-safe.
---------------------------------------------------------------------------
function addon:CreateEnemyDebuffs(frame, panelHeight, options)
    if not frame then
        return nil
    end

    if not self.config.modules.enemyDebuffs.enabled then return nil end

    local cfg = self.config.global
    local modCfg = self.config.modules.enemyDebuffs
    options = options or {}

    local spacing = options.spacing or 2
    local height = options.height or math.floor((panelHeight * 0.34) - (spacing / 2)) + 1
    local size = height -- square icons matching castbar height
    local num = options.num or 4

    -- Container frame – oUF's aura element uses this as the parent
    local debuffs = CreateFrame("Frame", nil, frame)
    debuffs:SetPoint(
        options.anchor or "BOTTOMLEFT",
        options.relativeTo or frame,
        options.relativePoint or "BOTTOMLEFT",
        options.offsetX or 0,
        options.offsetY or 0
    )
    debuffs:SetSize(num * (size + spacing), size)

    -- oUF Debuffs element configuration
    debuffs.num = num
    debuffs.size = size
    debuffs.spacing = spacing
    debuffs.initialAnchor = options.initialAnchor or "BOTTOMRIGHT"
    debuffs.growthX = options.growthX or "LEFT"
    debuffs.growthY = options.growthY or "UP"
    debuffs.filter = "HARMFUL"
    debuffs.tooltipAnchor = options.tooltipAnchor or "ANCHOR_TOP"
    debuffs.showDebuffType = true
    debuffs.disableMouse = false

    -- Style each button via the shared helper
    debuffs.PostCreateButton = function(element, button)
        addon:CreateAuraPostCreateButton(button, addon:GetFontPath(), cfg.extraSmallFontSize)
        if button.Cooldown then
            button.Cooldown.noCooldownCount = not modCfg.showCooldownNumbers
            button.Cooldown:SetHideCountdownNumbers(not modCfg.showCooldownNumbers)
            button.Cooldown:SetReverse(true)
        end
    end

    -- Register as oUF's Debuffs element so it gets UNIT_AURA updates
    frame.Debuffs = debuffs
    frame.EnemyDebuffs = debuffs

    return debuffs
end