local ListContainer = require("Rouge.UI.Common.ListContainer")
local WBP_LobbyCurrencyList_C = UnLua.Class()
function WBP_LobbyCurrencyList_C:Construct()
  self.ListContainer = ListContainer.New(UE.UGameplayStatics.GetObjectClass(self.ItemTemplate))
  table.insert(self.ListContainer.AllWidgets, self.ItemTemplate)
  self:InitCurrencyList()
end
function WBP_LobbyCurrencyList_C:InitCurrencyList()
  for i, SingleCurrencyId in iterator(self.CurrencyIDList) do
    print("WBP_LobbyCurrencyList_C:InitCurrencyList() SingleCurrencyId:", SingleCurrencyId)
    local Item = self.ListContainer:GetOrCreateItem()
    if Item:GetParent() ~= self.CurrencyList then
      local Slot = self.CurrencyList:AddChild(Item)
      local Padding = Slot.Padding
      Padding.Left = 10.0
      Slot:SetPadding(Padding)
    end
    self.ListContainer:ShowItem(Item, SingleCurrencyId)
  end
end
function WBP_LobbyCurrencyList_C:SetCurrencyList(CurrencyIds)
  for i, SingleCurrencyId in ipairs(CurrencyIds) do
    print("WBP_LobbyCurrencyList_C:InitCurrencyList() SingleCurrencyId:", SingleCurrencyId)
    local Item = self.ListContainer:GetOrCreateItem()
    if Item:GetParent() ~= self.CurrencyList then
      local Slot = self.CurrencyList:AddChild(Item)
      local Padding = Slot.Padding
      Padding.Left = 10.0
      Slot:SetPadding(Padding)
    end
    self.ListContainer:ShowItem(Item, SingleCurrencyId)
  end
end
function WBP_LobbyCurrencyList_C:GetCurrencyItemByCurrencyId(CurrencyId)
  local AllChildren = self.CurrencyList:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    if SingleItem.CurrencyId == CurrencyId then
      return SingleItem
    end
  end
  return nil
end
function WBP_LobbyCurrencyList_C:ClearListContainer()
  self.ListContainer:ClearAllUseWidgets()
end
function WBP_LobbyCurrencyList_C:Destruct()
  self.ListContainer:ClearAllWidgets()
  self.ListContainer = nil
end
return WBP_LobbyCurrencyList_C
