local R, C, DB = unpack(select(2, ...))

local autoreleasepvp = CreateFrame("frame")
autoreleasepvp:RegisterEvent("PLAYER_DEAD")
autoreleasepvp:SetScript("OnEvent", function(self, event)
	local soulstone = GetSpellInfo(20707)
	if ((R.myclass ~= "SHAMAN") and not (soulstone and UnitBuff("player", soulstone))) and MiniMapBattlefieldFrame.status == "active" then
		RepopMe()
	end
end)