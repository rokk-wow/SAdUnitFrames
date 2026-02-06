local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

addon.sadCore.savedVarsGlobalName = "SAdUnitFrames_Settings_Global"
addon.sadCore.savedVarsPerCharName = "SAdUnitFrames_Settings_Char"
addon.sadCore.compartmentFuncName = "SAdUnitFrames_Compartment_Func"

function addon:Initialize()
    self.author = "Rôkk-Wyrmrest Accord"
    
    -- Override oUF power colors with our config colors (do this early, before any frames are created)
    if oUF and oUF.colors and oUF.colors.power then
        local cfg = self.config.global
        
        -- MANA
        local manaR, manaG, manaB = self:HexToRGB(cfg.manaColor)
        oUF.colors.power["MANA"] = oUF:CreateColor(manaR, manaG, manaB)
        oUF.colors.power[Enum.PowerType.Mana or 0] = oUF.colors.power["MANA"]
        
        -- RAGE
        local rageR, rageG, rageB = self:HexToRGB(cfg.rageColor)
        oUF.colors.power["RAGE"] = oUF:CreateColor(rageR, rageG, rageB)
        oUF.colors.power[Enum.PowerType.Rage or 1] = oUF.colors.power["RAGE"]
        
        -- FOCUS
        local focusR, focusG, focusB = self:HexToRGB(cfg.focusColor)
        oUF.colors.power["FOCUS"] = oUF:CreateColor(focusR, focusG, focusB)
        oUF.colors.power[Enum.PowerType.Focus or 2] = oUF.colors.power["FOCUS"]
        
        -- ENERGY
        local energyR, energyG, energyB = self:HexToRGB(cfg.energyColor)
        oUF.colors.power["ENERGY"] = oUF:CreateColor(energyR, energyG, energyB)
        oUF.colors.power[Enum.PowerType.Energy or 3] = oUF.colors.power["ENERGY"]
        
        -- RUNIC_POWER
        local runicR, runicG, runicB = self:HexToRGB(cfg.runicPowerColor)
        oUF.colors.power["RUNIC_POWER"] = oUF:CreateColor(runicR, runicG, runicB)
        oUF.colors.power[Enum.PowerType.RunicPower or 6] = oUF.colors.power["RUNIC_POWER"]
        
        -- LUNAR_POWER (Balance Druid)
        local lunarR, lunarG, lunarB = self:HexToRGB(cfg.lunarPowerColor)
        oUF.colors.power["LUNAR_POWER"] = oUF:CreateColor(lunarR, lunarG, lunarB)
        oUF.colors.power[Enum.PowerType.LunarPower or 8] = oUF.colors.power["LUNAR_POWER"]
    end
    
    -- Prevent oUF from hiding Blizzard party and arena frames
    -- This allows both frames to be visible for development
    if oUF and oUF.DisableBlizzard then
        local originalDisableBlizzard = oUF.DisableBlizzard
        oUF.DisableBlizzard = function(self, unit)
            if unit and not unit:match('party%d?$') and not unit:match('arena%d?$') then
                originalDisableBlizzard(self, unit)
            end
        end
    end

    self:AddSettingsPanel("frameStyle", {
        title = "frameStyleTitle",
        controls = {
            {
                type = "header",
                name = "frameStyleHeader"
            },
        }
    })

    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.onPlayerEnteringWorld)   
    self:RegisterEvent("PLAYER_TARGET_CHANGED", self.onPlayerTargetChanged)    
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", self.onPlayerFocusChange)    
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", self.onPlayerSpecChange)
    self:RegisterEvent("UNIT_AURA", self.onUnitAura)
    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", self.onGroupUpdate)
    self:RegisterEvent("ARENA_OPPONENT_UPDATE", self.onGroupUpdate)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", self.onGroupUpdate)
end

function addon:onPlayerEnteringWorld()
    -- Show all standard frames
    self.unitFrames.Player:Show()
    self.unitFrames.Target:Show()
    self.unitFrames.TargetTarget:Show()
    self.unitFrames.Focus:Show()
    self.unitFrames.FocusTarget:Show()
    self.unitFrames.Pet:Show()
    
    -- Initialize party frames
    self.unitFrames.PlayerParty:Initialize()
    self.unitFrames.Party1:Initialize()
    self.unitFrames.Party2:Initialize()
    self.unitFrames.Party3:Initialize()
    self.unitFrames.Party4:Initialize()
    
    -- Initialize arena frames
    self.unitFrames.Arena1:Initialize()
    self.unitFrames.Arena2:Initialize()
    self.unitFrames.Arena3:Initialize()
    
    -- Disable party/arena frames initially
    if self.unitFrames.PlayerParty.frame then self.unitFrames.PlayerParty.frame:Disable() end
    if self.unitFrames.Party1.frame then self.unitFrames.Party1.frame:Disable() end
    if self.unitFrames.Party2.frame then self.unitFrames.Party2.frame:Disable() end
    if self.unitFrames.Party3.frame then self.unitFrames.Party3.frame:Disable() end
    if self.unitFrames.Party4.frame then self.unitFrames.Party4.frame:Disable() end
    if self.unitFrames.Arena1.frame then self.unitFrames.Arena1.frame:Disable() end
    if self.unitFrames.Arena2.frame then self.unitFrames.Arena2.frame:Disable() end
    if self.unitFrames.Arena3.frame then self.unitFrames.Arena3.frame:Disable() end
    
    -- Update frame visibility based on group status
    self:UpdateGroupFrames()    
end

function addon:onPlayerTargetChanged()
    local target = UnitName("target")
    
    -- Remove target border from all party/arena frames
    if self.unitFrames.PlayerParty.frame then self:RemoveTargetBorder(self.unitFrames.PlayerParty.frame) end
    if self.unitFrames.Party1.frame then self:RemoveTargetBorder(self.unitFrames.Party1.frame) end
    if self.unitFrames.Party2.frame then self:RemoveTargetBorder(self.unitFrames.Party2.frame) end
    if self.unitFrames.Party3.frame then self:RemoveTargetBorder(self.unitFrames.Party3.frame) end
    if self.unitFrames.Party4.frame then self:RemoveTargetBorder(self.unitFrames.Party4.frame) end
    if self.unitFrames.Arena1.frame then self:RemoveTargetBorder(self.unitFrames.Arena1.frame) end
    if self.unitFrames.Arena2.frame then self:RemoveTargetBorder(self.unitFrames.Arena2.frame) end
    if self.unitFrames.Arena3.frame then self:RemoveTargetBorder(self.unitFrames.Arena3.frame) end
    
    -- Add target border to the targeted frame
    if UnitExists("target") then
        -- Check party frames
        if UnitIsUnit("target", "player") and self.unitFrames.PlayerParty.frame then
            self:AddTargetBorder(self.unitFrames.PlayerParty.frame)
        elseif UnitIsUnit("target", "party1") and self.unitFrames.Party1.frame then
            self:AddTargetBorder(self.unitFrames.Party1.frame)
        elseif UnitIsUnit("target", "party2") and self.unitFrames.Party2.frame then
            self:AddTargetBorder(self.unitFrames.Party2.frame)
        elseif UnitIsUnit("target", "party3") and self.unitFrames.Party3.frame then
            self:AddTargetBorder(self.unitFrames.Party3.frame)
        elseif UnitIsUnit("target", "party4") and self.unitFrames.Party4.frame then
            self:AddTargetBorder(self.unitFrames.Party4.frame)
        -- Check arena frames
        elseif UnitIsUnit("target", "arena1") and self.unitFrames.Arena1.frame then
            self:AddTargetBorder(self.unitFrames.Arena1.frame)
        elseif UnitIsUnit("target", "arena2") and self.unitFrames.Arena2.frame then
            self:AddTargetBorder(self.unitFrames.Arena2.frame)
        elseif UnitIsUnit("target", "arena3") and self.unitFrames.Arena3.frame then
            self:AddTargetBorder(self.unitFrames.Arena3.frame)
        end
    end
end

function addon:onPlayerFocusChange()
end

function addon:onPlayerSpecChange()
end

function addon:onUnitAura()
end

function addon:onGroupUpdate(event)
    -- Enable party frames when in a group
    if IsInGroup() then
        if self.unitFrames.PlayerParty.frame then self.unitFrames.PlayerParty.frame:Enable() end
        if self.unitFrames.Party1.frame then self.unitFrames.Party1.frame:Enable() end
        if self.unitFrames.Party2.frame then self.unitFrames.Party2.frame:Enable() end
        if self.unitFrames.Party3.frame then self.unitFrames.Party3.frame:Enable() end
        if self.unitFrames.Party4.frame then self.unitFrames.Party4.frame:Enable() end
    else
        -- Disable party frames when not in a group 
        if self.unitFrames.PlayerParty.frame then self.unitFrames.PlayerParty.frame:Disable() end
        if self.unitFrames.Party1.frame then self.unitFrames.Party1.frame:Disable() end
        if self.unitFrames.Party2.frame then self.unitFrames.Party2.frame:Disable() end
        if self.unitFrames.Party3.frame then self.unitFrames.Party3.frame:Disable() end
        if self.unitFrames.Party4.frame then self.unitFrames.Party4.frame:Disable() end
    end
    
    -- Enable arena frames when arena units exist
    if UnitExists("arena1") then
        if self.unitFrames.Arena1.frame then self.unitFrames.Arena1.frame:Enable() end
        if self.unitFrames.Arena2.frame then self.unitFrames.Arena2.frame:Enable() end
        if self.unitFrames.Arena3.frame then self.unitFrames.Arena3.frame:Enable() end
    else
        if self.unitFrames.Arena1.frame then self.unitFrames.Arena1.frame:Disable() end
        if self.unitFrames.Arena2.frame then self.unitFrames.Arena2.frame:Disable() end
        if self.unitFrames.Arena3.frame then self.unitFrames.Arena3.frame:Disable() end
    end
end

function addon:UpdateGroupFrames()
    -- Delegate to onGroupUpdate which handles all party and arena frames
    self:onGroupUpdate("UpdateGroupFrames")
end

function addon:OnZoneChange(newZone)
    -- Update party/arena frames based on zone
    self:UpdateGroupFrames()
end

function addon:AddTextureBorder(button)
    -- Create solid black border using simple textures
    button.borderTop = button:CreateTexture(nil, 'OVERLAY', nil, 7)
    button.borderTop:SetColorTexture(0, 0, 0, 1)
    button.borderTop:SetPoint('BOTTOMLEFT', button, 'TOPLEFT', 0, 0)
    button.borderTop:SetPoint('BOTTOMRIGHT', button, 'TOPRIGHT', 0, 0)
    button.borderTop:SetHeight(1)
    
    button.borderBottom = button:CreateTexture(nil, 'OVERLAY', nil, 7)
    button.borderBottom:SetColorTexture(0, 0, 0, 1)
    button.borderBottom:SetPoint('TOPLEFT', button, 'BOTTOMLEFT', 0, 0)
    button.borderBottom:SetPoint('TOPRIGHT', button, 'BOTTOMRIGHT', 0, 0)
    button.borderBottom:SetHeight(1)
    
    button.borderLeft = button:CreateTexture(nil, 'OVERLAY', nil, 7)
    button.borderLeft:SetColorTexture(0, 0, 0, 1)
    button.borderLeft:SetPoint('TOPRIGHT', button, 'TOPLEFT', 0, 0)
    button.borderLeft:SetPoint('BOTTOMRIGHT', button, 'BOTTOMLEFT', 0, 0)
    button.borderLeft:SetWidth(1)
    
    button.borderRight = button:CreateTexture(nil, 'OVERLAY', nil, 7)
    button.borderRight:SetColorTexture(0, 0, 0, 1)
    button.borderRight:SetPoint('TOPLEFT', button, 'TOPRIGHT', 0, 0)
    button.borderRight:SetPoint('BOTTOMLEFT', button, 'BOTTOMRIGHT', 0, 0)
    button.borderRight:SetWidth(1)
end

function addon:AddBorder(frame)
    local cfg = self.config.global
    local borderR, borderG, borderB, borderA = self:HexToRGB(cfg.borderColor)
    
    frame.border = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
    frame.border:SetAllPoints(frame)
    frame.border:SetBackdrop({
        edgeFile = 'Interface\\Buttons\\WHITE8X8',
        edgeSize = cfg.borderWidth,
    })
    frame.border:SetBackdropBorderColor(borderR, borderG, borderB, borderA)
end

function addon:AddTargetBorder(frame)
    if not frame.targetBorder then
        frame.targetBorder = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
        frame.targetBorder:SetBackdrop({
            edgeFile = 'Interface\\Buttons\\WHITE8X8',
            edgeSize = 2,
        })
        frame.targetBorder:SetFrameLevel(frame:GetFrameLevel() + 10)
        local cfg = self.config.global
        local r, g, b, a = self:HexToRGB(cfg.targetBorderColor)
        frame.targetBorder:SetBackdropBorderColor(r, g, b, a)
        frame.targetBorder:Hide()
    end

    frame.targetBorder:ClearAllPoints()
    if frame.Health then
        frame.targetBorder:SetPoint('TOPLEFT', frame.Health, 'TOPLEFT', 0, 0)
        frame.targetBorder:SetPoint('TOPRIGHT', frame.Health, 'TOPRIGHT', 0, 0)

        if frame.Power and frame.Power:IsShown() then
            frame.targetBorder:SetPoint('BOTTOMLEFT', frame.Power, 'BOTTOMLEFT', 0, 0)
            frame.targetBorder:SetPoint('BOTTOMRIGHT', frame.Power, 'BOTTOMRIGHT', 0, 0)
        else
            frame.targetBorder:SetPoint('BOTTOMLEFT', frame.Health, 'BOTTOMLEFT', 0, 0)
            frame.targetBorder:SetPoint('BOTTOMRIGHT', frame.Health, 'BOTTOMRIGHT', 0, 0)
        end
    else
        frame.targetBorder:SetAllPoints(frame)
    end
    frame.targetBorder:Show()
end

function addon:RemoveTargetBorder(frame)
    if frame and frame.targetBorder then
        frame.targetBorder:Hide()
    end
end

function addon:GetFontPath()
    local cfg = self.config.global
    return 'Interface\\AddOns\\SAdUnitFrames\\Media\\Fonts\\' .. cfg.font .. '.ttf'
end

function addon:MakeFrameDraggable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        -- Disable dragging during combat
        if InCombatLockdown() then
            return
        end
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
end

function addon:GetPowerDisplayType(unit)
    -- Returns: "power", "classpower", or "runes"
    local _, class = UnitClass(unit)
    local spec = GetSpecialization()
    
    -- Death Knights use Runes
    if class == "DEATHKNIGHT" then
        return "runes"
    end
    
    -- Rogues and Feral Druids use Combo Points
    if class == "ROGUE" then
        return "classpower"
    end
    
    if class == "DRUID" and spec then
        local specID = GetSpecializationInfo(spec)
        -- Feral is spec 2
        if specID == 103 then -- Feral
            return "classpower"
        end
    end
    
    -- Everyone else uses standard Power bar
    return "power"
end

function addon:GetUnitSpecId(unit)
    if not unit then
        return nil
    end

    if UnitIsUnit(unit, "player") then
        local specIndex = GetSpecialization()
        if specIndex then
            local specId = GetSpecializationInfo(specIndex)
            if specId and specId > 0 then
                return specId
            end
        end
    end

    local arenaIndex = unit:match("^arena(%d)$")
    if arenaIndex and type(GetArenaOpponentSpec) == "function" then
        local specId = GetArenaOpponentSpec(tonumber(arenaIndex))
        if specId and specId > 0 then
            return specId
        end
    end

    if type(GetInspectSpecialization) == "function" then
        local specId = GetInspectSpecialization(unit)
        if specId and specId > 0 then
            return specId
        end
    end

    if type(GetSpecializationInfoForUnit) == "function" then
        local specId = GetSpecializationInfoForUnit(unit)
        if specId and specId > 0 then
            return specId
        end
    end

    if C_SpecializationInfo and type(C_SpecializationInfo.GetSpecializationInfoForUnit) == "function" then
        local specId = C_SpecializationInfo.GetSpecializationInfoForUnit(unit)
        if specId and specId > 0 then
            return specId
        end
    end

    return nil
end

function addon:GetUnitSpecAbbreviation(unit)
    local specId = self:GetUnitSpecId(unit)
    local cfg = self.config.global
    if specId and cfg.specAbbrevById and cfg.specAbbrevById[specId] then
        return cfg.specAbbrevById[specId]
    end
    return ""
end

function addon:GetUnitRole(unit)
    local role = UnitGroupRolesAssigned(unit)
    if role and role ~= "NONE" then
        return role
    end

    local specId = self:GetUnitSpecId(unit)
    if specId and type(GetSpecializationRoleByID) == "function" then
        local specRole = GetSpecializationRoleByID(specId)
        if specRole and specRole ~= "NONE" then
            return specRole
        end
    end

    return nil
end

function addon:UpdateHealerManaBar(frame, manaHeight, totalHeight)
    if not frame or not frame.Health or not frame.Power then
        return
    end

    if not frame.unit then
        frame.Power:Hide()
        return
    end

    local role = self:GetUnitRole(frame.unit)
    if role == "HEALER" then
        frame.Health:SetHeight(totalHeight - manaHeight + 2)
        frame.Power:SetHeight(manaHeight)
        frame.Power:Show()
    else
        frame.Health:SetHeight(totalHeight)
        frame.Power:Hide()
    end
end

function addon:UpdateUnitHeader(frame)
    if not frame or not frame.unit then
        return
    end

    if frame.RoleIcon then
        local cfg = self.config.global
        local role = self:GetUnitRole(frame.unit)
        local roleAtlas = role and cfg.roleIconAtlases and cfg.roleIconAtlases[role] or nil
        if roleAtlas then
            frame.RoleIcon:SetAtlas(roleAtlas, true)
            frame.RoleIcon:SetSize(12, 12)
            frame.RoleIcon:SetDesaturated(true)
            local roleR, roleG, roleB = self:HexToRGB("FFFFFF")
            frame.RoleIcon:SetVertexColor(roleR, roleG, roleB, 1)
            frame.RoleIcon:Show()
        else
            frame.RoleIcon:Hide()
        end
    end

    if frame.SpecText then
        frame.SpecText:SetText(self:GetUnitSpecAbbreviation(frame.unit))
    end
end

function addon:CreateUnitHeader(frame, totalWidth, totalHeight)
    local cfg = self.config.global
    local fontPath = self:GetFontPath()
    local headerHeight = totalHeight / 3
    local leftWidth = totalWidth * 0.75
    local rightWidth = totalWidth - leftWidth

    local header = CreateFrame("Frame", nil, frame)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -3)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -3)
    header:SetHeight(headerHeight)

    local left = CreateFrame("Frame", nil, header)
    left:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    left:SetWidth(leftWidth)

    local right = CreateFrame("Frame", nil, header)
    right:SetPoint("TOPRIGHT", header, "TOPRIGHT", 0, 0)
    right:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    right:SetWidth(rightWidth)

    local roleIcon = header:CreateTexture(nil, "OVERLAY")
    roleIcon:SetSize(12, 12)
    roleIcon:SetPoint("TOPLEFT", header, "TOPLEFT", cfg.roleIconOffsetX, cfg.roleIconOffsetY)

    local nameText = header:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(fontPath, cfg.nameFontSize, "OUTLINE")
    nameText:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", cfg.nameOffsetX, cfg.nameOffsetY)
    nameText:SetPoint("RIGHT", left, "RIGHT", -2, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)

    local specText = header:CreateFontString(nil, "OVERLAY")
    specText:SetFont(fontPath, cfg.specFontSize, "OUTLINE")
    specText:SetPoint("TOPRIGHT", header, "TOPRIGHT", cfg.specOffsetX, cfg.specOffsetY)
    specText:SetJustifyH("RIGHT")
    specText:SetWordWrap(false)

    frame.RoleIcon = roleIcon
    frame.SpecText = specText
    frame.InfoHeader = header
    frame.InfoHeaderLeft = left
    frame.InfoHeaderRight = right

    frame:Tag(nameText, "[name]")

    local function HeaderUpdate(self, event, unit)
        if unit and unit ~= self.unit then
            return
        end
        addon:UpdateUnitHeader(self)
    end

    frame:RegisterEvent("GROUP_ROSTER_UPDATE", HeaderUpdate, true)
    frame:RegisterEvent("PLAYER_ROLES_ASSIGNED", HeaderUpdate, true)
    frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", HeaderUpdate, true)
    frame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", HeaderUpdate, true)
    frame:RegisterEvent("ARENA_OPPONENT_UPDATE", HeaderUpdate, true)
    frame:RegisterEvent("INSPECT_READY", HeaderUpdate, true)

    self:UpdateUnitHeader(frame)
end

function addon:CreateAuraPostCreateButton(button, fontPath, fontSize)
    -- Remove default cooldown edge texture
    button.Cooldown:SetDrawEdge(false)
    
    -- Icon cropping
    button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Remove default overlay
    button.Overlay:SetTexture(nil)
    
    -- Add black borders
    self:AddTextureBorder(button)
    
    -- Stack count
    button.Count:ClearAllPoints()
    button.Count:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 2, 0)
    button.Count:SetFont(fontPath, fontSize, 'OUTLINE')
    button.Count:SetDrawLayer('OVERLAY', 7)
    
    -- Duration countdown
    button.Cooldown.noCooldownCount = false
    button.Cooldown:SetCountdownFont(fontPath, fontSize, 'OUTLINE')
end

function addon:UpdateAllFrames()
    self.unitFrames.Player:Initialize()
end
