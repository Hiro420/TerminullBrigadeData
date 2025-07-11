local WBP_CommonTipsNetBar = UnLua.Class()
function WBP_CommonTipsNetBar:Initialize(Initializer)
end
function WBP_CommonTipsNetBar:Construct()
end
function WBP_CommonTipsNetBar:ShowTips()
  UpdateVisibility(self, true)
  local NetBarDesItemList = {
    [0] = self.WBP_CommonTipsNetBarItem1,
    [1] = self.WBP_CommonTipsNetBarItem2,
    [2] = self.WBP_CommonTipsNetBarItem3
  }
  local TBNetBarPrivilegeDesList = LuaTableMgr.GetLuaTableByName(TableNames.TBNEtBarPrivilegeDes)
  local CurIndex = 0
  for key, RowInfo in pairs(TBNetBarPrivilegeDesList) do
    NetBarDesItemList[CurIndex]:UpdatePanel(RowInfo)
    CurIndex = CurIndex + 1
    if CurIndex >= 3 then
      break
    end
  end
end
return WBP_CommonTipsNetBar
