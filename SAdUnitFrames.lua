local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.savedVarsGlobalName = "SAdUnitFrames_Settings_Global"
addon.savedVarsPerCharName = "SAdUnitFrames_Settings_Char"
addon.compartmentFuncName = "SAdUnitFrames_Compartment_Func"
addon.activeChatFilters = {}

addon.vars = {
    borderWidth = 2,
    manaBarOffsetY = 2,
    borderColor = "#000000FF",
    backgroundColor = "#000000AA",
}

addon.combatQueue = addon.combatQueue or {}

function addon:queueForAfterCombat(func)
    if not InCombatLockdown() then
        func()
    else
        table.insert(self.combatQueue, func)
    end
end

function addon:processCombatQueue()
    if InCombatLockdown() then return end
    
    for _, func in ipairs(self.combatQueue) do
        pcall(func)
    end
    
    self.combatQueue = {}
end

function addon:LoadConfig()
    self.config.version = "1.0"
    self.author = "Rôkk-Wyrmrest Accord"

    local textures = {
        {value = "Blizzard", label = "Blizzard (Default)"},
        {value = "Minimalist", label = "Minimalist"},
        {value = "Flat", label = "Flat"},
        {value = "Glamour", label = "Glamour"},
        {value = "Smooth", label = "Smooth"},
        {value = "LiteStep", label = "LiteStep"},
        {value = "Perl", label = "Perl"},
        {value = "Charcoal", label = "Charcoal"},
        {value = "Otravi", label = "Otravi"},
        {value = "Aluminium", label = "Aluminium"},
        {value = "BantoBar", label = "BantoBar"},
        {value = "Bumps", label = "Bumps"},
        {value = "Cilo", label = "Cilo"},
        {value = "Cloud", label = "Cloud"},
        {value = "Gloss", label = "Gloss"},
        {value = "Graphite", label = "Graphite"},
        {value = "Healbot", label = "Healbot"},
        {value = "Round", label = "Round"},
        {value = "Ruben", label = "Ruben"},
        {value = "Skewed", label = "Skewed"},
        {value = "Smoothv2", label = "Smooth v2"},
        {value = "Steel", label = "Steel"},
    }

        self.config.settings.frameStyle = {
            title = "frameStyleTitle",
            controls = {
                {
                    type = "header",
                    name = "frameStyleHeader"
                },
                {
                    type = "dropdown",
                    name = "statusbarTexture",
                    default = "Smooth",
                    options = textures,
                    onValueChange = self.updateAllFrames
                },
            }
        }
end

function addon:updateUnitFrame(frameType)
    local frameTypeLower = frameType:lower()
    
    addon:debug("Updating " .. frameTypeLower .. " frame")
    
    local frameData = addon.unitFrames[frameTypeLower]
    if frameData then
        for funcName, func in pairs(frameData) do
            if type(func) == "function" then
                func(frameData)
            end
        end
    end
end

function addon:getUnitColor(frameType)
    local unitToken = frameType:lower()
    
    addon:debug("Getting color for unit: " .. unitToken)
    addon:debug("UnitIsPlayer: " .. tostring(UnitIsPlayer(unitToken)))
    
    if unitToken == "player" then
        local _, classFileName = UnitClass(unitToken)
        if classFileName and RAID_CLASS_COLORS[classFileName] then
            local classColor = RAID_CLASS_COLORS[classFileName]
            addon:debug("Player class color: " .. classColor.r .. ", " .. classColor.g .. ", " .. classColor.b)
            return classColor.r, classColor.g, classColor.b
        end
    end
    
    if UnitIsPlayer(unitToken) then
        local _, classFileName = UnitClass(unitToken)
        addon:debug("Target is player, class: " .. tostring(classFileName))
        if classFileName and RAID_CLASS_COLORS[classFileName] then
            local classColor = RAID_CLASS_COLORS[classFileName]
            addon:debug("Target class color: " .. classColor.r .. ", " .. classColor.g .. ", " .. classColor.b)
            return classColor.r, classColor.g, classColor.b
        end
    end
    
    if not UnitIsPlayer(unitToken) and UnitIsFriend("player", unitToken) then
        if addon.currentZone == "dungeon" or addon.currentZone == "raid" then
            local _, classFileName = UnitClass(unitToken)
            addon:debug("Friendly NPC in instance, class: " .. tostring(classFileName))
            if classFileName and RAID_CLASS_COLORS[classFileName] then
                local classColor = RAID_CLASS_COLORS[classFileName]
                addon:debug("NPC class color: " .. classColor.r .. ", " .. classColor.g .. ", " .. classColor.b)
                return classColor.r, classColor.g, classColor.b
            end
        end
    end
    
    -- Use Blizzard's default unit selection color for everything else
    local r, g, b = UnitSelectionColor(unitToken)
    addon:debug("UnitSelectionColor: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b))
    if not r or (r == 0 and g == 0 and b == 0) then
        addon:debug("Using fallback white color")
        return 1, 1, 1
    end
    return r, g, b
end

function addon:addBorder(bar)
    if not bar then return end
    
    local size = self.vars.borderWidth
    local colorHex = self.vars.borderColor
    local r, g, b, a = self:hexToRGB(colorHex)
    
    local borders = bar.SAdUnitFrames_Borders
    
    if borders then
        borders.top:SetColorTexture(r, g, b, a)
        borders.top:SetHeight(size)
        
        borders.bottom:SetColorTexture(r, g, b, a)
        borders.bottom:SetHeight(size)
        
        borders.left:SetColorTexture(r, g, b, a)
        borders.left:SetWidth(size)
        
        borders.right:SetColorTexture(r, g, b, a)
        borders.right:SetWidth(size)
    else
        borders = {}
        
        borders.top = bar:CreateTexture(nil, "OVERLAY")
        borders.top:SetColorTexture(r, g, b, a)
        borders.top:SetHeight(size)
        borders.top:ClearAllPoints()
        borders.top:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        borders.top:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
        
        borders.bottom = bar:CreateTexture(nil, "OVERLAY")
        borders.bottom:SetColorTexture(r, g, b, a)
        borders.bottom:SetHeight(size)
        borders.bottom:ClearAllPoints()
        borders.bottom:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
        borders.bottom:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
        
        borders.left = bar:CreateTexture(nil, "OVERLAY")
        borders.left:SetColorTexture(r, g, b, a)
        borders.left:SetWidth(size)
        borders.left:ClearAllPoints()
        borders.left:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        borders.left:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
        
        borders.right = bar:CreateTexture(nil, "OVERLAY")
        borders.right:SetColorTexture(r, g, b, a)
        borders.right:SetWidth(size)
        borders.right:ClearAllPoints()
        borders.right:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
        borders.right:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
        
        bar.SAdUnitFrames_Borders = borders
    end
end

function addon:addBackground(bar)
    if not bar then return end
    
    local colorHex = self.vars.backgroundColor
    local r, g, b, a = self:hexToRGB(colorHex)
    
    if bar.SAdUnitFrames_Background then
        bar.SAdUnitFrames_Background:SetColorTexture(r, g, b, a)
    else
        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetColorTexture(r, g, b, a)
        bg:SetAllPoints(bar)
        bar.SAdUnitFrames_Background = bg
    end
end

function addon:hideFrame(frame)
    if not frame then return end
    
    local function doHide()
        if not frame.sadunitframes_hideHooked then
            frame.sadunitframes_hideHooked = true
            hooksecurefunc(frame, "Show", function(self)
                if self.sadunitframes_hideHooked then
                    self:SetAlpha(0)
                end
            end)
        end
        
        local success, err = pcall(function()
            frame:Hide()
        end)
        
        frame:SetAlpha(0)
    end
    
    addon:queueForAfterCombat(doHide)
end

function addon:setFramePoint(frame, ...)
    if not frame then return end
    if InCombatLockdown() then return end
    frame:ClearAllPoints()
    frame:SetPoint(...)
end

function addon:getTexturePath(textureName)
    if textureName == "Blizzard" then
        return [[Interface\TargetingFrame\UI-StatusBar]]
    else
        return [[Interface\AddOns\SAdUnitFrames\Textures\]] .. textureName
    end
end

function addon:updateAllFrames()
    addon:debug("Updating all frames")
    for _, frameType in ipairs({"Player", "Target", "TargetTarget", "Pet", "Focus", "FocusTarget"}) do
        self:updateUnitFrame(frameType)
    end
end

addon:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    local attempts = 0
    local function tryUpdate()
        attempts = attempts + 1
        if UnitClass("player") then
            addon:updateAllFrames()
        elseif attempts < 20 then
            C_Timer.After(0.1, tryUpdate)
        else
            addon:updateAllFrames()
        end
    end
    C_Timer.After(0.1, tryUpdate)
end)

addon:RegisterEvent("PLAYER_TARGET_CHANGED", function()
    addon:updateUnitFrame("Target")
end)

addon:RegisterEvent("PLAYER_FOCUS_CHANGED", function()
    addon:updateUnitFrame("Focus")
end)

addon:RegisterEvent("UNIT_AURA", function(event, unit)
    if unit == "focus" then
        addon.unitFrames.focus:hideBuffsAndDebuffs()
    end
end)

addon:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function()
    addon:debug("Spec changed, updating player frame")
    C_Timer.After(0.2, function()
        addon:updateUnitFrame("Player")
    end)
end)
