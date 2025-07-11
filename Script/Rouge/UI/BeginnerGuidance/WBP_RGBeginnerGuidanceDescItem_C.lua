local WBP_RGBeginnerGuidanceDescItem_C = UnLua.Class()
function WBP_RGBeginnerGuidanceDescItem_C:Construct()
end
function WBP_RGBeginnerGuidanceDescItem_C:ShowFlagPanel()
  self.FlagPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_RGBeginnerGuidanceDescItem_C:SetFlagSelectedPanelVis(IsShow)
  if IsShow then
    self.FinishedPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.FinishedPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_RGBeginnerGuidanceDescItem_C:UpdateText(Desc, KeyInfoList)
  if not KeyInfoList or KeyInfoList:Length() <= 0 then
    self.Txt_LeftText:SetText(Desc)
    self.KeyList:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_RightText:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.IsLeftText = true
    self.OriginText = Desc
  else
    local Result, LeftStr, RightStr = UE.UKismetStringLibrary.Split(Desc, "{0}", nil, nil, UE.ESearchCase.IgnoreCase, UE.ESearchDir.FromStart)
    if not Result then
      self.Txt_LeftText:SetText(Desc)
      self.KeyList:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.Txt_RightText:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.IsLeftText = true
      self.OriginText = Desc
    else
      self.KeyList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Txt_LeftText:SetText(LeftStr)
      self.Txt_RightText:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Txt_RightText:SetText(RightStr)
      local AllChildren = self.KeyList:GetAllChildren()
      for key, SingleItem in pairs(AllChildren) do
        SingleItem:Hide()
      end
      for Index, SingleKeyRowName in pairs(KeyInfoList) do
        local Item = self.KeyList:GetChildAt(Index - 1)
        if not Item then
          Item = UE.UWidgetBlueprintLibrary.Create(self, self.CustomKeyNameTemplate:StaticClass())
          Item:SetCustomKeyDisplayInfo(self.CustomKeyNameTemplate.CustomKeyDisplayInfo)
          local Slot = self.KeyList:AddChild(Item)
          Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Left)
          Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Center)
          Slot:SetPadding(self.KeyPadding)
        end
        Item:SetCustomKeyConfig(SingleKeyRowName, nil)
      end
      self.IsLeftText = false
      self.OriginText = RightStr
    end
  end
end
return WBP_RGBeginnerGuidanceDescItem_C
