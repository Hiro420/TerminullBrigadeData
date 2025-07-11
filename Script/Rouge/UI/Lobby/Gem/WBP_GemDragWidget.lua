local WBP_GemDragWidget = UnLua.Class()
local GemData = require("Modules.Gem.GemData")
function WBP_GemDragWidget:Show(GemId)
  local ResourceId = GemData:GetGemResourceIdByUId(GemId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  SetImageBrushByPath(self.Img_Icon, RowInfo.Icon, self.IconSize)
end
return WBP_GemDragWidget
