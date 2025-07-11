local WBP_LifeBar_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")
local MaxBuffShowNum = 4
function WBP_LifeBar_C:Construct()
  self.Overridden.Construct(self)
  if not self.OwningActor then
    return
  end
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/Buff/WBP_BuffIcon.WBP_BuffIcon_C")
  self.ListContainer = ListContainer.New(WidgetClass, MaxBuffShowNum)
  self:UpdateShieldBarVisibility()
  local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
  if not CameraManager then
    return
  end
  self.CameraToCharacterDistance = 0
  local CurASC
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    local CameraLocation = CameraManager:GetCameraLocation()
    local CharacterLocation = Character:K2_GetActorLocation()
    self.CameraToCharacterDistance = UE.UKismetMathLibrary.Vector_Distance(CameraLocation, CharacterLocation)
    CurASC = Character:GetComponentByClass(UE.URGAbilitySystemComponent:StaticClass())
  end
  local CoreComp = self.OwningActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreComp then
    CoreComp:BindAttributeChanged(self.MaxShieldAttribute, {
      self,
      self.BindOnMaxShieldAttributeChanged
    })
  end
  if self.OwningActor.RGAffIdChanged then
    self.OwningActor.RGAffIdChanged:Add(self, self.OnBindUpdateName)
  end
  self:OnBindUpdateName()
  if self.OwningActor.GetShowLevel then
    self.Txt_Level:SetText(tostring(self.OwningActor:GetShowLevel()))
  end
  self:SetBottomBrush()
  local BuffComp = self.OwningActor:GetComponentByClass(UE.UBuffComponent:StaticClass())
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
    if BuffData and BuffData.IsNeedShowOnHUD and (BuffData.IconVisibleRule ~= UE.EBuffNiagaraVisibleRule.OnlyInitiatorSee or SingleBuffInfo.InitiatorASC == CurASC) then
      local BuffInfo = {}
      BuffInfo.ID = SingleBuffInfo.ID
      BuffInfo.CurrentCount = SingleBuffInfo.CurrentCount
      BuffInfo.BuffData = BuffData
      BuffInfo.IsElement = false
      BuffInfo.Target = self.OwningActor
      self.AllBuffInfos[SingleBuffInfo.ID] = BuffInfo
      table.insert(self.AllBuffIds, SingleBuffInfo.ID)
    end
  end
  if LogicElement.AllActorElementList then
    local ElementList = LogicElement.AllActorElementList[self.OwningActor]
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
  BuffComp.OnBuffAdded:Add(self, WBP_LifeBar_C.BindOnBuffChanged)
  BuffComp.OnBuffRemove:Add(self, WBP_LifeBar_C.BindOnBuffRemoved)
  BuffComp.OnBuffChanged:Add(self, WBP_LifeBar_C.BindOnBuffChanged)
  EventSystem.AddListener(self, EventDef.Battle.ElementChanged, WBP_LifeBar_C.BindOnElementChanged)
end
function WBP_LifeBar_C:OnBindUpdateName()
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local RGDataTableSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if RGDataTableSubsystem then
    local Result, Row = GetRowDataForCharacter(self.OwningActor:GetActorId())
    if Result then
      local Desc = Row.Desc
      if self.OwningActor.GetAffId then
        local BuffData = BuffDataSubsystem:GetDataFormID(self.OwningActor:GetAffId())
        if BuffData.BuffName ~= "" then
          Desc = string.format("%s\226\128\162%s", BuffData.BuffName, Row.Desc)
        end
      end
      self.Txt_Name_Elite:SetText(Desc)
      self.Txt_Name_Normal:SetText(Desc)
    end
  end
end
function WBP_LifeBar_C:ShowPanel()
  self.MainInfoPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end
function WBP_LifeBar_C:HidePanel()
  self.MainInfoPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_LifeBar_C:UpdateShieldBarVisibility()
  if 0 == self:GetMaxShieldValue() then
    self.ShieldBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.ShieldBar:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_LifeBar_C:BindOnMaxShieldAttributeChanged(NewValue, OldValue)
  self:UpdateShieldBarVisibility()
end
function WBP_LifeBar_C:SetBottomBrush()
  if not self.OwningActor then
    return
  end
  local Tag = self.OwningActor:GetGradeTag()
  if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(Tag, self.NormalAITag) then
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_Elite:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.Txt_Name_Elite, false)
    UpdateVisibility(self.Txt_Name_Normal, true)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.NormalLevelBottom)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, math.ceil(self.LevelBottomSize.X), math.ceil(self.LevelBottomSize.Y))
      if Brush then
        self.Img_LevelBottom:SetBrush(Brush)
      end
    end
    self.Txt_Level:SetColorAndOpacity(self.NormalLevelColor)
    return
  end
  if UE.UBlueprintGameplayTagLibrary.EqualEqual_GameplayTag(Tag, self.EliteAITag) then
    self.Img_Bottom:SetBrush(self.EliteBottom)
    self.Img_Bottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Elite:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.Txt_Name_Elite, true)
    UpdateVisibility(self.Txt_Name_Normal, false)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.EliteLevelBottom)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, math.ceil(self.LevelBottomSize.X), math.ceil(self.LevelBottomSize.Y))
      if Brush then
        self.Img_LevelBottom:SetBrush(Brush)
      end
    end
    self.Txt_Level:SetColorAndOpacity(self.EliteLevelColor)
    return
  end
  self.Img_Bottom:SetBrush(self.EliteBottom)
  self.Img_Elite:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_LifeBar_C:InitWidgetInfo(OwningActor)
  self.OwningActor = OwningActor
  self.HealthBar:InitInfo(self.OwningActor)
  self.ShieldBar:InitInfo(self.OwningActor)
end
function WBP_LifeBar_C:CalculateBuffIconSizeByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinBuffIconSize - self.MaxBuffIconSize) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxBuffIconSize
end
function WBP_LifeBar_C:CalculateBarLengthByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinLength - self.MaxLength) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxLength
end
function WBP_LifeBar_C:CalculateBarIntervalByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  local MinInterval, MaxInterval = 4, 8
  return (MinInterval - MaxInterval) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + MaxInterval
end
function WBP_LifeBar_C:CalculateHealthHeightByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinBarHeight - self.MaxBarHeight) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxBarHeight
end
function WBP_LifeBar_C:CalculateShieldHealthHeightByDistance(Distance)
  local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
  return (self.MinShieldBarHeight - self.MaxShieldBarHeight) / (self.MaxDistance - self.MinDistance) * (TargetDistance - self.MinDistance) + self.MaxShieldBarHeight
end
function WBP_LifeBar_C:BindOnBuffChanged(AddedBuff)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CurASC = Character:GetComponentByClass(UE.URGAbilitySystemComponent:StaticClass())
  local BuffData = BuffDataSubsystem:GetDataFormID(AddedBuff.ID)
  if BuffData and BuffData.IsNeedShowOnHUD and (BuffData.IconVisibleRule ~= UE.EBuffNiagaraVisibleRule.OnlyInitiatorSee or AddedBuff.InitiatorASC == CurASC) then
    local BuffInfo = {}
    BuffInfo.ID = AddedBuff.ID
    BuffInfo.CurrentCount = AddedBuff.CurrentCount
    BuffInfo.BuffData = BuffData
    BuffInfo.IsElement = false
    BuffInfo.Target = self.OwningActor
    if not self.AllBuffInfos[AddedBuff.ID] then
      table.insert(self.AllBuffIds, AddedBuff.ID)
    end
    self.AllBuffInfos[AddedBuff.ID] = BuffInfo
    self:RefreshBuffList()
  end
end
function WBP_LifeBar_C:BindOnBuffRemoved(RemovedBuff)
  table.RemoveItem(self.AllBuffIds, RemovedBuff.ID)
  self.AllBuffInfos[RemovedBuff.ID] = nil
  self:RefreshBuffList()
end
function WBP_LifeBar_C.BindOnElementChanged(Target, BuffId, Params, IsAdd)
  local self = Target
  local TargetActor
  if Params.Target:Cast(UE.ARGBodyPartActor) then
    TargetActor = Params.Target:GetOwner()
  else
    TargetActor = Params.Target
  end
  if TargetActor ~= self.OwningActor then
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
end
function WBP_LifeBar_C:RefreshBuffList()
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
      Item = self.ListContainer:GetOrCreateItem()
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
    self.ListContainer:ShowItem(Item, BuffInfo, 4 == CurIndex, self.OwningActor)
    CurIndex = CurIndex + 1
  end
  self.BuffListChildren = self.BuffList:GetAllChildren()
end
function WBP_LifeBar_C:UpdateBarLength(Distance)
  local HealthSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.HealthBar)
  local ShieldSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ShieldBar)
  local NameSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.VerticalBox_Name)
  local BuffSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.BuffList)
  local BottomSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.BottomPanel)
  local MarginShield = UE.FMargin()
  MarginShield.Left = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2 + 5.5
  MarginShield.Right = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2 - 5.5
  MarginShield.Bottom = self:CalculateShieldHealthHeightByDistance(Distance)
  local Margin = UE.FMargin()
  Margin.Left = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2
  Margin.Right = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2
  local HealthSize = self:CalculateHealthHeightByDistance(Distance)
  Margin.Bottom = HealthSize
  if self.ShieldBar:IsVisible() then
    Margin.Top = ShieldSlot:GetOffsets().Top + MarginShield.Bottom
  else
    Margin.Top = ShieldSlot:GetOffsets().Top
  end
  HealthSlot:SetOffsets(Margin)
  MarginShield.Top = ShieldSlot:GetOffsets().Top
  ShieldSlot:SetOffsets(MarginShield)
  Margin.Top = NameSlot:GetOffsets().Top
  Margin.Bottom = NameSlot:GetOffsets().Bottom
  local BuffInterval = self:CalculateBarIntervalByDistance(Distance)
  local CurDisBuffIconSize = self:CalculateBuffIconSizeByDistance(Distance)
  local BuffListSizeX = self.BuffList:GetChildrenCount() * CurDisBuffIconSize + (self.BuffList:GetChildrenCount() - 1) * BuffInterval
  Margin.Left = (self.MainSizeBox.WidthOverride - BuffListSizeX) / 2
  Margin.Right = (self.MainSizeBox.WidthOverride - BuffListSizeX) / 2
  Margin.Bottom = BuffSlot:GetOffsets().Bottom
  Margin.Top = HealthSlot:GetOffsets().Top + HealthSize + 2
  BuffSlot:SetOffsets(Margin)
  Margin.Left = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2 - 5
  Margin.Top = BottomSlot:GetOffsets().Top
  Margin.Right = (self.MainSizeBox.WidthOverride - self:CalculateBarLengthByDistance(Distance)) / 2 - 5
  Margin.Bottom = BottomSlot:GetOffsets().Bottom
  BottomSlot:SetOffsets(Margin)
end
function WBP_LifeBar_C:UpdateFonSize(Distance)
  local HalfDistance = (self.MaxDistance - self.MinDistance) / 2
  local FontSize = 0
  if Distance > HalfDistance then
    FontSize = self.MinFont
  else
    FontSize = self.MaxFont
  end
  self:SetFontSize(FontSize)
end
function WBP_LifeBar_C:UpdateBuffIcon(Distance)
  if not self.BuffListChildren then
    return
  end
  local BuffInterval = self:CalculateBarIntervalByDistance(Distance)
  local Offsets = UE.FMargin()
  Offsets.Right = self:CalculateBuffIconSizeByDistance(Distance)
  Offsets.Top = 0
  for i, SingleIconItem in iterator(self.BuffListChildren) do
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(SingleIconItem)
    if Slot then
      Offsets.Left = (i - 1) * (SingleIconItem.RenderTransform.Scale.X * Slot:GetSize().X + BuffInterval)
      Slot:SetPosition(UE.FVector2D(Offsets.Left, Offsets.Top))
      SingleIconItem:UpdateBuffIconSize(Offsets.Right)
    end
  end
end
function WBP_LifeBar_C:ClearAllBuff()
  for i, SingleWidget in iterator(self.BuffList:GetAllChildren()) do
    SingleWidget:Hide()
  end
  self.ShieldBar:ResetBarValue()
  self.HealthBar:ResetBarValue()
end
function WBP_LifeBar_C:Destruct()
  self.Overridden.Destruct(self)
  if not self.OwningActor then
    return
  end
  local CoreComp = self.OwningActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreComp then
    CoreComp:UnBindAttributeChanged(self.MaxShieldAttribute, {
      self,
      self.BindOnMaxShieldAttributeChanged
    })
  end
  if self.OwningActor.RGAffIdChanged then
    self.OwningActor.RGAffIdChanged:Remove(self, self.OnBindUpdateName)
  end
  local BuffComp = self.OwningActor:GetComponentByClass(UE.UBuffComponent:StaticClass())
  if not BuffComp then
    return
  end
  BuffComp.OnBuffAdded:Remove(self, WBP_LifeBar_C.BindOnBuffChanged)
  BuffComp.OnBuffRemove:Remove(self, WBP_LifeBar_C.BindOnBuffRemoved)
  BuffComp.OnBuffChanged:Remove(self, WBP_LifeBar_C.BindOnBuffChanged)
  EventSystem.RemoveListener(EventDef.Battle.ElementChanged, WBP_LifeBar_C.BindOnElementChanged, self)
  for i, SingleWidget in iterator(self.BuffList:GetAllChildren()) do
    self.ListContainer:HideItem(SingleWidget)
  end
  if self.ListContainer then
    self.ListContainer:ClearAllWidgets()
    self.ListContainer = nil
  end
  print("AIInfo Destruct")
end
function WBP_LifeBar_C:LuaTick(InDeltaTime)
  local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
  if CameraManager and self.OwningActor then
    local CameraLocation = CameraManager:GetCameraLocation()
    local OwnerLocation = self.OwningActor:K2_GetActorLocation()
    local Distance = UE.UKismetMathLibrary.Vector_Distance(CameraLocation, OwnerLocation) - self.CameraToCharacterDistance
    self:UpdateBarLength(Distance)
    self:UpdateBuffIcon(Distance)
    self:UpdateFonSize(Distance)
  end
end
return WBP_LifeBar_C
