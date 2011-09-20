------------------------------------------------------------
-- Module.lua
--
-- Bash99 ( bash99@gmail.com)
-- 2009-11-15
------------------------------------------------------------

local L = DPSCYCLE_SHAMAN_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2) then
	error(string.format("[%s]: Version incompatible, requires DPSCycle v2.0 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "SHAMAN")
if not module then return end

local STORMSTRIKE = GetSpellInfo(32176)
local EARTH_SHOCK = GetSpellInfo(49231)
local LAVA_LASH = GetSpellInfo(60103)
local MAGMA_TOTEM = GetSpellInfo(58734)
local LIGHTNING_SHIELD = GetSpellInfo(49281)
local LIGHTNING_BOLT = GetSpellInfo(49238)
local CHAIN_LIGHTNING = GetSpellInfo(49271)
local MAELSTROM_WEAPON = GetSpellInfo(51532)
local WATER_SHIELD = GetSpellInfo(23575)

local HEROISM = GetSpellInfo(32182)
local BLOODLUST = GetSpellInfo(2825)
local FERAL_SPIRIT = GetSpellInfo(51533)
local FIRE_ELEMENTAL_TOTEM = GetSpellInfo(2894)
local SHAMANISTIC_RAGE = GetSpellInfo(30823)

local COOLDOWNS = { HEROISM, BLOODLUST, FERAL_SPIRIT, FIRE_ELEMENTAL_TOTEM, SHAMANISTIC_RAGE }

local buffs = {}

function module:OnInitialize(db, firstTime)
	if firstTime then
		db.magma_totem = 1
	end

	self:RegisterUnitAura("player", MAELSTROM_WEAPON)
	self:RegisterUnitAura("player", LIGHTNING_SHIELD)
	self:RegisterUnitAura("player", WATER_SHIELD)	
	self:RegisterUnitAura("target", STORMSTRIKE, 1, 1)

	if type(db.lightning) ~= "string" or (db.lightning ~= LIGHTNING_BOLT and db.lightning ~=CHAIN_LIGHTNING) then
		db.lightning = LIGHTNING_BOLT
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
	return self:GetTalentSpec() == 2
end

function module:OnUnitAuraUpdated(unit, aura, rank, icon, count, dispelType, duration, expires)	
	buffs[aura] = count
end

function module:OnUnitAuraRemoved(unit, aura)	
	buffs[aura] = nil
end

-- a simple one, only test a fire totem exists, cause if the team has only one shaman
-- he should drop the Flametongue Totem
function module:GetMagamTotemInfo()
    -- 1 is the fire totem index
	local haveTotem, totemName, startTime, duration = GetTotemInfo(1)
	return totemName, duration
end

function module:EnhancementProc()	
--	error(string.format("[%s]: EnhancementProc start!", L["title"]))
-- check buff for 5stacks lb

	if buffs[MAELSTROM_WEAPON] == 5 then
		self:AddSequenceSpell(self.db.lightning)
	end

	if buffs[STORMSTRIKE] then               
		self:AddSequenceSpell(EARTH_SHOCK)
		self:AddSequenceSpell(STORMSTRIKE)
	else
		self:AddSequenceSpell(STORMSTRIKE)
		self:AddSequenceSpell(EARTH_SHOCK)
	end

-- check manga totem
	
	if self.db.magma_totem == 1 then
		local haveTotem, duration = self:GetMagamTotemInfo()
		if haveTotem and duration < 1 then
			self:AddSequenceSpell(MAGMA_TOTEM)
		end
	end
	
	self:AddSequenceSpell(LAVA_LASH)
	
-- check buff for L S

	if not buffs[LIGHTNING_SHIELD] and not buffs[WATER_SHIELD] then
		self:AddSequenceSpell(LIGHTNING_SHIELD)
	end

end

function module:OnSpellRequest()
	self:InitializeSequence()
	self:EnhancementProc()
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


local anchor = group[-1]
group = page:CreateSingleSelectionGroup(L["lightning selection"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(LIGHTNING_BOLT, LIGHTNING_BOLT)
group:AddButton(CHAIN_LIGHTNING, CHAIN_LIGHTNING)
group.OnCheckInit = function(self, value) return module.db.lightning == value end
group.OnSelectionChanged = function(self, value) module.db.lightning = value end

anchor = group[-1]
group = page:CreateMultiSelectionGroup(DL["misc"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(string.format(DL["keep"], MAGMA_TOTEM), "magma_totem")
group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end