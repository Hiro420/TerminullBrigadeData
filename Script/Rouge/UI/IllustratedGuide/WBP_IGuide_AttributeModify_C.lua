local WBP_IGuide_AttributeModify_C = UnLua.Class()

function WBP_IGuide_AttributeModify_C:Construct()
  Logic_IllustratedGuide.PullUnLockAttributeModify()
  self:BindFunction()
  self:RefreshSetList()
end

function WBP_IGuide_AttributeModify_C:Destruct()
  self:UnBindFunction()
end

function WBP_IGuide_AttributeModify_C:BindFunction()
  self.SearchBtn.OnClicked:Add(self, WBP_IGuide_AttributeModify_C.ConfirmSearch)
  self.BtnCancelSearch.OnClicked:Add(self, WBP_IGuide_AttributeModify_C.CancelSearch)
  self.SetList.BP_OnItemSelectionChanged:Add(self, WBP_IGuide_AttributeModify_C.OnItemSelectionChanged)
  self.EditableText_Search.OnTextChanged:Add(self, WBP_IGuide_AttributeModify_C.OnSearchTextChanged)
  self.AttributeModifyList.BP_OnItemIsHoveredChanged:Add(self, WBP_IGuide_AttributeModify_C.OnItemHoveredChanged)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.AttributeModifyHoveredTip, WBP_IGuide_AttributeModify_C.RefreshFloatingWindow)
  EventSystem.AddListener(self, EventDef.Lobby.LobbyPanelChanged, self.BindOnLobbyPanelChanged)
end

function WBP_IGuide_AttributeModify_C:BindOnLobbyPanelChanged(LastActiveWidget, CurActiveWidget)
  self:CancelSearch()
end

function WBP_IGuide_AttributeModify_C:UnBindFunction()
  self.SearchBtn.OnClicked:Remove(self, WBP_IGuide_AttributeModify_C.ConfirmSearch)
end

function WBP_IGuide_AttributeModify_C:RefreshSetList()
  local ItemDatas = Logic_IllustratedGuide.GetSetListData()
  ItemDatas = Logic_IllustratedGuide.SortSetListData(ItemDatas)
  UpdateVisibility(self.WBP_AttributeModify_HoveredTip, false)
  self.AttributeModifyList:ClearListItems()
  self.SetList:ClearListItems()
  for key, Data in pairs(ItemDatas) do
    self.SetList:AddItem(Data)
  end
  self.SetList:SetSelectedIndex(0)
end

function WBP_IGuide_AttributeModify_C:ConfirmSearch()
  Logic_IllustratedGuide.SearchKeyword = self.EditableText_Search:GetText()
  self:RefreshSetList()
end

function WBP_IGuide_AttributeModify_C:CancelSearch()
  self.EditableText_Search:SetText("")
  if "" == Logic_IllustratedGuide.SearchKeyword then
    return
  end
  Logic_IllustratedGuide.SearchKeyword = ""
  self.EditableText_Search:SetText("")
  self:RefreshSetList()
end

function WBP_IGuide_AttributeModify_C:RefreshFloatingWindow(ItemWidget, Id, bShow)
  self.WBP_AttributeModify_HoveredTip:SetSelected(self.SetList:BP_GetSelectedItem() and self.SetList:BP_GetSelectedItem().Data.Id == Id)
  self.SetList:BP_GetSelectedItem()
  local CurrentTime = self.WBP_AttributeModify_HoveredTip:GetAnimationCurrentTime(self.WBP_AttributeModify_HoveredTip.Show)
  if bShow then
    UpdateVisibility(self.WBP_AttributeModify_HoveredTip, true)
    self.WBP_AttributeModify_HoveredTip:PlayAnimation(self.WBP_AttributeModify_HoveredTip.Show, CurrentTime, 1, UE.EUMGSequencePlayMode.Forward)
  else
    self.WBP_AttributeModify_HoveredTip:PlayAnimation(self.WBP_AttributeModify_HoveredTip.Show, CurrentTime, 1, UE.EUMGSequencePlayMode.Reverse)
  end
  if ItemWidget then
    local AbsolutePosition = UE.URGBlueprintLibrary.GetAbsolutePosition(ItemWidget:GetCachedGeometry())
    local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(self.CanvasPanel_SetList:GetCachedGeometry(), AbsolutePosition)
    self.WBP_AttributeModify_HoveredTip.Slot:SetPosition(LocalPosition + self.Offset)
  end
end

function WBP_IGuide_AttributeModify_C:OnItemSelectionChanged(Item, IsSelected)
  if IsSelected then
    self.SelectItem = Item
    self.WBP_AttributeModify_HoveredTip:SetSelected(Item.Data.Id == self.WBP_AttributeModify_HoveredTip.HoveredId)
    self:RefreshAttributeModifyList(Item.Data.Id)
  end
end

function WBP_IGuide_AttributeModify_C:RefreshAttributeModifyList(SetId)
  self.AttributeModifyList:ClearListItems()
  for key, value in pairs(Logic_IllustratedGuide.GetAttributeModifyListData(SetId)) do
    self.AttributeModifyList:AddItem(value)
  end
  self.AttributeModifyList:SetSelectedIndex(0)
end

function WBP_IGuide_AttributeModify_C:OnSearchTextChanged(Text)
  UpdateVisibility(self.BtnCancelSearch, "" ~= Text, true)
  if string.len(Text) > self.MaxInputLength then
    self.EditableText_Search:SetText(string.sub(Text, 1, self.MaxInputLength))
  end
end

function WBP_IGuide_AttributeModify_C:OnItemHoveredChanged(item, bHovered)
  if bHovered then
    UpdateVisibility(self.Overlay_WBP_ScrollLegandTips, true)
    self.WBP_ScrollLegandTips:InitScrollLegandItem(item.Data.Id, 0)
    local MousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
    local Size = UE.USlateBlueprintLibrary.GetLocalSize(self.WBP_ScrollLegandTips:GetCachedGeometry())
    MousePosition.Y = MousePosition.Y - Size.Y
    self.Overlay_WBP_ScrollLegandTips.Slot:SetPosition(MousePosition)
    UpdateVisibility(self.Lock, not Logic_IllustratedGuide.UnLockAttributeModify[item.Data.Id])
  else
    UpdateVisibility(self.Overlay_WBP_ScrollLegandTips, false)
  end
end

return WBP_IGuide_AttributeModify_C
