local WBP_AbridgeAttrTips_C = UnLua.Class()

function WBP_AbridgeAttrTips_C:Construct()
  self.BP_ButtonExpand.OnClicked:Add(self, self.OnExpandClicked)
end

function WBP_AbridgeAttrTips_C:InitAbridgeAttrTips(AttrNameList, ParentView)
  self.ParentView = ParentView
  local Index = 1
  for i, v in ipairs(AttrNameList) do
    local Result, RowData = GetRowData(DT.DT_HeroBasicAttribute, v)
    if Result and RowData.DisplayInUI == UE.EAttributeDisplayPos.Main and RowData.bShowInBattle then
      local Item = GetOrCreateItem(self.VerticalBoxAttrRoot, Index, self.WBP_AttrItem:GetClass())
      Item:InitAttrItem(RowData, v, true)
      Index = Index + 1
    end
  end
  HideOtherItem(self.VerticalBoxAttrRoot, Index + 1)
  UpdateVisibility(self, true)
end

function WBP_AbridgeAttrTips_C:InitLobbyAbridgeAttrTips(ParentView, HeroId)
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

function WBP_AbridgeAttrTips_C:GetAttrDisplayNameList()
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
    if Result and RowData.DisplayInUI == UE.EAttributeDisplayPos.Main and RowData.bShowInBattle then
      table.insert(RowNameTb, SingleRowName)
    end
  end
  table.sort(RowNameTb, SortAttrRow)
  return RowNameTb
end

function WBP_AbridgeAttrTips_C:RefreshLobbyHeroAttribtueInfo()
end

function WBP_AbridgeAttrTips_C:OnExpandClicked()
  if self.ParentView and self.ParentView.ExpandAttr then
    self.ParentView:ExpandAttr()
  end
end

function WBP_AbridgeAttrTips_C:Hide()
  UpdateVisibility(self, false)
  self.ParentView = nil
end

function WBP_AbridgeAttrTips_C:Destruct()
  self.ParentView = nil
end

return WBP_AbridgeAttrTips_C
