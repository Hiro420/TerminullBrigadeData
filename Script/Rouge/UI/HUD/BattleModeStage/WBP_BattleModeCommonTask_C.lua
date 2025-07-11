local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_BattleModeCommonTask_C = UnLua.Class()
function WBP_BattleModeCommonTask_C:Construct()
end
function WBP_BattleModeCommonTask_C:OnDisplay(Param)
  self.Overridden.OnDisplay(self)
  self:PlayAnimation(self.TaskShowAni)
  if Param then
    self:RefreshInfo(Param.title, Param.content)
  else
    UIMgr:Hide(ViewID.UI_BattleModeCommonTask)
  end
end
function WBP_BattleModeCommonTask_C:RefreshInfo(TaskTitle, TaskText)
  self.TextBlock_Title:SetText(TaskTitle)
  self.RGTextBlock_TaskItemText:SetText(TaskText)
  self:PlayAnimation(self.TaskFlushAni)
end
function WBP_BattleModeCommonTask_C:OnAnimationFinished(anim)
  if anim == self.TaskShowAni then
  elseif anim == self.TaskFadeoutAni then
  end
end
return WBP_BattleModeCommonTask_C
