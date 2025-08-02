local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local DailyRewards = UnLua.Class()

function DailyRewards:Construct()
  self.MainBtn.OnClicked:Add(self, function()
    if ClimbTowerData.DailyRewardInfo ~= nil and nil ~= ClimbTowerData.DailyRewardInfo.rewardCount and ClimbTowerData.DailyRewardInfo.rewardCount > 0 then
      ClimbTowerData:ReceiveDailyReward()
      return
    end
    local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
    if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.DAILYREWARDS) then
      return
    end
    UIMgr:Show(ViewID.UI_DailyRewards, false)
  end)
  self.Btn_DailyRewards.OnClicked:Add(self, function()
  end)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnDailyRewardChange, self.OnRequestSuccess)
end

function DailyRewards:InitDailyRewards()
  ClimbTowerData:GetDailyRewardInfo(function(JsonTable)
    self:OnRequestSuccess(JsonTable)
  end)
  self:PlayAnimation(self.Ani_in)
end

function DailyRewards:OnRequestSuccess(JsonTable)
  if JsonTable then
    self.PointsAvailable:SetText(JsonTable.rewardCount)
    self.CumulativeSpeed:SetText(JsonTable.rewardRate)
    UpdateVisibility(self.CanvasPanel_Num, 0 ~= JsonTable.rewardCount)
    UpdateVisibility(self.in_hou, 0 ~= JsonTable.rewardCount)
    UpdateVisibility(self.in_qian, 0 ~= JsonTable.rewardCount)
    if 0 ~= JsonTable.rewardCount then
      self:PlayAnimation(self.Ani_loop, 0, 0)
    else
      self:StopAnimation(self.Ani_loop)
    end
  else
    self.PointsAvailable:SetText(ClimbTowerData.DailyRewardInfo.rewardCount)
    self.CumulativeSpeed:SetText(ClimbTowerData.DailyRewardInfo.rewardRate)
    UpdateVisibility(self.CanvasPanel_Num, 0 ~= ClimbTowerData.DailyRewardInfo.rewardCount)
    UpdateVisibility(self.in_hou, 0 ~= ClimbTowerData.DailyRewardInfo.rewardCount)
    UpdateVisibility(self.in_qian, 0 ~= ClimbTowerData.DailyRewardInfo.rewardCount)
    if 0 ~= ClimbTowerData.DailyRewardInfo.rewardCount then
      self:PlayAnimation(self.Ani_loop, 0, 0)
    else
      self:StopAnimation(self.Ani_loop)
    end
  end
end

return DailyRewards
