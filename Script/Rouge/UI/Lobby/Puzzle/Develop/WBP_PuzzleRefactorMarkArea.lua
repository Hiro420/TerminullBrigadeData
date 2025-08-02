local WBP_PuzzleRefactorMarkArea = UnLua.Class()

function WBP_PuzzleRefactorMarkArea:Construct()
  UpdateVisibility(self, false)
end

function WBP_PuzzleRefactorMarkArea:RegisitMarkArea(ResourceIdList)
  local PuzzleRefactorViewModel = UIModelMgr:Get("PuzzleRefactorViewModel")
  local ResourceIdList = ResourceIdList or self.ResourceId:ToTable()
  for k, SingleResourceId in pairs(ResourceIdList) do
    PuzzleRefactorViewModel:RegisitMarkArea(SingleResourceId, self)
  end
end

function WBP_PuzzleRefactorMarkArea:Show()
  UpdateVisibility(self, true)
  self:PlayAnimation(self.Anim_IN)
end

function WBP_PuzzleRefactorMarkArea:PlayRefreshAnim()
  self:PlayAnimation(self.Anim_Refresh)
end

function WBP_PuzzleRefactorMarkArea:Hide()
  UpdateVisibility(self, false)
end

function WBP_PuzzleRefactorMarkArea:Destruct()
  self:StopAllAnimations()
end

return WBP_PuzzleRefactorMarkArea
