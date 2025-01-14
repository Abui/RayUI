---------------------
-- HatTrick
---------------------

local hcheck = CreateFrame("CheckButton", "HelmCheckBox", PaperDollFrame, "OptionsCheckButtonTemplate")
hcheck:SetSize(22, 22)
hcheck:SetPoint("TOPLEFT", CharacterHeadSlot, "BOTTOMRIGHT", 5, 5)
hcheck:SetScript("OnClick", function () ShowHelm(not ShowingHelm()) end)
hcheck:SetScript("OnEnter", function ()
 	GameTooltip:SetOwner(hcheck, "ANCHOR_RIGHT")
	GameTooltip:SetText("开关头盔显示.")
end)
hcheck:SetScript("OnLeave", function () GameTooltip:Hide() end)
hcheck:SetFrameStrata("HIGH")

local ccheck = CreateFrame("CheckButton", "CloakCheckBox", PaperDollFrame, "OptionsCheckButtonTemplate")
ccheck:SetSize(22, 22)
ccheck:SetPoint("TOPLEFT", CharacterBackSlot, "BOTTOMRIGHT", 5, 5)
ccheck:SetScript("OnClick", function () ShowCloak(not ShowingCloak()) end)
ccheck:SetScript("OnEnter", function ()
	GameTooltip:SetOwner(ccheck, "ANCHOR_RIGHT")
	GameTooltip:SetText("开关披风显示.")
end)
ccheck:SetScript("OnLeave", function () GameTooltip:Hide() end)
ccheck:SetFrameStrata("HIGH")

hcheck:SetChecked(ShowingHelm())
ccheck:SetChecked(ShowingCloak())

hooksecurefunc("ShowHelm", function(v) hcheck:SetChecked(v) end)
hooksecurefunc("ShowCloak", function(v)	ccheck:SetChecked(v) end)