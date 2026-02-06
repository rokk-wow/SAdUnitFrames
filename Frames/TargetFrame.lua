local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.Target = addon.unitFrames.Target or {}

function addon.unitFrames.Target:Show()
    if not self.frame then
        self:Initialize()
    end
    if self.frame then
        self.frame:Show()
    end
end

function addon.unitFrames.Target:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function addon.unitFrames.Target:Initialize()
    if not oUF then
        print("TargetFrame: oUF not available")
        return
    end
    
    if self.frame then
        return
    end
    
    oUF:RegisterStyle('SAdUnitFrames_Target', function(frame, unit)
        addon.unitFrames.Target:StyleTarget(frame, unit)
    end)
    oUF:SetActiveStyle('SAdUnitFrames_Target')
    
    self.frame = oUF:Spawn('target', 'SAdUnitFrames_TargetFrame')
end

function addon.unitFrames.Target:StyleTarget(frame, unit)
    local cfg = addon.config.global
    
    frame:SetSize(cfg.primaryFramesWidth, cfg.primaryFramesHeight)
    
    -- Enable mouse clicks
    frame:RegisterForClicks('AnyUp')
    
    -- Position
    frame:SetPoint(cfg.targetFrameAnchor, _G[cfg.targetFrameRelativeTo], cfg.targetFrameRelativePoint, cfg.targetFrameOffsetX, cfg.targetFrameOffsetY)
    
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
    Health.colorClass = true
    Health.colorReaction = true
    
    local fontPath = addon:GetFontPath()
    
    -- Health name text (left side)
    Health.name = Health:CreateFontString(nil, 'OVERLAY')
    Health.name:SetFont(fontPath, cfg.smallFontSize, 'OUTLINE')
    Health.name:SetPoint('LEFT', Health, 'LEFT', 5, 0)
    Health.name:SetJustifyH('LEFT')
    Health.name:SetWidth(cfg.primaryFramesWidth / 2)
    Health.name:SetWordWrap(false)
    frame:Tag(Health.name, '[name]')
    
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
    damageAbsorb:SetStatusBarColor(1, 1, 1, cfg.absorbOpacity)
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
    Castbar:Hide()
    
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
    CastText:SetWidth(190)
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
    local powerDisplayType = addon:GetPowerDisplayType('target')
    
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
    
    -- Buffs
    local Buffs = CreateFrame('Frame', nil, frame)
    Buffs:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 1, -2)
    Buffs:SetSize(200, 80)
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
    
    -- Custom buff creation
    Buffs.PostCreateButton = function(element, button)
        addon:CreateAuraPostCreateButton(button, fontPath, cfg.extraSmallFontSize)
    end
    
    Buffs.tooltipAnchor = 'ANCHOR_TOP'
    
    frame.Buffs = Buffs
    
    -- Debuffs
    local Debuffs = CreateFrame('Frame', nil, frame)
    Debuffs:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, 25)
    Debuffs:SetSize(200, 80)
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
    
    -- Custom debuff creation
    Debuffs.PostCreateButton = function(element, button)
        addon:CreateAuraPostCreateButton(button, fontPath, cfg.extraSmallFontSize)
    end
    
    Debuffs.tooltipAnchor = 'ANCHOR_TOP'
    
    frame.Debuffs = Debuffs
end