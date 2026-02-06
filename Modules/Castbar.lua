local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreatePartyCastbar(frame, healthBarWidth, panelHeight, options)
    if not frame then
        return nil
    end

    local cfg = self.config.global
    local modCfg = self.config.modules.castbar
    if not modCfg.enabled then return nil end
    options = options or {}
    local spacing = options.spacing or 2
    local height = options.height or math.floor((panelHeight * 0.34) - (spacing / 2)) + 1
    local fontPath = self:GetFontPath()
    local castbarColor = options.color or cfg.partyCastbarColor or "FFBB00"

    -- Alignment: "RIGHT" means icon on right (for left-side frames),
    -- "LEFT" means icon on left (for right-side frames).
    -- Other modules can use the same options.alignIcon convention.
    local alignIcon = options.alignIcon or "RIGHT"

    local width = math.floor(healthBarWidth * 0.8) - 18

    local Castbar = CreateFrame("StatusBar", nil, frame)
    Castbar:SetPoint(options.anchor or "BOTTOMRIGHT",
        options.relativeTo or frame,
        options.relativePoint or "BOTTOMRIGHT",
        options.offsetX or 0,
        options.offsetY or 0)
    Castbar:SetSize(width, height)
    Castbar:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.healthTexture)

    local r, g, b = self:HexToRGB(castbarColor)
    Castbar:SetStatusBarColor(r, g, b)

    -- Spell icon (extends beyond castbar on the aligned side)
    if modCfg.showCastIcon then
        local Icon = Castbar:CreateTexture(nil, "OVERLAY")
        Icon:SetSize(height, height)
        Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- trim default icon border

        if alignIcon == "LEFT" then
            Icon:SetPoint("RIGHT", Castbar, "LEFT", -1, 0)
        else
            Icon:SetPoint("LEFT", Castbar, "RIGHT", 1, 0)
        end

        Castbar.Icon = Icon

        -- Icon border
        local iconBorder = CreateFrame("Frame", nil, Castbar)
        iconBorder:SetPoint("TOPLEFT", Icon, "TOPLEFT", 0, 0)
        iconBorder:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMRIGHT", 0, 0)
        addon:AddBorder(iconBorder)
    end

    -- Background
    local bg = Castbar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(Castbar)
    bg:SetTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.healthTexture)
    bg:SetVertexColor(0.15, 0.15, 0.15, 0.8)
    Castbar.bg = bg

    -- Border
    addon:AddBorder(Castbar)

    -- Spark
    local Spark = Castbar:CreateTexture(nil, "OVERLAY")
    Spark:SetSize(20, height * 2)
    Spark:SetBlendMode("ADD")
    Spark:SetPoint("CENTER", Castbar:GetStatusBarTexture(), "RIGHT", 0, 0)
    Castbar.Spark = Spark

    -- Spell name text
    if modCfg.showCastName then
        local Text = Castbar:CreateFontString(nil, "OVERLAY")
        Text:SetFont(fontPath, cfg.extraSmallFontSize - 2, "OUTLINE")
        Text:SetPoint("LEFT", Castbar, "LEFT", 2, 0)
        Text:SetPoint("RIGHT", Castbar, "RIGHT", -2, 0)
        Text:SetJustifyH("CENTER")
        Text:SetWordWrap(false)
        Castbar.Text = Text
    end

    -- Apply configured cast bar color on every cast/channel start.
    -- NOTE: notInterruptible is a secret value and cannot be tested.
    Castbar.PostCastStart = function(element)
        element:SetStatusBarColor(r, g, b)
    end

    Castbar.PostChannelStart = Castbar.PostCastStart

    Castbar.timeToHold = 0.3

    frame.Castbar = Castbar

    return Castbar
end