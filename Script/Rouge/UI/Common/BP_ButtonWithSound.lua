local BP_ButtonWithSound = UnLua.Class()
function BP_ButtonWithSound:K2_PlayButtonAnim(AnimName)
  if not self.AnimWidget or not self.AnimWidget:IsValid() then
    local WidgetTree = UE.UKismetSystemLibrary.GetOuterObject(self)
    if WidgetTree then
      local Widget = UE.UKismetSystemLibrary.GetOuterObject(WidgetTree)
      if Widget and Widget:Cast(UE.UUserWidget) then
        self:SetAnimWidget(Widget:Cast(UE.UUserWidget))
      end
    end
  end
  if not self.AnimWidget or not self.AnimWidget:IsValid() then
    return
  end
  if self.AnimWidget[AnimName] then
    self.AnimWidget:PlayAnimation(self.AnimWidget[AnimName])
  end
end
function BP_ButtonWithSound:K2_Hovered()
  self.Overridden.K2_Hovered(self)
  if UE.RGUtil.IsUObjectValid(self.StateCtrl_Hover) then
    self.StateCtrl_Hover:ChangeStatus(EHover.Hover)
  end
end
function BP_ButtonWithSound:K2_UnHovered()
  self.Overridden.K2_UnHovered(self)
  if UE.RGUtil.IsUObjectValid(self.StateCtrl_Hover) then
    self.StateCtrl_Hover:ChangeStatus(EHover.UnHover)
  end
end
return BP_ButtonWithSound
