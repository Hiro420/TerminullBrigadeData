local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local BattleHistoryData = require("Modules.PlayerInfoMain.History.BattleHistoryData")
local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local BattleHistoryHandler = require("Protocol.History.BattleHistoryHandler")
local BattleHistoryViewModel = CreateDefaultViewModel()
BattleHistoryViewModel.propertyBindings = {}
BattleHistoryViewModel.subViewModels = {}

function BattleHistoryViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListenerNew(EventDef.PlayerInfo.GetBattleHistory, self, self.OnGetBattleHistory)
end

function BattleHistoryViewModel:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.PlayerInfo.GetBattleHistory, self, self.OnGetBattleHistory)
  self.Super.OnShutdown(self)
end

function BattleHistoryViewModel:RegisterPropertyChanged(BindingTable, View)
  self.Super.RegisterPropertyChanged(self, BindingTable, View)
end

function BattleHistoryViewModel:SelectHeroId(HeroId, RoleID)
  local roleID = RoleID or DataMgr.GetUserId()
  local historyDatas = {}
  BattleHistoryData.CurSelectBattleHistoryHeroId = HeroId
  if self:GetFirstView() and BattleHistoryData.BattleHistory and BattleHistoryData.BattleHistory[roleID] and BattleHistoryData.BattleHistory[roleID].battleHistory then
    if HeroId == self:GetAllHeroSelectId() then
      for i, v in ipairs(BattleHistoryData.BattleHistory[roleID].recentBattleHistory) do
        table.insert(historyDatas, v)
      end
    else
      for i, v in ipairs(BattleHistoryData.BattleHistory[roleID].battleHistory) do
        if v.heroID == HeroId then
          historyDatas = BattleHistoryData.BattleHistory[roleID].battleHistory[i].battleHistoryDatas
          break
        end
      end
    end
    if HeroId == self:GetAllHeroSelectId() then
      self:GetFirstView():OnUpdateBattleHistory(historyDatas, HeroId)
      self:GetFirstView():OnUpdateAllHeroStatistics(PlayerInfoData.BattleStatistic[roleID], HeroId)
    else
      self:GetFirstView():OnUpdateBattleHistory(historyDatas, HeroId)
      self:GetFirstView():OnUpdateStatistics(self:GetHeroStatisticsByHeroId(HeroId, roleID), HeroId)
    end
  end
end

function BattleHistoryViewModel:ResetCurSelectHero()
  BattleHistoryData.CurSelectBattleHistoryHeroId = BattleHistoryData.AllHeroSelectId
end

function BattleHistoryViewModel:RequestGetBattleHistory()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  BattleHistoryHandler.RequestGetBattleHistory(roleID)
end

function BattleHistoryViewModel:GetCurSelectBattleHistoryHeroId()
  return BattleHistoryData.CurSelectBattleHistoryHeroId
end

function BattleHistoryViewModel:GetAllHeroSelectId()
  return BattleHistoryData.AllHeroSelectId
end

function BattleHistoryViewModel:GetHeroStatisticsByHeroId(HeroId, RoleID)
  local roleID = RoleID or DataMgr.GetUserId()
  return PlayerInfoData.BattleStatistic[roleID].heroStatistics[tostring(HeroId)]
end

function BattleHistoryViewModel:GetMostUsedHeroInfo()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  return PlayerInfoData:GetMostUsedHeroInfo(roleID)
end

function BattleHistoryViewModel:GetMostUsedWeaponIdByHeroId(HeroId)
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  return PlayerInfoData:GetMostUsedWeaponIdByHeroId(HeroId, roleID)
end

function BattleHistoryViewModel:OnGetBattleHistory(BattleHistory, RoleID)
  local roleID = RoleID or DataMgr.GetUserId()
  local HeroId = self:GetCurSelectBattleHistoryHeroId()
  local historyDatas = {}
  if self:GetFirstView() then
    if HeroId == self:GetAllHeroSelectId() then
      for i, v in ipairs(BattleHistory.recentBattleHistory) do
        table.insert(historyDatas, v)
      end
    else
      for i, v in ipairs(BattleHistory.battleHistory) do
        if v.heroID == self:GetCurSelectBattleHistoryHeroId() then
          historyDatas = BattleHistory.battleHistory[i].battleHistoryDatas
          break
        end
      end
    end
    self:GetFirstView():OnUpdateBattleHistory(historyDatas, self:GetCurSelectBattleHistoryHeroId())
    if HeroId == self:GetAllHeroSelectId() then
      self:GetFirstView():OnUpdateAllHeroStatistics(PlayerInfoData.BattleStatistic[roleID], HeroId)
    else
      self:GetFirstView():OnUpdateStatistics(self:GetHeroStatisticsByHeroId(HeroId, roleID), HeroId)
    end
  end
end

function BattleHistoryViewModel:OnGetBattleStatisticSucc(BattleStatistic, RoleID)
  if self:GetFirstView() then
    local roleID = RoleID or DataMgr.GetUserId()
    local HeroId = self:GetCurSelectBattleHistoryHeroId()
    if HeroId == self:GetAllHeroSelectId() then
      self:GetFirstView():OnUpdateAllHeroStatistics(PlayerInfoData.BattleStatistic[roleID], HeroId)
    else
      self:GetFirstView():OnUpdateStatistics(self:GetHeroStatisticsByHeroId(HeroId, roleID), HeroId)
    end
  end
end

function BattleHistoryViewModel:ResetData()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  if BattleHistoryData.BattleHistory[roleID] then
    BattleHistoryData.BattleHistory[roleID] = nil
  end
end

function BattleHistoryViewModel:SetCurHistoryData(HistoryData)
  self.HistoryData = HistoryData
end

function BattleHistoryViewModel:GetHistoryDataByRoleId(RoleId)
  if not self.HistoryData then
    return
  end
  for i, v in ipairs(self.HistoryData) do
    if tonumber(v.roleID) == tonumber(RoleId) then
      return v
    end
  end
  return nil
end

return BattleHistoryViewModel
