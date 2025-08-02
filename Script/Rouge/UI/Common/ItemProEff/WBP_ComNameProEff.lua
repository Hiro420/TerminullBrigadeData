local WBP_ComNameProEff = UnLua.Class()

function WBP_ComNameProEff:Construct()
end

function WBP_ComNameProEff:Destruct()
end

function WBP_ComNameProEff:InitComProEff(ItemId)
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

function WBP_ComNameProEff:Hide()
  UpdateVisibility(self, false)
end

return WBP_ComNameProEff
