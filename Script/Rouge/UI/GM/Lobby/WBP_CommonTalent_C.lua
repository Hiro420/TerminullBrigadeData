local WBP_CommonTalent_C = UnLua.Class()
local NameList = UE.TArray(UE.FString)
local IdList = UE.TArray(0)

function WBP_CommonTalent_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_CommonTalent_C:InitWidget()
  self.Overridden.InitWidget(self)
  local TalentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTalent)
  if not TalentTable then
    return
  end
  for TalentId, TalentInfo in pairs(TalentTable) do
    NameList:Add(TalentInfo.Name)
    IdList:Add(TalentId)
  end
  self:CreateTypeButtonList(NameList)
end

function WBP_CommonTalent_C:OnTypeButtonClick(Button, ItemData)
  self.Overridden.OnTypeButtonClick(self, Button)
  local index = ItemData.Index + 1
  local TalentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTalent)
  if not TalentTable then
    return
  end
  local Info = TalentTable[IdList:Get(index)]
  self.Overridden.ShowCustomPanel(self, Info.ID, Info.GroupID, Info.Name, Info.Desc, Info.Level)
end

return WBP_CommonTalent_C
