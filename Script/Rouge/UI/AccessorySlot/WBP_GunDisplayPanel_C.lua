local WBP_GunDisplayPanel_C = UnLua.Class()
function WBP_GunDisplayPanel_C:UpdateGunDisplayPanel(GunId, GunLevel, AccessoryList, AttributeList, InscriptionIdList, LeftOrRight)
  self.WBP_GunDisplayInfo:UpdateGunDisplayInfo(GunId, GunLevel, AccessoryList, AttributeList)
  local Number = #InscriptionIdList
  if Number > 0 then
    self.Overlay_Inscription:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_GunInscriptionPanel:UpdateInscriptionPanel(InscriptionIdList, 365)
  else
    self.Overlay_Inscription:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
end
return WBP_GunDisplayPanel_C
