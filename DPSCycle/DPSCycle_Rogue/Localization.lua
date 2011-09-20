------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

DPSCYCLE_ROGUE_LOCALE = {
	["title"] = "Rogue(Assassination/Combat)",
	["always"] = "Always",
	["never"] = "Never",
	["only with bleeding amplify debuffs"] = "Only when target affected by bleeding amplify debuffs",
	["assassination"] = "Assassination:",
	["allow 3-combo"] = "Allow 3-combo %s",
};

if GetLocale() == "zhCN" then
	DPSCYCLE_ROGUE_LOCALE = {
		["title"] = "潜行者(刺杀/战斗)",
		["always"] = "总是",
		["never"] = "从不",
		["only with bleeding amplify debuffs"] = "仅当目标受到流血伤害放大debuff时",
		["assassination"] = "刺杀:",
		["allow 3-combo"] = "允许3星施放%s",
	};

elseif GetLocale() == "zhTW" then
	DPSCYCLE_ROGUE_LOCALE = {
		["title"] = "盜賊(刺殺/戰鬥)",
		["always"] = "總是",
		["never"] = "從不",
		["only with bleeding amplify debuffs"] = "僅當目標受到流血傷害放大debuff時",
		["assassination"] = "刺殺:",
		["allow 3-combo"] = "允許3星施放%s",
	};
end