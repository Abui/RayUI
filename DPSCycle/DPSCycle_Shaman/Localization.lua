------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

DPSCYCLE_SHAMAN_LOCALE = {
	["title"] = "Shaman",
	["lightning selection"] = "Lightning spell selection:",
};

if GetLocale() == "zhCN" then
	DPSCYCLE_PALADIN_LOCALE = {
		["title"] = "萨满",
		["lightning selection"] = "闪电法术选择:",
	};

elseif GetLocale() == "zhTW" then
	DPSCYCLE_PALADIN_LOCALE = {
		["title"] = "薩滿",
		["lightning selection"] = "閃電法術选择:",
	};
end