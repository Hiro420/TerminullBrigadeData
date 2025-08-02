local WBP_Survival_Tips_C = UnLua.Class()

function WBP_Survival_Tips_C:OnCreate()
  self.Overridden.OnCreate(self)
  self:PlayAnimation(self.Anim_IN)
end

function WBP_Survival_Tips_C:InitTitle(TextId)
  local Desc = UE.URGBlueprintLibrary.TextFromStringTable(TextId)
  self.RGText:SetText(Desc)
  self.RGText_1:SetText(Desc)
end

function WBP_Survival_Tips_C:OnAnimationFinished(Animation)
  if Animation == self.Anim_IN then
    RGUIMgr:CloseUI(UIConfig.WBP_Survival_Tips_C.UIName)
  end
end

return WBP_Survival_Tips_C
