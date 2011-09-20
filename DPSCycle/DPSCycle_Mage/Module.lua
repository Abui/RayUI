------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-8-16
------------------------------------------------------------

local L = DPSCYCLE_MAGE_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2) then
	error(format("[%s]: Version incompatible, requires DPSCycle v2.0 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "MAGE")
if not module then return end

local ICE_BLOCK = GetSpellInfo(45438)
local COLD_SNAP = GetSpellInfo(11958)
local ICY_VEINS = GetSpellInfo(12472)
local SUMMON_WATER_ELEMENTAL = GetSpellInfo(31687)
local COMBUSTION = GetSpellInfo(11129)
local FIREBALL = GetSpellInfo(133)
local PYROBLAST = GetSpellInfo(11366)
local SCORCH = GetSpellInfo(2948)
local FROSTFIRE_BOLT = GetSpellInfo(44614)
local LIVING_BOMB = GetSpellInfo(55360)
local HOT_STREAK = GetSpellInfo(44445)
local INSTANT_FIREBALL = GetSpellInfo(57761)
local IMPROVED_SCORCH = GetSpellInfo(11095)
local FROST_BOLT = GetSpellInfo(116)
local WINTERS_CHILL = GetSpellInfo(11180)
local IMPROVED_SHADOW_BOLT = GetSpellInfo(17794)
local EVOCATION = GetSpellInfo(12051)
local COUNTERSPELL = GetSpellInfo(2139)
local ARCANE_MISSILES = GetSpellInfo(5143)
local ARCANE_BLAST = GetSpellInfo(30451)
local ARCANE_BARRAGE = GetSpellInfo(44425)
local MIRROR_IMAGE = GetSpellInfo(55342)
local ARCANE_POWER = GetSpellInfo(12042)
local PRESENCE_OF_MIND = GetSpellInfo(12043)
local MISSILE_BARRAGE = GetSpellInfo(44404)

local GLYPH_OF_IMPROVED_SCORCH = GetSpellInfo(56371)
local ABSTACKS = select(4, GetBuildInfo()) < 30200 and 3 or 4

local COOLDOWNS = { COMBUSTION, ICE_BLOCK, COLD_SNAP, SUMMON_WATER_ELEMENTAL, MIRROR_IMAGE, ICY_VEINS, EVOCATION, PRESENCE_OF_MIND, ARCANE_POWER, COUNTERSPELL }
local ARCANEBLASTCOLORS = { { r = 0, g = 1, b = 0 }, { r = 1, g = 1, b = 0 }, { r = 1, g = 0.5, b = 0 }, { r = 1, g = 0, b = 0 } }

local livingBombEndTime, monitorScorch, scorchCount, scorchExpires, hasPet, combustion, arcaneBlast, missileBarrage, instantFireball, hotStreak, winterChill, impSB

function module:OnInitialize(db, firstTime)
	if firstTime then
		db.arcaneSpell = ARCANE_MISSILES
		db.fireSpell = FIREBALL	
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

	self:RegisterUnitAura("player", INSTANT_FIREBALL)
	self:RegisterUnitAura("player", HOT_STREAK)
	self:RegisterUnitAura("player", MISSILE_BARRAGE)
	--self:RegisterUnitAura("player", ARCANE_FOCUS)
	self:RegisterUnitAura("player", ARCANE_BLAST, 1)
	self:RegisterUnitAura("player", COMBUSTION)
	self:RegisterUnitAura("target", IMPROVED_SCORCH, 1)
	self:RegisterUnitAura("target", WINTERS_CHILL, 1)
	self:RegisterUnitAura("target", IMPROVED_SHADOW_BOLT, 1)
end

function module:OnEnable()
end

function module:OnUnitAuraApplied(unit, aura, rank, icon)
	if aura == INSTANT_FIREBALL then
		instantFireball = 1
		self:DisplayInfo(icon, format(DL["gained"], aura))	
	elseif aura == HOT_STREAK then
		hotStreak = 1
		self:DisplayInfo(icon, format(DL["gained"], aura))
	elseif aura == COMBUSTION then
		combustion = 1
	elseif aura == MISSILE_BARRAGE then
		missileBarrage = 1
		self:DisplayInfo(icon, format(DL["gained"], aura))
	elseif aura == WINTERS_CHILL then
		winterChill = 1
	elseif aura == IMPROVED_SHADOW_BOLT then
		impSB = 1
	end
end

function module:OnUnitAuraUpdated(unit, aura, rank, icon, count, dispelType, duration, expires)
	if aura == ARCANE_BLAST then
		arcaneBlast = count
		local color = ARCANEBLASTCOLORS[count or 0]
		if color then
			self:SetCountText(count, color.r, color.g, color.b)
		end
	elseif aura == IMPROVED_SCORCH then
		scorchCount, scorchExpires = count, expires
	end
end

function module:OnUnitAuraRemoved(unit, aura)
	if aura == INSTANT_FIREBALL then
		instantFireball = nil
	elseif aura == HOT_STREAK then
		hotStreak = nil
	elseif aura == COMBUSTION then
		combustion = nil
	elseif aura == MISSILE_BARRAGE then
		missileBarrage = nil
	elseif aura == WINTERS_CHILL then
		winterChill = nil
	elseif aura == IMPROVED_SHADOW_BOLT then
		impSB = nil
	elseif aura == ARCANE_BLAST then
		arcaneBlast = nil
		self:SetCountText()
	elseif aura == IMPROVED_SCORCH then
		scorchCount, scorchExpires = nil
	end
end

function module:OnPlayerTalentsChanged()
	if self:GetTalentPoints(LIVING_BOMB) > 0 then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end

	if self:GetTalentPoints(SUMMON_WATER_ELEMENTAL) > 0 then
		self:RegisterEvent("UNIT_PET")
		self:UNIT_PET("player")
	else
		self:UnregisterEvent("UNIT_PET")
	end
	
	monitorScorch = self:GetTalentPoints(IMPROVED_SCORCH) > 0
end

function module:COMBAT_LOG_EVENT_UNFILTERED(_, flag, source, _, _, _, _, _, _, spell)
	if source == UnitGUID("player") and spell == LIVING_BOMB then
		if flag == "SPELL_AURA_APPLIED" then
			livingBombEndTime = GetTime() + 12
		elseif flag == "SPELL_AURA_REMOVED" then
			livingBombEndTime = nil
			self:SetCountText()
		end
	end
end

function module:UNIT_PET(unit)
	if unit == "player" then
		hasPet = UnitExists("pet") and GetPetTimeRemaining() and PetHasActionBar()
		if not hasPet then
			self:SetCountText()
		end
	end
end

function module:ArcaneProc()
	local spell = missileBarrage and ARCANE_MISSILES or self.db.arcaneSpell
	self:InitializeSequence()
	if self:PlayerHasSpell(ARCANE_BLAST) then
		local count = arcaneBlast or 0
		local i
		for i = count + 1, ABSTACKS do
			self:AddSequenceSpell(ARCANE_BLAST, 0, nil, 0)
		end

		self:AddSequenceSpell(spell, 0, nil, 0)
		self:AddSequenceSpell(ARCANE_BLAST, 0, nil, 0)
		self:AddSequenceSpell(ARCANE_BLAST, 0, nil, 0)
		self:AddSequenceSpell(ARCANE_BLAST, 0, nil, 0)		
	else
		self:AddSequenceSpell(spell, 0)
		self:AddSequenceSpell(self.db.arcaneSpell, 0)
		self:AddSequenceSpell(self.db.arcaneSpell, 0)
		self:AddSequenceSpell(self.db.arcaneSpell, 0)
	end	
	self:CompleteSequence()
	return self:GetSequenceSpells()
end

function module:FireProc()

	if livingBombEndTime then
		local remain = livingBombEndTime - GetTime()
		if remain >= 0 then
			self:SetCountText(format("%.1f", remain), 0, 0.5, 1)			
		end
	end

	self:InitializeSequence()

	local hasGlyph = self:PlayerHasGlyph(GLYPH_OF_IMPROVED_SCORCH)
	local spell1 = hotStreak and PYROBLAST or self.db.fireSpell
	local spell2 = self.db.fireSpell
	
	if monitorScorch and not winterChill and not impSB and not combustion and (IsResting() or UnitClassification("target") == "worldboss") then
		local timeLeft = scorchExpires and (scorchExpires - GetTime()) or 0
		local count = scorchCount or 0

		if hasGlyph then
			self:AddSequenceSpell(SCORCH, timeLeft)
		else
			if count < 5 then
				local i
				for i = count, 5 do
					self:AddSequenceSpell(SCORCH, 0, nil, 0)
				end
			else
				self:AddSequenceSpell(SCORCH, timeLeft - 5, nil, 0)
			end
		end	
	end

	if hotStreak then
		self:AddSequenceSpell(PYROBLAST, 0)
	end

	self:CompleteSequence(self.db.fireSpell, self:GetSpellCastTime(self.db.fireSpell), 1.5)
	return self:GetSequenceSpells()
end

function module:FrostProc()
	if hasPet then
		local ms = GetPetTimeRemaining()
		if ms and ms > 0 and ms < 200000 then
			self:SetCountText(format("%.1f", ms / 1000), 0, 1, 0.5)
		end
	end

	return instantFireball and FIREBALL or FROST_BOLT
end

function module:OnSpellRequest()
	local spec = self:GetTalentSpec()
	if spec == 1 then
		return self:ArcaneProc()
	elseif spec == 2 then
		return self:FireProc()
	else
		return self:FrostProc()
	end
end

------------------------------------------------------
-- Option page
------------------------------------------------------

local page = module.optionPage

local group = page:CreateSingleSelectionGroup(L["arcane spell selection"])
group:SetPoint("TOPLEFT", 16, -70)
group:AddButton(ARCANE_MISSILES, ARCANE_MISSILES)
group:AddButton(ARCANE_BARRAGE, ARCANE_BARRAGE)
group.OnCheckInit = function(self, value) return module.db.arcaneSpell == value end
group.OnSelectionChanged = function(self, value) module.db.arcaneSpell = value end

anchor = group[-1]
group = page:CreateSingleSelectionGroup(L["fire spell selection"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(FIREBALL, FIREBALL)
group:AddButton(FROSTFIRE_BOLT, FROSTFIRE_BOLT)
group.OnCheckInit = function(self, value) return module.db.fireSpell == value end
group.OnSelectionChanged = function(self, value) module.db.fireSpell = value end