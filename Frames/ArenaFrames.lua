local addonName, ns = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
local oUF = ns.oUF

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.Arena = addon.unitFrames.Arena or {}

-- Generic function to build arena frames
function addon:BuildArenaFrame(unit, anchor, relativeTo, relativePoint, offsetX, offsetY, isDraggable)
	if not oUF then
		print("BuildArenaFrame: oUF not available")
		return nil
	end

	local unitKey
	for key, obj in pairs(addon.unitFrames) do
		if obj == addon.unitFrames[key] and type(obj) == "table" and not obj.frame then
			if key:match("^Arena%d") and unit == key:gsub("Arena", "arena"):lower() then
				unitKey = key
				break
			end
		end
	end

	if not unitKey then
		unitKey = unit:gsub("arena", "Arena")
		unitKey = unitKey:gsub("^%l", string.upper)
	end

	addon.unitFrames[unitKey] = addon.unitFrames[unitKey] or {}
	local frameObj = addon.unitFrames[unitKey]

	if frameObj.frame then
		return frameObj.frame
	end

	local styleName = "SAdUnitFrames_" .. unitKey
	oUF:RegisterStyle(styleName, function(frame, frameUnit)
		addon:StyleArenaFrame(frame, frameUnit, anchor, relativeTo, relativePoint, offsetX, offsetY)
	end)
	oUF:SetActiveStyle(styleName)

	local frameName = "SAdUnitFrames_" .. unitKey .. "Frame"
	frameObj.frame = oUF:Spawn(unit, frameName)

	if isDraggable then
		addon:MakeFrameDraggable(frameObj.frame)
	end

	if frameObj.frame and UnitExists(unit) then
		C_Timer.After(0.1, function()
			if frameObj.frame then
				frameObj.frame:UpdateAllElements("RefreshUnit")
			end
		end)
	end

	return frameObj.frame
end

-- Style function for arena frames
function addon:StyleArenaFrame(frame, unit, anchor, relativeTo, relativePoint, offsetX, offsetY)
	local cfg = addon.config.global

	frame:SetSize(cfg.arenaFramesWidth, cfg.arenaFramesHeight)
	frame:RegisterForClicks("AnyUp")
	frame:SetPoint(anchor, _G[relativeTo] or relativeTo, relativePoint, offsetX, offsetY)

	local Background = frame:CreateTexture(nil, "BACKGROUND")
	Background:SetAllPoints(frame)
	local bgR, bgG, bgB, bgA = addon:HexToRGB(cfg.backgroundColor)
	Background:SetColorTexture(bgR, bgG, bgB, bgA)

	addon:CreateUnitHeader(frame, cfg.arenaFramesWidth, cfg.arenaFramesHeight)

	local Health = CreateFrame("StatusBar", nil, frame)
	Health:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	Health:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	Health:SetHeight(cfg.arenaFramesHeight)
	Health:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.healthTexture)
	Health.colorClass = true
	Health.colorReaction = true

	addon:AddBorder(Health)

	frame.Health = Health

	local HealthPrediction = {}
	local damageAbsorb = CreateFrame("StatusBar", nil, Health)
	damageAbsorb:SetPoint("TOP")
	damageAbsorb:SetPoint("BOTTOM")
	damageAbsorb:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
	damageAbsorb:SetPoint("RIGHT", Health, "RIGHT")
	damageAbsorb:SetStatusBarTexture([[Interface\AddOns\SAdUnitFrames\Media\Statusbar\]] .. cfg.absorbTexture)
	damageAbsorb:SetStatusBarColor(1, 1, 1, cfg.absorbOpacity)
	HealthPrediction.damageAbsorb = damageAbsorb
	HealthPrediction.maxOverflow = cfg.maxAbsorbOverflow
	frame.HealthPrediction = HealthPrediction

end

-- Initialize functions for each arena unit
addon.unitFrames.Arena1 = addon.unitFrames.Arena1 or {}
function addon.unitFrames.Arena1:Initialize()
	local cfg = addon.config.global
	addon:BuildArenaFrame("arena1",
		cfg.arena1FrameAnchor,
		cfg.arena1FrameRelativeTo,
		cfg.arena1FrameRelativePoint,
		cfg.arena1FrameOffsetX,
		cfg.arena1FrameOffsetY,
		true)
end

addon.unitFrames.Arena2 = addon.unitFrames.Arena2 or {}
function addon.unitFrames.Arena2:Initialize()
	local cfg = addon.config.global
	addon:BuildArenaFrame("arena2",
		cfg.arena2FrameAnchor,
		cfg.arena2FrameRelativeTo,
		cfg.arena2FrameRelativePoint,
		cfg.arenaFramesOffsetX,
		cfg.arenaFramesOffsetY,
		false)
end

addon.unitFrames.Arena3 = addon.unitFrames.Arena3 or {}
function addon.unitFrames.Arena3:Initialize()
	local cfg = addon.config.global
	addon:BuildArenaFrame("arena3",
		cfg.arena3FrameAnchor,
		cfg.arena3FrameRelativeTo,
		cfg.arena3FrameRelativePoint,
		cfg.arenaFramesOffsetX,
		cfg.arenaFramesOffsetY,
		false)
end