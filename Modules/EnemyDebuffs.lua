local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

function addon:CreateEnemyDebuffs(frame, panelHeight, options)
    if not frame then
        return nil
    end

    if not self.config.modules.enemyDebuffs.enabled then return nil end

    options = options or {}
    local spacing = options.spacing or 2
    local height = options.height or math.floor((panelHeight * 0.34) - (spacing / 2)) + 1
    local size = height -- square debuff icons matching castbar height
    local num = options.num or 4

    local debuffs = CreateFrame("Frame", nil, frame)
    debuffs:SetPoint(options.anchor or "BOTTOMLEFT",
        options.relativeTo or frame,
        options.relativePoint or "BOTTOMLEFT",
        options.offsetX or 0,
        options.offsetY or 0)
    debuffs:SetSize(num * (size + spacing), size)

    -- Create 4 placeholder debuff icons
    local placeholderColors = {
        {0.8, 0.2, 0.8, 0.5}, -- purple
        {0.9, 0.3, 0.1, 0.5}, -- orange
        {0.2, 0.7, 0.2, 0.5}, -- green
        {0.6, 0.2, 0.2, 0.5}, -- dark red
    }

    for i = 1, num do
        local icon = CreateFrame("Frame", nil, debuffs)
        icon:SetSize(size, size)
        if i == 1 then
            icon:SetPoint("BOTTOMRIGHT", debuffs, "BOTTOMRIGHT", 0, 0)
        else
            icon:SetPoint("BOTTOMRIGHT", debuffs[i - 1], "BOTTOMLEFT", -spacing, 0)
        end

        local bg = icon:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(icon)
        local c = placeholderColors[i]
        bg:SetColorTexture(c[1], c[2], c[3], c[4])

        addon:AddBorder(icon)

        debuffs[i] = icon
    end

    frame.EnemyDebuffs = debuffs

    return debuffs
end