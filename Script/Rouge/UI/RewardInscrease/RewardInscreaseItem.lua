local RewardInscreaseItem = UnLua.Class()

function RewardInscreaseItem:Construct()
  self.Overridden.Construct(self)
  self.StateCtrl_State:ChangeStatus("DisActive")
  self.ServerTimeZone = DataMgr.GetServerTimeZone()
  EventSystem.AddListenerNew(EventDef.RewardIncrease.RewardIncreaseSucc, self, self.OnRewardIncrease)
  self:OnRewardIncrease()
end

function RewardInscreaseItem:Destruct()
  EventSystem.RemoveListenerNew(EventDef.RewardIncrease.RewardIncreaseSucc, self, self.OnRewardIncrease)
  if self.TipsWidget then
    UpdateVisibility(self.TipsWidget, false)
  end
  self.TipsWidget = nil
  self.Overridden.Destruct(self)
end

function RewardInscreaseItem:OnRewardIncrease()
  local rewardIncreaseCount = DataMgr.GetRewardIncreaseCount()
  self.Txt_LeftNum:SetText(rewardIncreaseCount)
  if IsValidObj(self.TipsWidget) and CheckIsVisility(self.TipsWidget) then
    self.TipsWidget.Text_SecTitleNum:SetText(rewardIncreaseCount)
  end
  if rewardIncreaseCount > 0 then
    self.StateCtrl_State:ChangeStatus("Active")
  else
    self.StateCtrl_State:ChangeStatus("DisActive")
  end
end

function RewardInscreaseItem:BP_RefreshTime(UnixTimestampNowParam)
  local RewardIncreaseModule = ModuleManager:Get("RewardIncreaseModule")
  RewardIncreaseModule:RequestGetRewardIncreaseCount(UnixTimestampNowParam)
end

function RewardInscreaseItem:BP_ServerTimeZone()
  return DataMgr.GetServerTimeZone()
end

function RewardInscreaseItem:OnMouseEnter()
  local classPath = "/Game/Rouge/UI/RewardIncrease/WBP_RewardInscreaseTips.WBP_RewardInscreaseTips"
  self.TipsWidget = ShowCommonTips(nil, self.Btn_Hover, self.TipsWidget, classPath, false, false, UE.FVector2D(-10, 0))
  if IsValidObj(self.TipsWidget) then
    self:UpdateCountDown()
    self.TipsWidget.Text_SecTitleNum:SetText(DataMgr.GetRewardIncreaseCount())
  end
end

function RewardInscreaseItem:OnMouseLeave()
  UpdateVisibility(self.TipsWidget, false)
end

return RewardInscreaseItem
