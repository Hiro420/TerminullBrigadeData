local SeasonData = require("Modules.Season.SeasonData")
local WBP_NormalDropDownItem = UnLua.Class()

function WBP_NormalDropDownItem:Construct()
end

function WBP_NormalDropDownItem:Destruct()
end

function WBP_NormalDropDownItem:InitNormalDropDownItem(SeasonID)
  UpdateVisibility(self, true, true)
  if 0 == SeasonID then
    local title = UE.URGBlueprintLibrary.TextFromStringTable(1458)
    self.Txt_Name_UnSelect:SetText(title)
    self.Txt_Name_Select:SetText(title)
    return
  end
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSeasonGeneral, SeasonID)
  if result then
    self.Txt_Name_UnSelect:SetText(row.Title)
    self.Txt_Name_Select:SetText(row.Title)
  end
end

function WBP_NormalDropDownItem:Hide()
  UpdateVisibility(self, false)
end

return WBP_NormalDropDownItem
