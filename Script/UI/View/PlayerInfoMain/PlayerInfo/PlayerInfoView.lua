local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local EscName = "PauseGame"
local PlayerInfoView = Class(ViewBase)
function PlayerInfoView:OnBindUIInput()
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  self.WBP_InteractTipWidgetChangeChar:BindInteractAndClickEvent(self, self.OnShowChangeHeroClick)
  self.WBP_InteractTipWidgetSetting:BindInteractAndClickEvent(self, self.OnShowExchangeInfoClick)
end
function PlayerInfoView:OnUnBindUIInput()
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetChangeChar:UnBindInteractAndClickEvent(self, self.OnShowChangeHeroClick)
  self.WBP_InteractTipWidgetSetting:UnBindInteractAndClickEvent(self, self.OnShowExchangeInfoClick)
end
function PlayerInfoView:OnRollback()
  if self.viewModel then
    local curShowHeroId = self.viewModel:GetCurShowHeroId()
    if curShowHeroId and curShowHeroId > 0 then
      local RoleActor = self:GetRoleActor()
      if RoleActor then
        RoleActor:SetActorHiddenInGame(false)
      end
    end
  end
end
function PlayerInfoView:BindClickHandler()
  self.BP_ButtonWithSoundCopyID.OnClicked:Add(self, self.OnCopyUserIdClick)
  self.BP_ButtonWithSoundShowExchangeInfo.OnClicked:Add(self, self.OnShowExchangeInfoClick)
  self.BP_ButtonWithSoundChangeHero.OnClicked:Add(self, self.OnShowChangeHeroClick)
  self.BP_ButtonWithSoundTipsMask.OnClicked:Add(self, self.OnHideTipsClick)
  self.BP_ButtonWithSoundChangeBadges.OnClicked:Add(self, self.OnShowChangeBadgesClick)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Add(self, self.ListenForEscInputAction)
  self.BP_ButtonReport.OnClicked:Add(self, self.Report)
end
function PlayerInfoView:UnBindClickHandler()
  self.BP_ButtonWithSoundCopyID.OnClicked:Remove(self, self.OnCopyUserIdClick)
  self.BP_ButtonWithSoundShowExchangeInfo.OnClicked:Remove(self, self.OnShowExchangeInfoClick)
  self.BP_ButtonWithSoundChangeHero.OnClicked:Remove(self, self.OnShowChangeHeroClick)
  self.BP_ButtonWithSoundTipsMask.OnClicked:Remove(self, self.OnHideTipsClick)
  self.BP_ButtonWithSoundChangeBadges.OnClicked:Remove(self, self.OnShowChangeBadgesClick)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Remove(self, self.ListenForEscInputAction)
  self.BP_ButtonReport.OnClicked:Remove(self, self.Report)
end
function PlayerInfoView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("PlayerInfoViewModel")
  self:BindClickHandler()
end
function PlayerInfoView:OnDestroy()
  self:UnBindClickHandler()
end
function PlayerInfoView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self:SetPlayerInfoViewEmpty()
  self.viewModel:RequestInfoPlayerInfo()
  LogicRole.ShowOrLoadLevel(-1)
  LogicRole.ShowSkinLightMap(LogicRole.GetHeroDefaultSkinId(self.viewModel:GetCurShowHeroId()))
  ChangeLobbyCamera(self, "PlayerInfo")
  LogicRole.ChangeRoleMainTransform("PlayerInfo")
  LogicRole.ShowOrHideRoleMainHero(true)
  self:InitModeDifficultLevelConfig()
  self:UpdateBaseInfo()
  self:UpdateTheRoleIdAchievement()
end
function PlayerInfoView:OnRollback()
  LogicRole.ShowOrLoadLevel(-1)
  LogicRole.ShowSkinLightMap(LogicRole.GetHeroDefaultSkinId(self.viewModel:GetCurShowHeroId()))
  ChangeLobbyCamera(self, "PlayerInfo")
  LogicRole.ChangeRoleMainTransform("PlayerInfo")
end
function PlayerInfoView:OnShowLink(LinkParams)
  local firstToggleIdx = 1
  if LinkParams:IsValidIndex(1) then
    firstToggleIdx = LinkParams:GetRef(1).IntParam
  end
  self.RGToggleGroupFirst:SelectId(firstToggleIdx)
  self.viewModel:SwitchLink(firstToggleIdx, LinkParams)
end
function PlayerInfoView:SetPlayerInfoViewEmpty()
  HideOtherItem(self.HorizontalBoxAchievementBadges, 1)
  HideOtherItem(self.ScrollBoxGameModeList, 1)
  UpdateVisibility(self.HorizontalBoxInfo, false)
end
function PlayerInfoView:UpdateBaseInfo()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  local bIsOwnerInfo = playerInfoMainVM:CheckIsOwnerInfo(roleID)
  UpdateVisibility(self.BP_ButtonReport, not bIsOwnerInfo, not bIsOwnerInfo)
  UpdateVisibility(self.BP_ButtonWithSoundChangeHero, bIsOwnerInfo)
  UpdateVisibility(self.BP_ButtonWithSoundShowExchangeInfo, bIsOwnerInfo)
  self.WBP_MonthCardIcon:Show(roleID, false, true)
  DataMgr.GetOrQueryPlayerInfo({roleID}, false, function(playerInfoList)
    if self and playerInfoList and playerInfoList[1] and playerInfoList[1].playerInfo then
      local playerInfo = playerInfoList[1].playerInfo
      self.RGTextName:SetText(DataMgr.GetPlayerNickNameById(tonumber(roleID)))
      self.RGTextLv:SetText(playerInfo.level)
      local tbBannerData = self.viewModel:GetTBBannerDataByBannerId(playerInfo.banner)
      if tbBannerData then
        self.ComBannerItem:InitComBannerItem(tbBannerData.bannerIconPathInInfo, tbBannerData.EffectPath)
      end
      local tbPortraitData = LogicLobby.GetPlayerPortraitTableRowInfo(playerInfo.portrait)
      self.ComPortraitItem:InitComPortraitItem(tbPortraitData.portraitIconPath, tbPortraitData.EffectPath)
    end
  end)
  local idStr = string.format("ID:%s", roleID)
  self.RGTextRoleId:SetText(idStr)
  if CheckIsVisility(self.WBP_PlayerInfoChangeHeadIconTips) then
    self.WBP_PlayerInfoChangeHeadIconTips:InitPlayerInfoChangeHeadIconTips()
  end
  if CheckIsVisility(self.WBP_PlayerInfoChangeBannerTips) then
    self.WBP_PlayerInfoChangeBannerTips:InitPlayerInfoChangeBannerTips()
  end
  if self.PlatformIconPanel then
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo PlayerInfoView roleID: %s", tostring(roleID)))
    self.PlatformIconPanel:UpdateChannelInfo(roleID)
  end
end
function PlayerInfoView:UpdateTheRoleIdAchievement()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  local achievementViewModelTemp = UIModelMgr:Get("AchievementViewModel")
  achievementViewModelTemp:RequestGetAchievementInfo(roleID, function(displayBadges, point)
    if self then
      self.RGTextAchievementDotNum:SetText(point)
      local displayBadgesCopy = DeepCopy(displayBadges)
      local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      table.sort(displayBadgesCopy, function(a, b)
        local numberA = tonumber(a)
        local numberB = tonumber(b)
        if (0 == numberA or 0 == numberB) and numberA ~= numberB then
          return numberA > 0
        end
        if tbGeneral and tbGeneral[numberA] and tbGeneral[numberB] then
          local rareA = tbGeneral[numberA].Rare
          local rareB = tbGeneral[numberB].Rare
          if rareA == rareB then
            return numberA > numberB
          else
            return rareA > rareB
          end
        end
        return numberA > numberB
      end)
      local achievementViewModel = UIModelMgr:Get("AchievementViewModel")
      for i = 1, achievementViewModel:GetMaxDisplayBadgesNum() do
        local v = displayBadgesCopy[i]
        local item = GetOrCreateItem(self.HorizontalBoxAchievementBadges, i, self.WBP_AchievePlayerInfoBadgesItem:GetClass())
        item:InitAchievePlayerInfoBadgesItem(v)
      end
      HideOtherItem(self.HorizontalBoxAchievementBadges, achievementViewModel:GetMaxDisplayBadgesNum() + 1)
    end
  end, false)
end
function PlayerInfoView:OnUpdateAchievementPoint(AchievementPoint)
  self.RGTextAchievementDotNum:SetText(AchievementPoint)
end
function PlayerInfoView:OnUpdateDisplayBadges(DisplayBadges)
  local achievementViewModel = UIModelMgr:Get("AchievementViewModel")
  local displayBadgesCopy = DeepCopy(DisplayBadges)
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  table.sort(displayBadgesCopy, function(a, b)
    local numberA = tonumber(a)
    local numberB = tonumber(b)
    if (0 == numberA or 0 == numberB) and numberA ~= numberB then
      return numberA > 0
    end
    if tbGeneral and tbGeneral[numberA] and tbGeneral[numberB] then
      local rareA = tbGeneral[numberA].Rare
      local rareB = tbGeneral[numberB].Rare
      if rareA == rareB then
        return numberA > numberB
      else
        return rareA > rareB
      end
    end
    return numberA > numberB
  end)
  for i = 1, achievementViewModel:GetMaxDisplayBadgesNum() do
    local v = displayBadgesCopy[i]
    local item = GetOrCreateItem(self.HorizontalBoxAchievementBadges, i, self.WBP_AchievePlayerInfoBadgesItem:GetClass())
    item:InitAchievePlayerInfoBadgesItem(v)
  end
  HideOtherItem(self.HorizontalBoxAchievementBadges, achievementViewModel:GetMaxDisplayBadgesNum() + 1)
end
function PlayerInfoView:UpdateGameplayInfo(BattleStatistic)
  UpdateVisibility(self.HorizontalBoxInfo, true)
  self.WBP_GamePlayerInfoItemDuration:InitGamePlayerInfoItem(BattleStatistic)
  self.WBP_GamePlayerInfoItemBattleCount:InitGamePlayerInfoItem(BattleStatistic)
  self.WBP_GamePlayerInfoItemWinCount:InitGamePlayerInfoItem(BattleStatistic)
  self.WBP_GamePlayerInfoItemDifficult:InitGamePlayerInfoItem(BattleStatistic)
  self.WBP_GamePlayerInfoItemDamage:InitGamePlayerInfoItem(BattleStatistic)
end
function PlayerInfoView:UpdateGamePlayerInfoItemDamage(HighestTotalHarm)
  UpdateVisibility(self.WBP_GamePlayerInfoItemDamage, true)
  local battleStatistic = {totalHarm = HighestTotalHarm}
  self.WBP_GamePlayerInfoItemDamage:InitGamePlayerInfoItem(battleStatistic)
end
function PlayerInfoView:InitModeDifficultLevelConfig()
  local AllLevels = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  self.AllLevelConfigList = {}
  for LevelID, LevelFloorInfo in pairs(AllLevels) do
    local TargetLevelList = self.AllLevelConfigList[LevelFloorInfo.gameWorldID]
    if TargetLevelList then
      TargetLevelList[LevelFloorInfo.floor] = LevelID
    else
      local Table = {}
      Table[LevelFloorInfo.floor] = LevelID
      self.AllLevelConfigList[LevelFloorInfo.gameWorldID] = Table
    end
  end
end
function PlayerInfoView:UpdateCanvasPanelGameMode(BattleStatistic)
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  local bIsOwner = playerInfoMainVM:CheckIsOwnerInfo(roleID)
  local AllLevelModeIdList = {}
  for ModeIndex, LevelFloorInfo in pairs(self.AllLevelConfigList) do
    local AResult, ARowInfo = GetRowData(DT.DT_GameMode, tostring(ModeIndex))
    if AResult and ARowInfo.bCanSelected then
      table.insert(AllLevelModeIdList, ModeIndex)
    end
  end
  table.sort(AllLevelModeIdList, function(A, B)
    local AResult, ARowInfo = GetRowData(DT.DT_GameMode, tostring(A))
    local BResult, BRowInfo = GetRowData(DT.DT_GameMode, tostring(B))
    local AMaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(A)
    local BMaxUnLockFloor = DataMgr.GetFloorByGameModeIndex(B)
    if AMaxUnLockFloor > 0 and BMaxUnLockFloor > 0 or not bIsOwner then
      if ARowInfo.Priority ~= BRowInfo.Priority then
        return ARowInfo.Priority > BRowInfo.Priority
      end
      return ARowInfo.Id < BRowInfo.Id
    elseif AMaxUnLockFloor <= 0 and BMaxUnLockFloor <= 0 then
      if ARowInfo.Priority ~= BRowInfo.Priority then
        return ARowInfo.Priority > BRowInfo.Priority
      end
      return ARowInfo.Id < BRowInfo.Id
    else
      return AMaxUnLockFloor > 0 and BMaxUnLockFloor <= 0
    end
  end)
  for i, v in ipairs(AllLevelModeIdList) do
    local statisticWorldInfo = BattleStatistic.worldStatistics[tostring(v)]
    local item = GetOrCreateItem(self.ScrollBoxGameModeList, i, self.WBP_PlayerInfoGameModeItem:GetClass())
    item:InitPlayerInfoGameModeItem(v, statisticWorldInfo, self.AllLevelConfigList[v], bIsOwner)
  end
  HideOtherItem(self.ScrollBoxGameModeList, #AllLevelModeIdList + 1)
end
function PlayerInfoView:OnGetPortraitIds(PortraitsIDs)
  if CheckIsVisility(self.WBP_PlayerInfoChangeHeadIconTips) then
    self.WBP_PlayerInfoChangeHeadIconTips:InitPlayerInfoChangeHeadIconTips()
  end
end
function PlayerInfoView:OnGetBannerIds(BannerIDs)
  if CheckIsVisility(self.WBP_PlayerInfoChangeBannerTips) then
    self.WBP_PlayerInfoChangeBannerTips:InitPlayerInfoChangeBannerTips()
  end
end
function PlayerInfoView:ShowChangeHeadIconTips(bIsShow)
  if bIsShow then
    self.viewModel:RequestGetPortraits()
    self.WBP_PlayerInfoChangeHeadIconTips:InitPlayerInfoChangeHeadIconTips()
  else
    self.WBP_PlayerInfoChangeHeadIconTips:Hide()
  end
end
function PlayerInfoView:ShowChangeBannerTips(bIsShow)
  if bIsShow then
    self.viewModel:RequestGetBanners()
    self.WBP_PlayerInfoChangeBannerTips:InitPlayerInfoChangeBannerTips()
  else
    self.WBP_PlayerInfoChangeBannerTips:Hide()
  end
end
function PlayerInfoView:ShowChangeBadgesTips(bIsShow)
  if bIsShow then
    self.WBP_AchievePlayerInfoBadgesTips:InitAchievePlayerInfoBadgesTips()
    self.WBP_AchievePlayerInfoBadgesTips:StopAnimation(self.WBP_AchievePlayerInfoBadgesTips.Ani_out)
    self.WBP_AchievePlayerInfoBadgesTips:PlayAnimation(self.WBP_AchievePlayerInfoBadgesTips.Ani_in)
  else
    self.WBP_AchievePlayerInfoBadgesTips:Hide()
  end
end
function PlayerInfoView:UpdateRole(HeroId)
  LogicRole.ShowSkinLightMap(LogicRole.GetHeroDefaultSkinId(HeroId))
  local RoleActor = self:GetRoleActor()
  if RoleActor then
    RoleActor:SetActorHiddenInGame(false)
    local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
    if CharacterRow then
      RoleActor.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
    end
    local changeRoleFunc = function()
      RoleActor:ChangeBodyMesh(HeroId, nil, nil, true)
      RoleActor:ChangeChildActorDefaultRotation(HeroId)
    end
    local TargetEquippedInfo = DataMgr.GetEquippedWeaponList(HeroId)
    if not TargetEquippedInfo then
      LogicOutsideWeapon.RequestEquippedWeaponInfo(HeroId, changeRoleFunc)
    else
      changeRoleFunc()
    end
  end
end
function PlayerInfoView:UpdateRoleByHeroInfo(HeroInfo, WeaponInfo)
  local HeroId = HeroInfo.id
  LogicRole.ShowSkinLightMap(LogicRole.GetHeroDefaultSkinId(HeroId))
  local RoleActor = self:GetRoleActor()
  if RoleActor then
    RoleActor:SetActorHiddenInGame(false)
    local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
    if CharacterRow then
      RoleActor.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
    end
    RoleActor:ChangeBodyMesh(HeroId, HeroInfo.skinId, nil, true)
    RoleActor:ChangeChildActorDefaultRotation(HeroId)
    RoleActor:ChangeWeaponMeshBySkinId(WeaponInfo.skin)
  end
end
function PlayerInfoView:GetRoleActor()
  if UE.RGUtil.IsUObjectValid(self.TargetRoleActor) then
    return self.TargetRoleActor
  end
  if not self.TargetRoleActor or not self.TargetRoleActor:IsValid() then
    local RoleActorList = UE.UGameplayStatics.GetAllActorsWithTag(self, "RoleMainHero", nil)
    for i, SingleRoleActor in pairs(RoleActorList) do
      self.TargetRoleActor = SingleRoleActor
      break
    end
  end
  return self.TargetRoleActor
end
function PlayerInfoView:ListenForEscInputAction()
  if CheckIsVisility(self.BP_ButtonWithSoundTipsMask) then
    self:OnHideTipsClick()
  else
    local playerInfoMainViewModel = UIModelMgr:Get("PlayerInfoMainViewModel")
    playerInfoMainViewModel:HidePlayerMainView()
  end
end
function PlayerInfoView:UpdateAchievePlayerInfoBadgesTips()
  if CheckIsVisility(self.WBP_AchievePlayerInfoBadgesTips) then
    self.WBP_AchievePlayerInfoBadgesTips:InitAchievePlayerInfoBadgesTips()
  end
end
function PlayerInfoView:OnPreHide()
  LogicRole.ShowOrHideRoleMainHero(false)
  local RoleActor = self:GetRoleActor()
  if RoleActor then
    RoleActor:SetActorHiddenInGame(true)
  end
  self.TargetRoleActor = nil
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  LogicRole.ShowOrLoadLevel(-1)
end
function PlayerInfoView:OnHide()
  self:OnHideTipsClick()
  LogicRole.ChangeRoleMainTransform("Default")
end
function PlayerInfoView:OnCopyUserIdClick()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  UE.URGBlueprintLibrary.CopyMessageToClipboard(tostring(roleID))
  ShowWaveWindow(1164)
end
function PlayerInfoView:OnShowExchangeInfoClick()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.INFORMATION_CHANGE) then
    return
  end
  if CheckIsVisility(self.WBP_PlayerInfoChangeTips) then
    self.WBP_PlayerInfoChangeTips:Hide()
  else
    self:ShowTipsMask()
    self.WBP_PlayerInfoChangeTips:InitPlayerInfoChangeTips(self)
  end
end
function PlayerInfoView:OnShowChangeHeroClick()
  if CheckIsVisility(self.WBP_PlayerInfoChangeHeroTips) then
    self.WBP_PlayerInfoChangeHeroTips:Hide()
  else
    self:ShowTipsMask()
    self.WBP_PlayerInfoChangeHeroTips:InitPlayerInfoChangeHeroTips()
  end
end
function PlayerInfoView:ShowTipsMask()
  UpdateVisibility(self.BP_ButtonWithSoundTipsMask, true, true)
end
function PlayerInfoView:OnShowChangeBadgesClick()
  self:ShowTipsMask()
  self.WBP_AchievePlayerInfoBadgesTips:InitAchievePlayerInfoBadgesTips()
end
function PlayerInfoView:OnHideTipsClick()
  UpdateVisibility(self.BP_ButtonWithSoundTipsMask, false)
  if CheckIsVisility(self.WBP_PlayerInfoChangeTips) then
    self.WBP_PlayerInfoChangeTips:Hide()
  end
  if CheckIsVisility(self.WBP_PlayerInfoChangeHeroTips) then
    self.WBP_PlayerInfoChangeHeroTips:Hide()
  end
  if CheckIsVisility(self.WBP_AchievePlayerInfoBadgesTips) then
    self.WBP_AchievePlayerInfoBadgesTips:Hide()
  end
  if CheckIsVisility(self.WBP_PlayerInfoChangeBannerTips) then
    self.WBP_PlayerInfoChangeBannerTips:Hide()
  end
  if CheckIsVisility(self.WBP_PlayerInfoChangeHeadIconTips) then
    self.WBP_PlayerInfoChangeHeadIconTips:Hide()
  end
end
function PlayerInfoView:Report()
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  WaveWindowManager:ShowWaveWindowWithDelegate(303009, {}, nil, {
    self,
    function()
      local Param = {
        category = 9,
        desc = "",
        language = 1,
        reason = {901},
        reportedContent = "",
        reportedRoleID = playerInfoMainVM:GetCurRoleID(),
        scene = 2
      }
      HttpCommunication.Request("diplomat/reportcheating", Param, {
        self,
        function(Target, JsonResponse)
          ShowWaveWindow(303010)
          print("\228\184\190\230\138\165\230\136\144\229\138\159")
          UIMgr:Hide(ViewID.UI_ReportView)
        end
      }, {
        self,
        function(Error)
          ShowWaveWindow(303011)
          print("\228\184\190\230\138\165\229\164\177\232\180\165", Error.Content)
        end
      })
    end
  }, {
    self,
    function()
    end
  })
end
return PlayerInfoView
