local WBP_ComItemProEff = UnLua.Class()
function WBP_ComItemProEff:Construct()
end
function WBP_ComItemProEff:Destruct()
end
function WBP_ComItemProEff:InitComProEff(ItemId)
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if not Result then
    return
  end
  if Row.ProEffType == TableEnums.ENUMResourceEffProType.NONE then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, true)
  self.StateCtrl_ProEff:ChangeStatus(Row.ProEffType)
end
function WBP_ComItemProEff:Hide()
  UpdateVisibility(self, false)
end
return WBP_ComItemProEff
