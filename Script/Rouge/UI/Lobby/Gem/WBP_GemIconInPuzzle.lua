local WBP_GemIconInPuzzle = UnLua.Class()
local GemData = require("Modules.Gem.GemData")
function WBP_GemIconInPuzzle:Show(GemId)
  UpdateVisibility(self, true)
  UpdateVisibility(self.Img_Icon, "0" ~= GemId)
  UpdateVisibility(self.Img_Bottom, "0" == GemId)
  if "0" ~= GemId then
    local ResourceId = GemData:GetGemResourceIdByUId(GemId)
    local Result, ResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResGem, ResourceId)
    SetImageBrushByPath(self.Img_Icon, ResRowInfo.Icon, self.IconSize)
  end
end
function WBP_GemIconInPuzzle:Hide(...)
  UpdateVisibility(self, false)
end
return WBP_GemIconInPuzzle
