local BP_Pickup_AttributeModityBase_C = UnLua.Class()
function BP_Pickup_AttributeModityBase_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    local AttributeModifyItem = self.RGWidget:GetWidget()
    if AttributeModifyItem then
      AttributeModifyItem:InitPickUpIcon(self.ModifyId)
    end
    local ScrollPickupAttributeIcon = self.RGWidgetScrollIcon:GetWidget()
    if ScrollPickupAttributeIcon then
      print("BP_Pickup_AttributeModityBase_C:ReceiveBeginPlay AttributeModifyId:", self.ModifyId)
      ScrollPickupAttributeIcon:InitPickUpAttributeIcon(self.ModifyId)
    end
  end
end
function BP_Pickup_AttributeModityBase_C:PendingDestroy()
  self.Overridden.PendingDestroy(self)
  if UE.RGUtil.IsEditor() or not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    self:PlayPickUpEff()
  end
end
function BP_Pickup_AttributeModityBase_C:PlayPickUpEff()
  if UE.RGUtil.IsEditor() or not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    local AttributeModifyItem = self.RGWidgetScrollIcon:GetWidget()
    if AttributeModifyItem then
      AttributeModifyItem:PlayAnimation(AttributeModifyItem.Ani_PickUp, 0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, true)
    end
  end
end
function BP_Pickup_AttributeModityBase_C:ModifyRefresh()
  self.Overridden.ModifyRefresh(self)
  if not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    local AttributeModifyItem = self.RGWidget:GetWidget()
    if AttributeModifyItem then
      AttributeModifyItem:InitPickUpIcon(self.ModifyId)
    end
    local ScrollPickupAttributeIcon = self.RGWidgetScrollIcon:GetWidget()
    if ScrollPickupAttributeIcon then
      print("BP_Pickup_AttributeModityBase_C:ModifyRefresh AttributeModifyId:", self.ModifyId)
      ScrollPickupAttributeIcon:InitPickUpAttributeIcon(self.ModifyId)
    end
  end
end
function BP_Pickup_AttributeModityBase_C:ShowScrollItem(bIsShow)
  local AttributeModifyItem = self.RGWidget:GetWidget()
  if bIsShow and AttributeModifyItem then
    if AttributeModifyItem then
      AttributeModifyItem:InitPickUpIcon(self.ModifyId)
    end
    local ScrollPickupAttributeIcon = self.RGWidgetScrollIcon:GetWidget()
    if ScrollPickupAttributeIcon then
      print("BP_Pickup_AttributeModityBase_C:ModifyRefresh ShowScrollItem:", self.ModifyId)
      ScrollPickupAttributeIcon:InitPickUpAttributeIcon(self.ModifyId)
    end
  end
  if bIsShow then
    AttributeModifyItem:StopAnimation(AttributeModifyItem.ani_ScrollPickUpIcon_out)
    AttributeModifyItem:PlayAnimation(AttributeModifyItem.ani_ScrollPickUpIcon_in, 0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, true)
  else
    AttributeModifyItem:StopAnimation(AttributeModifyItem.ani_ScrollPickUpIcon_in)
    AttributeModifyItem:PlayAnimation(AttributeModifyItem.ani_ScrollPickUpIcon_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, true)
  end
end
function BP_Pickup_AttributeModityBase_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end
return BP_Pickup_AttributeModityBase_C
