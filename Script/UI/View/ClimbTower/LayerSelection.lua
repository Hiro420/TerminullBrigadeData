local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local LayerSelection = UnLua.Class()
function LayerSelection:InitLayerSelection()
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  local LayerNum = table.count(ClimbTowerTable)
  local UnLockIndex = DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode)
  local Index = 1
  self.TabCache = {}
  self.LayerTabList:ClearOptions()
  self.LayerTabList.OnSelectionChanged:Clear()
  self.LayerTabList.OnSelectionChanged:Add(GameInstance, function(Target, Index)
    if "" == Index or nil == Index then
      return
    end
    self:OnTabSel(math.floor(tonumber(Index) / 10))
  end)
  for i = 1, LayerNum do
    if 0 == i % 10 then
      self.LayerTabList:AddOption(i)
    end
  end
  local Floor = ClimbTowerData:GetFloor()
  if 0 == Floor % 10 then
    self:OnTabSel(math.floor(Floor / 10))
    self.LayerTabList:SetSelectedIndex(math.floor(Floor / 10) - 1)
  else
    self:OnTabSel(math.floor(Floor / 10) + 1)
    self.LayerTabList:SetSelectedIndex(math.floor(Floor / 10))
  end
  self.Btn_Right.OnClicked:Clear()
  self.Btn_Left.OnClicked:Clear()
  self.Btn_Right.OnClicked:Add(self, function()
    self:OnTabSel(self.CurSelIndex + 1)
  end)
  self.Btn_Left.OnClicked:Add(self, function()
    self:OnTabSel(self.CurSelIndex - 1)
  end)
end
function LayerSelection:OnTabSel(index)
  if nil == index or "" == index then
    return
  end
  if index <= 0 then
    return
  end
  local MinLayer = index * 10 - 9
  local UnLockIndex = DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode)
  if MinLayer > UnLockIndex then
    print("\230\178\161\230\156\137\232\167\163\233\148\129")
    ShowWaveWindow(15008)
    self.LayerTabList:SetSelectedIndex(math.floor((UnLockIndex - 1) / 10))
    return
  end
  if DataMgr.IsInTeam() and LogicTeam.IsCaptain() then
    local TeamInfo = DataMgr.GetTeamInfo()
    for i, SinglePlayerInfo in ipairs(TeamInfo.players) do
      if SinglePlayerInfo.id ~= DataMgr.GetUserId() then
        local Floor = DataMgr.GetTeamMemberGameFloorByModeAndWorld(SinglePlayerInfo.id, ClimbTowerData.GameMode, ClimbTowerData.WorldId)
        if MinLayer > Floor then
          print("\233\152\159\229\145\152\230\178\161\230\156\137\233\154\190\229\186\166\230\178\161\230\156\137\232\167\163\233\148\129")
          ShowWaveWindow(304011)
          self.LayerTabList:SetSelectedIndex(math.floor((Floor - 1) / 10))
          return
        end
      end
    end
  end
  for k, v in pairs(self.TabCache) do
    if k == index then
      v.RGStateController_Select:ChangeStatus("Select")
      self.CurSelIndex = index
    else
      v.RGStateController_Select:ChangeStatus("UnSelect")
    end
  end
  local Index = 1
  for i = index * 10 - 9, index * 10 do
    local Item = GetOrCreateItem(self.LayerList, Index, self.WBP_LayerSel_Item:GetClass())
    if Item then
      Item:Init(index * 10 - Index + 1)
      Index = Index + 1
    end
  end
  HideOtherItem(self.LayerList, Index, true)
end
return LayerSelection
