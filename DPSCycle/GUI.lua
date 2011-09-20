------------------------------------------------------------
-- GUI.lua
--
-- Abin
-- 2009-6-18
--
--Fix for CTM by Ray
-- 2011-9-20
------------------------------------------------------------

local max = max
local GetTime = GetTime
local IsSpellInRange = IsSpellInRange
local IsUsableSpell = IsUsableSpell
local GetSpellCooldown = GetSpellCooldown
local GetSpellTexture = GetSpellTexture
local GameTooltip_SetDefaultAnchor = GameTooltip_SetDefaultAnchor
local format = format
local UIFrameFadeOut = UIFrameFadeOut
local UIFrameFade = UIFrameFade
local select = select
local GetSpellInfo = GetSpellInfo
local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitIsDead = UnitIsDead
local UnitCanAttack = UnitCanAttack
local type = type
local ipairs = ipairs
local tremove = tremove
local tinsert = tinsert
local pairs = pairs
local wipe = wipe

local L = DPSCYCLE_LOCALE
local BUTTON_SIZE = 32
local BUTTON_GAP = 4

local ATTACK = GetSpellInfo((select(4, GetBuildInfo()) < 30300) and 3606 or 6603) -- "Attack" no longer exists as a spell in 3.3

local function VerifyTimeLeft(start, duration)
	if start then
		local timeLeft = max(0, duration - GetTime() + start)
		if timeLeft < 15 then
			return timeLeft, duration == 0
		end
	end
end

local function SpellButton_UpdateSpellUsable(self, checkAura)
	local spellId = self.spellId
	if spellId then
		local bookType = self.isPet and BOOKTYPE_PET or BOOKTYPE_SPELL
		local r, g, b
		if IsSpellInRange(spellId, bookType) == 0 then
			r, g, b = 0.8, 0.1, 0.1 -- out of range
		else
			local usable, oom = IsUsableSpell(spellId, bookType)
			if usable then
				r, g, b = 1, 1, 1
			elseif oom then
				r, g, b = 0.1, 0.3, 1.0 -- out of mana
			else
				r, g, b = 0.4, 0.4, 0.4 -- disabled
			end
		end
		self.icon:SetVertexColor(r, g, b)

		local start, duration, enable, aura
		if checkAura and self.spellName then
			local module = DPSCycle:GetSelectedModule()
			if module then
				local data = module.auraSpells[self.spellName]
				if data then
					local _, _, _, count, _, len, expires = DPSCycle:UnitAura(data.unit, data.aura, data.harmful, data.mine)
					if len and expires then
						start, duration, enable, aura = expires - len, len, 1, data.harmful and 1 or 0
					end
				end
			end
		end

		if not start then
			start, duration, enable = GetSpellCooldown(spellId, bookType)
		end

		if start and start > 0 and duration > 0 and enable > 0 then
			self.cd:SetCooldown(start, duration);
			self.cd:Show();
		else
			self.cd:Hide();
		end
		return r, g, b, start, duration, enable, aura
	end
end

local function SpellButton_SetSpell(self, spellId, spellName, isPet)
	if not spellId then
		spellId = DPSCycle:PlayerHasSpell(spellName, isPet)
	end

	self.spellId = spellId
	self.isPet = isPet

	if spellId then
		self.spellName = spellName
		self.icon:SetTexture(GetSpellTexture(spellId, isPet and BOOKTYPE_PET or BOOKTYPE_SPELL))
		self.icon:SetTexCoord(.1, .9, .1, .9)
		self.icon:Show()
		if not self.bg then
			self.bg = CreateFrame("Frame", nil, self)
			self.bg:Point("TOPLEFT", -2, 2)
			self.bg:Point("BOTTOMRIGHT", 2, -2)
			self.bg:CreateShadow("Background")
		end
		self.cd:Show()
	else
		self.spellName = nil
		self.icon:Hide()
		self.cd:Hide()
	end

	return spellId
end

local function SpellButton_OnEnter(self)
	if self.spellId then
		-- GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetSpellBookItem(self.spellId, self.isPet and BOOKTYPE_PET or BOOKTYPE_SPELL)
		GameTooltip:Show()
	end
end

local function SpellButton_OnLeave(self)
	GameTooltip:Hide()
end

local function UpdateCooldownSpellButton(self, checkAura)
	local _, _, _, start, duration, enable, aura = SpellButton_UpdateSpellUsable(self, checkAura)
	local timeLeft, finished, threshold

	if aura then
		timeLeft = start and max(0, (duration - GetTime() + start)) or 0
		finished = timeLeft < 0.1
		threshold = 0
	else
		timeLeft, finished = VerifyTimeLeft(start, duration)
		threshold = (self.minDuration or 1.5)
	end

	if finished then
		timeLeft = nil
	end

	if timeLeft and duration > threshold then
		self.text:SetText(format(self.timeFormat, timeLeft))
		self.text:Show()
	else
		self.text:Hide()
	end
	return timeLeft, finished, aura
end

local function UpdateSequenceSpellButton(self)
	local timeLeft, _, aura = UpdateCooldownSpellButton(self, 1)
	if timeLeft then
		if aura == 0 then
			self.text:SetTextColor(0, 0.25, 1)
		elseif aura == 1 then
			self.text:SetTextColor(1, 0.25, 0)
		else
			self.text:SetTextColor(1, 1, 0)
		end
	end
end

local function WatchButton_ShineFadeOut(self)
	self.shining = nil
	UIFrameFadeOut(self, 1);
end

local function WatchButton_ShineStartShining(self)
	if not self.shining then
		self.shining = 1
		UIFrameFade(self, { mode = "IN", timeToFade = 0.5, finishedFunc = WatchButton_ShineFadeOut, finishedArg1 = self })
	end
end

local function UpdateWatchButton(self)
	self.elapsed = 0
	local _, finished = UpdateCooldownSpellButton(self)
	if finished and not self.cooldownFinished then
		self.cooldownFinished = 1
		WatchButton_ShineStartShining(self.shine)
	end
end

local function WatchButton_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.2 then
		UpdateWatchButton(self)
	end
end

local function WatchButton_SetSpell(self, id, spell, isPet, cooldownFinished)
	self.cooldownFinished = cooldownFinished
	if SpellButton_SetSpell(self, id, spell, isPet) then
		self.minDuration = select(6, GetSpellInfo(self.spellId, isPet and BOOKTYPE_PET or BOOKTYPE_SPELL)) == 5 and 10 or 1.5
		UpdateWatchButton(self)
		self:Show()
	else
		self:Hide()
	end
end

local function CreateSpellIconButton(name, parent)
	local button = CreateFrame("Button", name, parent)
	button:SetWidth(BUTTON_SIZE)
	button:SetHeight(BUTTON_SIZE)

	button.icon = button:CreateTexture(name.."Icon", "ARTWORK")
	button.icon:SetAllPoints(button)

	button.cd = CreateFrame("Cooldown", name.."CD", button, "CooldownFrameTemplate") -- Do not use name.."Cooldown" or the cooldown button gets messed up by ButtonFacade
	button.cd:ClearAllPoints()
	button.cd:SetAllPoints(button.icon)

	button.SetSpell = SpellButton_SetSpell
	button.UpdateSpellUsable = SpellButton_UpdateSpellUsable
	button:SetScript("OnEnter", SpellButton_OnEnter)
	button:SetScript("OnLeave", SpellButton_OnLeave)
	return button
end

local function CreateCooldownSpellButton(name, parent)
	local button = CreateSpellIconButton(name, parent)
	button.timeFormat = "%.1f"
	button.text = button.cd:CreateFontString(name.."CountText", "OVERLAY", "TextStatusBarText")
	button.text:SetPoint("TOP", button, "BOTTOM", 0, -1)
	return button
end

local function CreateSequenceSpellButton(name, parent)
	local button = CreateCooldownSpellButton(name, parent)
	button.text:SetTextColor(1, 1, 0)
	return button
end

local function CreateSpellWatchButton(name, parent)
	local button = CreateCooldownSpellButton(name, parent)
	button.timeFormat = "%.0f"
	button.text:ClearAllPoints()
	button.text:SetPoint("CENTER", 1, -1)
	button.text:SetTextColor(0, 1, 0)

	local shine = CreateFrame("Frame", nil, button)
	button.shine = shine
	shine:SetAllPoints(button)
	shine:Hide()

	local texture = shine:CreateTexture(nil, "OVERLAY")
	texture:SetTexture("Interface\\ComboFrame\\ComboPoint")
	texture:SetBlendMode("ADD")
	texture:SetTexCoord(0.5625, 1, 0, 1)
	texture:SetWidth(50)
	texture:SetHeight(50)
	texture:SetPoint("CENTER")

	button.SetSpell = WatchButton_SetSpell
	button:SetScript("OnUpdate", WatchButton_OnUpdate)

	return button
end

-------------------------------------------
-- DPSCycle core frame and its mover
--------------------------------------------

local core = CreateFrame("Frame", "DPSCycleFrame", UIParent)
DPSCycle.coreFrame = core
core:SetWidth(BUTTON_SIZE)
core:SetHeight(BUTTON_SIZE)
core:SetFrameStrata("BACKGROUND")
core:SetPoint("CENTER")
core:SetMovable(true)
core:SetClampedToScreen(true)

core:RegisterEvent("PLAYER_TARGET_CHANGED")
core:RegisterEvent("PLAYER_REGEN_DISABLED")
core:RegisterEvent("PLAYER_REGEN_ENABLED")
core:RegisterEvent("UNIT_FACTION")
core:RegisterEvent("UNIT_AURA")
core:RegisterEvent("UNIT_TARGET")

core.CheckConditions = function(self)
	local module = DPSCycle:GetSelectedModule()
	if module and UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") and (type(module.OnCheckConditions) ~= "function" or module:OnCheckConditions()) then
		DPSCycle.iconFrame:Show()
		return 1
	else
		DPSCycle.iconFrame:Hide()
	end
end

core:SetScript("OnEvent", function(self, event, unit)
	local needCheck
	if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
		needCheck = 1
	elseif event == "UNIT_FACTION" or event == "UNIT_AURA" then
		needCheck = (unit == "player" or unit == "target")
	elseif event == "UNIT_TARGET" then
		needCheck = (unit == "target")
	end

	if needCheck then
		self:CheckConditions()
	end
end)

local mover = CreateSpellIconButton("DPSCycleFrameMover", core)
DPSCycle.moverFrame = mover
mover:SetAllPoints(core)
mover:SetFrameStrata("FULLSCREEN_DIALOG")
mover.icon:SetTexture(0, 1, 0, 0.5)
mover.text = mover:CreateFontString("DPSCycleFrameMoverText", "ARTWORK", "GameFontNormal")
mover.text:SetPoint("CENTER")
mover.text:SetText(L["title"])

mover:RegisterForDrag("LeftButton")
mover:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
mover:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)

mover:SetScript("OnMouseUp", function(self, button)
	if button == "RightButton" then
		DPSCycle.optionPage:Open()
	end
end)

mover:SetScript("OnEnter", function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["title"])
	GameTooltip:AddLine(L["mouseover prompt"], 1, 1, 1)
	GameTooltip:Show()
end)

mover:SetScript("OnUpdate", nil)

--------------------------------------------
-- DPSCycle icon frame
--------------------------------------------

local iconFrame = CreateSpellIconButton("DPSCycleIconFrame1", core)
DPSCycle.iconFrame = iconFrame
iconFrame.noSpellCheckHidden = 1
iconFrame:Hide()
iconFrame:SetAllPoints(core)
iconFrame.spellText = iconFrame:CreateFontString(iconFrame:GetName().."SpellText", "ARTWORK", "GameFontHighlightSmall")
iconFrame.spellText:SetPoint("TOP", iconFrame, "BOTTOM", 0, -2)

local countFrame = CreateFrame("Frame", iconFrame:GetName().."CountFrame", iconFrame)
countFrame:SetAllPoints(iconFrame.icon)
iconFrame.countText = countFrame:CreateFontString(countFrame:GetName().."Text", "OVERLAY", "TextStatusBarText")
iconFrame.countText:SetPoint("BOTTOMRIGHT", -1, 2)
countFrame:SetFrameLevel(6)

local iconFrame2 = CreateSequenceSpellButton("DPSCycleIconFrame2", iconFrame)
iconFrame.button2 = iconFrame2
iconFrame2:SetScale(0.7)
iconFrame2:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 8, 0)

local iconFrame3 = CreateSequenceSpellButton("DPSCycleIconFrame3", iconFrame2)
iconFrame3:SetPoint("LEFT", iconFrame2, "RIGHT", 8, 0)
iconFrame.button3 = iconFrame3

iconFrame.SetCountText = function(self, text, r, g, b)
	if text then
		self.countText:SetText(text)
		if r then
			self.countText:SetTextColor(r, g, b, 1)
		else
			self.countText:SetTextColor(1, 1, 1, 1)
		end
		countFrame:Show()
	else
		countFrame:Hide()
	end
end

-- Request spell from the selected module
iconFrame.OnUpdate = function(self)
	self.elapsed = 0
	local module = DPSCycle:GetSelectedModule()
	local func = self.func
	if not module or not func then
		self:Hide()
		return
	end

	local spell1, spell2, spell3 = func(module)
	local id1 = DPSCycle:PlayerHasSpell(spell1)
	if not id1 then
		spell1, spell2, spell3 = ATTACK
	end

	if spell1 ~= self.spellName then
		if self:SetSpell(id1, spell1) then
			self.spellText:SetText(spell1)
		else
			self.spellText:SetText()
		end
	end

	local r, g, b = self:UpdateSpellUsable()
	if r then
		self.spellText:SetTextColor(r, g, b)
	end

	if iconFrame2:SetSpell(nil, spell2) then
		iconFrame2:Show()
		UpdateSequenceSpellButton(iconFrame2)

		if iconFrame3:SetSpell(nil, spell3) then
			iconFrame3:Show()
			UpdateSequenceSpellButton(iconFrame3)
		else
			iconFrame3:Hide()
		end
	else
		iconFrame2:Hide()
	end
end

iconFrame:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.2 then
		self:OnUpdate()
	end
end)

iconFrame:SetScript("OnShow", function(self)
	local module = DPSCycle:GetSelectedModule()
	if module and type(module.OnShow) == "function" then
		module:OnShow()
	end
	self:OnUpdate()
end)

iconFrame:SetScript("OnHide", function(self)
	self:SetSpell()
	self:Hide()
	local module = DPSCycle:GetSelectedModule()
	if module and type(module.OnHide) == "function" then
		module:OnHide()
	end
end)

--------------------------------------------
-- DPSCycle cooldown watch frames
--------------------------------------------

local MAX_COOLDOWN_BUTTONS = 12
local cooldownButtons = {}
local watchSpells = {}
local watchCount = 0

local function FindWatchButton(button)
	local k, v
	for k, v in ipairs(cooldownButtons) do
		if v == button then
			return k
		end
	end
end

local function AddWatch(id, spell, isPet, cooldownFinished)
	local button = cooldownButtons[watchCount + 1]
	if button then
		watchCount = watchCount + 1
		watchSpells[spell] = button
		button:SetSpell(id, spell, isPet, cooldownFinished)
		return button
	end
end

local function RemoveWatch(spell, button)
	watchCount = watchCount - 1
	watchSpells[spell] = nil
	button:SetSpell()
	local i = FindWatchButton(button)
	local nextButton = cooldownButtons[i + 1]
	if nextButton and nextButton:IsShown() then
		nextButton:ClearAllPoints()
		nextButton:SetPoint(button:GetPoint(1))
		button:ClearAllPoints()
		button:SetPoint("LEFT", cooldownButtons[#cooldownButtons], "RIGHT", BUTTON_GAP, 0)
		tremove(cooldownButtons, i)
		tinsert(cooldownButtons, button)
	end
end

local function RemoveAllWatches()
	local spell, button
	for spell, button in pairs(watchSpells) do
		button:SetSpell()
	end
	watchSpells = wipe(watchSpells)
	watchCount = 0
end

local cooldownPanel = CreateFrame("Frame", "DPSCycleCooldownPanel", iconFrame)
DPSCycle.cooldownPanel = cooldownPanel
cooldownPanel:SetScale(.7)
cooldownPanel:SetWidth(BUTTON_SIZE)
cooldownPanel:SetHeight(BUTTON_SIZE)
cooldownPanel:SetPoint("BOTTOMLEFT", iconFrame, "TOPLEFT", 0, BUTTON_GAP * (1/DPSCycleCooldownPanel:GetScale()))
cooldownPanel.enableCursor = true
cooldownPanel:Hide()

cooldownPanel.SetEnableCursor = function(self, enabled)
	self.enableCursor = enabled and true or false
	iconFrame:EnableMouse(enabled)
	iconFrame2:EnableMouse(enabled)
	iconFrame3:EnableMouse(enabled)
	local button
	for _, button in ipairs(cooldownButtons) do
		button:EnableMouse(self.enableCursor)
	end
end

cooldownPanel.UpdateWidth = function(self)
	if watchCount > 0 then
		self:SetWidth(watchCount * BUTTON_SIZE + (watchCount - 1) * BUTTON_GAP)
	end
end

cooldownPanel.Reload = function(self)
	if self:GetParent():IsShown() then
		RemoveAllWatches()
		self:UpdateData()
	end
end

cooldownPanel.UpdateData = function(self)
	if type(DPSCycle.cooldownWatchSpells) ~= "table" then
		return
	end

	self.elapsed = 0
	local spell, spellType, changed
	for spell, spellType in pairs(DPSCycle.cooldownWatchSpells) do
		local isPet = spellType == 2
		local id = DPSCycle:PlayerHasSpell(spell, isPet)
		if id then
			local button = watchSpells[spell]
			local start, duration = GetSpellCooldown(id, isPet and BOOKTYPE_PET or BOOKTYPE_SPELL)
			local timeLeft, cooldownFinished = VerifyTimeLeft(start, duration)
			if button then
				if not timeLeft then
					RemoveWatch(spell, button)
					changed = 1
				end
			else
				if timeLeft and AddWatch(id, spell, isPet, cooldownFinished) then
					changed = 1
				end
			end
		end
	end

	if changed then
		self:UpdateWidth()
	end
end

cooldownPanel:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.5 then
		self:UpdateData()
	end
end)

cooldownPanel:SetScript("OnShow", function(self)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("SPELLS_CHANGED")
	self:UpdateData()
end)

cooldownPanel:SetScript("OnHide", function(self)
	self:UnregisterAllEvents()
	RemoveAllWatches()
end)

cooldownPanel:SetScript("OnEvent", function(self, event)
	if event == "SPELLS_CHANGED" then
		RemoveAllWatches()
	end
	self:UpdateData()
end)

local i
for i = 1, MAX_COOLDOWN_BUTTONS do
	local button = CreateSpellWatchButton(cooldownPanel:GetName().."Button"..i, cooldownPanel)
	tinsert(cooldownButtons, button)
	if i == 1 then
		button:SetPoint("LEFT")
	else
		button:SetPoint("LEFT", cooldownButtons[i - 1], "RIGHT", BUTTON_GAP * (1/DPSCycleCooldownPanel:GetScale()), 0)
	end
end

--------------------------------------------
-- DPSCycle info frame
--------------------------------------------

local infoFrame = CreateFrame("Frame", "DPSCycleInfoFrame", iconFrame)
DPSCycle.infoFrame = infoFrame
infoFrame:SetWidth(BUTTON_SIZE)
infoFrame:SetHeight(BUTTON_SIZE)
infoFrame:SetScale(0.6)
infoFrame:SetPoint("BOTTOM", cooldownPanel, "TOP", 0, 10)
infoFrame:Hide()

infoFrame.icon = infoFrame:CreateTexture("DPSCycleInfoFrameIcon", "ARTWORK")
infoFrame.icon:SetWidth(BUTTON_SIZE)
infoFrame.icon:SetHeight(BUTTON_SIZE)
infoFrame.icon:SetPoint("LEFT")
infoFrame.text = infoFrame:CreateFontString("DPSCycleInfoFrameText", "ARTWORK", "ZoneTextFont")

infoFrame.DisplayInfo = function(self, icon, text, r, g, b)
	self.icon:SetTexture(icon)
	self.text:SetText(text)
	if not r then
		r, g, b = 0.0, 0.82, 1.0
	end

	self.text:SetTextColor(r, g, b, 1)
	self.text:ClearAllPoints()

	local width = 0
	if icon then
		width = self.icon:GetWidth()
		self.text:SetPoint("LEFT", self.icon, "RIGHT", BUTTON_GAP, 0)
	else
		self.text:SetPoint("LEFT")
	end

	if text then
		if width > 0 then
			width = width + BUTTON_GAP
		end
		width = width + self.text:GetWidth()
	end

	if width > 0 then
		self:SetWidth(width)
	end

	UIFrameFadeOut(self, 5, 1, 0)
end

--------------------------------------------
-- ButtonFacade supports
--------------------------------------------

local bfs = CreateButtonFacadeSupport(L["title"], "DPSCycleDB")
if bfs then
	bfs:AddGroup(L["spell button"], "DPSCycleIconFrame", 3)
	bfs:AddGroup(L["cooldown buttons"], DPSCycle.cooldownPanel:GetName().."Button", MAX_COOLDOWN_BUTTONS)
end