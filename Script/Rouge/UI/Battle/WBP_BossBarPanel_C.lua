local WBP_BossBarPanel_C = UnLua.Class()

function WBP_BossBarPanel_C:Construct()
  self.DisplayBossTable = {}
  self:ListenBossBar(true)
end

function WBP_BossBarPanel_C:Destruct()
  self:ListenBossBar(false)
  self.DisplayBossTable = {}
end

function WBP_BossBarPanel_C:GetWidget(Boss)
  for key, value in pairs(self.DisplayBossTable) do
    if value.Boss == Boss then
      return value.Widget
    end
  end
  local Idx = table.count(self.DisplayBossTable) + 1
  local Cachetable = {}
  Cachetable.Boss = Boss
  Cachetable.Widget = GetOrCreateItem(self.BossBarPanel, Idx, self.WBP_BossBarInfo:GetClass())
  Cachetable.Widget.Index = Idx
  UpdateVisibility(Cachetable.Widget, false)
  Cachetable.Widget:BlueprintBeginPlay(Boss)
  self.DisplayBossTable[Idx] = Cachetable
  print("HideOtherItem", Idx + 1)
  HideOtherItem(self.BossBarPanel, Idx + 1, true)
  return Cachetable.Widget
end

function WBP_BossBarPanel_C:RemoveWidget(Boss)
  local bFindConfig = false
  for key, value in pairs(self.DisplayBossTable) do
    if not bFindConfig and value.Boss == Boss then
      bFindConfig = true
      value.Widget:RemoveFromParent()
      self.DisplayBossTable[key] = nil
    end
  end
  for key, value in pairs(self.DisplayBossTable) do
    if value.Widget then
      print("SetDisplayStyle", table.count(self.DisplayBossTable))
      value.Widget:SetDisplayStyle(table.count(self.DisplayBossTable))
    end
  end
end

function WBP_BossBarPanel_C:ListenBossBar(IsListen)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  if IsListen then
    UIManager.ShowBossBarInfoDelegate:Add(self, WBP_BossBarPanel_C.BindShowBossBarInfo)
    if UIManager:GetShowBossBarInfoFlag() then
      self:BindShowBossBarInfo(UIManager:GetBossFlagActor())
    end
    UIManager.BossBarVisibilityDelegate:Add(self, WBP_BossBarPanel_C.BindBossBarVisibilityDelegate)
    local TargetActor = UIManager:GetBossSubActor()
    if TargetActor then
      self:ShowSubBossBar(UIManager:GetBossFlagActor(), TargetActor)
    end
    UIManager.ShowSubBossBarDelegate:Add(self, WBP_BossBarPanel_C.ShowSubBossBar)
  else
    UIManager.ShowBossBarInfoDelegate:Remove(self, WBP_BossBarPanel_C.BindShowBossBarInfo)
    UIManager.BossBarVisibilityDelegate:Remove(self, WBP_BossBarPanel_C.BindBossBarVisibilityDelegate)
    UIManager.ShowSubBossBarDelegate:Remove(self, WBP_BossBarPanel_C.ShowSubBossBar)
  end
end

function WBP_BossBarPanel_C:BindShowBossBarInfo(Boss, AnimType, RemoveOnDestroy)
  print("WBP_BossBarPanel_C:BindShowBossBarInfo", Boss, table.count(self.DisplayBossTable))
  local BossBarWidget
  if nil == Boss then
    return
  else
    BossBarWidget = self:GetWidget(Boss)
    if BossBarWidget:GetVisibility() ~= UE.ESlateVisibility.Collapsed then
      return
    end
    BossBarWidget:SetVisibility(UE.ESlateVisibility.Visible)
  end
  if nil == AnimType then
    AnimType = UE.EBossBarAnimType.None
  end
  if AnimType == UE.EBossBarAnimType.None then
  elseif AnimType == UE.EBossBarAnimType.Short then
    BossBarWidget:PlayAnimationForward(BossBarWidget.Ani_in, 1)
  elseif AnimType == UE.EBossBarAnimType.Medium then
    BossBarWidget:PlayAnimationForward(BossBarWidget.Ani_in, 1)
  elseif AnimType == UE.EBossBarAnimType.Long then
    EventSystem.Invoke(EventDef.BossTips.BossTipsUI)
    BossBarWidget:PlayAnimationForward(BossBarWidget.Ani_in_delay, 1)
  end
  for key, value in pairs(self.DisplayBossTable) do
    if value.Widget then
      print("SetDisplayStyle", table.count(self.DisplayBossTable))
      value.Widget:SetDisplayStyle(table.count(self.DisplayBossTable))
    end
  end
end

function WBP_BossBarPanel_C:ShowSubBossBar(ParentActor, BossSubActor, AnimType)
  local ItemWidget = self:GetWidget(ParentActor)
  if ItemWidget then
    ItemWidget:ShowSubBossBar(BossSubActor)
  end
end

function WBP_BossBarPanel_C:BindBossBarVisibilityDelegate(Boss, InVisibility, bRemoveWidget)
  if not Boss then
    return
  end
  if InVisibility == UE.ESlateVisibility.Hidden and bRemoveWidget then
    self:RemoveWidget(Boss)
    return
  end
  local ItemWidget = self:GetWidget(Boss)
  if ItemWidget then
    ItemWidget:SetVisibility(InVisibility)
  end
end

return WBP_BossBarPanel_C
