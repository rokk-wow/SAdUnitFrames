local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.Player = addon.unitFrames.Player or {}

function addon.unitFrames.Player:Show()
    if not self.frame then
        self:Initialize()
    end
    if self.frame then
        self.frame:Show()
    end
end

function addon.unitFrames.Player:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

-- Register custom oUF tags for abbreviated health values
oUF.Tags.Methods['SAdUnitFrames:shorthp'] = function(unit)
    return AbbreviateNumbers(UnitHealth(unit))
end
oUF.Tags.Events['SAdUnitFrames:shorthp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['SAdUnitFrames:shortmaxhp'] = function(unit)
    return AbbreviateNumbers(UnitHealthMax(unit))
end
oUF.Tags.Events['SAdUnitFrames:shortmaxhp'] = 'UNIT_MAXHEALTH'

function addon.unitFrames.Player:Initialize()
    if not oUF then
        print("PlayerFrame: oUF not available")
        return
    end
    
    if self.frame then
        return
    end
    
    -- Hide default Blizzard buff/debuff frames
    BuffFrame:UnregisterAllEvents()
    BuffFrame:Hide()
    
    oUF:RegisterStyle('SAdUnitFrames_Player', function(frame, unit)
        addon.unitFrames.Player:StylePlayer(frame, unit)
    end)
    oUF:SetActiveStyle('SAdUnitFrames_Player')
    
    self.frame = oUF:Spawn('player', 'SAdUnitFrames_PlayerFrame')

    if self.frame then
        C_Timer.After(.1, function()
            if self.frame then
                self.frame:UpdateAllElements('RefreshUnit')
            end
        end)
    end
end

function addon.unitFrames.Player:StylePlayer(frame, unit)
    local cfg = addon.config.global
    
    frame:SetSize(cfg.primaryFramesWidth, cfg.primaryFramesHeight)
    
    -- Enable mouse clicks
    frame:RegisterForClicks('AnyUp')
    
    -- Position: top right of player frame attaches to top left of action bar
    frame:SetPoint(cfg.playerFrameAnchor, _G[cfg.playerFrameRelativeTo], cfg.playerFrameRelativePoint, cfg.playerFrameOffsetX, cfg.playerFrameOffsetY)
    
    -- Background
    local Background = frame:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(frame)
    local bgR, bgG, bgB, bgA = addon:HexToRGB(cfg.backgroundColor)
    Background:SetColorTexture(bgR, bgG, bgB, bgA)
    
    -- Health Bar
    local Health = CreateFrame('StatusBar', nil, frame)
    Health:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
    Health:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
    Health:SetHeight(cfg.primaryFramesHeight * cfg.healthBarPercent)
    Health:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.healthTexture)
    
    -- Set color to class color
    local _, class = UnitClass('player')
    local classColor = RAID_CLASS_COLORS[class]
    Health:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
    
    local borderR, borderG, borderB, borderA = addon:HexToRGB(cfg.borderColor)
    
    -- Health name text (left side)
    Health.name = Health:CreateFontString(nil, 'OVERLAY')
    local fontPath = addon:GetFontPath()
    Health.name:SetFont(fontPath, cfg.smallFontSize, 'OUTLINE')
    Health.name:SetPoint('LEFT', Health, 'LEFT', 5, 0)
    Health.name:SetJustifyH('LEFT')
    Health.name:SetWidth(cfg.primaryFramesWidth / 2)
    Health.name:SetWordWrap(false)
    Health.name:SetText(UnitName('player'))
    
    -- Health value text (right side)
    Health.value = Health:CreateFontString(nil, 'OVERLAY')
    Health.value:SetFont(fontPath, cfg.smallFontSize, 'OUTLINE')
    Health.value:SetPoint('RIGHT', Health, 'RIGHT', -5, 0)
    Health.value:SetJustifyH('RIGHT')
    Health.value.frequentUpdates = true
    frame:Tag(Health.value, '[perhp]% / [SAdUnitFrames:shortmaxhp]')
    
    -- Add border
    addon:AddBorder(Health)
    
    frame.Health = Health
    
    -- Health Prediction (damage absorbs only)
    local HealthPrediction = {}
    
    -- Damage absorbs (shields)
    local damageAbsorb = CreateFrame('StatusBar', nil, Health)
    damageAbsorb:SetPoint('TOP')
    damageAbsorb:SetPoint('BOTTOM')
    damageAbsorb:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
    damageAbsorb:SetPoint('RIGHT', Health, 'RIGHT')
    damageAbsorb:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.absorbTexture)
    damageAbsorb:SetStatusBarColor(classColor.r, classColor.g, classColor.b, cfg.absorbOpacity)
    HealthPrediction.damageAbsorb = damageAbsorb
    HealthPrediction.maxOverflow = cfg.maxAbsorbOverflow
    
    
    frame.HealthPrediction = HealthPrediction
    
    -- Cast Bar
    local Castbar = CreateFrame('StatusBar', nil, frame)
    Castbar:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, -1)
    Castbar:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 0, -1)
    Castbar:SetHeight(cfg.castBarHeight)
    Castbar:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.castBarTexture)
    Castbar:SetStatusBarColor(1, 0.7, 0)
    Castbar:Hide() -- Hidden by default, shown when casting
    
    -- Castbar background
    local CastbarBG = Castbar:CreateTexture(nil, 'BORDER')
    CastbarBG:SetAllPoints()
    CastbarBG:SetTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.castBarTexture)
    CastbarBG:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    Castbar.bg = CastbarBG
    
    -- Add border to castbar
    addon:AddBorder(Castbar)
    
    -- Cast name text (left aligned)
    local CastText = Castbar:CreateFontString(nil, 'OVERLAY')
    CastText:SetFont(fontPath, cfg.smallFontSize, 'OUTLINE')
    CastText:SetPoint('LEFT', Castbar, 'LEFT', 5, 0)
    CastText:SetWidth(190) -- Truncate with ellipsis to fit bar width
    CastText:SetWordWrap(false)
    CastText:SetJustifyH('LEFT')
    Castbar.Text = CastText
    
    -- Safezone for latency
    local SafeZone = Castbar:CreateTexture(nil, 'OVERLAY')
    SafeZone:SetTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.castBarTexture)
    SafeZone:SetVertexColor(1, 0, 0, 0.6)
    Castbar.SafeZone = SafeZone
    
    frame.Castbar = Castbar
    
    -- Power Display (varies by class/spec)
    local powerDisplayType = addon:GetPowerDisplayType('player')
    
    if powerDisplayType == "runes" then
        -- Death Knight Runes
        local Runes = CreateFrame('Frame', nil, frame)
        Runes:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, 2)
        Runes:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, 2)
        Runes:SetHeight(cfg.primaryFramesHeight * cfg.powerBarPercent)
        
        local runeR, runeG, runeB = addon:HexToRGB(cfg.runesColor)
        
        for i = 1, 6 do
            local Rune = CreateFrame('StatusBar', nil, Runes)
            Rune:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.powerTexture)
            Rune:SetStatusBarColor(runeR, runeG, runeB)
            
            if i == 1 then
                Rune:SetPoint('TOPLEFT', Runes, 'TOPLEFT', 0, 0)
            else
                Rune:SetPoint('TOPLEFT', Runes[i-1], 'TOPRIGHT', 2, 0)
            end
            
            Rune:SetWidth((cfg.primaryFramesWidth - 10) / 6)
            Rune:SetHeight(cfg.primaryFramesHeight * cfg.powerBarPercent)
            
            addon:AddBorder(Rune)
            
            Runes[i] = Rune
        end
        
        frame.Runes = Runes
        
    elseif powerDisplayType == "classpower" then
        -- Combo Points / Chi / etc
        local ClassPower = CreateFrame('Frame', nil, frame)
        ClassPower:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, 2)
        ClassPower:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, 2)
        ClassPower:SetHeight(cfg.primaryFramesHeight * cfg.powerBarPercent)
        
        local cpR, cpG, cpB = addon:HexToRGB(cfg.comboPointColor)
        
        for i = 1, 6 do -- Max 6 for some classes
            local Point = CreateFrame('StatusBar', nil, ClassPower)
            Point:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.powerTexture)
            Point:SetStatusBarColor(cpR, cpG, cpB)
            
            if i == 1 then
                Point:SetPoint('TOPLEFT', ClassPower, 'TOPLEFT', 0, 0)
            else
                Point:SetPoint('TOPLEFT', ClassPower[i-1], 'TOPRIGHT', 2, 0)
            end
            
            Point:SetWidth((cfg.primaryFramesWidth - 10) / 6)
            Point:SetHeight(cfg.primaryFramesHeight * cfg.powerBarPercent)
            
            addon:AddBorder(Point)
            
            ClassPower[i] = Point
        end
        
        frame.ClassPower = ClassPower
        
    else
        -- Standard Power Bar (Mana, Rage, Focus, Energy, Runic Power, Lunar Power)
        local Power = CreateFrame('StatusBar', nil, frame)
        Power:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, 2)
        Power:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, 2)
        Power:SetHeight(cfg.primaryFramesHeight * cfg.powerBarPercent)
        Power:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.powerTexture)
        Power.colorPower = true -- Let oUF handle power type coloring
        Power.frequentUpdates = true
        
        -- Add border
        addon:AddBorder(Power)
        
        frame.Power = Power
    end
    
    -- Resting Indicator (create first so combat can reference it)
    local RestingFrame = CreateFrame('Frame', nil, frame)
    RestingFrame:SetFrameStrata('HIGH')
    RestingFrame:SetSize(32, 32)
    RestingFrame:SetPoint(cfg.combatRestingAnchor, _G[cfg.combatRestingRelativeTo], cfg.combatRestingRelativePoint, cfg.combatRestingOffsetX, cfg.combatRestingOffsetY)
    
    local Resting = RestingFrame:CreateTexture(nil, 'OVERLAY')
    Resting:SetAllPoints(RestingFrame)

    Resting:SetAtlas('plunderstorm-nameplates-icon-2', false)
    RestingFrame.PostUpdate = function(element, isResting)
        if isResting and not UnitAffectingCombat('player') then
            element:Show()
        else
            element:Hide()
        end
    end
    frame.RestingIndicator = RestingFrame
    
    local CombatFrame = CreateFrame('Frame', nil, frame)
    CombatFrame:SetFrameStrata('HIGH')
    CombatFrame:SetSize(30, 30)
    CombatFrame:SetPoint(cfg.combatRestingAnchor, _G[cfg.combatRestingRelativeTo], cfg.combatRestingRelativePoint, cfg.combatRestingOffsetX, cfg.combatRestingOffsetY)
    CombatFrame:Hide() -- Hidden by default
    
    local Combat = CombatFrame:CreateTexture(nil, 'OVERLAY')
    Combat:SetAllPoints(CombatFrame)
    Combat:SetAtlas('titleprestige-prestigeicon', false)
    
    CombatFrame.PostUpdate = function(element, inCombat)
        if inCombat then
            element:Show()
            RestingFrame:Hide()
        else
            element:Hide()
            -- Force resting indicator to update when leaving combat
            if IsResting() then
                RestingFrame:Show()
            end
        end
    end
    frame.CombatIndicator = CombatFrame
    
    -- Buffs
    local Buffs = CreateFrame('Frame', nil, frame)
    Buffs:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 1, -2)
    Buffs:SetSize(200, 80) -- Adjust height as needed for multiple rows
    Buffs.num = cfg.maxBuffs
    Buffs.size = cfg.buffSize
    Buffs.spacing = 1
    Buffs.initialAnchor = 'TOPLEFT'
    Buffs.growthX = 'RIGHT'
    Buffs.growthY = 'DOWN'
    Buffs.spacingX = cfg.buffSpacingX
    Buffs.spacingY = cfg.buffSpacingY
    Buffs.tooltipAnchor = 'ANCHOR_TOP'
    Buffs.all = {}
    Buffs.active = {}
    
    -- Custom buff creation to add black borders
    Buffs.PostCreateButton = function(element, button)
        addon:CreateAuraPostCreateButton(button, fontPath, cfg.extraSmallFontSize)
    end
    
    Buffs.tooltipAnchor = 'ANCHOR_TOP'
    
    frame.Buffs = Buffs
    
    -- Debuffs
    local Debuffs = CreateFrame('Frame', nil, frame)
    Debuffs:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, 25)
    Debuffs:SetSize(200, 80) -- Adjust height as needed for multiple rows
    Debuffs.num = cfg.maxDebuffs
    Debuffs.size = cfg.debuffSize
    Debuffs.spacing = 1
    Debuffs.initialAnchor = 'BOTTOMLEFT'
    Debuffs.growthX = 'RIGHT'
    Debuffs.growthY = 'UP'
    Debuffs.spacingX = cfg.debuffSpacingX
    Debuffs.spacingY = cfg.debuffSpacingY
    Debuffs.tooltipAnchor = 'ANCHOR_TOP'
    Debuffs.all = {}
    Debuffs.active = {}
    
    -- Custom debuff creation to add black borders
    Debuffs.PostCreateButton = function(element, button)
        addon:CreateAuraPostCreateButton(button, fontPath, cfg.extraSmallFontSize)
    end
    
    Debuffs.tooltipAnchor = 'ANCHOR_TOP'
    
    frame.Debuffs = Debuffs
end
