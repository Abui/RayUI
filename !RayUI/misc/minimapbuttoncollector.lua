local BlackList = { 
	["MiniMapTracking"] = true,
	["MiniMapVoiceChatFrame"] = true,
	["MiniMapWorldMapButton"] = true,
	["MiniMapLFGFrame"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["MiniMapMailFrame"] = true,
	["MiniMapBattlefieldFrame"] = true,
	["MinimapBackdrop"] = true,
	["GameTimeFrame"] = true,
	["TimeManagerClockButton"] = true,
	["FeedbackUIButton"] = true,
}

local buttons = {}
local MBCF = CreateFrame("Frame", "MinimapButtonCollectFrame", UIParent)
if select(3, Minimap:GetPoint()):upper():find("TOP") then
	MBCF:SetPoint("BOTTOMLEFT", Minimap, "TOPLEFT", 0, 5)
else
	MBCF:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -5)
end
MBCF:SetFrameStrata("BACKGROUND")
MBCF:SetFrameLevel(1)
MBCF.bg = MBCF:CreateTexture(nil, "BACKGROUND")
MBCF.bg:SetAllPoints(MBCF)

local function PositionAndStyle()
	MBCF.bg:SetTexture(0, 0, 0, 1)
	MBCF:SetAlpha(0)
	if select(3, Minimap:GetPoint()):upper():find("TOP") then
		MBCF:SetSize(20, 150)
		MBCF:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 5, 2)
		MBCF.bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, .6)
		for i =1, #buttons do
			buttons[i]:ClearAllPoints()
			buttons[i]:SetPoint("TOP", MinimapButtonCollectFrame, "TOP", 0,  - (i - 1) * 30)
		end
	else
		MBCF:SetSize(150, 20)
		MBCF:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 2, -5)
		MBCF.bg:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 0, 0, 0, .6)
		for i =1, #buttons do
			buttons[i]:ClearAllPoints()
			buttons[i]:SetPoint("RIGHT", MinimapButtonCollectFrame, "RIGHT", - (i - 1) * 30 , 0)
		end
	end
end

local MinimapButtonCollect = CreateFrame("Frame")
MinimapButtonCollect:RegisterEvent("PLAYER_ENTERING_WORLD")
MinimapButtonCollect:SetScript("OnEvent", function(self)
	for i, child in ipairs({Minimap:GetChildren()}) do
		if not BlackList[child:GetName()] then
			if child:GetObjectType() == 'Button' and child:GetNumRegions() >= 3 then
				child:SetParent("MinimapButtonCollectFrame")
				for j = 1, child:GetNumRegions() do
					if select(j, child:GetRegions()):GetTexture():find("Highlight") then
						select(j, child:GetRegions()):Kill()
					end
				end
				tinsert(buttons, child)
			end
		end
	end
	if #buttons == 0 then 
		MBCF:Hide() 
	else
		for _, child in ipairs(buttons) do
			child:HookScript("OnEnter", function()
				UIFrameFadeIn(MBCF, .5, MBCF:GetAlpha(), 1)
			end)
			child:HookScript("OnLeave", function()
				UIFrameFadeOut(MBCF, .5, MBCF:GetAlpha(), 0)
			end)
		end
	end
	PositionAndStyle()
end)

MBCF:SetScript("OnEnter", function(self)
	UIFrameFadeIn(self, .5, self:GetAlpha(), 1)
end)

Minimap:HookScript("OnEnter", function()
	UIFrameFadeIn(MBCF, .5, MBCF:GetAlpha(), 1)
end)

MBCF:SetScript("OnLeave", function(self)
	UIFrameFadeOut(self, .5, self:GetAlpha(), 0)
end)

Minimap:HookScript("OnLeave", function()
	UIFrameFadeOut(MBCF, .5, MBCF:GetAlpha(), 0)
end)

hooksecurefunc(Minimap, "SetPoint", function()
			MBCF:ClearAllPoints()
			PositionAndStyle()
		end)