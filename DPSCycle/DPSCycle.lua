------------------------------------------------------------
-- DPSCycle.lua
--
-- Abin
-- 2009-6-18
--
--Fix for CTM by Ray
-- 2011-9-20
------------------------------------------------------------

-------------------------------------------------------------------------------------
-- Internal stuff, DO NOT TOUCH THEM IN YOUR MODULES
-------------------------------------------------------------------------------------

local format = format
local type = type
local pairs = pairs
local UnitAura = UnitAura
local wipe = wipe
local GetNumTalentTabs = GetNumTalentTabs
local GetNumTalents = GetNumTalents
local GetTalentInfo = GetTalentInfo
local GetSpellBookItemName = GetSpellBookItemName
local GetSpellBookItemInfo = GetSpellBookItemInfo
local IsSpellKnown = IsSpellKnown
local GetGlyphLink = GetGlyphLink
local strfind = strfind
local GetSpellInfo = GetSpellInfo
local UnitPowerType = UnitPowerType
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

DPSCycle = { modules = {}, talentSpec = 0, talentSpecPoints = 0, playerTalentList = {}, petTalentList = {}, playerSpellList = {}, petSpellList = {}, glyphList = {}, spellSent = {}, castTimeRecords = {}, gcd = 1.5 }
DPSCycle.major = 4
DPSCycle.minor = 10
DPSCycle.version = format("%d.%02d", DPSCycle.major, DPSCycle.minor)

local function SafeCall(module, method, ...)
	local func = module and module[method]
	if func and type(func) == "function" then
		return 1, func(module, ...)
	end
end

function DPSCycle:GetModule(name)
	if type(name) == "string" then
		return self.modules[name]
	end
end

function DPSCycle:GetSelectedModule()
	return self.selectedModule
end

function DPSCycle:InitializeModule(module)
	local profiles = self.profiles
	if profiles then
		local name = module.name
		local firstTime = type(profiles[name]) ~= "table"
		if firstTime then
			profiles[name] = {}
		end
		module.db = profiles[name]
		SafeCall(module, "OnInitialize", module.db, firstTime)
	end
end

local function OnUnitAura(module, unit)
	if not module then
		return
	end

	local list = module.registeredAuras[unit]
	if not list then
		return
	end

	local aura, auraData
	for aura, auraData in pairs(list) do
		local data = auraData.data
		local name, rank, icon, count, dispelType, duration, expires, caster, isStealable = DPSCycle:UnitAura(unit, aura, auraData.harmful, auraData.mine)
		if name then
			local isNew = not data.name
			local isUpdated = isNew or data.count ~= count or data.expires ~= expires
			data.name, data.rank, data.icon, data.count, data.dispelType, data.duration, data.expires, data.caster, data.isStealable = name, rank, icon, count, dispelType, duration, expires, caster, isStealable

			if isNew then
				SafeCall(module, "OnUnitAuraApplied", unit, name, rank, icon, count, dispelType, duration, expires, caster, isStealable)
			end

			if isUpdated then
				SafeCall(module, "OnUnitAuraUpdated", unit, name, rank, icon, count, dispelType, duration, expires, caster, isStealable)
			end
		else
			if data.name then
				name, rank, icon = data.name, data.rank, data.icon
				wipe(data)
				SafeCall(module, "OnUnitAuraRemoved", unit, name, rank, icon)
			end
		end
	end
end

local function ClearAuraData(module)
	if module then
		local list = module.registeredAuras
		local unitData, auraData
		for _, unitData in pairs(list) do
			for _, auraData in pairs(unitData) do
				wipe(auraData.data)
			end
		end
	end
end

local function RefreshAuraData(module)
	if module then
		local list = module.registeredAuras
		local unit
		for unit in pairs(list) do
			OnUnitAura(module, unit)
		end
	end
end

function DPSCycle:SelectModule(name)
	if not self.playerEnteredWorld then
		return
	end

	local module = self:GetModule(name)
	if not module then
		name = nil
	end

	local origModule = self.selectedModule
	self.selectedModule = module
	self.playerProfile.module = name
	if origModule ~= module then
		self.iconFrame:Hide()
		DPSCycle.iconFrame.func = nil
		self.iconFrame:SetCountText()
		self.cooldownWatchSpells = nil

		if origModule then
			origModule:UnregisterAllEvents()
			ClearAuraData(origModule)
			SafeCall(module, "OnDisable")
		end

		if module then
			SafeCall(module, "OnEnable")
			SafeCall(module, "OnPlayerSpellsChanged")
			SafeCall(module, "OnPlayerTalentsChanged", self.talentSpec, self.talentSpecPoints)
			SafeCall(module, "OnPlayerGlyphsChanged")

			if type(module.OnSpellRequest) == "function" then
				DPSCycle.iconFrame.func = module.OnSpellRequest
			end

			RefreshAuraData(module)
			self.cooldownWatchSpells = module.cooldownSpells
			self.coreFrame:CheckConditions()
		end
	end

	return module
end

function DPSCycle:__ModuleFrame_OnEvent(event, ...)
	local parent = self.parent
	if type(parent.OnEvent) == "function" then
		parent:OnEvent(event, ...)
	else
		local func = self.events[event]
		if not func then
			func = parent[event]
		elseif type(func) ~= "function" then -- string, number, etc
			func = parent[func]
		end

		if type(func) == "function" then
			func(parent, ...)
		end
	end
end

local function UpdateTalentData(isPet)
	local list = wipe(isPet and DPSCycle.petTalentList or DPSCycle.playerTalentList)
	if not isPet then
		DPSCycle.talentSpec, DPSCycle.talentSpecPoints = 0, 0
	end

	local tab, talent
	for tab = 1, GetNumTalentTabs(false, isPet) do
		local tabPoints = 0
		for talent = 1, GetNumTalents(tab, false, isPet) do
			local name, _, _, _, points = GetTalentInfo(tab, talent, false, isPet)
			if name and points > 0 then
				tabPoints = tabPoints + points
				list[name] = points
			end
		end

		if not isPet and tabPoints > DPSCycle.talentSpecPoints then
			DPSCycle.talentSpec, DPSCycle.talentSpecPoints = tab, tabPoints
		end
	end

	if not isPet then
		SafeCall(DPSCycle:GetSelectedModule(), "OnPlayerTalentsChanged", DPSCycle.talentSpec, DPSCycle.talentSpecPoints)
		DPSCycle.coreFrame:CheckConditions()
	end
end

local function UpdateSpellData(isPet)
	local list = wipe(isPet and DPSCycle.petSpellList or DPSCycle.playerSpellList)
	local book = isPet and BOOKTYPE_PET or BOOKTYPE_SPELL
	local i
	for i = 1, 1024 do
		local name = GetSpellBookItemName(i, book)
		local _, spellID = GetSpellBookItemInfo(i, book)
		if name and spellID then
			if IsSpellKnown(spellID, isPet) then
				list[name] = i
			end
		else
			break
		end
	end

	if not isPet then
		SafeCall(DPSCycle:GetSelectedModule(), "OnPlayerSpellsChanged")
	end
end

local function UpdateGlyphData()
	local list = wipe(DPSCycle.glyphList)
	local i
	for i = 1, 6 do
		local lnk = GetGlyphLink(i)
		if lnk then
			local _, _, name = strfind(lnk, "^.*%[(.*)%].*$")
			if name then
				list[name] = 1
			end
		end
	end

	SafeCall(DPSCycle:GetSelectedModule(), "OnPlayerGlyphsChanged")
end

local UNHOLY_PRESENCE = GetSpellInfo(48265)
local function UpdateGcd()
	if UnitPowerType("player") == 3 or DPSCycle:PlayerBuff(UNHOLY_PRESENCE) then
		DPSCycle.gcd = 1
	else
		DPSCycle.gcd = 1.5
	end
end

local function UpdateCastingTime(spell, func)
	local _, _, _, _, startTime, endTime = func("player")
	if startTime and endTime then
		DPSCycle.castTimeRecords[spell] = (endTime - startTime) / 1000
	end
end

------------------------------------------
-- Data frame
------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

local isLengthy
frame:SetScript("OnEvent", function(self, event, unit, spell)
	if event == "PLAYER_LOGIN" then
		UpdateSpellData(1)
		UpdateSpellData()
		UpdateTalentData(1)
		UpdateTalentData()
		UpdateGlyphData()

		self:RegisterEvent("PLAYER_TALENT_UPDATE")
		self:RegisterEvent("PET_TALENT_UPDATE")
		self:RegisterEvent("UNIT_PET")
		self:RegisterEvent("SPELLS_CHANGED")
		self:RegisterEvent("GLYPH_ADDED")
		self:RegisterEvent("GLYPH_REMOVED")
		self:RegisterEvent("GLYPH_UPDATED")
		self:RegisterEvent("PLAYER_ALIVE")
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_DISPLAYPOWER")
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")

		self:RegisterEvent("UNIT_SPELLCAST_SENT")
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		self:RegisterEvent("UNIT_SPELLCAST_START")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		self:RegisterEvent("UNIT_SPELLCAST_STOP")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

	elseif event == "PLAYER_ALIVE" then
		self:UnregisterEvent("PLAYER_ALIVE")
		UpdateTalentData(1)
		UpdateTalentData()
		UpdateGlyphData()
		UpdateGcd()
	elseif event == "UNIT_AURA" then
		if unit == "player" then
			UpdateGcd()
		end
		OnUnitAura(DPSCycle:GetSelectedModule(), unit)
	elseif event == "UNIT_DISPLAYPOWER" then
		if unit == "player" then
			UpdateGcd()
		end
	elseif event == "PLAYER_TALENT_UPDATE" then
		UpdateTalentData()
	elseif event == "PET_TALENT_UPDATE" then
		UpdateTalentData(1)
	elseif event == "UNIT_PET" then
		if unit == "player" then
			UpdateTalentData(1)
		end
		OnUnitAura(DPSCycle:GetSelectedModule(), "pet")
	elseif event == "SPELLS_CHANGED" then
		if not unit then
			UpdateSpellData(1)
			UpdateSpellData()
		end
	elseif event == "GLYPH_ADDED" or event == "GLYPH_REMOVED" or event == "GLYPH_UPDATED" then
		UpdateGlyphData()
	elseif event == "PLAYER_TARGET_CHANGED" then
		wipe(DPSCycle.spellSent)
		DPSCycle.castingSpell = nil
		DPSCycle.lastSentSpell, DPSCycle.lastSentTime = nil
		OnUnitAura(DPSCycle:GetSelectedModule(), "target")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		OnUnitAura(DPSCycle:GetSelectedModule(), "focus")

	elseif unit == "player" and spell and not IsAutoRepeatSpell(spell) then

		-- WOW's internal spell-casting events precedence:

		-- instant-casting:	UNIT_SPELLCAST_SENT -> UNIT_SPELLCAST_SUCCEEDED
		-- lenthy-casting:	UNIT_SPELLCAST_SENT -> UNIT_SPELLCAST_START -> [UNIT_SPELLCAST_SUCCEEDED ->] UNIT_SPELLCAST_STOP
		-- channeling:		UNIT_SPELLCAST_SENT -> UNIT_SPELLCAST_SUCCEEDED [-> UNIT_SPELLCAST_CHANNEL_START -> UNIT_SPELLCAST_CHANNEL_STOP]

		if event == "UNIT_SPELLCAST_SENT" then
			isLengthy = nil
			DPSCycle.castingSpell = spell
		elseif event == "UNIT_SPELLCAST_START" then
			isLengthy = 1
			UpdateCastingTime(spell, UnitCastingInfo)
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
			isLengthy = 1
			UpdateCastingTime(spell, UnitChannelInfo)
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			local now = GetTime()
			DPSCycle.spellSent[spell] = now
			DPSCycle.lastSentSpell, DPSCycle.lastSentTime = spell, now
			if not isLengthy then
				DPSCycle.castingSpell = nil
			end
		elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
			isLengthy = nil
			DPSCycle.castingSpell = nil
		end
	end
end)