local WBP_Occupancy_C = UnLua.Class()
local MaxPlayerNum = 4
local PlayerNum = 0
local ArrowNameFormat = "ImageRoleListBg_"
local Opening = NSLOCTEXT("WBP_Occupancy_C", "HackingChest", "\230\173\163\229\156\168\233\170\135\229\133\165\229\174\157\231\174\177")
local Stoping = NSLOCTEXT("WBP_Occupancy_C", "UnHackingChest", "\233\170\135\229\133\165\230\154\130\229\129\156")

function WBP_Occupancy_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_Occupancy_C:OnInit()
  self.RoleItemList = {}
  self:EnterOccupancyLevelImp()
  local needListenHudCreat = true
  if not LogicHUD then
    print("WBP_Occupancy_C:OnInit LogicHUD Is Nil")
  elseif not LogicHUD.GetHUDActor() then
    print("WBP_Occupancy_C:OnInit LogicHUD.GetHUDActor() Is Nil")
  elseif not LogicHUD.GetHUDActor().RGWidgetRight then
    print("WBP_Occupancy_C:OnInit LogicHUD.GetHUDActor().RGWidgetRight Is Nil")
  elseif not LogicHUD.GetHUDActor().RGWidgetRight.WBP_BattleModeTask then
    print("WBP_Occupancy_C:OnInit LogicHUD.GetHUDActor().RGWidgetRight:GetUserWidgetObject().WBP_BattleModeTask Is Nil")
  else
    needListenHudCreat = false
    self:InitTaskWidget()
  end
  if needListenHudCreat then
    EventSystem.AddListenerNew(EventDef.HUD.InitHUDActor, self, self.InitTaskWidget)
  end
end

function WBP_Occupancy_C:InitTaskWidget()
end

function WBP_Occupancy_C:OnDeInit()
  self.Overridden.Construct(self)
  EventSystem.RemoveListenerNew(EventDef.HUD.InitHUDActor, self, self.InitTaskWidget)
  self.RoleItemList = nil
end

function WBP_Occupancy_C:OnAnimationFinished(Animation)
  if Animation == self.FailedAni then
    self:ChangeBindFailedAniFinishedNextTab()
  elseif Animation == self.DefendSuccess then
    self:BindDefendSuccessFinished()
  elseif Animation == self.ExitCircleProgressAni then
    self:BindExitCircleProgressAniFinished()
  end
end

function WBP_Occupancy_C:BindFailedAniFinished()
end

function WBP_Occupancy_C:BindDefendSuccessFinished()
end

function WBP_Occupancy_C:BindExitCircleProgressAniFinished()
  if self.bIsExcuteFinished then
    local MarkItem = UE.URGBlueprintLibrary.GetMarkItem(self, self.LevelGamePlay)
    if MarkItem then
      UpdateVisibility(MarkItem.RootCanvasPanel, true)
    end
    UpdateVisibility(self.CanvasPanelProgress, false)
  end
end

function WBP_Occupancy_C:BindDefendStartAniFinished()
end

function WBP_Occupancy_C:UpdateDefendPlayer()
  if not self.LevelGamePlay then
    return
  end
  local DefendPlayerNum = self.LevelGamePlay:GetOverlappedActorsNum()
  for i = 1, PlayerNum do
    if not self.RoleItemList[i] then
      self.RoleItemList[i] = UE.UWidgetBlueprintLibrary.Create(GameInstance, self.OccupancyRoleItemCls)
      self.HorizontalBoxRole:AddChild(self.RoleItemList[i])
    end
    local ArrowName = ArrowNameFormat .. i
    UpdateVisibility(self[ArrowName], i == DefendPlayerNum)
    if i <= DefendPlayerNum then
      self.RoleItemList[i]:Update(true)
    elseif self.RoleItemList[i] then
      self.RoleItemList[i]:Update(false)
    end
  end
  for i = PlayerNum + 1, MaxPlayerNum do
    local ArrowName = ArrowNameFormat .. i
    if self[ArrowName] then
      self[ArrowName]:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function WBP_Occupancy_C:EnterAreaImp(LevelGamePlayParam, OtherActor)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character == OtherActor and OtherActor.LifeState ~= UE.ERGLifeState.Alive then
    return
  end
  self:UpdateDefendPlayer()
  if self.bIsStarted and not self.bIsEnded then
    if not Character or not OtherActor then
      return
    end
    if Character ~= OtherActor then
      return
    end
    local MatInst = self.URGImageProgress:GetDynamicMaterial()
    if MatInst then
      MatInst:SetVectorParameterValue("\232\161\128\230\157\161\233\162\156\232\137\178", self.NormalProgressColor)
    end
    self.RGTextTips:SetText(Opening())
    self.bIsExcuteFinished = false
    self:StopAnimation(self.ExitCircleProgressAni)
    self:PlayAnimation(self.ExitCircleProgressAni, 0, 1, UE.EUMGSequencePlayMode.Reverse)
    UpdateVisibility(self.CanvasPanelProgress, true)
    PlaySound2DEffect(80004, "WBP_Occupancy_C:BP_ProgressStart")
    local MarkItem = UE.URGBlueprintLibrary.GetMarkItem(self, LevelGamePlayParam)
    if MarkItem then
      UpdateVisibility(MarkItem.RootCanvasPanel, false)
    end
  elseif not self.bIsStarted and not self.bIsEnded then
    self.CanvasPanelInteract:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_Occupancy_C:ExitAreaImp(LevelGamePlayParam, OtherActor)
  self:UpdateDefendPlayer()
  if self.bIsStarted and not self.bIsEnded then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if not Character or not OtherActor then
      return
    end
    if Character ~= OtherActor then
      return
    end
    local MatInst = self.URGImageProgress:GetDynamicMaterial()
    if MatInst then
      MatInst:SetVectorParameterValue("\232\161\128\230\157\161\233\162\156\232\137\178", self.OutCircleProgressColor)
    end
    local DefendPlayerNum = 0
    if LevelGamePlayParam then
      DefendPlayerNum = LevelGamePlayParam:GetOverlappedActorsNum()
    end
    if DefendPlayerNum <= 0 then
      UpdateVisibility(self.RGTextTips, true)
      self.RGTextTips:SetText(Stoping())
      PlaySound2DEffect(80005)
    else
      UpdateVisibility(self.RGTextTips, false)
    end
    self.bIsExcuteFinished = true
    self:PlayAnimation(self.ExitCircleProgressAni)
  elseif not self.bIsStarted and not self.bIsEnded then
    self.CanvasPanelInteract:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_Occupancy_C:FailedImp(LevelGamePlayParam)
  self.WBP_BattleModeContent:ShowFailed()
  PlaySound2DEffect(80003, "WBP_Occupancy_C:FailedImp")
end

function WBP_Occupancy_C:FinishedImp(LevelGamePlayParam)
  self.WBP_BattleModeContent:ShowSuccess()
  PlaySound2DEffect(80002, "WBP_Occupancy_C:FinishedImp")
end

function WBP_Occupancy_C:ShutdownImp(LevelGamePlayParam)
  self.bIsEnded = true
  self.ProgressState = UE.EProgressState.NotStarted
  self.PrePlayerNum = -1
  self.CanvasPanelProgress:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CanvasPanelInteract:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_Occupancy_C:StartupImp(LevelGamePlayParam)
  self.CanvasPanelInteract:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.WBP_BattleModeContent:BeginAssembly()
  PlaySound2DEffect(80001, "WBP_Occupancy_C:ShutdownImp")
end

function WBP_Occupancy_C:EnterOccupancyLevelImp()
  local GS = UE.UGameplayStatics.GetGameState(self)
  if GS then
    PlayerNum = GS.PlayerArray:Num()
  end
end

function WBP_Occupancy_C:BP_ProgressStart()
end

function WBP_Occupancy_C:BP_ProgressPause()
  NotifyObjectMessage(nil, GMP.MSG_OccupationPause)
  local MatInst = self.URGImageProgress:GetDynamicMaterial()
  if MatInst then
    MatInst:SetVectorParameterValue("\232\161\128\230\157\161\233\162\156\232\137\178", self.OutCircleProgressColor)
  end
  UpdateVisibility(self.RGTextTips, true)
  self.RGTextTips:SetText(Stoping())
  self.bIsExcuteFinished = true
  self:PlayAnimation(self.ExitCircleProgressAni)
end

function WBP_Occupancy_C:BP_ProgressResume()
  PlaySound2DEffect(80006, "WBP_Occupancy_C:BP_ProgressResume")
end

function WBP_Occupancy_C:OccupancyShutdown()
  self.bIsEnded = true
  self.CanvasPanelProgress:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:StopAnimation(self.DefendSuccess)
  self:StopAnimation(self.FailedAni)
  self:StopAnimation(self.ExitCircleProgressAni)
end

function WBP_Occupancy_C:Destruct()
  self.Overridden.Destruct(self)
end

function WBP_Occupancy_C:LuaTick(InDeltaTime)
  if self.TaskWidget then
    self.TaskWidget:OccupancyRefreshCountDown(self.CountDown)
  end
end

return WBP_Occupancy_C
