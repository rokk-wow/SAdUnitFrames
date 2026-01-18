local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.player = addon.unitFrames.player or {}
addon.CombatSafe = addon.CombatSafe or {}

addon.CombatSafe.adjustPlayerManaBar = function(self, manaBar, HealthBarsContainer, offsetY)
    manaBar.sadunitframes_settingPosition = true
    manaBar:ClearAllPoints()
    manaBar:SetPoint("TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", 0, offsetY)
    manaBar:SetPoint("TOPRIGHT", HealthBarsContainer, "BOTTOMRIGHT", 0, offsetY)
    manaBar:SetHeight(12)
    manaBar.sadunitframes_settingPosition = false
    return true
end

function addon.unitFrames.player:removePortrait()
    addon:debug("Removing player portrait")
    
    local portrait = PlayerFrame.PlayerFrameContainer.PlayerPortrait
    local portraitMask = PlayerFrame.PlayerFrameContainer.PlayerPortraitMask
    local healthBarMask = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBarMask
    local frameTexture = PlayerFrame.PlayerFrameContainer.FrameTexture
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
    addon:hideFrame(portraitCornerIcon)
    addon:hideFrame(alternatePowerFrameTexture)
    
    if restLoop and nameText then
        addon:setFramePoint(restLoop, "BOTTOMLEFT", PlayerName, "RIGHT", -5, 0)
    end
end

function addon.unitFrames.player:hidePlayerFrameStatusTexture()
    addon:debug("Hiding player frame status texture")
    
    if PlayerFrame and PlayerFrame.PlayerFrameContent and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain then
        local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture
        if statusTexture then
            statusTexture:SetAlpha(0)
            statusTexture:Hide()
            
            if not statusTexture.sadunitframes_hideHooked then
                statusTexture.sadunitframes_hideHooked = true
                hooksecurefunc(statusTexture, "Show", function(self)
                    self:SetAlpha(0)
                    self:Hide()
                end)
                hooksecurefunc(statusTexture, "SetAlpha", function(self, alpha)
                    if alpha > 0 then
                        C_Timer.After(0, function()
                            self:SetAlpha(0)
                        end)
                    end
                end)
            end
        end
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
    local hitFlash = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar.AnimatedLossBar
    
    addon:hideFrame(hitIndicator)
    
    -- Also hide the animated loss bar that can show yellow
    if hitFlash then
        addon:hideFrame(hitFlash)
    end
    
    -- Hide all textures on the HitIndicator in case they're separate
    if hitIndicator then
        local regions = {hitIndicator:GetRegions()}
        for _, region in pairs(regions) do
            if region.GetTexture then
                addon:hideFrame(region)
            end
        end
    end
end

function addon.unitFrames.player:hidePvpIcon()
    addon:debug("Hiding player PVP icon")
    
    local pvpIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigePortrait
    local prestigeBadge = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge
    local pvpIconFrame = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PVPIcon
    
    addon:hideFrame(pvpIcon)
    addon:hideFrame(prestigeBadge)
    addon:hideFrame(pvpIconFrame)
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
    
    addon.CombatSafe:adjustPlayerManaBar(manaBar, HealthBarsContainer, offsetY)
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

addon.CombatSafe.adjustSecondaryPowerBar = function(self, staggerBar, HealthBarsContainer, offsetY)
    staggerBar:ClearAllPoints()
    staggerBar:SetPoint("TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", 0, offsetY)
    staggerBar:SetPoint("TOPRIGHT", HealthBarsContainer, "BOTTOMRIGHT", 0, offsetY)
    return true
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
            addon.CombatSafe:adjustSecondaryPowerBar(staggerBar, HealthBarsContainer, offsetY)
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

addon.CombatSafe.adjustRuneFramePosition = function(self, runeFrame, HealthBarsContainer, runeScale, runeOffsetX, runeOffsetY)
    runeFrame:SetScale(runeScale)
    runeFrame.sadunitframes_settingPosition = true
    runeFrame:ClearAllPoints()
    runeFrame:SetPoint("TOP", HealthBarsContainer, "BOTTOM", runeOffsetX, runeOffsetY)
    runeFrame.sadunitframes_settingPosition = false
    return true
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
                    addon.CombatSafe:adjustRuneFramePosition(self, HealthBarsContainer, runeScale, runeOffsetX, runeOffsetY)
                end)
            end)
        end
        
        -- Set scale and position
        addon.CombatSafe:adjustRuneFramePosition(runeFrame, HealthBarsContainer, runeScale, runeOffsetX, runeOffsetY)
        
        addon:debug("RuneFrame adjusted with scale: " .. tostring(runeScale))
    end
end

addon.CombatSafe.adjustEssenceFramePosition = function(self, essenceFrame, HealthBarsContainer, essenceScale, essenceOffsetX, essenceOffsetY)
    essenceFrame:SetScale(essenceScale)
    essenceFrame.sadunitframes_settingPosition = true
    essenceFrame:ClearAllPoints()
    essenceFrame:SetPoint("TOP", HealthBarsContainer, "BOTTOM", essenceOffsetX, essenceOffsetY)
    essenceFrame.sadunitframes_settingPosition = false
    return true
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
                    addon.CombatSafe:adjustEssenceFramePosition(self, HealthBarsContainer, essenceScale, essenceOffsetX, essenceOffsetY)
                end)
            end)
        end
        
        -- Set scale and position
        addon.CombatSafe:adjustEssenceFramePosition(essenceFrame, HealthBarsContainer, essenceScale, essenceOffsetX, essenceOffsetY)
        
        addon:debug("EssencePlayerFrame adjusted with scale: " .. tostring(essenceScale))
    end
end

function addon.unitFrames.player:hideCombatGlow()
    addon:debug("Hiding combat glow on player frame")
    
    -- Hide the combat flash effect
    local combatFlash = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.CombatFlash
    if combatFlash then
        addon:hideFrame(combatFlash)
    end
    
    -- Also hide the attack glow
    local attackGlow = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerAttackGlow
    if attackGlow then
        addon:hideFrame(attackGlow)
    end
end

function addon.unitFrames.player:hideFrameFlash()
    addon:debug("Hiding frame flash on player frame")
    
    -- Hide the FrameFlash from PlayerFrameContainer
    local frameFlash = PlayerFrame.PlayerFrameContainer.FrameFlash
    if frameFlash then
        frameFlash:SetAlpha(0)
        frameFlash:Hide()
        
        -- Hook to keep it hidden
        if not frameFlash.sadunitframes_hideHooked then
            frameFlash.sadunitframes_hideHooked = true
            hooksecurefunc(frameFlash, "Show", function(self)
                self:SetAlpha(0)
                self:Hide()
            end)
            hooksecurefunc(frameFlash, "SetAlpha", function(self, alpha)
                if alpha > 0 then
                    C_Timer.After(0, function()
                        self:SetAlpha(0)
                    end)
                end
            end)
        end
    end
end

addon.CombatSafe.positionCombatIndicator = function(self, combatIndicator, HealthBarsContainer, healthBarHeight)
    combatIndicator:SetSize(healthBarHeight, healthBarHeight)
    combatIndicator:ClearAllPoints()
    combatIndicator:SetPoint("RIGHT", HealthBarsContainer, "LEFT", 0, 0)
    return true
end

function addon.unitFrames.player:createCombatIndicator()
    addon:debug("Creating combat indicator")
    
    local HealthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    
    -- Create the combat indicator frame if it doesn't exist
    if not PlayerFrame.sadunitframes_combatIndicator then
        local combatIndicator = CreateFrame("Frame", "SAdUnitFrames_PlayerCombatIndicator", PlayerFrame)
        combatIndicator:SetFrameStrata("HIGH")
        combatIndicator:SetFrameLevel(100)
        
        -- Create texture using the atlas texture coordinates
        local texture = combatIndicator:CreateTexture(nil, "ARTWORK")
        texture:SetSnapToPixelGrid(false)
        texture:SetTexelSnappingBias(0)
        texture:SetSize(22, 18) -- Adjust to match texture coordinate aspect ratio
        texture:SetPoint("CENTER", combatIndicator, "CENTER")
        texture:SetTexture("interface/questframe/questlogquesttypeicons2x", "TRILINEAR", "TRILINEAR")
        texture:SetTexCoord(0.60, 0.7734375, 0.1953125, 0.3359375)
        
        combatIndicator.texture = texture
        
        PlayerFrame.sadunitframes_combatIndicator = combatIndicator
        
        addon:debug("Combat indicator frame created with name: SAdUnitFrames_PlayerCombatIndicator")
    end
    
    local combatIndicator = PlayerFrame.sadunitframes_combatIndicator
    
    -- Position the indicator to the left of the health bar
    -- Scale it to match health bar height
    local healthBarHeight = HealthBarsContainer:GetHeight()
    addon:debug("Health bar height: " .. tostring(healthBarHeight))
    
    -- Set the frame size and position
    addon.CombatSafe:positionCombatIndicator(combatIndicator, HealthBarsContainer, healthBarHeight)
    
    -- Register for combat events
    if not combatIndicator.eventRegistered then
        combatIndicator:RegisterEvent("PLAYER_REGEN_DISABLED")
        combatIndicator:RegisterEvent("PLAYER_REGEN_ENABLED")
        combatIndicator:SetScript("OnEvent", function(self, event)
            addon:debug("Combat event: " .. event)
            if event == "PLAYER_REGEN_DISABLED" then
                addon:debug("Entering combat - showing indicator")
                self:Show()
            elseif event == "PLAYER_REGEN_ENABLED" then
                addon:debug("Leaving combat - hiding indicator")
                self:Hide()
            end
        end)
        combatIndicator.eventRegistered = true
        addon:debug("Combat events registered")
    end
    
    -- Set initial state
    local inCombat = UnitAffectingCombat("player")
    addon:debug("Initial combat state: " .. tostring(inCombat))
    if inCombat then
        combatIndicator:Show()
        addon:debug("Showing combat indicator (initial state)")
    else
        combatIndicator:Hide()
        addon:debug("Hiding combat indicator (initial state)")
    end
    
    addon:debug("Combat indicator configured at position RIGHT of health bar with 0 offset")
end
