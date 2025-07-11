local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local rapidjson = require("rapidjson")
local UIUtil = require("Framework.UIMgr.UIUtil")
local LoginRewardActivityView = Class(ViewBase)
function LoginRewardActivityView:BindClickHandler()
end
function LoginRewardActivityView:UnBindClickHandler()
end
function LoginRewardActivityView:OnInit()
  self.DataBindTable = {
    {
      Source = "LoginTaskIdList",
      Callback = LoginRewardActivityView.OnLoginTaskIdListChanged
    }
  }
  self.viewModel = UIModelMgr:Get("LoginRewardActivityViewModel")
  self:BindClickHandler()
end
function LoginRewardActivityView:OnAnimationFinished(Animation)
  if self.Ani_out == Animation then
    UIMgr:Hide(ViewID.UI_LoginRewardActivity, self.bHideOther)
  end
end
function LoginRewardActivityView:OnDestroy()
  self:UnBindClickHandler()
end
function LoginRewardActivityView:ListenForEscInputAction()
  if self:IsAnimationPlaying(self.Ani_out) or self.Closeing then
    return
  end
  self:PlayAnimation(self.Ani_out)
  self.Closeing = true
end
function LoginRewardActivityView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  local params = {
    ...
  }
  self.viewModel:UpdateActivityId(params[1])
  self.ActivityId = params[1]
  self:PlayAnimation(self.Ani_in)
  self.Closeing = false
end
function LoginRewardActivityView:OnHide()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function LoginRewardActivityView:OnLoginTaskIdListChanged(LoginTaskIdList)
  if not LoginTaskIdList or LoginTaskIdList and 7 ~= #LoginTaskIdList then
    return
  end
  for i = 1, 7 do
    local Name = string.format("WBP_LoginRewardActivityItem_%s", tostring(i))
    if self[Name] then
      self[Name]:InitLoginRewardActivityItem(i, LoginTaskIdList[i], self.viewModel.TaskGroupId)
    end
  end
end
function LoginRewardActivityView:BindOnShowRule()
  UIMgr:Show(ViewID.UI_ActivityRuleDesc, false, self.ActivityId)
end
return LoginRewardActivityView
