local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreateTrinket(frame, panelHeight, options)
    if not frame then
        return nil
    end

    if not self.config.modules.trinket.enabled then return nil end

    options = options or {}
    local spacing = options.spacing or 2
    local height = options.height or math.floor((panelHeight * 0.66) - (spacing / 2))
    local width = height -- square, same size as Big CC

    local trinket = CreateFrame("Frame", nil, frame)
    trinket:SetPoint(options.anchor or "TOPRIGHT",
        options.relativeTo or frame,
        options.relativePoint or "TOPRIGHT",
        options.offsetX or 0,
        options.offsetY or 0)
    trinket:SetSize(width, height)

    local modCfg = self.config.modules.trinket

    -- Placeholder icon (desaturated, shown when trinket is available)
    local placeholder = trinket:CreateTexture(nil, "BACKGROUND")
    placeholder:SetAllPoints(trinket)
    placeholder:SetTexture("Interface\\Icons\\" .. modCfg.placeholderIcon)
    placeholder:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    placeholder:SetDesaturated(true)
    placeholder:SetAlpha(modCfg.placeholderOpacity)
    trinket.Placeholder = placeholder

    addon:AddBorder(trinket)

    frame.Trinket = trinket

    return trinket
end