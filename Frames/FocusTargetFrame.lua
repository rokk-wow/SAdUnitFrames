local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.FocusTarget = addon.unitFrames.FocusTarget or {}

function addon.unitFrames.FocusTarget:Show()
    if not self.frame then
        self:Initialize()
    end
    if self.frame then
        self.frame:Show()
    end
end

function addon.unitFrames.FocusTarget:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function addon.unitFrames.FocusTarget:Initialize()
    if not oUF then
        print("FocusTargetFrame: oUF not available")
        return
    end
    
    if self.frame then
        return
    end
    
    oUF:RegisterStyle('SAdUnitFrames_FocusTarget', function(frame, unit)
        addon.unitFrames.FocusTarget:StyleFocusTarget(frame, unit)
    end)
    oUF:SetActiveStyle('SAdUnitFrames_FocusTarget')
    
    self.frame = oUF:Spawn('focustarget', 'SAdUnitFrames_FocusTargetFrame')
end

function addon.unitFrames.FocusTarget:StyleFocusTarget(frame, unit)
    local cfg = addon.config.global
    
    -- Frame size (small)
    frame:SetSize(cfg.tinyFramesWidth, cfg.tinyFramesHeight)
    
    -- Position
    frame:ClearAllPoints()
    frame:SetPoint(cfg.focustargetFrameAnchor, cfg.focustargetFrameRelativeTo, cfg.focustargetFrameRelativePoint, cfg.focustargetFrameOffsetX, cfg.focustargetFrameOffsetY)
    
    -- Background
    local bgR, bgG, bgB, bgA = addon:HexToRGB(cfg.backgroundColor)
    local bg = frame:CreateTexture(nil, 'BACKGROUND')
    bg:SetAllPoints(frame)
    bg:SetColorTexture(bgR, bgG, bgB, bgA)
    
    -- Health Bar (100% height for small frames)
    local Health = CreateFrame('StatusBar', nil, frame)
    Health:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
    Health:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
    Health:SetHeight(cfg.tinyFramesHeight)
    Health:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.healthTexture)
    Health.colorClass = true
    Health.colorReaction = true
    
    local fontPath = addon:GetFontPath()
    
    -- Health name text
    Health.name = Health:CreateFontString(nil, 'OVERLAY')
    Health.name:SetFont(fontPath, cfg.extraSmallFontSize, 'OUTLINE')
    Health.name:SetPoint('LEFT', Health, 'LEFT', 5, 0)
    Health.name:SetJustifyH('LEFT')
    Health.name:SetWidth(cfg.tinyFramesWidth - 10)
    Health.name:SetWordWrap(false)
    frame:Tag(Health.name, '[name]')
    
    -- Add border
    addon:AddBorder(Health)
    
    frame.Health = Health
end
