------------------------------------------------------------
-- Module.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

local L = DPSCYCLE_DRUID_LOCALE
local DL = DPSCYCLE_LOCALE

if not DPSCycle.CheckCompatibility or not DPSCycle:CheckCompatibility(2) then
	error(format("[%s]: Version incompatible, requires DPSCycle v2.0 or higher.", L["title"]))
	return
end

local module = DPSCycle:New(L["title"], "DRUID")
if not module then return end

local SAVAGE_ROAR = GetSpellInfo(52610)
local TIGERS_FURY = GetSpellInfo(5217)
local BERSERK = GetSpellInfo(50334)
local MANGLE_CAT = GetSpellInfo(33876)
local MANGLE_BEAR = GetSpellInfo(33986)
local FAERIE_FIRE_FERAL = GetSpellInfo(16857)
local RAKE = GetSpellInfo(1822)
local RIP = GetSpellInfo(1079)
local TRAUMA = GetSpellInfo(46854)
local THRED = GetSpellInfo(5221)
local FEROCIOUS_BITE = GetSpellInfo(22568)
local FAERIE_FIRE = GetSpellInfo(770)
local PROWL = GetSpellInfo(5215)
local ENRAGE = GetSpellInfo(5229)
local LACERATE = GetSpellInfo(33745)

local MOONFIRE = GetSpellInfo(8921)
local INSECT_SWARM = GetSpellInfo(24974)
local IMPROVED_INSECT_SWARM = GetSpellInfo(57849)
local WRATH = GetSpellInfo(5176)
local STARFIRE = GetSpellInfo(2912)
local INNERVATE = GetSpellInfo(29166)
local TYPHOON = GetSpellInfo(53223)
local STARFALL = GetSpellInfo(53199)
local FORCE_OF_NATURE = GetSpellInfo(33831)
local MOOKIN_FORM = GetSpellInfo(24858)
local ECLIPSE = GetSpellInfo(48516)
local IMPROVED_FAERIE_FIRE = GetSpellInfo(33600)
local OMEN_OF_CLARITY = GetSpellInfo(12536)

local COOLDOWNS = { TIGERS_FURY, BERSERK, INNERVATE, TYPHOON, STARFALL, FORCE_OF_NATURE }
local COMBO_COLORS = { { r = 0, g = 1, b = 0 }, { r = 0.5, g = 1, b = 0 }, { r = 1, g = 1, b = 0 }, { r = 1, g = 0.5, b = 0 }, { r = 1, g = 0, b = 0 } }
local ELIPSEHASCD = select(4, GetBuildInfo()) < 30300

local auras = {}
local hasEclipse, eclipseCD, eclipseType, r, g, b
local hasMookin, impFire, hasInsect, hasLacerate, lacerateCount, hasRoar, hasMangle, impInsect

function module:OnInitialize(db, firstTime)
	if type(db.ignores) ~= "table" then
		db.ignores = {}
	end

	local spell
	for _, spell in ipairs(COOLDOWNS) do
		if not db.ignores[spell] then
			self:AddCooldownWatchSpell(spell)
		end
	end

	self:RegisterUnitAura("player", PROWL)
	self:RegisterUnitAura("player", OMEN_OF_CLARITY)
	self:RegisterUnitAura("player", SAVAGE_ROAR)
	self:RegisterUnitAura("target", RAKE, 1, 1)
	self:RegisterUnitAura("target", RIP, 1, 1)
	self:RegisterUnitAura("target", MANGLE_CAT, 1)
	self:RegisterUnitAura("target", MANGLE_BEAR, 1)
	self:RegisterUnitAura("target", TRAUMA, 1)

	self:RegisterUnitAura("player", ECLIPSE)
	self:RegisterUnitAura("player", MOOKIN_FORM)
	self:RegisterUnitAura("target", FAERIE_FIRE, 1)
	self:RegisterUnitAura("target", MOONFIRE, 1, 1)
	self:RegisterUnitAura("target", INSECT_SWARM, 1, 1)

	self:RegisterUnitAura("target", LACERATE, 1, 1)
	self:RegisterSpellAsAura(LACERATE, nil, "target", 1, 1)
end

function module:OnEnable()
end

function module:OnDisable()
end

function module:OnPlayerSpellsChanged()
	hasMookin = self:PlayerHasSpell(MOOKIN_FORM)
	hasInsect = self:PlayerHasSpell(INSECT_SWARM)
	hasLacerate = self:PlayerHasSpell(LACERATE)
	hasRoar = self:PlayerHasSpell(SAVAGE_ROAR)
	hasMangle = self:PlayerHasSpell(MANGLE_CAT)
end

function module:OnPlayerTalentsChanged(spec, points)
	hasEclipse = self:GetTalentPoints(ECLIPSE) > 0
	impFire = self:GetTalentPoints(IMPROVED_FAERIE_FIRE) > 0
	impInsect = self:GetTalentPoints(IMPROVED_INSECT_SWARM) > 0
end

function module:OnUnitAuraApplied(unit, aura, rank, icon, count, dispelType, duration, expires)
	auras[aura] = expires
	if expires and aura == ECLIPSE then
		eclipseCD = expires + 15
		eclipseType = (icon == "Interface\\Icons\\Ability_Druid_Eclipse") and 1 or 2
		if eclipseType == 1 then
			r, g, b = 0, 1, 0
		else
			r, g, b = 1, 1, 0
		end

		self:DisplayInfo(icon, format(DL["gained"], ECLIPSE))
		if not self.db.noSound then
			PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav")
		end
	end
end

function module:OnUnitAuraUpdated(unit, aura, rank, icon, count, dispelType, duration, expires)
	auras[aura] = expires
	if aura == LACERATE then
		lacerateCount = count
	end
end

function module:OnUnitAuraRemoved(unit, aura)
	auras[aura] = nil
	if aura == LACERATE then
		lacerateCount = nil
	end
end

function module:OnCheckConditions()
	local spec = self:GetTalentSpec()
	local power = UnitPowerType("player")
	return (spec == 1 and power == 0) or (spec == 2 and power ~= 0)
end

function module:GetAuraTime(aura)
	local expires = auras[aura]
	if expires then
		return expires - GetTime()
	else
		return 0
	end
end

function module:UpdateEclipseTimer()
	if not hasEclipse then
		self:SetCountText()
		return
	end

	local timeLeft, cdTimeLeft
	local now = GetTime()
	local expires = auras[ECLIPSE]
	if expires then
		timeLeft = expires - now
		if timeLeft < 0 then
			timeLeft = nil
		end
	elseif eclipseCD then
		cdTimeLeft = eclipseCD - now
		if cdTimeLeft <= 0 then
			cdTimeLeft, eclipseCD = nil
		end
	end

	if self.db.noTimer then
		self:SetCountText()
	elseif timeLeft then
		self:SetCountText(format("%.1f", timeLeft), r, g, b)
	elseif cdTimeLeft and ELIPSEHASCD then
		self:SetCountText(format("%.1f", cdTimeLeft), 1, 0, 0)
	else
		self:SetCountText()
	end

	return timeLeft, cdTimeLeft
end

function module:NeedToCast(spell)
	return not auras[spell] and not self:WasSpellSent(spell, 2)
end

function module:BalanceProc()
	local timeLeft, cdTimeLeft = self:UpdateEclipseTimer()

	if hasMookin and not auras[MOOKIN_FORM] then
		return MOOKIN_FORM
	end

	if impFire and self:NeedToCast(FAERIE_FIRE) then
		return FAERIE_FIRE
	end

	local needMoonFire = self:NeedToCast(MOONFIRE)
	local needInsect = hasInsect and not self.db.noInsect and self:NeedToCast(INSECT_SWARM)

	if timeLeft then
		if impInsect and timeLeft > 5 then
			if eclipseType == 1 then
				if needMoonFire then
					return MOONFIRE
				end
			else
				if needInsect then
					return INSECT_SWARM
				end
			end
		end

		return eclipseType == 1 and STARFIRE or WRATH
	end

	if needMoonFire then
		return MOONFIRE
	end

	if needInsect then
		return INSECT_SWARM
	end

	if not hasEclipse then
		return STARFIRE
	end

	if not cdTimeLeft then
		return WRATH
	end

	if ELIPSEHASCD then
		return cdTimeLeft > 3.5 and STARFIRE or WRATH
	else
		return eclipseType == 1 and STARFIRE or WRATH
	end
end

function module:BearProc()
	local color = COMBO_COLORS[lacerateCount or 0]
	if color then
		self:SetCountText(lacerateCount, color.r, color.g, color.b)
	else
		self:SetCountText()
	end

	self:InitializeSequence()
	if UnitMana("player") < 15 and self:IsUsableSpell(ENRAGE, 1) then
		self:AddSequenceSpell(ENRAGE, 0)
	end

	local mangleCd = self:AddSequenceSpell(MANGLE_BEAR) or 100
	local lacerateTime = 0

	if hasLacerate then
		if lacerateCount == 5 then
			lacerateTime = self:GetAuraTime(LACERATE)
			self:AddSequenceSpell(LACERATE, lacerateTime - 6)
		else
			local i
			for i = lacerateCount or 0, 4 do
				self:AddSequenceSpell(LACERATE, 0)
			end
		end
	end

	if not hasLacerate or lacerateCount == 5 then
		self:AddSequenceSpell(FAERIE_FIRE_FERAL)
	end

	self:CompleteSequence()
	return self:GetSequenceSpells()
end

function module:CatProc()
	local comboPoints = GetComboPoints("player", "target") or 0
	local color = COMBO_COLORS[comboPoints]
	if color then
		self:SetCountText(comboPoints, color.r, color.g, color.b)
	else
		self:SetCountText()
	end

	local energy = UnitMana("player")
	if energy < 30 and self:IsUsableSpell(TIGERS_FURY, 1) then
		return TIGERS_FURY
	end

	local normal = IsResting() or UnitHealth("target") > 200000
	local roarTime = hasRoar and self:GetAuraTime(SAVAGE_ROAR) or 100
	local ripTime = normal and self:GetAuraTime(RIP) or 100
	local needRake = normal and not auras[RAKE]
	local needMangle = hasMangle and not auras[MANGLE_CAT] and not auras[MANGLE_BEAR] and not auras[TRAUMA]

	if comboPoints < 5 then -- 0/1/2/3/4
		if roarTime < 3 and comboPoints > 0 then
			return SAVAGE_ROAR
		elseif auras[OMEN_OF_CLARITY] then
			return needMangle and MANGLE_CAT or THRED
		elseif needMangle then
			return MANGLE_CAT
		elseif needRake then
			return RAKE
		else
			return THRED
		end
	else -- 5
		if roarTime > 8 and ripTime > 8 then
			return FEROCIOUS_BITE
		else
			return roarTime < ripTime and SAVAGE_ROAR or RIP
		end
	end
end

function module:OnSpellRequest()
	if self:GetTalentSpec() == 1 then
		return self:BalanceProc()
	elseif UnitPowerType("player") == 1 then
		return self:BearProc()
	else
		return self:CatProc()
	end
end

------------------------------------------------------
-- Option page
------------------------------------------------------

local page = module.optionPage

local group = page:CreateMultiSelectionGroup(DL["spell cooldown monitor"])
group:SetPoint("TOPLEFT", 16, -70)
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

local anchor = group[-1]
group = page:CreateMultiSelectionGroup(L["balance"])
group:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
group:AddButton(format(L["no eclipse timer"], ECLIPSE), "noTimer")
group:AddButton(format(L["no eclipse sound"], ECLIPSE), "noSound")
group:AddButton(format(DL["don't suggest"], INSECT_SWARM), "noInsect")

group.OnCheckInit = function(self, value) return module.db[value] end
group.OnCheckChanged = function(self, value, checked) module.db[value] = checked end