local MyAddon = LibStub("AceAddon-3.0"):NewAddon("RayUI", "AceConsole-3.0","AceEvent-3.0")
	
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
end

function MyAddon:OnEnable()
	print("|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r已启用")
end

function MyAddon:OnDisable()
	print("|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r已禁用")
end