require("Rouge.UI.Lobby.Logic.Logic_Team")
local BattleLagacyModule = LuaClass()
local rapidjson = require("rapidjson")
local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local BattleLagacyHandler = require("Protocol.BattleLagacy.BattleLagacyHandler")
local Max_Request_Num = 5
local CurLagacyRequestNum = 0
local CurLagacyListRequestNum = 0

function BattleLagacyModule:Ctor()
end

function BattleLagacyModule:OnInit()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("BattleLagacyModule:OnInit...........")
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnGetBattleLagacyList, self, self.OnGetBattleLagacyList)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnGetCurrBattleLagacy, self, self.OnGetCurrBattleLagacy)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnGetBattleLagacyListFailed, self, self.OnGetBattleLagacyListFailed)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnGetCurrBattleLagacyFailed, self, self.OnGetCurrBattleLagacyFailed)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnSelectBattleLagacy, self, self.OnSelectBattleLagacy)
end

function BattleLagacyModule:OnShutdown()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("BattleLagacyModule:OnShutdown...........")
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnGetBattleLagacyList, self, self.OnGetBattleLagacyList)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnGetCurrBattleLagacy, self, self.OnGetCurrBattleLagacy)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnGetBattleLagacyListFailed, self, self.OnGetBattleLagacyListFailed)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnGetCurrBattleLagacyFailed, self, self.OnGetCurrBattleLagacyFailed)
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnSelectBattleLagacy, self, self.OnSelectBattleLagacy)
end

function BattleLagacyModule:Reset()
  CurLagacyRequestNum = 0
  CurLagacyListRequestNum = 0
  ModuleManager:Get("BattleLagacyModule").BattleLagacyList = {}
  print("BattleLagacyModule:Reset")
  BattleLagacyData.CurBattleLagacyData = {
    BattleLagacyType = EBattleLagacyType.Inscription,
    BattleLagacyId = "0"
  }
end

function BattleLagacyModule:UpdateBattleLagacyList(BattleLagacyList)
  self.BattleLagacyList = BattleLagacyList
  EventSystem.Invoke(EventDef.BattleLagacy.OnTriggerBattleLagacyList, BattleLagacyList)
end

function BattleLagacyModule:UpdateCurBattleLagacyData(BattleLagacyID, BattleLagacyType)
  BattleLagacyData.CurBattleLagacyData.BattleLagacyId = BattleLagacyID
  BattleLagacyData.CurBattleLagacyData.BattleLagacyType = BattleLagacyType
  EventSystem.Invoke(EventDef.BattleLagacy.OnTriggerCurrBattleLagacy, BattleLagacyData.CurBattleLagacyData)
end

function BattleLagacyModule:OnGetBattleLagacyList(BattleLagacyList)
  if #BattleLagacyList <= 0 then
    if BattleLagacyData.CurBattleLagacyData.BattleLagacyId == nil or BattleLagacyData.CurBattleLagacyData.BattleLagacyId == "0" then
      if CurLagacyListRequestNum < Max_Request_Num then
        self:GetBattleLagacyList()
        CurLagacyListRequestNum = CurLagacyListRequestNum + 1
        print(string.format("BattleLagacyModule:OnGetBattleLagacyList \231\172\172%d\230\172\161\232\175\183\230\177\130", CurLagacyListRequestNum))
      else
        print("BattleLagacyModule:OnGetBattleLagacyList Request had Over Max Request Num")
        EventSystem.Invoke(EventDef.BattleLagacy.OnGetBattleLagacyListOverMaxRequestNum)
      end
    end
  else
    for i, v in ipairs(BattleLagacyList) do
      print("BattleLagacyModule:OnGetBattleLagacyList BattleLagacyList", i, v)
    end
    self.BattleLagacyList = BattleLagacyList
    EventSystem.Invoke(EventDef.BattleLagacy.OnTriggerBattleLagacyList, BattleLagacyList)
  end
end

function BattleLagacyModule:OnGetBattleLagacyListFailed()
  if (BattleLagacyData.CurBattleLagacyData.BattleLagacyId == nil or BattleLagacyData.CurBattleLagacyData.BattleLagacyId == "0") and table.IsEmpty(self.BattleLagacyList) then
    if CurLagacyListRequestNum < Max_Request_Num then
      self:GetBattleLagacyList()
      CurLagacyListRequestNum = CurLagacyListRequestNum + 1
      print(string.format("BattleLagacyModule:OnGetBattleLagacyListFailed \231\172\172%d\230\172\161\232\175\183\230\177\130", CurLagacyListRequestNum))
    else
      print("BattleLagacyModule:OnGetBattleLagacyListFailed Request had Over Max Request Num")
      EventSystem.Invoke(EventDef.BattleLagacy.OnGetBattleLagacyListOverMaxRequestNum)
    end
  else
    print("BattleLagacyModule:OnGetBattleLagacyListFailed CurBattleLagacyData Had Not nil")
  end
end

function BattleLagacyModule:OnGetCurrBattleLagacy(BattleLagacyID, BattleLagacyType)
end

function BattleLagacyModule:OnGetCurrBattleLagacyFailed()
end

function BattleLagacyModule:OnSelectBattleLagacy(Idx, SelectId)
  self:UpdateCurBattleLagacyData(SelectId, EBattleLagacyType.GeneircModify)
end

function BattleLagacyModule:AddGenericModifyByBattleLagacy(Idx, SelectId)
  BattleLagacyHandler:AddGenericModifyByBattleLagacy(Idx, SelectId)
end

function BattleLagacyModule:GetBattleLagacyList()
  BattleLagacyHandler:GetBattleLagacyList()
end

function BattleLagacyModule:GetCurrBattleLagacy()
  BattleLagacyHandler:GetCurrBattleLagacy()
end

function BattleLagacyModule:GetCurrBattleLagacyLogin()
  BattleLagacyHandler:GetCurrBattleLagacyLogin()
end

function BattleLagacyModule:Setbattlelagacylist()
  BattleLagacyHandler:Setbattlelagacylist()
end

function BattleLagacyModule:CheckBattleLagacyIsActive()
  if BattleLagacyData.CurBattleLagacyData == nil then
    return false
  end
  if BattleLagacyData.CurBattleLagacyData.BattleLagacyId == "0" then
    return false
  end
  local floor = LogicTeam.GetFloor()
  if floor and floor <= UE.URGMatchSettings.GetSettings().MaxDifficultId then
    return false
  end
  return true
end

return BattleLagacyModule
