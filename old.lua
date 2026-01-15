local addonName, addon = ...

local LSM = LibStub("LibSharedMedia-3.0")
local strippedBars = {}
local healPredictionFrames = {}
local positionedFrames = {}

function addon.refresh()
    C_Timer.After(0.1, function()
        addon.updatePlayerFrame()
    end)
end

function addon.updatePlayerFrame()

    local settings = {
        showHitIndicator = false,
        texture = "Minimalist",
        bgColor = "00000077",
        borderSize = 2,
        borderColor = "000000FF",
        healthBarColor = "00FF98FF",
        manaBarColor = "0A6EEBFF",
        healPredictionColor = "00FF981A",
        runicPowerColor = "FFFF00FF",
        manaBarOffsetX = 0,
        manaBarOffsetY = 2,
        classPowerOffsetX = 0,
        classPowerOffsetY = 7,
        runeFrameOffsetX = 2,
        runeFrameOffsetY = -4,
        runeFrameScale = 0.92,
    }

    local portrait = PlayerFrame.PlayerFrameContainer.PlayerPortrait
    local portraitMask = PlayerFrame.PlayerFrameContainer.PlayerPortraitMask
    local healthBarMask = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBarMask
    local frameTexture = PlayerFrame.PlayerFrameContainer.FrameTexture
    local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture
    local portraitCornerIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon
    
    local healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar    
    local HealthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local manaBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar
    local manaBarArea = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea
    local nameText = PlayerName
    local levelText = PlayerLevelText
    local restLoop = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop
    local hitIndicator = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator
    local runeFrame = RuneFrame

    local healthBarBg = addon.getOrCreateBarBackground(healthBar)
    local manaBarBg = addon.getOrCreateBarBackground(manaBar)

    local texture = LSM:Fetch("statusbar", settings.texture)
    local bgR, bgG, bgB, bgA = addon.hexToRGB(settings.bgColor)
    local healthR, healthG, healthB, healthA = addon.hexToRGB(settings.healthBarColor)
    local healPredR, healPredG, healPredB, healPredA = addon.hexToRGB(settings.healPredictionColor)
    local runicR, runicG, runicB, runicA = addon.hexToRGB(settings.runicPowerColor)
    
    local healthBarColor = {healthR, healthG, healthB}
    local healPredictionColor = {healPredR, healPredG, healPredB, healPredA}
    local runicPowerColor = {runicR, runicG, runicB}

    addon.hideFrame(portrait)
    addon.hideFrame(portraitMask)
    addon.hideFrame(healthBarMask)
    addon.hideFrame(frameTexture)
    addon.hideFrame(statusTexture)
    addon.hideFrame(portraitCornerIcon)

    addon.setFramePoint(nameText, "BOTTOMLEFT", HealthBarsContainer, "TOPLEFT", -1, 0)
    addon.setFramePoint(levelText, "BOTTOMRIGHT", HealthBarsContainer, "TOPRIGHT", 0, 1)
    addon.setFramePoint(restLoop, "BOTTOMLEFT", nameText, "RIGHT", -5, 0)
    addon.hideFrame(hitIndicator)

    addon.stripBarTextures(healthBar, texture)
    addon.setStatusBarColor(healthBar, healthBarColor[1], healthBarColor[2], healthBarColor[3])
    
    addon.stripBarTextures(manaBar, texture)

    addon.setFrameAllPoints(healthBarBg, healthBar)
    addon.setColorTexture(healthBarBg, bgR, bgG, bgB, bgA)
    
    addon.setFrameAllPoints(manaBarBg, manaBar)
    addon.setColorTexture(manaBarBg, bgR, bgG, bgB, bgA)

    addon.addBarBorder(healthBar, settings.borderSize, settings.borderColor)
    addon.addBarBorder(manaBar, settings.borderSize, settings.borderColor)

    addon.setFramePoints(manaBarArea,
        {"TOPLEFT", HealthBarsContainer, "BOTTOMLEFT", settings.manaBarOffsetX, settings.manaBarOffsetY},
        {"BOTTOMRIGHT", HealthBarsContainer, "BOTTOMRIGHT", settings.manaBarOffsetX, settings.manaBarOffsetY - 12}
    )
    
    addon.setFrameAllPoints(manaBar, manaBarArea)

    addon.registerRuneFrame(runeFrame, HealthBarsContainer, settings.runeFrameOffsetX, settings.runeFrameOffsetY, settings.runeFrameScale, runicPowerColor, texture, bgR, bgG, bgB, bgA)

    addon.registerHealPrediction(PlayerFrame, PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar.MyHealPredictionBar, settings.texture, healPredictionColor)

end

function addon.getOrCreateBarBackground(bar)
    if not bar then return nil end
    
    local bg = bar.SAdUI_Background
    if not bg then
        bg = bar:GetStatusBarTexture():GetParent():CreateTexture(nil, "BACKGROUND")
        bar.SAdUI_Background = bg
    end
    
    return bg
end

function addon.hideFrame(frame)
    if not frame then return end
    
    -- Only hook once per frame
    if not frame.sadui_hideHooked then
        frame.sadui_hideHooked = true
        hooksecurefunc(frame, "Show", function(self)
            addon.debug("[" .. date("%H:%M:%S") .. "] [Hook] Frame Show triggered: " .. (self:GetName() or "unnamed"))
            if self.sadui_hideHooked then
                self:Hide()
            end
        end)
    end
    
    -- Always hide the frame when called, even if already hooked
    frame:Hide()
end

function addon.setFramePoint(frame, ...)
    if not frame then return end
    frame:ClearAllPoints()
    frame:SetPoint(...)
end

function addon.setFrameAllPoints(frame, relativeTo)
    if not frame then return end
    frame:ClearAllPoints()
    frame:SetAllPoints(relativeTo)
end

function addon.setFramePoints(frame, ...)
    if not frame then return end
    frame:ClearAllPoints()
    local points = {...}
    for i = 1, #points do
        frame:SetPoint(unpack(points[i]))
    end
end

function addon.setColorTexture(frame, r, g, b, a)
    if not frame then return end
    frame:SetColorTexture(r, g, b, a)
end

function addon.setTexture(frame, texture)
    if not frame then return end
    frame:SetTexture(texture)
end

function addon.setVertexColor(frame, r, g, b, a)
    if not frame then return end
    frame:SetVertexColor(r, g, b, a)
end

function addon.setHeight(frame, height)
    if not frame then return end
    frame:SetHeight(height)
end

function addon.setWidth(frame, width)
    if not frame or not width then return end
    frame:SetWidth(width)
end

function addon.getWidth(frame)
    if not frame then return end
    return frame:GetWidth()
end

function addon.setScale(frame, scale)
    if not frame or not scale then return end
    frame:SetScale(scale)
end

function addon.setStatusBarTexture(bar, texture)
    if not bar then return end
    bar:SetStatusBarTexture(texture)
end

function addon.setStatusBarColor(bar, r, g, b)
    if not bar then return end
    bar:SetStatusBarColor(r, g, b)
end

function addon.styleHealPredictionBar(healPredictionBar, texture, color)
    if not healPredictionBar then return end
    
    local healBar = healPredictionBar:GetFrame()
    if not healBar then return end
    
    if healBar:GetObjectType() == "StatusBar" then
        addon.stripBarTextures(healBar, texture)
    end
    
    if healBar.Fill then
        addon.setTexture(healBar.Fill, texture)
        addon.setVertexColor(healBar.Fill, color[1], color[2], color[3], color[4] or 0.5)
    end
end

function addon.registerHealPrediction(frame, healPredictionBar, textureName, color)
    if not frame or not healPredictionBar then return end
    
    -- Initialize hook on first registration
    if not healPredictionFrames._hooked then
        hooksecurefunc("UnitFrameHealPredictionBars_Update", function(frame)
            addon.debug("[" .. date("%H:%M:%S") .. "] [Hook] UnitFrameHealPredictionBars_Update triggered: " .. (frame and frame:GetName() or "unknown"))
            local frameInfo = healPredictionFrames[frame]
            if frameInfo then
                local texture = LSM:Fetch("statusbar", frameInfo.texture)
                addon.styleHealPredictionBar(frameInfo.bar, texture, frameInfo.color)
            end
        end)
        healPredictionFrames._hooked = true
    end
    
    healPredictionFrames[frame] = {
        bar = healPredictionBar,
        texture = textureName,
        color = color
    }
end

function addon.applyFramePosition(frame)
    if not frame then return end
    
    local settings = positionedFrames[frame]
    if not settings then return end
    
    -- Temporarily disable hooks to prevent recursion
    frame.SAdUI_ApplyingPosition = true
    
    addon.setFramePoints(frame,
        {"TOPLEFT", settings.relativeTo, "BOTTOMLEFT", settings.offsetX, settings.offsetY},
        {"TOPRIGHT", settings.relativeTo, "BOTTOMRIGHT", settings.offsetX, settings.offsetY}
    )
    
    addon.setScale(frame, settings.scale)
    
    frame.SAdUI_ApplyingPosition = false
end

function addon.registerFramePosition(frame, relativeTo, offsetX, offsetY, scale)
    if not frame then return end
    
    positionedFrames[frame] = {
        relativeTo = relativeTo,
        offsetX = offsetX,
        offsetY = offsetY,
        scale = scale
    }
    
    addon.applyFramePosition(frame)
    
    if not frame.SAdUI_PositionHooked then
        hooksecurefunc(frame, "SetPoint", function(self)
            addon.debug("[" .. date("%H:%M:%S") .. "] [Hook] SetPoint triggered: " .. (self:GetName() or "unnamed") .. ", applying: " .. tostring(not self.SAdUI_ApplyingPosition))
            -- Prevent recursive calls during position application
            if not self.SAdUI_ApplyingPosition then
                C_Timer.After(0, function()
                    addon.applyFramePosition(self)
                end)
            end
        end)
        
        hooksecurefunc(frame, "Show", function(self)
            addon.debug("[" .. date("%H:%M:%S") .. "] [Hook] Position Show triggered: " .. (self:GetName() or "unnamed") .. ", applying: " .. tostring(not self.SAdUI_ApplyingPosition))
            if not self.SAdUI_ApplyingPosition then
                addon.applyFramePosition(self)
            end
        end)
        
        frame.SAdUI_PositionHooked = true
    end
end

function addon.registerRuneFrame(frame, relativeTo, offsetX, offsetY, scale, color, texture, bgR, bgG, bgB, bgA)
    addon.registerFramePosition(frame, relativeTo, offsetX, offsetY, scale)
    
    if frame and color and texture then
        -- Debug: Check what's in the frame
        addon.debug("RuneFrame structure check:")
        if frame.RunicPowerBar then
            addon.debug("  - RunicPowerBar exists")
        else
            addon.debug("  - RunicPowerBar NOT found")
        end
        
        -- Try different possible names for the runic power bar
        local runicPowerBar = frame.RunicPowerBar or RunicPowerBar
        
        if runicPowerBar then
            addon.debug("  - Found runic power bar: " .. (runicPowerBar:GetName() or "unnamed"))
            addon.stripBarTextures(runicPowerBar, texture)
            
            -- Create and style background texture
            local runicBg = addon.getOrCreateBarBackground(runicPowerBar)
            if runicBg then
                addon.setFrameAllPoints(runicBg, runicPowerBar)
                addon.setColorTexture(runicBg, bgR, bgG, bgB, bgA)
            end
        else
            addon.debug("  - Could not find runic power bar")
        end
    end
end

function addon.addBarBorder(bar, size, colorHex)
    if not bar then return end    
    if bar.SAdUI_Borders then return end
    
    local r, g, b, a = addon.hexToRGB(colorHex)    
    local borders = {}
    
    borders.top = bar:CreateTexture(nil, "OVERLAY")
    addon.setColorTexture(borders.top, r, g, b, a)
    addon.setHeight(borders.top, size)
    addon.setFramePoints(borders.top,
        {"TOPLEFT", bar, "TOPLEFT", 0, 0},
        {"TOPRIGHT", bar, "TOPRIGHT", 0, 0}
    )
    
    borders.bottom = bar:CreateTexture(nil, "OVERLAY")
    addon.setColorTexture(borders.bottom, r, g, b, a)
    addon.setHeight(borders.bottom, size)
    addon.setFramePoints(borders.bottom,
        {"BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0},
        {"BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0}
    )
    
    borders.left = bar:CreateTexture(nil, "OVERLAY")
    addon.setColorTexture(borders.left, r, g, b, a)
    addon.setWidth(borders.left, size)
    addon.setFramePoints(borders.left,
        {"TOPLEFT", bar, "TOPLEFT", 0, 0},
        {"BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0}
    )
    
    borders.right = bar:CreateTexture(nil, "OVERLAY")
    addon.setColorTexture(borders.right, r, g, b, a)
    addon.setWidth(borders.right, size)
    addon.setFramePoints(borders.right,
        {"TOPRIGHT", bar, "TOPRIGHT", 0, 0},
        {"BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0}
    )
    
    bar.SAdUI_Borders = borders
end

function addon.stripBarTextures(bar, texture)
        if not bar or bar:GetObjectType() ~= "StatusBar" then return end
        
        strippedBars[bar] = {
            texture = texture
        }
        
        -- Set texture with protection flag
        bar.SAdUI_UpdatingBar = true
        addon.setStatusBarTexture(bar, texture)
        bar.SAdUI_UpdatingBar = false
        
        if not bar.SAdUI_TextureHooked then
            hooksecurefunc(bar, "SetStatusBarTexture", function(self, newTexture)
                addon.debug("[" .. date("%H:%M:%S") .. "] [Hook] SetStatusBarTexture triggered: " .. (self:GetName() or "unnamed") .. ", updating: " .. tostring(self.SAdUI_UpdatingBar))
                if self.SAdUI_UpdatingBar then return end
                local barInfo = strippedBars[self]
                if barInfo and newTexture ~= barInfo.texture then
                    self.SAdUI_UpdatingBar = true
                    self:SetStatusBarTexture(barInfo.texture)
                    self.SAdUI_UpdatingBar = false
                end
            end)
            bar.SAdUI_TextureHooked = true
        end
    end

function addon.RegisterFunctions()
    -- Apply customizations when entering world (zone changes, reloading UI, etc.)
    addon.RegisterEvent("PLAYER_ENTERING_WORLD", function()
        C_Timer.After(0.3, function()
            addon.updatePlayerFrame()
        end)
    end)
    
    -- Reapply when portrait updates (can reset frame visibility)
    addon.RegisterEvent("UNIT_PORTRAIT_UPDATE", function(event, unit)
        if unit == "player" then
            C_Timer.After(0.1, function()
                addon.updatePlayerFrame()
            end)
        end
    end)
    
    -- Reapply when player flags change (can affect frame display)
    addon.RegisterEvent("PLAYER_FLAGS_CHANGED", function()
        C_Timer.After(0.1, function()
            addon.updatePlayerFrame()
        end)
    end)
    
    -- Also apply when the player frame is shown (respawn, UI updates)
    if PlayerFrame then
        PlayerFrame:HookScript("OnShow", function()
            C_Timer.After(0.1, function()
                addon.updatePlayerFrame()
            end)
        end)
    end
    
    addon.updatePlayerFrame()
end




----------------------------


local addonName, addon = ...

local LSM = LibStub("LibSharedMedia-3.0")

function addon.refresh()
    C_Timer.After(0.1, function()
        addon.updatePlayerFrame()
    end)
end

-- oUF style function - defines how our frames look
local function CreateStyle(self)
    -- Frame dimensions and positioning
    self:SetSize(180, 40)
    
    -- Settings
    local settings = {
        texture = "Minimalist",
        bgColor = "00000077",
        borderSize = 2,
        borderColor = "000000FF",
        healthBarColor = "00FF98FF",
        powerBarColors = {
            ["MANA"] = "0A6EEBFF",      -- Blue
            ["RAGE"] = "FF0000FF",      -- Red
            ["FOCUS"] = "FF8000FF",     -- Orange
            ["ENERGY"] = "FFFF00FF",    -- Yellow
            ["RUNIC_POWER"] = "00D4FFFF", -- Cyan
        },
    }
    
    local texture = LSM:Fetch("statusbar", settings.texture)
    
    -- Parse colors
    local bgR, bgG, bgB, bgA = addon.hexToRGB(settings.bgColor)
    local borderR, borderG, borderB, borderA = addon.hexToRGB(settings.borderColor)
    local healthR, healthG, healthB, healthA = addon.hexToRGB(settings.healthBarColor)
    
    -- Health Bar
    local health = CreateFrame("StatusBar", nil, self)
    health:SetPoint("TOPLEFT")
    health:SetPoint("TOPRIGHT")
    health:SetHeight(28)
    health:SetStatusBarTexture(texture)
    health:SetStatusBarColor(healthR, healthG, healthB)
    
    -- Health Background
    local healthBg = health:CreateTexture(nil, "BACKGROUND")
    healthBg:SetAllPoints(health)
    healthBg:SetColorTexture(bgR, bgG, bgB, bgA)
    
    -- Health Border
    addon.addBorder(health, settings.borderSize, {borderR, borderG, borderB, borderA})
    
    -- Power Bar
    local power = CreateFrame("StatusBar", nil, self)
    power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -2)
    power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -2)
    power:SetHeight(10)
    power:SetStatusBarTexture(texture)
    
    -- Power Background
    local powerBg = power:CreateTexture(nil, "BACKGROUND")
    powerBg:SetAllPoints(power)
    powerBg:SetColorTexture(bgR, bgG, bgB, bgA)
    
    -- Power Border
    addon.addBorder(power, settings.borderSize, {borderR, borderG, borderB, borderA})
    
    -- Name Text
    local name = health:CreateFontString(nil, "OVERLAY")
    name:SetPoint("BOTTOMLEFT", health, "TOPLEFT", -1, 0)
    name:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    name:SetJustifyH("LEFT")
    
    -- Level Text
    local level = health:CreateFontString(nil, "OVERLAY")
    level:SetPoint("BOTTOMRIGHT", health, "TOPRIGHT", 0, 1)
    level:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    level:SetJustifyH("RIGHT")
    
    -- Health Percent Text (Left)
    local healthPercent = health:CreateFontString(nil, "OVERLAY")
    healthPercent:SetPoint("LEFT", health, "LEFT", 2, 0)
    healthPercent:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    healthPercent:SetJustifyH("LEFT")
    healthPercent:SetTextColor(1, 1, 1, 1) -- White
    
    -- Health Total Text (Right)
    local healthTotal = health:CreateFontString(nil, "OVERLAY")
    healthTotal:SetPoint("RIGHT", health, "RIGHT", -2, 0)
    healthTotal:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    healthTotal:SetJustifyH("RIGHT")
    healthTotal:SetTextColor(1, 1, 1, 1) -- White
    
    -- Manual health text update using OnUpdate
    health:SetScript("OnUpdate", function(self, elapsed)
        self.updateTimer = (self.updateTimer or 0) + elapsed
        if self.updateTimer >= 0.1 then -- Update 10 times per second
            self.updateTimer = 0
            
            -- Read from the statusbar's stored values
            local curPercent = (self:GetValue() / (self:GetMinMaxValues())) * 100
            if curPercent and curPercent >= 0 then
                healthPercent:SetText(math.floor(curPercent) .. "%")
            end
            
            -- For max health, try to read it from the bar's max property that oUF sets
            if self.max then
                healthTotal:SetText(math.floor(self.max))
            end
        end
    end)
    
    -- Register elements with oUF
    self.Health = health
    self.Health.bg = healthBg
    self.Power = power
    self.Power.bg = powerBg
    self.Power.colorPower = true -- Enable automatic power coloring by oUF
    self.Name = name
    self.Level = level
    
    -- Store the update function and text elements
    self.HealthPercentText = healthPercent
    self.HealthTotalText = healthTotal
    
    -- Override power colors with our custom colors
    self.colors = self.colors or {}
    self.colors.power = self.colors.power or {}
    for powerType, hexColor in pairs(settings.powerBarColors) do
        local r, g, b, a = addon.hexToRGB(hexColor)
        self.colors.power[powerType] = {r, g, b}
    end
end

-- Helper function to add borders
function addon.addBorder(frame, size, color)
    if not frame then return end
    if frame.SAdUI_Borders then return end
    
    local borders = {}
    
    borders.top = frame:CreateTexture(nil, "OVERLAY")
    borders.top:SetColorTexture(unpack(color))
    borders.top:SetHeight(size)
    borders.top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    borders.top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    
    borders.bottom = frame:CreateTexture(nil, "OVERLAY")
    borders.bottom:SetColorTexture(unpack(color))
    borders.bottom:SetHeight(size)
    borders.bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    borders.bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    
    borders.left = frame:CreateTexture(nil, "OVERLAY")
    borders.left:SetColorTexture(unpack(color))
    borders.left:SetWidth(size)
    borders.left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    borders.left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    
    borders.right = frame:CreateTexture(nil, "OVERLAY")
    borders.right:SetColorTexture(unpack(color))
    borders.right:SetWidth(size)
    borders.right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    borders.right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    
    frame.SAdUI_Borders = borders
end

function addon.updatePlayerFrame()
    local oUF = SAdUI_oUF
    if not oUF then
        print("SAdUI: oUF not loaded yet")
        return
    end
    
    print("SAdUI: Initializing oUF frames...")
    
    oUF.DisableBlizzard = function() end
    
    if not addon.oUFStyleRegistered then
        oUF:RegisterStyle("SAdUI", CreateStyle)
        addon.oUFStyleRegistered = true
        print("SAdUI: Style registered")
    end
    
    oUF:SetActiveStyle("SAdUI")
    
    if not addon.playerFrame then
        addon.playerFrame = oUF:Spawn("player", "SAdUI_PlayerFrame")
        if addon.playerFrame then
            addon.playerFrame:SetPoint("CENTER", UIParent, "CENTER", -350, -150)
            print("SAdUI: Player frame spawned")
        end
    end
end

function addon.RegisterFunctions()
    addon.RegisterEvent("PLAYER_ENTERING_WORLD", function()
        C_Timer.After(0.5, function()
            addon.updatePlayerFrame()
        end)
    end)
end

