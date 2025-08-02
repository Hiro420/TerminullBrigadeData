local WBP_MODItem_C = UnLua.Class()

function WBP_MODItem_C:Construct()
  self.WBP_ButtonBox.OnClicked:Add(self, WBP_MODItem_C.OnClicked_WBP_ButtonBox)
end

function WBP_MODItem_C:RefreshMODItem(InMODItem_MODData, InType_Int, InPanel)
  self.ChooseType = InType_Int
  self.Item = InMODItem_MODData
  self.Panel = InPanel
  self.DescTxt:SetText(InMODItem_MODData.Name)
  local value = self:GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass()):GetMODLevel(self.Item.MODID, self.ChooseType)
  self.NameTxt:SetText(value + 2)
end

function WBP_MODItem_C:OnClicked_WBP_ButtonBox(InButton)
  self:GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass()):TryUpgradeMOD(self.Item.MODID, self.ChooseType)
  self.Panel:HandleUpgrade(self.ChooseType)
end

return WBP_MODItem_C
