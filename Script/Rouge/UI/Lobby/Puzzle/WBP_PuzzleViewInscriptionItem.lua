local WBP_PuzzleViewInscriptionItem = UnLua.Class()
function WBP_PuzzleViewInscriptionItem:Show(InscriptionId, IsActive)
  UpdateVisibility(self, true)
  self.Txt_Name:SetText(GetInscriptionName(InscriptionId))
  self.Txt_Desc:SetText(GetLuaInscriptionDesc(InscriptionId))
  if IsActive then
    self.RGStateController_Status:ChangeStatus("Active")
  else
    self.RGStateController_Status:ChangeStatus("Inactive")
  end
end
return WBP_PuzzleViewInscriptionItem
