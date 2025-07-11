local WBP_LobbyMenuButton_C = UnLua.Class()
local CurrentSelectedLabelName = ""
local bBindInput = false
function WBP_LobbyMenuButton_C:OnBindUIInput()
  bBindInput = true
  if self.IsActivate then
    self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.OnSelectPrev)
    self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.OnSelectNext)
  end
end
function WBP_LobbyMenuButton_C:OnUnBindUIInput()
  bBindInput = false
  if self.IsActivate then
    self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.OnSelectPrev)
    self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.OnSelectNext)
  end
end
function WBP_LobbyMenuButton_C:Construct()
  self.Button_Menu.OnClicked:Add(self, WBP_LobbyMenuButton_C.OnClicked_Menu)
  self.Button_Menu.OnHovered:Add(self, self.BindOnMenuButtonHovered)
  self.Button_Menu.OnUnhovered:Add(self, self.BindOnMenuButtonUnhovered)
end
function WBP_LobbyMenuButton_C:Show(LabelTagName, ChildLabelList)
  self.LabelTagName = LabelTagName
  self.ChildLabelList = ChildLabelList
  self:RefreshChildLabelList()
  self:RefreshUnSelectedTips()
  local Result, RowInfo = GetRowData(DT.DT_LobbyPanelLabel, LabelTagName)
  if Result then
    self.Txt_MenuName:SetText(RowInfo.Name)
    self.Txt_MenuNameSelected:SetText(RowInfo.Name)
    if RowInfo.bSupportRedDot then
      self.WBP_RedDotView:ChangeRedDotId(LabelTagName, LabelTagName)
    else
      self.WBP_RedDotView:ChangeRedDotId("")
    end
    self.WBP_SystemUnlock:InitSysId(RowInfo.SystemId)
  end
  self.LabelRowInfo = RowInfo
  self:BindOnLobbyLabelSelected(LogicLobby.GetCurSelectedLabelName())
  EventSystem.AddListener(self, EventDef.Lobby.OnLobbyLabelSelected, self.BindOnLobbyLabelSelected)
end
function WBP_LobbyMenuButton_C:RefreshUnSelectedTips()
  local BResult, BRowInfo = GetRowData(DT.DT_LobbyPanelLabel, self.LabelTagName)
  if BResult and BRowInfo.UnSelectedTipsCls and not BRowInfo.UnSelectedTipsCls:IsNull() then
    local cls = BRowInfo.UnSelectedTipsCls:LoadSynchronous()
    if UE.RGUtil.IsUObjectValid(self.UnSelectedTips) then
      if self.UnSelectedTips:GetClass() ~= cls then
        self.UnSelectedTips = UE.UWidgetBlueprintLibrary.Create(self, cls)
        local slot = self.CanvasPanel_UnSelectTips:AddChildToOverlay(self.UnSelectedTips)
        slot:SetAnchors(UE.FAnchors(0, 0, 1, 1))
        slot:SetPosition(UE.FVector2D(0))
        slot:SetSize(UE.FVector2D(0))
      end
    else
      print("RefreshUnSelectedTips", tostring(BRowInfo.UnSelectedTipsCls), cls)
      self.UnSelectedTips = UE.UWidgetBlueprintLibrary.Create(self, cls)
      local slot = self.CanvasPanel_UnSelectTips:AddChildToCanvas(self.UnSelectedTips)
      slot:SetAnchors(UE.FAnchors(0, 0, 1, 1))
      slot:SetPosition(UE.FVector2D(0))
      slot:SetSize(UE.FVector2D(0))
    end
  end
end
function WBP_LobbyMenuButton_C:RefreshChildLabelList()
  if not self.ChildLabelList or next(self.ChildLabelList) == nil then
    self.ChildLabelPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.ChildLabelPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    table.sort(self.ChildLabelList, function(a, b)
      local AResult, ARowInfo = GetRowData(DT.DT_LobbyPanelLabel, a)
      local BResult, BRowInfo = GetRowData(DT.DT_LobbyPanelLabel, b)
      return ARowInfo.Priority > BRowInfo.Priority
    end)
    local SingleItem, Slot
    for index, SingleLabelTagName in ipairs(self.ChildLabelList) do
      SingleItem = self.HorizontalBox_ChildTab:GetChildAt(index - 1)
      if not SingleItem then
        SingleItem = UE.UWidgetBlueprintLibrary.Create(self, self.MenuButtonItemTemplate:StaticClass())
        Slot = self.HorizontalBox_ChildTab:AddChild(SingleItem)
      end
      SingleItem:Show(SingleLabelTagName, self.ChildLabelList[SingleLabelTagName])
    end
  end
end
function WBP_LobbyMenuButton_C:BindOnLobbyLabelSelected(LabelName)
  if self.LabelTagName == LabelName then
    if not self.ChildLabelList or next(self.ChildLabelList) == nil then
      CurrentSelectedLabelName = LabelName
      self:SetActivateState(true)
    else
      EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, self.ChildLabelList[1])
    end
    if UE.RGUtil.IsUObjectValid(self.UnSelectedTips) then
      if self.UnSelectedTips.Hide then
        self.UnSelectedTips:Hide()
      else
        UpdateVisibility(self.CanvasPanel_UnSelectTips, false)
      end
    end
  else
    local LabelTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(LabelName)
    local ParentTag = UE.URGBlueprintLibrary.GetGameplayTagDirectParentTag(LabelTag)
    if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(ParentTag, self.LabelRowInfo.Tag) then
      CurrentSelectedLabelName = LabelName
    end
    self:SetActivateState(UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(ParentTag, self.LabelRowInfo.Tag))
    if UE.RGUtil.IsUObjectValid(self.UnSelectedTips) then
      if self.UnSelectedTips.Show then
        self.UnSelectedTips:Show()
      else
        UpdateVisibility(self.CanvasPanel_UnSelectTips, true)
      end
    end
  end
end
function WBP_LobbyMenuButton_C:OnSelectPrev()
  if not self.ChildLabelList or next(self.ChildLabelList) == nil or #self.ChildLabelList < 1 then
    return
  end
  local CurrentIndex = self:GetChildLabelIndex(CurrentSelectedLabelName)
  local NextIndex = CurrentIndex
  NextIndex = NextIndex - 1
  if NextIndex < 1 then
    NextIndex = #self.ChildLabelList
  end
  if NextIndex == CurrentIndex then
    return
  end
  local IsLabelUnlock = LogicLobby.GetLobbyLabelIsOpen(self.ChildLabelList[NextIndex], true)
  if IsLabelUnlock then
    EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, self.ChildLabelList[NextIndex])
    return
  end
end
function WBP_LobbyMenuButton_C:OnSelectNext()
  if not self.ChildLabelList or next(self.ChildLabelList) == nil or #self.ChildLabelList < 1 then
    return
  end
  local CurrentIndex = self:GetChildLabelIndex(CurrentSelectedLabelName)
  local NextIndex = CurrentIndex
  NextIndex = NextIndex + 1
  if NextIndex > #self.ChildLabelList then
    NextIndex = 1
  end
  if NextIndex == CurrentIndex then
    return
  end
  local IsLabelUnlock = LogicLobby.GetLobbyLabelIsOpen(self.ChildLabelList[NextIndex], true)
  if IsLabelUnlock then
    EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, self.ChildLabelList[NextIndex])
    return
  end
end
function WBP_LobbyMenuButton_C:GetChildLabelIndex(LabelName)
  for Index, Value in ipairs(self.ChildLabelList) do
    if Value == LabelName then
      return Index
    end
  end
  return -1
end
function WBP_LobbyMenuButton_C:Destruct()
  self.Button_Menu.OnClicked:Remove(self, WBP_LobbyMenuButton_C.OnClicked_Menu)
  self.Button_Menu.OnHovered:Remove(self, self.BindOnMenuButtonHovered)
  self.Button_Menu.OnUnhovered:Remove(self, self.BindOnMenuButtonUnhovered)
  self.HorizontalBox_ChildTab:ClearChildren()
  EventSystem.RemoveListener(EventDef.Lobby.OnLobbyLabelSelected, self.BindOnLobbyLabelSelected, self)
end
function WBP_LobbyMenuButton_C:BindOnMenuButtonHovered()
  self:UpdateMenumNameStyleByStatus()
end
function WBP_LobbyMenuButton_C:BindOnMenuButtonUnhovered()
  self:UpdateMenumNameStyleByStatus()
end
function WBP_LobbyMenuButton_C:K2_SwitchChildTabWidgets(Show)
  if Show then
    self.Overlay_SecondTab:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Overlay_SecondTab:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_LobbyMenuButton_C:SetActivateState(Activate, PlayAnim)
  local LastIsActivate = self.IsActivate
  self.IsActivate = Activate
  if Activate then
    self.Image_Choose:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if not self:IsAnimationPlaying(self.ani_lobbymenubutton_switch) and LastIsActivate ~= self.IsActivate then
      self:PlayAnimationForward(self.ani_lobbymenubutton_switch)
    end
    if bBindInput then
      self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.OnSelectPrev)
      self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.OnSelectNext)
    end
  else
    self.Image_Choose:SetVisibility(UE.ESlateVisibility.Hidden)
    if bBindInput then
      self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.OnSelectPrev)
      self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.OnSelectNext)
    end
  end
  self:K2_SwitchChildTabWidgets(Activate)
  self:UpdateMenumNameStyleByStatus()
end
function WBP_LobbyMenuButton_C:UpdateMenumNameStyleByStatus()
  local Font
  local SlateColor = UE.FSlateColor()
  if self.IsActivate then
    Font = self.Txt_MenuNameSelected.Font
    Font.Size = self.SelectedFontSize
    SlateColor = self.SelectedTextColor
    self.Txt_MenuNameSelected:SetFont(Font)
    self.Txt_MenuNameSelected:SetColorAndOpacity(SlateColor)
    self.Txt_MenuNameSelected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_MenuName:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    Font = self.Txt_MenuName.Font
    self.Txt_MenuNameSelected:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_MenuName:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if self.Button_Menu:IsHovered() then
      Font.Size = self.HoveredFontSize
      SlateColor = self.HoveredTextColor
    else
      Font.Size = self.NormalFontSize
      SlateColor = self.NormalTextColor
    end
    self.Txt_MenuName:SetFont(Font)
    self.Txt_MenuName:SetColorAndOpacity(SlateColor)
  end
end
function WBP_LobbyMenuButton_C:OnClicked_Menu()
  LogicLobby.ChangeLobbyPanelLabelSelected(self.LabelTagName)
end
return WBP_LobbyMenuButton_C
