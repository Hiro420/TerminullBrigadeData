local WBP_MainPanel_C = UnLua.Class()
function WBP_MainPanel_C:Construct()
  self:BindTitleEvent(true)
  self.SwitchBagName = "SwitchBag"
  self.IllustratedName = "Illustrated"
  self.SwitchBattleRoleName = "BattleRoleInfoShortcut"
  self.ExitKeyName = "PauseGame"
  self.MainPanelLeftSwitchName = "MainPanelLeftSwitch"
  self.MainPanelRightSwitchName = "MainPanelRightSwitch"
  self.ShowGMWindowName = "ShowGMWindow"
  self.MainPanelDiscardWeaponName = "MainPanelDiscardWeapon"
  self.PageNameLuaAry = self.PageNameAry:ToTable()
end
function WBP_MainPanel_C:Destruct()
  self:ReleaseView()
  self:BindTitleEvent(false)
end
function WBP_MainPanel_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  self:SetEnhancedInputActionBlocking(true)
  self:PushInputAction()
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  self:PlayAnimation(self.fx_ani_gamepanel_in)
  self.WBP_NavigationBar:PlayAnimation(self.WBP_NavigationBar.ani_33_navigationbar_in)
  local ActiveIndex = self:GetChildIndexByWidget(self.WBP_ModScrollView)
  if ActiveIndex == self.ActivateNum then
    self:ShowScrollInfoPanel()
  end
end
function WBP_MainPanel_C:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  self:ReleaseView()
end
function WBP_MainPanel_C:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  self:RegisterInputComponent()
  if not IsListeningForInputAction(self, self.SwitchBagName) then
    ListenForInputAction(self.SwitchBagName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_MainPanel_C.ListenForSwitchBagNameInputAction
    })
  end
  if not IsListeningForInputAction(self, self.IllustratedName) then
    ListenForInputAction(self.IllustratedName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_MainPanel_C.ListenForIllustratedNameInputAction
    })
  end
  if not IsListeningForInputAction(self, self.SwitchBattleRoleName) then
    ListenForInputAction(self.SwitchBattleRoleName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_MainPanel_C.ListenForSwitchBattleRoleNameInputAction
    })
  end
  if not IsListeningForInputAction(self, self.ExitKeyName) then
    ListenForInputAction(self.ExitKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_MainPanel_C.ListenForEscInputAction
    })
  end
  if not IsListeningForInputAction(self, self.MainPanelLeftSwitchName) then
    ListenForInputAction(self.MainPanelLeftSwitchName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_MainPanel_C.ListenForLeftInputAction
    })
  end
  if not IsListeningForInputAction(self, self.MainPanelRightSwitchName) then
    ListenForInputAction(self.MainPanelRightSwitchName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_MainPanel_C.ListenForRightInputAction
    })
  end
  if not IsListeningForInputAction(self, self.ShowGMWindowName) then
    ListenForInputAction(self.ShowGMWindowName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_MainPanel_C.ListenForGMWindowInputAction
    })
  end
end
function WBP_MainPanel_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  self:ReleaseView()
end
function WBP_MainPanel_C:Bp_InputTypeToGamePadUpdateFocus()
  local currentActiveWidget = self:GetCurActiveWidget()
  if currentActiveWidget and currentActiveWidget.GamePadFocus then
    currentActiveWidget:GamePadFocus()
  end
end
function WBP_MainPanel_C:ReleaseView()
  self:SetEnhancedInputActionBlocking(false)
  self.WBP_BattleRoleInfo:OnClose()
  self.WBP_ModScrollView:OnClose()
  self:SetInputIgnore(false)
  UE.URGBlueprintLibrary.EnablePostProcessMaterial()
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  self:PopInputAction()
end
function WBP_MainPanel_C:OnAnimationFinished(Animation)
  if Animation == self.fx_ani_gamepanel_out then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
    if UIManager and UIManager:IsValid() then
      local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
      if PC then
        PC:SetViewTargetwithBlend(self:GetOwningPlayerPawn())
      end
      self:Exit()
    end
  end
end
function WBP_MainPanel_C:ActivatePageTitle(InActivateNum)
  local titleArray = self.WBP_NavigationBar.HorizontalBox_Title:GetAllChildren()
  for key, value in pairs(titleArray) do
    value:ActivatePageTitle(false)
  end
  if titleArray:IsValidIndex(InActivateNum + 1) then
    titleArray:Get(InActivateNum + 1):ActivatePageTitle(true)
    self.ActivateNum = InActivateNum
  end
end
function WBP_MainPanel_C:ActivatePagePanel(Index)
  print("WBP_MainPanel_C:ActivatePagePanel", Index)
  local lastActiveWidget = self:GetCurActiveWidget()
  self:SetActiveWidgetIndex(Index)
  self:ActivatePageTitle(Index)
  local currentActiveWidget = self:GetCurActiveWidget()
  EventSystem.Invoke(EventDef.MainPanel.OnEnter, Index)
  self:NotifyActiveWidgetChange(lastActiveWidget, currentActiveWidget)
  print("WBP_MainPanel_C:ActivatePagePanel1", lastActiveWidget, currentActiveWidget)
end
function WBP_MainPanel_C:ActivateItemPanel()
  self:ShowScrollInfoPanel()
end
function WBP_MainPanel_C:ActivateModPanel()
  self:ActivatePagePanel(1)
end
function WBP_MainPanel_C:ActivateLeft()
  local tempNumber = self.ActivateNum - 1
  if tempNumber >= 0 then
    self:ActivatePagePanel(tempNumber)
  end
end
function WBP_MainPanel_C:ActivateRight()
  local tempNumber = self.ActivateNum + 1
  local tempMaxNumber = self.WBP_NavigationBar.HorizontalBox_Title:GetChildrenCount() - 1
  if tempNumber <= tempMaxNumber then
    self:ActivatePagePanel(tempNumber)
  end
end
function WBP_MainPanel_C:ExitMainPanel()
  if not self:IsAnimationPlaying(self.fx_ani_gamepanel_in) and not self:IsAnimationPlaying(self.fx_ani_gamepanel_out) then
    self.WBP_BattleRoleInfo:OnExitPanel()
    self.WBP_ModScrollView:OnExitPanel()
    self.WBP_IllustratedGuide.WBP_IGuide_GenericModify:OnExitPanel()
    self:PlayAnimation(self.fx_ani_gamepanel_out)
    self.WBP_NavigationBar:PlayAnimation(self.WBP_NavigationBar.ani_33_navigationbar_out)
    EventSystem.Invoke(EventDef.MainPanel.OnExit, self:GetCurActiveWidget())
  end
end
function WBP_MainPanel_C:NotifyActiveWidgetChange(LastActiveWidget, CurActiveWidget)
  EventSystem.Invoke(EventDef.MainPanel.MainPanelChanged, LastActiveWidget, CurActiveWidget, self)
end
function WBP_MainPanel_C:SetInputIgnore(Ignored)
  if UE.RGUtil.IsUObjectValid(self:GetOwningPlayerPawn()) then
    local InputComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
    if InputComp and InputComp:IsValid() then
      InputComp:ReleaseAllBindEvents()
      InputComp:SetAllInputIgnored(Ignored)
    end
  end
end
function WBP_MainPanel_C:GetCurIdx()
  return self.ActivateNum
end
function WBP_MainPanel_C:GetCurActiveWidget()
  local Idx = self:GetCurIdx()
  if self.PageNameLuaAry[Idx + 1] then
    return self[self.PageNameLuaAry[Idx + 1]]
  end
  return nil
end
function WBP_MainPanel_C:SetActiveWidgetIndex(Index)
  for i, v in ipairs(self.PageNameLuaAry) do
    if i == Index + 1 then
      UpdateVisibility(self[v], true)
    else
      UpdateVisibility(self[v], false)
    end
  end
end
function WBP_MainPanel_C:GetChildIndexByWidget(Widget)
  for i = 1, self.WidgetSwitcher_Page:GetChildrenCount() do
    local Item = self.WidgetSwitcher_Page:GetChildAt(i - 1)
    if Item == Widget then
      return i - 1
    end
  end
  return -1
end
function WBP_MainPanel_C:OnVKeyEvent()
  self.WBP_ModScrollView:KeyDown()
end
function WBP_MainPanel_C:ListenForSwitchBattleRoleNameInputAction()
  print("WBP_MainPanel_C:ListenForSwitchBattleRoleNameInputAction", self:GetCurIdx())
  if 0 == self:GetCurIdx() then
    self:ExitMainPanel()
  end
end
function WBP_MainPanel_C:ListenForSwitchBagNameInputAction()
  print("WBP_MainPanel_C:ListenForSwitchBagNameInputAction", self:GetCurIdx())
  if 1 == self:GetCurIdx() then
    self:ExitMainPanel()
  end
end
function WBP_MainPanel_C:ListenForIllustratedNameInputAction()
  if 2 == self:GetCurIdx() then
    self:ExitMainPanel()
  end
end
function WBP_MainPanel_C:ListenForEscInputAction()
  self:ExitMainPanel()
end
function WBP_MainPanel_C:ListenForLeftInputAction()
  self:ActivateLeft()
end
function WBP_MainPanel_C:ListenForRightInputAction()
  self:ActivateRight()
end
function WBP_MainPanel_C:ListenForGMWindowInputAction()
end
function WBP_MainPanel_C:ListenForDiscardAccessoryInputAction()
end
function WBP_MainPanel_C:ShowRoleInfoPanel()
  local ActiveIndex = self:GetChildIndexByWidget(self.WBP_BattleRoleInfo)
  self:ActivatePagePanel(ActiveIndex)
  self.WBP_BattleRoleInfo:OnOpen(self)
end
function WBP_MainPanel_C:ShowScrollInfoPanel()
  local ActiveIndex = self:GetChildIndexByWidget(self.WBP_ModScrollView)
  self:ActivatePagePanel(ActiveIndex)
  self.WBP_ModScrollView:OnOpen(self)
end
function WBP_MainPanel_C:ShowIllustratedGuidePanel()
  local ActiveIndex = self:GetChildIndexByWidget(self.WBP_IllustratedGuide)
  self:ActivatePagePanel(ActiveIndex)
  self.WBP_IllustratedGuide.WBP_IGuide_GenericModify:InitGenericModify()
end
function WBP_MainPanel_C:TitleClicked(TitleNum)
  self:ActivatePagePanel(TitleNum)
end
function WBP_MainPanel_C:BindTitleEvent(Bind)
  local titleArray = self.WBP_NavigationBar.HorizontalBox_Title:GetAllChildren()
  for key, value in pairs(titleArray) do
    if Bind then
      value.ButtonClicked:Add(self, WBP_MainPanel_C.TitleClicked)
    else
      value.ButtonClicked:Remove(self, WBP_MainPanel_C.TitleClicked)
    end
  end
end
return WBP_MainPanel_C
