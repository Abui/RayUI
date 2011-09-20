------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

local L = DPSCYCLE_PALADIN_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2) then
	error(string.format("[%s]: Version incompatible, requires DPSCycle v2.0 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "PALADIN")
if not module then return end

local CONSECRATION = GetSpellInfo(26573)
local JUDGEMENT_OF_LIGHT = GetSpellInfo(20271)
local JUDGEMENT_OF_WISDOM = GetSpellInfo(53408)
local HAMMER_OF_WRATH = GetSpellInfo(24275)
local AVENGING_WRATH = GetSpellInfo(31884)
local EXORCISM = GetSpellInfo(879)
local CRUSADER_STRIKE = GetSpellInfo(35395)
local DIVINE_STORM = GetSpellInfo(53385)
local DIVINE_SHIELD = GetSpellInfo(642)
local DIVINE_PROTECTION = GetSpellInfo(498)
local HAMMER_OF_JUSTICE = GetSpellInfo(853)
local RIGHTEOUS_FURY = GetSpellInfo(25780)
local AVENGERS_SHIELD = GetSpellInfo(31935)
local HAMMER_OF_THE_RIGHTEOUS = GetSpellInfo(53595)
local HOLY_SHIELD = GetSpellInfo(20927)
local SHIELD_OF_RIGHTEOUSNESS = GetSpellInfo(53600)

local COOLDOWNS = { AVENGING_WRATH, DIVINE_SHIELD, DIVINE_PROTECTION, HAMMER_OF_JUSTICE, AVENGERS_SHIELD, EXORCISM }

function module:OnInitialize(db, firstTime)
	if firstTime then
		db.consecration = 1
		--db.exorcism = 1
	end

	if type(db.judgement) ~= "string" or (db.judgement ~= JUDGEMENT_OF_LIGHT and db.judgement ~=JUDGEMENT_OF_WISDOM) then
		db.judgement = JUDGEMENT_OF_WISDOM
	end

	if type(db.ignores) ~= "table" then
		db.ignores = {}
	end

	local spell
	for _, spell in ipairs(COOLDOWNS) do
		if not db.ignores[spell] then
			self:AddCooldownWatchSpell(spell)
		end
	end
end

function module:OnCheckConditions()
	return self:GetTalentSpec() > 1
end

function module:ProtectionProc(instantExorcism)	
	if not self:PlayerBuff(RIGHTEOUS_FURY, 1) then
		self:AddSequenceSpell(RIGHTEOUS_FURY, 0)
	end	
	
	self:AddSequenceSpell(SHIELD_OF_RIGHTEOUSNESS)
	self:AddSequenceSpell(HAMMER_OF_THE_RIGHTEOUS)
	self:AddSequenceSpell(self.db.judgement)
	if self.db.consecration then
		self:AddSequenceSpell(CONSECRATION)
	end

	if instantExorcism --[[or self.db.exorcism--]] then
		self:AddSequenceSpell(EXORCISM)
	end

	self:AddSequenceSpell(HOLY_SHIELD)

	if self:IsUsableSpell(HAMMER_OF_WRATH) then
		self:AddSequenceSpell(HAMMER_OF_WRATH)
	end
end

function module:RetributionProc(instantExorcism)	
	if self:IsUsableSpell(HAMMER_OF_WRATH) then
		self:AddSequenceSpell(HAMMER_OF_WRATH)
	end

	self:AddSequenceSpell(CRUSADER_STRIKE)
	self:AddSequenceSpell(self.db.judgement)
	self:AddSequenceSpell(DIVINE_STORM)
	if instantExorcism --[[or self.db.exorcism--]] then
		self:AddSequenceSpell(EXORCISM)
	end

	if self.db.consecration then
		self:AddSequenceSpell(CONSECRATION)
	end
end

function module:OnSpellRequest()
	local instantExorcism = self:GetSpellCastTime(EXORCISM) == 0
	self:InitializeSequence()
	if self:GetTalentSpec() == 2 then
		self:ProtectionProc(instantExorcism)
	else
		self:RetributionProc(instantExorcism)
	end
	self:CompleteSequence()
	return self:GetSequenceSpells(3)
end

------------------------------------------------------
-- Option page
------------------------------------------------------

local page = module.optionPage

local group = page:CreateMultiSelectionGroup(DL["spell cooldown monitor"])
group:SetPoint("TOPLEFT", 16, -70)
local spell
for _, spell in ipairs(COOLDOWNS) do
	group:AddButton(string.format(DL["don't display"], spell), spell)
end
group.OnCheckInit = function(self, value) return module.db.ignores[value] end
group.OnCheckChanged = function(self, value, checked)
	module.db.ignores[value] = checked
	if checked then
		module:RemoveCooldownWatchSpell(value)
	else
		module:AddCooldownWatchSpell(value)
	end
end

anchor = group[-1]
group = page:CreateSingleSelectionGroup(L["judgement selection"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(JUDGEMENT_OF_LIGHT, JUDGEMENT_OF_LIGHT)
group:AddButton(JUDGEMENT_OF_WISDOM, JUDGEMENT_OF_WISDOM)
group.OnCheckInit = function(self, value) return module.db.judgement == value end
group.OnSelectionChanged = function(self, value) module.db.judgement = value end

anchor = group[-1]
group = page:CreateMultiSelectionGroup(DL["misc"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(string.format(DL["keep"], CONSECRATION), "consecration")
--group:AddButton(string.format(DL["enable"], EXORCISM), "exorcism")
group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end