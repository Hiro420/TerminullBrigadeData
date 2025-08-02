local PlayerInfoChangeTips = Class()
local EPlayerInfoChangeTipsItemType = {
  ChangeNickName = 1,
  ChangeHeadIcon = 2,
  ChangeBanner = 3,
  ChangeBadges = 4
}

function PlayerInfoChangeTips:InitPlayerInfoChangeTips(ParentView)
  self:StopAnimation(self.Ani_out)
  UpdateVisibility(self, true)
  self.ParentView = ParentView
  self.RGToggleGroupChangeTipsItem.OnCheckStateChanged:Add(self, self.OnToggleGroupChanged)
  self.RGToggleGroupChangeTipsItem:SelectId(-1)
  self.viewModel = UIModelMgr:Get("PlayerInfoViewModel")
  self:PlayAnimation(self.Ani_in)
end

function PlayerInfoChangeTips:OnToggleGroupChanged(SelectId)
  local bNeedShowMask = true
  if SelectId == EPlayerInfoChangeTipsItemType.ChangeNickName then
    self.viewModel:ConfirmChangeNickName()
    self:Hide()
    bNeedShowMask = false
  elseif SelectId == EPlayerInfoChangeTipsItemType.ChangeHeadIcon then
    if UE.RGUtil.IsUObjectValid(self.ParentView) then
      self.ParentView:ShowChangeHeadIconTips(true)
      self:Hide()
      bNeedShowMask = true
    end
  elseif SelectId == EPlayerInfoChangeTipsItemType.ChangeBanner then
    if UE.RGUtil.IsUObjectValid(self.ParentView) then
      self.ParentView:ShowChangeBannerTips(true)
      self:Hide()
      bNeedShowMask = true
    end
  elseif SelectId == EPlayerInfoChangeTipsItemType.ChangeBadges and UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowChangeBadgesTips(true)
    self:Hide()
    bNeedShowMask = true
  end
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    if bNeedShowMask then
      self.ParentView:ShowTipsMask()
    else
      self.ParentView:OnHideTipsClick()
    end
  end
end

function PlayerInfoChangeTips:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end

function PlayerInfoChangeTips:Hide()
  self.RGToggleGroupChangeTipsItem.OnCheckStateChanged:Remove(self, self.OnToggleGroupChanged)
  SetHitTestInvisible(self)
  self:PlayAnimation(self.Ani_out)
end

return PlayerInfoChangeTips
