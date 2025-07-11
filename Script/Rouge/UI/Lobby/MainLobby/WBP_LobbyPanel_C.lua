local rapidjson = require("rapidjson")
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local HeirloomHandler = require("Protocol.Appearance.Heirloom.HeirloomHandler")
local TeamVoiceModule = require("Modules.TeamVoice.TeamVoiceModule")
local WBP_LobbyPanel_C = UnLua.Class()
local ShowCurrencyListLabel = {
  "LobbyLabel.LobbyMain"
}
function WBP_LobbyPanel_C:OnBindUIInput()
  if not IsListeningForInputAction(self, self.SpeakActionName) then
    ListenForInputAction(self.SpeakActionName, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_LobbyPanel_C.ListenForSpeakInputAction
    })
    ListenForInputAction(self.SpeakActionName, UE.EInputEvent.IE_Released, false, {
      self,
      WBP_LobbyPanel_C.ListenForSpeakInputReleasedAction
    })
  end
  self.ClickBG.OnClicked:Add(self, self.OnClickBGMouseButtonDown)
  self.BindExitGameKeyTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.ExitGameKey:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
    end
  }, 0.1, false)
  self.GameSettingsKey:BindInteractAndClickEvent(self, self.BindOnOpenSettingsKeyPressed)
  self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.BindOnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.BindOnSelectNextMenu)
end
function WBP_LobbyPanel_C:OnUnBindUIInput()
  StopListeningForInputAction(self, self.SpeakActionName, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, self.SpeakActionName, UE.EInputEvent.IE_Released)
  self.ClickBG.OnClicked:Remove(self, self.OnClickBGMouseButtonDown)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.BindExitGameKeyTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.BindExitGameKeyTimer)
  end
  self.ExitGameKey:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  self.GameSettingsKey:UnBindInteractAndClickEvent(self, self.BindOnOpenSettingsKeyPressed)
  self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.BindOnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.BindOnSelectNextMenu)
end
function WBP_LobbyPanel_C:Construct()
  ListenObjectMessage(nil, "LobbyLevelUp", self, self.OnLevelUp)
  EventSystem.AddListener(self, EventDef.Lobby.PlayInAnimation, self.OnPlayInAnimation)
  EventSystem.AddListener(self, EventDef.Lobby.PlayOutAnimation, self.OnPlayOutAnimation)
  EventSystem.AddListener(self, EventDef.RoleMain.OnTotalAttributeTipsVisChanged, self.BindOnTotalAttributeTipsVisChanged)
  EventSystem.AddListener(self, EventDef.Lobby.ChangeLobbyMenuPanelVis, self.BindOnChangeLobbyMenuPanelVis)
  EventSystem.AddListener(self, EventDef.Lobby.OnLobbyLabelSelected, self.BindOnLobbyLabelSelected)
  EventSystem.AddListenerNew(EventDef.LobbyPanel.SpecialFuncPanelVisCahange, self, self.UpdateSpecialFunctionalBtnPanel)
  EventSystem.AddListenerNew(EventDef.Season.SeasonModeChanged, self, self.InitPages)
  EventSystem.AddListener(self, EventDef.Lobby.OpenMonthCardTip, self.BindMonthCardTipOpen)
  EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, false)
  self.FirstLabelList = {}
  LogicLobby.CheckReConBattle()
  print("WBP_LobbyPanel_C:Construct LogicOutsideWeapon.RequestGetWeaponList")
  LogicRole.RequestMyHeroInfoToServer()
  LogicOutsideWeapon.RequestGetWeaponList()
  SkinHandler.SendGetHeroSkinList()
  SkinHandler.SendGetWeaponSkinList()
  HeirloomHandler.RequestGetFamilytreasureToServer()
  self:InitInfo()
  self:PlayInLobbyPanelAnimation(false)
  UpdateVisibility(self.WBP_TotalAttrTips, false)
  self.SpeakActionName = "CopyTeamCode"
  LogicLobby.ChangeModeSelectionVideoState(false)
  LogicLobby.InitModeSelectionMaterialParamValue()
  UpdateVisibility(self.WBP_LobbyFunctionSet.WBP_LobbyFunctionPanel, true)
  self.WBP_LobbyFunctionSet.WBP_MonthCardIcon.ParentView = self
end
function WBP_LobbyPanel_C:OnShow()
  self:BindOnPanelShown()
  SetLobbyPanelCurrencyList(true, {
    99994,
    300005,
    300101
  })
end
function WBP_LobbyPanel_C:OnRollback()
  self:PlayInLobbyPanelAnimation(false)
end
function WBP_LobbyPanel_C:OnHide()
  self:BindOnPanelHidden()
end
function WBP_LobbyPanel_C:OnLevelUp(Exp)
  Logic_Level.OnLevelUp(Exp)
end
function WBP_LobbyPanel_C:BindOnTotalAttributeTipsVisChanged(IsVis, CurHeroId)
  if IsVis then
    self.WBP_TotalAttrTips:LobbyShow(CurHeroId)
  else
    self.WBP_TotalAttrTips:Hide()
  end
end
function WBP_LobbyPanel_C:BindOnChangeLobbyMenuPanelVis(IsShow)
  self.IsShowLobbyMenuPanel = IsShow
  if IsShow then
    UIMgr:Show(ViewID.UI_LobbyEscMenuPanel)
  else
    UIMgr:Hide(ViewID.UI_LobbyEscMenuPanel)
  end
end
function WBP_LobbyPanel_C:BindOnLobbyLabelSelected(LabelTagName, CommonLinkRow)
  local CurShowLabelName = LogicLobby.GetCurSelectedLabelName()
  if CurShowLabelName and CurShowLabelName == LabelTagName then
    print("\229\189\147\229\137\141\233\161\181\231\173\190\230\178\161\230\156\137\228\191\174\230\148\185")
    return
  end
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:UserTriggerClickByTag(LabelTagName)
  end
  local IsShowCurrencyList = false
  for i, v in ipairs(ShowCurrencyListLabel) do
    if v == LabelTagName then
      IsShowCurrencyList = true
      break
    end
  end
  UpdateVisibility(self.WBP_LobbyCurrencyList, IsShowCurrencyList)
  if IsShowCurrencyList then
    self.WBP_LobbyCurrencyList:ClearListContainer()
    self.WBP_LobbyCurrencyList:InitCurrencyList()
  end
  if CurShowLabelName then
    local Result, RowInfo = GetRowData(DT.DT_LobbyPanelLabel, CurShowLabelName)
    if Result and not UE.UKismetStringLibrary.IsEmpty(RowInfo.TargetUIName) then
      UIMgr:Hide(ViewID[RowInfo.TargetUIName])
    end
  end
  LogicLobby.SetCurSelectedLabelName(LabelTagName)
  local Result, RowInfo = GetRowData(DT.DT_LobbyPanelLabel, LabelTagName)
  if not Result then
    print("WBP_LobbyPanel_C:BindOnLobbyLabelSelected not found RowInfo DT_LobbyPanelLabel, RowName:", LabelTagName)
    return
  end
  if UE.UKismetStringLibrary.IsEmpty(RowInfo.TargetUIName) then
    return
  end
  local DefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
  if DefaultLabelName == LabelTagName then
    self.ExitGameKey:UpdateKeyDesc(self.ExitGameText)
  else
    self.ExitGameKey:UpdateKeyDesc(self.ReturnLobbyText)
  end
  CommonLinkRow = CommonLinkRow or LogicLobby.GetPendingSelectedRowName()
  local ParamList = LogicLobby.GetPendingParamList()
  if CommonLinkRow then
    UIMgr:ShowLink(ViewID[RowInfo.TargetUIName], false, CommonLinkRow.LinkParams, ParamList)
  else
    UIMgr:Show(ViewID[RowInfo.TargetUIName])
  end
  local View = UIMgr:GetLuaFromActiveView(ViewID[RowInfo.TargetUIName])
  if View then
    self:RefreshBottomFunctionalButtonPanel(View)
  end
end
function WBP_LobbyPanel_C:RefreshBottomFunctionalButtonPanel(CurActiveWidget)
  if not CurActiveWidget.FunctionalBtnList then
    self.SpecialFunctionalBtnPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local AllChildren = self.SpecialFunctionalBtnPanel:GetAllChildren()
  for key, SingleWidget in pairs(AllChildren) do
    SingleWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local Index = 0
  local Item, Slot
  local Padding = UE.FMargin()
  Padding.Right = 5.0
  self:UpdateSpecialFunctionalBtnPanel(true)
  for KeyName, KeyDesc in pairs(CurActiveWidget.FunctionalBtnList) do
    Item = self.SpecialFunctionalBtnPanel:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.SpecialFunctionalBtnTemplate:StaticClass())
      Slot = self.SpecialFunctionalBtnPanel:AddChild(Item)
      Slot:SetPadding(Padding)
    end
    Slot = UE.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(Item)
    Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Center)
    Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Center)
    Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    Item:SetWidgetConfig(false, KeyName, KeyDesc, false)
    Index = Index + 1
  end
end
function WBP_LobbyPanel_C:UpdateSpecialFunctionalBtnPanel(bIsShow)
  UpdateVisibility(self.SpecialFunctionalBtnPanel, bIsShow)
end
function WBP_LobbyPanel_C:BindOnOpenSettingsKeyPressed()
  LogicGameSetting.ShowGameSettingPanel()
  self:OnClickBGMouseButtonDown()
end
function WBP_LobbyPanel_C:BindOnEscKeyPressed()
  local LobbyDefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
  local CurShowLabelName = LogicLobby.GetCurSelectedLabelName()
  if self.IsShowLobbyMenuPanel then
    EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, false)
    return
  end
  if CurShowLabelName == LobbyDefaultLabelName then
    EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, not self.IsShowLobbyMenuPanel)
  else
    LogicLobby.ChangeLobbyPanelLabelSelected(LobbyDefaultLabelName)
  end
  self:OnClickBGMouseButtonDown()
end
function WBP_LobbyPanel_C:BindOnSelectPrevMenu()
  if #self.FirstLabelList <= 0 then
    return
  end
  local CurSelectedLabelName = LogicLobby.GetCurSelectedLabelName()
  for key, value in pairs(self.FirstLabelList) do
    if string.find(CurSelectedLabelName, value) then
      if key <= 1 then
        LogicLobby.ChangeLobbyPanelLabelSelected(self.FirstLabelList[#self.FirstLabelList])
      else
        LogicLobby.ChangeLobbyPanelLabelSelected(self.FirstLabelList[key - 1])
      end
    end
  end
end
function WBP_LobbyPanel_C:BindOnSelectNextMenu()
  if #self.FirstLabelList <= 0 then
    return
  end
  local CurSelectedLabelName = LogicLobby.GetCurSelectedLabelName()
  for key, value in pairs(self.FirstLabelList) do
    if string.find(CurSelectedLabelName, value) then
      if key >= #self.FirstLabelList then
        LogicLobby.ChangeLobbyPanelLabelSelected(self.FirstLabelList[1])
      else
        LogicLobby.ChangeLobbyPanelLabelSelected(self.FirstLabelList[key + 1])
      end
    end
  end
end
function WBP_LobbyPanel_C:OnShow()
  SetInputMode_GameAndUIEx(self:GetOwningPlayer(), self, UE.EMouseLockMode.LockAlways, true)
  self:BindOnPanelShown()
end
function WBP_LobbyPanel_C:OnHide()
  SetLobbyPanelCurrencyList(false)
  self:BindOnPanelHidden()
  self:OnClickBGMouseButtonDown()
end
function WBP_LobbyPanel_C:Destruct()
  UnListenObjectMessage("LobbyLevelUp", self)
  self.CanvasPanel_Menu:ClearChildren()
  EventSystem.RemoveListener(EventDef.Lobby.PlayInAnimation, self.OnPlayInAnimation, self)
  EventSystem.RemoveListener(EventDef.Lobby.PlayOutAnimation, self.OnPlayOutAnimation, self)
  EventSystem.RemoveListener(EventDef.RoleMain.OnTotalAttributeTipsVisChanged, self.BindOnTotalAttributeTipsVisChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.ChangeLobbyMenuPanelVis, self.BindOnChangeLobbyMenuPanelVis)
  EventSystem.RemoveListener(EventDef.Lobby.OnLobbyLabelSelected, self.BindOnLobbyLabelSelected, self)
  EventSystem.RemoveListenerNew(EventDef.LobbyPanel.SpecialFuncPanelVisCahange, self, self.UpdateSpecialFunctionalBtnPanel)
  EventSystem.RemoveListenerNew(EventDef.Season.SeasonModeChanged, self, self.InitPages)
  EventSystem.RemoveListenerNew(EventDef.Lobby.OpenMonthCardTip, self, self.BindMonthCardTipOpen)
end
function WBP_LobbyPanel_C:InitInfo()
  self:InitPages()
end
function WBP_LobbyPanel_C:InitPages()
  local LabelTreeStruct = LogicLobby.GetLabelParentChildTreeStruct()
  self.FirstLabelList = {}
  for FirstLabelTagName, value in pairs(LabelTreeStruct) do
    if ModuleManager:Get("LobbyModule"):CheckLabelVisble(FirstLabelTagName) then
      table.insert(self.FirstLabelList, FirstLabelTagName)
    end
  end
  table.sort(self.FirstLabelList, function(a, b)
    local AResult, ARowInfo = GetRowData(DT.DT_LobbyPanelLabel, a)
    local BResult, BRowInfo = GetRowData(DT.DT_LobbyPanelLabel, b)
    return ARowInfo.Priority > BRowInfo.Priority
  end)
  local SingleItem, Slot
  local Anchors = UE.FAnchors()
  Anchors.Minimum = UE.FVector2D(0, 0)
  Anchors.Maximum = UE.FVector2D(0, 0)
  local idx = 1
  local RGGameUserSettings = UE.URGGameUserSettings.GetRGGameUserSettings()
  local TxtCultureTag = UE.URGBlueprintLibrary.RequestNameToGameplayTag("Settings.Language.Common.Interface")
  local TxtCultureValue = RGGameUserSettings:GetGameSettingByTag(TxtCultureTag)
  local Padding = self.TxtCulturePadding:ToTable()[TxtCultureValue + 1]
  Padding = Padding or 160
  for index, SingleLabelTagName in ipairs(self.FirstLabelList) do
    SingleItem = self.CanvasPanel_Menu:GetChildAt(index)
    if not SingleItem then
      SingleItem = UE.UWidgetBlueprintLibrary.Create(self, self.MenuButtonItemTemplate:StaticClass())
      Slot = self.CanvasPanel_Menu:AddChildToCanvas(SingleItem)
      Slot:SetAnchors(Anchors)
      Slot:SetAlignment(UE.FVector2D(0.5, 0))
      Slot:SetAutoSize(true)
      Slot:SetPosition(UE.FVector2D((index - 1) * Padding, 0))
    end
    SingleItem:Show(SingleLabelTagName, LabelTreeStruct[SingleLabelTagName])
    UpdateVisibility(SingleItem, true)
    idx = idx + 1
    if "LobbyLabel.Role" == SingleLabelTagName then
      BeginnerGuideData:UpdateWidget("RoleSelectButton", SingleItem.WBP_RGBeginnerGuidanceMarkArea)
    elseif "LobbyLabel.Talent" == SingleLabelTagName then
    end
  end
  HideOtherItem(self.CanvasPanel_Menu, idx + 1, true)
  local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_InteractTipWidgetMenuNext)
  slotCanvas:SetPosition(UE.FVector2D((idx - 2) * Padding + 100, 14.5))
  if self.WBP_InteractTipWidgetMenuNext:CanTipWidgetShowByInputType() then
    UpdateVisibility(self.WBP_InteractTipWidgetMenuNext, true)
  end
  local DefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
  DefaultLabelName = DefaultLabelName or self.FirstLabelList[1]
  if DefaultLabelName then
    LogicLobby.ChangeLobbyPanelLabelSelected(DefaultLabelName)
  end
end
function WBP_LobbyPanel_C:BindMonthCardTipOpen()
  UpdateVisibility(self.ClickBG, true, true)
end
function WBP_LobbyPanel_C:BindOnPanelShown()
  print("LobbyPanelShown")
  EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, false)
  local CurSelectedLabelTagName = LogicLobby.GetCurSelectedLabelName()
  if CurSelectedLabelTagName then
    local Result, RowInfo = GetRowData(DT.DT_LobbyPanelLabel, CurSelectedLabelTagName)
    if Result then
      if UIMgr:IsShow(ViewID[RowInfo.TargetUIName]) then
        return
      end
      local View = UIMgr:GetLuaFromDisableView(ViewID[RowInfo.TargetUIName])
      if View and View.ShowByLobbyPanel then
        View:ShowByLobbyPanel()
      end
      UIMgr:Show(ViewID[RowInfo.TargetUIName])
    end
  end
end
function WBP_LobbyPanel_C:BindOnPanelHidden()
  print("LobbyPanelHidden")
  self.WBP_TotalAttrTips:Hide()
  local CurSelectedLabelTagName = LogicLobby.GetCurSelectedLabelName()
  if CurSelectedLabelTagName then
    local Result, RowInfo = GetRowData(DT.DT_LobbyPanelLabel, CurSelectedLabelTagName)
    if Result then
      UIMgr:Hide(ViewID[RowInfo.TargetUIName])
    end
  end
end
function WBP_LobbyPanel_C:OnClickBGMouseButtonDown(MyGeometry, MouseEvent)
  self.WBP_LobbyFunctionSet.WBP_MonthCardIcon:CloseCardTips()
  UpdateVisibility(self.ClickBG, false)
  return UE.UWidgetBlueprintLibrary.Handled()
end
function WBP_LobbyPanel_C:OnPlayInAnimation()
  self:PlayInLobbyPanelAnimation()
end
function WBP_LobbyPanel_C:OnPlayOutAnimation()
  self:PlayOutAnimation()
  self.MatchingPanel:Hide()
end
function WBP_LobbyPanel_C:ListenForSpeakInputAction()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
    local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
    if 1 == CurValue then
      TeamVoiceModule:SetMicMode(0, false)
    end
  end
end
function WBP_LobbyPanel_C:ListenForSpeakInputReleasedAction()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
    local CurValue = GameUserSettings:GetGameSettingByTag(Tag)
    if 1 == CurValue then
      TeamVoiceModule:SetMicMode(1, false)
    end
  end
end
function WBP_LobbyPanel_C:PlayInLobbyPanelAnimation(bDelayPlay)
  local playFunc = function()
    if self then
      self:StopAnimation(self.ani_lobbypanel_out)
      self:StopAnimation(self.ani_lobbypanel_in)
      self:PlayAnimation(self.ani_lobbypanel_in)
      if not self.WBP_LobbyFunctionSet:IsAnimationPlaying(self.WBP_LobbyFunctionSet.ani_lobbyfunctionset_in) then
        self.WBP_LobbyFunctionSet:PlayInAnimation()
      end
      local LobbyMain = UIMgr:GetLuaFromActiveView(ViewID.UI_LobbyMain)
      if LobbyMain and LobbyMain.PlayInAnimation then
        LobbyMain:PlayInAnimation()
      end
    end
  end
  if bDelayPlay then
    local LobbyMain = UIMgr:GetLuaFromActiveView(ViewID.UI_LobbyMain)
    if LobbyMain and LobbyMain.StopLobbyMainAni then
      LobbyMain:StopLobbyMainAni()
    end
    self.Overlay_Panel:SetRenderOpacity(0)
    self.DelayLobbyMainInAnimTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        playFunc()
      end
    }, self.LobbyMainAnimDelayTime, false)
  else
    self.Overlay_Panel:SetRenderOpacity(0)
    playFunc()
  end
end
function WBP_LobbyPanel_C:PlayOutAnimation()
  self:PlayAnimation(self.ani_lobbypanel_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, true)
  self.WBP_LobbyFunctionSet:PlayOutAnimation()
end
return WBP_LobbyPanel_C
