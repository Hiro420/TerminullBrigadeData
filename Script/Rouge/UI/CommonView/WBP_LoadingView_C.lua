local WBP_LoadingView_C = UnLua.Class()

function WBP_LoadingView_C:Construct()
  self:PlayAnimation(self.ani_matchloading_loop, 0, 0)
end

function WBP_LoadingView_C:Destruct()
  self:StopAnimation(self.ani_matchloading_loop)
end

function WBP_LoadingView_C:OnShow(Desc)
  self.RGTextDesc:SetText(Desc)
  self:PlayAnimation(self.ani_matchloading_loop, 0, 0)
end

function WBP_LoadingView_C:OnHide()
  self:StopAnimation(self.ani_matchloading_loop)
end

function WBP_LoadingView_C:UpdateDesc(Desc)
  self.RGTextDesc:SetText(Desc)
end

return WBP_LoadingView_C
