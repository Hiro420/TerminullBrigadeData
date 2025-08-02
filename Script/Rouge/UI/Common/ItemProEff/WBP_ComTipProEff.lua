local WBP_ComTipProEff = UnLua.Class()

function WBP_ComTipProEff:Construct()
end

function WBP_ComTipProEff:Destruct()
end

function WBP_ComTipProEff:InitComProEff(ItemId)
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

function WBP_ComTipProEff:InitComProEffByProEffType(ProEffType)
  if not ProEffType or ProEffType == TableEnums.ENUMResourceEffProType.NONE then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, true)
  self.StateCtrl_ProEff:ChangeStatus(ProEffType)
end

function WBP_ComTipProEff:Hide()
  UpdateVisibility(self, false)
end

return WBP_ComTipProEff
