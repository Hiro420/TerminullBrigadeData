local WBP_ScrollPickupItem_C = UnLua.Class()
local ScrollSetTagPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetTag.WBP_ScrollSetTag_C"
local SlotDragAvailable = function(self, SlotItem, PointerEvent)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
    if CurrentInputType == UE.ECommonInputType.Gamepad then
      return false
    end
  end
  if self.ScrollId > 0 then
    if self.ParentView and self.ParentView.HighLightDropSlot then
      self.ParentView:HighLightDropSlot(true)
    end
    return true
  else
    return false
  end
end
local EndDrag = function(self)
  if self.ParentView then
    self.ParentView:UpdateRemoveDropBg(false)
    if self.ParentView.HighLightDropSlot then
      self.ParentView:HighLightDropSlot(false)
    end
  end
end

function WBP_ScrollPickupItem_C:Construct()
  self.Overridden.Construct(self)
  self.ScrollId = -1
  self.bIsHovered = false
  self.BP_ButtonMakePublic.OnClicked:Add(self, self.OnMakePublicClick)
end

function WBP_ScrollPickupItem_C:InitScrollPickupItem()
  if not self.bIsInited then
    self.WBP_DragDropItem:SetDragAvailableCallback(self, self, self.SizeBoxIcon, SlotDragAvailable, EndDrag)
    self.bIsInited = true
  end
end

function WBP_ScrollPickupItem_C:UpdateScrollData(Target, UpdateScrollTips, ParentView, Index)
  print("WBP_ScrollPickupItem_C:UpdateScrollData", Target, Target.ModifyId, Target.IsShared, Target.IsShine, ParentView, Index)
  if not Target then
    return
  end
  self.Idx = Index
  self.ParentView = ParentView
  local ScrollId = Target.ModifyId
  self.ScrollId = ScrollId
  self.Target = Target.Target
  self.IsShared = Target.IsShared
  self.IsShine = Target.IsShine
  self.UpdateScrollTips = UpdateScrollTips
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local Result, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(ScrollId, nil)
    if Result then
      SetImageBrushBySoftObject(self.Image_Icon, AttributeModifyRow.SpriteIcon)
      UpdateVisibility(self.Image_Icon, true)
      local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(AttributeModifyRow.Rarity, nil)
      if ResultItemRarity then
        self.Image_quality:SetColorAndOpacity(ItemRarityRow.AttributeModifyRareBgColor)
      end
    else
      UpdateVisibility(self.Image_Icon, false)
    end
  end
  self:InitScrollPickupItem()
  UpdateVisibility(self, true)
  UpdateVisibility(self.CanvasPanelMakePublic, not Target.IsShared)
  UpdateVisibility(self.URGImagePublicTag, Target.IsShared)
  UpdateVisibility(self.Effect_Panel, Target.IsShine)
  UpdateVisibility(self.TxT_Count, self.Target.Count > 1)
  self.TxT_Count:SetText(self.Target.Count)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollPickupItem_C:UpdateScrollData not DTSubsystem")
    return nil
  end
  local Result, AttributeModifyRow = GetRowData(DT.DT_AttributeModify, tostring(ScrollId))
  if Result then
    self.RGTextName:SetText(AttributeModifyRow.Name)
    local ScrollSetTagCls = UE.UClass.Load(ScrollSetTagPath)
    local IndexSetTag = 1
    for i, v in iterator(AttributeModifyRow.SetArray) do
      local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(v, nil)
      if ResultModifySet then
        local SetTagItem = GetOrCreateItem(self.VerticalBoxScrollSetTag, IndexSetTag, ScrollSetTagCls)
        UpdateVisibility(SetTagItem, true)
        SetTagItem:InitSetTag(AttributeModifySetRow)
        IndexSetTag = IndexSetTag + 1
      end
    end
    HideOtherItem(self.VerticalBoxScrollSetTag, IndexSetTag)
  end
  if self.bIsHovered then
    self:Hovered(false)
  end
end

function WBP_ScrollPickupItem_C:RefreshShine(IsShine)
  UpdateVisibility(self.Effect_Panel, IsShine)
end

function WBP_ScrollPickupItem_C:Hovered(bIsNeedInit)
  if self.ParentView then
    self.UpdateScrollTips(self.ParentView, true, self.ScrollId, self, EScrollTipsOpenType.EFromBagPickupList, bIsNeedInit)
  end
  UpdateVisibility(self.URGImageHover, true)
  self.bIsHovered = true
end

function WBP_ScrollPickupItem_C:UnHovered()
  if self.ParentView then
    self.UpdateScrollTips(self.ParentView, false, -1, nil, EScrollTipsOpenType.EFromBagPickupList)
  end
  UpdateVisibility(self.URGImageHover, false)
  self.bIsHovered = false
end

function WBP_ScrollPickupItem_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(self, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
    if CurrentInputType == UE.ECommonInputType.Gamepad and UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.LeftMouseButton then
      if UE.RGUtil.IsUObjectValid(self.ParentView) then
        self.ParentView:UpatePickupIdx(self.Idx)
      end
      Logic_Scroll.PickupScroll(self, true)
      return UE.UWidgetBlueprintLibrary.Handled()
    end
  end
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    Logic_Scroll.PickupScroll(self, true)
    return UE.UWidgetBlueprintLibrary.Handled()
  elseif UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.MiddleMouseButton then
    print("WBP_ScrollPickupItem_C:OnMouseButtonDown")
    EventSystem.Invoke(EventDef.MainPanel.MainPanelScrollPickUpPress)
    return UE.UWidgetBlueprintLibrary.Handled()
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_ScrollPickupItem_C:OnMouseButtonUp(MyGeometry, MouseEvent)
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.MiddleMouseButton then
    print("WBP_ScrollPickupItem_C:OnMouseButtonUp")
    EventSystem.Invoke(EventDef.MainPanel.MainPanelScrollPickUpReleased)
    return UE.UWidgetBlueprintLibrary.Handled()
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_ScrollPickupItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self:Hovered(true)
end

function WBP_ScrollPickupItem_C:OnMouseLeave(MyGeometry)
  self:UnHovered()
end

function WBP_ScrollPickupItem_C:OnMakePublicClick()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character or not Character.AttributeModifyComponent then
    return
  end
  local TargetActor = self.Target.ModifyActors:Get(1)
  if not TargetActor or not TargetActor:IsValid() then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
  if not PlayerMiscComp then
    return
  end
  if not TargetActor:IsShared() then
    PlayerMiscComp:SharePickupAttributeModify(TargetActor, Character)
  end
end

function WBP_ScrollPickupItem_C:Hide()
  UpdateVisibility(self, false)
  if self.bIsHovered then
    self:UnHovered()
  end
  self.ParentView = nil
  self.Idx = -1
  self.UpdateScrollTips = nil
  self.Target = nil
  self.ScrollId = -1
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.LongPressTimer) then
    print("WBP_ScrollPickupItem_C:ClearLongPressTimer")
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.LongPressTimer)
    self.LongPressTimer = nil
  end
end

function WBP_ScrollPickupItem_C:Destruct()
  self.ParentView = nil
  self.UpdateScrollTips = nil
  self.Target = nil
  self.BP_ButtonMakePublic.OnClicked:Remove(self, self.OnMakePublicClick)
  self.bIsHovered = false
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.LongPressTimer) then
    print("WBP_ScrollPickupItem_C:ClearLongPressTimer")
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.LongPressTimer)
    self.LongPressTimer = nil
  end
end

return WBP_ScrollPickupItem_C
