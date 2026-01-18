local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.target = addon.unitFrames.target or {}

function addon.unitFrames.target:removePortrait()
    addon:debug("Removing target portrait")
    
    local portrait = TargetFrame.TargetFrameContainer.Portrait
    local portraitMask = TargetFrame.TargetFrameContainer.PortraitMask
    local healthBarMask = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBarMask
    local frameTexture = TargetFrame.TargetFrameContainer.FrameTexture
    local statusTexture = TargetFrame.TargetFrameContent.TargetFrameContentMain.StatusTexture
    local portraitCornerIcon = TargetFrame.TargetFrameContent.TargetFrameContentContextual.PortraitCornerIcon
    local reputationColor = TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor
    
    local HealthBarsContainer = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    local nameText = TargetFrame.TargetFrameContent.TargetFrameContentMain.Name
    
    addon:debug("Portrait frame: " .. tostring(portrait))
    addon:debug("PortraitMask frame: " .. tostring(portraitMask))
    
    addon:hideFrame(portrait)
    addon:hideFrame(portraitMask)
    addon:hideFrame(healthBarMask)
    addon:hideFrame(frameTexture)
    addon:hideFrame(statusTexture)
    addon:hideFrame(portraitCornerIcon)
    addon:hideFrame(reputationColor)
end

function addon.unitFrames.target:setClassColor()
    addon:debug("Setting target frame class color")
    local healthBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    
    addon:debug("Target healthBar: " .. tostring(healthBar))
    
    -- Set up color hook first (before anything else)
    if not healthBar.sadunitframes_colorHooked then
        healthBar.sadunitframes_colorHooked = true
        hooksecurefunc(healthBar, "SetStatusBarColor", function(self, r, g, b)
            if self.sadunitframes_settingColor then return end
            local cr, cg, cb = addon:getUnitColor("Target")
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
    local r, g, b = addon:getUnitColor("Target")
    healthBar.sadunitframes_settingColor = true
    healthBar:SetStatusBarColor(r, g, b)
    healthBar.sadunitframes_settingColor = false
end

function addon.unitFrames.target:addBorder()
    addon:debug("Adding target frame border")
    
    local healthBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    local manaBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
    
    addon:addBorder(healthBar)
    
    if manaBar then
        addon:addBorder(manaBar)
    end
end

function addon.unitFrames.target:addBackground()
    addon:debug("Adding target frame background")
    
    local healthBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    local manaBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
    
    addon:addBackground(healthBar)
    
    if manaBar then
        addon:addBackground(manaBar)
    end
end

function addon.unitFrames.target:adjustHealthBar()
    addon:debug("Adjusting target health bar height")
    
    if InCombatLockdown() then return end
    
    local healthBarHeight = 19
    
    local HealthBarsContainer = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    
    if HealthBarsContainer then
        HealthBarsContainer:SetHeight(healthBarHeight)
        addon:debug("Target HealthBarsContainer height set to: " .. tostring(healthBarHeight))
    end
end

function addon.unitFrames.target:adjustText()
    addon:debug("Adjusting target frame text")
    
    local HealthBarsContainer = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    local nameText = TargetFrame.TargetFrameContent.TargetFrameContentMain.Name
    local levelText = TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText
    
    if not nameText.sadunitframes_positionHooked then
        nameText.sadunitframes_positionHooked = true
        hooksecurefunc(nameText, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                addon.unitFrames.target:adjustText()
            end)
        end)
    end
    
    nameText:SetJustifyH("RIGHT")
    
    nameText.sadunitframes_settingPosition = true
    addon:setFramePoint(nameText, "BOTTOMRIGHT", HealthBarsContainer, "TOPRIGHT", 0, 0)
    nameText.sadunitframes_settingPosition = false
    
    addon:setFramePoint(levelText, "BOTTOMLEFT", HealthBarsContainer, "TOPLEFT", 0, 1)
end

function addon.unitFrames.target:adjustManaBar()
    addon:debug("Adjusting target mana bar position")
    
    local HealthBarsContainer = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    local manaBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
    local offsetY = addon.vars.manaBarOffsetY
    
    if not manaBar then return end
    
    if not manaBar.sadunitframes_positionHooked then
        manaBar.sadunitframes_positionHooked = true
        hooksecurefunc(manaBar, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                addon.unitFrames.target:adjustManaBar()
            end)
        end)
    end
    
    -- Skip during combat - positioning is protected
    if InCombatLockdown() then return end
    
    manaBar.sadunitframes_settingPosition = true
    manaBar:ClearAllPoints()
    manaBar:SetPoint("TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", 0, offsetY)
    manaBar:SetPoint("TOPRIGHT", HealthBarsContainer, "BOTTOMRIGHT", 0, offsetY)
    manaBar:SetHeight(12)
    manaBar.sadunitframes_settingPosition = false
end

function addon.unitFrames.target:hideManaText()
    addon:debug("Hiding target mana text")
    
    local manaBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
    
    if not manaBar then return end
    
    local regions = {manaBar:GetRegions()}
    for _, region in pairs(regions) do
        if region:GetObjectType() == "FontString" then
            addon:hideFrame(region)
        end
    end
end

function addon.unitFrames.target:updateTexture()
    addon:debug("Updating target frame texture")
end

function addon.unitFrames.target:hidePvpIcon()
    addon:debug("Hiding target PVP icon")
    
    local pvpIcon = TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait
    local prestigeBadge = TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge
    
    addon:hideFrame(pvpIcon)
    addon:hideFrame(prestigeBadge)
end

function addon.unitFrames.target:adjustEliteDragon()
    addon:debug("Adjusting elite dragon")
    
    local dragonTexture = TargetFrame.TargetFrameContainer.BossPortraitFrameTexture
    
    if not dragonTexture then return end
    
    -- Scale down by 50%
    dragonTexture:SetScale(0.35)
    
    -- Position to the right of the target frame
    dragonTexture:ClearAllPoints()
    dragonTexture:SetPoint("LEFT", TargetFrame, "RIGHT", -300, 0)
end

function addon.unitFrames.target:adjustHighLevelSkull()
    addon:debug("Adjusting high level skull")
    
    local skull = TargetFrame.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture
    local HealthBarsContainer = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    
    if not skull then return end
    
    skull:ClearAllPoints()
    skull:SetPoint("RIGHT", HealthBarsContainer, "LEFT", -3, 0)
end

function addon.unitFrames.target:adjustCastBar()
    addon:debug("=== Adjusting target cast bar ===")
    
    -- Cast bar positioning settings
    local castBarWidth = 126
    local castBarOffsetX = 0
    local castBarOffsetY = -25
    
    -- Try multiple possible frame paths
    local castBar = _G["TargetFrameSpellBar"]
    local HealthBarsContainer = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    
    addon:debug("castBar: " .. tostring(castBar))
    addon:debug("HealthBarsContainer: " .. tostring(HealthBarsContainer))
    
    if not castBar then
        addon:debug("Cast bar not found!")
        return
    end
    
    if not HealthBarsContainer then
        addon:debug("HealthBarsContainer not found!")
        return
    end
    
    -- Set cast bar width
    addon:debug("Setting cast bar width to: " .. tostring(castBarWidth))
    castBar:SetWidth(castBarWidth)
    
    -- Clear and reposition
    castBar:ClearAllPoints()
    castBar:SetPoint("TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", castBarOffsetX, castBarOffsetY)
    
    addon:debug("Cast bar repositioned")
    
    -- Hook to maintain position and size
    if not castBar.sadunitframes_sizeHooked then
        castBar.sadunitframes_sizeHooked = true
        hooksecurefunc(castBar, "SetWidth", function(self, width)
            if self.sadunitframes_settingWidth then return end
            if math.abs(width - castBarWidth) > 1 then
                self.sadunitframes_settingWidth = true
                self:SetWidth(castBarWidth)
                self.sadunitframes_settingWidth = false
            end
        end)
        
        hooksecurefunc(castBar, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                self.sadunitframes_settingPosition = true
                self:ClearAllPoints()
                self:SetPoint("TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", castBarOffsetX, castBarOffsetY)
                self.sadunitframes_settingPosition = false
            end)
        end)
    end
end