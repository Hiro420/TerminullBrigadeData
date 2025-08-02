local specificmodifyconfig = require("GameConfig.SpecificModify.SpecificModifyConfig")
local IllustratedGuideData = {
  HeroSpecificModifyMap = {},
  CurrentWorldId = -1,
  CurrentClueId = -1,
  CurrentFragmentId = -1,
  NewUnlockSpecificModifyList = {},
  SpecificUnlockAniMap = {}
}

function IllustratedGuideData:Init()
  self:InitHeroSpecificMap()
end

function IllustratedGuideData:InitHeroSpecificMap()
  self.HeroSpecificModifyMap = {}
  local HeroIdList = GetAllRowNames(DT.DT_Hero)
  for k, HeroId in pairs(HeroIdList) do
    local ResultHero, HeroData = GetRowData(DT.DT_Hero, tostring(HeroId))
    if ResultHero then
      local LegendList = HeroData.ModConfig.LegendConfig.LegendList
      local TempSpecificModifyList = LegendList:ToTable()
      self.HeroSpecificModifyMap[tostring(HeroId)] = LegendList:ToTable()
      for k, SpecificModifyId in pairs(TempSpecificModifyList) do
        if not self.HeroSpecificModifyMap[tostring(SpecificModifyId)] then
          self.HeroSpecificModifyMap[tostring(SpecificModifyId)] = {
            tostring(HeroId)
          }
        else
          table.insert(self.HeroSpecificModifyMap[tostring(SpecificModifyId)], tostring(HeroId))
        end
      end
    end
  end
end

function IllustratedGuideData:GetHeroIdListBySpecificModifyId(SpecificModifyId)
  return self.HeroSpecificModifyMap[tostring(SpecificModifyId)]
end

function IllustratedGuideData:GetSpecificModifyListByHeroId(HeroId)
  return self.HeroSpecificModifyMap[tostring(HeroId)]
end

function IllustratedGuideData:GetUnlockMethodDescBySpecificModifyId(SpecificModifyId)
  local t = LuaTableMgr.GetLuaTableByName(TableNames.TBInfiniteProp)
  return tostring(t[SpecificModifyId].unlockMethodDesc)
end

function IllustratedGuideData:GetIsInitUnlockBySpecificModifyId(SpecificModifyId)
  local t = LuaTableMgr.GetLuaTableByName(TableNames.TBInfiniteProp)
  return t[tonumber(SpecificModifyId)].initunlock
end

function IllustratedGuideData:GetSpecificUnlockTaskId(SpecificModifyId)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBInfiniteProp, SpecificModifyId)
  if result then
    return row.unlockTaskId
  end
  return 0
end

function IllustratedGuideData:GetPlotFragmentWorldIdList()
  local WorldTable = LuaTableMgr.GetLuaTableByName("story_tbworld")
  local WorldIdList = {}
  for k, WorldInfo in pairs(WorldTable) do
    table.insert(WorldIdList, WorldInfo.worldID)
  end
  table.sort(WorldIdList, function(a, b)
    return a < b
  end)
  return WorldIdList
end

function IllustratedGuideData:GetFragmentPropIdList()
  local FragmentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBFragment)
  local FragmentPropIdList = {}
  for k, FragmentInfo in pairs(FragmentTable) do
    table.insert(FragmentPropIdList, FragmentInfo.battleFragmentPropID)
  end
  return FragmentPropIdList
end

function IllustratedGuideData:GetPlotFragmentIdListByWorldId(WorldId)
  local WorldTable = LuaTableMgr.GetLuaTableByName("story_tbworld")
  local ClueTable = LuaTableMgr.GetLuaTableByName("story_tbclue")
  local FragmentIdList = {}
  for k, WorldInfo in pairs(WorldTable) do
    if WorldInfo.worldID == WorldId then
      local ClueIdList = WorldInfo.clueIDList
      for k, ClueId in pairs(ClueIdList) do
        local FragmentIDList = ClueTable[ClueId].fragmentIDList
        for k, FragmentID in pairs(FragmentIDList) do
          table.insert(FragmentIdList, FragmentID)
        end
      end
      break
    end
  end
  return FragmentIdList
end

function IllustratedGuideData:GetClueInfoByClueId(ClueId)
  local ClueTable = LuaTableMgr.GetLuaTableByName("story_tbclue")
  return ClueTable[ClueId]
end

function IllustratedGuideData:GetWorldInfoByWorldId(WorldId)
  local WorldTable = LuaTableMgr.GetLuaTableByName("story_tbworld")
  local WorldTableRow
  for k, WorldInfo in pairs(WorldTable) do
    if WorldInfo.worldID == WorldId then
      WorldTableRow = WorldInfo
      break
    end
  end
  local WorldInfo = {}
  WorldInfo.WorldId = WorldId
  WorldInfo.Name = WorldTableRow.name
  WorldInfo.Icon = WorldTableRow.icon
  WorldInfo.BaseImage = WorldTableRow.baseImage
  WorldInfo.ClueIdList = WorldTableRow.clueIDList
  WorldInfo.PlotFragmentsCount = #self:GetPlotFragmentIdListByWorldId(WorldId)
  WorldInfo.FinishedPlotFragmentsCount = 0
  for k, FragmentId in pairs(self:GetPlotFragmentIdListByWorldId(WorldId)) do
    if 2 == self:GetPlotFragmentStateById(FragmentId) or 3 == self:GetPlotFragmentStateById(FragmentId) then
      WorldInfo.FinishedPlotFragmentsCount = WorldInfo.FinishedPlotFragmentsCount + 1
    end
  end
  return WorldInfo
end

function IllustratedGuideData:IsFragmentUnlock(FragmentId)
  local FragmentInfo = self:GetPlotFragmentInfoByFragmentId(FragmentId)
  local TaskId = FragmentInfo.taskID
  return table.Contain({2, 3}, Logic_MainTask.GetStateByTaskId(TaskId))
end

function IllustratedGuideData:IsClueUnlock(ClueId)
  local FragmentIdList = self:GetClueInfoByClueId(ClueId).fragmentIDList
  for k, FragmentId in pairs(FragmentIdList) do
    if not self:IsFragmentUnlock(FragmentId) then
      return false
    end
  end
  return true
end

function IllustratedGuideData:GetPlotFragmentStateById(FragmentId)
  local FragmentInfo = self:GetPlotFragmentInfoByFragmentId(FragmentId)
  local TaskId = FragmentInfo.taskID
  return Logic_MainTask.GetStateByTaskId(TaskId)
end

function IllustratedGuideData:GetPlotFragmentInfoByFragmentId(FragmentId)
  local FragmentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBFragment)
  return FragmentTable[FragmentId]
end

function IllustratedGuideData:GetPlotFragmentInfoByTaskId(TaskId)
  local FragmentTable = LuaTableMgr.GetLuaTableByName(TableNames.TBFragment)
  for k, FragmentInfo in pairs(FragmentTable) do
    if FragmentInfo.taskID == TaskId then
      return FragmentInfo
    end
  end
  return nil
end

function IllustratedGuideData:CheckClueFinishedByClueId(ClueId)
  local FragmentIdList = self:GetClueInfoByClueId(ClueId).fragmentIDList
  for k, FragmentId in pairs(FragmentIdList) do
    if 2 ~= self:GetPlotFragmentStateById(FragmentId) and 3 ~= self:GetPlotFragmentStateById(FragmentId) then
      return false
    end
  end
  return true
end

function IllustratedGuideData:ClueProgressByClueId(ClueId)
  local Result = {}
  Result.FinishedCount = 0
  Result.TotalCount = 0
  local FragmentIdList = self:GetClueInfoByClueId(ClueId).fragmentIDList
  for k, FragmentId in pairs(FragmentIdList) do
    if 2 == self:GetPlotFragmentStateById(FragmentId) or 3 == self:GetPlotFragmentStateById(FragmentId) then
      Result.FinishedCount = Result.FinishedCount + 1
    end
  end
  Result.TotalCount = #FragmentIdList
  return Result
end

function IllustratedGuideData:CheckIsPlotFragmentTask(TaskGroupId)
  local PlotFragmentClueTB = LuaTableMgr.GetLuaTableByName(TableNames.TBClue)
  for Index, ClueInfo in pairs(PlotFragmentClueTB) do
    if TaskGroupId == ClueInfo.taskGroupID then
      return true
    end
  end
  return false
end

function IllustratedGuideData:CheckIsSpecificTask(TaskGroupId)
  for Idx, GroupId in ipairs(specificmodifyconfig.TaskGroupIdList) do
    if TaskGroupId == GroupId then
      return true
    end
  end
  return false
end

function IllustratedGuideData:GetClueIdListByWorldId(WorldId)
  local WorldTable = LuaTableMgr.GetLuaTableByName("story_tbworld")
  local ClueIdList = {}
  for k, WorldInfo in pairs(WorldTable) do
    if WorldInfo.worldID == WorldId then
      ClueIdList = WorldInfo.clueIDList
      break
    end
  end
  return ClueIdList
end

function IllustratedGuideData:GetPlotFragmentProgress()
  local WorldTable = LuaTableMgr.GetLuaTableByName("story_tbworld")
  local CurCount = 0
  local TotalCount = 0
  for k, WorldInfo in pairs(WorldTable) do
    local _WorldInfo = self:GetWorldInfoByWorldId(WorldInfo.worldID)
    CurCount = CurCount + _WorldInfo.FinishedPlotFragmentsCount
    TotalCount = TotalCount + _WorldInfo.PlotFragmentsCount
  end
  return {CurCount, TotalCount}
end

function IllustratedGuideData:ClearNewUnlockSpecificData()
  self.NewUnlockSpecificModifyList = {}
end

function IllustratedGuideData:AddNewUnlockSpecificData(SpecificModifyData)
  for i, v in ipairs(self.NewUnlockSpecificModifyList) do
    if v.SpecificId == SpecificModifyData.SpecificId then
      return
    end
  end
  table.insert(self.NewUnlockSpecificModifyList, SpecificModifyData)
end

function IllustratedGuideData:AddSpecificUnlockAniMap(SpecificId)
  if not SpecificId then
    return
  end
  self.SpecificUnlockAniMap[tostring(SpecificId)] = true
end

return IllustratedGuideData
