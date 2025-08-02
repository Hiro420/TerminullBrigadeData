local WBP_BossBarInfo_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")
local reddot_tbreddot = require("Tables.reddot_tbreddot")

function WBP_BossBarInfo_C:Construct()
  self.Overridden.Construct(self)
  self.IsStopMoveVirtualBar = true
  self.WBP_BossBarItemClass = UE.UClass.Load("/Game/Rouge/UI/Battle/WBP_BossBarItem.WBP_BossBarItem_C")
  EventSystem.AddListener(self, EventDef.BossTips.BossBerserk, WBP_BossBarInfo_C.OnBossBerserk)
  self.UIQuality = BattleUIScalability:GetBossBarInfoScalability()
end

function WBP_BossBarInfo_C:ShowSubBossBar(BossSubActor)
  for index, value in ipairs(self.HorizontalBox_BarsNum:GetAllChildren():ToTable()) do
    value:ShowSubBar(nil ~= BossSubActor)
  end
  if nil == BossSubActor then
    return
  end
  if self.ShieldBar:GetVisibility() == UE.ESlateVisibility.Collapsed then
    if self.UIQuality ~= UIQuality.LOW then
      self:PlayAnimation(self.Ani_ExtraHealthBar_in_1)
    end
    UpdateVisibility(self.Image_frame, true)
  else
    if self.UIQuality ~= UIQuality.LOW then
      self:PlayAnimation(self.Ani_ExtraHealthBar_in_2)
    end
    UpdateVisibility(self.Image_frame_lang, true)
  end
  UpdateVisibility(self.SubBar, true)
  UpdateVisibility(self.Overlay_Invincible, false)
  ListenObjectMessage(BossSubActor, GMP.MSG_Pawn_OnDeath, self, self.SubBossDeath)
  self.SubBar:InitInfo(BossSubActor)
  print("WBP_BossBarInfo_C:ShowSubBossBar", BossSubActor)
end

function WBP_BossBarInfo_C:SubBossDeath()
  print("WBP_BossBarInfo_C:SubBossDeath")
  for index, value in ipairs(self.HorizontalBox_BarsNum:GetAllChildren():ToTable()) do
    value:ShowSubBar(false)
  end
  if self.UIQuality ~= UIQuality.LOW then
    if self.ShieldBar:GetVisibility() == UE.ESlateVisibility.Collapsed then
      self:StopAnimation(self.Ani_ExtraHealthBar_in_1)
      self:PlayAnimation(self.Ani_ExtraHealthBar_out_1)
    else
      self:StopAnimation(self.Ani_ExtraHealthBar_in_2)
      self:PlayAnimation(self.Ani_ExtraHealthBar_out_2)
    end
  end
  if self.ShieldBar:GetVisibility() == UE.ESlateVisibility.Collapsed then
    UpdateVisibility(self.Image_frame, false)
  else
    UpdateVisibility(self.Image_frame_lang, false)
  end
end

function WBP_BossBarInfo_C:Destruct()
  self.Overridden.Destruct(self)
  UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HealthTimer)
  EventSystem.RemoveListener(EventDef.BossTips.BossBerserk, WBP_BossBarInfo_C.OnBossBerserk, self)
  if not self.Boss then
    return
  end
  local BuffComp = self.Boss.BuffComponent
  if not BuffComp then
    return
  end
  if not self.CoreComponent then
    return
  end
  local ASCComp = self.Boss.AbilitySystemComponent
  if ASCComp then
    ASCComp.EventOnRGAbilityTagUpdated:Remove(self, self.BindOnAbilityTagUpdate)
  end
  self.CoreComponent:UnBindAttributeChanged(self.HealthAttribute, {
    self,
    self.HealthAttributeChanged
  })
  self.CoreComponent:UnBindAttributeChanged(self.MaxHealthAttribute, {
    self,
    self.HealthAttributeChanged
  })
  self.CoreComponent:UnBindAttributeChanged(self.MaxShieldAttribute, {
    self,
    self.ShieldAttributeChanged
  })
  self.CoreComponent:UnBindAttributeChanged(self.ToughnessAttribute, {
    self,
    self.ToughnessAttributeChanged
  })
  BuffComp.OnBuffAdded:Remove(self, WBP_BossBarInfo_C.BindOnBuffChanged)
  BuffComp.OnBuffRemove:Remove(self, WBP_BossBarInfo_C.BindOnBuffRemoved)
  BuffComp.OnBuffChanged:Remove(self, WBP_BossBarInfo_C.BindOnBuffChanged)
  EventSystem.RemoveListener(EventDef.Battle.ElementChanged, WBP_BossBarInfo_C.BindOnElementChanged, self)
  for i, SingleWidget in iterator(self.BuffList:GetAllChildren()) do
    LogicBuffList.ListContainer:HideItem(SingleWidget)
  end
  print("WBP_BossBarInfo_C Destruct")
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    print("WBP_BossBarInfo_C UIManager ")
    return
  end
  UIManager.ShowSubBossBarDelegate:Remove(self, WBP_BossBarInfo_C.ShowSubBossBar)
  print("WBP_BossBarInfo_C ShowSubBossBarDelegate ", self, UIManager.ShowSubBossBarDelegate)
end

function WBP_BossBarInfo_C:LuaTick(InDeltaTime)
  self:InterpToTargetHealth(InDeltaTime)
  self:UpdateVirtualBarValue(InDeltaTime)
end

function WBP_BossBarInfo_C:BindOnBuffChanged(AddedBuff)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local BuffData = BuffDataSubsystem:GetDataFormID(AddedBuff.ID)
  if BuffData and BuffData.IsNeedShowOnHUD then
    local BuffInfo = {}
    BuffInfo.ID = AddedBuff.ID
    BuffInfo.CurrentCount = AddedBuff.CurrentCount
    BuffInfo.BuffData = BuffData
    BuffInfo.IsElement = false
    BuffInfo.Target = self.Boss
    if not self.AllBuffInfos[AddedBuff.ID] then
      table.insert(self.AllBuffIds, AddedBuff.ID)
    end
    self.AllBuffInfos[AddedBuff.ID] = BuffInfo
    self:RefreshBuffList()
    self:RefreshVirusInfo()
  end
end

function WBP_BossBarInfo_C:BindOnBuffRemoved(RemovedBuff)
  table.RemoveItem(self.AllBuffIds, RemovedBuff.ID)
  self.AllBuffInfos[RemovedBuff.ID] = nil
  self:RefreshBuffList()
  self:RefreshVirusInfo()
end

function WBP_BossBarInfo_C:BindOnElementChanged(Target, BuffId, Params, IsAdd)
  local self = Target
  local TargetActor
  if Params.Target:Cast(UE.ARGBodyPartActor) then
    TargetActor = Params.Target:GetOwner()
  else
    TargetActor = Params.Target
  end
  if TargetActor ~= self.Boss then
    return
  end
  if IsAdd then
    local BuffInfo = {}
    local TempElementId = UE.FRGElementId()
    TempElementId.TypeA = BuffId.TypeA
    TempElementId.TypeB = BuffId.TypeB
    BuffInfo.ID = TempElementId
    BuffInfo.IsElement = true
    BuffInfo.Duration = Params.RemainTime
    local GS = UE.UGameplayStatics.GetGameState(self)
    BuffInfo.StartTime = GS:GetServerWorldTimeSeconds()
    if not table.Contain(self.AllBuffIds, BuffInfo.ID) then
      table.insert(self.AllBuffIds, BuffInfo.ID)
      self.AllBuffInfos[BuffInfo.ID] = BuffInfo
    else
      for SingleElementId, SingleBuffInfo in pairs(self.AllBuffInfos) do
        if SingleElementId == BuffInfo.ID then
          SingleBuffInfo.Duration = Params.RemainTime
          SingleBuffInfo.StartTime = GS:GetServerWorldTimeSeconds()
          break
        end
      end
    end
  else
    for SingleElementId, SingleBuffInfo in pairs(self.AllBuffInfos) do
      if SingleElementId == BuffId then
        self.AllBuffInfos[SingleElementId] = nil
        break
      end
    end
    table.RemoveItem(self.AllBuffIds, BuffId)
  end
  self:RefreshBuffList()
  self:RefreshVirusInfo()
end

function WBP_BossBarInfo_C:RefreshBuffList()
  for i, SingleWidget in iterator(self.BuffList:GetAllChildren()) do
    SingleWidget:Hide()
  end
  local CurIndex = 1
  for key, SingleBuffId in pairs(self.AllBuffIds) do
    if CurIndex > 4 then
      break
    end
    local Item = self.BuffList:GetChildAt(CurIndex - 1)
    if not Item then
      Item = LogicBuffList.ListContainer:GetOrCreateItem()
      self.BuffList:AddChild(Item)
    end
    local ItemSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
    if ItemSlot then
      Item:SetRenderTransformPivot(UE.FVector2D(0.0, 0.0))
      ItemSlot:SetSize(UE.FVector2D(self.MaxBuffIconSize, self.MaxBuffIconSize))
      local X = (CurIndex - 1) * (Item.RenderTransform.Scale.X * ItemSlot:GetSize().X + 8)
      ItemSlot:SetPosition(UE.FVector2D(X, 0))
    end
    local BuffInfo
    for SingleId, SingleInfo in pairs(self.AllBuffInfos) do
      if SingleId == SingleBuffId then
        BuffInfo = SingleInfo
        break
      end
    end
    LogicBuffList.ListContainer:ShowItem(Item, BuffInfo, 4 == CurIndex, self.Boss)
    CurIndex = CurIndex + 1
  end
  self.BuffListChildren = self.BuffList:GetAllChildren()
end

function WBP_BossBarInfo_C:UpdateShieldBarVisibility()
  if 0 == self:GetMaxShieldValue() then
    self.ShieldBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.ShieldBar:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_BossBarInfo_C:GetMaxShieldValue()
  if self.Boss then
    if self.Boss.AbilitySystemComponent then
      local bSuccessfullyFoundAttribute = false
      local Value = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(self.Boss.AbilitySystemComponent, self.MaxShieldAttribute, bSuccessfullyFoundAttribute)
      return Value
    else
      return 0
    end
  end
end

function WBP_BossBarInfo_C:CheckHealthState(NewValue, OldValue)
  if OldValue < NewValue then
    self.AddState = true
  else
    self.AddState = false
    if self.UIQuality ~= UIQuality.LOW and not self.WBP_HUDInfo_ShedBlood:IsAnimationPlaying(self.WBP_HUDInfo_ShedBlood.SHEDBloodAnim_S) then
      self.WBP_HUDInfo_ShedBlood:PlayAnimation(self.WBP_HUDInfo_ShedBlood.SHEDBloodAnim_S)
    end
    self:ReduceHealthAnim()
  end
end

function WBP_BossBarInfo_C:ResetHealthAnim()
  UpdateVisibility(self.CanvasPanelResetHealth, false)
  self.HealthDynamicMaterial:SetScalarParameterValue("\229\144\175\231\148\168\231\135\131\231\131\167", 0)
  self.CanvasPanel_Animation:SetVisibility(UE.ESlateVisibility.Hidden)
  if self.UIQuality ~= UIQuality.LOW then
    self:StopAnimation(self.Ani_Bleeding)
    self.WBP_HUDInfo_ShedBlood:StopAnimation(self.WBP_HUDInfo_ShedBlood.SHEDBloodAnim_S)
    self:StopAnimation(self.loop)
  end
end

function WBP_BossBarInfo_C:ReduceHealthAnim()
  UpdateVisibility(self.CanvasPanelResetHealth, true)
  if self.UIQuality ~= UIQuality.LOW and not self:IsAnimationPlaying(self.Ani_Bleeding) then
    self:PlayAnimation(self.Ani_Bleeding, 0, 0)
  end
  if self.HealthDynamicMaterial then
    self.HealthDynamicMaterial:SetScalarParameterValue("\229\144\175\231\148\168\231\135\131\231\131\167", 0)
    self.CanvasPanel_Animation:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_BossBarInfo_C:UpdateReduceSlotLocation(CurPercent)
  if self.StopAnim then
    return
  end
  local CanvasPanelResetHealthSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.CanvasPanelResetHealth)
  if CanvasPanelResetHealthSlot then
    local Y = self.SPX_Offset.Y
    if self.ShieldBar:GetVisibility() ~= UE.ESlateVisibility.Collapsed then
      Y = self.SPX_Offset.Y + 3.3
    end
    CanvasPanelResetHealthSlot:SetPosition(UE.FVector2D(CurPercent * self.SPX_Offset.Z + self.SPX_Offset.X, Y))
  end
end

function WBP_BossBarInfo_C:AddHealthAnim()
  if self.HealthDynamicMaterial then
    self.HealthDynamicMaterial:SetScalarParameterValue("\229\144\175\231\148\168\231\135\131\231\131\167", 1)
  end
  if self.UIQuality ~= UIQuality.LOW and not self:IsAnimationPlaying(self.loop) then
    self:PlayAnimation(self.loop)
    self.CanvasPanel_Animation:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_BossBarInfo_C:UpdateAddSlotLocation(CurPercent)
  if self.StopAnim then
    return
  end
  local CanvasPanel_AnimationSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.CanvasPanel_Animation)
  if CanvasPanel_AnimationSlot then
    CanvasPanel_AnimationSlot:SetPosition(UE.FVector2D(CurPercent * 699, 128))
  end
end

function WBP_BossBarInfo_C:InterpToTargetHealth(DeltaTime)
  if self.MultiBloodBarBaseValue == nil or 0 == self.MultiBloodBarBaseValue then
    return
  end
  if self.HealthDynamicMaterial and self.NewHealthValue then
    if nil == self.CurHealthValue then
      self.CurHealthValue = self.NewHealthValue
    end
    local CurPercent = self.HealthDynamicMaterial:K2_GetScalarParameterValue("ProgressPercent")
    if self.NewHealthValue - self.CurHealthValue > self.MultiBloodBarBaseValue then
      self.CurHealthValue = self.CurHealthValue + math.floor((self.NewHealthValue - self.CurHealthValue) / self.MultiBloodBarBaseValue) * self.MultiBloodBarBaseValue
    elseif self.CurHealthValue - self.NewHealthValue > self.MultiBloodBarBaseValue then
      self.CurHealthValue = self.CurHealthValue - math.floor((self.CurHealthValue - self.NewHealthValue) / self.MultiBloodBarBaseValue) * self.MultiBloodBarBaseValue
    end
    if math.abs(self.CurHealthValue - self.NewHealthValue) < self.DefSpeed then
      self.CurHealthValue = UE.UKismetMathLibrary.FInterpTo_Constant(self.CurHealthValue, self.NewHealthValue, DeltaTime, self.DefSpeed + self.AnimationSpeed)
    else
      self.CurHealthValue = UE.UKismetMathLibrary.FInterpTo(self.CurHealthValue, self.NewHealthValue, DeltaTime, self.AnimationSpeed)
    end
    self.NewHealthPercent = self:GetDisplayHealthPercentByValue(self.CurHealthValue)
    if math.abs(self.CurHealthValue - self.NewHealthValue) < 1 then
      self.StopAnim = true
      self:ResetHealthAnim()
    else
      self.StopAnim = false
    end
    if self.CurHealthValue >= self.NewHealthValue or UE.UKismetMathLibrary.NearlyEqual_FloatFloat(self.CurHealthValue, self.NewHealthValue, 0.1) then
      self:ReduceHealthAnim()
    else
      self:AddHealthAnim()
    end
    CurPercent = self.NewHealthPercent
    if self.AddState then
      self:UpdateAddSlotLocation(CurPercent)
    else
      self:UpdateReduceSlotLocation(CurPercent)
    end
    self.Image_Blood_1:SetClippingValue(CurPercent)
    self.Image_Blood_2:SetClippingValue(CurPercent)
    self.HealthDynamicMaterial:SetScalarParameterValue("ProgressPercent", CurPercent)
    self.HealthDynamicMaterial:SetScalarParameterValue("MaxPercent", CurPercent)
    self.URGImage_loop:SetClippingValue(CurPercent)
    self.URGImage_81:SetClippingValue(CurPercent)
  end
end

function WBP_BossBarInfo_C:UpdateVirtualBarValue(DeltaTime)
  if self.HealthDynamicMaterial == nil then
    return
  end
  local CurPercent = self.HealthDynamicMaterial:K2_GetScalarParameterValue("ProgressPercent") - 0.001
  if nil == self.VirtualBarValue then
    self.VirtualBarValue = CurPercent
  end
  if CurPercent < self.VirtualBarValue then
    self.Timer = self.Timer + DeltaTime
  end
  local InterpSpeed = self.HealthReduceBarCurve:GetFloatValue(self.Timer)
  if self.AddState then
    InterpSpeed = 0
  end
  self.VirtualBarValue = UE.UKismetMathLibrary.FInterpTo(self.VirtualBarValue, CurPercent, DeltaTime, InterpSpeed)
  if math.abs(self.VirtualBarValue - CurPercent) < 0.001 or CurPercent > self.VirtualBarValue then
    self.VirtualBarValue = CurPercent
    self.Timer = 0
  end
  self.Img_VirtualBloodBar:SetClippingValue(self.VirtualBarValue)
end

function WBP_BossBarInfo_C:StopMoveVirtualBar(IsStop)
  self.IsStopMoveVirtualBar = IsStop
  if IsStop then
    UpdateVisibility(self.CanvasPanelAni, false)
    if self.UIQuality ~= UIQuality.LOW then
      self:StopAnimation(self.loop2)
    end
  end
end

function WBP_BossBarInfo_C.BindOnElementChanged(Target, BuffId, Params, IsAdd)
  local self = Target
  local TargetActor
  if Params.Target:Cast(UE.ARGBodyPartActor) then
    TargetActor = Params.Target:GetOwner()
  else
    TargetActor = Params.Target
  end
  if TargetActor ~= self.Boss then
    return
  end
  if IsAdd then
    local BuffInfo = {}
    local TempElementId = UE.FRGElementId()
    TempElementId.TypeA = BuffId.TypeA
    TempElementId.TypeB = BuffId.TypeB
    BuffInfo.ID = TempElementId
    BuffInfo.IsElement = true
    BuffInfo.Duration = Params.RemainTime
    local GS = UE.UGameplayStatics.GetGameState(self)
    BuffInfo.StartTime = GS:GetServerWorldTimeSeconds()
    if not table.Contain(self.AllBuffIds, BuffInfo.ID) then
      table.insert(self.AllBuffIds, BuffInfo.ID)
      self.AllBuffInfos[BuffInfo.ID] = BuffInfo
    else
      for SingleElementId, SingleBuffInfo in pairs(self.AllBuffInfos) do
        if SingleElementId == BuffInfo.ID then
          SingleBuffInfo.Duration = Params.RemainTime
          SingleBuffInfo.StartTime = GS:GetServerWorldTimeSeconds()
          break
        end
      end
    end
  else
    for SingleElementId, SingleBuffInfo in pairs(self.AllBuffInfos) do
      if SingleElementId == BuffId then
        self.AllBuffInfos[SingleElementId] = nil
        break
      end
    end
    table.RemoveItem(self.AllBuffIds, BuffId)
  end
  self:RefreshBuffList()
  self:RefreshVirusInfo()
end

function WBP_BossBarInfo_C:InitBar()
  self:InitHealthBar()
  self.Img_VirtualBloodBar:SetClippingValue(self.CoreComponent:GetHealthPercent())
  self.ShieldBar:InitInfo(self.Boss)
  self.WBP_BossBar_Toughness.WBP_ProgressBar:InitInfo(self.Boss)
  self.WBP_BossBar_Toughness.WBP_ProgressBar:ForceChargingPercent()
  self:UpdateShieldBarVisibility()
  self.bTransitionAnim = false
end

function WBP_BossBarInfo_C:SetBossName(InText)
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local Difficulty = 0
  if LevelSubSystem then
    Difficulty = LevelSubSystem:GetDifficulty()
  end
  local R, RowInfo = GetRowData(DT.DT_BossBarConfig, Difficulty)
  if R then
    local SetFmt = NSLOCTEXT("WBP_BossBarInfo_C", "SetFmt", "{0}{1}")
    InText = UE.FTextFormat(SetFmt(), InText, RowInfo.AdditionalWords)
    UpdateVisibility(self.SizeBox_DifficultyIcon, UE.URGBlueprintLibrary.IsValidSoftObjectPath(RowInfo.Icon) and 1 == self.Index)
    UpdateVisibility(self.boss_icon, RowInfo.bUsingDynamicMaterials)
    UpdateVisibility(self.SizeBox_DifficultyIcon, not RowInfo.bUsingDynamicMaterials)
    SetImageBrushBySoftObjectPath(self.DifficultyIcon, RowInfo.Icon)
    self.MultiBloodBarBaseValue = RowInfo.SingleTubeBloodVolume
  end
  self.TextBlock_BossName:SetText(InText)
end

function WBP_BossBarInfo_C:InitHealthBar()
  self.HealthDynamicMaterial = self.Image_Blood:GetDynamicMaterial()
  if self.HealthDynamicMaterial then
    local Health = self.CoreComponent:GetHealth()
    local MaxHealth = self.CoreComponent:GetMaxHealth()
    self.NewHealthPercent = self:GetDisplayHealthPercent(Health, MaxHealth)
    self.OldHealthPercent = self.NewHealthPercent
    self:HealthInitState()
  end
end

function WBP_BossBarInfo_C:HealthInitState()
  if self.HealthDynamicMaterial then
    self.HealthDynamicMaterial:SetScalarParameterValue("ProgressPercent", self.NewHealthPercent)
    self.HealthDynamicMaterial:SetScalarParameterValue("MaxPercent", self.NewHealthPercent)
    self.HealthDynamicMaterial:SetScalarParameterValue("\229\144\175\231\148\168\231\135\131\231\131\167", 0)
    self.BeginAddLerp = false
  end
end

function WBP_BossBarInfo_C:BlueprintBeginPlay(Boss)
  if Boss == self.Boss and nil ~= Boss then
    return
  end
  if Boss and Boss:Cast(UE.URGAIInterface) then
    print("WBP_BossBarInfo_C", Boss:Cast(UE.URGAIInterface))
    self.Boss = Boss
  else
    local OutActors = UE.UGameplayStatics.GetAllActorsWithInterface(self, UE.URGAIInterface, nil)
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if not DTSubsystem then
      print("ERROR:DataTableSubsystem is nil")
    end
    for index, value in pairs(OutActors) do
      if value and value:IsBossAI() then
        self.Boss = value
        break
      end
    end
  end
  if self.Boss == nil then
    print("\230\178\161\230\156\137Boss")
    return
  end
  local CharacterResult, CharacterConfigRow = GetRowDataForCharacter(self.Boss:GetActorId())
  if not CharacterResult then
    return
  end
  self:SetBossName(CharacterConfigRow.Desc)
  ListenObjectMessage(nil, GMP.MSG_World_AIMSG_OnSectionBloodFinished, self, self.OnSectionBloodFinished)
  if self.Boss.CoreComponent then
    self.CoreComponent = self.Boss.CoreComponent
    self.CoreComponent:BindAttributeChanged(self.HealthAttribute, {
      self,
      self.HealthAttributeChanged
    })
    self.CoreComponent:BindAttributeChanged(self.MaxHealthAttribute, {
      self,
      self.HealthAttributeChanged
    })
    self.CoreComponent:BindAttributeChanged(self.MaxShieldAttribute, {
      self,
      self.ShieldAttributeChanged
    })
    self.CoreComponent:BindAttributeChanged(self.ToughnessAttribute, {
      self,
      self.ToughnessAttributeChanged
    })
    self.NewHealthValue = self.CoreComponent:GetHealth()
    local MaxHealth = self.CoreComponent:GetMaxHealth()
    self:CheckBarsNum(self:GetCurStageHealth(self.NewHealthValue, MaxHealth), self:GetCurStageMaxHealth(MaxHealth))
    self:HealthAttributeChanged(self.NewHealthValue, self.NewHealthValue)
    self:InitBar()
  end
  if not self.Boss then
    return
  end
  local ASCComp = self.Boss.AbilitySystemComponent
  if ASCComp then
    ASCComp.EventOnRGAbilityTagUpdated:Add(self, self.BindOnAbilityTagUpdate)
  end
  local BuffComp = self.Boss.BuffComponent
  if not BuffComp then
    return
  end
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  self.AllBuffInfos = {}
  self.AllBuffIds = {}
  for i, SingleBuffInfo in iterator(BuffComp.AllBuffInfo.AllBuffInfo) do
    local BuffData = BuffDataSubsystem:GetDataFormID(SingleBuffInfo.ID)
    if BuffData and BuffData.IsNeedShowOnHUD then
      local BuffInfo = {}
      BuffInfo.ID = SingleBuffInfo.ID
      BuffInfo.CurrentCount = SingleBuffInfo.CurrentCount
      BuffInfo.BuffData = BuffData
      BuffInfo.IsElement = false
      BuffInfo.Target = self.Boss
      self.AllBuffInfos[SingleBuffInfo.ID] = BuffInfo
      table.insert(self.AllBuffIds, SingleBuffInfo.ID)
    end
  end
  if LogicElement.AllActorElementList then
    local ElementList = LogicElement.AllActorElementList[self.OwningCharacter]
    if ElementList then
      local GS = UE.UGameplayStatics.GetGameState(self)
      for index, SingleElementInfo in ipairs(ElementList) do
        local BuffInfo = {}
        BuffInfo.ID = SingleElementInfo.ElementId
        BuffInfo.IsElement = true
        BuffInfo.Duration = SingleElementInfo.Duration
        BuffInfo.StartTime = GS:GetServerWorldTimeSeconds()
        self.AllBuffInfos[SingleElementInfo.ElementId] = BuffInfo
        table.insert(self.AllBuffIds, SingleElementInfo.ElementId)
      end
    end
  end
  self:RefreshBuffList()
  self:RefreshVirusInfo()
  BuffComp.OnBuffAdded:Add(self, WBP_BossBarInfo_C.BindOnBuffChanged)
  BuffComp.OnBuffRemove:Add(self, WBP_BossBarInfo_C.BindOnBuffRemoved)
  BuffComp.OnBuffChanged:Add(self, WBP_BossBarInfo_C.BindOnBuffChanged)
  EventSystem.AddListener(self, EventDef.Battle.ElementChanged, WBP_BossBarInfo_C.BindOnElementChanged)
  self.InAddDeltaTime = 0
  self:OnStageChange(self:GetCurStage(true))
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  if LevelSubSystem then
    UpdateVisibility(self.CanvasPanel_loop, LevelSubSystem:GetMatchGameMode() == TableEnums.ENUMGameMode.BOSSRUSH)
  end
end

function WBP_BossBarInfo_C:BindOnCharacterDeath()
  print("WBP_BossBarInfo_C:BindOnCharacterDeath")
  UpdateVisibility(self.ImageShieldBossBerserk, false)
  UpdateVisibility(self.ImageBossBerserk, false)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:SetBossBarVisibility(UE.ESlateVisibility.Collapsed, self.Boss)
  end
  self.Boss = nil
end

function WBP_BossBarInfo_C:BindOnAbilityTagUpdate(Tag, bTagExist, OwnerActor)
  if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(Tag, self.InvincibleTag) then
    if not bTagExist then
      UpdateVisibility(self.Overlay_Invincible, false)
      if self.UIQuality ~= UIQuality.LOW then
        self:PlayAnimation(self.Ani_invincible_out)
      end
      for index, value in ipairs(self.HorizontalBox_BarsNum:GetAllChildren():ToTable()) do
        value:OnInvincible(false)
      end
    elseif self.SubBar:GetVisibility() == UE.ESlateVisibility.Collapsed then
      if self.UIQuality ~= UIQuality.LOW then
        self:PlayAnimation(self.Ani_invincible_in)
      end
      for index, value in ipairs(self.HorizontalBox_BarsNum:GetAllChildren():ToTable()) do
        value:OnInvincible(true)
      end
      UpdateVisibility(self.Overlay_Invincible, true)
    end
  end
end

function WBP_BossBarInfo_C:HealthAttributeChanged(NewValue, OldValue)
  self.NewHealthValue = self.CoreComponent:GetHealth()
  local MaxHealth = self.CoreComponent:GetMaxHealth()
  self:CheckBarsNum(self:GetCurStageHealth(self.NewHealthValue, MaxHealth), self:GetCurStageMaxHealth(MaxHealth))
  self:CheckHealthState(NewValue, OldValue)
  if self.Text_Progress then
    self.Text_Progress:SetText(string.format("%.2f%%", self.NewHealthValue / MaxHealth * 100))
  end
end

function WBP_BossBarInfo_C:ShieldAttributeChanged(NewValue, OldValue)
  self:UpdateShieldBarVisibility()
end

function WBP_BossBarInfo_C:ToughnessAttributeChanged(NewValue, OldValue)
  if OldValue < NewValue then
    if self.UIQuality ~= UIQuality.LOW then
      self.WBP_BossBar_Toughness.WBP_ProgressBar:PlayAnimation(self.WBP_BossBar_Toughness.WBP_ProgressBar.AddAnim)
      self.WBP_BossBar_Toughness:PlayAnimation(self.WBP_BossBar_Toughness.Ani_damage)
    end
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RecoverToughnessTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RecoverToughnessTimer)
    end
  end
  self:UpdateToughnessAttribute(NewValue)
end

function WBP_BossBarInfo_C:UpdateToughnessAttribute(NewValue)
  if NewValue <= 0 then
    ShowWaveWindow(1165)
    if self.UIQuality ~= UIQuality.LOW then
      self.WBP_BossBar_Toughness:PlayAnimation(self.WBP_BossBar_Toughness.Ani_damage)
    end
    self:RecoverToughness()
  end
end

function WBP_BossBarInfo_C:RecoverToughness()
  self.RecoverToughnessProgress = 0
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RecoverToughnessTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RecoverToughnessTimer)
  end
  self.WBP_BossBar_Toughness.RecoverTime = UE.UAIToughnessManager.GetAIToughnessConfig(self.Boss).HitReactionTime
  self.RecoverToughnessTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.RecoverToughnessProgress = 1 / (self.WBP_BossBar_Toughness.RecoverTime / 0.05) + self.RecoverToughnessProgress
      self.WBP_BossBar_Toughness.WBP_ProgressBar.VirtualBar:SetClippingValue(self.RecoverToughnessProgress)
      self.WBP_BossBar_Toughness.WBP_ProgressBar.Img_Fill:SetClippingValue(self.RecoverToughnessProgress)
      self.WBP_BossBar_Toughness.WBP_ProgressBar.ProgressBar_Charging:SetPercent(self.RecoverToughnessProgress)
    end
  }, 0.05, true)
end

function WBP_BossBarInfo_C:GetDisplayHealthPercent(Health, MaxHealth)
  if self.MultiBloodBarBaseValue == nil or 0 == self.MultiBloodBarBaseValue then
    self.MultiBloodBarBaseValue = 5000
  end
  local CurStageHealth = self:GetCurStageHealth(Health, MaxHealth)
  local CurStageMaxHealth = self:GetCurStageMaxHealth(MaxHealth)
  if CurStageMaxHealth <= 0 or self.MultiBloodBarBaseValue <= 0 then
    return 0
  end
  local ExcessBlood = CurStageMaxHealth % self.MultiBloodBarBaseValue
  if CurStageMaxHealth < self.MultiBloodBarBaseValue then
    self.MultiBloodBarBaseValue = ExcessBlood
  elseif CurStageMaxHealth > self.MultiBloodBarBaseValue then
    local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
    local Difficulty = 0
    if LevelSubSystem then
      Difficulty = LevelSubSystem:GetDifficulty()
    end
    local R, RowInfo = GetRowData(DT.DT_BossBarConfig, Difficulty)
    if R then
      self.MultiBloodBarBaseValue = RowInfo.SingleTubeBloodVolume
    end
  end
  local DisplayQuantityRemaining = 0
  if CurStageHealth <= self.MultiBloodBarBaseValue + ExcessBlood then
    DisplayQuantityRemaining = 0
  else
    DisplayQuantityRemaining = math.floor((CurStageHealth - ExcessBlood) / self.MultiBloodBarBaseValue)
  end
  if 0 == (CurStageHealth - ExcessBlood) % self.MultiBloodBarBaseValue and CurStageHealth - ExcessBlood ~= self.MultiBloodBarBaseValue then
    DisplayQuantityRemaining = DisplayQuantityRemaining - 1
  end
  self:ChangeNextColor(DisplayQuantityRemaining)
  self.Text_Num:SetText(DisplayQuantityRemaining + 1)
  local CurRemainingValue = 0
  if 0 ~= DisplayQuantityRemaining then
    CurRemainingValue = CurStageHealth - self.MultiBloodBarBaseValue * DisplayQuantityRemaining - ExcessBlood
  else
    CurRemainingValue = CurStageHealth
  end
  if 0 ~= DisplayQuantityRemaining then
    return CurRemainingValue / self.MultiBloodBarBaseValue
  else
    return CurRemainingValue / (self.MultiBloodBarBaseValue + ExcessBlood)
  end
end

function WBP_BossBarInfo_C:GetDisplayHealthPercentByValue(NewValue)
  if IsValidObj(self.CoreComponent) then
    return self:GetDisplayHealthPercent(NewValue, self.CoreComponent:GetMaxHealth())
  end
  return 0
end

function WBP_BossBarInfo_C:CheckBarsNum(CurStageHealth, CurStageMaxHealth)
  if self.MultiBloodBarBaseValue == nil or 0 == self.MultiBloodBarBaseValue then
    self.MultiBloodBarBaseValue = 5000
  end
  local ExcessBlood = CurStageMaxHealth % self.MultiBloodBarBaseValue
  local DisplayQuantityRemaining = 0
  if CurStageHealth <= self.MultiBloodBarBaseValue + ExcessBlood then
    DisplayQuantityRemaining = 0
  else
    DisplayQuantityRemaining = math.floor((CurStageHealth - ExcessBlood) / self.MultiBloodBarBaseValue)
  end
  return DisplayQuantityRemaining
end

function WBP_BossBarInfo_C:OnBossBerserk(Boss)
  if Boss == self.Boss then
    print("OnBossBerserk")
    UpdateVisibility(self.NiagaraSystemWidget_70, true)
    UpdateVisibility(self.ImageShieldBossBerserk, self.ShieldBar:GetVisibility() ~= UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.ImageBossBerserk, self.ShieldBar:GetVisibility() ~= UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_BossBarInfo_C:SetDisplayStyle(BossNumber)
  if 1 == BossNumber then
    self.SizeBox_All:SetWidthOverride(750)
    self.SPX_Offset.Z = 745
  else
    if BossNumber >= 2 then
      self.SizeBox_All:SetWidthOverride(436)
      self.SPX_Offset.Z = 430
    else
    end
  end
  if self.ShieldBar:GetVisibility() ~= UE.ESlateVisibility.Collapsed then
    self.SPX_Offset.Y = 62
  else
    self.SPX_Offset.Y = 58
  end
end

function WBP_BossBarInfo_C:GetCurStageMaxHealth(MaxHealth)
  local Stage = self:GetCurStage()
  Stage = Stage or 1
  local MultiSectionBloodComponent = UE.URGMultiSectionBloodComponent.FindMultiSectionBloodComponent(self.Boss)
  if not MultiSectionBloodComponent then
    return 0
  end
  local MultiSectionBloodConfigs = MultiSectionBloodComponent:GetMultiSectionBloodConfigs()
  if Stage > MultiSectionBloodConfigs:Length() then
    return 0
  end
  local MultiSectionBlood = MultiSectionBloodConfigs:Get(Stage)
  if MultiSectionBlood then
    return (MultiSectionBlood.StartRatio - MultiSectionBlood.EndRatio) * MaxHealth
  end
end

function WBP_BossBarInfo_C:GetCurStageHealth(Health, MaxHealth)
  local Stage = self:GetCurStage()
  Stage = Stage or 1
  local MultiSectionBloodComponent = UE.URGMultiSectionBloodComponent.FindMultiSectionBloodComponent(self.Boss)
  if not MultiSectionBloodComponent then
    return 0
  end
  local MultiSectionBloodConfigs = MultiSectionBloodComponent:GetMultiSectionBloodConfigs()
  if Stage > MultiSectionBloodConfigs:Length() then
    return 0
  end
  local MultiSectionBlood = MultiSectionBloodConfigs:Get(Stage)
  if MultiSectionBlood then
    return Health - MultiSectionBlood.EndRatio * MaxHealth
  end
end

function WBP_BossBarInfo_C:GetCurStage(bShow)
  local MultiSectionBloodComponent = UE.URGMultiSectionBloodComponent.FindMultiSectionBloodComponent(self.Boss)
  if not MultiSectionBloodComponent then
    return 1
  end
  return MultiSectionBloodComponent:GetCurrentMultibloodIndex() + 1
end

function WBP_BossBarInfo_C:GetStageNum()
  local MultiSectionBloodComponent = UE.URGMultiSectionBloodComponent.FindMultiSectionBloodComponent(self.Boss)
  if MultiSectionBloodComponent then
    local MultiSectionBloodConfigs = MultiSectionBloodComponent:GetMultiSectionBloodConfigs()
    return MultiSectionBloodConfigs:Length()
  end
  return 1
end

function WBP_BossBarInfo_C:OnStageChange(NewValue)
  if self.ShowStage == nil then
    self.ShowStage = 1
  end
  if self.HorizontalBox_BarsNum:GetAllChildren():Num() ~= self:GetStageNum() then
    self.HorizontalBox_BarsNum:ClearChildren()
    for i = 1, self:GetStageNum() do
      local ChildWidget = GetOrCreateItem(self.HorizontalBox_BarsNum, i, self.WBP_BossBarItemClass)
      if ChildWidget then
        UpdateVisibility(ChildWidget, true)
        ChildWidget:InitItem(i, self:GetStageNum())
        self.HorizontalBox_BarsNum:AddChild(ChildWidget)
      end
    end
    HideOtherItem(self.HorizontalBox_BarsNum, self:GetStageNum() + 1, true)
  end
  print("WBP_BossBarInfo_C:OnStageChange", NewValue, self:GetStageNum(), self.ShowStage)
  if NewValue > self.ShowStage then
    for i = self.ShowStage, NewValue - 1 do
      local Widget = self.HorizontalBox_BarsNum:GetChildAt(self:GetStageNum() - i)
      if Widget then
        Widget:PlayDecreaseAnimation()
      end
    end
  else
    for i = NewValue, self.ShowStage do
      local Widget = self.HorizontalBox_BarsNum:GetChildAt(i)
      if Widget then
        Widget:PlayAddAnimation()
      end
    end
  end
  self.ShowStage = NewValue
end

function WBP_BossBarInfo_C:OnSectionBloodFinished(Boss, Index)
  if Boss ~= self.Boss then
    return
  end
  print("WBP_BossBarInfo_C:OnSectionBloodFinished", Index)
  local MultiSectionBloodComponent = UE.URGMultiSectionBloodComponent.FindMultiSectionBloodComponent(self.Boss)
  if MultiSectionBloodComponent then
    self:OnStageChange(Index + 2)
  end
end

function WBP_BossBarInfo_C:ChangeNextColor(DisplayQuantityRemaining)
  if self.CurBarColor == nil or 0 == self.CurBarColor then
    self.BarColorIndex = 1
  end
  if DisplayQuantityRemaining == self.CurBarColor then
    return
  end
  self.CurBarColor = DisplayQuantityRemaining
  local Index = 0
  if self.BgColorConfig:Num() > 0 then
    Index = self.BarColorIndex % self.BgColorConfig:Num()
  end
  if 0 == Index then
    Index = self.BgColorConfig:Num()
  end
  local LastIndex = Index + 1
  if LastIndex > self.BgColorConfig:Num() then
    LastIndex = LastIndex - self.BgColorConfig:Num()
  end
  if self.HealthDynamicMaterial then
    self.HealthDynamicMaterial:SetVectorParameterValue("\232\161\128\230\157\161\233\162\156\232\137\178", self.BgColorConfig:Get(Index))
    if 0 == DisplayQuantityRemaining then
      self.Image_Blood_BG:SetColorAndOpacity(self.LastBgColorConfig)
    else
      self.Image_Blood_BG:SetColorAndOpacity(self.BgColorConfig:Get(LastIndex))
    end
  end
  self.BarColorIndex = self.BarColorIndex + 1
end

function WBP_BossBarInfo_C:RefreshVirusInfo()
  if not self.AllBuffInfos then
    return
  end
  local bVirus = false
  for buffId, _ in pairs(self.AllBuffInfos) do
    if 305301 == buffId then
      bVirus = true
      break
    end
  end
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local bBossRush = false
  if LevelSubSystem then
    bBossRush = LevelSubSystem:GetMatchGameMode() == TableEnums.ENUMGameMode.BOSSRUSH
  end
  UpdateVisibility(self.CanvasPanel_skill, bVirus and not bBossRush)
  UpdateVisibility(self.CanvasPanel_Virus, bVirus and not bBossRush)
end

return WBP_BossBarInfo_C
