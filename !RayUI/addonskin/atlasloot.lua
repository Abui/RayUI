﻿local R, C, L, DB = unpack(select(2, ...))

if not IsAddOnLoaded("AtlasLoot") then return end

local function AL_OnShow(self, event, ...)

	-- Move Positions
	AtlasLootPanel:Point("TOP", AtlasLootDefaultFrame, "BOTTOM", 0, -5)
	AtlasLootQuickLooksButton:Point("BOTTOM", AtlasLootItemsFrame, "BOTTOM", 53, 33)
	AtlasLootPanelSearch_Box:ClearAllPoints()
	AtlasLootPanelSearch_Box:Point("TOP", AtlasLoot_PanelButton_7, "BOTTOM", 80, -10)
	AtlasLootPanelSearch_SearchButton:Point("LEFT", AtlasLootPanelSearch_Box, "RIGHT", 5, 0)
	AtlasLootPanelSearch_SelectModuel:Point("LEFT", AtlasLootPanelSearch_SearchButton, "RIGHT", 5, 0)
	AtlasLootPanelSearch_ClearButton:Point("LEFT", AtlasLootPanelSearch_SelectModuel, "RIGHT", 5, 0)
	AtlasLootPanelSearch_LastResultButton:Point("LEFT", AtlasLootPanelSearch_ClearButton, "RIGHT", 5, 0)
	AtlasLoot10Man25ManSwitch:Point("BOTTOM", AtlasLootItemsFrame, "BOTTOM", -130, 4)
	AtlasLootServerQueryButton:Point("BOTTOM", AtlasLootItemsFrame, "BOTTOM", 130, 4)
	AtlasLoot_PanelButton_2:Point("LEFT", AtlasLoot_PanelButton_1, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_3:Point("LEFT", AtlasLoot_PanelButton_2, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_4:Point("LEFT", AtlasLoot_PanelButton_3, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_5:Point("LEFT", AtlasLoot_PanelButton_4, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_6:Point("LEFT", AtlasLoot_PanelButton_5, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_8:Point("LEFT", AtlasLoot_PanelButton_7, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_9:Point("LEFT", AtlasLoot_PanelButton_8, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_10:Point("LEFT", AtlasLoot_PanelButton_9, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_11:Point("LEFT", AtlasLoot_PanelButton_10, "RIGHT", 1, 0)
	AtlasLoot_PanelButton_12:Point("LEFT", AtlasLoot_PanelButton_11, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_Rarity:Point("LEFT", AtlasLootCompareFrameSortButton_Name, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_1:Point("LEFT", AtlasLootCompareFrameSortButton_Rarity, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_2:Point("LEFT", AtlasLootCompareFrameSortButton_1, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_3:Point("LEFT", AtlasLootCompareFrameSortButton_2, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_4:Point("LEFT", AtlasLootCompareFrameSortButton_3, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_5:Point("LEFT", AtlasLootCompareFrameSortButton_4, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_6:Point("LEFT", AtlasLootCompareFrameSortButton_5, "RIGHT", 1, 0)
	AtlasLootCompareFrame_CloseButton2:Point("BOTTOMRIGHT", AtlasLootCompareFrame, "BOTTOMRIGHT", -7, 10)
	AtlasLootCompareFrame_WishlistButton:Point("RIGHT", AtlasLootCompareFrame_CloseButton2, "LEFT", -1, 0)
	AtlasLootCompareFrameSearch_SearchButton:Point("LEFT", AtlasLootCompareFrameSearch_Box, "RIGHT", 5, 0)
	AtlasLootCompareFrameSearch_SelectModuel:Point("LEFT", AtlasLootCompareFrameSearch_SearchButton, "RIGHT", 5, 0)
	-- Set Sizes
	local AL = ""
		if AL == "" then
			AtlasLootPanelSearch_Box:SetHeight(16)
			AtlasLootPanel:SetWidth(921)
		end
		R.ReskinClose(AtlasLootDefaultFrame_LockButton)
end

local function Nine_IsThere(Self, event, ...)
				
				for i = 1, 9 do 
						local f = _G["AtlasLootCompareFrameSortButton_"..i]
						f:SetWidth(44.44)
				end
				
		local StripAllTextures = {
				"AtlasLootCompareFrameSortButton_7",
				"AtlasLootCompareFrameSortButton_8",
				"AtlasLootCompareFrameSortButton_9",
				}

	local SetTemplateD = { -- Default Texture
				"AtlasLootCompareFrameSortButton_7",
				"AtlasLootCompareFrameSortButton_8",
				"AtlasLootCompareFrameSortButton_9",
				}

				for _, object in pairs(StripAllTextures) do
							_G[object]:StripTextures()
				end	

				for _, object in pairs(SetTemplateD) do
					R.CreateBD(_G[object])
				end		

	AtlasLootCompareFrameSortButton_7:Point("LEFT", AtlasLootCompareFrameSortButton_6, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_8:Point("LEFT", AtlasLootCompareFrameSortButton_7, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_9:Point("LEFT", AtlasLootCompareFrameSortButton_8, "RIGHT", 1, 0)
				
end

local function Compare_OnShow(self, event, ...)

				for i = 1, 6 do 
						local f = _G["AtlasLootCompareFrameSortButton_"..i]
						f:SetWidth(67.17)
				end
	
				local Nine = AtlasLootCompareFrameSortButton_9
					if Nine ~= nil then
					Nine:SetScript("OnUpdate", Nine_IsThere)
					else
					end	
end

local SkinAL = CreateFrame("Frame")
	SkinAL:RegisterEvent("PLAYER_ENTERING_WORLD")
	SkinAL:SetScript("OnEvent", function(self, event, addon)
	if IsAddOnLoaded("Skinner") then return end
			
		local FrameShow = AtlasLootDefaultFrame
		FrameShow:SetScript("OnUpdate", AL_OnShow)
		
		local CompareFrameShow = AtlasLootCompareFrame
		CompareFrameShow:SetScript("OnUpdate", Compare_OnShow)
		

			--start		
	local StripAllTextures = {
                "AtlasLootDefaultFrame",
                "AtlasLootItemsFrame",
				"AtlasLootPanel",
				"AtlasLootCompareFrame",
				"AtlasLootCompareFrame_ScrollFrameMainFilterScrollChildFrame",
				"AtlasLootCompareFrame_ScrollFrameItemFrame",
				"AtlasLootCompareFrame_ScrollFrameMainFilter",
				"AtlasLootCompareFrameSortButton_Name",
				"AtlasLootCompareFrameSortButton_Rarity",
				"AtlasLootCompareFrameSortButton_1",
				"AtlasLootCompareFrameSortButton_2",
				"AtlasLootCompareFrameSortButton_3",
				"AtlasLootCompareFrameSortButton_4",
				"AtlasLootCompareFrameSortButton_5",
				"AtlasLootCompareFrameSortButton_6",
				}

	local SetTemplateD = { -- Default Texture
                "AtlasLootItemsFrame",
				"AtlasLootCompareFrameSortButton_Name",
				"AtlasLootCompareFrameSortButton_Rarity",
				"AtlasLootCompareFrameSortButton_1",
				"AtlasLootCompareFrameSortButton_2",
				"AtlasLootCompareFrameSortButton_3",
				"AtlasLootCompareFrameSortButton_4",
				"AtlasLootCompareFrameSortButton_5",
				"AtlasLootCompareFrameSortButton_6",
				}

	local SetTemplateT = {-- Transparent Texture
                "AtlasLootDefaultFrame",
                "AtlasLootPanel",
				"AtlasLootCompareFrame",
				}	
	
	local buttons = {
                "AtlasLoot_AtlasInfoFrame_ToggleALButton",
                "AtlasLootServerQueryButton",
                "AtlasLootPanelSearch_SearchButton",
                "AtlasLootDefaultFrame_CompareFrame",
				"AtlasLootPanelSearch_ClearButton",
				"AtlasLootPanelSearch_LastResultButton",
				"AtlasLoot10Man25ManSwitch",
				"AtlasLootItemsFrame_BACK",
				"AtlasLootCompareFrameSearch_ClearButton",
				"AtlasLootCompareFrameSearch_SearchButton",
				"AtlasLootCompareFrame_WishlistButton",
				"AtlasLootCompareFrame_CloseButton2",
				}
							
				for _, object in pairs(StripAllTextures) do
							_G[object]:StripTextures()
				end	

				for _, object in pairs(SetTemplateD) do
							R.CreateBD(_G[object])
				end	

				for _, object in pairs(SetTemplateT) do
							R.CreateBD(_G[object])
							R.CreateSD(_G[object])
				end			
	
	-- Skin Buttons
				for _, button in pairs(buttons) do
								R.Reskin(_G[button])
				end	
	
				for i = 1, 12 do
					local f = _G["AtlasLoot_PanelButton_"..i]
					R.Reskin(f)
				end
				for i = 1, 15 do -- 15 that I could find
					local f = _G["AtlasLootCompareFrameMainFilterButton"..i]
					f:StripTextures()
				end
				
	-- Skin Close Buttons
		R.ReskinClose(AtlasLootDefaultFrame_CloseButton)
		R.ReskinClose(AtlasLootDefaultFrame_LockButton)
		R.ReskinClose(AtlasLootCompareFrame_CloseButton)
		R.ReskinClose( AtlasLootCompareFrame_CloseButton_Wishlist)
	
	-- Skin Next Previous Buttons	
		R.ReskinArrow(AtlasLootQuickLooksButton, 2)
		R.ReskinArrow(AtlasLootItemsFrame_NEXT, 2)
		R.ReskinArrow(AtlasLootItemsFrame_PREV, 1)
		R.ReskinArrow(AtlasLootPanelSearch_SelectModuel, 2)	
		R.ReskinArrow(AtlasLootCompareFrameSearch_SelectModuel, 2)		
	
	-- Skin Dropdown Boxes		
		R.ReskinDropDown(AtlasLootDefaultFrame_ModuleSelect, 225)
		R.ReskinDropDown(AtlasLootDefaultFrame_InstanceSelect, 225)
		R.ReskinDropDown(AtlasLootCompareFrameSearch_StatsListDropDown,240)
		R.ReskinDropDown(AtlasLootCompareFrame_WishlistDropDown,200)
		
	-- Skin Edit Boxes
		R.ReskinInput(AtlasLootPanelSearch_Box)
		R.ReskinInput(AtlasLootCompareFrameSearch_Box)
		
	-- Skin Check Boxes
		R.ReskinCheck(AtlasLootFilterCheck)
		R.ReskinCheck(AtlasLootItemsFrame_Heroic)
		R.ReskinCheck(AtlasLootCompareFrameSearch_FilterCheck)
		
		select(5,AtlasLootItemsFrame_NEXT:GetRegions()):Kill()
		select(5,AtlasLootItemsFrame_PREV:GetRegions()):Kill()
		
		AtlasLootTooltip:HookScript("OnShow", function(self)
			R.CreateBD(self)
			local item
			if self.GetItem then
				item = select(2, self:GetItem())
			end
			if item then
				local quality = select(3, GetItemInfo(item))
				if quality and quality > 1 then
					local r, g, b = GetItemQualityColor(quality)
					self:SetBackdropBorderColor(r, g, b)
				end
			else
				self:SetBackdropBorderColor(0, 0, 0)
			end
			if self.NumLines then
				for index=1, self:NumLines() do
					_G[self:GetName()..'TextLeft'..index]:SetShadowOffset(R.mult, -R.mult)
				end
			end
		end)
	AtlasLootTooltip:HookScript("OnHide", function(self)
			self:SetBackdropBorderColor(0, 0, 0, 1)
		end)
end)