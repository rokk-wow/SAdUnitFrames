local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.targettarget = addon.unitFrames.targettarget or {}

function addon.unitFrames.targettarget:removePortrait()
    addon:debug("Removing target of target portrait")
    
    local portrait = TargetFrameToT.Portrait
    local healthBarMask = TargetFrameToT.HealthBar.HealthBarMask
    local frameTexture = TargetFrameToT.FrameTexture
    
    addon:hideFrame(portrait)
    addon:hideFrame(healthBarMask)
    addon:hideFrame(frameTexture)
end

function addon.unitFrames.targettarget:setClassColor()
    addon:debug("Setting target of target frame class color")
    local healthBar = TargetFrameToT.HealthBar
    
    if not healthBar then return end
    
    -- Set up color hook first (before anything else)
    if not healthBar.sadunitframes_colorHooked then
        healthBar.sadunitframes_colorHooked = true
        hooksecurefunc(healthBar, "SetStatusBarColor", function(self, r, g, b)
            if self.sadunitframes_settingColor then return end
            local cr, cg, cb = addon:getUnitColor("TargetTarget")
            if math.abs(r - cr) > 0.01 or math.abs(g - cg) > 0.01 or math.abs(b - cb) > 0.01 then
                self.sadunitframes_settingColor = true
                self:SetStatusBarColor(cr, cg, cb)
                self.sadunitframes_settingColor = false
            end
        end)
    end
    
    -- Apply texture
    local texturePath = addon:getTexturePath(addon.settings.frameStyle.statusbarTexture)
    healthBar:SetStatusBarTexture(texturePath)
    
    -- Apply color immediately after texture (the hook will maintain it)
    local r, g, b = addon:getUnitColor("TargetTarget")
    healthBar.sadunitframes_settingColor = true
    healthBar:SetStatusBarColor(r, g, b)
    healthBar.sadunitframes_settingColor = false
end

function addon.unitFrames.targettarget:addBorder()
    addon:debug("Adding target of target frame border")
    
    local healthBar = TargetFrameToT.HealthBar
    
    if healthBar then
        addon:addBorder(healthBar)
    end
end

function addon.unitFrames.targettarget:addBackground()
    addon:debug("Adding target of target frame background")
    
    local healthBar = TargetFrameToT.HealthBar
    
    if healthBar then
        addon:addBackground(healthBar)
    end
end

function addon.unitFrames.targettarget:adjustText()
    addon:debug("Adjusting target of target frame text")
    
    -- Text positioning settings
    local textOffsetX = 0
    local textOffsetY = 0
    local textScale = 0.6
    
    local healthBar = TargetFrameToT.HealthBar
    local nameText = TargetFrameToT.Name
    
    if not nameText or not healthBar then return end
    
    -- Scale and align text
    nameText:SetScale(textScale)
    nameText:SetJustifyH("LEFT")
    
    nameText:ClearAllPoints()
    nameText:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", textOffsetX, textOffsetY)
end

function addon.unitFrames.targettarget:adjustManaBar()
    addon:debug("Adjusting target of target mana bar position")
    
    local healthBar = TargetFrameToT.HealthBar
    local manaBar = TargetFrameToT.ManaBar
    local offsetY = addon.vars.manaBarOffsetY
    
    if not manaBar then return end
    
    if not manaBar.sadunitframes_positionHooked then
        manaBar.sadunitframes_positionHooked = true
        hooksecurefunc(manaBar, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                addon.unitFrames.targettarget:adjustManaBar()
            end)
        end)
    end
    
    manaBar.sadunitframes_settingPosition = true
    manaBar:ClearAllPoints()
    manaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, offsetY)
    manaBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, offsetY)
    manaBar:SetHeight(12)
    manaBar.sadunitframes_settingPosition = false
end

function addon.unitFrames.targettarget:hideManaText()
    addon:debug("Hiding target of target mana text")
    
    local manaBar = TargetFrameToT.ManaBar
    
    if not manaBar then return end
    
    local regions = {manaBar:GetRegions()}
    for _, region in pairs(regions) do
        if region:GetObjectType() == "FontString" then
            addon:hideFrame(region)
        end
    end
end

function addon.unitFrames.targettarget:updateTexture()
    addon:debug("Updating target of target frame texture")
end

function addon.unitFrames.targettarget:adjustPosition()
    addon:debug("Adjusting target of target frame position")
    
    -- Positioning settings
    local offsetX = -37
    local offsetY = 2.5
    
    local totFrame = TargetFrameToT
    local targetHealthBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    
    if not totFrame or not targetHealthBar then return end
    
    if not totFrame.sadunitframes_positionHooked then
        totFrame.sadunitframes_positionHooked = true
        hooksecurefunc(totFrame, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                addon.unitFrames.targettarget:adjustPosition()
            end)
        end)
    end
    
    totFrame.sadunitframes_settingPosition = true
    totFrame:ClearAllPoints()
    totFrame:SetPoint("LEFT", targetHealthBar, "RIGHT", offsetX, offsetY)
    totFrame.sadunitframes_settingPosition = false
end
