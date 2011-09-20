------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

DPSCYCLE_PRIESTSHADOW_LOCALE = {
	["title"] = "Priest(Shadow)",
	["display MF tick count"] = "Display %s 3-tick count",
};

if GetLocale() == "zhCN" then
	DPSCYCLE_PRIESTSHADOW_LOCALE = {
		["title"] = "牧师(暗影)",
		["display MF tick count"] = "显示%s三段提示",
	};

elseif GetLocale() == "zhTW" then
	DPSCYCLE_PRIESTSHADOW_LOCALE = {
		["title"] = "牧師(暗影)",
		["display MF tick count"] = "顯示%s三段提示",
	};
end