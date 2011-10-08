
-----------------------------------------------------------------------------------------------------
-- name = "目标debuff",
-- setpoint = { "LEFT", UIParent, "CENTER", 198, -190 },
-- direction = "UP",
-- iconSide = "LEFT",
-- mode = "BAR", 
-- size = 24,
-- barWidth = 200,				
--	{spellID = 8050, unitId = "target", caster = "target", filter = "DEBUFF"},
--	{ spellID = 18499, filter = "CD" },
--	{ itemID = 56285, filter = "CD" },
---------------------------------------------------------------------------------------------------

local _, ns = ...

ns.font = "Fonts\\bLEI00D.ttf"
ns.fontsize = 12
ns.fontflag = "OUTLINE"

ns.watchers ={
	["DRUID"] = {
		{
			name = "玩家buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -146 },
			size = 32,

			-- Lifebloom / Blühendes Leben
			{ spellID = 33763, unitId = "player", caster = "player", filter = "BUFF" },
			-- Rejuvenation / Verjüngung
			{ spellID = 774, unitId = "player", caster = "player", filter = "BUFF" },
			-- Regrowth / Nachwachsen
			{ spellID = 8936, unitId = "player", caster = "player", filter = "BUFF" },
			-- Wild Growth / Wildwuchs
			{ spellID = 48438, unitId = "player", caster = "player", filter = "BUFF" },
		},
		{
			name = "目标buff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -146 },
			size = 32,

			-- Lifebloom / Blühendes Leben
			{ spellID = 33763, unitId = "target", caster = "player", filter = "BUFF" },
			-- Rejuvenation / Verjüngung
			{ spellID = 774, unitId = "target", caster = "player", filter = "BUFF" },
			-- Regrowth / Nachwachsen
			{ spellID = 8936, unitId = "target", caster = "player", filter = "BUFF" },
			-- Wild Growth / Wildwuchs
			{ spellID = 48438, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			size = 47,
			
			-- Eclipse (Lunar) / Mondfinsternis
			{ spellID = 48518, unitId = "player", caster = "player", filter = "BUFF" },
			-- Eclipse (Solar) / Sonnenfinsternis
			{ spellID = 48517, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shooting Stars / Sternschnuppen
			{ spellID = 93400, unitId = "player", caster = "player", filter = "BUFF" },
			-- Savage Roar / Wildes Brüllen
			{ spellID = 52610, unitId = "player", caster = "player", filter = "BUFF" },
			-- Survival Instincts / Überlebensinstinkte
			{ spellID = 61336, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tree of Life / Baum des Lebens
			{ spellID = 33891, unitId = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting / Freizaubern
			{ spellID = 16870, unitId = "player", caster = "player", filter = "BUFF" },
			-- Innervate / Anregen
			{ spellID = 29166, unitId = "player", caster = "all", filter = "BUFF" },
			-- Barkskin / Baumrinde
			{ spellID = 22812, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -190 },
			size = 47,
			
			-- Hibernate / Winterschlaf
			{ spellID = 2637, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Entangling Roots / Wucherwurzeln
			{ spellID = 339, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Cyclone / Wirbelsturm
			{ spellID = 33786, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Moonfire / Mondfeuer
			{ spellID = 8921, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Sunfire / Sonnenfeuer
			{ spellID = 93402, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Insect Swarm / Insektenschwarm
			{ spellID = 5570, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Rake / Krallenhieb
			{ spellID = 1822, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Rip / Zerfetzen
			{ spellID = 1079, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Lacerate / Aufschlitzen
			{ spellID = 33745, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Pounce Bleed / Anspringblutung
			{ spellID = 9007, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Mangle / Zerfleischen
			{ spellID = 33876, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Earth and Moon / Erde und Mond
			{ spellID = 48506, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Faerie Fire / Feenfeuer
			{ spellID = 770, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "LEFT", UIParent, "CENTER", 198, 100 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 200,
			
			-- Hibernate / Winterschlaf
			{ spellID = 2637, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Entangling Roots / Wucherwurzeln
			{ spellID = 339, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Cyclone / Wirbelsturm
			{ spellID = 33786, unitId = "focus", caster = "all", filter = "DEBUFF" },
		},
		{
			name = "CD",
			direction = "UP",
			iconSide = "RIGHT",
			mode = "BAR",
			size = 32,
			barWidth = 200,
			setpoint = { "RIGHT", UIParent, "CENTER", -198, 100 },

			-- Swiftmend / Rasche Heilung
			{ spellID = 18562, filter = "CD" },
			-- Wild Growth / Wildwuchs
			{ spellID = 48438, filter = "CD" },
		},
	},
	["HUNTER"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			size = 47,
			
			-- Lock and Load / Sichern und Laden
			{ spellID = 56342, unitId = "player", caster = "player", filter = "BUFF" },
			-- Quick Shots / Schnelle Schüsse
			{ spellID = 6150, unitId = "player", caster = "player", filter = "BUFF" },
			-- Master Tactician / Meister der Taktik
			{ spellID = 34837, unitId = "player", caster = "player", filter = "BUFF" },
			-- Improved Steady Shot / Verbesserter zuverlässiger Schuss
			{ spellID = 53224, unitId = "player", caster = "player", filter = "BUFF" },
			-- Rapid Fire / Schnellfeuer
			{ spellID = 3045, unitId = "player", caster = "player", filter = "BUFF" },
			-- Mend Pet / Tier heilen
			{ spellID = 136, unitId = "pet", caster = "player", filter = "BUFF" },
			-- Feed Pet / Tier füttern
			{ spellID = 6991, unitId = "pet", caster = "player", filter = "BUFF" },
			-- Call of the Wild / Ruf der Wildnis
			{ spellID = 53434, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -190 },
			size = 47,
			
			-- Wyvern Sting / Wyverngift
			{ spellID = 19386, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Silencing Shot / Unterdrückender Schuss
			{ spellID = 34490, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Serpent Sting / Schlangengift
			{ spellID = 1978, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Widow Venom / Witwentoxin
			{ spellID = 82654, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Black Arrow / Schwarzer Pfeil
			{ spellID = 3674, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Explosive Shot / Explosivschuss
			{ spellID = 53301, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Hunter's Mark/ Mal des Jägers
			{ spellID = 1130, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "LEFT", UIParent, "CENTER", 198, 100 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 200,
			
			-- Wyvern Sting / Wyverngift
			{ spellID = 19386, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Silencing Shot / Unterdrückender Schuss
			{ spellID = 34490, unitId = "focus", caster = "all", filter = "DEBUFF" },
		},
	},
	["MAGE"] = {
		{
			name = "P_PROC_ICON",
			direction = "LEFT",
			setPoint = { "right", "oUF_FreebPlayer", "right", 0, 40  },
			size = 47,
			
			--Frostbite/Erfrierung/霜寒刺骨
			--{ spellID = 11071, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			--深冬之寒
			{ spellID = 28593, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			--寒冰指
			{ spellID = 83074, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			--腦部凍結
			{ spellID = 44549, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			--熱門連勝
			{ spellID = 44448, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			--節能施法
			{ spellID = 12575, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			--衝擊
			{ spellID = 12357, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			--嗜血
			{ spellID = 2825, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
			--英勇氣概
			{ spellID = 32182, size = 47, unitId = "player", caster = "all", filter = "BUFF" },

		},
		{
			name = "P_BUFF_BAR",
			direction = "DOWN",
			Mode = "BAR",
			setPoint = { "BOTTOM", nil, "BOTTOM", 284, 268 },
			size = 30,
			iconSide = "LEFT",
			barWidth = 180, 
			
			--鏡像
			{ spellID = 55342, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },
            --烈焰之球
			{ spellID = 82731, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },
            --霜之環
			{ spellID = 84676, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },
            --秘法強化
			{ spellID = 12042, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },
            --喚醒
			{ spellID = 12051, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },

		},
		{
			name = "T_DEBUFF_ICON",
			direction = "RIGHT",
			setPoint = { "left", "oUF_FreebTarget", "left", -1, 65 },
			size = 47, 
			Mode = "ICON",
			
			--減速術
			{ spellID = 31589, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			--點燃
			{ spellID = 12846, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			--活體炸彈
			{ spellID = 44457, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			--變羊
			{ spellID = 118, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
		},
		{
			name = "秘法衝擊",
			direction = "RIGHT",
			setPoint = { "right", "oUF_FreebPlayer", "right", 0, -38 },
			size = 47, 
			Mode = "ICON",
			
			--秘法衝擊
			{ spellID = 30451, size = 47, unitId = "player", caster = "player", filter = "DEBUFF" },
		},
		{
			name = "P_BUFFS_ICON",
			direction = "RIGHT",
			setPoint = { "center", nil, "center", -100, -378 },
			size = 42, 
			Mode = "ICON",
			
			 --能量洪流
            { spellID = 74241, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
            --神經突觸彈簧
            { spellID = 96230, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
            --災厄魔力
            { spellID = 91007, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
			--光紋刺繡
            { spellID = 75170, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
			--魂棺
            { spellID = 91019, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
			 --法力寶石
            { spellID = 83098, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
            --火山毀滅
            { spellID = 89091, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
			--鏡子
			{ spellID = 91024, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
		},
	},
	["WARRIOR"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			size = 47,
			
			-- Sudden Death / Plötzlicher Tod
			{ spellID = 52437, unitId = "player", caster = "player", filter = "BUFF" },
			-- Bloodsurge / Schäumendes Blut
			{ spellID = 46916, unitId = "player", caster = "all", filter = "BUFF" },
			-- Sword and Board / Schwert und Schild
			{ spellID = 50227, unitId = "player", caster = "player", filter = "BUFF" },
			-- Blood Reserve / Blutreserve
			{ spellID = 64568, unitId = "player", caster = "player", filter = "BUFF" },
			-- Spell Reflection / Zauberreflexion
			{ spellID = 23920, unitId = "player", caster = "player", filter = "BUFF" },
			-- Victory Rush / Siegesrausch
			{ spellID = 34428, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shield Block / Schildblock
			{ spellID = 2565, unitId = "player", caster = "player", filter = "BUFF" },
			-- Last Stand / Letztes Gefecht
			{ spellID = 12975, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shield Wall / Schildwall
			{ spellID = 871, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -190 },
			size = 47,
			
			-- Charge Stun / Sturmangriffsbetäubung
			{ spellID = 7922, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Shockwave / Schockwelle
			{ spellID = 46968, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Hamstring / Kniesehne
			{ spellID = 1715, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Rend / Verwunden
			{ spellID = 94009, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Sunder Armor /Rüstung zerreiße
			{ spellID = 7386, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Thunder Clap / Donnerknall
			{ spellID = 6343, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Demoralizing Shout / Demoralisierender Ruf
			{ spellID = 1160, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Expose Armor / Rüstung schwächen (Rogue)
			{ spellID = 8647, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Infected Wounds / Infizierte Wunden (Druid)
			{ spellID = 48484, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Frost Fever / Frostfieber (Death Knight)
			{ spellID = 55095, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Demoralizing Roar / Demoralisierendes Gebrüll (Druid)
			{ spellID = 99, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Curse of Weakness / Fluch der Schwäche (Warlock)
			{ spellID = 702, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
	},
	["SHAMAN"] = {
		{
			name = "玩家buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -146 },
			size = 32,
			
			-- Earth Shield / Erdschild
			{ spellID = 974, unitId = "player", caster = "player", filter = "BUFF" },
			-- Riptide / Springflut
			{ spellID = 61295, unitId = "player", caster = "player", filter = "BUFF" },
			-- Lightning Shield / Blitzschlagschild
			{ spellID = 324, unitId = "player", caster = "player", filter = "BUFF" },
			-- Water Shield / Wasserschild
			{ spellID = 52127, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标buff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -146 },
			size = 32,
			
			-- Earth Shield / Erdschild
			{ spellID = 974, unitId = "target", caster = "player", filter = "BUFF" },
			-- Riptide / Springflut
			{ spellID = 61295, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			size = 47,
			
			-- Maelstorm Weapon / Waffe des Mahlstroms
			{ spellID = 53817, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shamanistic Rage / Schamanistische Wut
			{ spellID = 30823, unitId = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting / Freizaubern
			{ spellID = 16246, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tidal Waves / Flutwellen
			{ spellID = 51562, unitId = "player", caster = "player", filter = "BUFF" },
			-- Ancestral Fortitude / Seelenstärke der Ahnen
			{ spellID = 16177, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -190 },
			size = 47,
			
			-- Hex / Verhexen
			{ spellID = 51514, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Bind Elemental / Elementar binden
			{ spellID = 76780, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Storm Strike / Sturmschlag
			{ spellID = 17364, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Earth Shock / Erdschock
			{ spellID = 8042, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Frost Shock / Frostschock
			{ spellID = 8056, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Flame Shock / Flammenschock
			{ spellID = 8050, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "LEFT", UIParent, "CENTER", 198, 100 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 200,
			
			-- Hex / Verhexen
			{ spellID = 51514, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Bind Elemental / Elementar binden
			{ spellID = 76780, unitId = "focus", caster = "all", filter = "DEBUFF" },

		},
	},
	["PALADIN"] = {
		{
			name = "玩家buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -146 },
			size = 32,
			
			-- Beacon of Light / Flamme des Glaubens
			{ spellID = 53563, unitId = "player", caster = "player", filter = "BUFF" },
			{ spellID = 20154, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标buff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -146 },
			size = 32,
			
			-- Beacon of Light / Flamme des Glaubens
			{ spellID = 53563, unitId = "target", caster = "player", filter = "BUFF" },

		},
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			size = 47,
			
			-- Judgements of the Pure / Richturteile des Reinen
			{ spellID = 53671, unitId = "player", caster = "player", filter = "BUFF" },
			-- Judgements of the Just / Richturteil des Gerechten
			{ spellID = 68055, unitId = "player", caster = "player", filter = "BUFF" },
			-- Holy Shield / Heiliger Schild
			{ spellID = 20925, unitId = "player", caster = "player", filter = "BUFF" },
			-- Infusion of Light / Lichtenergie
			{ spellID = 53672, unitId = "player", caster = "player", filter = "BUFF" },
			-- Divine Plea / Göttliche Bitte
			{ spellID = 54428, unitId = "player", caster = "player", filter = "BUFF" },
			-- Essence of Life / Essenz des Lebens
			{ spellID = 60062, unitId = "player", caster = "player", filter = "BUFF" },
			-- Divine Illumination / Göttliche Gunst
			{ spellID = 31842, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -190 },
			size = 47,
			
			-- Hammer of Justice / Hammer der Gerechtigkeit
			{ spellID = 853, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Judgement / Richturteil
			{ spellID = 20271, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "LEFT", UIParent, "CENTER", 198, 100 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 200,
			
			-- Hammer of Justice / Hammer der Gerechtigkeit
			{ spellID = 853, unitId = "focus", caster = "all", filter = "DEBUFF" },

		},
	},
	["PRIEST"] = {
		{
			name = "P_BUFFS_ICON",
			direction = "LEFT",
			setPoint = { "center", nil, "center", -100, -378 },
			size = 42,
			
			--能量洪流
            { spellID = 74241, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
            --神經突觸彈簧
            { spellID = 96230, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
            --災厄魔力
            { spellID = 91007, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
            --火山毀滅
            { spellID = 89091, size = 42, unitId = "player", caster = "all", filter = "BUFF" },
			--鏡子
			{ spellID = 91024, size = 42, unitId = "player", caster = "all", filter = "BUFF" },

		},
		{
			name = "P_BUFF_ICON",
			direction = "LEFT",
			setPoint = { "right", "oUF_FreebPlayer", "right", 0, -38 },
			size = 37,
			
			--爭分奪秒
            { spellID = 59888, size = 37, unitId = "player", caster = "all", filter = "BUFF" },
            --暗影寶珠
            { spellID = 77487, size = 37, unitId = "player", caster = "all", filter = "BUFF" },	
            --真言術：壁
            { spellID = 81782 , size = 37, unitId = "player", caster = "all", filter = "BUFF" },	
            --光之澎湃
			{ spellID = 88690, size = 37, unitId = "player", caster = "all", filter = "BUFF" },
			--機緣回復
			{ spellID = 63733, size = 37, unitId = "player", caster = "player", filter = "BUFF" },
			--虚弱靈魂
			{ spellID = 6788, size = 37, unitId = "player", caster = "all", filter = "DEBUFF" },		

		},
		{
			name = "T_DEBUFF_ICON",
			direction = "RIGHT",
			setPoint = { "left", "oUF_FreebTarget", "left", -1, 65 },
			size = 37,
			
			--暗言術:痛
			{ spellID = 589, size = 37, unitId = "target", caster = "player", filter = "DEBUFF" },
			--虚弱靈魂
			{ spellID = 6788, size = 37, unitId = "target", caster = "all", filter = "DEBUFF" },
			--噬靈瘟疫
			{ spellID = 2944, size = 37, unitId = "target", caster = "player", filter = "DEBUFF" },
			--吸血鬼之觸
            { spellID = 34914, size = 37, unitId = "target", caster = "player", filter = "DEBUFF" },
			--守護聖靈
			{ spellID = 47788, size = 37, unitId = "target", caster = "all", filter = "BUFF" },
			--痛苦壓制
			{ spellID = 33206, size = 37, unitId = "target", caster = "all", filter = "BUFF" },

		},
		{
			name = "P_PRAIDBUFF/DEBUFF_ICON",
			direction = "LEFT",
			setPoint = { "right", "oUF_FreebPlayer", "right", 0, 40 },
			size = 45,
			
            --黑天使
            { spellID = 87153, size = 45, unitId = "player", caster = "player", filter = "BUFF" },
		    --2T12效果
            { spellID = 99132, size = 45, unitId = "player", caster = "player", filter = "BUFF" },
			--嗜血
			{ spellID = 2825, size = 45, unitId = "player", caster = "all", filter = "BUFF" },
			--英勇氣概
			{ spellID = 32182, size = 45, unitId = "player", caster = "all", filter = "BUFF" },
            --時間扭曲
			{ spellID = 80353, size = 45, unitId = "player", caster = "all", filter = "BUFF" },
			--火山藥水
			{ spellID = 79476, size = 45, unitId = "player", caster = "player", filter = "BUFF" },
            --激活
            { spellID = 29166, size = 45, unitId = "player", caster = "all", filter = "BUFF"},
            --注入能量
            { spellID = 10060, size = 45, unitId = "player", caster = "all", filter = "BUFF" },	
			--絕命當頭buff
			{ spellID = 96907, size = 45, unitId = "player", caster = "player", filter = "DEBUFF" },	

		},
		{
			name = "P_BUFF_BAR",
			direction = "DOWN",
			setPoint = { "BOTTOM", nil, "BOTTOM", 284, 268 },
			size = 30, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 180,
			
            --大天使
			{ spellID = 87151, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },
            --暗影魔
			{ spellID = 34433, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },
            --真言術:壁
			{ spellID = 62618, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },
            --影散
			{ spellID = 47585, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },
            --絕望禱言
			{ spellID = 19236, size = 30, barWidth = 180, unitId = "player", caster = "player", filter = "CD" },

		},
	},
	["WARLOCK"]={
		{
			name = "目标debuff",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -190 },
			direction = "RIGHT",
			mode = "ICON",
			size = 47,
	
			{spellID = 8050, unitId = "target", caster = "target", filter = "DEBUFF"},
			-- Fear / Furcht
			{ spellID = 5782, unitId = "target", caster = "target", filter = "DEBUFF" },
			-- Banish / Verbannen
			{ spellID = 710, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of the Elements / Fluch der Elemente
			{ spellID = 1490, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Tongues / Fluch der Sprachen
			{ spellID = 1714, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Exhaustion / Fluch der Erschöpfung
			{ spellID = 18223, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Weakness / Fluch der Schwäche
			{ spellID = 702, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Shadow Embrace / Umschlingende Schatten
			{ spellID = 32385, filter = "BUFF" },
			-- Corruption / Verderbnis
			{ spellID = 172, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Immolate / Feuerbrand
			{ spellID = 348, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Agony / Omen der Pein
			{ spellID = 980, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Bane of Doom / Omen der Verdammnis
			{ spellID = 603, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Unstable Affliction / Instabiles Gebrechen
			{ spellID = 30108, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Haunt / Heimsuchung
			{ spellID = 48181, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Seed of Corruption / Saat der Verderbnis
			{ spellID = 27243, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Howl of Terror / Schreckensgeheul
			{ spellID = 5484, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Death Coil / Todesmantel
			{ spellID = 6789, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Enslave Demon / Dämonensklave
			{ spellID = 1098, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Demon Charge / Dämonischer Ansturm
			{ spellID = 54785, unitId = "target", caster = "player", filter = "DEBUFF" },
		},
		{
			name = "玩家重要buff",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			direction = "LEFT",
			size = 47,
			-- Improved Soul Fire / Verbessertes Seelenfeuer
			{ spellID = 85383, unitId = "player", caster = "player", filter = "BUFF" },
			-- Molten Core / Geschmolzener Kern
			{ spellID = 47383, unitId = "player", caster = "player", filter = "BUFF" },
			-- Decimation / Dezimierung
			{ spellID = 63165, unitId = "player", caster = "player", filter = "BUFF" },
			-- Backdraft / Pyrolyse
			{ spellID = 54274, unitId = "player", caster = "player", filter = "BUFF" },
			-- Backlash / Heimzahlen
			{ spellID = 34936, unitId = "player", caster = "player", filter = "BUFF" },
			-- Nether Protection / Netherschutz
			{ spellID = 30299, unitId = "player", caster = "player", filter = "BUFF" },
			-- Nightfall / Einbruch der Nacht
			{ spellID = 18094, unitId = "player", caster = "player", filter = "BUFF" },
			-- Soulburn / Seelenbrand
			{ spellID = 74434, unitId = "player", caster = "player", filter = "BUFF" },
		},
	},
	["ROGUE"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "BOTTOMRIGHT", "oUF_FreebPlayer", "TOPRIGHT", 0, 10 },
			size = 47,
			
			-- Sprint / Sprinten
			{ spellID = 2983, unitId = "player", caster = "player", filter = "BUFF" },
			-- Cloak of Shadows / Mantel der Schatten
			{ spellID = 31224, unitId = "player", caster = "player", filter = "BUFF" },
			-- Adrenaline Rush / Adrenalinrausch
			{ spellID = 13750, unitId = "player", caster = "player", filter = "BUFF" },
			-- Evasion / Entrinnen
			{ spellID = 5277, unitId = "player", caster = "player", filter = "BUFF" },
			-- Envenom / Vergiften
			{ spellID = 32645, unitId = "player", caster = "player", filter = "BUFF" },
			-- Overkill / Amok
			{ spellID = 58426, unitId = "player", caster = "player", filter = "BUFF" },
			-- Slice and Dice / Zerhäckseln
			{ spellID = 5171, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tricks of the Trade / Schurkenhandel
			{ spellID = 57934, unitId = "player", caster = "player", filter = "BUFF" },
			-- Turn the Tables / Den Spieß umdrehen
			{ spellID = 51627, unitId = "player", caster = "player", filter = "BUFF" },
			--  贱人乱舞
			{ spellID = 13877, unitId = "player", caster = "player", filter = "BUFF" },
			--  绿灯
			{ spellID = 84745, unitId = "player", caster = "player", filter = "BUFF" },
			--  黄灯
			{ spellID = 84746, unitId = "player", caster = "player", filter = "BUFF" },
			--  红灯
			{ spellID = 84747, unitId = "player", caster = "player", filter = "BUFF" },
			-- 恢復
			{ spellID = 73651, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "BOTTOMLEFT", "oUF_FreebTarget", "TOPLEFT", 0, 10 },
			size = 47,
			
			-- Cheap Shot / Fieser Trick
			{ spellID = 1833, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Kidney Shot / Nierenhieb
			{ spellID = 408, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Blind / Blenden
			{ spellID = 2094, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Sap / Kopfnuss
			{ spellID = 6770, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Rupture / Blutung
			{ spellID = 1943, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Garrote / Erdrosseln
			{ spellID = 703, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Gouge / Solarplexus
			{ spellID = 1776, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Expose Armor / Rüstung schwächen
			{ spellID = 8647, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Dismantle / Zerlegen
			{ spellID = 51722, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Deadly Poison / Tödliches Gift
			{ spellID = 2818, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Mind-numbing Poison / Gedankenbenebelndes Gift
			{ spellID = 5760, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Crippling Poison / Verkrüppelndes Gift
			{ spellID = 3409, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Wound Poison / Wundgift
			{ spellID = 13218, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
		{
			name = "焦点debuff",
			direction = "UP",
			setpoint = { "BOTTOMLEFT", "oUF_FreebFocus", "TOPLEFT", 0, 10 },
			size = 32, 
			mode = "BAR",
			iconSide = "LEFT",
			barWidth = 170,
			
			-- Blind / Blenden
			{ spellID = 2094, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Sap / Kopfnuss
			{ spellID = 6770, unitId = "focus", caster = "all", filter = "DEBUFF" },

		},
		{
			name = "CD",
			direction = "DOWN",
			iconSide = "LEFT",
			mode = "BAR",
			size = 32,
			barWidth = 200,
			setpoint = { "TOPLEFT", "ActionBar2Mover", "TOPRIGHT", 10, 0 },

			-- 能量刺激
			{ spellID = 13750, filter = "CD" },
			-- 狂舞殘殺
			{ spellID = 51690, filter = "CD" },
			--宿怨
			{ spellID = 79140, filter = "CD" },
			--冷血
			{ spellID = 14177, filter = "CD" },
		},
	},
	["DEATHKNIGHT"] = {
		{
			name = "玩家重要buff",
			direction = "LEFT",
			setpoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			size = 47,
			
			-- Blood Shield / Blutschild
			{ spellID = 77513, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Force / Unheilige Kraft
			{ spellID = 67383, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Strength / Unheilige Stärke
			{ spellID = 53365, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Might / Unheilige Macht
			{ spellID = 67117, unitId = "player", caster = "player", filter = "BUFF" },
			-- Dancing Rune Weapon / Tanzende Runenwaffe
			{ spellID = 49028, unitId = "player", caster = "player", filter = "BUFF" },
			-- Icebound Fortitude / Eisige Gegenwehr
			{ spellID = 48792, unitId = "player", caster = "player", filter = "BUFF" },
			-- Anti-Magic Shell / Antimagische Hülle
			{ spellID = 48707, unitId = "player", caster = "player", filter = "BUFF" },
			-- Killing Machine / Tötungsmaschine
			{ spellID = 51124, unitId = "player", caster = "player", filter = "BUFF" },
			-- Freezing Fog / Gefrierender Nebel
			{ spellID = 59052, unitId = "player", caster = "player", filter = "BUFF" },
			-- Bone Shield / Knochenschild
			{ spellID = 49222, unitId = "player", caster = "player", filter = "BUFF" },

		},
		{
			name = "目标debuff",
			direction = "RIGHT",
			setpoint = { "LEFT", UIParent, "CENTER", 198, -190 },
			size = 47,
			
			-- Strangulate / Strangulieren
			{ spellID = 47476, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Blood Plague / Blutseuche
			{ spellID = 59879, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Frost Fever / Frostfieber
			{ spellID = 59921, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Unholy Blight / Unheilige Verseuchung
			{ spellID = 49194, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Summon Gargoyle / Gargoyle beschwören
			{ spellID = 49206, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Death and Decay / Tod und Verfall
			{ spellID = 43265, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
	},
	["ALL"]={
		{
			Name = "PVE/PVP_P_DEBUFF_ICON",
			Direction = "UP",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "BOTTOM", nil, "BOTTOM", 0, 350 },
			size = 55, 
			
			--活力火花
            { spellID = 99262, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
			--佈道
            { spellID = 81661, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
			--心靈融烙
			{ spellID = 14910, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
			--活力烈焰
			{ spellID = 99263, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
            --聚雷針
             { spellID = 83099, size = 55, unitId = "player", caster = "all", filter = "DEBUFF" }, 
			--侵蝕魔法
             { spellID = 86622, size = 55, unitId = "player", caster = "all", filter = "DEBUFF" },
			--暮光隕星
            { spellID = 88518, size = 55, unitId = "player", caster = "all", filter = "DEBUFF" },
			--爆裂灰燼
            { spellID = 79339, size = 55, unitId = "player", caster = "all", filter = "DEBUFF" },
			--火焰易傷
			{ spellID = 98492, size = 55, unitId = "player", caster = "all", filter = "DEBUFF" },
			--爆裂種子
			{ spellID = 98450, size = 55, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Death Knight
			-- 啃食
			{ spellID = 47481, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 絞殺
			{ spellID = 47476, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 冰鍊術
			{ spellID = 45524, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 褻瀆
			{ spellID = 55741, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 碎心打擊
			{ spellID = 58617, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 噬溫酷寒
			{ spellID = 49203, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Druid
			-- 颶風術
			{ spellID = 33786, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 休眠
			{ spellID = 2637, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 重擊
			{ spellID = 5211, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 傷殘術
			{ spellID = 22570, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 突襲
			{ spellID = 9005, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 糾纏根鬚
			{ spellID = 339, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 野性衝鋒效果
			{ spellID = 45334, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 感染之傷
			{ spellID = 58179, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Hunter
			-- 冰凍陷阱
			{ spellID = 3355, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 恐嚇野獸
			{ spellID = 1513, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 驅散射擊
			{ spellID = 19503, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 奪械
			{ spellID = 50541, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 沉默射擊
			{ spellID = 34490, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 脅迫
			{ spellID = 24394, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 音波衝擊
			{ spellID = 50519, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 劫掠
			{ spellID = 50518, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 震盪狙擊
			{ spellID = 35101, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 震盪射擊
			--{ spellID = 5116, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 寒冰陷阱
			{ spellID = 13810, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 凍痕
			{ spellID = 61394, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 摔絆
			{ spellID = 2974, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 反擊
			{ spellID = 19306, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 誘捕
			{ spellID = 19185, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 釘刺
			{ spellID = 50245, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 噴灑毒網
			{ spellID = 54706, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 蛛網
			{ spellID = 4167, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 霜暴之息
			{ spellID = 92380, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 裂筋
			{ spellID = 50271, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Mage
			-- 龍之吐息
			{ spellID = 31661, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 變形術
			{ spellID = 118, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 沉默 - 強化法術反制
			{ spellID = 18469, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 極度冰凍
			{ spellID = 44572, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 冰凍術
			{ spellID = 33395, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 冰霜新星
			{ spellID = 122, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 碎裂屏障
			{ spellID = 55080, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 冰凍
			{ spellID = 6136, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 冰錐術
			{ spellID = 120, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 減速術
			{ spellID = 31589, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 強化冰錐術
			{ spellID = 83301, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			{ spellID = 83302, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Paladin
			-- 懺悔
			{ spellID = 20066, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 暈眩 - 復仇之盾
			{ spellID = 63529, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 制裁之錘
			{ spellID = 853, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 公正聖印
			{ spellID = 20170, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 復仇之盾
			{ spellID = 31935, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Priest
			-- 心靈恐慌（繳械效果）
			{ spellID = 64058, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 精神控制
			{ spellID = 605, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 心靈恐慌
			{ spellID = 64044, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 心靈尖嘯
			{ spellID = 8122, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 沉默
			{ spellID = 15487, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 精神鞭笞
			{ spellID = 15407, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			--罪與罰
			{ spellID = 87204, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Rogue
			-- 卸除武裝
			{ spellID = 51722, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 致盲
			{ spellID = 2094, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 鑿擊
			{ spellID = 1776, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 悶棍
			{ spellID = 6770, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 絞喉 - 沉默
			{ spellID = 1330, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 沉默 - 強化腳踢
			{ spellID = 18425, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 偷襲
			{ spellID = 1833, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 腎擊
			{ spellID = 408, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 旋轉劍刃
			{ spellID = 31125, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 致殘毒藥
			{ spellID = 3409, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 擲殺
			{ spellID = 26679, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Shaman
			-- 妖術
			{ spellID = 51514, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 陷地
			{ spellID = 64695, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 凍結
			{ spellID = 63685, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 石爪昏迷
			{ spellID = 39796, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 地縛術
			{ spellID = 3600, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 冰霜震擊
			{ spellID = 8056, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Warlock
			-- 放逐術
			{ spellID = 710, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 死亡纏繞
			{ spellID = 6789, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 恐懼術
			{ spellID = 5782, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 恐懼嚎叫
			{ spellID = 5484, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 誘惑
			{ spellID = 6358, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 法術封鎖
			{ spellID = 24259, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 暗影之怒
			{ spellID = 30283, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 追獵
			{ spellID = 30153, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 清算
			{ spellID = 18118, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 疲勞詛咒
			{ spellID = 18223, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Warrior
			-- 破膽怒吼
			{ spellID = 20511, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 繳械
			{ spellID = 676, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 沉默 - 窒息律令
			{ spellID = 18498, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 衝鋒昏迷
			{ spellID = 7922, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 震盪猛擊
			{ spellID = 12809, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 攔截
			{ spellID = 20253, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
            -- 震懾波
			{ spellID = 46968, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 斷筋雕紋
			{ spellID = 58373, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 強化斷筋
			{ spellID = 23694, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 斷筋
			{ spellID = 1715, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 刺耳怒吼
			{ spellID = 12323, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Racials
			-- 戰爭踐踏
			{ spellID = 20549, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			
		-- Bastion of Twilight
		
			--浸濕
			{ spellID = 82762, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			
		-- Blackwing Descent

			-- 寄生感染
			{ spellID = 94679, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 避雷針
			{ spellID = 91433, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 吞噬烈焰
			{ spellID = 77786, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- 聚影體
			{ spellID = 92053, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

		-- Firelands
		
			-- 燃燒之球
			{ spellID = 98451, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
		},
		{
			Name = "PVP_T_BUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "right", "oUF_FreebTarget", "right", 75, 80 },
			size = 55,

			-- 啟動
			{ spellID = 29166, size = 72, unitId = "target", caster = "all", filter = "BUFF"},
			-- 法術反射
			{ spellID = 23920, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 精通光環
			{ spellID = 31821, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 寒冰屏障
			{ spellID = 45438, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 暗影披風
			{ spellID = 31224, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 聖盾術
			{ spellID = 642, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 威懾
			{ spellID = 19263, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 反魔法護罩
			{ spellID = 48707, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 巫妖之軀
			{ spellID = 49039, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 自由聖禦
			{ spellID = 1044, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 犧牲聖禦
			{ spellID = 6940, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- 根基圖騰效果
			{ spellID = 8178, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			--保護聖禦
            { spellID = 1022, size = 72, unitId= "target", caster = "all", filter = "BUFF" },
		},
	},
}