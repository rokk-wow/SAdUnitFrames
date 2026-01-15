local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.savedVarsGlobalName = "SAdUnitFrames_Settings_Global"
addon.savedVarsPerCharName = "SAdUnitFrames_Settings_Char"
addon.compartmentFuncName = "SAdUnitFrames_Compartment_Func"
addon.activeChatFilters = {}

-- Internal constants (not user-configurable)
addon.vars = {
    borderWidth = 2,
    manaBarOffsetY = 2,
}

function addon:LoadConfig()
    self.config.version = "1.0"
    self.author = "Rôkk-Wyrmrest Accord"

    -- Available textures
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
                {
                    type = "colorPicker",
                    name = "borderColor",
                    default = "#000000FF",
                    onValueChange = self.updateAllFrames
                },
                {
                    type = "colorPicker",
                    name = "backgroundColor",
                    default = "#000000AA",
                    onValueChange = self.updateAllFrames
                },
            }
        }

        self.config.settings.enabledFrames = {
            title = "enabledFramesTitle",
            controls = {
                {
                    type = "checkbox",
                    name = "enablePlayerFrame",
                    default = true,
                    onValueChange = function(isEnabled)
                        addon:handleFrameToggle("Player", isEnabled)
                    end
                },
                {
                    type = "checkbox",
                    name = "enableTargetFrame",
                    default = true,
                    onValueChange = function(isEnabled)
                        addon:handleFrameToggle("Target", isEnabled)
                    end
                },
                {
                    type = "checkbox",
                    name = "enablePetFrame",
                    default = true,
                    onValueChange = function(isEnabled)
                        addon:handleFrameToggle("Pet", isEnabled)
                    end
                },
                {
                    type = "checkbox",
                    name = "enableFocusFrame",
                    default = true,
                    onValueChange = function(isEnabled)
                        addon:handleFrameToggle("Focus", isEnabled)
                    end
                }
            }
        }
end

function addon:handleFrameToggle(frameName, isEnabled)
    if not isEnabled then
        self:ShowDialog({
            title = "disableFrameTitle",
            controls = {
                {
                    type = "description",
                    name = "disableFrameMessage"
                },
                {
                    type = "button",
                    name = "disableFrameConfirm",
                    onClick = function()
                        ReloadUI()
                    end
                },
                {
                    type = "button",
                    name = "disableFrameCancel",
                    onClick = function()
                        self.settings.enabledFrames["enable" .. frameName .. "Frame"] = true
                    end
                }
            },
            onClose = function()
                self.settings.enabledFrames["enable" .. frameName .. "Frame"] = true
            end
        })
    else
        local updateFunc = self["update" .. frameName .. "Frame"]
        if updateFunc then
            updateFunc(self)
        end
    end
end

function addon:updateUnitFrame(frameType)
    local frameTypeLower = frameType:lower()
    local settingName = "enable" .. frameType .. "Frame"
    
    if not self.settings.enabledFrames[settingName] then
        return
    end
    
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
    
    -- For player unit, always use class color
    if unitToken == "player" then
        local _, classFileName = UnitClass(unitToken)
        if classFileName and RAID_CLASS_COLORS[classFileName] then
            local classColor = RAID_CLASS_COLORS[classFileName]
            return classColor.r, classColor.g, classColor.b
        end
    end
    
    -- For other players
    if UnitIsPlayer(unitToken) then
        local _, classFileName = UnitClass(unitToken)
        if classFileName and RAID_CLASS_COLORS[classFileName] then
            local classColor = RAID_CLASS_COLORS[classFileName]
            return classColor.r, classColor.g, classColor.b
        end
    end
    
    -- Use Blizzard's default unit selection color for everything else
    local r, g, b = UnitSelectionColor(unitToken)
    if not r or (r == 0 and g == 0 and b == 0) then
        return 1, 1, 1
    end
    return r, g, b
end

function addon:addBorder(bar)
    if not bar then return end
    
    local size = self.vars.borderWidth
    local colorHex = self.settings.frameStyle.borderColor
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
    
    local colorHex = self.settings.frameStyle.backgroundColor
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
    
    if not frame.sadunitframes_hideHooked then
        frame.sadunitframes_hideHooked = true
        hooksecurefunc(frame, "Show", function(self)
            if self.sadunitframes_hideHooked then
                self:Hide()
                self:SetAlpha(0)
            end
        end)
    end
    
    frame:Hide()
    frame:SetAlpha(0)
end

function addon:setFramePoint(frame, ...)
    if not frame then return end
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
    for _, frameType in ipairs({"Player", "Target", "Pet", "Focus"}) do
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
