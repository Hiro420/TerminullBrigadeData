local RewardIncreaseModule = LuaClass()
local RewardIncreaseHandler = require("Protocol.RewardIncrease.RewardIncreaseHandler")
local RequestGap = 0.5

function RewardIncreaseModule:Ctor()
end

function RewardIncreaseModule:OnInit()
  print("RewardIncreaseModule:OnInit...........")
  EventSystem.AddListenerNew(EventDef.MonthCard.OnUpdateRolesMonthCardInfo, self, self.OnUpdateRolesMonthCardInfo)
end

function RewardIncreaseModule:OnShutdown()
  print("RewardIncreaseModule:OnShutdown...........")
  EventSystem.RemoveListenerNew(EventDef.MonthCard.OnUpdateRolesMonthCardInfo, self, self.OnUpdateRolesMonthCardInfo)
end

function RewardIncreaseModule:OnUpdateRolesMonthCardInfo(RoleIdList)
  for i, v in ipairs(RoleIdList) do
    if v == DataMgr.GetUserId() then
      print("RewardIncreaseModule:OnUpdateRolesMonthCardInfo")
      self:RequestGetRewardIncreaseCount(nil, true)
      break
    end
  end
end

function RewardIncreaseModule:RequestGetRewardIncreaseCount(TimeStamp, bForceRequest)
  if bForceRequest then
    RewardIncreaseHandler.RequestGetRewardIncreaseCount()
  elseif TimeStamp then
    if not self.PreTimeStamp then
      self.PreTimeStamp = 0
    end
    if TimeStamp - self.PreTimeStamp >= RequestGap then
      RewardIncreaseHandler.RequestGetRewardIncreaseCount()
    end
    self.PreTimeStamp = TimeStamp
  end
end

function RewardIncreaseModule:RequestReceiverewardIncrease()
  RewardIncreaseHandler.RequestReceiverewardIncrease()
end

return RewardIncreaseModule
