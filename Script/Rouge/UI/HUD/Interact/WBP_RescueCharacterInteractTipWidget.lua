local WBP_RescueCharacterInteractTipWidget = UnLua.Class()

function WBP_RescueCharacterInteractTipWidget:Construct()
  ListenObjectMessage(nil, GMP.MSG_World_OnRescueRatioChange, self, self.BindOnRescueRatioChange)
end

function WBP_RescueCharacterInteractTipWidget:SetWidgetConfig(IsNeedProgress, KeyRowName, KeyDesc, IsNeedShowDescBottom)
  local InteractTipWidget = self.WBP_MarkUIInteractTipWidget:GetRealInteractTipWidget()
  InteractTipWidget:SetWidgetConfig(IsNeedProgress, KeyRowName, KeyDesc, IsNeedShowDescBottom)
  UpdateVisibility(self.WBP_MarkUIInteractTipWidget, true)
  InteractTipWidget:PlayInAnimation()
  UpdateVisibility(self.RescuingPanel, false)
end

function WBP_RescueCharacterInteractTipWidget:BindOnRescueRatioChange(TargetActor, Ratio)
  UpdateVisibility(self.WBP_MarkUIInteractTipWidget, 0 == Ratio)
  UpdateVisibility(self.RescuingPanel, 0 ~= Ratio)
  if 0 ~= Ratio then
    self.Txt_UserName:SetText(TargetActor:GetUserNickName())
  end
  self.Prg_RescueRatio:SetPercent(Ratio)
end

function WBP_RescueCharacterInteractTipWidget:PlayOutAnimation(AnimationFinishedEvent)
  local InteractTipWidget = self.WBP_MarkUIInteractTipWidget:GetRealInteractTipWidget()
  InteractTipWidget:PlayOutAnimation(AnimationFinishedEvent)
end

function WBP_RescueCharacterInteractTipWidget:HideWidget(...)
  UpdateVisibility(self, false)
end

function WBP_RescueCharacterInteractTipWidget:Destruct(...)
  UnListenObjectMessage(GMP.MSG_World_OnRescueRatioChange, self)
end

return WBP_RescueCharacterInteractTipWidget
