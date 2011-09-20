------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-9-02
------------------------------------------------------------

local L = DPSCYCLE_WARRIOR_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2, 10) then
	error(format("[%s]: Version incompatible, requires DPSCycle v2.10 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "WARRIOR")
if not module then return end

local HERORIC_STRIKE = GetSpellInfo(78)
local SUNDER_ARMOR = GetSpellInfo(7386)
local OVERPOWER = GetSpellInfo(7384)
local EXECUTE = GetSpellInfo(5308)
local REND = GetSpellInfo(772)
local MORTAL_STRIKE = GetSpellInfo(21551)
local SLAM = GetSpellInfo(1464)
local BLOODTHIRST = GetSpellInfo(23881)
local WHIRLWIND = GetSpellInfo(1680)
local INSTANT_SLAM = GetSpellInfo(46916)
local BLOODRAGE = GetSpellInfo(2687)
local SHIELD_SLAM = GetSpellInfo(23922)
local REVENGE = GetSpellInfo(6572)
local DEVASTATE = GetSpellInfo(20243)
local VICTORY_RUSH = GetSpellInfo(34428)
local CHARGE = GetSpellInfo(100)
local INTERCEPT = GetSpellInfo(20252)

local SHIELD_WALL = GetSpellInfo(871)
local SHIELD_BLOCK = GetSpellInfo(2565)
local LAST_STAND = GetSpellInfo(12975)
local SHOCKWAVE = GetSpellInfo(46968)
local CONCUSSION_BLOW = GetSpellInfo(12809)
local BLADESTORM = GetSpellInfo(46924)
local SWEEPING_STRIKES = GetSpellInfo(12328)
local RECKLESSNESS = GetSpellInfo(1719)
local DEATH_WISH = GetSpellInfo(12292)

local COOLDOWNS = { BLADESTORM, SWEEPING_STRIKES, RECKLESSNESS, DEATH_WISH, SHIELD_WALL, LAST_STAND, SHIELD_BLOCK, SHOCKWAVE, CONCUSSION_BLOW }

local debuffs = {}
local sunderArmorId

function module:OnInitialize(db, firstTime)
	if type(db.hsRage) ~= "number" then
		db.hsRage = nil
	end

	local spell
	for _, spell in ipairs(COOLDOWNS) do
		self:AddCooldownWatchSpell(spell)
	end
	
	self:RegisterUnitAura("player", INSTANT_SLAM)	
	self:RegisterUnitAura("target", REND, 1, 1)	
end

function module:OnPlayerSpellsChanged()
	sunderArmorId = self:PlayerHasSpell(SUNDER_ARMOR)
end

function module:OnUnitAuraApplied(unit, aura, rank, icon, count, dispelType, duration, expires, caster)
	debuffs[aura] = 1
	if aura == INSTANT_SLAM then
		self:DisplayInfo(icon, format(DL["gained"], aura))	
	end
end

function module:OnUnitAuraRemoved(unit, aura)
	debuffs[aura] = nil
end

function module:NeedHS(rage)
	return self.db.hsRage and self.db.hsRage <= rage and not IsCurrentSpell(HERORIC_STRIKE)
end

function module:ArmsProc(rage)
	if self:IsUsableSpell(OVERPOWER) then
		return OVERPOWER
	end
	
	if not debuffs[REND] then
		return REND
	end

	if self:IsUsableSpell(EXECUTE) then
		return EXECUTE
	end

	if rage > 60 and self:IsUsableSpell(MORTAL_STRIKE, 1) then
		return MORTAL_STRIKE		
	end
	
	if self:NeedHS(rage) then
		return HERORIC_STRIKE
	end

	return SLAM
end

function module:FuryProc(rage)
	local bt, _, btTime = self:IsUsableSpell(BLOODTHIRST, 1)
	local ww, _, wwTime = self:IsUsableSpell(WHIRLWIND, 1)

	if bt then
		return BLOODTHIRST
	end

	if ww then
		return WHIRLWIND
	end	

	if self:IsUsableSpell(EXECUTE) then
		return EXECUTE
	end

	if self:NeedHS(rage) then
		return HERORIC_STRIKE
	end

	if not btTime then
		btTime = 10
	end

	if not wwTime then
		wwTime = 10
	end
	
	if btTime > 1.3 and wwTime > 1.3 and debuffs[INSTANT_SLAM] then
		return SLAM
	end

	return btTime > wwTime and WHIRLWIND or BLOODTHIRST
end

function module:ProtectionProc(rage)
	if self:IsUsableSpell(SHIELD_SLAM, 1) then
		return SHIELD_SLAM
	end

	if self:IsUsableSpell(REVENGE, 1) then
		return REVENGE
	end

	if self:NeedHS(rage) then
		return HERORIC_STRIKE
	end

	return self:IsUsableSpell(DEVASTATE) and DEVASTATE or SUNDER_ARMOR
end

function module:OnSpellRequest()
	local rage = UnitMana("player")
	if rage < 10 and self:IsUsableSpell(BLOODRAGE, 1) then
		return BLOODRAGE
	end		

	if sunderArmorId and IsSpellInRange(sunderArmorId, BOOKTYPE_SPELL) == 0 and not self:WasSpellSent(CHARGE, 3) and not self:WasSpellSent(INTERCEPT, 3) then
		if self:IsUsableSpell(CHARGE, 1) then
			return CHARGE
		end

		if self:IsUsableSpell(INTERCEPT, 1, 1) then
			return INTERCEPT
		end
	end
	
	if self:IsUsableSpell(VICTORY_RUSH) then
		return VICTORY_RUSH
	end
	
	local spec = self:GetTalentSpec()	
	if spec == 2 then
		return self:FuryProc(rage)
	elseif spec == 3 then
		return self:ProtectionProc(rage)
	else
		return self:ArmsProc(rage)
	end
end

------------------------------------------------------
-- Option page
------------------------------------------------------

local page = module.optionPage
group = page:CreateSingleSelectionGroup(format(DL["suggest"]..":", HERORIC_STRIKE))
group:SetPoint("TOPLEFT", 16, -70)
group:AddButton(NEVER)
group:AddButton(format("%d+ %s", 50, RAGE), 50)
group:AddButton(format("%d+ %s", 60, RAGE), 60)
group:AddButton(format("%d+ %s", 70, RAGE), 70)
group:AddButton(format("%d+ %s", 80, RAGE), 80)
group.OnCheckInit = function(self, value) return module.db.hsRage == value end
group.OnSelectionChanged = function(self, value) module.db.hsRage = value end