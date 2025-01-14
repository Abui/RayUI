local R, C, L, DB = unpack(select(2, ...))

local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI then return end

local oldRegisterAsWidget = AceGUI.RegisterAsWidget

AceGUI.RegisterAsWidget = function(self, widget)
	local TYPE = widget.type
	--print(TYPE)
	if TYPE == "CheckBox" then
		widget.checkbg:Kill()
		widget.highlight:Kill()

		if not widget.skinnedCheckBG then
			widget.skinnedCheckBG = CreateFrame('Frame', nil, widget.frame)
			widget.skinnedCheckBG:SetTemplate('Transparent')
			widget.skinnedCheckBG:CreateBorder(.2, .2, .2)
			widget.skinnedCheckBG:Point('TOPLEFT', widget.checkbg, 'TOPLEFT', 4, -4)
			widget.skinnedCheckBG:Point('BOTTOMRIGHT', widget.checkbg, 'BOTTOMRIGHT', -4, 4)
		end

		if widget.skinnedCheckBG.oborder then
			widget.check:SetParent(widget.skinnedCheckBG.oborder)
		else
			widget.check:SetParent(widget.skinnedCheckBG)
		end
	elseif TYPE == "Dropdown" then
		local frame = widget.dropdown
		local button = widget.button
		local text = widget.text
		frame:StripTextures()
		local bg = CreateFrame("Frame", nil, frame)
		bg:Point("TOPLEFT", 16, -1)
		bg:Point("BOTTOMRIGHT", -20, -1)
		bg:SetFrameLevel(frame:GetFrameLevel()-1)
		R.CreateBD(bg, 0)

		local tex = bg:CreateTexture(nil, "BACKGROUND")
		tex:SetPoint("TOPLEFT")
		tex:SetPoint("BOTTOMRIGHT")
		tex:SetTexture(C.Aurora.backdrop)
		tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)

		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -20, 0)
	
		button:SetDisabledTexture(C.Aurora.backdrop)
		local dis = button:GetDisabledTexture()
		dis:SetVertexColor(0, 0, 0, .3)
		dis:SetDrawLayer("OVERLAY")

		local downtex = button:CreateTexture(nil, "ARTWORK")
		downtex:SetTexture("Interface\\AddOns\\!RayUI\\Aurora\\arrow-down-active")
		downtex:Size(8, 8)
		downtex:SetPoint("CENTER")
		downtex:SetVertexColor(1, 1, 1)

		if not frame.backdrop then
			-- frame:CreateBackdrop("Default")
			frame.backdrop =CreateFrame("Frame", nil , frame)
			frame.backdrop:Point("TOPLEFT", 20, -2)
			frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		end
		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
		button:HookScript('OnClick', function(this)
			local self = this.obj
			self.pullout.frame:SetTemplate('Default', true)
		end)	
	elseif TYPE == "LSM30_Font" or TYPE == "LSM30_Sound" or TYPE == "LSM30_Border" or TYPE == "LSM30_Background" or TYPE == "LSM30_Statusbar" then
		local frame = widget.frame
		local button = frame.dropButton
		local text = frame.text
		frame:StripTextures()

		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -20, 0)
		R.Reskin(button)
	
		button:SetDisabledTexture(C.Aurora.backdrop)
		local dis = button:GetDisabledTexture()
		dis:SetVertexColor(0, 0, 0, .3)
		dis:SetDrawLayer("OVERLAY")

		local downtex = button:CreateTexture(nil, "ARTWORK")
		downtex:SetTexture("Interface\\AddOns\\!RayUI\\Aurora\\arrow-down-active")
		downtex:Size(8, 8)
		downtex:SetPoint("CENTER")
		downtex:SetVertexColor(1, 1, 1)
		frame.text:ClearAllPoints()
		frame.text:Point('RIGHT', button, 'LEFT', -2, 0)

		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -10, -6)

		if not frame.backdrop then
			frame:CreateBackdrop("Default")
			if TYPE == "LSM30_Font" then
				frame.backdrop:Point("TOPLEFT", 20, -17)
			elseif TYPE == "LSM30_Sound" then
				frame.backdrop:Point("TOPLEFT", 20, -17)
				widget.soundbutton:SetParent(frame.backdrop)
				widget.soundbutton:ClearAllPoints()
				widget.soundbutton:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
			elseif TYPE == "LSM30_Statusbar" then
				frame.backdrop:Point("TOPLEFT", 20, -17)
				widget.bar:ClearAllPoints()
				widget.bar:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 2, -2)
				widget.bar:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)
				widget.bar:SetParent(frame.backdrop)
			elseif TYPE == "LSM30_Border" or TYPE == "LSM30_Background" then
				frame.backdrop:Point("TOPLEFT", 42, -16)
			end

			frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		end
		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
		button:HookScript('OnClick', function(this, button)
			local self = this.obj
			if self.dropdown then
				self.dropdown:SetTemplate('Default', true)
			end
		end)		
	elseif TYPE == "EditBox" then
		local frame = widget.editbox
		local button = widget.button
		_G[frame:GetName()..'Left']:Kill()
		_G[frame:GetName()..'Middle']:Kill()
		_G[frame:GetName()..'Right']:Kill()
		frame:Height(17)
		-- frame:CreateBackdrop('Default')
		-- frame.backdrop =CreateFrame("Frame", nil , frame)
		-- frame.backdrop:Point('TOPLEFT', -2, 0)
		-- frame.backdrop:Point('BOTTOMRIGHT', 2, 0)		
		-- frame.backdrop:SetParent(widget.frame)
		-- frame:SetParent(frame.backdrop)
		R.ReskinInput(frame)
		R.Reskin(button)
	elseif TYPE == "Button" then
		local frame = widget.frame
		R.Reskin(frame)
		-- frame:StripTextures()
		-- frame.backdrop =CreateFrame("Frame", nil , frame)
		-- frame.backdrop:Point("TOPLEFT", 2, -2)
		-- frame.backdrop:Point("BOTTOMRIGHT", -2, 2)
		-- widget.text:SetParent(frame.backdrop)
	elseif TYPE == "Slider" then
		-- local frame = widget.slider
		-- local editbox = widget.editbox
		-- local lowtext = widget.lowtext
		-- local hightext = widget.hightext
		-- local HEIGHT = 12

		-- frame:StripTextures()
		-- frame:SetTemplate('Transparent')
		-- frame:Height(HEIGHT)
		-- frame:SetThumbTexture(C["media"].blank)
		-- frame:GetThumbTexture():SetVertexColor(1,1,1)
		-- frame:GetThumbTexture():Size(HEIGHT-2,HEIGHT+2)

		-- editbox:SetTemplate('Transparent')
		-- editbox:Height(15)
		-- editbox:Point("TOP", frame, "BOTTOM", 0, -1)

		-- lowtext:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 2, -2)
		-- hightext:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -2, -2)


	--[[elseif TYPE == "ColorPicker" then
		local frame = widget.frame
		local colorSwatch = widget.colorSwatch
	]]
	end
	return oldRegisterAsWidget(self, widget)
end

local oldRegisterAsContainer = AceGUI.RegisterAsContainer

AceGUI.RegisterAsContainer = function(self, widget)
	local TYPE = widget.type
	if TYPE == "ScrollFrame" then
		local frame = widget.scrollbar
		R.ReskinScroll(frame)
	elseif TYPE == "InlineGroup" or TYPE == "TreeGroup" or TYPE == "TabGroup" or TYPE == "SimpleGroup" or TYPE == "Frame" or TYPE == "DropdownGroup" then
		local frame = widget.content:GetParent()
		if TYPE == "Frame" then
			frame:StripTextures()
			for i=1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child:GetObjectType() == "Button" and child:GetText() then
					R.Reskin(child)
				else
					child:StripTextures()
				end
			end
			frame.bg = CreateFrame("Frame", nil , frame)
			frame.bg:Point("TOPLEFT", -4, 4)
			frame.bg:Point("BOTTOMRIGHT", 4, -4)
			frame.bg:CreateShadow()
		else
			frame.bd = CreateFrame("Frame", nil , frame)
			frame.bd:SetPoint("TOPLEFT")
			frame.bd:SetPoint("BOTTOMRIGHT")
			frame.bd:CreateBorder(0.2,0.2,0.2,1)
		end	
		frame:SetTemplate('Transparent')
		
		if widget.treeframe then
			widget.treeframe:SetTemplate('Transparent')
			widget.treeframe.bd = CreateFrame("Frame", nil , widget.treeframe)
			widget.treeframe.bd:SetPoint("TOPLEFT")
			widget.treeframe.bd:SetPoint("BOTTOMRIGHT")
			widget.treeframe.bd:CreateBorder(0.2,0.2,0.2,1)
			frame:Point("TOPLEFT", widget.treeframe, "TOPRIGHT", 1, 0)
		end

		if TYPE == "TabGroup" then
			local oldCreateTab = widget.CreateTab
			widget.CreateTab = function(self, id)
				local tab = oldCreateTab(self, id)
				tab:StripTextures()			
				return tab
			end
		end
	end

	return oldRegisterAsContainer(self, widget)
end