local ZkyTargetBar = LibStub("AceAddon-3.0"):GetAddon("ZkyTargetBar")

local defaults = {
    profile = {
        position = nil,
        scale = 1.5,
        layout = 3,
        textPosition = { x = 0, y = -2 },
        hideText = false,
        showInRaid = true,
        showInParty = false,
        showSolo = false,
        locked = false,
        playErrorSound = true,
    }
}

local options = nil
local function getOptions()
    if options then return options end

    options = {
        type = "group",
        name = "Return Target Icon Bar",
        args = {
            general = {
                type = "group",
                name = "",
                inline = true,
                args = {
                    descriptionImage = {
                        name = "",
                        type = "description",
                        image = "Interface\\AddOns\\ZkyTargetBar\\media\\return",
                        imageWidth = 64,
                        imageHeight = 64,
                        width = "half",
                        order = 1
                    },
                    descriptiontext = {
                        name = "Return Target Icon Bar by Irpa\nDiscord: https://discord.gg/SZYAKFy\nGithub: https://github.com/zorkqz/ZkyTargetBar\n",
                        type = "description",
                        width = "full",
                        order = 1.1
                    },
                    headerGlobalSettings = {
                        name = "Settings",
                        type = "header",
                        width = "double",
                        order = 2
                    },
                    showInRaid = {
                        name = "Show in raids",
                        desc = "",
                        type = "toggle",
                        order = 2.1,
                        get = function(self)
                            return ZkyTargetBar.db.profile.showInRaid
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.showInRaid = value
                            ZkyTargetBar:CheckHide()
                        end
                    },
                    showInParty = {
                        name = "Show in party",
                        desc = "",
                        type = "toggle",
                        order = 2.2,
                        get = function(self)
                            return ZkyTargetBar.db.profile.showInParty
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.showInParty = value
                            ZkyTargetBar:CheckHide()
                        end
                    },
                    showSolo = {
                        name = "Show when solo",
                        desc = "Doesn't make much sense.",
                        type = "toggle",
                        order = 2.3,
                        get = function(self)
                            return ZkyTargetBar.db.profile.showSolo
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.showSolo = value
                            ZkyTargetBar:CheckHide()
                        end
                    },
                    locked = {
                        name = "Lock position",
                        desc = "Lock icons in place.",
                        type = "toggle",
                        order = 2.4,
                        get = function(self)
                            return ZkyTargetBar.db.profile.locked
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.locked = value
                        end
                    },
                    playErrorSound = {
                        name = "Play error sound",
                        desc = "Play an error sound if no target could be found.",
                        type = "toggle",
                        order = 2.4,
                        get = function(self)
                            return ZkyTargetBar.db.profile.playErrorSound
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.playErrorSound = value
                        end
                    },
                    hideText = {
                        name = "Hide Text",
                        desc = "",
                        type = "toggle",
                        order = 2.5,
                        get = function(self)
                            return ZkyTargetBar.db.profile.hideText
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.hideText = value
                            ZkyTargetBar:UpdateTextPosition()
                        end
                    },
                    headerLayout = {
                        name = "Layout",
                        type = "header",
                        width = "double",
                        order = 3
                    },
                    scale = {
                        name = "Scale",
                        desc = "",
                        type = "range",
                        order = 3.1,
                        min = 0.1,
                        max = 5,
                        softMin = 0.5,
                        softMax = 2,
                        step = 0.1,
                        bigStep = 0.1,
                        get = function(self)
                            return ZkyTargetBar.db.profile.scale
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.scale = value
                            ZkyTargetBar:DoLayout()
                        end
                    },
                    layout = {
                        name = "Layout",
                        desc = "",
                        type = "range",
                        order = 3.2,
                        min = 0,
                        max = 3,
                        softMin = 0,
                        softMax = 3,
                        step = 1,
                        bigStep = 1,
                        get = function(self)
                            return ZkyTargetBar.db.profile.layout
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.layout = value
                            ZkyTargetBar:DoLayout()
                        end
                    },
                    emptyDescription1 = {
                        name = "",
                        type = "description",
                        order = 3.3
                    },
                    textPositionX = {
                        name = "Text X",
                        desc = "",
                        type = "range",
                        order = 3.4,
                        min = -100,
                        max = 100,
                        softMin = -100,
                        softMax = 100,
                        step = 0.1,
                        bigStep = 1,
                        get = function(self)
                            return ZkyTargetBar.db.profile.textPosition.x
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.textPosition.x = value
                            ZkyTargetBar:UpdateTextPosition()
                        end
                    },
                    textPositionY = {
                        name = "Text Y",
                        desc = "",
                        type = "range",
                        order = 3.5,
                        min = -100,
                        max = 100,
                        softMin = -100,
                        softMax = 100,
                        step = 0.1,
                        bigStep = 1,
                        get = function(self)
                            return ZkyTargetBar.db.profile.textPosition.y
                        end,
                        set = function(self, value)
                            ZkyTargetBar.db.profile.textPosition.y = value
                            ZkyTargetBar:UpdateTextPosition()
                        end
                    },
                    
                }
            }
        }
    }

    return options
end

function ZkyTargetBar:ChatCommand(input)
    InterfaceOptionsFrame_OpenToCategory(ZkyTargetBar.Options.Menus.Profiles)
    InterfaceOptionsFrame_OpenToCategory(ZkyTargetBar.Options.Menus.Profiles)
    InterfaceOptionsFrame_OpenToCategory(ZkyTargetBar.Options.Menus.ZkyTargetBar)
end


function ZkyTargetBar:SetupOptions()

    ZkyTargetBar.db = LibStub("AceDB-3.0"):New("ZkyTargetBarDB", defaults, true)

    ZkyTargetBar.Options = {}
    ZkyTargetBar.Options.Menus = {}
    ZkyTargetBar.Options.Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(ZkyTargetBar.db)
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable("ZkyTargetBar", getOptions)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ZkyTargetBar Profiles", ZkyTargetBar.Options.Profiles)
    
    ZkyTargetBar.Options.Menus.ZkyTargetBar
        = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ZkyTargetBar", "ZkyTargetBar", nil)
    ZkyTargetBar.Options.Menus.Profiles
        = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ZkyTargetBar Profiles", "Profiles", "ZkyTargetBar")
    
    ZkyTargetBar:RegisterChatCommand("ZkyTargetBar", "ChatCommand")
    ZkyTargetBar:RegisterChatCommand("ztb", "ChatCommand")
    
end


-- Binding Variables
BINDING_HEADER_RETURNTARGETBAR = "Return Target Icon Bar" 
_G["BINDING_NAME_CLICK ZkyTargetBarButton8:LeftButton"] = "Target Skull";
_G["BINDING_NAME_CLICK ZkyTargetBarButton7:LeftButton"] = "Target Cross";
_G["BINDING_NAME_CLICK ZkyTargetBarButton6:LeftButton"] = "Target Square";
_G["BINDING_NAME_CLICK ZkyTargetBarButton5:LeftButton"] = "Target Moon";
_G["BINDING_NAME_CLICK ZkyTargetBarButton4:LeftButton"] = "Target Triangle";
_G["BINDING_NAME_CLICK ZkyTargetBarButton3:LeftButton"] = "Target Diamond";
_G["BINDING_NAME_CLICK ZkyTargetBarButton2:LeftButton"] = "Target Circle";
_G["BINDING_NAME_CLICK ZkyTargetBarButton1:LeftButton"] = "Target Star";
