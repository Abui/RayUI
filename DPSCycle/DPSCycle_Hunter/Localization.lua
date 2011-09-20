------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

DPSCYCLE_HUNTER_LOCALE = {
	["title"] = "Hunter(Marksmanship)",	
	["pet dying"] = "Pet dying, heal it",
	["mana full"] = "Mana full, turn off %s",
	["viper notify"] = "Prompt to turn off %s when mana is more than 80%%",
	["mend pet"] = "Prompt to %s when pet health is below 40%%",
};

if GetLocale() == "zhCN" then
	DPSCYCLE_HUNTER_LOCALE = {
		["title"] = "猎人(射击)",		
		["pet dying"] = "宠物垂危，需要治疗",
		["mana full"] = "法力已满，关闭%s",
		["viper notify"] = "法力值高于80%%时提示关闭%s",
		["mend pet"] = "宠物生命值低于40%%时提示%s",
	};

elseif GetLocale() == "zhTW" then
	DPSCYCLE_HUNTER_LOCALE = {
		["title"] = "獵人(射擊)",		
		["pet dying"] = "寵物垂危，需要治療",
		["mana full"] = "法力已滿，關閉%s",
		["viper notify"] = "法力高於80%%時提示關閉%s",
		["mend pet"] = "寵物生命值低於40%%時提示%s",
	};
end