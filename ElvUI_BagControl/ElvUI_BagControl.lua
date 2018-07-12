local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local BC = E:NewModule("BagControl", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local B = E:GetModule("Bags")
local EP = LibStub("LibElvUIPlugin-1.0")

--Cache global variables
--Lua functions
local pairs = pairs
local format = string.format
--WoW API / Variables
local AUCTIONS, BUG_CATEGORY12, MAIL_LABEL, MERCHANT, TRADE = AUCTIONS, BUG_CATEGORY12, MAIL_LABEL, MERCHANT, TRADE
local CreateFrame = CreateFrame

P["BagControl"] = {
	["Enabled"] = true,
	["Open"] = {
		["Mail"] = true,
		["Vendor"] = true,
		["Bank"] = true,
		["AH"] = true,
		["TS"] = true,
		["Trade"] = true
	},
	["Close"] = {
		["Mail"] = true,
		["Vendor"] = true,
		["Bank"] = true,
		["AH"] = true,
		["TS"] = true,
		["Trade"] = true
	}
}

local function ColorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName)
end

function BC:InsertOptions()
	E.Options.args.BagControl = {
		order = 53,
		type = "group",
		childGroups = "tab",
		name = ColorizeSettingName(L["Bag Control"]),
		get = function(info) return E.db.BagControl[ info[getn(info)] ] end,
		set = function(info, value) E.db.BagControl[ info[getn(info)] ] = value; end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Bag Control"]
			},
			Enabled = {
				order = 2,
				type = "toggle",
				name = L["Enable"],
				set = function(info, value) E.db.BagControl[ info[getn(info)] ] = value; BC:Update() end,
				disabled = function() return not E.bags end
			},
			Open = {
				order = 3,
				type = "group",
				name = L["Open bags when the following windows open:"],
				guiInline = true,
				get = function(info) return E.db.BagControl.Open[ info[getn(info)] ] end,
				set = function(info, value) E.db.BagControl.Open[ info[getn(info)] ] = value; end,
				disabled = function() return not E.bags or not E.db.BagControl.Enabled end,
				args = {
					Mail = {
						order = 1,
						type = "toggle",
						name = MAIL_LABEL
					},
					Vendor = {
						order = 2,
						type = "toggle",
						name = MERCHANT
					},
					Bank = {
						order = 3,
						type = "toggle",
						name = L["Bank"]
					},
					AH = {
						order = 4,
						type = "toggle",
						name = AUCTIONS
					},
					TS = {
						order = 5,
						type = "toggle",
						name = BUG_CATEGORY12
					},
					Trade = {
						order = 6,
						type = "toggle",
						name = TRADE
					}
				}
			},
			Close = {
				order = 4,
				type = "group",
				name = L["Close bags when the following windows close:"],
				guiInline = true,
				get = function(info) return E.db.BagControl.Close[ info[getn(info)] ] end,
				set = function(info, value) E.db.BagControl.Close[ info[getn(info)] ] = value; end,
				disabled = function() return not E.bags or not E.db.BagControl.Enabled end,
				args = {
					Mail = {
						order = 1,
						type = "toggle",
						name = MAIL_LABEL
					},
					Vendor = {
						order = 2,
						type = "toggle",
						name = MERCHANT
					},
					Bank = {
						order = 3,
						type = "toggle",
						name = L["Bank"]
					},
					AH = {
						order = 4,
						type = "toggle",
						name = AUCTIONS
					},
					TS = {
						order = 5,
						type = "toggle",
						name = BUG_CATEGORY12
					},
					Trade = {
						order = 6,
						type = "toggle",
						name = TRADE
					}
				}
			}
		}
	}
end

local OpenEvents = {
	["MAIL_SHOW"] = "Mail",
	["MERCHANT_SHOW"] = "Vendor",
	["BANKFRAME_OPENED"] = "Bank",
	["AUCTION_HOUSE_SHOW"] = "AH",
	["TRADE_SKILL_SHOW"] = "TS",
	["TRADE_SHOW"] = "Trade"
}

local CloseEvents = {
	["MAIL_CLOSED"] = "Mail",
	["MERCHANT_CLOSED"] = "Vendor",
	["BANKFRAME_CLOSED"] = "Bank",
	["AUCTION_HOUSE_CLOSED"] = "AH",
	["TRADE_SKILL_CLOSE"] = "TS",
	["TRADE_CLOSED"] = "Trade"
}

local function EventHandler()
	if not E.bags  then return end
	if OpenEvents[event] then
		if event == "BANKFRAME_OPENED" then
			B:OpenBank()
			if not E.db.BagControl.Open[OpenEvents[event]] then
				B.BagFrame:Hide()
			end
			return
		elseif E.db.BagControl.Open[OpenEvents[event]] then
			B:OpenBags()
			return
		else
			B:CloseBags()
			return
		end
	elseif CloseEvents[event] then
		if E.db.BagControl.Close[CloseEvents[event]] then
			B:CloseBags()
			return
		else
			B:OpenBags()
			return
		end
	end
end

local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", EventHandler)

local eventsRegistered = false
local function RegisterMyEvents()
	for event in pairs(OpenEvents) do
		EventFrame:RegisterEvent(event)
	end

	for event in pairs(CloseEvents) do
		EventFrame:RegisterEvent(event)
	end

	eventsRegistered = true
end

local function UnregisterMyEvents()
	for event in pairs(OpenEvents) do
		EventFrame:UnregisterEvent(event)
	end

	for event in pairs(CloseEvents) do
		EventFrame:UnregisterEvent(event)
	end

	eventsRegistered = false
end

function BC:Update()
	if E.db.BagControl.Enabled and not eventsRegistered then
		RegisterMyEvents()
	elseif not E.db.BagControl.Enabled and eventsRegistered then
		UnregisterMyEvents()
	end
end

function BC:Initialize()
	EP:RegisterPlugin("ElvUI_BagControl", BC.InsertOptions)
	BC:Update()
end

local function InitializeCallback()
	BC:Initialize()
end

E:RegisterModule(BC:GetName(), InitializeCallback)