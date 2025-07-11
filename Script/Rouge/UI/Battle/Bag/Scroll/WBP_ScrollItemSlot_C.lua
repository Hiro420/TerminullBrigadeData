local WBP_ScrollItemSlot_C = UnLua.Class()
local SlotDragAvailable = function(self, SlotItem, PointerEvent)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
    if CurrentInputType == UE.ECommonInputType.Gamepad then
      return false
    end
  end
  if self.ScrollId and self.ScrollId > 0 then
    if self.ParentView then
      self.ParentView:UpdateRemoveDropBg(true)
    end
    return true
  else
    return false
  end
end
local EndDrag = function(self)
  if self.ParentView then
    self.ParentView:UpdateRemoveDropBg(false)
  end
end
local SlotDropAvailable = function(self, DragDropItem, PickupItem, PointerEvent)
  if self.ParentView then
    self.ParentView:UpdateRemoveDropBg(false)
  end
  if not self:IsEmptySlot() then
    return
  end
  if not PickupItem.Target then
    return
  end
  Logic_Scroll.PickupScroll(PickupItem, true)
end
function WBP_ScrollItemSlot_C:Construct()
  self.Overridden.Construct(self)
  self.ScrollId = -1
  self.Index = -1
  self.bIsHovered = false
end
function WBP_ScrollItemSlot_C:InitScrollItemSlot()
  self.WBP_DragDropItem:SetDragAvailableCallback(self, self, self.WBP_ScrollItem, SlotDragAvailable, EndDrag)
  self.WBP_DragDropItem:SetDropAvailableCallback(self, self, SlotDropAvailable)
end
function WBP_ScrollItemSlot_C:UpdateScrollData(ScollId, UpdateScrollTips, ParentView, Index, ScrollTipsOpenType)
  self.ParentView = ParentView
  self.ScrollId = ScollId
  self.Index = Index
  self.UpdateScrollTips = UpdateScrollTips
  self.ScrollTipsOpenType = ScrollTipsOpenType or EScrollTipsOpenType.EFromScrollSlot
  if ScollId then
    self.WBP_ScrollItem:InitScrollItem(ScollId, UpdateScrollTips, ParentView, Index, false, true)
    UpdateVisibility(self.WBP_ScrollItem, true)
    UpdateVisibility(self.URGImage_361, false)
    UpdateVisibility(self.CanvasPanelNull, false)
    if self.bIsHovered then
      self:Hovered(false)
    end
  else
    UpdateVisibility(self.WBP_ScrollItem, false)
    UpdateVisibility(self.URGImage_361, true)
    UpdateVisibility(self.CanvasPanelNull, true)
    if self.bIsHovered then
      self:UnHovered()
    end
  end
  local LikeUserIdList = UE.URGGameplayLibrary.GetItemRequestUsers(self, tonumber(DataMgr.GetUserId()), ScollId)
  if self.RGStateController_Like ~= nil then
    if LikeUserIdList and LikeUserIdList:Num() > 0 then
      self.RGStateController_Like:ChangeStatus("LikeByOther")
    else
      self.RGStateController_Like:ChangeStatus("LikeByNone")
    end
  end
end
function WBP_ScrollItemSlot_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(self, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
    if CurrentInputType == UE.ECommonInputType.Gamepad and UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.LeftMouseButton then
      Logic_Scroll.ShareModify(self.ScrollId)
    end
  end
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    Logic_Scroll.ShareModify(self.ScrollId)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function WBP_ScrollItemSlot_C:OnMouseEnter(MyGeometry, MouseEvent)
  self:Hovered(true)
end
function WBP_ScrollItemSlot_C:Hovered(bIsNeedInit)
  if self.ParentView and self.ScrollId and self.ScrollId > 0 then
    self.UpdateScrollTips(self.ParentView, true, self.ScrollId, self, self.ScrollTipsOpenType, bIsNeedInit)
  end
  UpdateVisibility(self.URGImageHover, true)
  PlaySound2DEffect(50006, " WBP_ScrollItemSlot_C:Hovered")
  self.bIsHovered = true
end
function WBP_ScrollItemSlot_C:UnHovered()
  if self.ParentView then
    self.UpdateScrollTips(self.ParentView, false, -1, nil, self.ScrollTipsOpenType)
  end
  UpdateVisibility(self.URGImageHover, false)
  self.bIsHovered = false
end
function WBP_ScrollItemSlot_C:OnMouseLeave(MyGeometry, MouseEvent)
  self:UnHovered()
end
function WBP_ScrollItemSlot_C:UpdateHighlight(bIsShow)
  UpdateVisibility(self.URGImageHover, bIsShow)
end
function WBP_ScrollItemSlot_C:IsEmptySlot()
  return -1 == self.ScrollId or self.ScrollId == nil
end
function WBP_ScrollItemSlot_C:Hide()
  UpdateVisibility(self, false)
  if self.bIsHovered then
    self:UnHovered()
  end
  self:Reset()
end
function WBP_ScrollItemSlot_C:Destruct()
  self:PopInputAction()
end
function WBP_ScrollItemSlot_C:Reset()
  self.ParentView = nil
  self.ScrollTipsOpenType = nil
  self.UpdateScrollTips = nil
  self.Index = -1
  self.ScrollId = -1
  self.bIsHovered = false
end
function WBP_ScrollItemSlot_C:OnBtnDown()
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(self, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
    if CurrentInputType == UE.ECommonInputType.Gamepad then
      Logic_Scroll.ShareModify(self.ScrollId)
      return
    end
  end
end
return WBP_ScrollItemSlot_C
