local RayUIWatcher = LibStub("AceAddon-3.0"):NewAddon("RayUI_Watcher", "AceConsole-3.0","AceEvent-3.0")

local _, ns = ...
local _, myclass = UnitClass("player")
local page

local modules = {}

local function CreateShadow(f)
	if f.shadow then return end
	
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -3, 3)
	shadow:SetPoint("BOTTOMRIGHT", 3, -3)
	shadow:SetBackdrop({
	bgFile = [[Interface\ChatFrame\ChatFrameBackground.blp]], 
	edgeFile = [[Interface\AddOns\RayUI_Watcher\media\glowTex.tga]], 
	edgeSize = 5,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	shadow:SetBackdropColor(.05,.05,.05, .9)
	shadow:SetBackdropBorderColor(0, 0, 0, 1)
	f.shadow = shadow
	f.glow = shadow
end

function RayUIWatcher:PrintCmd(input)
	input = input:trim():match("^(.-);*$")
	local func, err = loadstring("LibStub(\"AceConsole-3.0\"):Print(" .. input .. ")")
	if not func then
		LibStub("AceConsole-3.0"):Print("错误: " .. err)
	else
		func()
	end
end

function RayUIWatcher:OnInitialize()
	self:RegisterChatCommand("print", "PrintCmd")
	local watchers = ns.watchers[myclass]
	for _, t in ipairs(watchers) do
		self:NewWatcher(t)
	end
	watchers = ns.watchers["ALL"]
	for _, t in ipairs(watchers) do
		self:NewWatcher(t)
	end
	
	local lockgroup = page:CreateMultiSelectionGroup("锁定/解锁模块")
	page:AnchorToTopLeft(lockgroup)
	lockgroup:AddButton("锁定", "lock")
	lockgroup.OnCheckInit = function(self, value) 
			if db.lock ~= nil then
			return db.lock
		else
			return false
		end
	end
	lockgroup.OnCheckChanged = function(self, value, checked)
		for _, v in pairs(modules) do
			v:TestMode(checked)
		end
		db.lock = checked == 1 and true or false
	end
	
	local group = page:CreateMultiSelectionGroup("选择启用的模块")
	page:AnchorToTopLeft(group, 0, -50)
	for _, v in pairs(modules) do
		group:AddButton(v:GetName(), v:GetName())
	end
	group.OnCheckInit = function(self, value)
		if db.profiles[myclass][value] ~= nil then
			return db.profiles[myclass][value]
		else
			return RayUIWatcher:GetModule(value):IsEnabled()
		end
	end
	group.OnCheckChanged = function(self, value, checked)
		if checked then
			RayUIWatcher:GetModule(value):Enable()
			db.profiles[myclass][value] = true
		else
			RayUIWatcher:GetModule(value):Disable()
			db.profiles[myclass][value] = false
		end
	end
end

function RayUIWatcher:OnEnable()
	print("|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r Watcher已启用")
end

function RayUIWatcher:OnDisable()
	print("|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r Watcher已禁用")
end

function RayUIWatcher:NewWatcher(data)
	if type(data) ~= 'table' then 
		error(format("bad argument #1 to 'RayUIWatcher:New' (table expected, got %s)", type(name)))
		return
	end
	local module = self:NewModule(data.name, "AceConsole-3.0", "AceEvent-3.0")
	
	function module:OnEnable()
		if self.parent then
			self.parent:Show()
		end
		self:Update()
	end
	
	function module:OnDisable()
		self:Print("模块已禁用")
		if self.parent then
			self.parent:Hide()
		end
	end
	
	function module:CreateButton()
		-- local button=CreateFrame("Button", nil, self.parent, "SecureActionButtonTemplate")
		local button=CreateFrame("Frame", nil, self.parent)
		CreateShadow(button)
		button:SetWidth(self.size)
		button:SetHeight(self.size)
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetPoint("TOPLEFT", button , 2, -2)
		button.icon:SetPoint("BOTTOMRIGHT", button , -2, 2)
		button.count = button:CreateFontString(nil, "OVERLAY")
		button.count:SetFont(ns.font, ns.fontsize, ns.fontflag)
		button.count:SetPoint("BOTTOMRIGHT", button , "BOTTOMRIGHT", 0, 0)
		button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cooldown:SetAllPoints(button.icon)
		button.cooldown:SetReverse()
		return button
	end
	
	function module:UpdateButton(button, index, icon, count, duration, expires, spellID, unitId, filter)
		button.icon:SetTexture(icon)
		button.icon:SetTexCoord(.1, .9, .1, .9)
		button.count:SetText(count==0 and "" or count)
		CooldownFrame_SetTimer(button.cooldown, expires - duration, duration, 1)
		button.index = index
		button:Show()
		button:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				if filter == "BUFF" then
					GameTooltip:SetUnitAura(unitId, self.index, "HELPFUL")
				elseif filter == "DEBUFF" then
					GameTooltip:SetUnitAura(unitId, self.index, "HARMFUL")
				else
					GameTooltip:SetSpellByID(spellID)
				end
				GameTooltip:Show()
			end)
		button:SetScript("OnLeave", function(self) 
				GameTooltip:Hide() 
			end)
	end
	
	function module:CheckAura(unitID, filter, num)
		local index = 1
		local list = self[filter:lower().."list"]
		if next(list) then
			while UnitAura(unitID,index, filter == "BUFF" and "HELPFUL" or "HARMFUL") do
				local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unitID,index, filter == "BUFF" and "HELPFUL" or "HARMFUL")
				if list[spellID] then
					if list[spellID].unitId == unitID and (list[spellID].caster == caster or list[spellID].caster == "all")then
						if not self.button[num] then
							self.button[num] = self:CreateButton()					
							if num == 1 then 
								self.button[num]:SetPoint("CENTER", self.parent, "CENTER", 0, 0)
							elseif self.direction == "LEFT" then
								self.button[num]:SetPoint("RIGHT", self.button[num-1], "LEFT", -5, 0)
							elseif self.direction == "UP" then
								self.button[num]:SetPoint("BOTTOM", self.button[num-1], "TOP", 0, 5)
							elseif self.direction == "DOWN" then
								self.button[num]:SetPoint("TOP", self.button[num-1], "BOTTOM", 0, -5)
							else
								self.button[num]:SetPoint("LEFT", self.button[num-1], "RIGHT", 5, 0)
							end
						end	
						self:UpdateButton(self.button[num], index, icon, count, duration, expires, spellID, unitID, filter)
						num = num + 1
					end
				end
				index = index + 1
			end
		end
		return num
	end

	function module:Update()		
		local num = 1
		for i = 1, #self.button do
			self.button[i]:Hide()
		end
		num = self:CheckAura("player","BUFF",num)
		num = self:CheckAura("player","DEBUFF",num)
		num = self:CheckAura("target","BUFF",num)
		num = self:CheckAura("target","DEBUFF",num)	
		num = self:CheckAura("focus","DEBUFF",num)	
	end
	
	function module:TestMode(arg)
		if not self:IsEnabled() then return end
		if arg == true or self.testmode ~= true then
			self.testmode = true
			local num = 1
			module:UnregisterEvent("UNIT_AURA")
			module:UnregisterEvent("PLAYER_TARGET_CHANGED")
			for i,v in next,self.bufflist do
				if not self.button[num] then
					self.button[num] = self:CreateButton()					
					if num == 1 then 
						self.button[num]:SetPoint("CENTER", self.parent, "CENTER", 0, 0)
					elseif self.direction == "LEFT" then
						self.button[num]:SetPoint("RIGHT", self.button[num-1], "LEFT", -5, 0)
					elseif self.direction == "UP" then
						self.button[num]:SetPoint("BOTTOM", self.button[num-1], "TOP", 0, 5)
					elseif self.direction == "DOWN" then
						self.button[num]:SetPoint("TOP", self.button[num-1], "BOTTOM", 0, -5)
					else
						self.button[num]:SetPoint("LEFT", self.button[num-1], "RIGHT", 5, 0)
					end
				end
				local _, _, icon = GetSpellInfo(i)
				self:UpdateButton(self.button[num], 1, icon, 9, 0, 0, i, "player", "BUFF")
				num = num + 1
			end
			for i,v in next,self.debufflist do
				if not self.button[num] then
					self.button[num] = self:CreateButton()					
					if num == 1 then 
						self.button[num]:SetPoint("CENTER", self.parent, "CENTER", 0, 0)
					elseif self.direction == "LEFT" then
						self.button[num]:SetPoint("RIGHT", self.button[num-1], "LEFT", -5, 0)
					elseif self.direction == "UP" then
						self.button[num]:SetPoint("BOTTOM", self.button[num-1], "TOP", 0, 5)
					elseif self.direction == "DOWN" then
						self.button[num]:SetPoint("TOP", self.button[num-1], "BOTTOM", 0, -5)
					else
						self.button[num]:SetPoint("LEFT", self.button[num-1], "RIGHT", 5, 0)
					end
				end
				local _, _, icon = GetSpellInfo(i)
				self:UpdateButton(self.button[num], 1, icon, 9, 0, 0, i, "player", "DEBUFF")
				num = num + 1
			end
			self.moverFrame:Show()
		else
			self.testmode = false
			module:RegisterEvent("UNIT_AURA")
			module:RegisterEvent("PLAYER_TARGET_CHANGED")
			for _, v in pairs(modules) do
				v:Update()
			end
			self.moverFrame:Hide()
		end
	end
	
	function module:UNIT_AURA()
		self:Update()
	end
	
	function module:PLAYER_TARGET_CHANGED()
		self:Update()
	end
	
	function module:PLAYER_ENTERING_WORLD()		
		if db.profiles[myclass][self:GetName()] == false then
			self:Disable()
		else
			self:Update()
		end
		
		if db.lock ~= true then
			self:TestMode(true)
		end
	end
	
	module.parent = CreateFrame("Frame", data.name, UIParent)
	module.parent:SetSize(data.size, data.size)
	module.parent:SetPoint(unpack(data.anchor))
	module.parent:SetMovable(true)
	
	local mover = CreateFrame("Frame", nil, module.parent)
	module.moverFrame = mover
	mover:SetAllPoints(module.parent)
	mover:SetFrameStrata("FULLSCREEN_DIALOG")
	mover.mask = mover:CreateTexture(nil, "OVERLAY")
	mover.mask:SetAllPoints(mover)
	mover.mask:SetTexture(0, 1, 0, 0.5)
	mover.text = mover:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	mover.text:SetPoint("CENTER")
	mover.text:SetText(data.name)
	
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
	mover:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)

	mover:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(data.name)
		GameTooltip:AddLine("拖拽左键移动，右键设置", 1, 1, 1)
		GameTooltip:Show()
	end)
	
	mover:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			page:Open()
		end
	end)

	mover:SetScript("OnUpdate", nil)
	
	mover:Hide()
	
	module.list = data.list
	module.direction = data.direction
	module.size = data.size
	module.bufflist = {}
	module.debufflist = {}	
	module.cdlist = {}
	module.button = {}	
	
	module.testmode = false
	
	for i, t in ipairs(data.list) do
		if t.filter == "BUFF" then
			module.bufflist[t.spellID] = {unitId = t.unitId, caster = t.caster,}
		elseif t.filter == "DEBUFF" then
			module.debufflist[t.spellID] = {unitId = t.unitId, caster = t.caster,}
		elseif t.filter == "CD" then
			module.cdlist[t.spellID] = true
		end
	end
	
	module:RegisterEvent("UNIT_AURA")
	module:RegisterEvent("PLAYER_TARGET_CHANGED")
	module:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	tinsert(modules, module)
end

page = UICreateInterfaceOptionPage("RayUI_WatcherOptionPage", RayUIWatcher:GetName(), "一个很2B的技能监视")
RayUIWatcher.optionPage = page
page.title:SetText(RayUIWatcher:GetName().." "..GetAddOnMetadata("RayUI_Watcher", "Version"))
page:RegisterEvent("VARIABLES_LOADED")
page:SetScript("OnEvent", function(self, event)
	if event == "VARIABLES_LOADED" then

		if type(RayUI_WatcherDB) ~= "table" then
			RayUI_WatcherDB = {}
		end

		db = RayUI_WatcherDB

		if type(db.profiles) ~= "table" then
			db.profiles = {}
		end
		
		if type(db.profiles[myclass]) ~= "table" then
			db.profiles[myclass] = {}
		end
	end
end)

SLASH_TESTMODE1="/testmode"
SlashCmdList["TESTMODE"]=function(msg)
	for _, v in pairs(modules) do
		v:TestMode()
	end
end