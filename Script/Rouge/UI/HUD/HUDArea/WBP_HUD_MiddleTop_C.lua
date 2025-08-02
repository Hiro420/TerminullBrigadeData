local WBP_HUD_MiddleTop_C = UnLua.Class()

function WBP_HUD_MiddleTop_C:Construct()
  print("WBP_HUD_MiddleTop_C, Construct")
  self:InitRiftGuardian()
end

function WBP_HUD_MiddleTop_C:Destruct()
  print("WBP_HUD_MiddleTop_C, Destruct")
  self:ListenBossBar(false)
  self:UnInitRiftGuardian()
end

function WBP_HUD_MiddleTop_C:Init()
end

function WBP_HUD_MiddleTop_C:UnInit()
end

function WBP_HUD_MiddleTop_C:OnUpdateBossBarVisibility(InVisibility)
  self.WBP_BossBarInfo:SetVisibility(InVisibility)
  self.WBP_BossBarInfo.ShieldBar:ForceChargingPercent()
end

function WBP_HUD_MiddleTop_C:OnCreateBossBar(Boss, AnimType, bRemoveOnDestroy)
  self.WBP_BossBarInfo:BlueprintBeginPlay(Boss)
  self:OnUpdateBossBarVisibility(UE.ESlateVisibility.Visible)
  if nil == AnimType then
    AnimType = 0
  end
  if 0 == AnimType then
  elseif 1 == AnimType then
    self.WBP_BossBarInfo:PlayAnimationForward(self.WBP_BossBarInfo.Ani_in, 1)
  elseif 2 == AnimType then
    self.WBP_BossBarInfo:PlayAnimationForward(self.WBP_BossBarInfo.Ani_in, 1)
  elseif 3 == AnimType then
    EventSystem.Invoke(EventDef.BossTips.BossTipsUI)
    self.WBP_BossBarInfo:PlayAnimationForward(self.WBP_BossBarInfo.Ani_in_delay, 1)
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:SetShowBossBarInfoFlag(false)
end

function WBP_HUD_MiddleTop_C:OnShowSubBossBar(BossSubActor)
  if BossSubActor and self.WBP_BossBarInfo:GetVisibility() == UE.ESlateVisibility.Collapsed then
    self:OnCreateBossBar()
  end
  self.WBP_BossBarInfo:ShowSubBossBar(BossSubActor)
end

function WBP_HUD_MiddleTop_C:ListenBossBar(IsListen)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  if IsListen then
    UIManager.ShowBossBarInfoDelegate:Add(self, WBP_HUD_MiddleTop_C.OnCreateBossBar)
    if UIManager:GetShowBossBarInfoFlag() then
      self:OnCreateBossBar()
    end
    UIManager.BossBarVisibilityDelegate:Add(self, WBP_HUD_MiddleTop_C.OnUpdateBossBarVisibility)
    local TargetActor = UIManager:GetBossSubActor()
    if TargetActor then
      self:OnShowSubBossBar(TargetActor)
    end
    UIManager.ShowSubBossBarDelegate:Add(self, WBP_HUD_MiddleTop_C.OnShowSubBossBar)
  else
    UIManager.ShowBossBarInfoDelegate:Remove(self, WBP_HUD_MiddleTop_C.OnCreateBossBar)
    UIManager.BossBarVisibilityDelegate:Remove(self, WBP_HUD_MiddleTop_C.OnUpdateBossBarVisibility)
    UIManager.ShowSubBossBarDelegate:Remove(self, WBP_HUD_MiddleTop_C.OnShowSubBossBar)
  end
end

function WBP_HUD_MiddleTop_C:InitRiftGuardian()
  UpdateVisibility(self.WBP_RiftGuardianBarInfo, false)
  ListenObjectMessage(nil, GMP.MSG_OnRiftGuardianBorn, self, self.BindOnRiftGuardianBorn)
  ListenObjectMessage(nil, GMP.MSG_OnRiftGuardianDie, self, self.BindOnRiftGuardianDie)
  ListenObjectMessage(nil, GMP.MSG_Level_Rift_Destroyed, self, self.BindOnLevelRiftDestroyed)
end

function WBP_HUD_MiddleTop_C:UnInitRiftGuardian()
  UnListenObjectMessage(GMP.MSG_OnRiftGuardianBorn, self)
  UnListenObjectMessage(GMP.MSG_OnRiftGuardianDie, self)
  UnListenObjectMessage(GMP.MSG_Level_Rift_Destroyed, self)
end

function WBP_HUD_MiddleTop_C:BindOnRiftGuardianBorn(OwningActor)
  self.WBP_RiftGuardianBarInfo:InitInfo(OwningActor)
  UpdateVisibility(self.WBP_RiftGuardianBarInfo, true)
end

function WBP_HUD_MiddleTop_C:BindOnRiftGuardianDie()
  UpdateVisibility(self.WBP_RiftGuardianBarInfo, false)
end

function WBP_HUD_MiddleTop_C:BindOnLevelRiftDestroyed()
  UpdateVisibility(self.WBP_RiftGuardianBarInfo, false)
end

function WBP_HUD_MiddleTop_C:ShowRift(TimeOffUTCStamp, SpawnTimeStamp, TimeOffStamp)
  self.WBP_RiftGuardianBarInfo:ShowRift(TimeOffUTCStamp, SpawnTimeStamp, TimeOffStamp)
end

function WBP_HUD_MiddleTop_C:HideRift()
  self.WBP_RiftGuardianBarInfo:HideRift()
end

function WBP_HUD_MiddleTop_C:RiftTick()
  self.WBP_RiftGuardianBarInfo:LuaTick()
end

return WBP_HUD_MiddleTop_C
