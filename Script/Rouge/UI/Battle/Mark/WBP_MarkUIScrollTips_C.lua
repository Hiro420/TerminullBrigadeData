local WBP_MarkUIScrollTips_C = UnLua.Class()
local ScrollSetTagPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetTag.WBP_ScrollSetTag_C"
function WBP_MarkUIScrollTips_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_MarkUIScrollTips_C:UpdateInteractInfo(InteractTipRow, TargetActor)
  if not UE.RGUtil.IsUObjectValid(TargetActor) then
    return
  end
  Logic_Scroll.SetPreOptimalTarget(TargetActor)
  self:InitScrollItem(TargetActor.ModifyId)
end
function WBP_MarkUIScrollTips_C:InitScrollItem(AttributeModifyId)
  self:PlayAnimation(self.ScaleAni)
  self.AttributeModifyId = AttributeModifyId
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_MarkUIScrollTips_C:InitScrollItem not DTSubsystem")
    return nil
  end
  local Result, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(AttributeModifyId, nil)
  if Result then
    UpdateVisibility(self.WBP_ScrollTipsView, true)
    self.WBP_ScrollTipsView:InitScrollTipsView(AttributeModifyId, EScrollTipsOpenType.EFromPickup)
  end
end
function WBP_MarkUIScrollTips_C:HideTips(AttributeModifyId)
  UpdateVisibility(self.WBP_ScrollTipsView, false)
  UpdateVisibility(self.URGImageInteractScrollTag, false)
  self.WBP_ScrollTipsView:Reset()
end
function WBP_MarkUIScrollTips_C:ResetNative()
  self.WBP_ScrollTipsView:Reset()
end
function WBP_MarkUIScrollTips_C:OnMouseEnter(MyGeometry, MouseEvent)
end
function WBP_MarkUIScrollTips_C:OnMouseLeave(MouseEvent)
end
function WBP_MarkUIScrollTips_C:UpdateHighlight(bIsHighlight)
end
function WBP_MarkUIScrollTips_C:HideWidget()
  self:HideTips()
end
function WBP_MarkUIScrollTips_C:Destruct()
  self:HideTips()
  self.Overridden.Destruct(self)
end
return WBP_MarkUIScrollTips_C
