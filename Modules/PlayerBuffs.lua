local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreatePlayerBuffs(frame, totalWidth, totalHeight, options)
    if not frame then
        return nil
    end

    if not self.config.modules.playerBuffs.enabled then return nil end

    local cfg = self.config.global
    options = options or {}
    local size = options.size or (totalHeight / 2.75)
    local spacingX = options.spacingX or cfg.buffSpacingX
    local maxCols = options.maxCols or math.max(1, math.floor((totalWidth + spacingX) / (size + spacingX)))
    local num = options.num or maxCols

    local buffs = CreateFrame("Frame", nil, frame)
    buffs:SetPoint(options.anchor or "BOTTOMRIGHT",
        options.relativeTo or frame,
        options.relativePoint or "BOTTOMRIGHT",
        options.offsetX or 0,
        options.offsetY or 0)

    buffs:SetSize(totalWidth, size)
    buffs.size = size
    buffs.num = num
    buffs.maxCols = maxCols
    buffs.spacingX = spacingX
    buffs.spacingY = options.spacingY or cfg.buffSpacingY
    buffs.initialAnchor = options.initialAnchor or "BOTTOMRIGHT"
    buffs.growthX = options.growthX or "LEFT"
    buffs.growthY = options.growthY or "UP"
    buffs.tooltipAnchor = options.tooltipAnchor or "ANCHOR_TOP"
    buffs.filter = options.filter or "HELPFUL"

    -- Sort by auraInstanceID only (stable order, oldest first).
    -- Default oUF sort also checks isPlayerAura which can cause reordering.
    -- Since we already filter to player-only, that check is redundant.
    buffs.SortBuffs = function(a, b)
        return a.auraInstanceID < b.auraInstanceID
    end

    -- Visibility caches: keyed by auraInstanceID, populated out of combat
    -- when secret values are accessible.  Two caches because Blizzard uses
    -- different visibility rules in and out of combat (RaidInCombat is much
    -- stricter — hides passive / non-cancelable buffs that show out of combat).
    local displayCacheOOC = {} -- out-of-combat visibility
    local displayCacheIC  = {} -- in-combat visibility

    -- Clear caches when leaving combat so the next update rebuilds them fresh
    local cacheFrame = CreateFrame("Frame")
    cacheFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    cacheFrame:SetScript("OnEvent", function()
        wipe(displayCacheOOC)
        wipe(displayCacheIC)
    end)

    buffs.FilterAura = function(element, unit, data)
        if not data.isPlayerAura then
            return false
        end

        local id = data.auraInstanceID
        if UnitAffectingCombat("player") then
            local cached = displayCacheIC[id]
            if cached ~= nil then
                return cached
            end
            -- Uncached = new aura during combat (e.g. a HoT the player
            -- just cast).  Passive / non-cancelable buffs are always
            -- present BEFORE combat and will already be cached as hidden
            -- via the RaidInCombat check, so showing unknowns is safe.
            return true
        end

        -- Out of combat: evaluate and cache for BOTH states
        if displayCacheOOC[id] == nil then
            -- Helper: run Blizzard's visibility check for a given visType
            local function evaluate(visType)
                local hasCustom, alwaysShowMine, showForMySpec =
                    C_Spell.GetVisibilityInfo(data.spellId, visType)
                if hasCustom then
                    return showForMySpec
                        or (alwaysShowMine
                            and (data.sourceUnit == "player"
                              or data.sourceUnit == "pet"
                              or data.sourceUnit == "vehicle"))
                else
                    return data.canApplyAura and not C_Spell.IsSelfBuff(data.spellId)
                end
            end

            displayCacheOOC[id] = evaluate(Enum.SpellAuraVisibilityType.RaidOutOfCombat)
            displayCacheIC[id]  = evaluate(Enum.SpellAuraVisibilityType.RaidInCombat)
        end

        return displayCacheOOC[id]
    end

    local modCfg = self.config.modules.playerBuffs

    buffs.PostCreateButton = function(element, button)
        addon:CreateAuraPostCreateButton(button, addon:GetFontPath(), cfg.extraSmallFontSize)
        if button.Cooldown then
            button.Cooldown.noCooldownCount = not modCfg.showCooldownNumbers
            button.Cooldown:SetHideCountdownNumbers(not modCfg.showCooldownNumbers)
            button.Cooldown:SetReverse(true)
        end
    end


    frame.Buffs = buffs
    frame.PlayerBuffs = buffs

    return buffs
end
