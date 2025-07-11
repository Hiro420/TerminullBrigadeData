local WBP_GPWeaponDisplayInfo_C = UnLua.Class()
function WBP_GPWeaponDisplayInfo_C:Construct()
  EventSystem.AddListener(self, EventDef.GamePokey.OnInscriptionHovered, WBP_GPWeaponDisplayInfo_C.OnInscriptionHovered)
  EventSystem.AddListener(self, EventDef.GamePokey.OnInscriptionUnHovered, WBP_GPWeaponDisplayInfo_C.OnInscriptionUnHovered)
  self.WBP_GPExtraDescItemsPanel:SetVisibility(UE.ESlateVisibility.Hidden)
end
function WBP_GPWeaponDisplayInfo_C:Destruct()
  EventSystem.RemoveListener(EventDef.GamePokey.OnInscriptionHovered, WBP_GPWeaponDisplayInfo_C.OnInscriptionHovered)
  EventSystem.RemoveListener(EventDef.GamePokey.OnInscriptionUnHovered, WBP_GPWeaponDisplayInfo_C.OnInscriptionUnHovered)
end
function WBP_GPWeaponDisplayInfo_C:UpdateWeaponDisplayInfo(InWeapon)
  self.WBP_CommonWeaponDisplayInfo:InitInfo(InWeapon)
  self.WBP_GPInscriptionPanel:UpdateInscriptionsDes(InWeapon)
end
function WBP_GPWeaponDisplayInfo_C:OnInscriptionHovered(InscriptionId)
  local dataArray = UE.TArray(0)
  dataArray:Add(InscriptionId)
  self.WBP_GPExtraDescItemsPanel:UpdateInscriptionAdditions(dataArray)
end
function WBP_GPWeaponDisplayInfo_C:OnInscriptionUnHovered()
  self.WBP_GPExtraDescItemsPanel:SetVisibility(UE.ESlateVisibility.Hidden)
end
return WBP_GPWeaponDisplayInfo_C
