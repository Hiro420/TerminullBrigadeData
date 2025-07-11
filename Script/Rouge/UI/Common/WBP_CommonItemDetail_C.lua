local WBP_CommonItemDetail_C = UnLua.Class()
function WBP_CommonItemDetail_C:InitCommonItemDetail(Id, IsInscription)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TotalResourceTable then
    return
  end
  self:InitProEff(Id)
  if IsInscription then
    local DA = GetLuaInscription(Id)
    local name = GetInscriptionName(Id)
    local desc = GetLuaInscriptionDesc(Id)
    self.Text_Name:SetText(name)
    self.Text_doc:SetText(desc)
    local A, RowInfo = GetRowData(DT.DT_ItemRarity, DA.Rarity)
    if A then
      self.Text_Quality:SetText(RowInfo.DisplayName)
      self.Img_Quality:SetColorAndOpacity(RowInfo.CommonItemDetailQualityColor.SpecifiedColor)
    end
  else
    local ItemInfo = TotalResourceTable[Id]
    if ItemInfo then
      local A, RowInfo = GetRowData(DT.DT_ItemRarity, ItemInfo.Rare)
      if A then
        self.Text_Quality:SetText(RowInfo.DisplayName)
        self.Img_Quality:SetColorAndOpacity(RowInfo.CommonItemDetailQualityColor.SpecifiedColor)
      end
      self.Text_Name:SetText(ItemInfo.Name)
      self.Text_doc:SetText(ItemInfo.Desc)
    end
  end
  self.WBP_CommonItem:InitCommonItem(Id, 0, false, nil, nil, nil, IsInscription)
end
function WBP_CommonItemDetail_C:InitProEff(ItemID)
  local ItemId = tonumber(ItemID)
  if not ItemId then
    UpdateVisibility(self.AutoLoad_ComTipProEff, false)
    return
  end
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if not Result then
    UpdateVisibility(self.AutoLoad_ComTipProEff, false)
    return
  end
  if Row.ProEffType == TableEnums.ENUMResourceEffProType.NONE then
    UpdateVisibility(self.AutoLoad_ComTipProEff, false)
    return
  end
  UpdateVisibility(self.AutoLoad_ComTipProEff, true)
  self.AutoLoad_ComTipProEff.ChildWidget:InitComProEff(ItemId)
end
function WBP_CommonItemDetail_C:ShowExpireAt(ExpireAt)
  UpdateVisibility(self.URGImage_90, nil ~= ExpireAt and "0" ~= ExpireAt and "" ~= ExpireAt)
  UpdateVisibility(self.LimitedTime, nil ~= ExpireAt and "0" ~= ExpireAt and "" ~= ExpireAt)
  self.WBP_CommonExpireAt:InitCommonExpireAt(ExpireAt)
end
return WBP_CommonItemDetail_C
