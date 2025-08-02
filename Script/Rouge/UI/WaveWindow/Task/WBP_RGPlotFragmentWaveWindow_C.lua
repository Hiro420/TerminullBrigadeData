local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_RGPlotFragmentWaveWindow_C = UnLua.Class()

function WBP_RGPlotFragmentWaveWindow_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_RGPlotFragmentWaveWindow_C:SetWaveWindowParam(WaveWindowParamParam)
  local TaskGroup = WaveWindowParamParam.IntParam0
  local TaskId = WaveWindowParamParam.IntParam1
  self:Show(TaskGroup, TaskId)
end

function WBP_RGPlotFragmentWaveWindow_C:Show(TaskGroup, TaskId)
  local FragmentInfo = IllustratedGuideData:GetPlotFragmentInfoByTaskId(TaskId)
  if FragmentInfo then
    self.RGTextAchievementName:SetText(FragmentInfo.title)
    SetImageBrushByPath(self.URGImageAchievementIcon, FragmentInfo.icon)
  end
end

function WBP_RGPlotFragmentWaveWindow_C:Destruct()
  self.Overridden.Destruct(self)
end

function WBP_RGPlotFragmentWaveWindow_C:Hide()
end

return WBP_RGPlotFragmentWaveWindow_C
