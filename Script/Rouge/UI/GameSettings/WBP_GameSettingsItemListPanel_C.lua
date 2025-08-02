local WBP_GameSettingsItemListPanel_C = UnLua.Class()

function WBP_GameSettingsItemListPanel_C:Show(TagName)
  self.TagName = TagName
  local LabelRowInfo = LogicGameSetting.GetLabelRowInfo(self.TagName)
  if not LabelRowInfo then
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_LabelName:SetText(LabelRowInfo.Name)
  self:RefreshItemList()
end

function WBP_GameSettingsItemListPanel_C:RefreshItemList()
  local AllChild = self.ItemList:GetAllChildren()
  for i, SingleChild in pairs(AllChild) do
    SingleChild:Hide()
  end
  local ItemTagList = LogicGameSetting.GetSettingsBySecondLabel(self.TagName)
  if ItemTagList then
    local Index = 1
    for i, SingleTag in ipairs(ItemTagList) do
      local Item = self.ItemList:GetChildAt(Index - 1)
      if not Item then
        Item = UE.UWidgetBlueprintLibrary.Create(self, self.ItemTemplate:StaticClass())
        self.ItemList:AddChild(Item)
      end
      Item:Show(SingleTag)
      Item:SetNavigationRuleCustom(UE.EUINavigation.Left, {
        self,
        self.DoCustomNavigation
      })
      Item:SetNavigationRuleBase(UE.EUINavigation.Right, UE.EUINavigationRule.Stop)
      Index = Index + 1
    end
  end
end

function WBP_GameSettingsItemListPanel_C:DoCustomNavigation(Type)
  EventSystem.Invoke(EventDef.GameSettings.OnItemNavigation, Type)
end

function WBP_GameSettingsItemListPanel_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  local AllChild = self.ItemList:GetAllChildren()
  for i, SingleChild in pairs(AllChild) do
    SingleChild:Hide()
  end
end

return WBP_GameSettingsItemListPanel_C
