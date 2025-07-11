local GMConfig = require("GameConfig.GM.GMConfig")
local WBP_AddLobbyResourceCurrency_C = UnLua.Class()
local CurSelectItemIndex = 0
function WBP_AddLobbyResourceCurrency_C:InitWidget()
  for TypeName, TypeAlias in pairs(TableEnumsAlias.ENUMResourceType) do
    if not GMConfig.FilterResType[TypeName] then
      self.TypeNameList:Add(TypeAlias)
      self.TypeIdList:Add(TableEnums.ENUMResourceType[TypeName])
    end
  end
  self.Overridden.InitWidget(self)
end
function WBP_AddLobbyResourceCurrency_C:OnTypeButtonClick(Button, ItemData)
  local index = ItemData.Index + 1
  self:GetResourceItemName(self.TypeIdList:Get(index))
  self.Overridden.OnTypeButtonClick(self, Button, ItemData)
end
function WBP_AddLobbyResourceCurrency_C:GetResourceItemName(TypeId)
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not ResourceTable then
    return
  end
  self.NameList:Clear()
  self.IdList:Clear()
  for SingleResourceId, SingleResourceInfo in pairs(ResourceTable) do
    if SingleResourceInfo.Type == TypeId then
      self.NameList:Add(SingleResourceInfo.Name)
      self.IdList:Add(SingleResourceId)
    end
  end
end
function WBP_AddLobbyResourceCurrency_C:OnItemButtonClick(Button, ItemData)
  CurSelectItemIndex = ItemData.Index + 1
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local Info = ResourceTable[self.IdList:Get(CurSelectItemIndex)]
  self.ItemId = self.IdList:Get(CurSelectItemIndex)
  self.Overridden.ShowCustomPanel(self, Info.ID, Info.Name, Info.Desc)
end
function WBP_AddLobbyResourceCurrency_C:OnSubmitClick(Num)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local cheatManager = PC.CheatManager
  print(CurSelectItemIndex)
  print(self.IdList:IsValidIndex(CurSelectItemIndex))
  print(self.IdList:Get(CurSelectItemIndex))
  cheatManager:AddLobbyResourceCurrency(self.IdList:Get(CurSelectItemIndex), Num)
end
return WBP_AddLobbyResourceCurrency_C
