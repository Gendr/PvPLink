--[[	PvPLink	]]--

local pairs = pairs
local rawset = rawset
local select = select
local setmetatable = setmetatable
local string = string
local table = table
local tostring = tostring

----------------------

local AddMessage = AddMessage
local CreateFrame = CreateFrame
local DEFUALT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local GAME_LOCALE = GAME_LOCALE
local GetAddOnMetadata = GetAddOnMetadata
local GetParent = GetParent
local GetLocale = GetLocale
local GetRealmName = GetRealmName
local GetScreenHeight = GetScreenHeight
local UIParent = UIParent

----------------------

local addonName, ns = ...
local addon_prefix = "|cffFFC04D"..addonName..":|r"
local addon_version = GetAddOnMetadata(addonName, "Version")

local CONST_REALM_LIST = ns.realmList
local MediaPath = "Interface\\AddOns\\PvPLink\\img\\"

----------------------

local function out(...)
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", addon_prefix, ...))
end

----------------------

local locale = GAME_LOCALE or GetLocale()

local L = setmetatable({}, {
	__index = function(t, k)
		if (locale ~= "enUS") then out(string.format("|cffFF0000No translation available in your language!|r (%s)", locale)) end
		local v = tostring(k)
		rawset(t, k, v)

		return v
	end
})

if (locale == "enUS") then
	L["PvP Link"] = "PvP Link"
	L["World of Warcraft Link:"] = "World of Warcraft Link:"
	L["Check-PvP Link:"] = "Check-PvP Link:"
	L["Okay"] = "Okay"
	L["PvP Link v"] = "PvP Link v"
	L["Check-PvP Manual Copy:"] = "Check-PvP Manual Copy:"
end

----------------------

local regionIndex = {
	["enUS"] = "us",
	["esMX"] = "us",
	["ptBR"] = "us",
	["enGB"] = "eu",
	["frFR"] = "eu",
	["deDE"] = "eu",
	["itIT"] = "eu",
	["esES"] = "eu",
	["ruRU"] = "eu",
}

local realmFix = {
	["Blade'sEdge"] = "Blade's Edge",
	["Death'sDoor"] = "Death's Door",
	["Doom'sVigil"] = "Doom's Vigil",
	["Explorer'sLeague"] = "Explorer's League",
	["Light'sHope"] = "Light's Hope",
	["Lightning'sBlade"] = "Lightning's Blade",
	["TheMaster'sGlaive"] = "TheMaster's Glaive",
	["Twilight'sHammer"] = "Twilight's Hammer",
	["Tyr'sHand"] = "Tyr's Hand",
}

local siteIndex = {
	["enUS"] = "https://worldofwarcraft.com/en-us/character/us/",
	["esMX"] = "https://worldofwarcraft.com/es-mx/character/us/",
	["ptBR"] = "https://worldofwarcraft.com/pt-br/character/us/",
	["enGB"] = "https://worldofwarcraft.com/en-gb/character/eu/",
	["frFR"] = "https://worldofwarcraft.com/fr-fr/character/eu/",
	["deDE"] = "https://worldofwarcraft.com/de-de/character/eu/",
	["itIT"] = "https://worldofwarcraft.com/it-it/character/eu/",
	["esES"] = "https://worldofwarcraft.com/es-es/character/eu/",
	["ruRU"] = "https://worldofwarcraft.com/ru-ru/character/eu/",
	["koKR"] = "https://worldofwarcraft.com/ko-kr/character/kr/",
	["zhTW"] = "https://worldofwarcraft.com/zh-tw/character/tw/",
}

local site = siteIndex[locale]
local site2 = "https://check-pvp.com/database/character/?r="

----------------------

local viewer = CreateFrame("Frame", "PvPLinkFrame", UIParent, "UIPanelDialogTemplate")
local editbox = CreateFrame("EditBox", "$parentEditBox", viewer, "InputBoxTemplate")
local editbox2 = CreateFrame("EditBox", "$parentEditBox2", viewer, "InputBoxTemplate")
local editboxText = viewer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
local editbox2Text = viewer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
local button = CreateFrame("Button","$parentButton", viewer, "UIPanelButtonTemplate")
local versionText = viewer:CreateFontString(nil, "ARTWORK", "GameFontNormal")

local help = CreateFrame("Frame", "PvPLinkHelpFrame", viewer)
local tip = CreateFrame("Frame", "$parentTipFrame", help)
local tipbox = CreateFrame("EditBox", "$parentTipBox", tip, "InputBoxTemplate")
local tipboxText = tipbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")

viewer.editbox = editbox
viewer.editbox2 = editbox2
viewer.button = button
viewer.help = help
viewer.tip = tip
viewer.tipbox = tipbox

viewer:Hide()
viewer:SetSize(475, 175)
viewer:SetToplevel(true)
viewer:SetPoint("CENTER", UIParent, "TOP", 0, -1 * GetScreenHeight() / 4)
viewer.Title:SetText(L["PvP Link"])
viewer:EnableKeyboard(false)
viewer:SetMovable(true)
viewer:EnableMouse(true)
viewer:RegisterForDrag("LeftButton")
viewer:SetScript("OnShow", function() help:Show() end)
viewer:SetScript("OnHide", function(self) tip:Hide(); help:Hide(); self:Hide() end)
viewer:SetScript("OnDragStart", function(self) self:StartMoving() end)
viewer:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

editbox:SetPoint("TOPLEFT", viewer, "LEFT", 30, 50)
editbox:SetPoint("BOTTOMRIGHT", viewer, "RIGHT", -30, -8)
editbox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
editbox:SetScript("OnEscapePressed", function(self) self:GetParent():Hide() end)
editbox:SetAutoFocus(false)
editboxText:SetText(L["World of Warcraft Link:"])
editboxText:SetPoint("TOPLEFT", editbox, "LEFT", 0, 25)

editbox2:SetPoint("TOPLEFT", editbox, "LEFT", 0, -75)
editbox2:SetPoint("BOTTOMRIGHT", editbox, "RIGHT", 0, -8)
editbox2:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
editbox2:SetScript("OnEscapePressed", function(self) self:GetParent():Hide() end)
editbox2:SetAutoFocus(false)
editbox2Text:SetText(L["Check-PvP Link:"])
editbox2Text:SetPoint("TOPLEFT", editbox2, "LEFT", 0, 25)

button:SetPoint("BOTTOM", viewer, "BOTTOM", 0, 10)
button:SetSize(100, 25)
button:SetText(L["Okay"])
button:SetScript("OnClick", function() viewer:Hide() end)

versionText:SetText(string.format("|cffFFC04D%s%.1f|r", L["PvP Link v"], addon_version))
versionText:SetPoint("BOTTOMRIGHT", viewer, "BOTTOMRIGHT", -10, 10)

help:SetBackdrop({
	bgFile = MediaPath.."mark.tga",
	edgeFile = nil,
	tile = false, tileSize = 16, edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
help:Hide()
help:SetSize(32, 32)
help:SetPoint("BOTTOMRIGHT", viewer, "BOTTOMRIGHT", -2, 50)
help:SetScript("OnEnter", function() tip:Show() end)

tip:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = false, tileSize = 16, edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
tip:Hide()
tip:SetSize(250, 75)
tip:SetToplevel(true)
tip:SetPoint("CENTER", help, "CENTER")

tipbox:SetPoint("TOPLEFT", tip, "LEFT", 30, 15)
tipbox:SetPoint("BOTTOMRIGHT", tip, "RIGHT", -30, -15)
tipbox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
tipbox:SetScript("OnEditFocusLost", function(self) self:GetParent():Hide() end)
tipbox:SetScript("OnEscapePressed", function(self) self:GetParent():Hide() end)
tipbox:SetAutoFocus(true)

tipboxText:SetText(L["Check-PvP Manual Copy:"])
tipboxText:SetPoint("TOPLEFT", tipbox, "LEFT", 15, 25)

----------------------

UnitPopupButtons["PVPLINK"] = {text = "PvP Link"}
table.insert(UnitPopupMenus["ARENAENEMY"], #UnitPopupMenus["ARENAENEMY"], "PVPLINK")
table.insert(UnitPopupMenus["BN_FRIEND"], #UnitPopupMenus["BN_FRIEND"], "PVPLINK")
table.insert(UnitPopupMenus["CHAT_ROSTER"], #UnitPopupMenus["CHAT_ROSTER"], "PVPLINK")
table.insert(UnitPopupMenus["COMMUNITIES_GUILD_MEMBER"], #UnitPopupMenus["COMMUNITIES_GUILD_MEMBER"], "PVPLINK")
table.insert(UnitPopupMenus["COMMUNITIES_WOW_MEMBER"], #UnitPopupMenus["COMMUNITIES_WOW_MEMBER"], "PVPLINK")
table.insert(UnitPopupMenus["FOCUS"], #UnitPopupMenus["FOCUS"], "PVPLINK")
table.insert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"], "PVPLINK")
table.insert(UnitPopupMenus["GUILD"], #UnitPopupMenus["GUILD"], "PVPLINK")
table.insert(UnitPopupMenus["GUILD_OFFLINE"], #UnitPopupMenus["GUILD_OFFLINE"], "PVPLINK")
table.insert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"], "PVPLINK")
table.insert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"], "PVPLINK")
table.insert(UnitPopupMenus["RAID"], #UnitPopupMenus["RAID"], "PVPLINK")
table.insert(UnitPopupMenus["RAID_PLAYER"], #UnitPopupMenus["RAID_PLAYER"], "PVPLINK")
table.insert(UnitPopupMenus["SELF"], #UnitPopupMenus["SELF"] - 2, "PVPLINK")
table.insert(UnitPopupMenus["TARGET"], #UnitPopupMenus["TARGET"], "PVPLINK")
table.insert(UnitPopupMenus["WORLD_STATE_SCORE"], #UnitPopupMenus["WORLD_STATE_SCORE"], "PVPLINK")

function PvPLink_Show(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
    if (dropDownFrame and level) then
		local name, server, server2, active, custom, orig, orig_server2, temp, orig_temp
		if (dropDownFrame.which == "BN_FRIEND") then
			if (dropDownFrame.bnetIDAccount) then
				local _,_,_,_,_,gameaccount,game = BNGetFriendInfoByID(dropDownFrame.bnetIDAccount)
				if (game == BNET_CLIENT_WOW) then
					name = select(2, BNGetGameAccountInfo(gameaccount))
					server = select(4, BNGetGameAccountInfo(gameaccount))
					server2 = select(4, BNGetGameAccountInfo(gameaccount))
					active = true
				else
					active = false
				end
			end
		else
			if (dropDownFrame.name) then
				name = dropDownFrame.name
				server = dropDownFrame.server or GetRealmName()
				server2 = dropDownFrame.server or GetRealmName()
				active = true
			else
				active = false
                if (menuList) then
                    if (menuList[2].arg1) then
                        custom = true
                    end
                end
			end
		end
		if (server) then
			server = server:gsub("%s", "")
		end
		if (server2) then
			server2 = server2:gsub("%s", "")
			if (server2:find("'")) then
				orig_server2 = server2
				orig = true
			end
			for k,v in pairs(realmFix) do
				if (server2:find(k)) then
					orig_temp = v
					temp = true
				end
			end
		end
		local realm = CONST_REALM_LIST[server]
		local realm2 = CONST_REALM_LIST[server2]
		local buttonPrefix = "DropDownList"..level.."Button"
		local i=2
		while (1) do
			local button = _G[buttonPrefix..i]
			if (not button) then break end
			if (button:GetText() == UnitPopupButtons["PVPLINK"].text) then
				if (active == true) then
					button.func = function()
						name = name:lower()
						realm2 = realm2:gsub("(%u%l+)(%d+)", "%1 %2"):gsub("-", " ")
						if (orig == true) then
							realm2 = orig_server2
						end
						if (temp == true) then
							realm2 = orig_temp
						end
						realm2 = realm2:lower()

						editbox:SetText(site..realm.."/"..name)	
						editbox2:SetText(site2..regionIndex[locale].."&q="..name.."-"..realm2)
						tipbox:SetText(name.."-"..realm2)
						viewer:Show()
					end
				else
					button.func = function()
						if (custom == true) then
							name, server = ("-"):split(menuList[2].arg1)
							if (not server) or (server == nil) then
								server = GetRealmName()
							end
							name = name:lower()
							server2 = server
                            if (server) then 
                                server = server:gsub("%s", "")
							end
							if (server2) then
								server2 = server2:gsub("%s", "")
								if (server2:find("'")) then
									orig_server2 = server2
									orig = true
								end
								for k,v in pairs(realmFix) do
									if (server2:find(k)) then
										orig_temp = v
										temp = true
									end
								end
							end
							local realm = CONST_REALM_LIST[server]
							local realm2 = CONST_REALM_LIST[server2]
							realm2 = realm2:gsub("(%u%l+)(%d+)", "%1 %2"):gsub("-", " ")
							if (orig == true) then
								realm2 = orig_server2
							end
							if (temp == true) then
								realm2 = orig_temp
							end
							realm2 = realm2:lower()

							editbox:SetText(site..realm.."/"..name)
							editbox2:SetText(site2..regionIndex[locale].."&q="..name.."-"..realm2)
							tipbox:SetText(name.."-"..realm2)
							viewer:Show()
						else
							out("|cffFF0000Player not logged into WoW|r")
						end
					end
				end
				break
			end
			i=i+1
		end
	end
end

hooksecurefunc("ToggleDropDownMenu", PvPLink_Show)
UnitPopupButtons["PVPLINK"].dist = nil

local LFG_LIST_SEARCH_ENTRY_MENU = {
    {
        text = nil,
        isTitle = true,
        notCheckable = true,
    },
    {
        text = WHISPER_LEADER,
        func = function(_, name) ChatFrame_SendTell(name) end,
        notCheckable = true,
        arg1 = nil,
        disabled = nil,
        tooltipWhileDisabled = 1,
        tooltipOnButton = 1,
        tooltipTitle = nil,
        tooltipText = nil,
    },
    {
        text = "PvP Link",
        notCheckable = true,
        arg1 = nil,
        disabled = nil,
    },
    {
        text = LFG_LIST_REPORT_GROUP_FOR,
        hasArrow = true,
        notCheckable = true,
        menuList = {
            {
                text = LFG_LIST_BAD_NAME,
                func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistname") end,
                arg1 = nil,
                notCheckable = true,
            },
            {
                text = LFG_LIST_BAD_DESCRIPTION,
                func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistcomment") end,
                arg1 = nil,
                notCheckable = true,
                disabled = nil,
            },
            {
                text = LFG_LIST_BAD_VOICE_CHAT_COMMENT,
                func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistvoicechat") end,
                arg1 = nil,
                notCheckable = true,
                disabled = nil,
            },
            {
                text = LFG_LIST_BAD_LEADER_NAME,
                func = function(_, id) C_LFGList.ReportSearchResult(id, "badplayername") end,
                arg1 = nil,
                notCheckable = true,
                disabled = nil,
            },
        },
    },
    {
        text = CANCEL,
        notCheckable = true,
    },
}
 
function LFGListUtil_GetSearchEntryMenu(resultID)

    local results = C_LFGList.GetSearchResultInfo(resultID)
    if (not results) then
        return
    end
    local activityID = results.activityID
    local leaderName = results.leaderName
    
    local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID)
    LFG_LIST_SEARCH_ENTRY_MENU[1].text = name
    LFG_LIST_SEARCH_ENTRY_MENU[2].arg1 = leaderName
    LFG_LIST_SEARCH_ENTRY_MENU[2].disabled = not leaderName
    LFG_LIST_SEARCH_ENTRY_MENU[3].arg1 = leaderName
    LFG_LIST_SEARCH_ENTRY_MENU[3].disabled = not leaderName
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[1].arg1 = resultID
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[2].arg1 = resultID
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[2].disabled = (comment == "")
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[3].arg1 = resultID
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[3].disabled = (voiceChat == "")
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[4].arg1 = resultID
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[4].disabled = not leaderName

    return LFG_LIST_SEARCH_ENTRY_MENU
end

local LFG_LIST_APPLICANT_MEMBER_MENU = {
    {
        text = nil,
        isTitle = true,
        notCheckable = true,
    },
    {
        text = WHISPER,
        func = function(_, name) ChatFrame_SendTell(name) end,
        notCheckable = true,
        arg1 = nil,
        disabled = nil,
    },
    {
        text = "PvP Link",
        notCheckable = true,
        arg1 = nil,
        disabled = nil,
    },
    {
        text = LFG_LIST_REPORT_FOR,
        hasArrow = true,
        notCheckable = true,
        menuList = {
            {
                text = LFG_LIST_BAD_PLAYER_NAME,
                notCheckable = true,
                func = function(_, id, memberIdx) C_LFGList.ReportApplicant(id, "badplayername", memberIdx) end,
                arg1 = nil,
                arg2 = nil,
            },
            {
                text = LFG_LIST_BAD_DESCRIPTION,
                notCheckable = true,
                func = function(_, id) C_LFGList.ReportApplicant(id, "lfglistappcomment") end,
                arg1 = nil,
            },
        },
    },
    {
        text = IGNORE_PLAYER,
        notCheckable = true,
        func = function(_, name, applicantID) AddIgnore(name) C_LFGList.DeclineApplicant(applicantID) end,
        arg1 = nil,
        arg2 = nil,
        disabled = nil,
    },
    {
        text = CANCEL,
        notCheckable = true,
    },
}
 
function LFGListUtil_GetApplicantMemberMenu(applicantID, memberIdx)
    local name, class, localizedClass, level, itemLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
    
    LFG_LIST_APPLICANT_MEMBER_MENU[1].text = name or " "
    LFG_LIST_APPLICANT_MEMBER_MENU[2].arg1 = name
    LFG_LIST_APPLICANT_MEMBER_MENU[2].disabled = not name
    LFG_LIST_APPLICANT_MEMBER_MENU[3].arg1 = name
    LFG_LIST_APPLICANT_MEMBER_MENU[3].disabled = not name
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[1].arg1 = applicantID
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[1].arg2 = memberIdx
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[2].arg1 = applicantID
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[2].disabled = (comment == "")
    LFG_LIST_APPLICANT_MEMBER_MENU[5].arg1 = name
    LFG_LIST_APPLICANT_MEMBER_MENU[5].arg2 = applicantID
    LFG_LIST_APPLICANT_MEMBER_MENU[5].disabled = not name

    return LFG_LIST_APPLICANT_MEMBER_MENU
end
