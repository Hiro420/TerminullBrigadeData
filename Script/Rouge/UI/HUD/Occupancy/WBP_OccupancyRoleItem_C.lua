local WBP_OccupancyRoleItem_C = UnLua.Class()
local ListContainerMaxNum = 4
local ArrowNameFormat = "ImageRoleListBg_"

function WBP_OccupancyRoleItem_C:Update(bHavePlayer)
  if bHavePlayer then
    self.URGImagePlayer:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.URGImagePlayer:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_OccupancyRoleItem_C:OnInit()
  self.Overridden.Construct(self)
  self.RoleItemList = {}
  self:EnterOccupancyLevelImp()
  self:BindToAnimationFinished(self.FailedAni, {
    self,
    WBP_OccupancyRoleItem_C.BindFailedAniFinished
  })
  self:BindToAnimationFinished(self.DefendSuccess, {
    self,
    WBP_OccupancyRoleItem_C.BindDefendSuccessFinished
  })
  self:BindToAnimationFinished(self.DefendStartAni, {
    self,
    WBP_OccupancyRoleItem_C.BindDefendStartAniFinished
  })
end

return WBP_OccupancyRoleItem_C
