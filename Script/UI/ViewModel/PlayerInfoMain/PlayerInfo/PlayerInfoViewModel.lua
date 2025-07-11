local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local AchievementData = require("Modules.Achievement.AchievementData")
local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local PlayerInfoHandler = require("Protocol.PlayerInfo.PlayerInfoHandler")
local BattleHistoryHandler = require("Protocol.History.BattleHistoryHandler")
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local funcutil = require("Framework.Utils.FuncUtil")
local PlayerInfoConfig = require("GameConfig.PlayerInfo.PlayerInfoConfig")
local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
local PlayerInfoViewModel = CreateDefaultViewModel()
local SystemPromptIdList = {
  NickNameHasSensitiveWord = 1128,
  AccountNameHasChinese = 1086,
  IllegalAccountName = 1088,
  NonConformityAccountName = 1081,
  NonConformityNickNameLength = 1085,
  IllegalNickName = 1087,
  AccountBlocked = 30004,
  AccountBeKickedOut = 20001
}
PlayerInfoViewModel.propertyBindings = {}
PlayerInfoViewModel.subViewModels = {}
function PlayerInfoViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListenerNew(EventDef.Login.DataResetWhenLogin, self, self.OnDataResetWhenLogin)
  EventSystem.AddListenerNew(EventDef.Lobby.OnBasicInfoUpdated, self, self.OnBasicInfoUpdated)
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.OnMainTaskRefres)
  EventSystem.AddListenerNew(EventDef.Achievement.GetAchievementInfo, self, self.OnGetAchievementInfo)
  EventSystem.AddListenerNew(EventDef.Achievement.SetDisplayBadges, self, self.OnSetDisplayBadges)
  EventSystem.AddListenerNew(EventDef.PlayerInfo.GetBattleStatisticSucc, self, self.OnGetBattleStatisticSucc)
  EventSystem.AddListenerNew(EventDef.PlayerInfo.GetPortraitIds, self, self.OnGetPortraitIds)
  EventSystem.AddListenerNew(EventDef.PlayerInfo.GetBannerIds, self, self.OnGetBannerIds)
  EventSystem.AddListenerNew(EventDef.Lobby.OnSetNickFailed, self, self.OnSetNickFailed)
  EventSystem.AddListenerNew(EventDef.Lobby.OnSetNickSuccess, self, self.OnSetNickSuccess)
  EventSystem.AddListenerNew(EventDef.PlayerInfo.GetDisplayHeroInfo, self, self.OnGetDisplayHeroInfo)
end
function PlayerInfoViewModel:OnShutdown()
  EventSystem.AddListenerNew(EventDef.Login.DataResetWhenLogin, self, self.OnDataResetWhenLogin)
  EventSystem.RemoveListenerNew(EventDef.Lobby.OnBasicInfoUpdated, self, self.OnBasicInfoUpdated)
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.OnMainTaskRefres)
  EventSystem.RemoveListenerNew(EventDef.Achievement.GetAchievementInfo, self, self.OnGetAchievementInfo)
  EventSystem.RemoveListenerNew(EventDef.Achievement.SetDisplayBadges, self, self.OnSetDisplayBadges)
  EventSystem.RemoveListenerNew(EventDef.PlayerInfo.GetBattleStatisticSucc, self, self.OnGetBattleStatisticSucc)
  EventSystem.RemoveListenerNew(EventDef.PlayerInfo.GetPortraitIds, self, self.OnGetPortraitIds)
  EventSystem.RemoveListenerNew(EventDef.PlayerInfo.GetBannerIds, self, self.OnGetBannerIds)
  EventSystem.RemoveListenerNew(EventDef.Lobby.OnSetNickFailed, self, self.OnSetNickFailed)
  EventSystem.RemoveListenerNew(EventDef.Lobby.OnSetNickSuccess, self, self.OnSetNickSuccess)
  EventSystem.RemoveListenerNew(EventDef.PlayerInfo.GetDisplayHeroInfo, self, self.OnGetDisplayHeroInfo)
  self.Super.OnShutdown(self)
end
function PlayerInfoViewModel:RegisterPropertyChanged(BindingTable, View)
  self.Super.RegisterPropertyChanged(self, BindingTable, View)
end
function PlayerInfoViewModel:OnDataResetWhenLogin()
  PlayerInfoData:ResetWhenLogin()
end
function PlayerInfoViewModel:OnBasicInfoUpdated()
  if self:GetFirstView() then
    self:GetFirstView():UpdateBaseInfo()
  end
end
function PlayerInfoViewModel:OnMainTaskRefres()
  if self:GetFirstView() then
    local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
    local bIsOwnerInfo = playerInfoMainVM:CheckIsOwnerInfo(playerInfoMainVM:GetCurRoleID())
    if bIsOwnerInfo then
      local firstValue = AchievementData:GetCurAchievementPointNum()
      self:GetFirstView():OnUpdateAchievementPoint(firstValue)
    end
  end
end
function PlayerInfoViewModel:OnGetAchievementInfo()
  if self:GetFirstView() then
    local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
    local bIsOwnerInfo = playerInfoMainVM:CheckIsOwnerInfo(playerInfoMainVM:GetCurRoleID())
    if bIsOwnerInfo then
      self:GetFirstView():OnUpdateAchievementPoint(AchievementData:GetCurAchievementPointNum())
      local displayBadges = AchievementData:GetDisplayBadges()
      table.sort(displayBadges, function(A, B)
        local generalA = tbGeneral[A]
        local generalB = tbGeneral[B]
        if generalA.rare ~= generalB.rare then
          return generalA.rare > generalB.rare
        end
        return B < A
      end)
      self:GetFirstView():OnUpdateDisplayBadges(displayBadges)
    end
  end
end
function PlayerInfoViewModel:OnSetDisplayBadges()
  if self:GetFirstView() then
    local achievementViewModel = UIModelMgr:Get("AchievementViewModel")
    local displayBadges = achievementViewModel:GetDisplayBadges()
    table.sort(displayBadges, function(A, B)
      local generalA = tbGeneral[A]
      local generalB = tbGeneral[B]
      if generalA.rare ~= generalB.rare then
        return generalA.rare > generalB.rare
      end
      return B < A
    end)
    self:GetFirstView():OnUpdateDisplayBadges(displayBadges)
    self:GetFirstView():UpdateAchievePlayerInfoBadgesTips()
  end
end
function PlayerInfoViewModel:OnGetBattleStatisticSucc(BattleStatistic)
  if self:GetFirstView() then
    self:GetFirstView():UpdateGameplayInfo(BattleStatistic)
    self:GetFirstView():UpdateCanvasPanelGameMode(BattleStatistic)
  end
  local battleHistoryViewModel = UIModelMgr:Get("BattleHistoryViewModel")
  battleHistoryViewModel:OnGetBattleStatisticSucc(BattleStatistic)
end
function PlayerInfoViewModel:OnGetPortraitIds(PortraitIDs)
  if self:GetFirstView() then
    self:GetFirstView():OnGetPortraitIds(PortraitIDs)
  end
end
function PlayerInfoViewModel:OnGetBannerIds(BannerIDs)
  if self:GetFirstView() then
    self:GetFirstView():OnGetBannerIds(BannerIDs)
  end
end
function PlayerInfoViewModel:RequestInfoPlayerInfo()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  PlayerInfoHandler.RequestBattleStatistic(PlayerInfoConfig.PlayerInfoRequestModeIdList, roleID)
  PlayerInfoHandler.RequestGetDisplayHeroInfo(roleID)
  if playerInfoMainVM:CheckIsOwnerInfo() then
    local achievementViewModel = UIModelMgr:Get("AchievementViewModel")
    achievementViewModel:RequestGetAchievementInfo()
  end
end
function PlayerInfoViewModel:RequestGetBanners()
  PlayerInfoHandler.RequestGetBanners()
end
function PlayerInfoViewModel:RequestGetPortraits()
  PlayerInfoHandler.RequestGetPortraits()
end
function PlayerInfoViewModel:GetCurShowHeroId()
  return PlayerInfoData.CurShowHeroId
end
function PlayerInfoViewModel:GetCostItemList()
  return PlayerInfoData.CostItemList
end
function PlayerInfoViewModel:GetPortraitList()
  return PlayerInfoData:GetPortraitList()
end
function PlayerInfoViewModel:GetHeadIconState(portraitId)
  local tbPortraitData = LogicLobby.GetPlayerPortraitTableRowInfo(portraitId)
  if DataMgr.GetBasicInfo().portrait == portraitId then
    return EPlayerInfoEquipedState.Equiped
  elseif tbPortraitData and table.Contain(PlayerInfoData.PortraitIDs, tbPortraitData.portraitID) then
    return EPlayerInfoEquipedState.UnEquiped
  else
    return EPlayerInfoEquipedState.Lock
  end
end
function PlayerInfoViewModel:GetPortraitIdByResourceId(ResourceId)
  local tbPortrait = LuaTableMgr.GetLuaTableByName(TableNames.TBPortrait)
  if not tbPortrait or not tbPortrait[ResourceId] then
    return nil
  end
  return tbPortrait[ResourceId].portraitID
end
function PlayerInfoViewModel:GetOwnerPortraitList()
  return PlayerInfoData.PortraitIDs
end
function PlayerInfoViewModel:GetBannerState(bannerId)
  if DataMgr.GetBasicInfo().banner == bannerId then
    return EPlayerInfoEquipedState.Equiped
  elseif table.Contain(PlayerInfoData.BannerIDs, bannerId) or 0 == bannerId then
    return EPlayerInfoEquipedState.UnEquiped
  else
    return EPlayerInfoEquipedState.Lock
  end
end
function PlayerInfoViewModel:GetBannerIdByResourceId(ResourceId)
  local tbBanner = LuaTableMgr.GetLuaTableByName(TableNames.TBBanner)
  if not tbBanner or not tbBanner[ResourceId] then
    return nil
  end
  return tbBanner[ResourceId].bannerID
end
function PlayerInfoViewModel:GetTBBannerDataByBannerId(BannerId)
  if BannerId == PlayerInfoConfig.DefaultBannerInfo.bannerID then
    return PlayerInfoConfig.DefaultBannerInfo
  end
  return PlayerInfoData:GetTBBannerDataByBannerId(BannerId)
end
function PlayerInfoViewModel:GetBannerList()
  return PlayerInfoData:GetBannerList()
end
function PlayerInfoViewModel:GetOwnerBannerList()
  return PlayerInfoData.BannerIDs
end
function PlayerInfoViewModel:ChangePlayerInfoRoleDisplay(SelectId)
  if PlayerInfoData.CurShowHeroId == SelectId then
    if self:GetFirstView() then
      self:GetFirstView():UpdateRole(PlayerInfoData.CurShowHeroId)
    end
    return
  end
  PlayerInfoHandler.RequestSetDisplayHero(SelectId, function(HeroId)
    if -1 == HeroId then
      if -1 == PlayerInfoData.CurShowHeroId then
        PlayerInfoData.CurShowHeroId = DataMgr.GetMyHeroInfo().equipHero
      end
    else
      PlayerInfoData.CurShowHeroId = HeroId
    end
    if self:GetFirstView() then
      self:GetFirstView():UpdateRole(PlayerInfoData.CurShowHeroId)
    end
  end)
end
function PlayerInfoViewModel:RequestGetDisplayHeroInfo(RoleID)
  PlayerInfoHandler.RequestGetDisplayHeroInfo(RoleID)
end
function PlayerInfoViewModel:CheckIsSameName(NickName)
  local MyNickName = DataMgr.GetBasicInfo().nickname
  if MyNickName == NickName then
    return true
  end
  return false
end
function PlayerInfoViewModel:ConfirmChangeNickName()
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  self.waveWindow = nil
  self.waveWindow = WaveWindowManager:ShowWaveWindowWithDelegate(1158, {}, nil, {
    GameInstance,
    function()
      local notCloseWnd = true
      if not CheckCost(self:GetCostItemList()) then
        ShowWaveWindow(1166, {})
        return notCloseWnd
      end
      if self.waveWindow and self.waveWindow:GetNickName() then
        local loginViewModel = UIModelMgr:Get("LoginViewModel")
        if loginViewModel then
          local NickName = tostring(self.waveWindow:GetNickName())
          local HalfWidthStr = UE.URGBlueprintLibrary.ConvertFullWidthToHalfWidth(NickName)
          local bIsSame = self:CheckIsSameName(HalfWidthStr)
          if bIsSame then
            ShowWaveWindow(1199)
            return true
          end
          local bIsValid = loginViewModel:CheckNickNameIsVaild(HalfWidthStr)
          if bIsValid then
            PlayerInfoHandler.RequestSetNick(HalfWidthStr)
            notCloseWnd = false
          end
        end
      end
      return notCloseWnd
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function PlayerInfoViewModel:OnSetNickFailed()
end
function PlayerInfoViewModel:OnSetNickSuccess()
  if self.waveWindow then
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if RGWaveWindowManager then
      RGWaveWindowManager:CloseWaveWindow(self.waveWindow)
    end
  end
end
function PlayerInfoViewModel:OnGetDisplayHeroInfo(HeroInfo, WeaponInfo, RoleID)
  if self:GetFirstView() then
    self:GetFirstView():UpdateRoleByHeroInfo(HeroInfo, WeaponInfo)
  end
end
function PlayerInfoViewModel:OperatorHeadIcon(PortraitId)
  if self:GetHeadIconState(PortraitId) == EPlayerInfoEquipedState.UnEquiped then
    PlayerInfoHandler.RequestSetPortrait(PortraitId)
  elseif self:GetHeadIconState(PortraitId) == EPlayerInfoEquipedState.Lock then
  end
end
function PlayerInfoViewModel:OperatorBanner(BannerId)
  if self:GetBannerState(BannerId) == EPlayerInfoEquipedState.UnEquiped then
    PlayerInfoHandler.RequestSetBanner(BannerId)
  elseif self:GetBannerState(BannerId) == EPlayerInfoEquipedState.Lock then
  end
end
function PlayerInfoViewModel:ResetData()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  if PlayerInfoData.BattleStatistic[roleID] then
    PlayerInfoData.BattleStatistic[roleID] = nil
  end
end
function PlayerInfoViewModel:GetDefaultBannerPath()
  return PlayerInfoConfig.DefaultBannerInfo.bannerIconPathInInfo
end
function PlayerInfoViewModel:GetDefaultBannerInfo()
  return PlayerInfoConfig.DefaultBannerInfo
end
return PlayerInfoViewModel
