local climbtowerdata = require("UI.View.ClimbTower.ClimbTowerData")
local WBP_TeamDamagePanel_C = UnLua.Class()
local ShowTeamDamagePanelName = "ShowTeamDamagePanel"
function WBP_TeamDamagePanel_C:Construct()
  self.DamageItemClass = UE.UClass.Load("/Game/Rouge/UI/Battle/WBP_SingleDamageItem.WBP_SingleDamageItem_C")
end
function WBP_TeamDamagePanel_C:FocusInput()
  self.Overridden.FocusInput(self)
  if not IsListeningForInputAction(self, self.EscActionName) then
    ListenForInputAction(self.EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  if not IsListeningForInputAction(self, ShowTeamDamagePanelName) then
    ListenForInputAction(ShowTeamDamagePanelName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.ListenForEscInputAction)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  self:SetEnhancedInputActionBlocking(true)
  self.NavigateUserIndex = -1
  self.NavigateAttributeModifyIndex = -1
  self.NavigateGenericModifyIndex = -1
end
function WBP_TeamDamagePanel_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  self:PopInputAction()
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.ListenForEscInputAction)
  StopListeningForInputAction(self, "MainPanelLeftSwitch", UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, "MainPanelRightSwitch", UE.EInputEvent.IE_Pressed)
  local PC = self:GetOwningPlayer()
  if not PC then
    return
  end
  UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(PC)
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  self:SetEnhancedInputActionBlocking(false)
end
function WBP_TeamDamagePanel_C:OnDisplay()
  print("WBP_TeamDamagePanel_C:OnDisplay")
  self.Overridden.OnDisplay(self)
  self:RefreshDamageList()
  self.TeamTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_TeamDamagePanel_C.RefreshDamageList
  }, 1, true)
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local ModeId = 0
  if LevelSubSystem then
    ModeId = LevelSubSystem:GetMatchGameMode()
  end
  UpdateVisibility(self.Overlay_2, LogicTeam.GetModeId() == climbtowerdata.GameMode or ModeId == climbtowerdata.GameMode)
  UpdateVisibility(self.CanvasPanel_2, ModeId ~= climbtowerdata.GameMode)
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      self.WBP_InteractTipWidget:SetFocus()
      self.WBP_InteractTipWidget:SetNavigationRuleCustom(UE.EUINavigation.Left, {
        self,
        self.InitFocusOnPos
      })
      self.WBP_InteractTipWidget:SetNavigationRuleCustom(UE.EUINavigation.Right, {
        self,
        self.InitFocusOnPos
      })
      self.WBP_InteractTipWidget:SetNavigationRuleCustom(UE.EUINavigation.Up, {
        self,
        self.InitFocusOnPos
      })
      self.WBP_InteractTipWidget:SetNavigationRuleCustom(UE.EUINavigation.Down, {
        self,
        self.InitFocusOnPos
      })
    end
  })
  self.bIsFocusEsc = true
  if not IsListeningForInputAction(self, "MainPanelLeftSwitch") then
    ListenForInputAction("MainPanelLeftSwitch", UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_TeamDamagePanel_C.ListenForLeftInputAction
    })
  end
  if not IsListeningForInputAction(self, "MainPanelRightSwitch") then
    ListenForInputAction("MainPanelRightSwitch", UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_TeamDamagePanel_C.ListenForRightInputAction
    })
  end
end
function WBP_TeamDamagePanel_C:ListenForLeftInputAction()
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local ModeId = 0
  if LevelSubSystem then
    ModeId = LevelSubSystem:GetMatchGameMode()
  end
  if ModeId ~= climbtowerdata.GameMode then
    return
  end
  UpdateVisibility(self.Damage, true)
  UpdateVisibility(self.Btn_Select, true)
  UpdateVisibility(self.Btn_Select_01, false)
  UpdateVisibility(self.WBP_ClimbTower_DebuffPanle, false)
end
function WBP_TeamDamagePanel_C:ListenForRightInputAction()
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local ModeId = 0
  if LevelSubSystem then
    ModeId = LevelSubSystem:GetMatchGameMode()
  end
  if ModeId ~= climbtowerdata.GameMode then
    return
  end
  UpdateVisibility(self.Damage, false)
  UpdateVisibility(self.Btn_Select, false)
  UpdateVisibility(self.Btn_Select_01, true)
  UpdateVisibility(self.WBP_ClimbTower_DebuffPanle, true)
end
function WBP_TeamDamagePanel_C:ListenForEscInputAction()
  if UIMgr:IsShow(ViewID.UI_ReportView) then
    UIMgr:Hide(ViewID.UI_ReportView)
    return
  end
  if (self.WBP_ScrollPickUpTipsView:IsVisible() or self.WBP_GenericModifyBagTips:IsVisible()) and not self.bIsFocusEsc then
    self.WBP_InteractTipWidget:SetFocus()
    self.bIsFocusEsc = true
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:Switch(UE.UClass.Load("/Game/Rouge/UI/Battle/WBP_TeamDamagePanel.WBP_TeamDamagePanel_C"), false)
end
function WBP_TeamDamagePanel_C:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TeamTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TeamTimer)
  end
  local ChildrenItems = self.ItemList:GetAllChildren()
  for i, SingleItem in iterator(ChildrenItems) do
    SingleItem:UnBindInputHandler()
  end
end
function WBP_TeamDamagePanel_C:RefreshDamageList()
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  local PlayerUserIds = RGTeamSubsystem:GetPlayers()
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    print("WBP_TeamDamagePanel_C:RefreshDamageList GS is Null")
    return
  end
  local ChildrenItems = self.ItemList:GetAllChildren()
  for i, SingleItem in iterator(ChildrenItems) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if GS.PlayerArray then
    print("WBP_TeamDamagePanel_C:RefreshDamageList GS.PlayerArray Length:", GS.PlayerArray:Length())
  else
    print("WBP_TeamDamagePanel_C:RefreshDamageList GS.PlayerArray Is Null")
  end
  local ShowPlayerList = {}
  local OwnerPlayer
  for i, UserId in iterator(PlayerUserIds) do
    local bIsOwner = DataMgr.GetUserId() == tostring(UserId)
    if not bIsOwner then
      table.insert(ShowPlayerList, UserId)
    else
      OwnerPlayer = UserId
    end
  end
  if 0 == #ShowPlayerList then
    table.insert(ShowPlayerList, false)
    table.insert(ShowPlayerList, false)
  end
  table.insert(ShowPlayerList, 2, OwnerPlayer)
  self.RequestMsg = {}
  self.VisibleItemWigetList = {}
  local PanelIndex = 1
  for i, UserId in pairs(ShowPlayerList) do
    local SinglePS = self:GetPlayerStateByUserId(UserId)
    print("WBP_TeamDamagePanel_C:RefreshDamageList iterator PlayerArray", i, SinglePS)
    local Item = self.ItemList:GetChildAt(i - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.DamageItemClass)
      local Slot = self.ItemList:AddChild(Item)
      local Margin = UE.FMargin()
      Margin.Top = 10
      Slot:SetPadding(Margin)
    end
    Item:SetVisibility(UE.ESlateVisibility.Visible)
    Item:RefreshInfo(UserId, SinglePS, self.UpdateScrollSetTips, self.UpdateGenericModifyTips, self, PanelIndex)
    Item:BindInputHandler()
    if not UserId then
      Item:SetVisibility(UE.ESlateVisibility.Hidden)
    else
      table.insert(self.VisibleItemWigetList, Item)
      PanelIndex = PanelIndex + 1
    end
  end
  for i, RequestData in ipairs(self.RequestMsg) do
    local RequestMsgItem = GetOrCreateItem(self.VerticalBox_RequestMsg, i, self.WBP_AttributeModifyRequestMsg:GetClass())
    RequestMsgItem:InitInfo(RequestData.FromUserId, RequestData.TargetUserId, RequestData.AttributeModifyId)
  end
  HideOtherItem(self.VerticalBox_RequestMsg, #self.RequestMsg + 1, true)
  local Index = 1
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local ModeId = 0
  if LevelSubSystem then
    ModeId = LevelSubSystem:GetMatchGameMode()
  end
  if LogicTeam.GetModeId() == climbtowerdata.GameMode or ModeId == climbtowerdata.GameMode then
    self.WBP_ClimbTower_DebuffPanle:Init(ShowPlayerList, 3)
  end
end
function WBP_TeamDamagePanel_C:UpdateScrollSetTips(bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit, UserId)
  print("WBP_TeamDamagePanel_C:UpdateScrollSetTips", bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  if ScrollId and ScrollId > 0 then
    self.WBP_ScrollPickUpTipsView:InitScrollTipsView(ScrollId, EScrollTipsOpenType.EFromTeamDamage, TargetItem, bIsNeedInit, UserId)
  end
  if TargetItem and TargetItem.bIsOwner then
    UpdateVisibility(self.WBP_ScrollPickUpTipsView.WBP_InteractTipWidgetLike, false)
  end
  if bIsShowTipsView then
    self.PickupTargetItem = TargetItem
    self.ScrollTipsOpenType = ScrollTipsOpenType
    self.WBP_ScrollPickUpTipsView:Show()
    if bIsNeedInit then
      ShowCommonTips(nil, TargetItem, self.WBP_ScrollPickUpTipsView)
    end
  elseif self.ScrollTipsOpenType == ScrollTipsOpenType then
    self.PickupTargetItem = nil
    self.WBP_ScrollPickUpTipsView:Hide()
  end
end
function WBP_TeamDamagePanel_C:UpdateGenericModifyTips(bIsShow, Data, ModifyChooseTypeParam, Slot, TargetItem)
  if bIsShow then
    if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
      self.WBP_GenericModifyBagTips:InitGenericModifyTips(Data.ModifyId, false, Slot, nil, Data)
    elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
      self.WBP_GenericModifyBagTips:InitSpecificModifyTips(Data.ModifyId, false)
    end
    UpdateVisibility(self.WBP_GenericModifyBagTips, true)
    ShowCommonTips(nil, TargetItem, self.WBP_GenericModifyBagTips)
  else
    self.WBP_GenericModifyBagTips:Hide()
  end
end
function WBP_TeamDamagePanel_C:GetPlayerStateByUserId(UserId)
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return nil
  end
  for i, SinglePS in iterator(GS.PlayerArray) do
    if SinglePS:GetUserId() == UserId then
      return SinglePS
    end
  end
  return nil
end
function WBP_TeamDamagePanel_C:GetUserIdByIndex(Index)
  local SingleDamageItemList = self.ItemList:GetAllChildren()
  for i, SingleDamageItem in iterator(SingleDamageItemList) do
    if i == Index then
      return SingleDamageItem.UserId
    end
  end
  return nil
end
function WBP_TeamDamagePanel_C:GetGenericModifyCountByIndex(Index)
  local SingleDamageItemList = self.ItemList:GetAllChildren()
  for i, SingleDamageItem in iterator(SingleDamageItemList) do
    if i == Index then
      return #SingleDamageItem.GenericModifies
    end
  end
  return nil
end
function WBP_TeamDamagePanel_C:GetNextUserIndexByIndex(UserIndex, Direction)
  local UserCount = self.ItemList:GetChildrenCount()
  local NextUserIndex
  if Direction == UE.EUINavigation.Left then
    NextUserIndex = (UserIndex + UserCount - 1 - 1) % UserCount + 1
  elseif Direction == UE.EUINavigation.Right then
    NextUserIndex = UserIndex % UserCount + 1
  end
  if self:GetUserIdByIndex(NextUserIndex) == nil then
    return self:GetNextUserIndexByIndex(NextUserIndex, Direction)
  else
    return NextUserIndex
  end
end
function WBP_TeamDamagePanel_C:GetNextGenericModifyByIndex(UserIndex, GenericModifyIndex, Direction)
  local SingleDamageItemList = self.ItemList:GetAllChildren()
  local GenericModifyCount = #SingleDamageItemList:GetRef(UserIndex).GenericModifies
  if Direction == UE.EUINavigation.Left then
    if (GenericModifyIndex - 1) % self.LayoutGenericModifyColCount + 1 > 1 then
      return UserIndex, GenericModifyIndex - 1
    end
  elseif Direction == UE.EUINavigation.Right and GenericModifyIndex < GenericModifyCount and 0 ~= GenericModifyIndex % self.LayoutGenericModifyColCount then
    return UserIndex, GenericModifyIndex + 1
  end
  local CurrentUserIndex = UserIndex
  while nil ~= CurrentUserIndex do
    CurrentUserIndex = self:GetNextUserIndexByIndex(CurrentUserIndex, Direction)
    GenericModifyCount = #SingleDamageItemList:GetRef(CurrentUserIndex).GenericModifies
    if GenericModifyCount > 0 then
      local GenericModifyRowIndex = math.ceil(GenericModifyIndex / self.LayoutGenericModifyColCount)
      if Direction == UE.EUINavigation.Left then
        return CurrentUserIndex, math.min(GenericModifyRowIndex * self.LayoutGenericModifyColCount, GenericModifyCount)
      elseif Direction == UE.EUINavigation.Right then
        return CurrentUserIndex, math.min((GenericModifyRowIndex - 1) * self.LayoutGenericModifyColCount + 1, math.floor(GenericModifyCount / self.LayoutGenericModifyColCount) * self.LayoutGenericModifyColCount + 1)
      end
    end
    if CurrentUserIndex == UserIndex then
      break
    end
  end
  return nil
end
function WBP_TeamDamagePanel_C:BindOnNavigation(Type)
  if Type == UE.EUINavigation.Left then
    if -1 ~= self.NavigateAttributeModifyIndex then
      if 1 == self.NavigateAttributeModifyIndex % self.LayoutAttributeModifyColCount then
        self.NavigateUserIndex = self:GetNextUserIndexByIndex(self.NavigateUserIndex, Type)
        self.NavigateAttributeModifyIndex = self.NavigateAttributeModifyIndex + (self.LayoutAttributeModifyColCount - 1)
      else
        self.NavigateAttributeModifyIndex = self.NavigateAttributeModifyIndex - 1
      end
    elseif -1 ~= self.NavigateGenericModifyIndex then
      self.NavigateUserIndex, self.NavigateGenericModifyIndex = self:GetNextGenericModifyByIndex(self.NavigateUserIndex, self.NavigateGenericModifyIndex, Type)
    end
  elseif Type == UE.EUINavigation.Up then
    if -1 ~= self.NavigateAttributeModifyIndex then
      if self.NavigateAttributeModifyIndex > self.LayoutAttributeModifyColCount then
        self.NavigateAttributeModifyIndex = self.NavigateAttributeModifyIndex - self.LayoutAttributeModifyColCount
      end
    elseif -1 ~= self.NavigateGenericModifyIndex then
      if self.NavigateGenericModifyIndex > self.LayoutGenericModifyColCount then
        self.NavigateGenericModifyIndex = self.NavigateGenericModifyIndex - self.LayoutGenericModifyColCount
      else
        self.NavigateAttributeModifyIndex = math.floor(self.NavigateGenericModifyIndex / self.LayoutGenericModifyColCount * self.LayoutAttributeModifyColCount + 0.5) + self.LayoutAttributeModifyColCount * (self.LayoutAttributeModifyRowCount - 1)
        self.NavigateGenericModifyIndex = -1
      end
    end
  elseif Type == UE.EUINavigation.Down then
    if -1 ~= self.NavigateAttributeModifyIndex then
      if self.NavigateAttributeModifyIndex <= self.LayoutAttributeModifyColCount then
        self.NavigateAttributeModifyIndex = self.NavigateAttributeModifyIndex + self.LayoutAttributeModifyColCount
      else
        local GenericModifyCount = self:GetGenericModifyCountByIndex(self.NavigateUserIndex)
        if 0 == GenericModifyCount then
          return
        end
        self.NavigateGenericModifyIndex = math.min(math.ceil(((self.NavigateAttributeModifyIndex - 1) % self.LayoutAttributeModifyColCount + 1) / self.LayoutAttributeModifyColCount * self.LayoutGenericModifyColCount - 0.5), GenericModifyCount)
        self.NavigateAttributeModifyIndex = -1
      end
    elseif -1 ~= self.NavigateGenericModifyIndex then
      local GenericModifyCount = self:GetGenericModifyCountByIndex(self.NavigateUserIndex)
      if GenericModifyCount >= self.NavigateGenericModifyIndex + self.LayoutGenericModifyColCount then
        self.NavigateGenericModifyIndex = self.NavigateGenericModifyIndex + self.LayoutGenericModifyColCount
      elseif math.ceil(self.NavigateGenericModifyIndex / self.LayoutGenericModifyColCount) ~= math.ceil(GenericModifyCount / self.LayoutGenericModifyColCount) then
        self.NavigateGenericModifyIndex = GenericModifyCount
      end
    end
  elseif Type == UE.EUINavigation.Right then
    if -1 ~= self.NavigateAttributeModifyIndex then
      if 0 == self.NavigateAttributeModifyIndex % self.LayoutAttributeModifyColCount then
        self.NavigateUserIndex = self:GetNextUserIndexByIndex(self.NavigateUserIndex, Type)
        self.NavigateAttributeModifyIndex = self.NavigateAttributeModifyIndex - (self.LayoutAttributeModifyColCount - 1)
      else
        self.NavigateAttributeModifyIndex = self.NavigateAttributeModifyIndex + 1
      end
    elseif -1 ~= self.NavigateGenericModifyIndex then
      self.NavigateUserIndex, self.NavigateGenericModifyIndex = self:GetNextGenericModifyByIndex(self.NavigateUserIndex, self.NavigateGenericModifyIndex, Type)
    end
  end
  EventSystem.Invoke(EventDef.TeamDamage.OnUpdateHoverStatus, self:GetUserIdByIndex(self.NavigateUserIndex), self.NavigateAttributeModifyIndex, self.NavigateGenericModifyIndex)
  print("WBP_TeamDamagePanel_C:BindOnNavigation", self.NavigateUserIndex, self.NavigateAttributeModifyIndex, self.NavigateGenericModifyIndex)
end
function WBP_TeamDamagePanel_C:InitFocusOnPos()
  local TargetFocusItem = self.ItemList:GetChildAt(1).WrapBoxScroll:GetChildAt(0)
  if TargetFocusItem then
    TargetFocusItem:SetKeyboardFocus()
  end
  self.NavigateUserIndex = 1 == self.ItemList:GetChildrenCount() and 1 or 2
  self.NavigateAttributeModifyIndex = 1
  self.NavigateGenericModifyIndex = -1
  self.bIsFocusEsc = false
end
function WBP_TeamDamagePanel_C:Destruct()
  self:UnfocusInput()
end
function WBP_TeamDamagePanel_C:OnRepeorViewClosed()
  local DefaultFocusWidget = self:GetDefaultFocusWidget()
  if DefaultFocusWidget then
    DefaultFocusWidget:SetFocus()
  end
end
function WBP_TeamDamagePanel_C:GetDefaultFocusWidget()
  if UIMgr:IsShow(ViewID.UI_ReportView) then
    return nil
  end
  local ItemWidget = self.ItemList:GetChildAt(0)
  if ItemWidget then
    local TargetWidget = ItemWidget:GetFirstFocusWidget()
    return TargetWidget
  end
  return nil
end
function WBP_TeamDamagePanel_C:GetLeftDamagePanel(CurrentPanelIndex)
  local ItemCount = #self.VisibleItemWigetList
  local NextPanelIndex = CurrentPanelIndex
  if CurrentPanelIndex <= 1 then
    NextPanelIndex = ItemCount
  else
    NextPanelIndex = CurrentPanelIndex - 1
  end
  local NextWidget = self.VisibleItemWigetList[NextPanelIndex]
  return NextWidget
end
function WBP_TeamDamagePanel_C:GetRightDamagePanel(CurrentPanelIndex)
  local ItemCount = #self.VisibleItemWigetList
  local NextPanelIndex = CurrentPanelIndex
  if CurrentPanelIndex >= ItemCount then
    NextPanelIndex = 1
  else
    NextPanelIndex = CurrentPanelIndex + 1
  end
  local NextWidget = self.VisibleItemWigetList[NextPanelIndex]
  return NextWidget
end
function WBP_TeamDamagePanel_C:GetFunctionBtnLeft(PanelIndex, ItemIndex)
  local NextWidget = self:GetLeftDamagePanel(PanelIndex)
  return NextWidget:GetFunctionBtnLeft(ItemIndex, true)
end
function WBP_TeamDamagePanel_C:GetFunctionBtnRight(PanelIndex, ItemIndex)
  local NextWidget = self:GetRightDamagePanel(PanelIndex)
  return NextWidget:GetFunctionBtnRight(ItemIndex, true)
end
function WBP_TeamDamagePanel_C:GetModifyItemLeft(PanelIndex, ItemIndex)
  local NextWidget = self:GetLeftDamagePanel(PanelIndex)
  return NextWidget:GetModifyItemLeft(ItemIndex, true)
end
function WBP_TeamDamagePanel_C:GetModifyItemRight(PanelIndex, ItemIndex)
  local NextWidget = self:GetRightDamagePanel(PanelIndex)
  return NextWidget:GetModifyItemRight(ItemIndex, true)
end
return WBP_TeamDamagePanel_C
