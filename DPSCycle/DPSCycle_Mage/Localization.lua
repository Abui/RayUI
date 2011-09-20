------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-8-16
------------------------------------------------------------

DPSCYCLE_MAGE_LOCALE = {
	["title"] = "Mage",
	["arcane spell selection"] = "Arcane spell selection:",
	["fire spell selection"] = "Fire spell selection:",
	--["arcane blast stacks"] = "%s stacks count",
	--["timer"] = "%s timer",
};

if GetLocale() == "zhCN" then
	DPSCYCLE_MAGE_LOCALE = {
		["title"] = "法师",
		["arcane spell selection"] = "奥术系技能选择:",
		["fire spell selection"] = "火焰系技能选择:",
		--["arcane blast stacks"] = "%s叠加数字",
		--["timer"] = "%s计时",
	};

elseif GetLocale() == "zhTW" then
	DPSCYCLE_MAGE_LOCALE = {
		["title"] = "法師",
		["arcane spell selection"] = "秘法系技能选择:",
		["fire spell selection"] = "火焰系技能选择:",
		--["arcane blast stacks"] = "%s疊加數字",
		--["timer"] = "%s計時",
	};
end