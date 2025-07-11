local WBP_RoleMainCoreAttrList_C = UnLua.Class()
function WBP_RoleMainCoreAttrList_C:Construct()
  self.BP_ButtonExpand.OnClicked:Add(self, self.OnExpandClicked)
end
function WBP_RoleMainCoreAttrList_C:InitLobbyAbridgeAttrTips(ParentView, HeroId)
  self.ParentView = ParentView
  self.HeroId = HeroId
  self.IsInLobby = true
  self:RefreshLobbyHeroAttribtueInfo()
end
local SortAttrRow = function(A, B)
  local ResultA, AAttrDisplay = GetRowData(DT.DT_HeroBasicAttribute, tostring(A))
  local ResultB, BAttrDisplay = GetRowData(DT.DT_HeroBasicAttribute, tostring(B))
  return AAttrDisplay.PriorityLevel > BAttrDisplay.PriorityLevel
end
function WBP_RoleMainCoreAttrList_C:GetAttrDisplayNameList()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local DataTableTemp = DTSubsystem:GetDataTable(DT.DT_HeroBasicAttribute)
  local RowNames = UE.TArray(UE.FName)
  RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(DataTableTemp)
  local RowNameTb = {}
  local Result, RowData = false
  for key, SingleRowName in pairs(RowNames) do
    Result, RowData = GetRowData(DT.DT_HeroBasicAttribute, SingleRowName)
    if Result and RowData.DisplayInUI == UE.EAttributeDisplayPos.Main then
      table.insert(RowNameTb, SingleRowName)
    end
  end
  table.sort(RowNameTb, SortAttrRow)
  return RowNameTb
end
function WBP_RoleMainCoreAttrList_C:RefreshLobbyHeroAttribtueInfo()
  local Result, RowData = GetRowData(DT.DT_BasicAttributeSetInitTable, self.HeroId)
  if not Result then
    print("WBP_RoleMainCoreAttrList_C:RefreshHeroAttribtueInfo not found BasicAttribute Init Data, HeroId: ", self.CurHeroId)
    return
  end
  local AllAttribute = self:GetAttrDisplayNameList()
  local ModifyAttributeList = {}
  for index, SingleAttributeName in ipairs(AllAttribute) do
    local Result, LeftName, RightName = UE.UKismetStringLibrary.Split(SingleAttributeName, ".", nil, nil)
    ModifyAttributeList[RightName] = LogicRole.GetAttrInitValue(RightName, self.HeroId)
    local Attribute = UE.URGBlueprintLibrary.MakeGameplayAttributeByName(SingleAttributeName)
    local SingleAttributeConfig = UE.FRGAttributeConfig()
    SingleAttributeConfig.Attribute = Attribute
    SingleAttributeConfig.Value = LogicRole.GetAttrInitValue(RightName, self.HeroId)
    table.insert(ModifyAttributeList, SingleAttributeConfig)
  end
  local InscriptionIdList = {}
  local HeroTalent = DataMgr.GetHeroTalentByHeroId(self.HeroId)
  if not HeroTalent then
    if DataMgr.IsOwnHero(self.HeroId) then
      LogicTalent.RequestGetHeroTalentsToServer(self.HeroId)
    end
  else
    for SingleGroupId, SingleInfo in pairs(HeroTalent) do
      local SingleGroupInfo = LogicTalent.GetTalentTableRow(SingleGroupId)
      local TargetInfo = SingleGroupInfo[SingleInfo.level]
      TargetInfo = TargetInfo or SingleGroupInfo[1]
      if TargetInfo then
        for index, SingleInscriptionId in ipairs(TargetInfo.Inscription) do
          table.insert(InscriptionIdList, SingleInscriptionId)
        end
      else
        print("\230\156\170\230\137\190\229\136\176\229\189\147\229\137\141\229\164\169\232\181\139\231\154\132\233\133\141\231\189\174\228\191\161\230\129\175", SingleGroupId)
      end
    end
  end
  local CommonTalents = DataMgr.GetCommonTalentInfos()
  if not CommonTalents or next(CommonTalents) == nil then
  else
    for SingleGroupId, SingleInfo in pairs(CommonTalents) do
      local SingleGroupInfo = LogicTalent.GetTalentTableRow(SingleGroupId)
      local TargetInfo = SingleGroupInfo[SingleInfo.level]
      TargetInfo = TargetInfo or SingleGroupInfo[1]
      if TargetInfo then
        for index, SingleInscriptionId in ipairs(TargetInfo.Inscription) do
          table.insert(InscriptionIdList, SingleInscriptionId)
        end
      else
        print("\230\156\170\230\137\190\229\136\176\229\189\147\229\137\141\229\164\169\232\181\139\231\154\132\233\133\141\231\189\174\228\191\161\230\129\175", SingleGroupId)
      end
    end
  end
  local TargetModifyAttributeList = UE.URGBlueprintLibrary.GetAllAttributesByAttributeList(InscriptionIdList, ModifyAttributeList)
  local Index = 1
  for key, SingleModifyAttributeConfig in pairs(TargetModifyAttributeList) do
    local RowName = UE.URGBlueprintLibrary.GetAttributeFullName(SingleModifyAttributeConfig)
    local Result, RowData = GetRowData(DT.DT_HeroBasicAttribute, RowName)
    if Result then
      local Item = GetOrCreateItem(self.AttributeList, Index, self.AttributeItemTemplate:GetClass())
      Item:InitAttributeInfo(RowData.DisplayNameInUI, SingleModifyAttributeConfig.Value)
      Index = Index + 1
    end
  end
  HideOtherItem(self.AttributeList, Index)
end
function WBP_RoleMainCoreAttrList_C:OnExpandClicked()
  if self.ParentView and self.ParentView.ExpandAttr then
    self.ParentView:ExpandAttr()
  end
end
function WBP_RoleMainCoreAttrList_C:Hide()
  UpdateVisibility(self, false)
  self.ParentView = nil
end
function WBP_RoleMainCoreAttrList_C:Destruct()
  self.ParentView = nil
end
return WBP_RoleMainCoreAttrList_C
