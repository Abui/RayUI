------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-8-21
------------------------------------------------------------

local L = DPSCYCLE_WARLOCK_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2, 10) then
	error(string.format("[%s]: Version incompatible, requires DPSCycle v2.10 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "WARLOCK")
if not module then return end

local DEMON_SKIN = GetSpellInfo(687)
local DEMON_ARMOR = GetSpellInfo(706)
local FEL_ARMOR = GetSpellInfo(28176)
local IMMOLATE = GetSpellInfo(348)
local INCINERATE = GetSpellInfo(29722)
local SHADOW_BOLT = GetSpellInfo(686)
local UNSTABLE_AFFLICTION = GetSpellInfo(30108)
local HAUNT = GetSpellInfo(48181)
local CHAOS_BOLT = GetSpellInfo(50796)
local CONFLAGRATE = GetSpellInfo(17962)
local BACKLASH = GetSpellInfo(34935)
local NIGHTFALL = GetSpellInfo(18094)
local SHADOW_MEDITATION = GetSpellInfo(17941)
local CORRUPTION = GetSpellInfo(172)
local CURSE_OF_DOOM = GetSpellInfo(603)
local CURSE_OF_AGONY = GetSpellInfo(980)
local CURSE_OF_THE_ELEMENTS = GetSpellInfo(1490)
local CURSE_OF_TONGUES = GetSpellInfo(1714)
local CURSE_OF_WEAKNESS = GetSpellInfo(702)
local CURSE_OF_EXHAUSTION = GetSpellInfo(18223)
local LIFE_TAP = GetSpellInfo(1454)
local GLYPH_OF_CONFLAGRATE = GetSpellInfo(56270)
local GLYPH_OF_LIFE_TAP = GetSpellInfo(64248)
local DRAIN_SOUL = GetSpellInfo(1120)

local DEMON_SOUL = GetSpellInfo(77801)
local SOULBURN = GetSpellInfo(74434)
local HAND_OF_GULDAN = GetSpellInfo(71521)
local METAMORPHOSIS = GetSpellInfo(47241)
local MOLTEN_CORE = GetSpellInfo(71165)
local DECIMATION = GetSpellInfo(63167)
local SOUL_FIRE = GetSpellInfo(6353)

local SUMMON_DOOMGUARD = GetSpellInfo(18540)

local CURSES = { CURSE_OF_THE_ELEMENTS, CURSE_OF_TONGUES, CURSE_OF_WEAKNESS, CURSE_OF_EXHAUSTION }
local COOLDOWNS = {DEMON_SOUL, SOULBURN, METAMORPHOSIS, SUMMON_DOOMGUARD}

local debuffs = {}
local armors = {}
local hasGlyphOfConflagrate, immolateFakeExpires
local moltencore, moltencore_count, decimation

function module:OnInitialize(db, firstTime)	
	if firstTime then
		db.curse = CURSE_OF_THE_ELEMENTS
	end
	
	local spell
	for _, spell in ipairs(COOLDOWNS) do
		self:AddCooldownWatchSpell(spell)
	end
		
	self:RegisterUnitAura("player", BACKLASH)
	self:RegisterUnitAura("player", NIGHTFALL)
	self:RegisterUnitAura("player", SHADOW_MEDITATION)
	self:RegisterUnitAura("player", DEMON_SKIN)
	self:RegisterUnitAura("player", DEMON_ARMOR)
	self:RegisterUnitAura("player", FEL_ARMOR)
	self:RegisterUnitAura("player", MOLTEN_CORE)	
	self:RegisterUnitAura("player", DECIMATION)	
	self:RegisterUnitAura("target", IMMOLATE, 1, 1)
	self:RegisterUnitAura("target", CORRUPTION, 1, 1)
	-- self:RegisterUnitAura("target", HAUNT, 1, 1)
	self:RegisterUnitAura("target", UNSTABLE_AFFLICTION, 1, 1)
	self:RegisterUnitAura("target", CURSE_OF_DOOM, 1, 1)
	self:RegisterUnitAura("target", CURSE_OF_AGONY, 1, 1)	
	self:RegisterUnitAura("target", CURSE_OF_EXHAUSTION, 1)	
	self:RegisterUnitAura("target", CURSE_OF_WEAKNESS, 1)	
	self:RegisterUnitAura("target", CURSE_OF_TONGUES, 1)	
	self:RegisterUnitAura("target", CURSE_OF_THE_ELEMENTS, 1)
	
	self:RegisterSpellAsAura(CURSE_OF_DOOM, nil, "target", 1, 1)
	self:RegisterSpellAsAura(CURSE_OF_AGONY, nil, "target", 1, 1)
	self:RegisterSpellAsAura(CORRUPTION, nil, "target", 1, 1)
	self:RegisterSpellAsAura(UNSTABLE_AFFLICTION, nil, "target", 1, 1)
end

function module:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function module:OnPlayerGlyphsChanged()
	hasGlyphOfConflagrate = self:PlayerHasGlyph(GLYPH_OF_CONFLAGRATE)
	if hasGlyphOfConflagrate then
		self:RegisterSpellAsAura(IMMOLATE, nil, "target", 1, 1)
	else
		self:UnregisterSpellAsAura(IMMOLATE)
	end
end

function module:UNIT_SPELLCAST_SENT(unit, spell)
	if not hasGlyphOfConflagrate and unit == "player" and spell == CONFLAGRATE then
		debuffs[IMMOLATE] = nil
		immolateFakeExpires = nil
	end
end

function module:UNIT_SPELLCAST_START(unit, spell)
	if unit == "player" and spell == IMMOLATE then
		local _, _, _, _, _, endTime = UnitCastingInfo("player")
		if endTime then
			immolateFakeExpires = endTime / 1000 + 1
		end
	end
end

function module:UNIT_SPELLCAST_SUCCEEDED(unit, spell)
	if unit == "player" and spell == IMMOLATE then
		immolateFakeExpires = GetTime() + 1
	end
end

function module:OnUnitAuraApplied(unit, aura, rank, icon)
	if aura == BACKLASH or aura == NIGHTFALL or aura == SHADOW_MEDITATION then
		self:DisplayInfo(icon, string.format(DL["gained"], aura))
	elseif aura == MOLTEN_CORE then
		self:DisplayInfo(icon, string.format(DL["gained"], aura))
		moltencore = 1	
	elseif aura == DECIMATION then
		self:DisplayInfo(icon, string.format(DL["gained"], aura))
		decimation = 1
	elseif aura == HAUNT then
		self:RegisterSpellAsAura(HAUNT, nil, "target", 1, 1)
	end
end

function module:OnUnitAuraUpdated(unit, aura, rank, icon, count, dispelType, duration, expires)
	if aura == DEMON_SKIN or aura == DEMON_ARMOR or aura == FEL_ARMOR then
		armors[aura] = expires	
	elseif aura == MOLTEN_CORE then
		moltencore_count = count
	elseif unit == "target" then
		debuffs[aura] = expires
		if aura == IMMOLATE then
			immolateFakeExpires = nil
		end
	end
end

function module:OnUnitAuraRemoved(unit, aura)	
	if aura == DEMON_SKIN or aura == DEMON_ARMOR or aura == FEL_ARMOR then
		armors[aura] = nil
	elseif aura == MOLTEN_CORE then
		moltencore = nil
		moltencore_count = nil
	elseif aura == DECIMATION then
		decimation = 1
	elseif unit == "target" then
		debuffs[aura] = nil
		if aura == IMMOLATE then
			immolateFakeExpires = nil
		elseif aura == HAUNT then
			self:UnregisterSpellAsAura(HAUNT)
		end 
	end
end

function module:GetImmolateTime()
	local timeLeft = self:GetDebuffTime(IMMOLATE)
	if timeLeft then
		return timeLeft
	end

	if immolateFakeExpires then
		timeLeft = immolateFakeExpires - GetTime()
		if timeLeft > 0 then
			return timeLeft, 1
		else
			immolateFakeExpires = nil
		end
	end
end

function module:GetDebuffTime(debuff)
	if debuff then
		local expires = debuffs[debuff]
		if expires then
			return expires - GetTime() - 1
		end
	end
end

function module:GetCurse()
	local curse
	for _, curse in ipairs(CURSES) do
		local timeLeft = self:GetDebuffTime(curse)
		if timeLeft then
			return curse, timeLeft
		end
	end	
end

function module:ChooseCurse(isBoss)	
	if not isBoss then
		return
	end
	
	local curse = self.db.curse
	if not self:PlayerHasSpell(curse) then
		return
	end
	
	if curse == CURSE_OF_THE_ELEMENTS then
		if not UnitDebuff("target",GetSpellInfo(86105)) and not UnitDebuff("target",CURSE_OF_THE_ELEMENTS) then
			return CURSE_OF_THE_ELEMENTS
		end
	else
		local timeLeft = self:GetDebuffTime(curse)		
		return curse, timeLeft or 0
	end		
end

function module:AfflictionProc(isBoss)
	local sbCastTime = self:GetSpellCastTime(SHADOW_BOLT) or 2.5
	if sbCastTime == 0 then
		self:AddSequenceSpell(SHADOW_BOLT, 0)
	end

	local curse, timeLeft = self:ChooseCurse(isBoss)
	if curse then		
		self:AddSequenceSpell(curse, timeLeft)
	end

	self:AddSequenceSpell(HAUNT)
	self:AddSequenceSpell(CURSE_OF_DOOM, self:GetDebuffTime(CURSE_OF_DOOM) or 0)
	self:AddSequenceSpell(CORRUPTION, self:GetDebuffTime(CORRUPTION) or 0)
	self:AddSequenceSpell(UNSTABLE_AFFLICTION, self:GetDebuffTime(UNSTABLE_AFFLICTION) or 0)	
	if UnitHealth("target")/UnitHealthMax("target")<.25 then
		self:AddSequenceSpell(DRAIN_SOUL)	
	end
	self:CompleteSequence(SHADOW_BOLT, sbCastTime > 0 and sbCastTime or 2.5)
end

function module:DestructionProc(isBoss)
	local immolateCasting = self:GetSpellCastTime(IMMOLATE)
	local immoTime, isFake = self:GetImmolateTime()

	if hasGlyphOfConflagrate then
		if immoTime then
			if isFake then
				immoTime = immoTime + 13
			else
				immoTime = immoTime - 2
			end
		else
			immoTime = 0
		end
		self:AddSequenceSpell(IMMOLATE, immoTime, immolateCasting)		
	elseif not immoTime then
		self:AddSequenceSpell(IMMOLATE, 0, immolateCasting, 0)
	end

	local curse, timeLeft = self:ChooseCurse(isBoss)
	if curse then		
		self:AddSequenceSpell(curse, timeLeft)
	end

	if self.db.corruption then
		self:AddSequenceSpell(CORRUPTION, self:GetDebuffTime(CORRUPTION) or 0)
	end

	local cooldown = self:AddSequenceSpell(CONFLAGRATE)
	if not hasGlyphOfConflagrate then
		self:AddSequenceSpell(IMMOLATE, cooldown, immolateCasting)
	end
	
	self:AddSequenceSpell(CHAOS_BOLT)
	self:CompleteSequence(INCINERATE, self:GetSpellCastTime(INCINERATE) + 0.2, 0.6)
end

function module:DemonologyProc(isBoss)
	local sbCastTime = self:GetSpellCastTime(SHADOW_BOLT) or 2.5
	if sbCastTime == 0 then
		self:AddSequenceSpell(SHADOW_BOLT, 0)
	end
	
	local curse, timeLeft = self:ChooseCurse(isBoss)
	if curse then		
		self:AddSequenceSpell(curse, timeLeft)
	end

	self:AddSequenceSpell(IMMOLATE, self:GetDebuffTime(IMMOLATE) or 0)
	self:AddSequenceSpell(HAND_OF_GULDAN)
	self:AddSequenceSpell(CURSE_OF_DOOM, self:GetDebuffTime(CURSE_OF_DOOM) or 0)
	self:AddSequenceSpell(CORRUPTION, self:GetDebuffTime(CORRUPTION) or 0)
	if moltencore then
		for i=1,moltencore_count do
			self:AddSequenceSpell(INCINERATE)
		end
	end
	if decimation then
		self:AddSequenceSpell(SOUL_FIRE)
	end
	self:CompleteSequence(SHADOW_BOLT, sbCastTime > 0 and sbCastTime or 2.5)
end

function module:OnSpellRequest()	
	self:InitializeSequence()
	if not armors[FEL_ARMOR] and not armors[DEMON_ARMOR] and not armors[DEMON_SKIN] then
		local pickArmor = DEMON_SKIN
		if self:PlayerHasSpell(FEL_ARMOR) then
			pickArmor = FEL_ARMOR
		elseif self:PlayerHasSpell(DEMON_ARMOR) then
			pickArmor = DEMON_ARMOR
		end
		self:AddSequenceSpell(pickArmor, 0)
	end

	local isBoss = IsResting() or UnitClassification("target") == "worldboss"
	if self:GetTalentSpec() == 3 then
		self:DestructionProc(isBoss)
	elseif self:GetTalentSpec() == 2 then
		self:DemonologyProc(isBoss)
	else
		self:AfflictionProc(isBoss)
	end
	return self:GetSequenceSpells()
end

------------------------------------------------------
-- Option page
------------------------------------------------------

local page = module.optionPage
group = page:CreateSingleSelectionGroup(L["keep curse"])
group:SetPoint("TOPLEFT", 16, -70)
group:AddButton(NONE)
group:AddButton(CURSE_OF_THE_ELEMENTS, CURSE_OF_THE_ELEMENTS)
group:AddButton(CURSE_OF_TONGUES, CURSE_OF_TONGUES)
group.OnCheckInit = function(self, value) return module.db.curse == value end
group.OnSelectionChanged = function(self, value, checked) module.db.curse = value end

local anchor = group[-1]
group = page:CreateMultiSelectionGroup(DL["misc"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(string.format(L["keep corruption"], CORRUPTION), "corruption")
group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end