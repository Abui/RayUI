local R, C, L, DB = unpack(select(2, ...))

local function ReskinDropDown(f)
	local frame = f:GetName()

	local left = _G[frame.."Left"]
	local middle = _G[frame.."Middle"]
	local right = _G[frame.."Right"]

	if left then left:SetAlpha(0) end
	if middle then middle:SetAlpha(0) end
	if right then right:SetAlpha(0) end

	local down = _G[frame.."Button"]

	down:Size(20, 20)
	down:ClearAllPoints()
	down:Point("RIGHT", -18, 2)

	R.Reskin(down)
	
	down:SetDisabledTexture(C.Aurora.backdrop)
	local dis = down:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")

	local downtex = down:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture("Interface\\AddOns\\!RayUI\\Aurora\\arrow-down-active")
	downtex:Size(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)

	local bg = CreateFrame("Frame", nil, f)
	bg:Point("TOPLEFT", 16, -4)
	bg:Point("BOTTOMRIGHT", 90, 8)
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	R.CreateBD(bg, 0)

	local tex = bg:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(C.Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)
end

ACP_AddonList:SetScript("OnShow", function(self)
	if ACP_AddonList.bg then return end
	ACP_AddonList:StripTextures()
	ACP_AddonList.bg = CreateFrame("Frame", nil, ACP_AddonList)
	ACP_AddonList.bg:SetPoint("TOPLEFT")
	ACP_AddonList.bg:SetPoint("BOTTOMRIGHT", -30, 0)
	R.SetBD(ACP_AddonList.bg)
	ReskinDropDown(ACP_AddonListSortDropDown)
	ACP_AddonListSortDropDownButton:ClearAllPoints()
	ACP_AddonListSortDropDownButton:SetPoint("LEFT", ACP_AddonListSortDropDown, "RIGHT", 91, 2)
	R.Reskin(ACP_AddonListSetButton)
	R.Reskin(ACP_AddonListDisableAll)
	R.Reskin(ACP_AddonListEnableAll)
	R.Reskin(ACP_AddonList_ReloadUI)
	R.Reskin(ACP_AddonListBottomClose)
	R.ReskinClose(ACP_AddonListCloseButton)
	ACP_AddonListCloseButton:ClearAllPoints()
	ACP_AddonListCloseButton:SetPoint("TOPRIGHT", ACP_AddonList.bg, "TOPRIGHT", -10, -10)
	ACP_AddonList_ScrollFrame:StripTextures()
	R.ReskinScroll(ACP_AddonList_ScrollFrameScrollBar)
end)