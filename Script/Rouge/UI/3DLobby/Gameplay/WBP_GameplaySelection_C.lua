local WBP_GameplaySelection_C = UnLua.Class()

function WBP_GameplaySelection_C:Construct()
  local AllItem = self.ModeSelectionList:GetAllChildren()
  for i, SingleItem in pairs(AllItem) do
    SingleItem:Hide()
  end
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self:RefreshModeList()
    end
  }, 0.33, false)
  self.Btn_SaveSettings.OnClicked:Add(self, WBP_GameplaySelection_C.BindOnSaveSettingsButtonClicked)
  
  function self.EscFunctionalPanel.MainButtonClicked()
    self:BindOnEscKeyPressed()
  end
end

function WBP_GameplaySelection_C:BindOnSaveSettingsButtonClicked()
  local MaxUnLockFloor = DataMgr.GetGameFloorByGameMode(self.CurSelectMode)
  if (self.CurSelectMode ~= LogicTeam.GetWorldId() or self.CurSelectFloor ~= LogicTeam.GetFloor()) and MaxUnLockFloor >= self.CurSelectFloor then
    local TeamInfo = DataMgr.GetTeamInfo()
    if LogicTeam.IsCaptain() then
      if not DataMgr.IsInTeam() or TeamInfo.state ~= LogicTeam.TeamState.Matching then
        LogicTeam.RequestSetTeamDataToServer(self.CurSelectMode, LogicTeam.GetModeId(), self.CurSelectFloor)
      else
        local WaveWindowMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
        if WaveWindowMgr then
          WaveWindowMgr:ShowWaveWindow(1089, {})
        end
      end
    end
  else
    print("\230\151\160\233\156\128\228\191\174\230\148\185")
  end
  self:BindOnEscKeyPressed()
end

function WBP_GameplaySelection_C:FocusInput()
  self.Overridden.FocusInput(self)
  self:PlayAnimation(self.ani_GameplaySelection_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward)
  self:PlayAnimationForward(self.ani_GameplaySelection_in)
  LogicLobby.SetCanMove3DLobby(false)
  ListenForInputAction(self.EscName, UE.EInputEvent.IE_Pressed, true, {
    self,
    WBP_GameplaySelection_C.BindOnEscKeyPressed
  })
  EventSystem.AddListener(self, EventDef.Lobby.OnModeInfoItemClicked, WBP_GameplaySelection_C.BindOnModeInfoItemClicked)
end

function WBP_GameplaySelection_C:BindOnEscKeyPressed()
  if self:IsAnimationPlaying(self.ani_GameplaySelection_in) then
    self:StopAnimation(self.ani_GameplaySelection_in)
  end
  self:PlayAnimation(self.ani_GameplaySelection_out, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
end

function WBP_GameplaySelection_C:OnAnimationFinished(Animation)
  if Animation == self.ani_GameplaySelection_out then
    self:BindOnGameplaySelectionOutFinished()
  end
end

function WBP_GameplaySelection_C:BindOnGameplaySelectionOutFinished()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local WidgetClass = UE.UGameplayStatics.GetObjectClass(self)
  UIManager:Switch(WidgetClass, true)
end

function WBP_GameplaySelection_C:BindOnModeInfoItemClicked(ModeId, Floor)
  self.CurSelectMode = ModeId
  self.CurSelectFloor = Floor
end

function WBP_GameplaySelection_C:OnLeftMouseButtonDown()
  EventSystem.Invoke(EventDef.Lobby.OnGameplaySelectionBGClicked)
end

function WBP_GameplaySelection_C:RefreshModeList()
  local AllItem = self.ModeSelectionList:GetAllChildren()
  for i, SingleItem in pairs(AllItem) do
    SingleItem:Hide()
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local AllModeRowNames = DTSubsystem:GetAllGameMode(nil):ToTable()
  table.sort(AllModeRowNames, function(A, B)
    local AResult, ARowInfo = DTSubsystem:GetGameModeRowInfoById(tonumber(A), nil)
    local BResult, BRowInfo = DTSubsystem:GetGameModeRowInfoById(tonumber(B), nil)
    return ARowInfo.Priority > BRowInfo.Priority
  end)
  local ItemWidgetClass = self.ItemTemplate:StaticClass()
  local Index = 0
  for i, SingleModeRowName in ipairs(AllModeRowNames) do
    local AResult, ModeRowInfo = DTSubsystem:GetGameModeRowInfoById(tonumber(SingleModeRowName), nil)
    if AResult and ModeRowInfo.bCanSelected then
      local Item = self.ModeSelectionList:GetChildAt(Index)
      if not Item then
        Item = UE.UWidgetBlueprintLibrary.Create(self, ItemWidgetClass)
        self.ModeSelectionList:AddChild(Item)
      end
      Item:Show(tonumber(SingleModeRowName))
      Item:PlayInAnimation()
      Index = Index + 1
    end
  end
  EventSystem.Invoke(EventDef.Lobby.OnModeInfoItemClicked, LogicTeam.GetWorldId(), LogicTeam.GetFloor())
end

function WBP_GameplaySelection_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  self:RemoveListener()
  if self:IsAnimationPlaying(self.ani_GameplaySelection_loop) then
    self:StopAnimation(self.ani_GameplaySelection_loop)
  end
  LogicLobby.SetCanMove3DLobby(true)
end

function WBP_GameplaySelection_C:RemoveListener()
  if IsListeningForInputAction(self, self.EscName) then
    StopListeningForInputAction(self, self.EscName, UE.EInputEvent.IE_Pressed)
  end
  EventSystem.RemoveListener(EventDef.Lobby.OnModeInfoItemClicked, WBP_GameplaySelection_C.BindOnModeInfoItemClicked, self)
end

function WBP_GameplaySelection_C:Destruct()
  self:RemoveListener()
end

return WBP_GameplaySelection_C
