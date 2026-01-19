local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.focus = addon.unitFrames.focus or {}

function addon:adjustFocusManaBar(manaBar, HealthBarsContainer, offsetY)
    self:CombatSafe(function()
        manaBar.sadunitframes_settingPosition = true
        manaBar:ClearAllPoints()
        manaBar:SetPoint("TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", 0, offsetY)
        manaBar:SetPoint("TOPRIGHT", HealthBarsContainer, "BOTTOMRIGHT", 0, offsetY)
        manaBar:SetHeight(12)
        manaBar.sadunitframes_settingPosition = false
    end)
end

function addon.unitFrames.focus:removePortrait()
    addon:Debug("Removing focus portrait")
    
    local portrait = FocusFrame.TargetFrameContainer.Portrait
    local portraitMask = FocusFrame.TargetFrameContainer.PortraitMask
    local healthBarMask = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBarMask
    local frameTexture = FocusFrame.TargetFrameContainer.FrameTexture
    local statusTexture = FocusFrame.TargetFrameContent.TargetFrameContentMain.StatusTexture
    local portraitCornerIcon = FocusFrame.TargetFrameContent.TargetFrameContentContextual.PortraitCornerIcon
    local reputationColor = FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor
    
    local HealthBarsContainer = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    local nameText = FocusFrame.TargetFrameContent.TargetFrameContentMain.Name
    
    addon:Debug("Portrait frame: " .. tostring(portrait))
    addon:Debug("PortraitMask frame: " .. tostring(portraitMask))
    
    addon:hideFrame(portrait)
    addon:hideFrame(portraitMask)
    addon:hideFrame(healthBarMask)
    addon:hideFrame(frameTexture)
    addon:hideFrame(statusTexture)
    addon:hideFrame(portraitCornerIcon)
    addon:hideFrame(reputationColor)
end

function addon.unitFrames.focus:setClassColor()
    addon:Debug("Setting focus frame class color")
    local healthBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    
    addon:Debug("Focus healthBar: " .. tostring(healthBar))
    
    -- Set up color hook first (before anything else)
    if not healthBar.sadunitframes_colorHooked then
        healthBar.sadunitframes_colorHooked = true
        hooksecurefunc(healthBar, "SetStatusBarColor", function(self, r, g, b)
            if self.sadunitframes_settingColor then return end
            if not UnitExists("focus") then return end
            local cr, cg, cb = addon:getUnitColor("Focus")
            if math.abs(r - cr) > 0.01 or math.abs(g - cg) > 0.01 or math.abs(b - cb) > 0.01 then
                self.sadunitframes_settingColor = true
                self:SetStatusBarColor(cr, cg, cb)
                self.sadunitframes_settingColor = false
            end
        end)
    end
    
    -- Only apply color if focus exists
    if not UnitExists("focus") then 
        addon:Debug("Focus unit does not exist, skipping color update")
        return 
    end
    
    -- Apply texture
    local texturePath = addon:getTexturePath(addon.savedVars.frameStyle.statusbarTexture)
    healthBar:SetStatusBarTexture(texturePath)
    
    -- Apply color immediately after texture (the hook will maintain it)
    local r, g, b = addon:getUnitColor("Focus")
    healthBar.sadunitframes_settingColor = true
    healthBar:SetStatusBarColor(r, g, b)
    healthBar.sadunitframes_settingColor = false
end

function addon.unitFrames.focus:addBorder()
    addon:Debug("Adding focus frame border")
    
    local healthBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    local manaBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
    
    addon:addBorder(healthBar)
    
    if manaBar then
        addon:addBorder(manaBar)
    end
end

function addon.unitFrames.focus:addBackground()
    addon:Debug("Adding focus frame background")
    
    local healthBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    local manaBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
    
    addon:addBackground(healthBar)
    
    if manaBar then
        addon:addBackground(manaBar)
    end
end

function addon.unitFrames.focus:adjustText()
    addon:Debug("Adjusting focus frame text")
    
    local HealthBarsContainer = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    local nameText = FocusFrame.TargetFrameContent.TargetFrameContentMain.Name
    local levelText = FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText
    
    if not nameText.sadunitframes_positionHooked then
        nameText.sadunitframes_positionHooked = true
        hooksecurefunc(nameText, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                addon.unitFrames.focus:adjustText()
            end)
        end)
    end
    
    -- Set white color and center alignment
    nameText:SetTextColor(1, 1, 1)
    nameText:SetJustifyH("CENTER")
    
    nameText.sadunitframes_settingPosition = true
    addon:setFramePoint(nameText, "BOTTOM", HealthBarsContainer, "TOP", 0, 0)
    nameText.sadunitframes_settingPosition = false
    
    addon:setFramePoint(levelText, "BOTTOMLEFT", HealthBarsContainer, "TOPLEFT", 0, 1)
end

function addon.unitFrames.focus:adjustManaBar()
    addon:Debug("Adjusting focus mana bar position")
    
    local HealthBarsContainer = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
    local manaBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
    local offsetY = addon.vars.manaBarOffsetY
    
    if not manaBar then return end
    
    if not manaBar.sadunitframes_positionHooked then
        manaBar.sadunitframes_positionHooked = true
        hooksecurefunc(manaBar, "SetPoint", function(self)
            if self.sadunitframes_settingPosition then return end
            C_Timer.After(0, function()
                addon.unitFrames.focus:adjustManaBar()
            end)
        end)
    end
    
    addon:adjustFocusManaBar(manaBar, HealthBarsContainer, offsetY)
end

function addon.unitFrames.focus:hideManaText()
    addon:Debug("Hiding focus mana text")
    
    local manaBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar
    
    if not manaBar then return end
    
    local regions = {manaBar:GetRegions()}
    for _, region in pairs(regions) do
        if region:GetObjectType() == "FontString" then
            addon:hideFrame(region)
        end
    end
end

function addon.unitFrames.focus:hideHealthText()
    addon:Debug("Hiding focus health text")
    
    local healthBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    local rightText = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.RightText
    local leftText = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.LeftText
    
    addon:hideFrame(rightText)
    addon:hideFrame(leftText)
    
    if healthBar then
        local regions = {healthBar:GetRegions()}
        for _, region in pairs(regions) do
            if region:GetObjectType() == "FontString" then
                addon:hideFrame(region)
            end
        end
    end
end

function addon.unitFrames.focus:hideLevelText()
    addon:Debug("Hiding focus level text")
    
    local levelText = FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText
    
    addon:hideFrame(levelText)
end

function addon.unitFrames.focus:updateTexture()
    addon:Debug("Updating focus frame texture")
end

function addon.unitFrames.focus:hidePvpIcon()
    addon:Debug("Hiding focus PVP icon")
    
    local pvpIcon = FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait
    local prestigeBadge = FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge
    
    addon:hideFrame(pvpIcon)
    addon:hideFrame(prestigeBadge)
end

function addon.unitFrames.focus:hideBuffsAndDebuffs()
    local children = {FocusFrame:GetChildren()}
    for _, child in ipairs(children) do
        if child.icon or child.Icon then
            child:Hide()
            child:SetAlpha(0)
        end
    end
end

function addon.unitFrames.focus:hideCastBar()
    addon:Debug("Hiding focus cast bar")
    
    local castBar = FocusFrameSpellBar
    
    if not castBar then return end
    
    -- Set up persistent hook to keep it hidden
    if not castBar.sadunitframes_castbarHooked then
        castBar.sadunitframes_castbarHooked = true
        hooksecurefunc(castBar, "Show", function(self)
            self:Hide()
            self:SetAlpha(0)
        end)
    end
    
    -- Hide the main cast bar
    addon:hideFrame(castBar)
    
    -- Hide all known child elements
    if castBar.Border then addon:hideFrame(castBar.Border) end
    if castBar.Icon then addon:hideFrame(castBar.Icon) end
    if castBar.Text then addon:hideFrame(castBar.Text) end
    if castBar.BorderShield then addon:hideFrame(castBar.BorderShield) end
    if castBar.Flash then addon:hideFrame(castBar.Flash) end
    if castBar.Spark then addon:hideFrame(castBar.Spark) end
    if castBar.TextBorder then addon:hideFrame(castBar.TextBorder) end
    
    -- Also hide all regions and children
    local regions = {castBar:GetRegions()}
    for _, region in pairs(regions) do
        addon:hideFrame(region)
    end
    
    local children = {castBar:GetChildren()}
    for _, child in pairs(children) do
        addon:hideFrame(child)
    end
end