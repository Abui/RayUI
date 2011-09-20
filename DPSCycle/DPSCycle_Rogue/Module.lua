------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

local L = DPSCYCLE_ROGUE_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2) then
	error(format("[%s]: Version incompatible, requires DPSCycle v2.0 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "ROGUE")
if not module then return end

local STEALTH = GetSpellInfo(1784)
local SLICE_AND_DICE = GetSpellInfo(5171)
local RUPTURE = GetSpellInfo(1943)
local EVISCERATE = GetSpellInfo(2098) 
local GARROTE = GetSpellInfo(703)
local SINISTER_STRIKE = GetSpellInfo(1752)
local KICK = GetSpellInfo(1766)
local CLOAK_OF_SHADOWS = GetSpellInfo(31224)
local RIPOSTE = GetSpellInfo(14251)
local BLADE_FLURRY = GetSpellInfo(13877)
local ADRENALINE_RUSH = GetSpellInfo(13750)
local KILLING_SPREE = GetSpellInfo(51690)
local MANGLE_CAT = GetSpellInfo(33876)
local MANGLE_BEAR = GetSpellInfo(33986)
local TRAUMA = GetSpellInfo(46854)
local VANISH = GetSpellInfo(1856)
local EVASION = GetSpellInfo(5277)
local COLD_BLOOD = GetSpellInfo(14177)
local MULTILATE = GetSpellInfo(34411)
local HUNGER_FOR_BLOOD = GetSpellInfo(51662)
local ENVENOM = GetSpellInfo(32645)

local COOLDOWNS = { KICK, VANISH, EVASION, CLOAK_OF_SHADOWS, BLADE_FLURRY, ADRENALINE_RUSH, KILLING_SPREE, COLD_BLOOD }
local COMBO_COLORS = { { r = 0, g = 1, b = 0 }, { r = 0.5, g = 1, b = 0 }, { r = 1, g = 1, b = 0 }, { r = 1, g = 0.5, b = 0 }, { r = 1, g = 0, b = 0 } };

local auras = {}
local hasAT -- ash tongue trinket
local hasBleedAmp, hasHFB, hasEnvenom
local comboPoints = 0

function module:OnInitialize(db, firstTime)	
	if firstTime then
		db.rupture = 2
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

	self:RegisterUnitAura("player", STEALTH)
	self:RegisterUnitAura("player", SLICE_AND_DICE)
	self:RegisterUnitAura("player", HUNGER_FOR_BLOOD)
	self:RegisterUnitAura("player", ADRENALINE_RUSH)
	self:RegisterUnitAura("player", ENVENOM)
	self:RegisterUnitAura("target", RUPTURE, 1, 1)
	self:RegisterUnitAura("target", MANGLE_BEAR, 1)
	self:RegisterUnitAura("target", MANGLE_CAT, 1)
	self:RegisterUnitAura("target", TRAUMA, 1)
end

function module:OnEnable()
	self:RegisterEvent("UNIT_COMBO_POINTS")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UNIT_COMBO_POINTS("player")
	self:PLAYER_EQUIPMENT_CHANGED()
end

function module:OnDisable()
end

function module:OnPlayerSpellsChanged()
	hasHFB = self:PlayerHasSpell(HUNGER_FOR_BLOOD)
	hasEnvenom = self:PlayerHasSpell(ENVENOM)
end

function module:OnUnitAuraApplied(unit, aura, rank, icon, count, dispelType, duration, expires)
	auras[aura] = expires
	if not hasBleedAmp then
		hasBleedAmp = auras[MANGLE_BEAR] or auras[MANGLE_CAT] or auras[TRAUMA]
	end
end

function module:OnUnitAuraUpdated(unit, aura, rank, icon, count, dispelType, duration, expires)
	auras[aura] = expires	
end

function module:OnUnitAuraRemoved(unit, aura)
	auras[aura] = nil
	if hasBleedAmp then
		hasBleedAmp = auras[MANGLE_BEAR] or auras[MANGLE_CAT] or auras[TRAUMA]
	end
end

function module:GetAuraTime(aura)
	local expires = auras[aura]
	return expires and (expires - GetTime()) or 0
end

function module:PLAYER_EQUIPMENT_CHANGED()
	hasAT = nil
	local trinket = GetInventoryItemLink("player", 13)
	if trinket then
		local _, _, id = strfind(trinket, "item:(%d+)")
		if id == "32492" then
			hasAT = 13
		end
	end

	if not hasAT then
		trinket = GetInventoryItemLink("player", 14)
		if trinket then
			local _, _, id = strfind(trinket, "item:(%d+)")
			if id == "32492" then
				hasAT = 14
			end
		end
	end
end

function module:UNIT_COMBO_POINTS(unit)
	if unit == "player" then
		comboPoints = GetComboPoints("player", "target") or 0
		local color = COMBO_COLORS[comboPoints]
		if color then
			self:SetCountText(comboPoints, color.r, color.g, color.b)
		else
			self:SetCountText()
		end
	end
end

function module:PLAYER_TARGET_CHANGED()
	self:UNIT_COMBO_POINTS("player")
end

function module:OnCheckConditions()
	return self:GetTalentSpec() ~= 3 -- Subtlety rogue? Go have your own fun in PVP!
end

function module:NeedRuptrue()
	return self.db.rupture and not auras[RUPTURE] and (self.db.rupture == 1 or hasBleedAmp)
end

function module:AssassinationProc()
	if hasHFB then
		local hfbTime = self:GetAuraTime(HUNGER_FOR_BLOOD)		
		if self:WasSpellSent(GARROTE, 2) or self:WasSpellSent(RUPTURE, 2) or self:IsUsableSpell(HUNGER_FOR_BLOOD) then
			if hfbTime < 1.5 then
				return HUNGER_FOR_BLOOD
			end
		elseif hfbTime < 5 then
			if auras[STEALTH] then
				return GARROTE
			elseif comboPoints > 0 then
				return RUPTURE -- Apply a bleeding debuff to enable Hunger for Blood!
			end 
		end		
	end

	local canEnvenom = hasEnvenom and self:IsUsableSpell(ENVENOM)

	if comboPoints > 0 then
		local snd = self:GetAuraTime(SLICE_AND_DICE)
		if snd < 0.6 then
			return SLICE_AND_DICE
		elseif snd < 3 then
			return canEnvenom and ENVENOM or EVISCERATE
		end
	end
	
	local energyFull = UnitMana("player") > 60

	if canEnvenom then
		local needEnvenom = self:GetAuraTime(ENVENOM) < 1

		if comboPoints < 3 then -- 0/1/2
			return MULTILATE
		elseif comboPoints == 3 then -- 3
			if needEnvenom and self.db.keepEnvenim then
				return ENVENOM
			else
				return MULTILATE
			end
		else -- 4/5
			if self:NeedRuptrue() then
				if energyFull then
					return RUPTURE
				end
			else
				if needEnvenom or energyFull then
					return ENVENOM
				end
			end
		end
	else
		if comboPoints < 4 then
			return MULTILATE
		else
			if energyFull then
				return self:NeedRuptrue() and RUPTURE or EVISCERATE
			end
		end
	end	
end

function module:CombatProc()
	if auras[STEALTH] then
		return GARROTE
	end

	if comboPoints > 0 and self:GetAuraTime(SLICE_AND_DICE) < 1 then
		return SLICE_AND_DICE	
	end	

	if comboPoints < 5 then		
		return SINISTER_STRIKE
	end

	if not hasAT or UnitMana("player") > 50 or auras[ADRENALINE_RUSH] then	
		return self:NeedRuptrue() and RUPTURE or EVISCERATE
	end		
end

function module:OnSpellRequest()
	if self:GetTalentSpec() == 1 then
		return self:AssassinationProc()
	else
		return self:CombatProc()
	end	
end

------------------------------------------------------
-- Option page
------------------------------------------------------

local page = module.optionPage

local group = page:CreateSingleSelectionGroup(format(DL["keep"], RUPTURE)..":")
group:SetPoint("TOPLEFT", 16, -70)
group:AddButton(L["always"], 1)
group:AddButton(L["never"])
group:AddButton(L["only with bleeding amplify debuffs"], 2)
group.OnCheckInit = function(self, value) return module.db.rupture == value end
group.OnSelectionChanged = function(self, value) module.db.rupture = value end

local anchor = group[-1]
group = page:CreateMultiSelectionGroup(L["assassination"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(format(L["allow 3-combo"], ENVENOM), "keepEnvenim")
group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end