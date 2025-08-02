local RedDotData = require("Modules.RedDot.RedDotData")
local MallExteriorTypeView = UnLua.Class()

function MallExteriorTypeView:OnListItemObjectSet(ListItemObj)
  if ListItemObj then
    self.SecondShelfId = ListItemObj.SecondShelfId
    self.ShelfId = ListItemObj.ShelfId
  end
  self.WBP_SkinToggleHero:OnSelect(false)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBShelfSecondTab, self.SecondShelfId)
  if result then
    self.WBP_SkinToggleHero:SetSkinToggleForStore(row.Icon, row.Name)
    self.WBP_SystemUnlock:InitSysId(row.SystemID)
  else
    self.WBP_SystemUnlock:InitSysId(-1)
  end
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.ShelfId .. "_" .. self.SecondShelfId)
  UpdateVisibility(self.WBP_SkinToggleHero.CheckBox, true, false)
end

function MallExteriorTypeView:BP_OnItemSelectionChanged(bSelected)
  self.WBP_SkinToggleHero:OnSelect(bSelected)
end

return MallExteriorTypeView
