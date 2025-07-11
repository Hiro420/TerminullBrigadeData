local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local BattlePassHandler = require("Protocol.BattlePass.BattlePassHandler")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local BattlePassData = require("Modules.BattlePass.BattlePassData")
local TimeInterval = 1
local SendTime = 0
local BattlePassSubViewModel = CreateDefaultViewModel()
function BattlePassSubViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListenerNew(EventDef.BattlePass.GetBattlePassData, self, self.BindOnUpdateBattlePass)
  EventSystem.AddListenerNew(EventDef.BattlePass.ReceiveAllReward, self, self.BindOnReceiveAllReward)
  EventSystem.AddListenerNew(EventDef.BattlePass.ReceiveReward, self, self.BindOnReceiveReward)
  EventSystem.AddListenerNew(EventDef.WSMessage.ResourceUpdate, self, self.OnResourceUpdate)
end
function BattlePassSubViewModel:OnShutdown()
  self.Super.OnShutdown(self)
  EventSystem.RemoveListenerNew(EventDef.BattlePass.GetBattlePassData, self, self.BindOnUpdateBattlePass)
  EventSystem.RemoveAddListenerNew(EventDef.BattlePass.ReceiveAllReward, self, self.BindOnReceiveAllReward)
  EventSystem.RemoveAddListenerNew(EventDef.BattlePass.ReceiveReward, self, self.BindOnReceiveReward)
  EventSystem.RemoveListenerNew(EventDef.WSMessage.ResourceUpdate, self, self.OnResourceUpdate)
end
function BattlePassSubViewModel:SendGetBattlePassData(BattlePassID)
  self.BattlePassID = BattlePassID
  BattlePassHandler:SendBattlePassData(BattlePassID)
end
function BattlePassSubViewModel:SendReceiveAward(BattlePassID, Level)
  self.BattlePassID = BattlePassID
  if GetLocalTimestampByServerTimeZone() - SendTime >= TimeInterval then
    SendTime = GetLocalTimestampByServerTimeZone()
    BattlePassHandler:SendReceiveAward(BattlePassID, Level)
  end
end
function BattlePassSubViewModel:SendReceiveAllReward(BattlePassID)
  self.BattlePassID = BattlePassID
  if GetLocalTimestampByServerTimeZone() - SendTime >= TimeInterval then
    SendTime = GetLocalTimestampByServerTimeZone()
    BattlePassHandler:SendReceiveAllReward(BattlePassID)
  end
end
function BattlePassSubViewModel:BindOnUpdateBattlePass(BattlePassData)
  self.BattlePassState = BattlePassData.battlePassActivateState
  self.Level = BattlePassData.level
  self.exp = BattlePassData.exp
  local view = self:GetFirstView()
  if view then
    view:UpdateBattlePassData(BattlePassData)
  end
end
function BattlePassSubViewModel:BindOnReceiveAllReward(BattlePassID, AwardList)
  local view = self:GetFirstView()
  if view then
    view:ReceiveAllReward(AwardList)
  end
  self:SendGetBattlePassData(self.BattlePassID)
end
function BattlePassSubViewModel:BindOnReceiveReward(Level, AwardList)
  local view = self:GetFirstView()
  if view then
    view:ReceiveReward(Level, AwardList)
  end
end
function BattlePassSubViewModel:GetWeaponResIdBySkinId(SkinId)
  return SkinData.GetWeaponResIdBySkinResId(SkinId)
end
function BattlePassSubViewModel:CheckHaveDefaultWeaponInfo(CharacterID)
  local EquippedWeaponList = DataMgr.GetEquippedWeaponList(CharacterID)
  if not EquippedWeaponList then
    return false
  end
  local TargetWeaponInfo = EquippedWeaponList[1]
  if not TargetWeaponInfo then
    return false
  end
  return true
end
function BattlePassSubViewModel:GetVoiceDataByCommId(CommId)
  local CommunicationViewModel = UIModelMgr:Get("CommunicationViewModel")
  return CommunicationViewModel:GetVoiceDataByCommId(CommId)
end
function BattlePassSubViewModel:OnResourceUpdate(JsonStr)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local bNeedRequest = false
  local JsonTable = rapidjson.decode(JsonStr)
  if JsonTable.resources then
    for i, res in ipairs(JsonTable.resources) do
      local id = tonumber(res.id)
      if TotalResourceTable and TotalResourceTable[id] and 31 == TotalResourceTable[id].Type then
        bNeedRequest = true
      end
    end
  end
  if bNeedRequest then
    self:SendGetBattlePassData(self.BattlePassID)
  end
end
return BattlePassSubViewModel
