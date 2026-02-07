local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.Party = addon.unitFrames.Party or {}

function addon.unitFrames.Party:Show()
    -- Only show party frames when actually in a party
    if not IsInGroup() then
        return
    end
    
    -- Initialize player party frame first (anchor point for party1)
    if addon.unitFrames.PlayerParty and UnitExists("player") then
        if not addon.unitFrames.PlayerParty.frame then
            addon.unitFrames.PlayerParty:Initialize()
        end
    end
    
    -- Initialize party frames sequentially (each anchors to the previous)
    for i = 1, 4 do
        local unitFrameKey = "Party" .. i
        local unitId = "party" .. i
        
        if addon.unitFrames[unitFrameKey] and UnitExists(unitId) then
            if not addon.unitFrames[unitFrameKey].frame then
                -- Wait a tick to ensure previous frame is fully initialized
                if i > 1 then
                    local prevFrameKey = i == 1 and "PlayerParty" or ("Party" .. (i - 1))
                    if not addon.unitFrames[prevFrameKey] or not addon.unitFrames[prevFrameKey].frame then
                        -- Previous frame not ready yet, skip for now
                        return
                    end
                end
                addon.unitFrames[unitFrameKey]:Initialize()
            end
        end
    end
end

function addon.unitFrames.Party:Hide()
    -- Hide all party frames
    if addon.unitFrames.PlayerParty and addon.unitFrames.PlayerParty.frame then
        addon.unitFrames.PlayerParty.frame:Hide()
    end
    
    for i = 1, 4 do
        local unitFrameKey = "Party" .. i
        if addon.unitFrames[unitFrameKey] and addon.unitFrames[unitFrameKey].frame then
            addon.unitFrames[unitFrameKey].frame:Hide()
        end
    end
end

-- Generic function to build party frames
function addon:BuildPartyFrame(unit, anchor, relativeTo, relativePoint, offsetX, offsetY, isDraggable)
    if not oUF then
        print("BuildPartyFrame: oUF not available")
        return nil
    end
    
    local unitKey
    if unit == "player" then
        unitKey = "PlayerParty"
    else
        local index = unit and unit:match("^party(%d)$")
        if index then
            unitKey = "Party" .. index
        end
    end

    if not unitKey and unit then
        unitKey = unit:gsub("party", "Party")
    end

    if not unitKey then
        print("BuildPartyFrame: unable to resolve unitKey for unit " .. tostring(unit))
        return nil
    end
    
    -- Initialize frame object
    addon.unitFrames[unitKey] = addon.unitFrames[unitKey] or {}
    local frameObj = addon.unitFrames[unitKey]
    
    -- Don't recreate if already exists
    if frameObj.frame then
        return frameObj.frame
    end
    
    -- Register and set style
    local styleName = 'SAdUnitFrames_' .. unitKey
    oUF:RegisterStyle(styleName, function(frame, frameUnit)
        addon:StylePartyFrame(frame, frameUnit, anchor, relativeTo, relativePoint, offsetX, offsetY)
    end)
    oUF:SetActiveStyle(styleName)
    
    -- Spawn the frame
    local frameName = 'SAdUnitFrames_' .. unitKey .. 'Frame'
    frameObj.frame = oUF:Spawn(unit, frameName)
    
    -- Make draggable if requested
    if isDraggable then
        addon:MakeFrameDraggable(frameObj.frame)
    end
    
    -- Use SAdCore Retry to wait for role/spec data which may arrive late
    if frameObj.frame then
        local f = frameObj.frame
        addon:Retry(function()
            if not f or not f.unit or not UnitExists(f.unit) then
                return false
            end
            f:UpdateAllElements('RefreshUnit')
            addon:UpdateUnitHeader(f)
            return f.RoleIcon and f.RoleIcon:IsShown()
        end, 0.1)
    end
    
    return frameObj.frame
end

-- Style function for party frames
function addon:StylePartyFrame(frame, unit, anchor, relativeTo, relativePoint, offsetX, offsetY)
    local cfg = addon.config.global
    
    frame:SetSize(cfg.partyFramesWidth, cfg.partyFramesHeight)
    
    -- Enable mouse clicks
    frame:RegisterForClicks('AnyUp')
    
    -- Position
    frame:SetPoint(anchor, _G[relativeTo] or relativeTo, relativePoint, offsetX, offsetY)
    
    -- Background
    local Background = frame:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(frame)
    local bgR, bgG, bgB, bgA = addon:HexToRGB(cfg.backgroundColor)
    Background:SetColorTexture(bgR, bgG, bgB, bgA)

    addon:CreateUnitHeader(frame, cfg.partyFramesWidth, cfg.partyFramesHeight)
    
    -- Health Bar
    local Health = CreateFrame('StatusBar', nil, frame)
    Health:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
    Health:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
    Health:SetHeight(cfg.partyFramesHeight)
    Health:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.healthTexture)
    Health.colorClass = true
    Health.colorReaction = true
    
    -- Add border
    addon:AddBorder(Health)
    
    frame.Health = Health
    
    -- Health Prediction (damage absorbs)
    local HealthPrediction = {}
    local damageAbsorb = CreateFrame('StatusBar', nil, Health)
    damageAbsorb:SetPoint('TOP')
    damageAbsorb:SetPoint('BOTTOM')
    damageAbsorb:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
    damageAbsorb:SetPoint('RIGHT', Health, 'RIGHT')
    damageAbsorb:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.absorbTexture)
    damageAbsorb:SetStatusBarColor(1, 1, 1, cfg.absorbOpacity)
    HealthPrediction.damageAbsorb = damageAbsorb
    HealthPrediction.maxOverflow = cfg.maxAbsorbOverflow
    frame.HealthPrediction = HealthPrediction

    -- Right panel: Big modules chain to the right of the health bar.
    -- Each module anchors to the previous ENABLED one, skipping disabled.
    local rightPanelSpacing = cfg.partyRightPanelSpacing
    local lastRightAnchor = Health

    local bigCC = addon:CreateBigCC(frame, cfg.partyFramesHeight, {
        spacing = rightPanelSpacing,
        anchor = "TOPLEFT",
        relativeTo = lastRightAnchor,
        relativePoint = "TOPRIGHT",
        offsetX = rightPanelSpacing,
        offsetY = 0,
    })
    if bigCC then lastRightAnchor = bigCC end

    local bigBuffs = addon:CreateBigBuffs(frame, cfg.partyFramesHeight, {
        spacing = rightPanelSpacing,
        anchor = "TOPLEFT",
        relativeTo = lastRightAnchor,
        relativePoint = "TOPRIGHT",
        offsetX = rightPanelSpacing,
        offsetY = 0,
    })
    if bigBuffs then lastRightAnchor = bigBuffs end

    addon:CreateBigDefensives(frame, cfg.partyFramesHeight, {
        spacing = rightPanelSpacing,
        anchor = "TOPLEFT",
        relativeTo = lastRightAnchor,
        relativePoint = "TOPRIGHT",
        offsetX = rightPanelSpacing,
        offsetY = 0,
    })

    addon:CreatePartyCastbar(frame, cfg.partyFramesWidth, cfg.partyFramesHeight, {
        spacing = rightPanelSpacing,
        anchor = "BOTTOMLEFT",
        relativeTo = Health,
        relativePoint = "BOTTOMRIGHT",
        offsetX = rightPanelSpacing,
        offsetY = 0,
        alignIcon = "RIGHT",
    })

    -- Left panel: Trinket (square, symmetrical to Big CC)
    local trinket = addon:CreateTrinket(frame, cfg.partyFramesHeight, {
        spacing = rightPanelSpacing,
        anchor = "TOPRIGHT",
        relativeTo = Health,
        relativePoint = "TOPLEFT",
        offsetX = -rightPanelSpacing,
        offsetY = 0,
    })

    -- Enemy debuffs below trinket, grows left
    addon:CreateEnemyDebuffs(frame, cfg.partyFramesHeight, {
        spacing = rightPanelSpacing,
        anchor = "BOTTOMRIGHT",
        relativeTo = Health,
        relativePoint = "BOTTOMLEFT",
        offsetX = -rightPanelSpacing,
        offsetY = 0,
    })

    -- Dispel border (inside health bar) — shows when unit has a dispellable debuff
    addon:CreateDispelBorder(frame)

    addon:CreatePlayerBuffs(frame, cfg.partyFramesWidth, cfg.partyFramesHeight, {
        offsetX = -5,
        offsetY = 5,
    })
    
end

-- Initialize functions for each party member
-- Player is the first party member (yourself)
addon.unitFrames.PlayerParty = addon.unitFrames.PlayerParty or {}
function addon.unitFrames.PlayerParty:Initialize()
    local cfg = addon.config.global
    addon:BuildPartyFrame("player", 
        cfg.playerPartyFrameAnchor, 
        cfg.playerPartyFrameRelativeTo, 
        cfg.playerPartyFrameRelativePoint, 
        cfg.playerPartyFrameOffsetX, 
        cfg.playerPartyFrameOffsetY,
        true) -- draggable
end

-- Party1 is the second party member
addon.unitFrames.Party1 = addon.unitFrames.Party1 or {}
function addon.unitFrames.Party1:Initialize()
    local cfg = addon.config.global
    addon:BuildPartyFrame("party1", 
        cfg.party1FrameAnchor, 
        cfg.party1FrameRelativeTo, 
        cfg.party1FrameRelativePoint, 
        cfg.partyFramesOffsetX, 
        cfg.partyFramesOffsetY,
        false) -- draggable
end

addon.unitFrames.Party2 = addon.unitFrames.Party2 or {}
function addon.unitFrames.Party2:Initialize()
    local cfg = addon.config.global
    addon:BuildPartyFrame("party2", 
        cfg.party2FrameAnchor, 
        cfg.party2FrameRelativeTo, 
        cfg.party2FrameRelativePoint, 
        cfg.partyFramesOffsetX, 
        cfg.partyFramesOffsetY,
        false) -- not draggable
end

addon.unitFrames.Party3 = addon.unitFrames.Party3 or {}
function addon.unitFrames.Party3:Initialize()
    local cfg = addon.config.global
    addon:BuildPartyFrame("party3", 
        cfg.party3FrameAnchor, 
        cfg.party3FrameRelativeTo, 
        cfg.party3FrameRelativePoint, 
        cfg.partyFramesOffsetX, 
        cfg.partyFramesOffsetY,
        false) -- not draggable
end

addon.unitFrames.Party4 = addon.unitFrames.Party4 or {}
function addon.unitFrames.Party4:Initialize()
    local cfg = addon.config.global
    addon:BuildPartyFrame("party4", 
        cfg.party4FrameAnchor, 
        cfg.party4FrameRelativeTo, 
        cfg.party4FrameRelativePoint, 
        cfg.partyFramesOffsetX, 
        cfg.partyFramesOffsetY,
        false) -- not draggable
end
