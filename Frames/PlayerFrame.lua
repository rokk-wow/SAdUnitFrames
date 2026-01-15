local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.player = addon.unitFrames.player or {}

function addon.unitFrames.player:removePortrait()
    addon:debug("Removing player portrait")
    
    local portrait = PlayerFrame.PlayerFrameContainer.PlayerPortrait
    local portraitMask = PlayerFrame.PlayerFrameContainer.PlayerPortraitMask
    local healthBarMask = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBarMask
    local frameTexture = PlayerFrame.PlayerFrameContainer.FrameTexture
    local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture
    local portraitCornerIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon
    local alternatePowerFrameTexture = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
    
    local HealthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local nameText = PlayerName
    local levelText = PlayerLevelText
    local restLoop = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop
    
    addon:debug("Portrait frame: " .. tostring(portrait))
    addon:debug("PortraitMask frame: " .. tostring(portraitMask))
    
    addon:hideFrame(portrait)
    addon:hideFrame(portraitMask)
    addon:hideFrame(healthBarMask)
    addon:hideFrame(frameTexture)
    addon:hideFrame(statusTexture)
    addon:hideFrame(portraitCornerIcon)
    addon:hideFrame(alternatePowerFrameTexture)
    
    if restLoop and nameText then
        addon:setFramePoint(restLoop, "BOTTOMLEFT", PlayerName, "RIGHT", -5, 0)
    end
end

function addon.unitFrames.player:setClassColor()
    local healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
    
    -- Set up color hook first (before anything else)
    if not healthBar.sadunitframes_colorHooked then
        healthBar.sadunitframes_colorHooked = true
        hooksecurefunc(healthBar, "SetStatusBarColor", function(self, r, g, b)
            if self.sadunitframes_settingColor then return end
            local cr, cg, cb = addon:getUnitColor("Player")
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
    local r, g, b = addon:getUnitColor("Player")
    healthBar.sadunitframes_settingColor = true
    healthBar:SetStatusBarColor(r, g, b)
    healthBar.sadunitframes_settingColor = false
end

function addon.unitFrames.player:addBorder()
    addon:debug("Adding player frame border")
    
    local healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
    local manaBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar
    
    addon:addBorder(healthBar)
    addon:addBorder(manaBar)
end

function addon.unitFrames.player:addBackground()
    addon:debug("Adding player frame background")
    
    local healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
    local manaBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar
    
    addon:addBackground(healthBar)
    addon:addBackground(manaBar)
end

function addon.unitFrames.player:adjustText()
    addon:debug("Adjusting player frame text")
    
    local HealthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local nameText = PlayerName
    local levelText = PlayerLevelText
    
    if not nameText.sadunitframes_positionHooked then
        nameText.sadunitframes_positionHooked = true
        hooksecurefunc(nameText, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                addon.unitFrames.player:adjustText()
            end)
        end)
    end
    
    nameText.sadunitframes_settingPosition = true
    addon:setFramePoint(nameText, "BOTTOMLEFT", HealthBarsContainer, "TOPLEFT", -1, 0)
    nameText.sadunitframes_settingPosition = false
    
    addon:setFramePoint(levelText, "BOTTOMRIGHT", HealthBarsContainer, "TOPRIGHT", 0, 1)
end

function addon.unitFrames.player:updateTexture()
    addon:debug("Updating player frame texture")
end

function addon.unitFrames.player:hideHitIndicator()
    addon:debug("Hiding player hit indicator")
    
    local hitIndicator = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator
    addon:hideFrame(hitIndicator)
end

function addon.unitFrames.player:adjustManaBar()
    addon:debug("Adjusting player mana bar position")
    
    local HealthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local manaBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar
    local offsetY = addon.vars.manaBarOffsetY
    
    if not manaBar.sadunitframes_positionHooked then
        manaBar.sadunitframes_positionHooked = true
        hooksecurefunc(manaBar, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                addon.unitFrames.player:adjustManaBar()
            end)
        end)
    end
    
    manaBar.sadunitframes_settingPosition = true
    manaBar:ClearAllPoints()
    manaBar:SetPoint("TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", 0, offsetY)
    manaBar:SetPoint("TOPRIGHT", HealthBarsContainer, "BOTTOMRIGHT", 0, offsetY)
    manaBar:SetHeight(12)
    manaBar.sadunitframes_settingPosition = false
end

function addon.unitFrames.player:hideManaText()
    addon:debug("Hiding player mana text")
    
    local manaBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar
    
    local regions = {manaBar:GetRegions()}
    for _, region in pairs(regions) do
        if region:GetObjectType() == "FontString" then
            addon:hideFrame(region)
        end
    end
end

function addon.unitFrames.player:handleSecondaryPowerBar()
    addon:debug("Handling secondary power bar (Stagger, etc.)")
    
    -- For Brewmaster monks - MonkStaggerBar
    local staggerBar = _G["MonkStaggerBar"]
    
    if staggerBar then
        addon:debug("Found MonkStaggerBar")
        
        -- Positioning settings
        local offsetY = -8
        
        -- Apply border and background
        addon:addBorder(staggerBar)
        addon:addBackground(staggerBar)
        
        -- Apply texture
        local texturePath = addon:getTexturePath(addon.settings.frameStyle.statusbarTexture)
        if staggerBar.SetStatusBarTexture then
            staggerBar:SetStatusBarTexture(texturePath)
        end
        
        -- Hide power bar mask
        local powerBarMask = staggerBar.PowerBarMask
        if powerBarMask then
            addon:hideFrame(powerBarMask)
        end
        
        -- Position stagger bar
        local HealthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
        if HealthBarsContainer then
            staggerBar:ClearAllPoints()
            staggerBar:SetPoint("TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", 0, offsetY)
            staggerBar:SetPoint("TOPRIGHT", HealthBarsContainer, "BOTTOMRIGHT", 0, offsetY)
        end
        
        -- Hide text on stagger bar
        local regions = {staggerBar:GetRegions()}
        for _, region in pairs(regions) do
            if region:GetObjectType() == "FontString" then
                addon:hideFrame(region)
            end
        end
    end
end

function addon.unitFrames.player:adjustRuneFrame()
    addon:debug("Adjusting DK rune frame")
    
    -- Rune frame positioning settings
    local runeScale = 0.85
    local runeOffsetX = 2
    local runeOffsetY = -8
    
    local runeFrame = _G["RuneFrame"]
    local HealthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    
    if runeFrame and HealthBarsContainer then
        addon:debug("Found RuneFrame")
        
        -- Hook to maintain position
        if not runeFrame.sadunitframes_positionHooked then
            runeFrame.sadunitframes_positionHooked = true
            hooksecurefunc(runeFrame, "SetPoint", function(self)
                if self.sadunitframes_settingPosition then return end
                C_Timer.After(0, function()
                    self.sadunitframes_settingPosition = true
                    self:ClearAllPoints()
                    self:SetPoint("TOP", HealthBarsContainer, "BOTTOM", runeOffsetX, runeOffsetY)
                    self.sadunitframes_settingPosition = false
                end)
            end)
        end
        
        -- Set scale (makes it smaller/narrower)
        runeFrame:SetScale(runeScale)
        
        -- Position below health bar
        runeFrame.sadunitframes_settingPosition = true
        runeFrame:ClearAllPoints()
        runeFrame:SetPoint("TOP", HealthBarsContainer, "BOTTOM", runeOffsetX, runeOffsetY)
        runeFrame.sadunitframes_settingPosition = false
        
        addon:debug("RuneFrame adjusted with scale: " .. tostring(runeScale))
    end
end

function addon.unitFrames.player:adjustEssenceFrame()
    addon:debug("Adjusting Evoker essence frame")
    
    -- Essence frame positioning settings
    local essenceScale = 0.85
    local essenceOffsetX = 0
    local essenceOffsetY = -8
    
    local essenceFrame = _G["EssencePlayerFrame"]
    local HealthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    
    if essenceFrame and HealthBarsContainer then
        addon:debug("Found EssencePlayerFrame")
        
        -- Hook to maintain position
        if not essenceFrame.sadunitframes_positionHooked then
            essenceFrame.sadunitframes_positionHooked = true
            hooksecurefunc(essenceFrame, "SetPoint", function(self)
                if self.sadunitframes_settingPosition then return end
                C_Timer.After(0, function()
                    self.sadunitframes_settingPosition = true
                    self:ClearAllPoints()
                    self:SetPoint("TOP", HealthBarsContainer, "BOTTOM", essenceOffsetX, essenceOffsetY)
                    self.sadunitframes_settingPosition = false
                end)
            end)
        end
        
        -- Set scale (makes it smaller/narrower)
        essenceFrame:SetScale(essenceScale)
        
        -- Position below health bar
        essenceFrame.sadunitframes_settingPosition = true
        essenceFrame:ClearAllPoints()
        essenceFrame:SetPoint("TOP", HealthBarsContainer, "BOTTOM", essenceOffsetX, essenceOffsetY)
        essenceFrame.sadunitframes_settingPosition = false
        
        addon:debug("EssencePlayerFrame adjusted with scale: " .. tostring(essenceScale))
    end
end
