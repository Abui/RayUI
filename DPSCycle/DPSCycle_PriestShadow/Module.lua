------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

local L = DPSCYCLE_PRIESTSHADOW_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2, 10) then
	error(string.format("[%s]: Version incompatible, requires DPSCycle v2.10 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "PRIEST")
if not module then return end

local SHADOWFORM = GetSpellInfo(15473)
local SHADOW_WORD_PAIN = GetSpellInfo(589)
local MIND_BLAST = GetSpellInfo(8092)
local DEVOURING_PLAGUE = GetSpellInfo(2944) 
local MIND_FLAY = GetSpellInfo(15407)
local VAMPIRIC_TOUCH = GetSpellInfo(34916)
local SHADOW_WORD_DEATH = GetSpellInfo(32379)
local SHADOW_FIEND = GetSpellInfo(34433)
local DISPERSION = GetSpellInfo(47585)
local FADE = GetSpellInfo(586)
local SHADOW_WEAVING = GetSpellInfo(15257)

local COOLDOWNS = { FADE, DISPERSION, SHADOW_FIEND }
local COUNTCOLORS = { { r = 1, g = 0, b = 0 }, { r = 1, g = 1, b = 0 }, { r = 0, g = 1, b = 0 } }
local VER30200 = select(4, GetBuildInfo()) >= 30200

local debuffs = {}
local mfCount = 0
local shadowWavingCount

function module:OnInitialize(db, firstTime)
	if firstTime then
		db.mfTick = 1
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

	self:RegisterUnitAura("player", SHADOW_WEAVING, nil, 1)
	self:RegisterUnitAura("target", SHADOW_WORD_PAIN, 1, 1)
	self:RegisterUnitAura("target", VAMPIRIC_TOUCH, 1, 1)	

	self:RegisterSpellAsAura(SHADOW_WORD_PAIN, nil, "target", 1, 1)
	self:RegisterSpellAsAura(VAMPIRIC_TOUCH, nil, "target", 1, 1)

	if VER30200 then
		self:RegisterUnitAura("target", DEVOURING_PLAGUE, 1, 1)
		self:RegisterSpellAsAura(DEVOURING_PLAGUE, nil, "target", 1, 1)
	end
end

function module:OnEnable()
	self:UpdateMindFlayCount(0)
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function module:OnUnitAuraUpdated(unit, aura, rank, icon, count, dispelType, duration, expires)
	if aura == SHADOW_WEAVING then
		shadowWavingCount = count
	elseif unit == "target" then
		debuffs[aura] = expires
	end
end

function module:OnUnitAuraRemoved(unit, aura)
	if aura == SHADOW_WEAVING then
		shadowWavingCount = nil
	elseif unit == "target" then
		debuffs[aura] = nil
	end
end

function module:OnCheckConditions()
	return self:GetTalentSpec() == 3 -- Must be a shadow priest!
end

function module:UpdateMindFlayCount(count)
	mfCount = count or 0
	local color = COUNTCOLORS[mfCount]
	if color and self.db.mfTick then
		self:SetCountText(mfCount, color.r, color.g, color.b)
	else
		self:SetCountText()
	end
end

function module:UNIT_SPELLCAST_CHANNEL_START(unit, spell)
	if unit == "player" and spell == MIND_FLAY then
		self:UpdateMindFlayCount(3)
	end
end

function module:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell)
	if unit == "player" and spell == MIND_FLAY then
		self:UpdateMindFlayCount(0)
	end
end

function module:COMBAT_LOG_EVENT_UNFILTERED(_, flag, source, srcName, _, _, _, _, _, spell, ...)
	if source == UnitGUID("player") and (flag == "SPELL_DAMAGE" or flag == "SPELL_MISSED") and spell == MIND_FLAY then
		self:UpdateMindFlayCount(mfCount - 1)
	end
end

function module:GetDebuffTime(debuff)	
	local expires = debuffs[debuff]
	return expires and (expires - GetTime()) or 0	
end

function module:OnSpellRequest()
	self:InitializeSequence()	

	if shadowWavingCount == 5 then
		self:AddSequenceSpell(SHADOW_WORD_PAIN, self:GetDebuffTime(SHADOW_WORD_PAIN))
	end

	self:AddSequenceSpell(VAMPIRIC_TOUCH, self:GetDebuffTime(VAMPIRIC_TOUCH))
	self:AddSequenceSpell(MIND_BLAST)

	if VER30200 then
		self:AddSequenceSpell(DEVOURING_PLAGUE, self:GetDebuffTime(DEVOURING_PLAGUE))
	else
		self:AddSequenceSpell(DEVOURING_PLAGUE)
	end	

	if self.db.death and UnitHealth("player") / UnitHealthMax("player") > 0.75 then
		self:AddSequenceSpell(SHADOW_WORD_DEATH)
	end

	self:CompleteSequence(MIND_FLAY, self:GetSpellCastTime(MIND_FLAY, 3), 1)
	return self:GetSequenceSpells()
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

local anchor = group[-1]
group = page:CreateMultiSelectionGroup(DL["misc"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(string.format(DL["enable"], SHADOW_WORD_DEATH), "death")
group:AddButton(string.format(L["display MF tick count"], MIND_FLAY), "mfTick")
group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end