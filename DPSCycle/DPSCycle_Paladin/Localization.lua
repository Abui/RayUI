------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

DPSCYCLE_PALADIN_LOCALE = {
	["title"] = "Paladin",
	["judgement selection"] = "Judgement selection:",
};

if GetLocale() == "zhCN" then
	DPSCYCLE_PALADIN_LOCALE = {
		["title"] = "圣骑士",
		["judgement selection"] = "审判选择:",
	};

elseif GetLocale() == "zhTW" then
	DPSCYCLE_PALADIN_LOCALE = {
		["title"] = "聖騎士",
		["judgement selection"] = "审判选择:",
	};
end