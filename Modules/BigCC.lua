local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreateBigCC(frame, panelHeight, options)
    if not frame then
        return nil
    end

    local modCfg = self.config.modules.bigCC
    if not modCfg.enabled then return nil end

    options = options or {}
    local spacing = options.spacing or 2
    local height = options.height or math.floor((panelHeight * 0.66) - (spacing / 2))
    local width = height -- square

    local bigCC = CreateFrame("Frame", nil, frame)
    bigCC:SetPoint(options.anchor or "TOPRIGHT",
        options.relativeTo or frame,
        options.relativePoint or "TOPRIGHT",
        options.offsetX or 0,
        options.offsetY or 0)
    bigCC:SetSize(width, height)

    -- Placeholder icon (desaturated, shown when no CC is active)
    local placeholder = bigCC:CreateTexture(nil, "BACKGROUND")
    placeholder:SetAllPoints(bigCC)
    placeholder:SetTexture("Interface\\Icons\\" .. modCfg.placeholderIcon)
    placeholder:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    placeholder:SetDesaturated(true)
    placeholder:SetAlpha(modCfg.placeholderOpacity)
    bigCC.Placeholder = placeholder

    -- Active CC icon (shown when a CC is active)
    local icon = bigCC:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(bigCC)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:Hide()
    bigCC.Icon = icon

    -- Cooldown swipe overlay
    local cooldown = CreateFrame("Cooldown", nil, bigCC, "CooldownFrameTemplate")
    cooldown:SetAllPoints(bigCC)
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:EnableMouse(false)
    cooldown.noCooldownCount = not modCfg.showCooldownNumbers
    cooldown:SetHideCountdownNumbers(not modCfg.showCooldownNumbers)
    bigCC.Cooldown = cooldown

    -- Tooltip support
    bigCC:EnableMouse(true)
    bigCC:SetScript("OnEnter", function(self)
        if self.activeAuraInstanceID and self.activeUnit then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetUnitDebuffByAuraInstanceID(self.activeUnit, self.activeAuraInstanceID)
            GameTooltip:Show()
        end
    end)
    bigCC:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    addon:AddBorder(bigCC)

    frame.BigCC = bigCC

    return bigCC
end

---------------------------------------------------------------------------
-- oUF element: BigCC
-- Uses C_LossOfControl API to find and display the highest-priority CC
---------------------------------------------------------------------------

local function Update(self, event, unit)
    if self.unit ~= unit then return end

    local element = self.BigCC
    if not element then return end

    --[[ Callback: BigCC:PreUpdate(unit)
    Called before the element has been updated.
    * self - the BigCC element
    * unit - the unit for which the update has been triggered (string)
    --]]
    if element.PreUpdate then
        element:PreUpdate(unit)
    end

    -- Find highest priority CC via C_LossOfControl
    local highestPriorityCC = nil
    local highestPriority = -1

    local count = C_LossOfControl.GetActiveLossOfControlDataCountByUnit(unit)
    for i = 1, count do
        local locData = C_LossOfControl.GetActiveLossOfControlDataByUnit(unit, i)
        if locData and locData.priority and locData.priority > highestPriority then
            highestPriority = locData.priority
            highestPriorityCC = locData
        end
    end

    -- Get the actual aura data for the winning CC
    local auraData = nil
    if highestPriorityCC and highestPriorityCC.auraInstanceID then
        auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, highestPriorityCC.auraInstanceID)
    end

    if auraData then
        -- Show active CC — use C_LossOfControl fields (safe for addon code)
        -- auraData fields (icon, duration, etc.) are secret values and must NOT be used
        element.Icon:SetTexture(highestPriorityCC.iconTexture)
        element.Icon:Show()
        element.activeAuraInstanceID = highestPriorityCC.auraInstanceID
        element.activeUnit = unit
        if element.Placeholder then
            element.Placeholder:Hide()
        end

        -- Set cooldown swipe using C_LossOfControl timing fields
        if element.Cooldown then
            local duration = highestPriorityCC.duration or 0
            local startTime = highestPriorityCC.startTime or 0
            if duration > 0 and startTime > 0 then
                element.Cooldown:SetCooldown(startTime, duration)
                element.Cooldown:Show()
            else
                element.Cooldown:Hide()
            end
        end
    else
        -- No CC active — show placeholder
        element.Icon:Hide()
        element.activeAuraInstanceID = nil
        element.activeUnit = nil
        if element.Placeholder then
            element.Placeholder:Show()
        end
        if element.Cooldown then
            element.Cooldown:Hide()
        end
    end

    --[[ Callback: BigCC:PostUpdate(unit, auraData)
    Called after the element has been updated.
    * self     - the BigCC element
    * unit     - the unit for which the update has been triggered (string)
    * auraData - the aura data of the active CC, or nil if none (table?)
    --]]
    if element.PostUpdate then
        element:PostUpdate(unit, auraData)
    end
end

local function Enable(self)
    local element = self.BigCC
    if element then
        self:RegisterEvent("UNIT_AURA", Update)
        return true
    end
end

local function Disable(self)
    local element = self.BigCC
    if element then
        element.Icon:Hide()
        if element.Placeholder then
            element.Placeholder:Show()
        end
        if element.Cooldown then
            element.Cooldown:Hide()
        end

        self:UnregisterEvent("UNIT_AURA", Update)
    end
end

oUF:AddElement("BigCC", Update, Enable, Disable)