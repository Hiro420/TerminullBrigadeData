local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local rapidjson = require("rapidjson")
local UIUtil = require("Framework.UIMgr.UIUtil")
local LoginRewardsView = Class(ViewBase)

function LoginRewardsView:BindClickHandler()
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, LoginRewardsView.ListenForEscInputAction)
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    LoginRewardsView.ListenForEscInputAction
  })
end

function LoginRewardsView:UnBindClickHandler()
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, LoginRewardsView.ListenForEscInputAction)
  StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
end

function LoginRewardsView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("LoginRewardsViewModel")
  self:BindClickHandler()
end

function LoginRewardsView:OnAnimationFinished(Animation)
  if self.Ani_out == Animation then
    UIMgr:Hide(ViewID.UI_LoginRewards, self.bHideOther)
  end
end

function LoginRewardsView:OnDestroy()
  self:UnBindClickHandler()
end

function LoginRewardsView:ListenForEscInputAction()
  if self:IsAnimationPlaying(self.Ani_out) or self.Closeing then
    return
  end
  self:PlayAnimation(self.Ani_out)
  self.Closeing = true
  for i = 1, 7 do
    local Name = string.format("WBP_LoginRewards_Item_%s", tostring(i))
    if self[Name] then
      self[Name]:CloseAnim()
    end
  end
end

function LoginRewardsView:OnShow(bAuto)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self:PlayAnimation(self.Ani_in)
  self.Closeing = false
  self:InitShowTime()
  for i = 1, 7 do
    local Name = string.format("WBP_LoginRewards_Item_%s", tostring(i))
    if self[Name] then
      self[Name]:InitLoginRewardsItem(i, table.Contain(self.viewModel.Rewards, i))
    end
  end
end

function LoginRewardsView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function LoginRewardsView:InitShowTime()
  local ServerOpenTime = DataMgr:GetServerOpenTime()
  local StartString = os.date("%Y/%m/%d", ServerOpenTime)
  local EndTime = os.date("%m/%d", ServerOpenTime + 604800)
  self.RGTextBlock_Time:SetText(StartString .. " - " .. EndTime)
end

return LoginRewardsView
