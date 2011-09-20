------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-6-21
------------------------------------------------------------

local L = DPSCYCLE_DEATHKNIGHT_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2) then
	error(format("[%s]: Version incompatible, requires DPSCycle v2.0 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "DEATHKNIGHT")
if not module then return end

local FROST_FEVER = GetSpellInfo(59921)
local BLOOD_PLAGUE = GetSpellInfo(59879)
local ICY_TOUCH = GetSpellInfo(45477)
local PLAGUE_STRIKE = GetSpellInfo(45462)
local BLOOD_STRIKE = GetSpellInfo(45902)
local HEART_STRIKE = GetSpellInfo(55258)
local DEATH_STRIKE = GetSpellInfo(49998)
local OBLITERATE = GetSpellInfo(49020)
local SCOURGE_STRIKE = GetSpellInfo(55265)
local DEATH_COIL = GetSpellInfo(49892)
local FROST_STRIKE = GetSpellInfo(51416)
local DANCING_OF_RUNE_WEAPONS = GetSpellInfo(49028)
local SUMMON_GARGOYLE = GetSpellInfo(49206)
local HORN_OF_WINTER = GetSpellInfo(57330)
local BLOOD_GORGED = GetSpellInfo(61154)
local BONE_SHIELD = GetSpellInfo(49222)
local BLOOD_PRESENCE = GetSpellInfo(48266)
local HYSTERIA = GetSpellInfo(49016)
local BLOOD_TAP = GetSpellInfo(45529)
local EMPOWER_RUNE_WEAPON = GetSpellInfo(47568)
local ARMY_OF_THE_DEAD = GetSpellInfo(42650)
local MIND_FREEZE = GetSpellInfo(47528)
local PESTILENCE, _, PESTILENCE_TEXTURE = GetSpellInfo(50842)
local PESTILENCE_CAST = format(L["pestilence message"], PESTILENCE)
local PESTILENCE_TIMEOUT = format(L["pestilence timeout message"], PESTILENCE)

local GLYPH_OF_DISEASE = GetSpellInfo(63334)

local COOLDOWNS = { HYSTERIA, DANCING_OF_RUNE_WEAPONS, SUMMON_GARGOYLE, BLOOD_TAP, MIND_FREEZE, EMPOWER_RUNE_WEAPON }

local auras = {}
local runes = {}
local pestilenceCastTime

function module:OnInitialize(db, firstTime)
	if firstTime then
		db.pestilenceNotify = 1
		db.pestilenceTimeoutNotify = 1
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

	self:RegisterUnitAura("player", BONE_SHIELD)
	self:RegisterUnitAura("target", FROST_FEVER, 1, 1)
	self:RegisterUnitAura("target", BLOOD_PLAGUE, 1, 1)
end

function module:OnEnable()
	pestilenceCastTime = nil
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("RUNE_POWER_UPDATE")
	self:RegisterEvent("RUNE_TYPE_UPDATE", "RUNE_POWER_UPDATE")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RUNE_POWER_UPDATE()
end

function module:OnUnitAuraUpdated(unit, aura, rank, icon, count, dispelType, duration, expires)
	auras[aura] = expires
end

function module:OnUnitAuraRemoved(unit, aura)
	auras[aura] = nil
end

function module:PLAYER_REGEN_ENABLED()
	pestilenceCastTime = nil
end

function module:RUNE_POWER_UPDATE()
	runes = wipe(runes)
	local i
	for i = 1, 6 do
		if select(3, GetRuneCooldown(i)) then
			local id = GetRuneType(i)
			runes[id] = (runes[id] or 0) + 1
		end
	end
end

function module:UNIT_SPELLCAST_SUCCEEDED(unit, spell)
	if unit == "player" and spell == PESTILENCE then
		pestilenceCastTime = GetTime()
		if self.db.pestilenceNotify then
			self:DisplayInfo(PESTILENCE_TEXTURE, PESTILENCE_CAST)
		end
	end
end

function module:IsUsableRune(runeType, allowDeathRune)
	local blood, unholy, frost, death = runes[1], runes[2], runes[3], allowDeathRune and runes[4]
	if runeType == "BLOOD" then
		return blood or death
	elseif runeType == "FROST" then
		return frost or death
	elseif runeType == "UNHOLY" then
		return unholy or death
	elseif runeType == "DUAL" then
		if frost then
			return unholy or death
		elseif unholy then
			return frost or death
		elseif death and death >= 2 then
			return death
		end
	end
end

function module:CheckPestilenceElapsed()
	if pestilenceCastTime then
		local elapsed = GetTime() - pestilenceCastTime
		if elapsed > 20 then
			pestilenceCastTime = nil
			if elapsed < 25 and self.db.pestilenceTimeoutNotify then
				self:DisplayInfo(nil, PESTILENCE_TIMEOUT, 1, 0.5, 0)
			end
		end
	end
end

function module:OnSpellRequest()
	self:CheckPestilenceElapsed()

	-- Presence please!
	if GetShapeshiftForm() == 0 then
		return BLOOD_PRESENCE
	end

	-- Bone shield
	if not auras[BONE_SHIELD] and self:IsUsableSpell(BONE_SHIELD, 1, 1) then
		return BONE_SHIELD
	end

	------------------------------------------------------
	-- Diseases keep up
	------------------------------------------------------

	local frostFeverTime, bloodPlagueTime = auras[FROST_FEVER], auras[BLOOD_PLAGUE]
	if self.db.ignores[FROST_FEVER] then
		frostFeverTime = 20
	else
		frostFeverTime = frostFeverTime and (frostFeverTime - GetTime()) or 0
	end

	if self.db.ignores[BLOOD_PLAGUE] then
		bloodPlagueTime = 20
	else
		bloodPlagueTime = bloodPlagueTime and (bloodPlagueTime - GetTime()) or 0
	end

	if self:PlayerHasGlyph(GLYPH_OF_DISEASE) then
		if frostFeverTime > 1 and bloodPlagueTime > 1 then
			if (frostFeverTime < 5 or bloodPlagueTime < 5) and self:IsUsableRune("BLOOD", 1) then
				return PESTILENCE
			end
		elseif frostFeverTime < 1 then
			if self:IsUsableRune("FROST", 1) then
				return ICY_TOUCH
			end
		elseif bloodPlagueTime < 1 then
			if self:IsUsableRune("UNHOLY", 1) then
				return PLAGUE_STRIKE
			end
		end
	else
		if frostFeverTime < 1.5 and self:IsUsableRune("FROST", 1) then
			return ICY_TOUCH
		end

		if bloodPlagueTime < 1.5 and self:IsUsableRune("UNHOLY", 1) then
			return PLAGUE_STRIKE
		end
	end

	------------------------------------------------------
	-- Special spells
	------------------------------------------------------

	-- Low health prefer Death Strike?
	if self:IsUsableRune("DUAL", 1) and UnitHealth("player") / UnitHealthMax("player") <= 0.75 and self:GetTalentPoints(BLOOD_GORGED) > 0 then
		return DEATH_STRIKE
	end

	------------------------------------------------------
	-- Talent main strikes
	------------------------------------------------------
	local runePowerBlow = DEATH_COIL

	if self:GetTalentPoints(HEART_STRIKE) > 0 then

		-- Blood DK, HS-DS
		if self:IsUsableRune("BLOOD", 1) then
			return HEART_STRIKE
		elseif self:IsUsableRune("DUAL") then
			return DEATH_STRIKE
		end

	elseif self:GetTalentPoints(FROST_STRIKE) > 0 then

		-- Ice DK, OB-BS
		if self:IsUsableRune("DUAL", 1) then
			return OBLITERATE
		elseif self:IsUsableRune("BLOOD") then
			return BLOOD_STRIKE
		end

		runePowerBlow = FROST_STRIKE

	elseif self:GetTalentPoints(SCOURGE_STRIKE) > 0 then

		-- Unholy DK, BS-SS
		if self:IsUsableRune("BLOOD") then
			return BLOOD_STRIKE
		elseif self:IsUsableRune("DUAL", 1) then
			return SCOURGE_STRIKE
		end
	else

		-- Other DK, could be OB-BS or DS-BS depends on talend spec, Obliterate for frost/unholy, Death Strike for blood
		if self:IsUsableRune("DUAL", 1) then
			return self:GetTalentSpec() > 1 and OBLITERATE or DEATH_STRIKE
		elseif self:IsUsableRune("BLOOD") then
			return BLOOD_STRIKE
		end
	end

	-- Runic power blowout
	if self:IsUsableSpell(runePowerBlow, nil, 1) then
		return runePowerBlow
	end

	-- Horn of Winter
	if self:IsUsableSpell(HORN_OF_WINTER, 1, 1) then
		return HORN_OF_WINTER
	end
end

------------------------------------------------------
-- Option page
------------------------------------------------------

local page = module.optionPage

local group = page:CreateMultiSelectionGroup(L["disease check"])
group:SetPoint("TOPLEFT", 16, -70)
group:AddButton(format(DL["don't check"], FROST_FEVER), FROST_FEVER)
group:AddButton(format(DL["don't check"], BLOOD_PLAGUE), BLOOD_PLAGUE)
group.OnCheckInit = function(self, value) return module.db.ignores[value] end
group.OnCheckChanged = function(self, value, checked) module.db.ignores[value] = checked end

local anchor = group[-1]
group = page:CreateMultiSelectionGroup(DL["spell cooldown monitor"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
local spell
for _, spell in ipairs(COOLDOWNS) do
	group:AddButton(format(DL["don't display"], spell), spell)
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
group = page:CreateMultiSelectionGroup(DL["display info"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(format(L["pestilence notify"], PESTILENCE), "pestilenceNotify")
group:AddButton(format(L["pestilence timeout notify"], PESTILENCE), "pestilenceTimeoutNotify")
group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end