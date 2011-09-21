local MyAddon = LibStub("AceAddon-3.0"):NewAddon("RayUI Watcher", "AceConsole-3.0","AceEvent-3.0")
local watchers = {}

function MyAddon:PrintCmd(input)
	input = input:trim():match("^(.-);*$")
	local func, err = loadstring("LibStub(\"AceConsole-3.0\"):Print(" .. input .. ")")
	if not func then
		LibStub("AceConsole-3.0"):Print("错误: " .. err)
	else
		func()
	end
end

function MyAddon:OnInitialize()
	self:RegisterChatCommand("print", "PrintCmd")
	self:NewWatch("BUFFS")
end

function MyAddon:OnEnable()
	print("|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r已启用")
end

function MyAddon:OnDisable()
	print("|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r已禁用")
end

function MyAddon:NewWatch(name)
	local watcher = CreateFrame("Frame", name, UIParent)
	watcher:SetSize(32, 32)
	watcher:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	
	watcher.icon = watcher:CreateTexture(nil, "BORDER")
	watcher.icon:SetAllPoints(watcher)
	
	function watcher:Update()
		self.icon:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
	end
	tinsert(watchers, watcher)
end

function MyAddon:Update(unitID)
	if unitID == "player" then
		for _, watcher in pairs(watchers) do
			watcher:Update()
		end
	end
end

function MyAddon:UNIT_AURA(event, unitID)
	self:Print(unitID)
	self:Update(unitID)
end

function MyAddon:PLAYER_ENTERING_WORLD()
	LibStub("AceConsole-3.0"):Print("加载成功")
end

MyAddon:RegisterEvent("PLAYER_ENTERING_WORLD")
MyAddon:RegisterEvent("UNIT_AURA")