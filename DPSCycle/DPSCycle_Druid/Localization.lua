------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

DPSCYCLE_DRUID_LOCALE = {
	["title"] = "Druid(Balance/Feral)",
	["balance"] = "Balance:",
	["no eclipse timer"] = "Hide %s timer",
	["no eclipse sound"] = "Disable %s sound notification",
	["no insect swarm"] = "Don't use %s without talent improvement",
}

if GetLocale() == "zhCN" then
	DPSCYCLE_DRUID_LOCALE = {
		["title"] = "德鲁伊(平衡/野性)",
		["balance"] = "平衡系:",
		["no eclipse timer"] = "隐藏%s计时",
		["no eclipse sound"] = "禁用%s音效提示",
	}

elseif GetLocale() == "zhTW" then
	DPSCYCLE_DRUID_LOCALE = {
		["title"] = "德魯伊(平衡/野性)",
		["balance"] = "平衡系:",
		["no eclipse timer"] = "隱藏%s計時",
		["no eclipse sound"] = "禁用%s音效提示",
	}
end