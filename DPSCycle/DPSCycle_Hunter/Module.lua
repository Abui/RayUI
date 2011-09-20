------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

local L = DPSCYCLE_HUNTER_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2, 10) then
	error(string.format("[%s]: Version incompatible, requires DPSCycle v2.10 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "HUNTER")
if not module then return end

local ASPECT_OF_THE_VIPER, _, ASPECT_OF_THE_VIPER_TEXTURE = GetSpellInfo(34074)
local HUNTERS_MARK = GetSpellInfo(1130)
local SERPENT_STING = GetSpellInfo(1978)
local VIPER_STING = GetSpellInfo(3034)
local SCORPID_STING = GetSpellInfo(3043)
local MEND_PET, _, MEND_PET_TEXTURE = GetSpellInfo(136)
local KILLING_COMMAND = GetSpellInfo(34026)
local READINESS = GetSpellInfo(23989)
local RAPID_FIRE = GetSpellInfo(3045)
local CALL_OF_THE_WILD = GetSpellInfo(53434)
local KILL_SHOT = GetSpellInfo(53351)
local STEADY_SHOT = GetSpellInfo(56641) 
local ARCANE_SHOT = GetSpellInfo(3044)
local AIMED_SHOT = GetSpellInfo(19434)
local CHIMERA_SHOT = GetSpellInfo(53209)
local SILENCING_SHOT = GetSpellInfo(34490)
local GLYPH_OF_AIMED_SHOT = GetSpellInfo(56824)

local COOLDOWNS = { RAPID_FIRE, READINESS, KILLING_COMMAND, SILENCING_SHOT, CALL_OF_THE_WILD }

local auras = {}
local viperNotify, petNotify

function module:OnInitialize(db, firstTime)	
	if firstTime then
		db.viperNotify = 1
		db.mendPet = 1
		db.arcaneShot = 1
	end

	if type(db.ignores) ~= "table" then
		db.ignores = {}
	end

	local spell
	for _, spell in ipairs(COOLDOWNS) do
		if not db.ignores[spell] then
			self:AddCooldownWatchSpell(spell, spell == CALL_OF_THE_WILD)
		end
	end

	self:RegisterUnitAura("player", ASPECT_OF_THE_VIPER, nil, 1)
	self:RegisterUnitAura("pet", MEND_PET, nil, 1)
	self:RegisterUnitAura("target", HUNTERS_MARK, 1)
	self:RegisterUnitAura("target", SERPENT_STING, 1, 1)
	self:RegisterUnitAura("target", VIPER_STING, 1, 1)
	self:RegisterUnitAura("target", SCORPID_STING, 1, 1)
end

function module:OnEnable()
	viperNotify, petNotify = nil
end

function module:OnUnitAuraApplied(unit, aura)
	auras[aura] = 1		
end

function module:OnUnitAuraRemoved(unit, aura)
	auras[aura] = nil
end

function module:OnCheckConditions()
	return self:GetTalentSpec() == 2
end

function module:OnSpellRequest()
	if self.db.viperNotify then
		local manaMax = UnitManaMax("player")
		if auras[ASPECT_OF_THE_VIPER] and manaMax > 500 and UnitMana("player") / manaMax > 0.8 then
			local now = GetTime()
			if not viperNotify or now - viperNotify > 5 then
				viperNotify = now
				PlaySound("AlarmClockWarning3")
				self:DisplayInfo(ASPECT_OF_THE_VIPER_TEXTURE, string.format(L["mana full"], ASPECT_OF_THE_VIPER))
			end
		elseif viperNotify then
			viperNotify = nil
		end
	end

	if self.db.mendPet then
		if not auras[MEND_PET] and UnitExists("pet") and not UnitIsDead("pet") and UnitHealth("pet") / UnitHealthMax("pet") < 0.4 then
			local now = GetTime()
			if not petNotify or now - petNotify > 5 then
				petNotify = now
				self:DisplayInfo(MEND_PET_TEXTURE, L["pet dying"], 1, 0.5, 0)
			end
		elseif petNotify then
			petNotify = nil
		end
	end
	
	self:InitializeSequence()

	if IsResting() or UnitClassification("target") == "worldboss" then
		if not auras[HUNTERS_MARK] then
			self:AddSequenceSpell(HUNTERS_MARK, 0)
		end

		if not auras[SERPENT_STING] and not auras[VIPER_STING] and not auras[SCORPID_STING] then
			self:AddSequenceSpell(SERPENT_STING, 0)
		end
	end

	if self:IsUsableSpell(KILL_SHOT) then
		self:AddSequenceSpell(KILL_SHOT)
	end

	if self:PlayerHasGlyph(GLYPH_OF_AIMED_SHOT) then		
		self:AddSequenceSpell(AIMED_SHOT)
		self:AddSequenceSpell(CHIMERA_SHOT)
	else
		self:AddSequenceSpell(CHIMERA_SHOT)
		self:AddSequenceSpell(AIMED_SHOT)
	end
	
	if self.db.arcaneShot then
		self:AddSequenceSpell(ARCANE_SHOT)
	end
	self:CompleteSequence(STEADY_SHOT, self:GetSpellCastTime(STEADY_SHOT, 1.8), 0.6)
	return self:GetSequenceSpells()
end

------------------------------------------------------
-- Option page
------------------------------------------------------

local page = module.optionPage
group = page:CreateMultiSelectionGroup(DL["spell cooldown monitor"])
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
		module:AddCooldownWatchSpell(value, value == CALL_OF_THE_WILD)
	end
end

local anchor = group[-1]
group = page:CreateMultiSelectionGroup(DL["spell filters"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(string.format(DL["enable"], ARCANE_SHOT), "arcaneShot")
group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end

local anchor = group[-1]
group = page:CreateMultiSelectionGroup(DL["display info"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(string.format(L["viper notify"], ASPECT_OF_THE_VIPER), "viperNotify")
group:AddButton(string.format(L["mend pet"], MEND_PET), "mendPet")
group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end