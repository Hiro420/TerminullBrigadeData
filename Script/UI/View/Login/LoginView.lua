local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local LoginData = require("Modules.Login.LoginData")
local LoginHandler = require("Protocol.LoginHandler")
local LoginView = Class(ViewBase)

function LoginView:BindClickHandler()
  self.Button_Join.OnClicked:Add(self, self.OnClicked_Join)
  self.Button_SetNickName.OnClicked:Add(self, self.OnClicked_SetNickName)
  self.Text_Account.OnTextChanged:Add(self, self.OnAccountTextChanged)
  self.Text_UserName.OnTextChanged:Add(self, self.OnUserNameTextChanged)
  self.Combo_NewServerList.OnSelectionChanged:Add(self, self.OnSelChanged_ComboNewServerList)
  self.Btn_Announcement.OnClicked:Add(self, self.BindOnAnnouncementButtonClicked)
  self.Btn_ExitAccount.OnClicked:Add(self, self.BindOnExitAccountButtonClicked)
  self.Btn_AgeReminder.OnClicked:Add(self, self.BindOnAgeReminderButtonClicked)
  self.Btn_AgeReminder12.OnClicked:Add(self, self.BindOnAgeReminderButtonClicked)
  self.Btn_Close.OnClicked:Add(self, self.BindOnCloseButtonClicked)
end

function LoginView:UnBindClickHandler()
  self.Button_Join.OnClicked:Remove(self, self.OnClicked_Join)
  self.Button_SetNickName.OnClicked:Remove(self, self.OnClicked_SetNickName)
  self.Text_Account.OnTextChanged:Remove(self, self.OnAccountTextChanged)
  self.Text_UserName.OnTextChanged:Remove(self, self.OnUserNameTextChanged)
  self.Combo_NewServerList.OnSelectionChanged:Remove(self, self.OnSelChanged_ComboNewServerList)
  self.Btn_Announcement.OnClicked:Remove(self, self.BindOnAnnouncementButtonClicked)
  self.Btn_ExitAccount.OnClicked:Remove(self, self.BindOnExitAccountButtonClicked)
  self.Btn_AgeReminder.OnClicked:Remove(self, self.BindOnAgeReminderButtonClicked)
  self.Btn_AgeReminder12.OnClicked:Remove(self, self.BindOnAgeReminderButtonClicked)
  self.Btn_Close.OnClicked:Remove(self, self.BindOnCloseButtonClicked)
end

function LoginView:OnInit()
  self.DataBindTable = {
    {
      Source = "AccountName",
      Target = "Text_Account",
      Policy = DataBinding.DirectText(),
      Callback = LoginView.OnAccountNameChanged
    },
    {
      Source = "IsShowLoginPanel",
      Target = "CanvasPanelLogin",
      Policy = DataBinding.CollapsedOrSelfNotHit
    },
    {
      Source = "IsShowNicknamePanel",
      Target = "CanvasPanelSetNickName",
      Policy = DataBinding.CollapsedOrSelfNotHit
    }
  }
  self.ViewModel = UIModelMgr:Get("LoginViewModel")
  self:BindClickHandler()
  if UE.URGBlueprintLibrary.IsPlatformConsole() then
    local ContactPersonManager = ModuleManager:Get("ContactPersonModule")
    if ContactPersonManager then
      ContactPersonManager:CheckSessionUpdateDelegate()
    end
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
  if UserOnlineSubsystem then
    UserOnlineSubsystem.OnUpdateUserInfoCompleteDelegate:Add(self, self.OnUpdateUserInfoComplete)
  end
  EventSystem.AddListenerNew(EventDef.Login.OnGetUserID, self, self.UpdateXboxPanelVisible)
end

function LoginView:OnDestroy()
  self:UnBindClickHandler()
  if UE.URGBlueprintLibrary.IsPlatformConsole() then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
    if UserOnlineSubsystem then
      UserOnlineSubsystem.OnUpdateUserInfoCompleteDelegate:Remove(self, self.OnUpdateUserInfoComplete)
    end
  end
  EventSystem.RemoveListenerNew(EventDef.Login.OnGetUserID, self, self.UpdateXboxPanelVisible)
end

function LoginView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  SetInputMode_GameAndUIEx(self:GetOwningPlayer(), self, UE.EMouseLockMode.LockAlways, true)
  self:DefaultInputName()
  self:ClearComboServerListOptions()
  self:PlayAnimation(self.ani_login_in)
  self:PlayAnimation(self.ani_login_loop, 0, 0)
  if LoginData:GetIsRequestServerList() then
    print("LoginFlow", "LoginView:OnShow - \229\188\128\229\167\139\230\139\137\229\143\150\230\156\141\229\138\161\229\153\168\229\136\151\232\161\168")
    self:InitServerListPullService()
  else
    local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, HttpCommunication.GetHttpServiceClass())
    local DefaultServerInfo = require("GameConfig.ServerInfoConfig")
    print("LoginView:OnShow", SaveLastSelectServerName)
    HttpService:AddHttpServerList(DefaultServerInfo.Name, DefaultServerInfo.IP, DefaultServerInfo.Port, DefaultServerInfo.IsTLS)
    LoginData:SaveLastSelectServeName(DefaultServerInfo.Name)
    LoginData:SetLobbyServerId(DefaultServerInfo.Code)
    UE.URGLogLibrary.TriggerClientLogEvent(self, UE.ERGClientLogEvent.Activation)
  end
  self.ViewModel:CheckNeedShowKickOutTip()
  local DistributionChannel = DataMgr.GetDistributionChannel()
  self:ChangeExitAccountButtonVis(DistributionChannel == LogicLobby.DistributionChannelList.Normal)
end

function LoginView:ClearComboServerListOptions()
  self.Combo_NewServerList:ClearOptions()
end

function LoginView:DefaultInputName()
  if not UE.URGBlueprintLibrary.CheckWithEditor() then
    return
  end
  local AccountPrefixSettings = UE.UAccountPrefixSettings.GetAccountPrefixSettings()
  if not AccountPrefixSettings then
    return
  end
  self.Text_Account:SetText(AccountPrefixSettings.DefaultAccountPrefix)
end

function LoginView:ChangeExitAccountButtonVis(IsShow)
  UpdateVisibility(self.Btn_ExitAccount, false)
end

function LoginView:OnHide()
  self:ShutdownServerListPullService()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function LoginView:AddServerList(name)
  self.Combo_NewServerList:AddOption(name)
end

function LoginView:UpdateLastSelectedServer(name, DefaultServerIndex, IsForceServerId)
  local TargetIndex = self.Combo_NewServerList:FindOptionIndex(name)
  if IsForceServerId or -1 == TargetIndex then
    TargetIndex = DefaultServerIndex
  end
  self.Combo_NewServerList:SetSelectedIndex(TargetIndex)
end

function LoginView:GetSelectedServerName()
  return self.Combo_NewServerList:GetSelectedOption()
end

function LoginView:OnAccountTextChanged(Text)
  local isTextEmpty = UKismetTextLibrary.TextIsEmpty(Text)
  UpdateVisibility(self.Txt_AccountHintText, isTextEmpty)
end

function LoginView:OnUserNameTextChanged(Text)
  local isTextEmpty = UKismetTextLibrary.TextIsEmpty(Text)
  UpdateVisibility(self.Txt_NameHintText, isTextEmpty)
end

function LoginView:OnSelChanged_ComboNewServerList(SelectedItem, SelectionType)
  self.ViewModel:SetLastSelectedServer(SelectedItem)
end

function LoginView:OnClicked_Join()
  self.ViewModel:Login(self.Text_Account:GetText())
end

function LoginView:OnClicked_SetNickName()
  local InputNickName = self:GetInputNickName()
  self.ViewModel:SetNicknameButtonClicked(InputNickName)
end

function LoginView:GetInputNickName()
  local Text = tostring(self.Text_UserName:GetText())
  local WidthStr = UE.URGBlueprintLibrary.ConvertFullWidthToHalfWidth(Text)
  return WidthStr
end

function LoginView:ChangeLoginPanelStep(Step)
  self.Step = Step
  UpdateVisibility(self.CanvasPanelLogin, false)
  UpdateVisibility(self.CanvasPanelNotLoginAndNotShowNameInput, false)
  UpdateVisibility(self.CanvasPanelLoggedInWaitClick, false)
  UpdateVisibility(self.CanvasPanelJapanPopup, false)
  UpdateVisibility(self.CanvasPanelSetNickName, false)
  UpdateVisibility(self.Btn_Announcement, true, true)
  UpdateVisibility(self.Btn_AgeReminder, true, true)
  self:RecoverIsOverseaPanel()
  if Step == ELoginStep.NotLogin then
    UpdateVisibility(self.CanvasPanelLogin, true)
  elseif Step == ELoginStep.NotLoginAndNotShowAccountNameInputPanel then
    UpdateVisibility(self.CanvasPanelNotLoginAndNotShowNameInput, true)
  elseif Step == ELoginStep.LoggedInWaitClick then
    self:SetKeyboardFocus()
    UpdateVisibility(self.CanvasPanelJapanPopup, false)
    UpdateVisibility(self.CanvasPanelLoggedInWaitClick, true)
    UpdateVisibility(self.CanvasPanelLoggedInWaitClick, true)
    self:UpdateXboxPanelVisible()
    local AccountCom = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGAccountSubsystem:StaticClass())
    if AccountCom then
      local RegionCode = AccountCom:GetRegion()
      print("LoginView RegionCode = " .. RegionCode)
      if "410" == RegionCode then
        UpdateVisibility(self.Btn_AgeReminder12, true, true)
      end
    end
  elseif Step == ELoginStep.SetNickName then
    UpdateVisibility(self.CanvasPanelSetNickName, true)
  elseif Step == ELoginStep.AfterSetNickName then
  elseif Step == ELoginStep.RegionClick then
    local AccountCom = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGAccountSubsystem:StaticClass())
    if AccountCom then
      local AccountRegionCode = AccountCom:GetRegion()
      print("LoginView RegionCode = " .. AccountRegionCode)
      if AccountRegionCode == RegionCode.Japan then
        UpdateVisibility(self.CanvasPanelJapanPopup, true)
      else
        self:ChangeLoginPanelStep(ELoginStep.LoggedInWaitClick)
      end
    else
      self:ChangeLoginPanelStep(ELoginStep.LoggedInWaitClick)
    end
  elseif Step == ELoginStep.Empty then
    UpdateVisibility(self.Btn_Announcement, false)
    UpdateVisibility(self.Btn_AgeReminder, false)
    UpdateVisibility(self.CanvasOverseaPanel, false, false)
    UpdateVisibility(self.CanvasChinaPanel, false, false)
  end
end

function LoginView:DelayChangeToLoggedInWaitClickStep()
  if self.Step ~= ELoginStep.AfterSetNickName then
    return
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ChangeToLoggedInWaitClickTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ChangeToLoggedInWaitClickTimer)
  end
  self.ChangeToLoggedInWaitClickTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self:ChangeLoginPanelStep(ELoginStep.LoggedInWaitClick)
    end
  }, 3.0, false)
end

function LoginView:UpdateXboxPanelVisible()
  local platformName = UE.URGBlueprintLibrary.GetPlatformName()
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo UpdateXboxPanelVisible platformName: %s", tostring(platformName)))
  if "XSX" == platformName then
    local CurChannelID = DataMgr.GetChannelUserId()
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo LoginView.UpdateXboxPanelVisible CurChannelID: %s", tostring(CurChannelID)))
    if CurChannelID then
      self:UpdateUserNickName(CurChannelID)
    end
    UpdateVisibility(self.CanvasPanelXbox, true)
  else
    UpdateVisibility(self.CanvasPanelXbox, false)
  end
end

function LoginView:OnUpdateUserInfoComplete(OnlineID)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo LoginView OnUpdateUserInfoComplete: %s", tostring(OnlineID)))
  self:UpdateUserNickName(OnlineID)
end

function LoginView:UpdateUserNickName(OnlineID)
  if self.Txt_ChannelID then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
    if UserOnlineSubsystem and UserOnlineSubsystem:CheckRequestLoginStatus() then
      local Res, NickName = UserOnlineSubsystem:GetPlayerNickName(OnlineID)
      DataMgr.PrintChannelInfoLog(string.format("ChannelInfo LoginView UpdateUserNickName OnlineID: %s", tostring(OnlineID)))
      DataMgr.PrintChannelInfoLog(string.format("ChannelInfo LoginView UpdateUserNickName NickName: %s", tostring(NickName)))
      if Res == UE.EUserQueryResult.valid then
        self.Txt_ChannelID:SetText(NickName)
      end
    end
  end
end

function LoginView:InitServerListPullService()
  self.RequestServerListTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self._RequestServerList
  }, 3.0, true)
  self:_RequestServerList()
end

function LoginView:ShutdownServerListPullService()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RequestServerListTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RequestServerListTimer)
  end
end

function LoginView:_RequestServerList()
  if LoginData:GetIsServerListInited() then
    self:ShutdownServerListPullService()
    return
  end
  if not LoginData:IsOverGetServerListMaxCount() then
    LoginHandler.SendServerListReq()
  else
    self:ShowRequestServerListFailed()
    print("\232\182\133\229\135\186\230\139\137\229\143\150\230\156\141\229\138\161\229\153\168\229\136\151\232\161\168\230\156\128\229\164\167\230\149\176\233\135\143\228\186\134")
  end
end

function LoginView:ShowRequestServerListFailed()
  self:ShutdownServerListPullService()
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveWindowManager then
    WaveWindowManager:ShowWaveWindowWithDelegate(101004, {}, nil, {
      self,
      function()
        UE.UKismetSystemLibrary.QuitGame(self, UE.UGameplayStatics.GetPlayerController(self, 0), UE.EQuitPreference.Quit, false)
      end
    })
  end
end

function LoginView:OnKeyDown(MyGeometry, InKeyEvent)
  if self.Step ~= ELoginStep.LoggedInWaitClick then
    return UE.UWidgetBlueprintLibrary.Handled()
  end
  self.ViewModel:ChangeLoggedInWaitClickStepToNextStep()
  return UE.UWidgetBlueprintLibrary.Handled()
end

function LoginView:OnWaitBGMouseButtonDown(MyGeometry, MouseEvent)
  self.ViewModel:ChangeLoggedInWaitClickStepToNextStep()
  return UE.UWidgetBlueprintLibrary.Handled()
end

function LoginView:BindOnAnnouncementButtonClicked()
  self.ViewModel:OnAnnouncementButtonClicked()
end

function LoginView:BindOnExitAccountButtonClicked()
  self.ViewModel:OnExitAccountButtonClicked()
end

function LoginView:BindOnAgeReminderButtonClicked()
  self.ViewModel:OnAgeReminderButtonClicked()
end

function LoginView:BindOnCloseButtonClicked()
  self.ViewModel:OnCloseButtonClicked()
end

function LoginView:Destruct()
  self:ShutdownServerListPullService()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ChangeToLoggedInWaitClickTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ChangeToLoggedInWaitClickTimer)
  end
end

function LoginView:RecoverIsOverseaPanel()
  local IsOversea = LogicLobby.IsLIPassLogin()
  UpdateVisibility(self.CanvasOverseaPanel, IsOversea, false)
  UpdateVisibility(self.CanvasChinaPanel, not IsOversea, false)
end

return LoginView
