local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreateDispelBorder(frame, options)
    if not frame or not frame.Health then
        return nil
    end

    if not self.config.modules.dispelBorder.enabled then return nil end

    options = options or {}
    local borderSize = options.borderSize or 3
    local r, g, b = self:HexToRGB(options.color or "FF00FF")

    local dispelBorder = CreateFrame("Frame", nil, frame.Health, "BackdropTemplate")
    dispelBorder:SetPoint("TOPLEFT", frame.Health, "TOPLEFT", borderSize - 1, -(borderSize - 1))
    dispelBorder:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -(borderSize - 1), borderSize - 1)
    dispelBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = borderSize,
    })
    dispelBorder:SetBackdropBorderColor(r, g, b, 1)
    dispelBorder:SetFrameLevel(frame.Health:GetFrameLevel() + 5)

    frame.DispelBorder = dispelBorder

    return dispelBorder
end