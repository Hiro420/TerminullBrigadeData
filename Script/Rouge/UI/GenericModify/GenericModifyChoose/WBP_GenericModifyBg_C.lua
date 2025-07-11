local WBP_GenericModifyBg_C = UnLua.Class()
function WBP_GenericModifyBg_C:InitGenericModifyBg(RoleDrawing, HeroId, GroupId)
  UpdateVisibility(self.URGImageRoleDrawing, true)
  if HeroId and HeroId > 0 then
    local Offset = self.HeroIdToDrawingOffset:Find(HeroId)
    self:SetDrawingOffset(Offset)
  elseif GroupId and GroupId > 0 then
    local Offset = self.HeroGroupIdToDrawingOffset:Find(GroupId)
    self:SetDrawingOffset(Offset)
  else
    self:SetDrawingOffset(UE.FVector2D(0))
  end
  self:PlayAnimation(self.ani_GenericModifyBg_in)
end
function WBP_GenericModifyBg_C:SetDrawingOffset(Offset)
  if not Offset then
    return
  end
  local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.URGImageRoleDrawing)
  if CanvasPanelSlot then
    CanvasPanelSlot:SetPosition(self.NormalDrawingOffset + Offset)
  end
end
function WBP_GenericModifyBg_C:OnCreate()
end
function WBP_GenericModifyBg_C:FocusInput()
  UpdateVisibility(self.URGImageRoleDrawing, true)
end
function WBP_GenericModifyBg_C:OnDisplay()
  UpdateVisibility(self.URGImageRoleDrawing, true)
end
function WBP_GenericModifyBg_C:UnfocusInput()
  UpdateVisibility(self.URGImageRoleDrawing, false)
end
function WBP_GenericModifyBg_C:OnUnDisplay()
  UpdateVisibility(self.URGImageRoleDrawing, false)
  self:StopAllAnimations()
end
function WBP_GenericModifyBg_C:OnClose()
  UpdateVisibility(self.URGImageRoleDrawing, false)
end
function WBP_GenericModifyBg_C:FadeOut()
  self:PlayAnimation(self.ani_GenericModifyBg_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
end
return WBP_GenericModifyBg_C
