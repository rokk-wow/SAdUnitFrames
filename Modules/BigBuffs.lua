local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreateBigBuffs(frame, panelHeight, options)
    if not frame then
        return nil
    end

    if not self.config.modules.bigBuffs.enabled then return nil end

    options = options or {}
    local spacing = options.spacing or 2
    local height = options.height or math.floor((panelHeight * 0.66) - (spacing / 2))
    local width = height -- square

    local bigBuffs = CreateFrame("Frame", nil, frame)
    bigBuffs:SetPoint(options.anchor or "TOPRIGHT",
        options.relativeTo or frame,
        options.relativePoint or "TOPRIGHT",
        options.offsetX or 0,
        options.offsetY or 0)
    bigBuffs:SetSize(width, height)

    -- Placeholder icon (desaturated at 50% opacity)
    local modCfg = self.config.modules.bigBuffs
    local bg = bigBuffs:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(bigBuffs)
    bg:SetTexture("Interface\\Icons\\" .. modCfg.placeholderIcon)
    bg:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    bg:SetDesaturated(true)
    bg:SetAlpha(modCfg.placeholderOpacity)

    addon:AddBorder(bigBuffs)

    frame.BigBuffs = bigBuffs

    return bigBuffs
end