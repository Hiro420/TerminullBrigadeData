local WBP_QTE_C = UnLua.Class()
function WBP_QTE_C:Construct()
  print("WBP_QTE_C:Construct")
  ListenObjectMessage(nil, GMP.MSG_World_Hero_StartQTE, self, self.Show)
  ListenObjectMessage(nil, GMP.MSG_World_Hero_EndQTE, self, self.Hide)
end
function WBP_QTE_C:Destruct()
  print("WBP_QTE_C:Destruct")
  UnListenObjectMessage(nil, GMP.MSG_World_Hero_StartQTE, self, self.Show)
  UnListenObjectMessage(nil, GMP.MSG_World_Hero_EndQTE, self, self.Hide)
end
function WBP_QTE_C:Show(InputId)
  self:StopAllAnimations()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationForward(self.Ani_in)
  local KeyName = UE.ERGAbilityInputID:GetNameStringByValue(InputId)
  self:RefreshInfo(KeyName)
end
function WBP_QTE_C:Hide()
  if not self:IsAnimationPlaying(self.Ani_out) then
    self:PlayAnimationForward(self.Ani_out)
  end
end
function WBP_QTE_C:BindOnPlayerEnterArea()
  self:Show()
end
function WBP_QTE_C:RefreshInfo(KeyName)
  self.WBP_CustomKeyName:SetCustomKeyConfig(KeyName, nil)
  self.WBP_CustomKeyName:InitInfo()
end
function WBP_QTE_C:OnAnimationFinished(Animation)
  if self.Ani_out == Animation then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.Ani_in == Animation then
  end
end
return WBP_QTE_C
