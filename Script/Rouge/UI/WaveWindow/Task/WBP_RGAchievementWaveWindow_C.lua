local AchievementData, AchievementItemData = require("Modules.Achievement.AchievementData")
local WBP_RGAchievementWaveWindow_C = UnLua.Class()

function WBP_RGAchievementWaveWindow_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_RGAchievementWaveWindow_C:SetWaveWindowParam(WaveWindowParamParam)
  local TaskGroup = WaveWindowParamParam.IntParam0
  local TaskId = WaveWindowParamParam.IntParam1
  self:Show(TaskGroup, TaskId)
end

function WBP_RGAchievementWaveWindow_C:Show(TaskGroup, TaskId)
  self:PlayAnimation(self.Ani_in)
  local fadeOutAniDuration = self.Ani_out:GetEndTime()
  local fadeOutStartTime = self.Info.Duration - fadeOutAniDuration
  self.DelayFadeOutHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.PlayAniFadeOut
  }, fadeOutStartTime, false)
  local bIsAchievementTask = AchievementData:CheckIsAchievementTask(TaskGroup)
  if not bIsAchievementTask then
    return
  end
  local tbTask = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskData)
  local tbTaskGroup = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  if tbTask and tbTask[TaskId] then
    self.RGTextAchievementName:SetText(tbTask[TaskId].name)
    self.RGTextDesc:SetText(tbTask[TaskId].content)
    SetImageBrushByPath(self.URGImageAchievementIcon, tbTask[TaskId].icon)
  end
  if tbTaskGroup and tbTaskGroup[TaskGroup] then
    local bhover = true
    for i, v in ipairs(tbTaskGroup[TaskGroup].tasklist) do
      local item = GetOrCreateItem(self.HorizontalBoxStep, i, self.WBP_RGAchievementStepWaveItem:GetClass())
      if bhover then
        item.RGStateControllerHover:ChangeStatus(EHover.Hover)
      else
        item.RGStateControllerHover:ChangeStatus(EHover.UnHover)
      end
      if v == TaskId then
        bhover = false
      end
    end
    HideOtherItem(self.HorizontalBoxStep, #tbTaskGroup[TaskGroup].tasklist + 1)
  end
end

function WBP_RGAchievementWaveWindow_C:PlayAniFadeOut()
  self:PlayAnimation(self.Ani_out)
end

function WBP_RGAchievementWaveWindow_C:K2_CloseWaveWindow()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayFadeOutHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.DelayFadeOutHandle)
    self.DelayFadeOutHandle = nil
  end
end

function WBP_RGAchievementWaveWindow_C:Destruct()
  self.Overridden.Destruct(self)
end

function WBP_RGAchievementWaveWindow_C:Hide()
end

return WBP_RGAchievementWaveWindow_C
