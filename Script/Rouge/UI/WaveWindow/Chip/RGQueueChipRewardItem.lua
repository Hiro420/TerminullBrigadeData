local ChipData = require("Modules.Chip.ChipData")
local RGQueueChipRewardItem = UnLua.Class()

function RGQueueChipRewardItem:InitQueueChipRewardItem(ChipResID)
  UpdateVisibility(self, false)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ChipResID)
  if result then
    self.RGStateController_color:ChangeStatus(row.Rare)
    SetImageBrushByPath(self.Img_Icon, row.Icon)
  end
end

function RGQueueChipRewardItem:Show()
  UpdateVisibility(self, true)
  self:PlayAnimation(self.Ani_in)
end

function RGQueueChipRewardItem:Hide()
  UpdateVisibility(self, false)
end

return RGQueueChipRewardItem
