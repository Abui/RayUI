------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-8-21
------------------------------------------------------------

DPSCYCLE_WARLOCK_LOCALE = {
	["title"] = "Warlock",
	["keep curse"] = "Keep on curse(Boss only):",
	["keep corruption"] = "Keep on %s even in Destruction talent spec",
}

if GetLocale() == "zhCN" then
	DPSCYCLE_WARLOCK_LOCALE = {
		["title"] = "术士",	
		["keep curse"] = "保持诅咒（仅Boss）:",
		["keep corruption"] = "即使是毁灭天赋也保持%s",
	}

elseif GetLocale() == "zhTW" then
	DPSCYCLE_WARLOCK_LOCALE = {
		["title"] = "術士",	
		["keep curse"] = "保持詛咒（僅王）:",
		["keep corruption"] = "即使是毀滅天賦也保持%s",
	}
end