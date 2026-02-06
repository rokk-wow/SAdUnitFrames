local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.config = {
    global = {
        -- Font settings
        font = "DorisPP",
        normalFontSize = 18,
        smallFontSize = 14,
        extraSmallFontSize = 12,
        
        -- Color settings
        backgroundColor = "000000AA",
        borderColor = "000000FF",
        targetBorderColor = "FFBB00FF",
        manaColor = "2482ff",
        rageColor = "ff0000",
        focusColor = "ff8000",
        energyColor = "ffff00",
        runicPowerColor = "00d4ff",
        lunarPowerColor = "4d85e6",
        comboPointColor = "ffaa00",
        runesColor = "00d4ff",
        
        -- Border settings
        borderWidth = 2,
        
        -- Primary frames (Player, Target)
        primaryFramesWidth = 203,
        primaryFramesHeight = 41,
        
        -- Minor frames (Pet, Focus, TargetTarget)
        minorFramesWidth = 93,
        minorFramesHeight = 29,
        
        -- Tiny frames (FocusTarget)
        tinyFramesWidth = 93,
        tinyFramesHeight = 20,
        
        -- Battleground frames (BG Blitz, etc. - not yet implemented)
        bgFramesWidth = 100,
        bgFramesHeight = 40,
        
        -- Raid frames (not yet implemented)
        raidFramesWidth = 80,
        raidFramesHeight = 35,
        
        -- Bar heights
        healthBarPercent = 0.7, -- (percent of frame height)
        powerBarPercent = 0.3, -- (percent of frame height)
        castBarHeight = 25,
        
        -- Texture settings
        healthTexture = "smooth",
        powerTexture = "otravi",
        absorbTexture = "Diagonal",
        castBarTexture = "smooth",
        
        -- Buff/Debuff settings
        buffSize = 26,
        debuffSize = 30,
        buffSpacingX = 3,
        buffSpacingY = 3,
        debuffSpacingX = 4,
        debuffSpacingY = 4,
        maxBuffs = 20,
        maxDebuffs = 20,
        
        -- Absorb settings
        absorbOpacity = 0.5,
        maxAbsorbOverflow = 1.0,
        
        -- Player frame position
        playerFrameAnchor = "TOPRIGHT",
        playerFrameRelativeTo = "MainActionBar",
        playerFrameRelativePoint = "TOPLEFT",
        playerFrameOffsetX = -10,
        playerFrameOffsetY = 0,

        -- Target frame position
        targetFrameAnchor = "TOPLEFT",
        targetFrameRelativeTo = "MainActionBar",
        targetFrameRelativePoint = "TOPRIGHT",
        targetFrameOffsetX = 10,
        targetFrameOffsetY = 0,
        
        -- TargetTarget frame position
        targettargetFrameAnchor = "TOPLEFT",
        targettargetFrameRelativeTo = "SAdUnitFrames_TargetFrame",
        targettargetFrameRelativePoint = "TOPRIGHT",
        targettargetFrameOffsetX = 10,
        targettargetFrameOffsetY = 0,
        
        -- Focus frame position
        focusFrameAnchor = "TOPRIGHT",
        focusFrameRelativeTo = "SAdUnitFrames_PlayerFrame",
        focusFrameRelativePoint = "TOPLEFT",
        focusFrameOffsetX = -10,
        focusFrameOffsetY = 0,
        
        -- FocusTarget frame position
        focustargetFrameAnchor = "TOP",
        focustargetFrameRelativeTo = "SAdUnitFrames_FocusFrame",
        focustargetFrameRelativePoint = "BOTTOM",
        focustargetFrameOffsetX = 0,
        focustargetFrameOffsetY = 1,
        
        -- Pet frame position
        petFrameAnchor = "TOPRIGHT",
        petFrameRelativeTo = "SAdUnitFrames_PlayerFrame",
        petFrameRelativePoint = "TOPLEFT",
        petFrameOffsetX = -10,
        petFrameOffsetY = -57,
        
        -- Arena frames
        arenaFramesWidth = 170,
        arenaFramesHeight = 50,
        arenaHealerManaHeight = 10,
        arenaFramesOffsetX = 0,
        arenaFramesOffsetY = -17,

        -- Arena1 frame position (draggable)
        arena1FrameAnchor = "CENTER",
        arena1FrameRelativeTo = "UIParent",
        arena1FrameRelativePoint = "CENTER",
        arena1FrameOffsetX = -250,
        arena1FrameOffsetY = 0,
        
        -- Arena2 frame position
        arena2FrameAnchor = "TOP",
        arena2FrameRelativeTo = "SAdUnitFrames_Arena1Frame",
        arena2FrameRelativePoint = "BOTTOM",
        
        -- Arena3 frame position
        arena3FrameAnchor = "TOP",
        arena3FrameRelativeTo = "SAdUnitFrames_Arena2Frame",
        arena3FrameRelativePoint = "BOTTOM",
        
        -- Party frames
        partyFramesWidth = 170,
        partyFramesHeight = 60,
        partyHealerManaHeight = 10,
        partyFramesOffsetX = 0,
        partyFramesOffsetY = 0,
        partyRightPanelSpacing = 2,

        -- Party castbar
        partyCastbarColor = "FFBB00",

        -- Player party frame position (draggable, first in party stack)
        playerPartyFrameAnchor = "TOPRIGHT",
        playerPartyFrameRelativeTo = "UIParent",
        playerPartyFrameRelativePoint = "CENTER",
        playerPartyFrameOffsetX = -550,
        playerPartyFrameOffsetY = 150,
        
        -- Party1 frame position (second in party stack)
        party1FrameAnchor = "TOP",
        party1FrameRelativeTo = "SAdUnitFrames_PlayerPartyFrame",
        party1FrameRelativePoint = "BOTTOM",
        
        -- Party2 frame position (fourth in party stack)
        party2FrameAnchor = "TOP",
        party2FrameRelativeTo = "SAdUnitFrames_Party1Frame",
        party2FrameRelativePoint = "BOTTOM",
        
        -- Party3 frame position
        party3FrameAnchor = "TOP",
        party3FrameRelativeTo = "SAdUnitFrames_Party2Frame",
        party3FrameRelativePoint = "BOTTOM",
        
        -- Party4 frame position
        party4FrameAnchor = "TOP",
        party4FrameRelativeTo = "SAdUnitFrames_Party3Frame",
        party4FrameRelativePoint = "BOTTOM",
        
        -- Combat/Resting indicator position
        combatRestingAnchor = "BOTTOM",
        combatRestingRelativeTo = "UIParent",
        combatRestingRelativePoint = "BOTTOM",
        combatRestingOffsetX = 0,
        combatRestingOffsetY = 176,

        -- Spec abbreviations
        specAbbrevById = {
            -- Warrior
            [71] = "ARMS",
            [72] = "FURY",
            [73] = "PROT",
            -- Paladin
            [65] = "HOLY",
            [66] = "PROT",
            [70] = "RET",
            -- Hunter
            [253] = "BM",
            [254] = "MM",
            [255] = "SV",
            -- Rogue
            [259] = "ASSA",
            [260] = "OUTL",
            [261] = "SUB",
            -- Priest
            [256] = "DISC",
            [257] = "HOLY",
            [258] = "SPRIEST",
            -- Death Knight
            [250] = "BDK",
            [251] = "FDK",
            [252] = "UDK",
            -- Shaman
            [262] = "ELE",
            [263] = "ENH",
            [264] = "RESTO",
            -- Mage
            [62] = "ARC",
            [63] = "FIRE",
            [64] = "FROST",
            -- Warlock
            [265] = "AFF",
            [266] = "DEMO",
            [267] = "DESTRO",
            -- Monk
            [268] = "BREW",
            [269] = "WW",
            [270] = "MW",
            -- Druid
            [102] = "BAL",
            [103] = "FERAL",
            [104] = "GUARD",
            [105] = "RESTO",
            -- Demon Hunter
            [577] = "HAVOC",
            [581] = "VENG",
            -- Evoker
            [1467] = "DEV",
            [1468] = "PRES",
            [1473] = "AUG",
        },

        -- Role icon atlases
        roleIconAtlases = {
            TANK = "RaidFrame-Icon-MainTank",
            HEALER = "icons_64x64_heal",
            DAMAGER = "RaidFrame-Icon-MainAssist",
        },

        -- Header module offsets and font sizes
        roleIconOffsetX = 3,
        roleIconOffsetY = -2,

        nameOffsetX = 1,
        nameOffsetY = -2,
        nameFontSize = 12,

        specOffsetX = -4,
        specOffsetY = -4,
        specFontSize = 12,
    },

    ---------------------------------------------------------------------------
    -- Module settings
    ---------------------------------------------------------------------------
    modules = {
        bigCC = {
            enabled = true,
            showCooldownNumbers = true,
            showGlow = true,
            glowColor = { r = 1, g = 0, b = 0, a = 1 },   -- red
            placeholderIcon = "spell_nature_polymorph",
            placeholderOpacity = 0.3,
        },

        bigBuffs = {
            enabled = true,
            showCooldownNumbers = false,
            showGlow = true,
            glowColor = { r = 0.2, g = 0.6, b = 1, a = 1 }, -- blue
            placeholderIcon = "inv_sword_04",
            placeholderOpacity = 0.3,
        },

        bigDefensives = {
            enabled = true,
            showCooldownNumbers = true,
            showGlow = true,
            glowColor = { r = 0.76, g = 0.6, b = 0.36, a = 1 }, -- tan/gold
            placeholderIcon = "inv_shield_04",
            placeholderOpacity = 0.3,
        },

        castbar = {
            enabled = true,
            showCastName = true,
            showCastIcon = false,
        },

        dispelBorder = {
            enabled = false,
        },

        enemyDebuffs = {
            enabled = true,
            showCooldownNumbers = true,
        },

        playerBuffs = {
            enabled = true,
            showCooldownNumbers = false,
        },

        trinket = {
            enabled = true,
        },
    },
}