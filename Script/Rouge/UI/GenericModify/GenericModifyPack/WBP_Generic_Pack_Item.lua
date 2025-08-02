local WBP_Generic_Pack_Item = UnLua.Class()

function WBP_Generic_Pack_Item:Construct()
end

function WBP_Generic_Pack_Item:OnUnDisplay()
end

function WBP_Generic_Pack_Item:InitGenericModifyPackItem(GenericPackData, ParentView)
  self.ParentView = ParentView
  self.GenericPackItemData = GenericPackData
  self.Btn_Hover.OnHovered:Remove(self, self.Hover)
  self.Btn_Hover.OnHovered:Add(self, self.Hover)
  self.Btn_Hover.OnUnhovered:Remove(self, self.UnHover)
  self.Btn_Hover.OnUnhovered:Add(self, self.UnHover)
  self.Btn_Hover.OnClicked:Remove(self, self.Select)
  self.Btn_Hover.OnClicked:Add(self, self.Select)
  local ModifyId = GenericPackData.ModifyId
  local bActive = GenericPackData.bActive
  if bActive then
    self.StateCtrl_Active:ChangeStatus(EActive.Active)
  else
    self.StateCtrl_Active:ChangeStatus(EActive.DisActive)
  end
  local result, row = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if result then
    if GenericModifySlotDesc[row.Slot] then
      self.Txt_Slot:SetText(GenericModifySlotDesc[row.Slot])
    elseif row.Slot == UE.ERGGenericModifySlot.None then
      local Text = UE.URGBlueprintLibrary.TextFromStringTable("1054")
      self.Txt_Slot:SetText(Text)
    end
  end
  self.WBP_GenericModifyItem:InitGenericModifyItem(ModifyId)
end

function WBP_Generic_Pack_Item:Hover()
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  self.ParentView:UpdateChooseItemByModifyId(self.GenericPackItemData.ModifyId)
end

function WBP_Generic_Pack_Item:UnHover()
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  self.ParentView:UpdateChooseItem()
end

function WBP_Generic_Pack_Item:Select()
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  self.ParentView:OnBtnSelectClicked(self.GenericPackItemData.ModifyId)
end

return WBP_Generic_Pack_Item
