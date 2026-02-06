local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.TargetTarget = addon.unitFrames.TargetTarget or {}

function addon.unitFrames.TargetTarget:Show()
    if not self.frame then
        self:Initialize()
    end
    if self.frame then
        self.frame:Show()
    end
end

function addon.unitFrames.TargetTarget:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function addon.unitFrames.TargetTarget:Initialize()
    if not oUF then
        print("TargetTargetFrame: oUF not available")
        return
    end
    
    if self.frame then
        return
    end
    
    oUF:RegisterStyle('SAdUnitFrames_TargetTarget', function(frame, unit)
        addon.unitFrames.TargetTarget:StyleTargetTarget(frame, unit)
    end)
    oUF:SetActiveStyle('SAdUnitFrames_TargetTarget')
    
    self.frame = oUF:Spawn('targettarget', 'SAdUnitFrames_TargetTargetFrame')
end

function addon.unitFrames.TargetTarget:StyleTargetTarget(frame, unit)
    local cfg = addon.config.global
    
    frame:SetSize(cfg.minorFramesWidth, cfg.minorFramesHeight)
    
    -- Enable mouse clicks
    frame:RegisterForClicks('AnyUp')
    
    -- Position
    frame:SetPoint(cfg.targettargetFrameAnchor, _G[cfg.targettargetFrameRelativeTo], cfg.targettargetFrameRelativePoint, cfg.targettargetFrameOffsetX, cfg.targettargetFrameOffsetY)
    
    -- Background
    local Background = frame:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(frame)
    local bgR, bgG, bgB, bgA = addon:HexToRGB(cfg.backgroundColor)
    Background:SetColorTexture(bgR, bgG, bgB, bgA)
    
    -- Health Bar (100% height for medium frames)
    local Health = CreateFrame('StatusBar', nil, frame)
    Health:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
    Health:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
    Health:SetHeight(cfg.minorFramesHeight)
    Health:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.healthTexture)
    Health.colorClass = true
    Health.colorReaction = true
    
    local fontPath = addon:GetFontPath()
    
    -- Health name text
    Health.name = Health:CreateFontString(nil, 'OVERLAY')
    Health.name:SetFont(fontPath, cfg.extraSmallFontSize, 'OUTLINE')
    Health.name:SetPoint('LEFT', Health, 'LEFT', 5, 0)
    Health.name:SetJustifyH('LEFT')
    Health.name:SetWidth(cfg.minorFramesWidth - 10)
    Health.name:SetWordWrap(false)
    frame:Tag(Health.name, '[name]')
    
    -- Add border
    addon:AddBorder(Health)
    
    frame.Health = Health
end