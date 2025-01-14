local R, C, L, DB = unpack(select(2, ...))

--Dummy Bar
--/run TimerTracker_OnLoad(TimerTracker); TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, 30, 30)

local function SkinIt(bar)
	for i=1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			region:SetFont(C["media"].font,C["media"].fontsize, "THINOUTLINE")
			region:SetShadowColor(0,0,0,0)
		end
	end
	
	bar:SetStatusBarTexture(C["media"].normal)
	bar:SetStatusBarColor(95/255, 182/255, 255/255)
	
	local spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
	spark:SetBlendMode("ADD")
	spark:SetAlpha(.8)
	spark:Point("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT", -10, 13)
	spark:Point("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -13)
	
	bar.backdrop = CreateFrame("Frame", nil, bar)
	bar.backdrop:SetFrameLevel(0)
	bar.backdrop:CreateShadow("Background")
	bar.backdrop:Point("TOPLEFT", bar, "TOPLEFT", -2, 2)
	bar.backdrop:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
end

local function SkinBlizzTimer()	
	for _, b in pairs(TimerTracker.timerList) do
		if b["bar"] and not b["bar"].skinned then
			SkinIt(b["bar"])
			b["bar"].skinned = true
		end
	end
end

local load = CreateFrame("Frame")
load:RegisterEvent("START_TIMER")
load:SetScript("OnEvent", SkinBlizzTimer)