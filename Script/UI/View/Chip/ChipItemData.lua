local ChipItemData = UnLua.Class()
function ChipItemData:Reset()
  self.ParentView = nil
  self.ChipItemData = nil
  self.bFirst = false
  self.SelectAmount = 0
end
return ChipItemData
