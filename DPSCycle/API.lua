------------------------------------------------------------
-- API.lua
--
-- Abin
-- 2009-6-18
--
--Fix for CTM by Ray
-- 2011-9-20
------------------------------------------------------------

local L = DPSCYCLE_LOCALE
local DPSCYCLE_METHODS = { "CurrentSpell", "GetTalentSpec", "GetTalentPoints", "PlayerHasSpell", "PlayerHasGlyph", "IsUsableSpell", "WasSpellSent",
	"GetLastSentSpell", "UnitAura", "PlayerBuff", "PlayerDebuff", "TargetBuff", "TargetDebuff", "UnitAuraTime", "PlayerBuffTime", "PlayerDebuffTime",
	"TargetBuffTime", "TargetDebuffTime", "GetSpellCastTime", "GetGCD" }
local MODULE_METHODS = { "IsEnabled", "SetCountText", "DisplayInfo", "AddCooldownWatchSpell", "RemoveCooldownWatchSpell",
			"RegisterEvent", "UnregisterEvent", "IsEventRegistered", "RegisterAllEvents", "UnregisterAllEvents",
			"InitializeSequence", "AddSequenceSpell", "CompleteSequence", "GetSequenceSpells", "IsSequenceCompleted",
			"RegisterSpellAsAura", "UnregisterSpellAsAura", "UnregisterAllSpellsAsAura",
			"RegisterUnitAura", "UnregisterUnitAura", "UnregisterAllUnitAuras" }

local type = type
local error = error
local format = format
local strtrim = strtrim
local strupper = strupper
local select = select
local UnitClass = UnitClass
local CreateFrame = CreateFrame
local ipairs = ipairs
local GetSpellCooldown = GetSpellCooldown
local GetTime = GetTime
local IsUsableSpell = IsUsableSpell
local IsSpellInRange = IsSpellInRange
local GetSpellInfo = GetSpellInfo
local UnitAura = UnitAura
local max = max
local tremove = tremove
local wipe = wipe
local tinsert = tinsert
local tremove = tremove
local strlower = strlower
local pairs = pairs

-------------------------------------------------------------------------------------
-- module = DPSCycle:New("name", "class" [, desc])

-- Create a new module for DPSCycle
--
-- name [STRING] - Name of the module, must be unique among all registered modules
-- class [STRING] - Required class(upper-case English), the function returns nil if the player class does not match
-- desc [nil, STRING] -- Description text to display on the option page of this module, can be any texts
--
-- Callback functions: -- The following functions are user-defined and will be called automatically, you need to define at least
--                        module:OnSpellRequest() to make the module meaningful. You should never call any of them in your code!
--
-- module:OnInitialize(db, firstTime) -- Called after the "VARIABLES_LOADED" event fires, "db" is a table where you should store your module's
--                            persistent data(it is not necessary to have a "SavedVariables" field in your module's TOC file), "firstTime" is 1 or nil
--                            which indicates whether it's the first time this player uses this module. You may also access this table via "module.db".
--                            At this moment the player data such as spells or talents are not ready yet. This is where you should do one-time
--                            initialization only.

-- module:OnEnable() -- Called after the module has been selected(activated), this is where you prepare your module and make it ready to work.

-- module:OnDisable() -- Called after the module has been deselected(deactiated), this is where you should cleanup all game resources
--                       that were occupied. module:UnregisterAllEvents() is automatically called.

-- module:OnCheckConditions() -- Called when the framework needs to decide whether to display the spell button, if you return nil or false,
--                               the spell button will be hidden. This is useful for hiding the addon in situations such as the player is in
--                               wrong shapeshift form, or does not have required talent spec etc.

-- module:OnShow() -- Called after the DPSCycle main button shows up.

-- module:OnHide() -- Called after the DPSCycle main button hides.

-- module:OnSpellRequest() -- Called when a spell suggestion is requested, must return a spell name(string) for DPSCycle GUI to display
--                            a spell. In addition, if you want to display the 2nd and 3rd spell icons as a "spell sequence forecst", you
--                            will have to return the 2nd and 3rd spell names as well.
--                            For example, (return "Fireball", "Forst Bolt", "Arcane Missiles") will make the main icon display Fireball,
--                            the 2nd icon display Forst Bolt and the 3rd icon display Arcane Missiles.

-- module:OnPlayerSpellsChanged() -- Called when the player's spells are changed, also called when module is selected
--
-- module:OnPlayerTalentsChanged(spec, points) -- Called when the player's talents are changed, also called when module is selected
--
-- module:OnPlayerGlyphsChanged() -- Called when the player's glyphs are changed, also called when module is selected

-- module:OnUnitAuraApplied(unit, aura, rank, icon, count, dispelType, duration, expires, caster, isStealable) -- Called when an registered aura is applied to the unit

-- module:OnUnitAuraUpdated(unit, aura, rank, icon, count, dispelType, duration, expires, caster, isStealable) -- Called when an registered aura on the unit is updated

-- module:OnUnitAuraRemoved(unit, aura, rank, icon) -- Called when an registered aura disappears from the unit

-- After calling DPSCycle:New() successfully, a new module has been created and registered to DPSCycle, in order to make
-- it work, the player needs to goto the "DPS Cycle" option page to select(activate) this module, once it's done, the addon will
-- start requesting suggestions from this module by calling module:OnSpellRequest() whenever needed.

-- An option page for this new module has also been created and injected to Blizzard's InterfaceOptions UI panel(under "DPS Cycle" category),
-- a handle of this option page is saved in "module.optionPage", you may create any extra option items on it, it's privately yours.
-------------------------------------------------------------------------------------
function DPSCycle:New(name, class, desc)

	if type(name) ~= "string" then
		error(format("bad argument #1 to 'DPSCycle:New' (string expected, got %s)", type(name)))
		return
	end

	name = strtrim(name)
	if name == "" or name == NONE or name == L["title"] or self.modules[name] then
		error(format("bad argument #1 to 'DPSCycle:New' (module '%s' already exists or the name is reserved)", name))
		return
	end

	if type(class) ~= "string" then
		error(format("bad argument #2 to 'DPSCycle:New' (string expected, got %s)", type(class)))
		return
	else
		local up = strupper(class)
		if not RAID_CLASS_COLORS[up] then
			error(format("bad argument #2 to 'DPSCycle:New' (invalid class: %s)", class))
			return
		end

		if up ~= select(2, UnitClass("player")) then
			return
		end
	end

	local module = { name = name, class = class, desc = desc, db = {}, cooldownSpells = {}, sequence = {}, auraSpells = {}, registeredAuras = {} }

	module.optionPage = self.optionPage:CreateModuleOptionPage(name, desc or format(L["module sub title"], name))

	local moduleFrame = CreateFrame("Frame")
	module.moduleFrame = moduleFrame
	moduleFrame:Hide()
	moduleFrame.parent = module
	moduleFrame.events = {}
	moduleFrame:SetScript("OnEvent", self.__ModuleFrame_OnEvent)

	local method
	for _, method in ipairs(DPSCYCLE_METHODS) do
		module[method] = self[method]
	end

	for _, method in ipairs(MODULE_METHODS) do
		module[method] = self["Module_"..method]
	end

	self.modules[name] = module

	self:InitializeModule(module)
	if not self.firstModule then
		self.firstModule = module
	end

	return module
end

-------------------------------------------------------------------------------------
-- DPSCycle:GetVersion()

-- Retrieves DPSCycle core version (string)
-------------------------------------------------------------------------------------
function DPSCycle:GetVersion()
	return DPSCycle.version, DPSCycle.major, DPSCycle.minor
end

-------------------------------------------------------------------------------------
-- DPSCycle:CheckCompatibility(major [, minor])

-- Checks whether DPSCycle meets the version requirements specified by major and minor
-------------------------------------------------------------------------------------
function DPSCycle:CheckCompatibility(major, minor)
	if type(major) ~= "number" or major < DPSCycle.major then
		return true
	end

	if major > DPSCycle.major then
		return false
	end

	-- major equal, check minor
	return type(minor) ~= "number" or minor <= DPSCycle.minor
end


-------------------------------------------------------------------------------------
-- module:GetTalentSpec()

-- Retrieves index of the talent tab in which the player has spent the most points
-------------------------------------------------------------------------------------
DPSCycle.GetTalentSpec = function(self)
	return DPSCycle.talentSpec, DPSCycle.talentSpecPoints
end

-------------------------------------------------------------------------------------
-- module:GetTalentPoints("name" [, isPet])

-- Retrieves points the player has spent on a particular talent
-------------------------------------------------------------------------------------
DPSCycle.GetTalentPoints = function(self, name, isPet)
	if type(name) ~= "string" then
		return 0
	end

	local list = isPet and DPSCycle.petTalentList or DPSCycle.playerTalentList
	return list[name] or 0
end

-------------------------------------------------------------------------------------
-- module:PlayerHasSpell("name" [, isPet])

-- Queries a book spell id from a spell name, it's really funny that Blizzard doesn't
-- provide this function by themselves...
-------------------------------------------------------------------------------------
DPSCycle.PlayerHasSpell = function(self, name, isPet)
	if type(name) == "string" then
		local list = isPet and DPSCycle.petSpellList or DPSCycle.playerSpellList
		return list[name]
	end
end

-------------------------------------------------------------------------------------
-- module:PlayerHasGlyph("name")

-- Checks whether the player has the specified glyph inscribed
-------------------------------------------------------------------------------------
DPSCycle.PlayerHasGlyph = function(self, name)
	if type(name) == "string" then
		return DPSCycle.glyphList[name]
	end
end

-------------------------------------------------------------------------------------
-- module:IsUsableSpell("name", checkCooldown, checkMana, checkRange, isPet)

-- Checks whether a spell is usable at the moment, returns spell id if the spell is usable,
-- or nil if it's unavailable, in which case the 2nd return value indicates the error types:
-- nil: Invalid spell name
-- 1: Spell is in cooldown, the 3rd return value is time left of the cooldown, in seconds
-- 2: Spell is not castable
-- 3: Out of mana
-- 4: Out of range
-------------------------------------------------------------------------------------
DPSCycle.IsUsableSpell = function(self, name, checkCooldown, checkMana, checkRange, isPet)
	local id = self:PlayerHasSpell(name, isPet)
	if not id then
		return
	end

	local bookType = isPet and BOOKTYPE_PET or BOOKTYPE_SPELL
	if checkCooldown then
		local start, duration = GetSpellCooldown(id, bookType)
		if start and duration and duration > 1.5 then
			local timeLeft = duration - GetTime() + start
			if timeLeft > 0 then
				return nil, 1, timeLeft, start, duration
			end
		end
	end

	local usable, oom = IsUsableSpell(id, bookType)
	if not usable then
		if not oom then
			return nil, 2
		elseif checkMana then
			return nil, 3
		end
	end

	if checkRange then
		if IsSpellInRange(id, bookType) == 0 then
			return nil, 4
		end
	end

	return id
end

-------------------------------------------------------------------------------------
-- module:GetSpellCastTime("name", useRecord)

-- Returns casting or channeling time of a spell, if useRecord is specified, DPSCycle searches internal
-- records if it was previously cast, if not found and type of useRecord is number, it returns useRecord.
-------------------------------------------------------------------------------------
DPSCycle.GetSpellCastTime = function(self, name, useRecord)
	local id = DPSCycle:PlayerHasSpell(name)
	if id then
		local castTime
		if useRecord then
			castTime = DPSCycle.castTimeRecords[name]
		else
			castTime = select(7, GetSpellInfo(id, BOOKTYPE_SPELL))
			if castTime then
				castTime = castTime / 1000
			end
		end

		if not castTime and type(useRecord) == "number" then
			castTime = useRecord
		end
		return castTime
	end
end

-------------------------------------------------------------------------------------
-- module:GetGCD()

-- Returns the generic GCD, either 1 or 1.5 seconds, hasting modifiers are not taken into account.
-------------------------------------------------------------------------------------
DPSCycle.GetGCD = function(self)
	return DPSCycle.gcd
end

-------------------------------------------------------------------------------------
-- module:WasSpellSent("name" [, elapsed])

-- Checks whether a spell was previously cast, if "elapsed" is specified, the function will
-- returns true only if the spell was cast within that time span, in seconds.
-------------------------------------------------------------------------------------
DPSCycle.WasSpellSent = function(self, name, elapsed)
	if type(name) == "string" then
		local sentTime = DPSCycle.spellSent[name]
		if sentTime then
			local timeSpan = GetTime() - sentTime
			if type(elapsed) == "number" then
				return timeSpan <= elapsed, timeSpan
			else
				return true, timeSpan
			end
		end
	end
end

-------------------------------------------------------------------------------------
-- module:GetLastSentSpell()

-- Retrives the last spell the player cast, and the time when it was cast
-------------------------------------------------------------------------------------
DPSCycle.GetLastSentSpell = function(self)
	return DPSCycle.lastSentSpell, DPSCycle.lastSentTime
end


-------------------------------------------------------------------------------------
-- module:UnitAura("unit", "aura", harmful, mine)
-- module:PlayerBuff("aura", mine)
-- module:PlayerDebuff("aura", mine)
-- module:TargetBuff("aura", mine)
-- module:TargetDebuff("aura", mine)

-- module:UnitAuraTime("unit", "aura", harmful, mine)
-- module:PlayerBuffTime("aura", mine)
-- module:PlayerDebuffTime("aura", mine)
-- module:TargetBuffTime("aura", mine)
-- module:TargetDebuffTime("aura", mine)

-- Some convenient warps to Blizzard's native API, you'll find yourself using these
-- a lot in your own modules.

-- unit: [STRING] - "player", "target", "pet", "focus" etc
-- aura: [STRING] - name of the aura
-- harmful: [BOOLEAN] - true if the aura must be a debuff
-- mine: [BOOLEAN] - true if the aura must be cast by myself
-------------------------------------------------------------------------------------

local FILTER_HARMFUL, FILTER_HELPFUL, FILTER_HARMFULPLAYER, FILTER_HELPFULPLAYER = "HARMFUL", "HELPFUL", "HARMFUL|PLAYER", "HELPFUL|PLAYER"
local function GetAuraFilter(harmful, mine)
	if harmful then
		if mine then
			return FILTER_HARMFULPLAYER
		else
			return FILTER_HARMFUL
		end
	else
		if mine then
			return FILTER_HELPFULPLAYER
		else
			return FILTER_HELPFUL
		end
	end
end

DPSCycle.UnitAura = function(self, unit, aura, harmful, mine)
	if type(aura) == "string" then
		return UnitAura(unit or "target", aura, nil, GetAuraFilter(harmful, mine))
	end
end

DPSCycle.PlayerBuff = function(self, aura, mine)
	return self:UnitAura("player", aura, nil, mine)
end

DPSCycle.PlayerDebuff = function(self, aura, mine)
	return self:UnitAura("player", aura, 1, mine)
end

DPSCycle.TargetBuff = function(self, aura, mine)
	return self:UnitAura("target", aura, nil, mine)
end

DPSCycle.TargetDebuff = function(self, aura, mine)
	return self:UnitAura("target", aura, 1, mine)
end

DPSCycle.UnitAuraTime = function(self, unit, aura, harmful, mine)
	local expires = select(7, self:UnitAura(unit, aura, harmful, mine))
	return max(0, expires and (expires - GetTime()) or 0)
end

DPSCycle.PlayerBuffTime = function(self, aura, mine)
	return self:UnitAuraTime("player", aura, nil, mine)
end

DPSCycle.PlayerDebuffTime = function(self, aura, mine)
	return self:UnitAuraTime("player", aura, 1, mine)
end

DPSCycle.TargetBuffTime = function(self, aura, mine)
	return self:UnitAuraTime("target", aura, nil, mine)
end

DPSCycle.TargetDebuffTime = function(self, aura, mine)
	return self:UnitAuraTime("target", aura, 1, mine)
end

-------------------------------------------------------------------------------------
-- module:CurrentSpell()

-- Returns the current spell which is displayed on DPSCycle GUI
-------------------------------------------------------------------------------------
DPSCycle.CurrentSpell = function(self)
	return DPSCycle.iconFrame.spellName
end

-------------------------------------------------------------------------------------
-- module:IsEnabled()

-- Checks whether the given module is the currently selected module
-------------------------------------------------------------------------------------
DPSCycle.Module_IsEnabled = function(module)
	return module and DPSCycle:GetSelectedModule() == module
end

-------------------------------------------------------------------------------------
-- module:DisplayInfo("icon", "text" [, r, g, b])

-- Displays a notify message on top of DPSCycle GUI
-------------------------------------------------------------------------------------
DPSCycle.Module_DisplayInfo = function(module, icon, text, r, g, b)
	if DPSCycle.Module_IsEnabled(module) then
		DPSCycle.infoFrame:DisplayInfo(icon, text, r, g, b)
	end
end

-------------------------------------------------------------------------------------
-- module:SetCountText("text" [, r, g, b])

-- Display count text on DPSCycle spell button
-------------------------------------------------------------------------------------
DPSCycle.Module_SetCountText = function(module, text, r, g, b)
	if DPSCycle.Module_IsEnabled(module) then
		DPSCycle.iconFrame:SetCountText(text, r, g, b)
	end
end

-------------------------------------------------------------------------------------
-- module:AddCooldownWatchSpell("spell", isPet)

-- Adds a cooldown watch spell
-------------------------------------------------------------------------------------
DPSCycle.Module_AddCooldownWatchSpell = function(module, spell, isPet)
	if type(spell) == "string" and not module.cooldownSpells[spell] then
		module.cooldownSpells[spell] = isPet and 2 or 1
		if DPSCycle.Module_IsEnabled(module) then
			DPSCycle.cooldownPanel:UpdateData()
		end
	end
end

-------------------------------------------------------------------------------------
-- module:RemoveCooldownWatchSpell("spell")

-- Removes a cooldown watch spell
-------------------------------------------------------------------------------------
DPSCycle.Module_RemoveCooldownWatchSpell = function(module, spell)
	if type(spell) == "string" and module.cooldownSpells[spell] then
		module.cooldownSpells[spell] = nil
		if DPSCycle.Module_IsEnabled(module) then
			DPSCycle.cooldownPanel:Reload()
		end
	end
end

-------------------------------------------------------------------------------------
-- module:RegisterEvent("event" [, "method"])
-- module:UnregisterEvent("event")
-- module:IsEventRegistered("event")
-- module:RegisterAllEvents()
-- module:UnregisterAllEvents()

-- Game events registration, when you use these functions you simply treat your module as a frame, if your
-- module has an "OnEvent" function, it will be called, otherwise the framework will call module[event] when
-- the event fires, or module[method] if you specified "method" in RegisterEvent.
-------------------------------------------------------------------------------------
DPSCycle.Module_RegisterEvent = function(module, event, method)
	module.moduleFrame.events[event] = method
	if not module.moduleFrame:IsEventRegistered(event) then
		module.moduleFrame:RegisterEvent(event)
	end
end

DPSCycle.Module_UnregisterEvent = function(module, event)
	module.moduleFrame.events[event] = nil
	if module.moduleFrame:IsEventRegistered(event) then
		module.moduleFrame:UnregisterEvent(event)
	end
end

DPSCycle.Module_IsEventRegistered = function(module, event)
	return module.moduleFrame:IsEventRegistered(event)
end

DPSCycle.Module_RegisterAllEvents = function(module)
	return module.moduleFrame:RegisterAllEvents()
end

DPSCycle.Module_UnregisterAllEvents = function(module)
	return module.moduleFrame:UnregisterAllEvents()
end

-------------------------------------------------------------------------------------
-- Memory problem and solution
--
-- Due to the high frequency that module:AddSequenceSpell and module:CompleteSequence are
-- called, table data allocation could occur up to hundreds times per second leaving as
-- many unrefrenced data segments in heap memory waiting to be attended by LUA GC (Garbage-
-- collection) system. In situation like this I think I must consider the memory expense
-- over time complication.
--
-- LUA executes its internal GC periodically at completely unpredictable moments, to avoid
-- the memory space this addon occupies becomes unacceptable between two GC encounters, I
-- create a public queue and use which to recycle all allocated table data.
--
-- This approach indeed slows down the addon a bit, but the sheer advantage of reducing the
-- memory usage from 600kb down to 100kb is worth the cost, I believe.
-------------------------------------------------------------------------------------

--local dataCount = 0
local dataPool = {} -- The global queue for recycling our allocated data

local function AcquireData()
	local data = tremove(dataPool)
	if not data then
		--dataCount = dataCount + 1
		data = {}
	end
	return data
end

local function ReleaseData(data)
	if data then
		wipe(data)
		tinsert(dataPool, data)
		return 1
	end
end

--[[
function DPSCycle._Debug()
	return dataCount, #dataPool
end
--]]

local function CompareCooldownSequence(sequence, cooldown)
	cooldown = cooldown + 0.5
	local count = #sequence
	local i
	for i = 1, count do
		if cooldown < sequence[i].cooldown then
			return i
		end
	end
	return count + 1
end

local function GetSequenceAt(sequence, position)
	local count = #sequence
	if count == 0 then
		return
	end

	if count == 1 then
		position = 1
	elseif position > count then
		position = position % count
	end

	local data = sequence[position]
	if data then
		return data.spell
	end
end

local fillData = { isFill = 1 }

local function FillSequence(sequence, spell, duration, threshold)
	if not DPSCycle:PlayerHasSpell(spell) then
		return
	end

	if not duration or duration < DPSCycle.gcd then
		duration = DPSCycle.gcd
	end

	if not threshold then
		threshold = duration / 2
	elseif threshold > duration then
		threshold = duration
	end

	if threshold < 0.2 then
		threshold = 0.2
	end

	fillData.spell = spell
	fillData.cooldown = duration

	local prevCD, prevCasting = 0, 0
	local count = 0
	local i = 1
	while i <= #sequence do
		local data = sequence[i]
		local cd, casting = data.cooldown, data.castingTime
		if casting then
			local len = cd - prevCD - prevCasting
			prevCD, prevCasting = cd, casting
			while len > threshold do
				len = len - duration
				tinsert(sequence, i, fillData)
				count = count + 1
				if count >= 3 then
					return
				end
				i = i + 1
			end
		end
		i = i + 1
	end

	for i = #sequence, 3 do
		tinsert(sequence, fillData)
	end
end

-------------------------------------------------------------------------------------
-- module:InitializeSequence()

-- Initialize the module's internal sequence data, all contents in the sequence will be wiped out.
-- You must call this function to prepare a new sequence.
-------------------------------------------------------------------------------------
DPSCycle.Module_InitializeSequence = function(module)
	module.sequenceCompleted = nil
	local sequence = module.sequence
	local data
	for _, data in ipairs(sequence) do
		if data ~= fillData then
			ReleaseData(data)
		end
	end
	wipe(sequence)
end

-------------------------------------------------------------------------------------
-- module:AddSequenceSpell("spell" [, cooldown [, castingTime [, ignoreDuration]]])

-- Adds a spell into the forecast sequence
-- spell: [STRING] - name of the spell
-- cooldown: [nil/NUMBER] - if specified, the framework will use this value instead of the spell's real cooldown time
-- castingTime: [nil/NUMBER] - if specified, the framework will use this value instead of the spell's real casting time
-- ignoreDuration: [nil/NUMBER] - the framework will ignore this spell after successful casting if it is the first spell in the sequence,
--                                default value is 0.5 second

-------------------------------------------------------------------------------------
DPSCycle.Module_AddSequenceSpell = function(module, spell, cooldown, castingTime, ignoreDuration)
	if module.sequenceCompleted then
		return
	end

	local id = DPSCycle:PlayerHasSpell(spell)
	if not id then
		return
	end

	if type(cooldown) == "number" then
		if cooldown < 0 then
			cooldown = 0
		end
	else
		local start, duration = GetSpellCooldown(id, BOOKTYPE_SPELL)
		if start and duration and duration > 1.5 then
			cooldown = duration - GetTime() + start
		else
			cooldown = 0
		end
	end

	if type(castingTime) == "number" then
		if castingTime < 0 then
			castingTime = 0
		end
	else
		castingTime = DPSCycle.gcd
	end

	if type(ignoreDuration) ~= "number" then
		ignoreDuration = DPSCycle.gcd
	end

	local sequence = module.sequence
	local position = CompareCooldownSequence(sequence, cooldown)
	local data = AcquireData()
	data.spell = spell
	data.cooldown = cooldown
	data.castingTime = castingTime
	data.ignoreDuration = ignoreDuration
	tinsert(sequence, position, data)
	return cooldown
end

-------------------------------------------------------------------------------------
-- module:CompleteSequence("fillSpell" [, cooldown [, threshold]])

-- Completes the spell sequence, asfter this you cannot call "AddSequenceSpell" until next "InitializeSequence". This
-- function encloses the current sequence and,  if "fillSpell" is specified, fill spell "gaps" in the sequence using it.

-- fillSpell: [STRING] - name of the spell which is to be filled into sequence gaps.
-- duration: [NUMBER] - aribitrary duration of "fillSpell", usually its casting/channeling time or a GCD for instant-cast spell
-- threshold: [NUMBER] - specifies the minimum time span between each two spells in the sequence, if its greater than "threshold",
--                       "fillSpell" will be kept inserting between them until the time span is no longer greater than "threshold".
-------------------------------------------------------------------------------------
DPSCycle.Module_CompleteSequence = function(module, fillSpell, duration, threshold)
	if not module.sequenceCompleted then
		module.sequenceCompleted = 1
		FillSequence(module.sequence, fillSpell, duration, threshold)
	end
end

-------------------------------------------------------------------------------------
-- module:IsSequenceCompleted()

-- Checks whether the sequence is currently completed.
-------------------------------------------------------------------------------------
DPSCycle.Module_IsSequenceCompleted = function(module)
	return module.sequenceCompleted
end

-------------------------------------------------------------------------------------
-- module:GetSequenceSpells()

-- Returns the first 3 spells in the sequence, you should only call this function after calling
-- "CompleteSequence", otherwise the results could likely be undesired.
-------------------------------------------------------------------------------------
DPSCycle.Module_GetSequenceSpells = function(module)
	local sequence = module.sequence
	local data = sequence[1]
	if not data then
		return
	end

	local spell = data.spell
	local ignoreDuration = data.ignoreDuration
	if not data.isFill and (DPSCycle.castingSpell == spell or (ignoreDuration and ignoreDuration > 0 and DPSCycle:WasSpellSent(spell, ignoreDuration))) then
		return GetSequenceAt(sequence, 2), GetSequenceAt(sequence, 3), GetSequenceAt(sequence, 4)
	else
		return spell, GetSequenceAt(sequence, 2), GetSequenceAt(sequence, 3)
	end
end

-------------------------------------------------------------------------------------
-- module:RegisterSpellAsAura("spell", "aura", "unit", harmful, mine)
-- module:UnregisterSpellAsAura("spell")
-- module:UnregisterAllSpellsAsAura()

-- Registers an aura as a spell so DPSCycle GUI will use the aura remaining time as the spell cooldown.

-- spell: [STRING] - name of the spell
-- aura: [nil/STRING] - name of the aura, if not specified, the framework uses spell name as default
-- unit: [STRING] - the unit which is being checked which affects the aura, "player", "target", etc
-- harmful: [BOOLEAN] - whether it is an harmful aura
-- mine: [BOOLEAN] - whether the aura must be cast by the player
-------------------------------------------------------------------------------------
DPSCycle.Module_RegisterSpellAsAura = function(module, spell, aura, unit, harmful, mine)
	if type(spell) ~= "string" then
		return
	end

	if type(aura) ~= "string" then
		aura = spell
	end

	if type(unit) ~= "string" then
		unit = "target"
	else
		unit = strlower(unit)
	end

	local data = AcquireData()
	data.aura = aura
	data.unit = unit
	data.harmful = harmful
	data.mine = mine
	module.auraSpells[spell] = data
end

DPSCycle.Module_UnregisterSpellAsAura = function(module, spell)
	if spell and ReleaseData(module.auraSpells[spell]) then
		module.auraSpells[spell] = nil
		return 1
	end
end

DPSCycle.Module_UnregisterAllSpellsAsAura = function(module)
	local list = module.auraSpells
	local spell, data
	for spell, data in pairs(list) do
		ReleaseData(data)
	end
	wipe(list)
end

-------------------------------------------------------------------------------------
-- module:RegisterUnitAura("unit", "aura", harmful, mine)

-- Registers an aura to receive notifications when the aura is applied/updated/removed on the specified unit.
-- unit: [STRING] - must be one of "player", "target", "pet", "focus".
-- aura: [STRING] - name of the aura
-- harmful: [BOOLEAN] - true if the aura must be a debuff
-- mine: [BOOLEAN] - true if the aura must be cast by myself
-------------------------------------------------------------------------------------
DPSCycle.Module_RegisterUnitAura = function(module, unit, aura, harmful, mine)
	if type(unit) ~= "string" or type(aura) ~= "string" then
		return
	end

	unit = strlower(unit)
	if unit ~= "player" and unit ~= "target" and unit ~= "pet" and unit ~= "focus" then
		return
	end

	local list = module.registeredAuras
	if not list[unit] then
		list[unit] = {}
	end

	local auraData = list[unit][aura]
	if not auraData then
		auraData = AcquireData()
		auraData.data = AcquireData()
		auraData.harmful = harmful
		auraData.mine = mine
		list[unit][aura] = auraData
	end
	return 1
end

-------------------------------------------------------------------------------------
-- module:UnregisterUnitAura("unit", "aura")

-- Unregisters an aura, notifications are no longer sent to this module for this aura.
-------------------------------------------------------------------------------------
DPSCycle.Module_UnregisterUnitAura = function(module, unit, aura)
	if type(unit) ~= "string" or type(aura) ~= "string" then
		return
	end

	unit = strlower(unit)
	local list = module.registeredAuras[unit]
	if not list then
		return
	end

	local auraData = list[unit][aura]
	if not auraData then
		return
	end

	ReleaseData(auraData.data)
	ReleaseData(auraData)
	list[unit][auraData] = nil
	return 1
end

-------------------------------------------------------------------------------------
-- module:UnregisterAllUnitAuras("unit")

-- Unregisters all auras on an unit, notifications are no longer sent to this module for this unit.
-------------------------------------------------------------------------------------
DPSCycle.Module_UnregisterAllUnitAuras = function(module, unit)
	if type(unit) ~= "string" then
		return
	end

	unit = strlower(unit)
	local list = module.registeredAuras[unit]
	if not list then
		return
	end

	local auraData
	for _, auraData in pairs(list) do
		ReleaseData(auraData.data)
		ReleaseData(auraData)
	end
	wipe(list)
	return 1
end