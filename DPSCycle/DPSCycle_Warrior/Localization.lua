------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-9-02
------------------------------------------------------------

DPSCYCLE_WARRIOR_LOCALE = {
	["title"] = "Warrior",
}

if GetLocale() == "zhCN" then
	DPSCYCLE_WARRIOR_LOCALE = {
		["title"] = "战士",	
	}

elseif GetLocale() == "zhTW" then
	DPSCYCLE_WARRIOR_LOCALE = {
		["title"] = "戰士",	
	}
end