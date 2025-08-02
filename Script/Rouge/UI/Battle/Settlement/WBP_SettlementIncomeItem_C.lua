local WBP_SettlementIncomeItem_C = UnLua.Class()

function WBP_SettlementIncomeItem_C:Construct()
end

function WBP_SettlementIncomeItem_C:InitByItemId(IncrementValue, ItemId, Name, bIsHideWhenIncrementZero, PrivilegeDetailsParam)
  if bIsHideWhenIncrementZero and 0 == IncrementValue then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local PrivilegeSource = UE.ERGPrivilegeSource.None
  if PrivilegeDetailsParam and PrivilegeDetailsParam.PrivilegeSource then
    PrivilegeSource = PrivilegeDetailsParam.PrivilegeSource
  end
  UpdateVisibility(self.Overlay_ExtraFlag, PrivilegeSource == UE.ERGPrivilegeSource.MonthCard or PrivilegeSource == UE.ERGPrivilegeSource.NetBar)
  if PrivilegeSource ~= UE.ERGPrivilegeSource.None and SettlementPrivilegeConfig[PrivilegeSource] then
    if SettlementPrivilegeConfig[PrivilegeSource].IconPath then
      UpdateVisibility(self.Icon_Privilege, true)
      SetImageBrushByPath(self.Icon_Privilege, SettlementPrivilegeConfig[PrivilegeSource].IconPath)
    else
      UpdateVisibility(self.Icon_Privilege, false)
    end
    if SettlementPrivilegeConfig[PrivilegeSource].DescFmt and PrivilegeDetailsParam.IncreasePercent then
      local Percent = math.floor(PrivilegeDetailsParam.IncreasePercent * 100 + 0.5)
      local privilegeName = UE.FTextFormat(SettlementPrivilegeConfig[PrivilegeSource].DescFmt(), Percent)
      self.Txt_Extra:SetText(privilegeName)
    else
      self.Txt_Extra:SetText("")
    end
  end
  UpdateVisibility(self.Overlay_Benefit, PrivilegeSource == UE.ERGPrivilegeSource.Benefit)
  UpdateVisibility(self.WBP_Item, true)
  UpdateVisibility(self.Canvas_Frag, false)
  self.WBP_Item:InitItem(ItemId)
  self.Txt_Num:SetText(IncrementValue)
  self.Txt_FragNum:SetText(IncrementValue)
  if Name then
    self.Txt_Name:SetText(Name)
  else
    local result, row = LuaTableMgr.GetLuaTableRowInfo(TableEnums.TBGeneral, ItemId)
    if result then
      self.Txt_Name:SetText(row.Name)
    else
      local resultItem, rowItem = GetRowData(DT.DT_Item, tonumber(ItemId))
      if resultItem then
        self.Txt_Name:SetText(rowItem.Name)
      end
    end
  end
end

function WBP_SettlementIncomeItem_C:Init(IncrementValue, Name, Icon, bIsHideWhenIncrementZero)
  if bIsHideWhenIncrementZero and 0 == IncrementValue then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  UpdateVisibility(self.WBP_Item, false)
  UpdateVisibility(self.Canvas_Frag, true)
  self.Txt_Name:SetText(Name)
  self.Txt_Num:SetText(IncrementValue)
  SetImageBrushBySoftObject(self.Img_Icon, Icon)
end

function WBP_SettlementIncomeItem_C:ShowBeginnerClearFlag()
  UpdateVisibility(self.Overlay_ExtraFlag, true)
  if SettlementBeginnerClearConfig.Name then
    self.Txt_Extra:SetText(SettlementBeginnerClearConfig.Name)
  end
  if SettlementBeginnerClearConfig.IconPath then
    SetImageBrushByPath(self.Icon_Privilege, SettlementBeginnerClearConfig.IconPath)
  else
    UpdateVisibility(self.Icon_Privilege, false)
  end
end

function WBP_SettlementIncomeItem_C:UnInit()
end

function WBP_SettlementIncomeItem_C:Destruct()
end

return WBP_SettlementIncomeItem_C
