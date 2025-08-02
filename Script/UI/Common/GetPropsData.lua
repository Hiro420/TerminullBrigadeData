local ChipItemData = UnLua.Class()

function ChipItemData:Reset()
  self.PropId = 0
  self.PropNum = 0
  self.IsInscription = false
  self.extra = {}
  self.ExchangedAmount = 0
end

return ChipItemData
