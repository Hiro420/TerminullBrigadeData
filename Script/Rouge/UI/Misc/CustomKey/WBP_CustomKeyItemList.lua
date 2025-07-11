local WBP_CustomKeyItemList = UnLua.Class()
function WBP_CustomKeyItemList:Show(LabelName, LabelKeyNames, InputType)
  UpdateVisibility(self, true)
  self.LabelName = LabelName
  self.LabelKeyNames = LabelKeyNames
  local Result, LabelRowInfo = GetRowData(DT.DT_CustomKeyLabel, LabelName)
  if not Result then
    return
  end
  self.Txt_LabelName:SetText(LabelRowInfo.Name)
  local Index = 1
  for i, SingleRowName in ipairs(LabelKeyNames) do
    local Item = GetOrCreateItem(self.ItemList, Index, self.ItemTemplate:StaticClass(), true)
    Item:InitInfo(SingleRowName, InputType)
    Index = Index + 1
  end
  local FirstItem = self.ItemList:GetChildAt(0)
  if FirstItem then
    FirstItem:SetNavigationRuleCustom(UE.EUINavigation.Up, {
      self,
      self.DoCustomNavigation
    })
  end
  HideOtherItem(self.ItemList, Index, true)
  EventSystem.AddListenerNew(EventDef.GameSettings.OnFocusGamePadCustomKeyItem, self, self.BindOnFocusGamePadCustomKeyItem)
end
function WBP_CustomKeyItemList:DoCustomNavigation(Type)
  if Type == UE.EUINavigation.Left then
    EventSystem.Invoke(EventDef.GameSettings.OnItemNavigation, Type)
  elseif Type == UE.EUINavigation.Up then
    EventSystem.Invoke(EventDef.GameSettings.OnGamepadCustomKeyNavitionUp, self.LabelKeyNames[1])
  end
end
function WBP_CustomKeyItemList:BindOnFocusGamePadCustomKeyItem(KeyItemName)
  local Index = table.IndexOf(self.LabelKeyNames, KeyItemName)
  if not Index then
    return
  end
  local TargetItem = self.ItemList:GetChildAt(Index - 1)
  if TargetItem then
    TargetItem:SetKeyboardFocus()
    if TargetItem.CanChange then
      UE.URGBlueprintLibrary.SetTimerForNextTick(TargetItem, {
        TargetItem,
        function()
          TargetItem.InputKeySelector:SetKeyboardFocus()
        end
      })
    end
  end
end
function WBP_CustomKeyItemList:Hide(...)
  UpdateVisibility(self, false)
  local AllChildren = self.ItemList:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  EventSystem.RemoveListenerNew(EventDef.GameSettings.OnFocusGamePadCustomKeyItem, self, self.BindOnFocusGamePadCustomKeyItem)
end
function WBP_CustomKeyItemList:Destruct(...)
  self:Hide()
end
return WBP_CustomKeyItemList
