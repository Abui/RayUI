local R, C, L, DB = unpack(select(2, ...))

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = BottomInfoBar:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
Text:SetShadowOffset(1.25, -1.25)
Text:SetShadowColor(0, 0, 0, 0.4)
Text:SetPoint("BOTTOMRIGHT", BottomInfoBar, "TOPRIGHT", -10, -3)
Stat:SetParent(Text:GetParent())

local _G = getfenv(0)
local format = string.format
local chanceString = "%.2f%%"
local armorString = ARMOR..": "
local modifierString = string.join("", "%d (+", chanceString, ")")
local baseArmor, effectiveArmor, armor, posBuff, negBuff
local displayNumberString = string.join("", "%s%d|r")
local displayFloatString = string.join("", "%s%.2f%%|r")

local function CalculateMitigation(level, effective)
	local mitigation
	
	if not effective then
		_, effective, _, _, _ = UnitArmor("player")
	end
	
	if level < 60 then
		mitigation = (effective/(effective + 400 + (85 * level)));
	else
		mitigation = (effective/(effective + (467.5 * level - 22167.5)));
	end
	if mitigation > .75 then
		mitigation = .75
	end
	return mitigation
end

local function AddTooltipHeader(description)
	GameTooltip:AddLine(description)
end

local function ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", xoff, yoff)
	GameTooltip:ClearLines()
	
	if R.Role == "Tank" then
		AddTooltipHeader(L["等级缓和"]..": ")
		local lv = R.level +3
		for i = 1, 4 do
			GameTooltip:AddDoubleLine(lv,format(chanceString, CalculateMitigation(lv, effectiveArmor) * 100),1,1,1)
			lv = lv - 1
		end
		lv = UnitLevel("target")
		if lv and lv > 0 and (lv > R.level + 3 or lv < R.level) then
			GameTooltip:AddDoubleLine(lv, format(chanceString, CalculateMitigation(lv, effectiveArmor) * 100),1,1,1)
		end	
	elseif R.Role == "Caster" or R.Role == "Melee" then
		AddTooltipHeader(MAGIC_RESISTANCES_COLON)
		
		local baseResistance, effectiveResistance, posResitance, negResistance
		for i = 2, 6 do
			baseResistance, effectiveResistance, posResitance, negResistance = UnitResistance("player", i)
			GameTooltip:AddDoubleLine(_G["DAMAGE_SCHOOL"..(i+1)], format(chanceString, (effectiveResistance / (effectiveResistance + (500 + R.level + 2.5))) * 100),1,1,1)
		end
		
		local spellpen = GetSpellPenetration()
		if (R.myclass == "SHAMAN" or R.Role == "Caster") and spellpen > 0 then
			GameTooltip:AddLine' '
			GameTooltip:AddDoubleLine(ITEM_MOD_SPELL_PENETRATION_SHORT, spellpen,1,1,1)
		end
	end
	GameTooltip:Show()
end

local function UpdateTank(self)
	baseArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
	
	Text:SetFormattedText(displayNumberString, armorString, effectiveArmor)
	--Setup Tooltip
	self:SetAllPoints(Text)
end

local function UpdateCaster(self)
	local spellcrit = GetSpellCritChance(1)

	Text:SetFormattedText(displayFloatString, L["致命"]..": ", spellcrit)
	--Setup Tooltip
	self:SetAllPoints(Text)
end

local function UpdateMelee(self)
	local meleecrit = GetCritChance()
	local rangedcrit = GetRangedCritChance()
	local critChance
		
	if R.myclass == "HUNTER" then    
		critChance = rangedcrit
	else
		critChance = meleecrit
	end
	
	Text:SetFormattedText(displayFloatString, L["致命"]..": ", critChance)
	--Setup Tooltip
	self:SetAllPoints(Text)
end

-- initial delay for update (let the ui load)
local int = 5	
local function Update(self, t)
	int = int - t
	if int > 0 then return end
	
	if R.Role == "Tank" then
		UpdateTank(self)
	elseif R.Role == "Caster" then
		UpdateCaster(self)
	elseif R.Role == "Melee" then
		UpdateMelee(self)		
	end
	int = 2
end

Stat:SetScript("OnEnter", function() ShowTooltip(Stat) end)
Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
Stat:SetScript("OnUpdate", Update)
Update(Stat, 6)
