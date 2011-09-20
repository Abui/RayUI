------------------------------------------------------------
-- Localization.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

DPSCYCLE_DEATHKNIGHT_LOCALE = {
	["title"] = "Death Knight",
	["disease check"] = "Disease check:",
	["pestilence message"] = "%s cast succeeded",
	["pestilence timeout message"] = "It's 20s since last %s",
	["pestilence notify"] = "Display info when %s is cast successfully",
	["pestilence timeout notify"] = "Remind in 20 seconds after %s is cast",
};

if GetLocale() == "zhCN" then
	DPSCYCLE_DEATHKNIGHT_LOCALE = {
		["title"] = "死亡骑士",
		["disease check"] = "疾病检查:",
		["pestilence message"] = "%s施放成功",
		["pestilence timeout message"] = "距离上次%s已过20秒",
		["pestilence notify"] = "当成功施放%s时显示信息",
		["pestilence timeout notify"] = "施放%s20秒后提醒",
	};

elseif GetLocale() == "zhTW" then
	DPSCYCLE_DEATHKNIGHT_LOCALE = {
		["title"] = "死亡騎士",
		["disease check"] = "疾病檢查:",
		["pestilence message"] = "%s施放成功",
		["pestilence timeout message"] = "距離上次%s已過20秒",
		["pestilence notify"] = "當成功施放%s時顯示信息",
		["pestilence timeout notify"] = "施放%s20秒後提醒",
	};
end