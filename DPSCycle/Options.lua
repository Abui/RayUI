------------------------------------------------------------
-- Options.lua
--
-- Abin
-- 2009-6-18
--
--Fix for CTM by Ray
-- 2011-9-20
------------------------------------------------------------

local type = type
local select = select
local UnitClass = UnitClass
local UnitName = UnitName
local pairs = pairs

local L = DPSCYCLE_LOCALE
local db = {}
local modulePageId = 0

-- GUI options

local page = UICreateInterfaceOptionPage("DPSCycleOptionPage", L["title"], L["sub title"])
DPSCycle.optionPage = page
page.title:SetText(L["title"].." "..DPSCycle.version)

page.CreateModuleOptionPage = function(self, title, desc)
	modulePageId = modulePageId + 1
	return UICreateInterfaceOptionPage(self:GetName().."ModulePage"..modulePageId, title, desc, L["title"])
end

local function HideShowRegion(region, hide)
	if hide then
		region:Hide()
	else
		region:Show()
	end
end

local group = page:CreateMultiSelectionGroup(L["GUI settings"])
page:AnchorToTopLeft(group)
group:AddButton(L["lock"], "lock")
group:AddButton(L["hide text"], "hideText")
group:AddButton(L["hide cooldown buttons"], "hideCooldown")
group:AddButton(L["disable cursor tooltip"], "disableCursor")

group.OnCheckInit = function(self, value) return db[value] end
group.OnCheckChanged = function(self, value, checked)
	db[value] = checked
	if value == "lock" then
		HideShowRegion(DPSCycle.moverFrame, checked)
	elseif value == "hideText" then
		HideShowRegion(DPSCycle.iconFrame.spellText, checked)
	elseif value == "hideCooldown" then
		HideShowRegion(DPSCycle.cooldownPanel, checked)
	elseif value == "disableCursor" then
		DPSCycle.cooldownPanel:SetEnableCursor(not checked)
	end
end

local function DPSCycleOptionPage_CreateSlider(key, minVal, maxVal, func)
	local slider = page:CreateSlider(L[key], minVal, maxVal, 5, "%d%%")
	slider.func = func
	slider:SetWidth(220)
	slider:SetHeight(15)

	slider.OnSliderChanged = function(self, value)
		db[key] = value
		DPSCycle.coreFrame[self.func](DPSCycle.coreFrame, value / 100)
	end

	return slider
end

local scaleSlider = DPSCycleOptionPage_CreateSlider("scale", 50, 250, "SetScale")
scaleSlider:SetPoint("TOPLEFT", group[-1], "BOTTOMLEFT", 8, -22)

local alphaSlider = DPSCycleOptionPage_CreateSlider("alpha", 0, 100, "SetAlpha")
alphaSlider:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -32)

local moduleCombo = page:CreateComboBox(L["selected module"])
moduleCombo:SetWidth(200)
moduleCombo:SetPoint("TOPLEFT", alphaSlider, "BOTTOMLEFT", 0, -36)
moduleCombo:AddLine(NONE)

moduleCombo.OnComboInit = function(self) return DPSCycle.playerProfile and DPSCycle.playerProfile.module or nil end
moduleCombo.OnComboChanged = function(self, value)
	DPSCycle:SelectModule(value)
	if DPSCycle.playerProfile then
		DPSCycle.playerProfile.manualNone = (value == nil) or nil
	end
end

page.default = function(self)
	scaleSlider:SetValue(100)
	alphaSlider:SetValue(100)
	DPSCycle.coreFrame:ClearAllPoints()
	DPSCycle.coreFrame:SetPoint("CENTER")
end

page:RegisterEvent("VARIABLES_LOADED")
page:RegisterEvent("PLAYER_LOGIN")

-- Oh my holy God! "PLAYER_LOGIN" event sometime fires before "VARIABLES_LOADED" in 3.3, what a funny bug!
-- Now what can I do? Just delay everything until both "VARIABLES_LOADED" and "PLAYER_LOGIN" are fired...
local varLoaded, playerLogin
local function InitModuleSelection()
	if varLoaded and playerLogin then
		DPSCycle.playerEnteredWorld = 1
		local name, module
		for name, module in pairs(DPSCycle.modules) do
			DPSCycle:InitializeModule(module)
			moduleCombo:AddLine(name, name)
		end

		name = DPSCycle.playerProfile.module
		if not name and DPSCycle.firstModule and not DPSCycle.playerProfile.manualNone then
			name = DPSCycle.firstModule.name
		end
		DPSCycle:SelectModule(name)

		DEFAULT_CHAT_FRAME:AddMessage("|cffffff78"..L["title"].." "..DPSCycle.version.."|r by Abin loaded.")
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff78"..L["title"]..":|r "..L["command prompt"])
	end
end

page:SetScript("OnEvent", function(self, event)
	if event == "VARIABLES_LOADED" then

		if type(DPSCycleDB) ~= "table" then
			DPSCycleDB = {}
		end

		db = DPSCycleDB

		if type(db.profiles) ~= "table" then
			db.profiles = {}
		end

		if type(db.players) ~= "table" then
			db.players = {}
		end

		local PLAYER_PROFILE = (select(2, UnitClass("player")) or "UnknownClass").."-"..(UnitName("player") or "UnknownPlayer")
		if type(db.players[PLAYER_PROFILE]) ~= "table" then
			db.players[PLAYER_PROFILE] = {}
		end

		DPSCycle.db = db
		DPSCycle.profiles = db.profiles
		DPSCycle.playerProfile = db.players[PLAYER_PROFILE]

		if type(DPSCycle.playerProfile.module) ~= "string" then
			DPSCycle.playerProfile.module = nil
		end

		scaleSlider:SetValue(db.scale or 100)
		alphaSlider:SetValue(db.alpha or 100)

		if db.lock then
			DPSCycle.moverFrame:Hide()
		end

		if db.hideText then
			DPSCycle.iconFrame.spellText:Hide()
		end

		if not db.hideCooldown then
			DPSCycle.cooldownPanel:Show()
		end

		if db.disableCursor then
			DPSCycle.cooldownPanel:SetEnableCursor(false)
		end

		varLoaded = 1
		InitModuleSelection()

	elseif event == "PLAYER_LOGIN" then

		playerLogin = 1
		InitModuleSelection()
	end
end)

------------------------------------------------------------
-- Slash command handler: "/dpscycle"
------------------------------------------------------------

SLASH_DPSCYCLE1 = "/dps"
SLASH_DPSCYCLE2 = "/dpscycle"
SlashCmdList["DPSCYCLE"] = function(cmd)
	local module = DPSCycle:GetSelectedModule()
	if not module or not cmd or cmd == "" then
		-- I want the "DPS Cycle" node to be expanded, but Blizzard does not seem to provide any method...
		if DPSCycle.firstModule then
			DPSCycle.firstModule.optionPage:Open()
		end
		page:Open()
	else
		module.optionPage:Open()
	end
end