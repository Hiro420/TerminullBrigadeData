local WBP_OptimalPickup_C = UnLua.Class()

function WBP_OptimalPickup_C:Construct()
  self.Overridden.Construct(self)
  if not IsListeningForInputAction(self, self.ActionName) then
    ListenForInputAction(self.ActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_OptimalPickup_C.ListenForCompareInput
    })
  end
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if EquipmentComp then
    EquipmentComp.OnCurrentWeaponChanged:Add(self, WBP_OptimalPickup_C.BindOnCurrentWeaponChanged)
  end
end

function WBP_OptimalPickup_C:ListenForChangePanelTypeInput()
  LogicPickup.IsShowOptimalDetailPanel = not LogicPickup.IsShowOptimalDetailPanel
  self:SwitchInfoPanel()
end

function WBP_OptimalPickup_C:ListenForCompareInput()
  LogicPickup.IsShowComparePanel = not LogicPickup.IsShowComparePanel
  LogicPickup.ShowPickupComparePanel()
  self:Hide(true, true)
end

function WBP_OptimalPickup_C:BindOnCurrentWeaponChanged(OldWeapon, NewWeapon)
  if not LogicPickup.IsShowOptimalDetailPanel then
    self.SimplePickupTip:RefreshPanelInfo()
  end
  self:ChangeFunctionTipVisibility()
end

function WBP_OptimalPickup_C:SwitchInfoPanel()
  self:ShowSimplePanel()
end

function WBP_OptimalPickup_C:ChangeFunctionTipVisibility()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ItemData = DTSubsystem:K2_GetItemTableRow(self.AttachActor:GetItemId(), nil)
  if ItemData.ArticleType == UE.EArticleDataType.Weapon then
    self.Pickup:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  self.Decompose:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Pickup:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_OptimalPickup_C:OnPanelHide()
  self.AttachActor = nil
  if IsListeningForInputAction(self, self.ActionName) then
    StopListeningForInputAction(self, self.ActionName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, self.CompareActionName) then
    StopListeningForInputAction(self, self.CompareActionName, UE.EInputEvent.IE_Pressed)
  end
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if EquipmentComp then
    EquipmentComp.OnCurrentWeaponChanged:Remove(self, WBP_OptimalPickup_C.BindOnCurrentWeaponChanged)
  end
end

function WBP_OptimalPickup_C:Destruct()
  self.Overridden.Destruct(self)
  self:OnPanelHide()
end

return WBP_OptimalPickup_C
