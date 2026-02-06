local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreateBigDefensives(frame, panelHeight, options)
    if not frame then
        return nil
    end

    if not self.config.modules.bigDefensives.enabled then return nil end

    options = options or {}
    local spacing = options.spacing or 2
    local height = options.height or math.floor((panelHeight * 0.66) - (spacing / 2))
    local width = height -- square

    local bigDefensives = CreateFrame("Frame", nil, frame)
    bigDefensives:SetPoint(options.anchor or "TOPRIGHT",
        options.relativeTo or frame,
        options.relativePoint or "TOPRIGHT",
        options.offsetX or 0,
        options.offsetY or 0)
    bigDefensives:SetSize(width, height)

    -- Placeholder icon (desaturated at 50% opacity)
    local modCfg = self.config.modules.bigDefensives
    local bg = bigDefensives:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(bigDefensives)
    bg:SetTexture("Interface\\Icons\\" .. modCfg.placeholderIcon)
    bg:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    bg:SetDesaturated(true)
    bg:SetAlpha(modCfg.placeholderOpacity)

    addon:AddBorder(bigDefensives)

    frame.BigDefensives = bigDefensives

    return bigDefensives
end