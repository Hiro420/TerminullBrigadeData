local WBP_RGProfyWaveWindow_C = UnLua.Class()
function WBP_RGProfyWaveWindow_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_RGProfyWaveWindow_C:SetWaveWindowParam(WaveWindowParamParam)
  local TaskGroup = WaveWindowParamParam.IntParam0
  local TaskId = WaveWindowParamParam.IntParam1
  local HeroId = WaveWindowParamParam.IntParam2
  self:Show(TaskGroup, TaskId, HeroId)
end
function WBP_RGProfyWaveWindow_C:Show(TaskGroup, TaskId, HeroId)
  local tbTask = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  if tbTask and tbTask[TaskId] then
    self.RGTextDesc:SetText(tbTask[TaskId].content)
  end
  local tbHeroMonsterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if tbHeroMonsterTable and tbHeroMonsterTable[HeroId] then
    SetImageBrushByPath(self.URGImageHeroIcon, tbHeroMonsterTable[HeroId].ActorIcon)
  end
end
function WBP_RGProfyWaveWindow_C:Destruct()
  self.Overridden.Destruct(self)
end
function WBP_RGProfyWaveWindow_C:Hide()
end
return WBP_RGProfyWaveWindow_C
