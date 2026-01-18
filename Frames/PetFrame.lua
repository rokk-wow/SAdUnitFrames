local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.unitFrames = addon.unitFrames or {}
addon.unitFrames.pet = addon.unitFrames.pet or {}

function addon.unitFrames.pet:removePortrait()
    addon:Debug("Removing pet portrait")
    
    local portrait = _G["PetPortrait"]
    local healthBarMask = PetFrame.HealthBarMask
    local portraitMask = PetFrame.PortraitMask
    local frameTexture = PetFrame.FrameTexture
    local petFrameTexture = _G["PetFrameTexture"]
    local manaBar = _G["PetFrameManaBar"]
    
    addon:hideFrame(portrait)
    addon:hideFrame(healthBarMask)
    addon:hideFrame(portraitMask)
    addon:hideFrame(frameTexture)
    addon:hideFrame(petFrameTexture)
    addon:hideFrame(manaBar)
end

function addon.unitFrames.pet:setClassColor()
    addon:Debug("Setting pet frame class color")
    
    local healthBar = PetFrame.HealthBar
    
    if not healthBar then return end
    
    -- Set up color hook
    if not healthBar.sadunitframes_colorHooked then
        healthBar.sadunitframes_colorHooked = true
        hooksecurefunc(healthBar, "SetStatusBarColor", function(self, r, g, b)
            if self.sadunitframes_settingColor then return end
            local cr, cg, cb = addon:getUnitColor("Pet")
            if math.abs(r - cr) > 0.01 or math.abs(g - cg) > 0.01 or math.abs(b - cb) > 0.01 then
                self.sadunitframes_settingColor = true
                self:SetStatusBarColor(cr, cg, cb)
                self.sadunitframes_settingColor = false
            end
        end)
    end
    
    -- Apply texture
    local texturePath = addon:getTexturePath(addon.settings.frameStyle.statusbarTexture)
    healthBar:SetStatusBarTexture(texturePath)
    
    -- Apply color immediately after texture
    local r, g, b = addon:getUnitColor("Pet")
    healthBar.sadunitframes_settingColor = true
    healthBar:SetStatusBarColor(r, g, b)
    healthBar.sadunitframes_settingColor = false
end

function addon.unitFrames.pet:addBorder()
    addon:Debug("Adding pet frame border")
    
    local healthBar = _G["PetFrameHealthBar"]
    
    if healthBar then
        addon:addBorder(healthBar)
    end
end

function addon.unitFrames.pet:addBackground()
    addon:Debug("Adding pet frame background")
    
    local healthBar = _G["PetFrameHealthBar"]
    
    if healthBar then
        addon:addBackground(healthBar)
    end
end

function addon:adjustPetHealthBar(healthBar, healthBarHeight)
    self:CombatSafe(function()
        healthBar:SetHeight(healthBarHeight)
    end)
end

function addon.unitFrames.pet:adjustHealthBar()
    addon:Debug("Adjusting pet health bar height")
    
    -- Health bar height setting
    local healthBarHeight = 16
    
    local healthBar = _G["PetFrameHealthBar"]
    
    if healthBar then
        addon:adjustPetHealthBar(healthBar, healthBarHeight)
        addon:Debug("Pet health bar height set to: " .. tostring(healthBarHeight))
    end
end

function addon:adjustPetText(nameText, healthBar, textOffsetX, textOffsetY, textScale)
    self:CombatSafe(function()
        nameText:SetScale(textScale)
        nameText:SetJustifyH("LEFT")
        nameText:ClearAllPoints()
        nameText:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", textOffsetX, textOffsetY)
    end)
end

function addon.unitFrames.pet:adjustText()
    addon:Debug("Adjusting pet frame text")
    
    -- Text positioning settings
    local textOffsetX = 0
    local textOffsetY = 0
    local textScale = 0.8
    
    local healthBar = PetFrame.HealthBar
    local nameText = _G["PetName"]
    
    if not nameText or not healthBar then return end
    
    addon:adjustPetText(nameText, healthBar, textOffsetX, textOffsetY, textScale)
end

-- function addon.unitFrames.pet:adjustManaBar()
--     addon:debug("Adjusting pet mana bar position")
    
--     local healthBar = PetFrame.HealthBar
--     local manaBar = _G["PetFrameManaBar"]
--     local offsetY = addon.vars.manaBarOffsetY
    
--     if not manaBar then return end
    
--     manaBar:ClearAllPoints()
--     manaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, offsetY)
--     manaBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, offsetY)
--     manaBar:SetHeight(12)
-- end

-- function addon.unitFrames.pet:hideManaText()
--     addon:debug("Hiding pet mana text")
    
--     local manaBar = _G["PetFrameManaBar"]
    
--     if not manaBar then return end
    
--     local regions = {manaBar:GetRegions()}
--     for _, region in pairs(regions) do
--         if region:GetObjectType() == "FontString" then
--             addon:hideFrame(region)
--         end
--     end
-- end

-- function addon.unitFrames.pet:updateTexture()
--     addon:debug("Updating pet frame texture")
-- end
