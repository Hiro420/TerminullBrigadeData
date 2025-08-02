local WBP_GridBarList_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")

function WBP_GridBarList_C:Construct()
  self.OldValue = 0
end

function WBP_GridBarList_C:InitInfo(Character)
  local Quality = BattleUIScalability:GetGridBarScalability()
  self.UIQuality = Quality
  if Quality == UIQuality.LOW then
    self.MaxBarValue = math.floor(self.MaxBarValue * 0.25)
    self.SingleBarGrid = self.SingleBarGrid * 4
  end
  if self.IsInit then
    self:RefreshWidgetInfo(Character)
    return
  end
  self.OwningCharacter = Character
  self.IsMoveVirtualBar = false
  self.IsInit = true
  self.ListContainer = ListContainer.New(self.GridBarItemTemplate:StaticClass())
  table.insert(self.ListContainer.AllWidgets, self.GridBarItemTemplate)
  if self.OwningCharacter and self.OwningCharacter.CoreComponent then
    self.OwningCharacter.CoreComponent:BindAttributeChanged(self.Attribute, {
      self,
      self.BindOnAttributeChanged
    })
    self.OwningCharacter.CoreComponent:BindAttributeChanged(self.MaxAttribute, {
      self,
      self.BindOnMaxAttributeChanged
    })
    self.OwningCharacter.CoreComponent:BindAttributeChanged(self.SpecialAttribute, {
      self,
      self.BindOnSpecialAttributeChanged
    })
    self.OwningCharacter.CoreComponent:BindAttributeChanged(self.SpecialMaxAttribute, {
      self,
      self.BindOnSpecialMaxAttributeChanged
    })
    self.IsUpdateAttributeCache = self.OwningCharacter.CoreComponent:HasAttributeCacheModify(self.Attribute)
  end
  ListenObjectMessage(nil, GMP.MSG_World_OnAttributeModifyCacheAdded, self, self.OnAttributeModifyCacheAdded)
  ListenObjectMessage(nil, GMP.MSG_World_OnAttributeModifyCacheRemove, self, self.OnAttributeModifyCacheRemove)
end

function WBP_GridBarList_C:RefreshWidgetInfo(Character)
  if self.OwningCharacter ~= Character and Character and Character.CoreComponent then
    Character.CoreComponent:BindAttributeChanged(self.Attribute, {
      self,
      self.BindOnAttributeChanged
    })
    Character.CoreComponent:BindAttributeChanged(self.MaxAttribute, {
      self,
      self.BindOnMaxAttributeChanged
    })
    Character.CoreComponent:BindAttributeChanged(self.SpecialAttribute, {
      self,
      self.BindOnSpecialAttributeChanged
    })
  end
  self.OwningCharacter = Character
  self.IsMoveVirtualBar = false
end

function WBP_GridBarList_C:OnAttributeModifyCacheAdded(AttributeCacheModifyData)
  if UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.Attribute) or UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.MaxAttribute) then
    self.AttributeModifyCacheList:Add(AttributeCacheModifyData.ModifyID, AttributeCacheModifyData)
    self.AttributeModifyCacheStartTime:Add(AttributeCacheModifyData.ModifyID, GetCurrentUTCTimestamp())
    self.IsUpdateAttributeCache = true
  end
end

function WBP_GridBarList_C:OnAttributeModifyCacheRemove(AttributeCacheModifyData)
  if UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.Attribute) or UE.UAbilitySystemBlueprintLibrary.EqualEqual_GameplayAttributeGameplayAttribute(AttributeCacheModifyData.ConfigData.Attribute, self.MaxAttribute) then
    self.AttributeModifyCacheList:Remove(AttributeCacheModifyData.ModifyID)
    self.AttributeModifyCacheStartTime:Remove(AttributeCacheModifyData.ModifyID)
    self.IsUpdateAttributeCache = self.AttributeModifyCacheList:Length() > 0
    if not self.IsUpdateAttributeCache then
      local CurAttributeValue = self:GetAttributeValue()
      self:ExecuteSetAttributeModifyText(CurAttributeValue, self:GetMaxAttributeValue())
      local AllChildren = self.GridList:GetAllChildren()
      for i, SingleItem in pairs(AllChildren) do
        SingleItem:UpdateFillImg(CurAttributeValue, CurAttributeValue)
      end
      self.UpdateVirtualImg:Broadcast(CurAttributeValue)
      self.CurrentAttributeValue = CurAttributeValue
    end
  end
end

function WBP_GridBarList_C:BindOnAttributeChanged(NewValue, OldValue)
  if NewValue == OldValue and NewValue == self.CurrentAttributeValue then
    return
  end
  local Difference = NewValue - OldValue
  NewValue = self:GetAttributeValue()
  OldValue = self:GetAttributeValue() - Difference
  if not self.IsMoveVirtualBar then
    self.OldValue = OldValue
  end
  if NewValue > 0 and NewValue < 1 then
    NewValue = 1
  end
  self.CurrentAttributeValue = NewValue
  self:ExecuteSetAttributeModifyText(self.CurrentAttributeValue, self:GetMaxAttributeValue())
  local AllChildren = self.GridList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    if OldValue >= NewValue or not self.IsNeedRecoverVirtualWhite then
      SingleItem:UpdateFillImg(NewValue, OldValue)
    end
  end
  if OldValue > NewValue or self.IsNeedRecoverVirtualWhite and OldValue < NewValue then
    self:UpdateVirtualWhiteValue(OldValue, NewValue)
  end
end

function WBP_GridBarList_C:BindOnMaxAttributeChanged(NewValue, OldValue)
  self:UpdateBarGrid(self.BarLength, self.BarHeight)
end

function WBP_GridBarList_C:BindOnSpecialAttributeChanged(NewValue, OldValue)
  self:UpdateBarGrid(self.BarLength, self.BarHeight)
  self:BindOnAttributeChanged(self:GetAttributeValue(), self:GetAttributeValue() - (NewValue - OldValue))
end

function WBP_GridBarList_C:SetBarValue(NewValue, OldValue)
  local AllChildren = self.GridList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:UpdateFillImg(NewValue, OldValue)
  end
  self.UpdateVirtualImg:Broadcast(NewValue)
end

function WBP_GridBarList_C:UpdateVirtualWhiteValue(OldValue, NewValue)
  local DifferenceValue = NewValue - OldValue
  if DifferenceValue < 0 or self.IsNeedRecoverVirtualWhite then
    if DifferenceValue > 0 then
      if self.IsPlayVirtualWhiteAnim and not self.IsPlayRecoverVirtualWhiteAnim then
        self:EndVirtualWhiteAnim()
      end
      self.IsPlayRecoverVirtualWhiteAnim = true
    else
      if self.IsPlayVirtualWhiteAnim and self.IsPlayRecoverVirtualWhiteAnim then
        self:EndVirtualWhiteAnim()
      end
      self.IsPlayRecoverVirtualWhiteAnim = false
    end
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.VirtualWhiteTimer) then
      self.VirtualWhiteAnimTime = 0
      self.VirtualWhiteTargetValue = NewValue
      if self.TargetVirtualWhiteValue then
        self.VirtualWhiteOldValue = self.TargetVirtualWhiteValue
      end
      local AllChildren = self.GridList:GetAllChildren()
      for i, SingleItem in pairs(AllChildren) do
        SingleItem:ShowOrHideVirtualWhiteBar(true)
        if self.IsPlayRecoverVirtualWhiteAnim then
          SingleItem:UpdateVirtualWhiteBarValue(self.VirtualWhiteTargetValue)
          SingleItem:UpdateVirtualWhiteColor(self.RecoverVirtualWhiteColor)
          SingleItem:PlayVirtualWhiteFXAnim(true, OldValue, NewValue, self.RecoverVirtualWhiteFXColor)
        else
          SingleItem:UpdateVirtualWhiteColor(self.VirtualWhiteColor)
          SingleItem:PlayVirtualWhiteFXAnim(false, NewValue, OldValue, self.VirtualWhiteFXColor)
        end
      end
      if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.VirtualWhiteTimer) then
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.VirtualWhiteTimer)
        self.VirtualWhiteTimer = nil
      end
      self.IsPlayVirtualWhiteAnim = false
      self:DelayStartPlayVirtualWhiteAnim()
      return
    end
    self.VirtualWhiteOldValue = OldValue
    self.VirtualWhiteTargetValue = NewValue
    local AllChildren = self.GridList:GetAllChildren()
    for i, SingleItem in pairs(AllChildren) do
      SingleItem:ShowOrHideVirtualWhiteBar(true)
      if self.IsPlayRecoverVirtualWhiteAnim then
        SingleItem:UpdateVirtualWhiteBarValue(self.VirtualWhiteTargetValue)
        SingleItem:UpdateVirtualWhiteColor(self.RecoverVirtualWhiteColor)
        SingleItem:UpdateFillImg(self.VirtualWhiteOldValue, self.VirtualWhiteOldValue)
        SingleItem:PlayVirtualWhiteFXAnim(true, OldValue, NewValue, self.RecoverVirtualWhiteFXColor)
      else
        SingleItem:UpdateVirtualWhiteBarValue(self.VirtualWhiteOldValue)
        SingleItem:UpdateVirtualWhiteColor(self.VirtualWhiteColor)
        SingleItem:PlayVirtualWhiteFXAnim(false, NewValue, OldValue, self.VirtualWhiteFXColor)
      end
    end
    self:DelayStartPlayVirtualWhiteAnim()
  else
    self.VirtualWhiteOldValue = OldValue
    self.VirtualWhiteTargetValue = NewValue
    self:EndVirtualWhiteAnim()
  end
end

function WBP_GridBarList_C:DelayStartPlayVirtualWhiteAnim()
  if self.VirtualWhiteDuration <= 0.0 then
    self:StartPlayVirtualWhiteAnim()
  else
    self.VirtualWhiteTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        self:StartPlayVirtualWhiteAnim()
      end
    }, self.VirtualWhiteDuration, false)
  end
end

function WBP_GridBarList_C:StartPlayVirtualWhiteAnim()
  if self.UIQuality == UIQuality.LOW then
    self:EndVirtualWhiteAnim()
    return
  end
  self.VirtualWhiteAnimTime = 0
  self.IsPlayVirtualWhiteAnim = true
end

function WBP_GridBarList_C:UpdateVirtualWhiteAnim(InDeltaTime)
  self.VirtualWhiteAnimTime = self.VirtualWhiteAnimTime + InDeltaTime
  local MinTime, MaxTime = self.VirtualWhiteAnimCurve:GetTimeRange()
  if MaxTime < self.VirtualWhiteAnimTime then
    self:EndVirtualWhiteAnim()
    return
  end
  local PercentValue = self.VirtualWhiteAnimCurve:GetFloatValue(self.VirtualWhiteAnimTime)
  local TargetOldVirtualWhiteValue = self.VirtualWhiteOldValue - PercentValue * (self.VirtualWhiteOldValue - self.VirtualWhiteTargetValue)
  self.TargetVirtualWhiteValue = TargetOldVirtualWhiteValue
  local AllChildren = self.GridList:GetAllChildren()
  for index, SingleWidget in pairs(AllChildren) do
    if self.IsPlayRecoverVirtualWhiteAnim then
      SingleWidget:UpdateFillImg(TargetOldVirtualWhiteValue, self.VirtualWhiteOldValue)
    else
      SingleWidget:UpdateVirtualWhiteBarValue(TargetOldVirtualWhiteValue)
    end
  end
end

function WBP_GridBarList_C:EndVirtualWhiteAnim()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.VirtualWhiteTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.VirtualWhiteTimer)
    self.VirtualWhiteTimer = nil
  end
  self.IsPlayVirtualWhiteAnim = false
  self.IsPlayRecoverVirtualWhiteAnim = false
  local AllChildren = self.GridList:GetAllChildren()
  for index, SingleWidget in pairs(AllChildren) do
    SingleWidget:ShowOrHideVirtualWhiteBar(false)
    SingleWidget:UpdateFillImg(self:GetAttributeValue(), self.VirtualWhiteOldValue)
  end
  self.TargetVirtualWhiteValue = nil
end

function WBP_GridBarList_C:StartPlayVirtualBarAnim(Difference)
  if not self.IsExecuteVirtualLogic then
    return
  end
  if Difference > 0 then
    self.IsMoveVirtualBar = false
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ChangeVirtualTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ChangeVirtualTimer)
    end
    self.UpdateVirtualImg:Broadcast(self:GetAttributeValue())
  else
    self.IsMoveVirtualBar = true
    self.Speed = math.abs(Difference) / (self.VirtualChangeTotalTime / self.VirtualChangeInterval)
  end
end

function WBP_GridBarList_C:UpdateVirtualBarAnimValue(AppointValue)
  local TargetValue = self.OldValue - self.Speed
  if AppointValue then
    TargetValue = AppointValue
  elseif TargetValue > self:GetAttributeValue() then
    self.OldValue = TargetValue
  else
    TargetValue = self:GetAttributeValue()
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ChangeVirtualTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ChangeVirtualTimer)
    end
  end
  self.UpdateVirtualImg:Broadcast(TargetValue)
end

function WBP_GridBarList_C:GetAttributeValue()
  return self:GetTargetAttributeValue(self.Attribute) + self:GetTargetAttributeValue(self.SpecialAttribute)
end

function WBP_GridBarList_C:GetMaxAttributeValue()
  return self:GetTargetAttributeValue(self.MaxAttribute) + self:GetTargetAttributeValue(self.SpecialAttribute)
end

function WBP_GridBarList_C:SetGetSpecialMaxAttributeValue(Func)
  self.GetSpecialMaxAttributeValue = Func
  local AllChildren = self.GridList:GetAllChildren()
  local GetFunc = function()
    return self:GetMaxAttributeValue()
  end
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetGetSpecialMaxAttributeValue(GetFunc)
  end
end

function WBP_GridBarList_C:UpdateBarGrid(BarLength, BarHeight)
  self.BarLength = BarLength
  self.BarHeight = BarHeight
  self.ListContainer:ClearAllUseWidgets()
  if self.IsSingleGrid then
    self:InitBarItemInfo(0.0, self.BarLength, 0.0, self:GetMaxAttributeValue())
  else
    local MaxAttributeValue = self:GetMaxAttributeValue()
    local IntegetNum = math.floor(MaxAttributeValue / self.SingleBarGrid)
    local TargetNum = IntegetNum
    local RemainValue = MaxAttributeValue % self.SingleBarGrid
    local Num = TargetNum
    if 0 ~= RemainValue then
      TargetNum = TargetNum + 1
      Num = TargetNum - 1
    end
    local RemainPercent = RemainValue / self.SingleBarGrid
    local TotalNum = Num + RemainPercent
    local TargetSizeX = (self.BarLength - (TargetNum - 1) * self.IntervalPixel) / TotalNum
    if TargetNum <= self.MaxBarValue then
      local PosX = 0
      local MinNum = 0
      local MaxNum = 0
      for i = 1, IntegetNum do
        PosX = (i - 1) * (TargetSizeX + self.IntervalPixel)
        MinNum = (i - 1) * self.SingleBarGrid
        MaxNum = MinNum + self.SingleBarGrid
        self:InitBarItemInfo(PosX, TargetSizeX, MinNum, MaxNum)
      end
      if 0 ~= RemainValue then
        PosX = (TargetNum - 1) * (TargetSizeX + self.IntervalPixel)
        MinNum = MaxAttributeValue - RemainValue
        MaxNum = MaxAttributeValue
        self:InitBarItemInfo(PosX, TargetSizeX * RemainPercent, MinNum, MaxNum)
      end
    else
      self:InitBarItemInfo(0.0, self.BarLength, 0.0, self:GetMaxAttributeValue())
    end
  end
end

function WBP_GridBarList_C:InitBarItemInfo(PosX, SizeX, MinValue, MaxValue)
  local Item = self.ListContainer:GetOrCreateItem()
  if not self.GridList:HasChild(Item) then
    self.GridList:AddChildToCanvas(Item)
  end
  self.ListContainer:ShowItem(Item)
  Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  Item.ListWidget = self
  local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
  Slot:SetSize(UE.FVector2D(SizeX, self.BarHeight))
  Slot:SetPosition(UE.FVector2D(PosX, 0))
  Item.IsExecuteVirtualLogic = self.IsExecuteVirtualLogic
  Item:InitInfo(MinValue, MaxValue, self.ReduceAnimName, SizeX, self)
  Item:UpdateReduceFXWidgetColor(self.FXImgColor)
  Item:UpdateBarStyle(self.FillBrush, self.BottomBrush, self.VirtualBrush, self.SpecialFillBrush)
  Item:UpdateFillImg(self:GetAttributeValue(), -1)
  Item:UpdateVirtualImg(self:GetAttributeValue())
  Item:UpdateBarColor(self.FillColor, self.VirtualColor, self.BottomColor, self.SpecialFillColor)
  Item:SetIsShowVirtualWhite(self.IsShowVirtualWhite)
  Item.bIsShowEffect = self.bIsShowEffect
  if self.CanPlayReduceAnim then
    Item.CanPlayReduceAnim = self.CanPlayReduceAnim
  end
end

function WBP_GridBarList_C:Destruct()
  self.IsInit = false
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ChangeVirtualTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ChangeVirtualTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayVirtualTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.DelayVirtualTimer)
  end
  if self.ListContainer then
    self.ListContainer:ClearAllWidgets()
    self.ListContainer = nil
  end
  if self.OwningCharacter and self.OwningCharacter.CoreComponent then
    self.OwningCharacter.CoreComponent:UnBindAttributeChanged(self.Attribute, {
      self,
      self.BindOnAttributeChanged
    })
    self.OwningCharacter.CoreComponent:UnBindAttributeChanged(self.MaxAttribute, {
      self,
      self.BindOnMaxAttributeChanged
    })
    self.OwningCharacter.CoreComponent:UnBindAttributeChanged(self.SpecialAttribute, {
      self,
      self.BindOnSpecialAttributeChanged
    })
    self.OwningCharacter.CoreComponent:UnBindAttributeChanged(self.SpecialMaxAttribute, {
      self,
      self.BindOnSpecialMaxAttributeChanged
    })
  end
  UnListenObjectMessage(GMP.MSG_World_OnAttributeModifyCacheAdded, self)
  UnListenObjectMessage(GMP.MSG_World_OnAttributeModifyCacheRemove, self)
end

return WBP_GridBarList_C
