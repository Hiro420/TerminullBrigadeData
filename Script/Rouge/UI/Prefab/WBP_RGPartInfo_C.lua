local WBP_RGPartInfo_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")
function WBP_RGPartInfo_C:Construct()
  if not self.ListContainer then
    self.ListContainer = ListContainer.New(self.GridBarItemTemplate:StaticClass())
    table.insert(self.ListContainer.AllWidgets, self.GridBarItemTemplate)
  end
  self:HidePanel()
  ListenObjectMessage(nil, "BodyPart.OnShowWeaknessInfo", self, self.BindOnShowWeaknessInfo)
  ListenObjectMessage(nil, "BodyPart.NotifyRestore", self, self.BindOnListenPartRestore)
  if self.OwningCharacter then
    if self.OwningCharacter.OnBodyPartComponentReady then
      self.OwningCharacter.OnBodyPartComponentReady:Add(self, WBP_RGPartInfo_C.BindOnBodyPartComponentReady)
    end
    local BodyPartComp = self.OwningCharacter:GetComponentByClass(UE.URGBodyPartComponent:StaticClass())
    if not BodyPartComp then
      return
    end
    local IsPartDestruct = BodyPartComp:IsPartBroken(self.PartIndex)
    self.IsBroken = IsPartDestruct
    ListenObjectMessage(self.OwningCharacter, GMP.MSG_Pawn_OnDeath, self, self.BindOnPawnDeath)
  end
end
function WBP_RGPartInfo_C:BindOnShowWeaknessInfo()
  print("BindOnShowWeaknessInfo")
  local CanShow = self:CanShowPanel()
  CanShow = (not (self.OwningCharacter and self.OwningCharacter.CanShowInfoPanel) or self.OwningCharacter:CanShowInfoPanel()) and CanShow
  if CanShow then
    self:ShowPanel()
  end
end
function WBP_RGPartInfo_C:BindOnListenPartRestore(PartIndex)
  print("BindOnListenPartRestore", PartIndex, self.PartIndex)
  if self.PartIndex == PartIndex then
    self.IsBroken = false
  end
end
function WBP_RGPartInfo_C:BindOnPawnDeath()
  self:HidePanel()
end
function WBP_RGPartInfo_C:InitInfo(ElementId)
  print("WBP_RGPartInfo_C:InitInfo")
  self:InitBarStyle()
end
function WBP_RGPartInfo_C:InitBarStyle()
  local Result, CharacterRow = GetRowDataForCharacter(self.OwningCharacter:GetTypeID())
  if not Result then
    print("WBP_RGPartInfo_C:InitInfo, not found Character row info, CharacterId", self.OwningCharacter:GetTypeID())
    return
  end
  local BodyPartDetail = self:GetBodyPartDetailByIndex(self.PartIndex)
  if not BodyPartDetail then
    print("WBP_RGPartInfo_C:InitInfo, not found BodyPartDetail for index", self.PartIndex)
    return
  end
  local PartDetail = BodyPartDetail.DamagePartDetail
  local BackObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(PartDetail.PartBloodBarDetail.BottomImg)
  local FillObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(PartDetail.PartBloodBarDetail.FillImg)
  if BackObj and FillObj then
    local Margin = UE.FMargin()
    Margin.Bottom = 0.5
    Margin.Left = 0.5
    Margin.Right = 0.5
    Margin.Top = 0.5
    local BackBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(BackObj, 0, 0)
    BackBrush.DrawAs = UE.ESlateBrushDrawType.Box
    BackBrush.Margin = Margin
    local FillBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(FillObj, 0, 0)
    FillBrush.DrawAs = UE.ESlateBrushDrawType.Box
    FillBrush.Margin = Margin
  end
end
function WBP_RGPartInfo_C:UpdateGridBarList()
  local Result, CharacterRow = GetRowDataForCharacter(self.OwningCharacter:GetTypeID())
  if not Result then
    return
  end
  self.ListContainer:ClearAllUseWidgets()
  local ListSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.GridBarList)
  local BarLength = ListSlot:GetSize().X
  self.BarHeight = ListSlot:GetSize().Y
  local SingleBarGrid = CharacterRow.BodyPartInfo.PartGridWidgetValue
  if 0 == SingleBarGrid then
    SingleBarGrid = self.MaxHealth
  end
  local IntegerNum = math.floor(self.MaxHealth / SingleBarGrid)
  local RemainValue = self.MaxHealth % SingleBarGrid
  local FinalGridNum = IntegerNum
  local RemainPercent = RemainValue / SingleBarGrid
  if 0 ~= RemainValue then
    FinalGridNum = FinalGridNum + RemainPercent
  end
  if FinalGridNum > self.MaxBarNum then
    FinalGridNum = self.MaxBarNum
    SingleBarGrid = self.MaxHealth / FinalGridNum
  end
  local TargetSizeX = (BarLength - math.ceil(FinalGridNum - 1) * self.IntervalPixel) / FinalGridNum
  local PosX = 0
  local MinNum = 0
  local MaxNum = 0
  local ViewportScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
  for i = 1, math.floor(FinalGridNum) do
    PosX = (i - 1) * (TargetSizeX + self.IntervalPixel / ViewportScale)
    MinNum = (i - 1) * SingleBarGrid
    MaxNum = MinNum + SingleBarGrid
    self:InitBarItemInfo(PosX, TargetSizeX, MinNum, MaxNum)
  end
  if 0 ~= FinalGridNum - math.floor(FinalGridNum) then
    PosX = math.ceil(FinalGridNum - 1) * (TargetSizeX + self.IntervalPixel / ViewportScale)
    MinNum = self.MaxHealth - RemainValue
    MaxNum = self.MaxHealth
    self:InitBarItemInfo(PosX, TargetSizeX * RemainPercent, MinNum, MaxNum)
  end
end
function WBP_RGPartInfo_C:InitBarItemInfo(PosX, SizeX, MinValue, MaxValue)
  local Item = self.ListContainer:GetOrCreateItem()
  if not self.GridBarList:HasChild(Item) then
    self.GridBarList:AddChildToCanvas(Item)
  end
  self.ListContainer:ShowItem(Item)
  local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
  Slot:SetSize(UE.FVector2D(SizeX, self.BarHeight))
  Slot:SetPosition(UE.FVector2D(PosX, 0))
  Item:InitInfo(MinValue, MaxValue, nil, SizeX)
  Item:SetIsShowVirtualWhite(self.GridBarItemTemplate.IsShowVirtualWhite)
  Item:SetReduceAnimName(self.ReduceAnimName)
  local Result, CharacterRow = GetRowDataForCharacter(self.OwningCharacter:GetTypeID())
  if Result then
    local BodyPartDetail = self:GetBodyPartDetailByIndex(self.PartIndex)
    if not BodyPartDetail then
      print("WBP_RGPartInfo_C:InitBarItemInfo, not found BodyPartDetail for index", self.PartIndex)
      return
    end
    local PartDetail = BodyPartDetail.DamagePartDetail
    local BackObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(PartDetail.PartBloodBarDetail.BottomImg)
    local FillObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(PartDetail.PartBloodBarDetail.FillImg)
    Item:UpdateBarStyle(FillObj, BackObj, nil)
  end
  Item:UpdateFillImg(self:GetPartValue(), -1)
  Item:UpdateVirtualImg(self:GetPartValue())
end
function WBP_RGPartInfo_C:GetPartValue()
  if not self.OwningCharacter.TryGetPartAbilitySystemComponent then
    print("WBP_RGPartInfo_C:GetPartValue Owner not has Part Ability System Component!")
    return 0
  end
  local PartASC = self.OwningCharacter:TryGetPartAbilitySystemComponent(self.PartIndex)
  if not PartASC then
    return 0
  end
  return PartASC:GetPartValue()
end
function WBP_RGPartInfo_C:BindOnBodyPartComponentReady()
  print("OnBodyPartComponentReady")
end
function WBP_RGPartInfo_C:SetPartBroken()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HideTimer)
  end
  LogicBodyPart.HideWidget(self)
  self.IsBroken = true
end
function WBP_RGPartInfo_C:SetHealthPercentage()
  if self.MaxHealth <= 0 then
    print("\233\131\168\228\189\141\232\161\128\230\157\161\230\156\128\229\164\167\231\148\159\229\145\189\229\128\188\228\184\1860")
    LogicBodyPart.HideWidget(self)
    return
  end
  local AllUseWidgets = self.ListContainer:GetAllUseWidgetsList()
  for index, SingleWidget in ipairs(AllUseWidgets) do
    SingleWidget:UpdateFillImg(self:GetPartValue(), self.OldHealthValue)
    SingleWidget:UpdateVirtualImg(self:GetPartValue())
  end
  if self.OldHealthValue > self:GetPartValue() then
    self:UpdateVirtualWhiteValue(self.OldHealthValue, self:GetPartValue())
  end
  self.OldHealthValue = self:GetPartValue()
end
function WBP_RGPartInfo_C:UpdateVirtualWhiteValue(OldValue, NewValue)
  local DifferenceValue = NewValue - OldValue
  if DifferenceValue < 0 then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.VirtualWhiteTimer) then
      self.VirtualWhiteTargetValue = NewValue
      return
    end
    self.VirtualWhiteOldValue = OldValue
    self.VirtualWhiteTargetValue = NewValue
    local AllUseWidgets = self.ListContainer:GetAllUseWidgetsList()
    for index, SingleWidget in ipairs(AllUseWidgets) do
      SingleWidget:ShowOrHideVirtualWhiteBar(true)
    end
    self.VirtualWhiteTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self:StartPlayVirtualWhiteAnim()
      end
    }, self.VirtualWhiteDuration, false)
  else
    self:EndVirtualWhiteAnim()
  end
end
function WBP_RGPartInfo_C:StartPlayVirtualWhiteAnim()
  self.VirtualWhiteAnimTime = 0
  self.IsPlayVirtualWhiteAnim = true
end
function WBP_RGPartInfo_C:EndVirtualWhiteAnim()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.VirtualWhiteTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.VirtualWhiteTimer)
  end
  self.IsPlayVirtualWhiteAnim = false
  local AllUseWidgets = self.ListContainer:GetAllUseWidgetsList()
  for index, SingleWidget in ipairs(AllUseWidgets) do
    SingleWidget:ShowOrHideVirtualWhiteBar(false)
  end
end
function WBP_RGPartInfo_C:ShowPanel()
  if not self.ListContainer then
    self.ListContainer = ListContainer.New(self.GridBarItemTemplate:StaticClass())
    table.insert(self.ListContainer.AllWidgets, self.GridBarItemTemplate)
  end
  local BodyPartComp = self.OwningCharacter:GetComponentByClass(UE.URGBodyPartComponent:StaticClass())
  if BodyPartComp then
    local Result, PartHealth = BodyPartComp:GetPartHealthInfo(self.PartIndex, nil)
    if Result then
      self.MaxHealth = PartHealth.MaxHealth
      if not self:IsVisible() then
        self:UpdateGridBarList()
      end
    end
  end
  self:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HideTimer)
  end
  self.HideTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      LogicBodyPart.HideWidget(self)
    end
  }, self.HideTime, false)
end
function WBP_RGPartInfo_C:HidePanel()
  self.OldHealthValue = -1
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HideTimer)
  end
end
function WBP_RGPartInfo_C:CanShowPanel()
  if not self.OwningCharacter or not self.OwningCharacter:IsValid() then
    return false
  end
  if not LogicBodyPart.GetCanShowBodyPartWidget() then
    return false
  end
  local IsPartEnabled = true
  local BodyPartComp = self.OwningCharacter:GetComponentByClass(UE.URGBodyPartComponent:StaticClass())
  if BodyPartComp then
    IsPartEnabled = BodyPartComp:IsPartEnabled(self.PartIndex)
  end
  return IsPartEnabled and not self.IsBroken
end
function WBP_RGPartInfo_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.HideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.HideTimer)
  end
  UnListenObjectMessage("BodyPart.OnShowWeaknessInfo")
  UnListenObjectMessage("BodyPart.NotifyRestore")
  UnListenObjectMessage(GMP.MSG_Pawn_OnDeath, self)
  if self.OwningCharacter and self.OwningCharacter.OnBodyPartComponentReady then
    self.OwningCharacter.OnBodyPartComponentReady:Remove(self, WBP_RGPartInfo_C.BindOnBodyPartComponentReady)
  end
end
function WBP_RGPartInfo_C:LuaTick(InDeltaTime)
  if self.IsBroken then
    return
  end
  if not self.OwningCharacter then
    return
  end
  local BodyPartComp = self.OwningCharacter:GetComponentByClass(UE.URGBodyPartComponent:StaticClass())
  if not BodyPartComp then
    return
  end
  local IsPartDestruct = BodyPartComp:IsPartBroken(self.PartIndex)
  if IsPartDestruct then
    self:SetPartBroken()
  else
    local Result, PartHealth = BodyPartComp:GetPartHealthInfo(self.PartIndex, nil)
    if not Result then
      return
    end
    self:SetHealthPercentage()
  end
  if self.IsPlayVirtualWhiteAnim then
    self:UpdateVirtualWhiteAnim(InDeltaTime)
  end
end
function WBP_RGPartInfo_C:UpdateVirtualWhiteAnim(InDeltaTime)
  self.VirtualWhiteAnimTime = self.VirtualWhiteAnimTime + InDeltaTime
  local MinTime, MaxTime = self.VirtualWhiteAnimCurve:GetTimeRange()
  if MaxTime < self.VirtualWhiteAnimTime then
    self:EndVirtualWhiteAnim()
    return
  end
  local PercentValue = self.VirtualWhiteAnimCurve:GetFloatValue(self.VirtualWhiteAnimTime)
  local TargetOldVirtualWhiteValue = self.VirtualWhiteOldValue - PercentValue * (self.VirtualWhiteOldValue - self.VirtualWhiteTargetValue)
  local AllUseWidgets = self.ListContainer:GetAllUseWidgetsList()
  for index, SingleWidget in ipairs(AllUseWidgets) do
    SingleWidget:UpdateVirtualWhiteBarValue(TargetOldVirtualWhiteValue)
  end
end
function WBP_RGPartInfo_C:GetBodyPartDetailByIndex(PartIndex)
  local Result, CharacterRow = GetRowDataForCharacter(self.OwningCharacter:GetTypeID())
  if not Result then
    print("WBP_RGPartInfo_C:GetBodyPartDetailByIndex, not found Character row info, CharacterId", self.OwningCharacter:GetTypeID())
    return
  end
  local BodyPartDetail
  if CharacterRow.BodyPartInfo.BodyPartDetail:IsValidIndex(PartIndex + 1) then
    BodyPartDetail = CharacterRow.BodyPartInfo.BodyPartDetail:Get(PartIndex + 1)
  else
    local AIBodyPartComp = self.OwningCharacter:GetComponentByClass(UE.URGAIBodyPartComponent:StaticClass())
    if not AIBodyPartComp then
      print("WBP_RGPartInfo_C:GetBodyPartDetailByIndex, not found AIBodyPartComp")
      return
    end
    local Result, PartDetail = AIBodyPartComp:GetBodyPartDetailByIndex(PartIndex)
    if not Result then
      print("WBP_RGPartInfo_C:GetBodyPartDetailByIndex, not found BodyPartDetail for index", PartIndex)
      return
    end
    BodyPartDetail = PartDetail
  end
  return BodyPartDetail
end
return WBP_RGPartInfo_C
