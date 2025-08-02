local RedDotModule = LuaClass()
local rapidjson = require("rapidjson")
local RedDotData = require("Modules.RedDot.RedDotData")
local MailHandler = require("Protocol.Mail.MailHandler")
local MailData = require("Modules.Mail.MailData")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local IllustratedGuideHandler = require("Protocol.IllustratedGuide.IllustratedGuideHandler")
local ChipData = require("Modules.Chip.ChipData")
local AchievementData = require("Modules.Achievement.AchievementData")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local climbtowerdata = require("UI.View.ClimbTower.ClimbTowerData")
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")
local LocalRedDotDataFilePath

function RedDotModule:Ctor()
end

function RedDotModule:OnInit()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("RedDotModule:OnInit...........")
  RedDotData:Init()
  IllustratedGuideData:Init()
  EventSystem.AddListenerNew(EventDef.BeginnerGuide.OnLobbyShow, self, self.BindOnLobbyShow)
  EventSystem.AddListenerNew(EventDef.Mail.OnUpdateAllMailListInfo, self, self.BindOnUpdateAllMailListInfo)
  EventSystem.AddListenerNew(EventDef.Login.OnLoginProtocolSuccess, self, self.BindOnLoginProtocolSuccess)
  EventSystem.AddListenerNew(EventDef.BeginnerGuide.OnGetFinishedGuideList, self, self.BindOnFinishedGuideListChange)
  EventSystem.AddListenerNew(EventDef.ContactPerson.OnFriendApplyListUpdate, self, self.BindOnFriendApplyListUpdate)
  EventSystem.AddListenerNew(EventDef.ContactPerson.OnPersonalChatInfoUpdate, self, self.BindOnPersonalChatInfoUpdate)
  EventSystem.AddListenerNew(EventDef.Lobby.OnUpdateGameFloorInfo, self, self.BindOnUpdateGameFloorInfo)
  EventSystem.AddListenerNew(EventDef.Heirloom.OnHeirloomInfoChanged, self, self.BindOnHeirloomInfoChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateResourceInfo, self, self.BindOnUpdateResourceInfo)
  EventSystem.AddListenerNew(EventDef.WSMessage.ResourceUpdate, self, self.OnResourceUpdate)
  EventSystem.AddListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.BindOnGetHeroSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.BindOnGetWeaponSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnHeroSkinUpdate, self, self.BindOnGetHeroSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnWeaponSkinUpdate, self, self.BindOnGetWeaponSkinList)
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnRefreshBattlePassTask)
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnRefreshPlotFragment)
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnRefreshAchievement)
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnMainTaskRefresh)
  EventSystem.AddListenerNew(EventDef.Pandora.pandoraActCenterRedpoint, self, self.BindPandoraActCenterRedpoint)
  EventSystem.AddListenerNew(EventDef.RuleTask.OnMainRewardStateChanged, self, self.BindOnMainRewardStateChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.WeaponListChanged, self, self.BindOnWeaponListChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateCommonTalentInfo, self, self.BindOnUpdateCommonTalentInfo)
  EventSystem.AddListenerNew(EventDef.IllustratedGuide.OnUpdateAllSpecificModifyInfo, self, self.BindOnUpdateAllSpecificModifyInfo)
  EventSystem.AddListenerNew(EventDef.Chip.GetHeroChipBag, self, self.BindOnGetHeroChipBag)
  EventSystem.AddListenerNew(EventDef.Chip.AddChip, self, self.BindOnGetHeroChipBag)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.BindOnUpdateMyHeroInfo)
  EventSystem.AddListenerNew(EventDef.Communication.OnGetCommList, self, self.BindOnGetCommList)
  EventSystem.AddListenerNew(EventDef.BattlePass.GetBattlePassData, self, self.BindOnGetBattlePassData)
  EventSystem.AddListenerNew(EventDef.ClimbTowerView.OnDailyRewardChange, self, self.BindOnDailyRewardChange)
  EventSystem.AddListenerNew(EventDef.ClimbTowerView.OnPassRewardStatusChange, self, self.BindOnPassRewardStatusChange)
end

function RedDotModule:OnShutdown()
  if UE.RGUtil.IsDedicatedServer() then
    return
  end
  print("RedDotModule:OnShutdown...........")
  self:GlobalStopAnimation()
  self:StopCheckNeedSaveToFileTimer()
  EventSystem.RemoveListenerNew(EventDef.BeginnerGuide.OnLobbyShow, self, self.BindOnLobbyShow)
  EventSystem.RemoveListenerNew(EventDef.Mail.OnUpdateAllMailListInfo, self, self.BindOnUpdateAllMailListInfo)
  EventSystem.RemoveListenerNew(EventDef.Login.OnLoginProtocolSuccess, self, self.BindOnLoginProtocolSuccess)
  EventSystem.RemoveListenerNew(EventDef.BeginnerGuide.OnGetFinishedGuideList, self, self.BindOnFinishedGuideListChange)
  EventSystem.RemoveListenerNew(EventDef.ContactPerson.OnFriendApplyListUpdate, self, self.BindOnFriendApplyListUpdate)
  EventSystem.RemoveListenerNew(EventDef.ContactPerson.OnPersonalChatInfoUpdate, self, self.BindOnPersonalChatInfoUpdate)
  EventSystem.RemoveListenerNew(EventDef.Lobby.OnUpdateGameFloorInfo, self, self.BindOnUpdateGameFloorInfo)
  EventSystem.RemoveListenerNew(EventDef.Heirloom.OnHeirloomInfoChanged, self, self.BindOnHeirloomInfoChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateResourceInfo, self, self.BindOnUpdateResourceInfo)
  EventSystem.RemoveListenerNew(EventDef.WSMessage.ResourceUpdate, self, self.OnResourceUpdate)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.BindOnGetHeroSkinList)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.BindOnGetWeaponSkinList)
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnRefreshBattlePassTask)
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnRefreshPlotFragment)
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnRefreshAchievement)
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnMainTaskRefresh)
  EventSystem.RemoveListenerNew(EventDef.Pandora.pandoraActCenterRedpoint, self, self.BindPandoraActCenterRedpoint)
  EventSystem.RemoveListenerNew(EventDef.RuleTask.OnMainRewardStateChanged, self, self.BindOnMainRewardStateChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.WeaponListChanged, self, self.BindOnWeaponListChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateCommonTalentInfo, self, self.BindOnUpdateCommonTalentInfo)
  EventSystem.RemoveListenerNew(EventDef.IllustratedGuide.OnUpdateAllSpecificModifyInfo, self, self.BindOnUpdateAllSpecificModifyInfo)
  EventSystem.RemoveListenerNew(EventDef.Chip.GetHeroChipBag, self, self.BindOnGetHeroChipBag)
  EventSystem.RemoveListenerNew(EventDef.Chip.AddChip, self, self.BindOnGetHeroChipBag)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.BindOnUpdateMyHeroInfo)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnGetCommList, self, self.BindOnGetCommList)
  EventSystem.RemoveListenerNew(EventDef.BattlePass.GetBattlePassData, self, self.BindOnGetBattlePassData)
  EventSystem.RemoveListenerNew(EventDef.ClimbTowerView.OnDailyRewardChange, self, self.BindOnDailyRewardChange)
  EventSystem.RemoveListenerNew(EventDef.ClimbTowerView.OnPassRewardStatusChange, self, self.BindOnPassRewardStatusChange)
  self:SaveRedDotDataToLocal()
end

function RedDotModule:SaveRedDotDataToLocal()
  local RedDotNumList = {}
  for k, v in pairs(RedDotData.RedDotList) do
    if v.IsCacheEnable then
      RedDotNumList[k] = {}
      RedDotNumList[k].Num = v.Num
      RedDotNumList[k].Class = v.Class
      RedDotNumList[k].IsLeaf = v.IsLeaf
      RedDotNumList[k].IsActive = v.IsActive
    end
  end
  local RedDotNumListJson = RapidJsonEncode(RedDotNumList)
  if LocalRedDotDataFilePath then
    UE.URGBlueprintLibrary.SaveStringToFile(LocalRedDotDataFilePath, RedDotNumListJson)
  end
end

function RedDotModule:GlobalStartAnimation()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RedDotAnimationLoopTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.RedDotAnimationLoopTimer)
  end
  self.RedDotAnimationLoopTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    self.InvokeEventOnPlayOnceAnimation
  }, 3.1, true)
end

function RedDotModule:GlobalStopAnimation()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RedDotAnimationLoopTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.RedDotAnimationLoopTimer)
  end
end

function RedDotModule:StartCheckNeedSaveToFileTimer()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RedDotSaveToFileTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.RedDotSaveToFileTimer)
  end
  self.RedDotSaveToFileTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    self.CheckNeedSaveToFile
  }, 5, true)
end

function RedDotModule:StopCheckNeedSaveToFileTimer()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RedDotSaveToFileTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.RedDotSaveToFileTimer)
  end
end

function RedDotModule:CheckNeedSaveToFile()
  if RedDotData.bIsNeedSaveToFile then
    RedDotModule:SaveRedDotDataToLocal()
    RedDotData.bIsNeedSaveToFile = false
    print("ywtao, RedDotModule:CheckNeedSaveToFile true")
  else
    print("ywtao, RedDotModule:CheckNeedSaveToFile false")
  end
end

function RedDotModule:InvokeEventOnPlayOnceAnimation()
  EventSystem.Invoke(EventDef.RedDot.OnPlayOnceAnimation)
end

function RedDotModule:BindOnLobbyShow()
end

function RedDotModule:BindOnUpdateAllMailListInfo()
  local AllMailInfoList = MailData:GetAllMailInfoList()
  for MailId, value in pairs(AllMailInfoList) do
    local RedDotId = "Mail_SingleItem_" .. MailId
    local IsNewCreate = RedDotData:CreateRedDotState(RedDotId, "Mail_SingleItem")
    if IsNewCreate then
      local RedDotState = {}
      if value.IsHaveAttachment then
        RedDotState.IsStubborn = true
        if value.IsReceiveAttachment then
          RedDotState.Num = 0
        else
          RedDotState.Num = 1
        end
      else
        RedDotState.IsStubborn = false
        if value.readStatus == EMailReadStatus.UnRead then
          RedDotState.Num = 1
        else
          RedDotState.Num = 0
        end
      end
      RedDotData:UpdateRedDotState(RedDotId, RedDotState)
    end
  end
end

function RedDotModule:BindOnLoginProtocolSuccess()
  LocalRedDotDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/RedDot/RedDotData_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalRedDotDataFilePath)
  if Result then
    local LocalFileRedDotList = rapidjson.decode(FileStr)
    for k, v in pairs(LocalFileRedDotList) do
      if v.IsLeaf then
        if RedDotData:GetRedDotRawDef(v.Class) then
          RedDotData:CreateRedDotState(k, v.Class)
          RedDotData:SetRedDotNum(k, v.Num)
        else
          UnLua.LogWarn("ywtao\239\188\140\229\138\160\232\189\189\231\186\162\231\130\185\231\188\147\229\173\152\229\164\177\232\180\165\239\188\129\231\186\162\231\130\185\231\177\187\228\184\141\229\173\152\229\156\168\239\188\140\231\177\187\229\144\141:" .. tostring(v.Class))
        end
      end
    end
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      RedDotModule.LoadParentRedDotActive
    }, 2, false)
  else
    RedDotModule:StartCheckNeedSaveToFileTimer()
  end
  self:GlobalStartAnimation()
end

function RedDotModule:LoadParentRedDotActive()
  LocalRedDotDataFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/RedDot/RedDotData_" .. DataMgr.GetUserId() .. ".json"
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalRedDotDataFilePath)
  if Result then
    local LocalFileRedDotList = rapidjson.decode(FileStr)
    for k, v in pairs(LocalFileRedDotList) do
      if not v.IsLeaf then
        if RedDotData:GetRedDotRawDef(v.Class) then
          local RedDotState = RedDotData:GetRedDotState(k)
          if RedDotState and RedDotState.Num == v.Num and RedDotState.IsActive ~= v.IsActive then
            RedDotData:UpdateRedDotState(k, {
              IsActive = v.IsActive
            })
          end
        else
          UnLua.LogWarn("ywtao\239\188\140\229\138\160\232\189\189\231\186\162\231\130\185\231\188\147\229\173\152\229\164\177\232\180\165\239\188\129\231\186\162\231\130\185\231\177\187\228\184\141\229\173\152\229\156\168\239\188\140\231\177\187\229\144\141:" .. tostring(v.Class))
        end
      end
    end
  end
  RedDotModule:StartCheckNeedSaveToFileTimer()
end

function RedDotModule:BindOnFinishedGuideListChange()
  local GuideBookActiveItemList = BeginnerGuideData:GetGuideBookActiveItemList()
  for k, GuideInfo in pairs(GuideBookActiveItemList) do
    local RedDotId = "Learn_Gameplay_Num_" .. GuideInfo.id
    local IsNewCreate = RedDotData:CreateRedDotState(RedDotId, "Learn_Gameplay_Num")
    local RedDotState = {}
    if IsNewCreate then
      RedDotState.Num = 1
    end
    RedDotState.ParentIdList = {
      "Learn_Gameplay_" .. GuideInfo.type
    }
    RedDotData:CreateRedDotState("Learn_Gameplay_" .. GuideInfo.type, "Learn_Gameplay")
    RedDotData:UpdateRedDotState(RedDotId, RedDotState)
  end
end

function RedDotModule:BindOnFriendApplyListUpdate()
  local RedDotId = "Friend_Request"
  RedDotData:CreateRedDotState(RedDotId, "Friend_Request")
  RedDotData:SetRedDotNum(RedDotId, table.count(ContactPersonData:GetFriendApplyIdList()))
end

function RedDotModule:BindOnPersonalChatInfoUpdate(SenderId)
  local ChatInfo = ContactPersonData:GetPersonalChatInfoById(SenderId)
  local LastChatInfo
  for index, SingleChatInfo in ipairs(ChatInfo) do
    LastChatInfo = SingleChatInfo
  end
  if not LastChatInfo or not LastChatInfo.IsReceive then
    return
  end
  local RedDotId = "Friend_Chat_Item_" .. tostring(SenderId)
  RedDotData:CreateRedDotState(RedDotId, "Friend_Chat_Item")
  RedDotData:ChangeRedDotNum(RedDotId, 1)
end

function RedDotModule:BindOnUpdateGameFloorInfo()
  local GameModeId = LogicTeam and GetCurNormalMode() or 1001
  local GameFloors = DataMgr.GameFloorInfo[GameModeId]
  if not GameFloors then
    return
  end
  local ModeRedDotPrefix = "GameMode_World_Num"
  local DifficultLevelRedDotPrefix = "GameMode_Level_Num"
  for WorldId, Floor in pairs(GameFloors) do
    local ModeRedDotId = ModeRedDotPrefix .. "_" .. tostring(WorldId)
    RedDotData:CreateRedDotState(ModeRedDotId, ModeRedDotPrefix)
    for SingleFloor = 1, Floor do
      local DifficultLevelRedDotId = DifficultLevelRedDotPrefix .. "_" .. tostring(WorldId) .. "_" .. tostring(SingleFloor)
      local IsNewCreate = RedDotData:CreateRedDotState(DifficultLevelRedDotId, DifficultLevelRedDotPrefix)
      local DifficultLevelRedDotState = {
        ParentIdList = {ModeRedDotId}
      }
      if IsNewCreate then
        DifficultLevelRedDotState.Num = 1
      end
      RedDotData:UpdateRedDotState(DifficultLevelRedDotId, DifficultLevelRedDotState)
    end
  end
end

function RedDotModule:BindOnHeirloomInfoChanged()
  if not LogicRole then
    return
  end
  local AllCharacterList = LogicRole.GetAllCanSelectCharacterList()
  for index, SingleHeroId in ipairs(AllCharacterList) do
    local RedDotHeirloom = string.format("Skin_Menu2_%d", SingleHeroId)
    RedDotData:CreateRedDotState(RedDotHeirloom, "Skin_Menu2")
    local redDotAppearanceId = string.format("Role_Skin_%d", SingleHeroId)
    RedDotData:CreateRedDotState(redDotAppearanceId, "Role_Skin")
    local RedDotHeirloomState = {
      ParentIdList = {redDotAppearanceId}
    }
    RedDotData:UpdateRedDotState(RedDotHeirloom, RedDotHeirloomState)
    local AllHeirloomIdList = HeirloomData:GetAllHeirloomByHeroId(SingleHeroId)
    local TargetHeirloomId = -1
    for index, SingleHeirloomId in ipairs(AllHeirloomIdList) do
      TargetHeirloomId = SingleHeirloomId
      break
    end
    if -1 ~= TargetHeirloomId then
      local MaxLevel = HeirloomData:GetHeirloomMaxLevel(TargetHeirloomId)
      local MaxUnLockLevel = HeirloomData:GetMaxUnLockHeirloomLevel(TargetHeirloomId)
      for i = 1, MaxLevel do
        local RedDotId = string.format("Skin_Heirloom_LevelItem_%d_%d", TargetHeirloomId, i)
        RedDotData:CreateRedDotState(RedDotId, "Skin_Heirloom_LevelItem")
        local RedDotState = {
          ParentIdList = {RedDotHeirloom},
          Num = 0
        }
        if i > 1 and i > MaxUnLockLevel and 1 == i - MaxUnLockLevel then
          local RowInfo = HeirloomData:GetHeirloomInfoByLevel(TargetHeirloomId, i)
          local HaveEnoughResource = true
          for i, SingleCost in ipairs(RowInfo.CostResources) do
            local CurHavaNum = LogicOutsidePackback.GetResourceNumById(SingleCost.key)
            if CurHavaNum < SingleCost.value then
              HaveEnoughResource = false
              break
            end
          end
          if HaveEnoughResource then
            RedDotState.Num = 1
          end
        end
        RedDotData:UpdateRedDotState(RedDotId, RedDotState)
      end
    end
  end
end

function RedDotModule:BindOnUpdateResourceInfo()
  if LogicTalent then
    LogicTalent.ResetPreRemainCostList()
    LogicTalent.ResetPreCommonTalentLevelList()
    EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentPresetCost)
  end
  self:BindOnHeirloomInfoChanged()
  self:BindOnUpdateCommonTalentInfo()
end

function RedDotModule:OnResourceUpdate(JsonStr)
  local bNeedRequest = false
  local JsonTable = rapidjson.decode(JsonStr)
  if JsonTable.resources then
    local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    for i, res in ipairs(JsonTable.resources) do
      local id = tonumber(res.id)
      if tbGeneral and tbGeneral[id] and 18 == tbGeneral[id].Type then
        bNeedRequest = true
      end
    end
  end
  if bNeedRequest then
    IllustratedGuideHandler.RequestGetOwnedSpecificModifyListFromServer()
  end
end

function RedDotModule:BindOnGetHeroSkinList(HeroSkinList)
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  for heroId, vSkinData in pairs(SkinData.HeroSkinMap) do
    local redDotHeroId = string.format("Role_SingleItem_%d", heroId)
    local isHeroNewCreate = RedDotData:CreateRedDotState(redDotHeroId, "Role_SingleItem")
    local redDotIdHeroSkin = string.format("Skin_RoleSkin_%d", heroId)
    local isNewCreateHeroSkin = RedDotData:CreateRedDotState(redDotIdHeroSkin, "Skin_RoleSkin")
    local redDotIdSkinView = string.format("Skin_Menu1_%d", heroId)
    local isNewCreateSkinView = RedDotData:CreateRedDotState(redDotIdSkinView, "Skin_Menu1")
    local redDotAppearanceId = string.format("Role_Skin_%d", heroId)
    local isAppearanceNewCreate = RedDotData:CreateRedDotState(redDotAppearanceId, "Role_Skin")
    local redDotStateSkinView = {
      ParentIdList = {redDotAppearanceId}
    }
    local redDotStateHeroSkin = {
      ParentIdList = {redDotIdSkinView}
    }
    local redDotAppearanceState = {
      ParentIdList = {redDotHeroId}
    }
    RedDotData:UpdateRedDotState(redDotIdHeroSkin, redDotStateHeroSkin)
    RedDotData:UpdateRedDotState(redDotIdSkinView, redDotStateSkinView)
    RedDotData:UpdateRedDotState(redDotAppearanceId, redDotAppearanceState)
    for iHeroSkinData, vHeroSkinData in ipairs(vSkinData.SkinDataList) do
      if vHeroSkinData.bUnlocked then
        if vHeroSkinData.HeirloomId > 0 then
          local redDotHeirloomId = string.format("Skin_RoleSkin_Item_%d_%d", vHeroSkinData.HeroSkinTb.CharacterID, vHeroSkinData.HeirloomId)
          local isHeirloomNewCreate = RedDotData:CreateRedDotState(redDotHeirloomId, "Skin_RoleSkin_Item")
          local redDotHeirloomState = {}
          redDotHeirloomState.ParentIdList = {redDotIdHeroSkin}
          if isHeirloomNewCreate then
            redDotHeirloomState.Num = 1
          else
            redDotHeirloomState.IsStubborn = false
          end
          RedDotData:UpdateRedDotState(redDotHeirloomId, redDotHeirloomState)
        else
          if vHeroSkinData.HeroSkinTb.ParentSkinId > 0 then
            return
          end
          local redDotId = string.format("Skin_RoleSkin_Item_%d_%d", vHeroSkinData.HeroSkinTb.CharacterID, vHeroSkinData.HeroSkinTb.SkinID)
          local isNewCreate = RedDotData:CreateRedDotState(redDotId, "Skin_RoleSkin_Item")
          local redDotState = {}
          redDotState.ParentIdList = {redDotIdHeroSkin}
          if isNewCreate then
            local defaultSkinId = -1
            if tbHeroMonster and tbHeroMonster[heroId] then
              defaultSkinId = tbHeroMonster[heroId].SkinID
            end
            if vHeroSkinData.bUnlocked and vSkinData.EquipedSkinId ~= vHeroSkinData.HeroSkinTb.SkinID and defaultSkinId ~= vHeroSkinData.HeroSkinTb.SkinID and vHeroSkinData.HeroSkinTb.IsShow then
              redDotState.Num = 1
            else
              redDotState.Num = 0
            end
          else
            redDotState.IsStubborn = false
          end
          RedDotData:UpdateRedDotState(redDotId, redDotState)
        end
      end
    end
  end
end

function RedDotModule:BindOnGetWeaponSkinList(WeaponSkinList)
  local tbWeapon = LuaTableMgr.GetLuaTableByName(TableNames.TBWeapon)
  for weaponResId, vSkinData in pairs(SkinData.WeaponSkinMap) do
    local heroId = LogicOutsideWeapon.GetHeroIdByWeaponId(weaponResId)
    if heroId > 0 then
      local redDotHeroId = string.format("Role_SingleItem_%d", heroId)
      RedDotData:CreateRedDotState(redDotHeroId, "Role_SingleItem")
      local redDotIdWeapon = string.format("Skin_WeaponSkin_WeaponName_%d", heroId .. weaponResId)
      RedDotData:CreateRedDotState(redDotIdWeapon, "Skin_WeaponSkin_WeaponName")
      local redDotWeaponMenuId2 = string.format("Weapon_Menu_2_%d", heroId)
      local redDotIdWeaponSkin = string.format("Skin_WeaponSkin_%d", heroId)
      RedDotData:CreateRedDotState(redDotIdWeaponSkin, "Skin_WeaponSkin")
      local redDotIdSkinView = string.format("Skin_Menu1_%d", heroId)
      RedDotData:CreateRedDotState(redDotIdSkinView, "Skin_Menu1")
      local redDotAppearanceId = string.format("Role_Skin_%d", heroId)
      RedDotData:CreateRedDotState(redDotAppearanceId, "Role_Skin")
      local redDotStateWeapon = {
        ParentIdList = {redDotIdWeaponSkin, redDotWeaponMenuId2}
      }
      local redDotStateWeaponSkin = {
        ParentIdList = {redDotIdSkinView}
      }
      local redDotStateSkinView = {
        ParentIdList = {redDotAppearanceId}
      }
      local redDotAppearanceState = {
        ParentIdList = {redDotHeroId}
      }
      RedDotData:UpdateRedDotState(redDotIdWeapon, redDotStateWeapon)
      RedDotData:UpdateRedDotState(redDotIdWeaponSkin, redDotStateWeaponSkin)
      RedDotData:UpdateRedDotState(redDotIdSkinView, redDotStateSkinView)
      RedDotData:UpdateRedDotState(redDotAppearanceId, redDotAppearanceState)
      local redDotWeaponId = string.format("Role_Weapon_%d", heroId)
      RedDotData:CreateRedDotState(redDotWeaponId, "Role_Weapon")
      local redDotWeaponState = {
        ParentIdList = {redDotHeroId}
      }
      RedDotData:UpdateRedDotState(redDotWeaponId, redDotWeaponState)
      local redDotWeaponMainMenuId = string.format("Weapon_Menu_%d", heroId)
      RedDotData:CreateRedDotState(redDotWeaponMainMenuId, "Weapon_Menu")
      local redDotWeaponMenuState = {
        ParentIdList = {redDotWeaponId}
      }
      RedDotData:UpdateRedDotState(redDotWeaponMainMenuId, redDotWeaponMenuState)
      RedDotData:CreateRedDotState(redDotWeaponMenuId2, "Weapon_Menu_2")
      local redDotWeaponMenuState2 = {
        ParentIdList = {redDotWeaponMainMenuId}
      }
      RedDotData:UpdateRedDotState(redDotWeaponMenuId2, redDotWeaponMenuState2)
      for iHeroSkinData, vWeaponSkinData in ipairs(vSkinData.SkinDataList) do
        if vWeaponSkinData.bUnlocked then
          local redDotId = string.format("Skin_WeaponSkin_Item_%d", heroId .. vWeaponSkinData.WeaponSkinTb.SkinID)
          local isNewCreate = RedDotData:CreateRedDotState(redDotId, "Skin_WeaponSkin_Item")
          local redDotState = {}
          redDotState.ParentIdList = {redDotIdWeapon}
          if isNewCreate then
            local defaultSkinId = -1
            if tbWeapon and tbWeapon[weaponResId] then
              defaultSkinId = tbWeapon[weaponResId].SkinID
            end
            if vWeaponSkinData.bUnlocked and vSkinData.EquipedSkinId ~= vWeaponSkinData.WeaponSkinTb.SkinID and vWeaponSkinData.WeaponSkinTb.SkinID ~= defaultSkinId and vWeaponSkinData.WeaponSkinTb.IsShow then
              redDotState.Num = 1
            else
              redDotState.Num = 0
            end
          else
            redDotState.IsStubborn = false
          end
          RedDotData:UpdateRedDotState(redDotId, redDotState)
        end
      end
    end
  end
end

function RedDotModule:BindOnMainTaskRefres()
  local allCharacterList = LogicRole.GetAllCanSelectCharacterList()
  for iHeroId, heroId in pairs(allCharacterList) do
    local redDotHeroId = string.format("Role_SingleItem_%d", heroId)
    RedDotData:CreateRedDotState(redDotHeroId, "Role_SingleItem")
    local redDotProfyId = string.format("Role_Proficiency_%d", heroId)
    RedDotData:CreateRedDotState(redDotProfyId, "Role_Proficiency")
    local redDotProfyState = {
      ParentIdList = {redDotHeroId}
    }
    RedDotData:UpdateRedDotState(redDotProfyId, redDotProfyState)
    for profyLvIdx = 1, ProficiencyData.MaxLv do
      local taskList = ProficiencyData:GetProfyTaskList(heroId, profyLvIdx)
      if 0 == #taskList then
        break
      end
      for i = 1, #taskList - 1 do
        local taskId = taskList[i]
        local state = Logic_MainTask.GetStateByTaskId(taskId)
        local redDotProfyNormalTask = string.format("Proficiency_NormalTask_Num_%d", taskId)
        RedDotData:CreateRedDotState(redDotProfyNormalTask, "Proficiency_NormalTask_Num")
        local redDotProfyNormalTaskState = {
          ParentIdList = {redDotProfyId}
        }
        if state == ETaskState.Finished then
          redDotProfyNormalTaskState.Num = 1
        else
          redDotProfyNormalTaskState.Num = 0
        end
        RedDotData:UpdateRedDotState(redDotProfyNormalTask, redDotProfyNormalTaskState)
      end
      local legandProfyTask = taskList[#taskList]
      local legandTaskState = Logic_MainTask.GetStateByTaskId(legandProfyTask)
      local redDotLegendTaskBonusId = string.format("Proficiency_LegendTaskBonus_Num_%d", legandProfyTask)
      RedDotData:CreateRedDotState(redDotLegendTaskBonusId, "Proficiency_LegendTaskBonus_Num")
      local redDotLegendTaskBonusState = {
        ParentIdList = {redDotProfyId}
      }
      if legandTaskState == ETaskState.Finished then
        redDotLegendTaskBonusState.Num = 1
      else
        redDotLegendTaskBonusState.Num = 0
      end
      RedDotData:UpdateRedDotState(redDotLegendTaskBonusId, redDotLegendTaskBonusState)
      local redDotLegendTaskId = string.format("Proficiency_LegendTask_Num_%d", legandProfyTask)
      RedDotData:CreateRedDotState(redDotLegendTaskId, "Proficiency_LegendTask_Num")
      local redDotLegendTaskState = {
        ParentIdList = {redDotProfyId}
      }
      RedDotData:UpdateRedDotState(redDotLegendTaskId, redDotLegendTaskState)
      local profyData = ProficiencyData:GetProfyData(heroId, profyLvIdx)
      local taskGroupId = profyData.ProfyTaskTb.TaskGroupID
      local profyGroupUnlock = Logic_MainTask.IsProfyTaskGroupOrGotAward(heroId, profyLvIdx, taskGroupId)
      if (legandTaskState == ETaskState.Finished or legandTaskState == ETaskState.GotAward) and profyGroupUnlock then
        local redDotSynopsisItemId = string.format("Proficiency_SynopsisItem_Num_%d", legandProfyTask)
        RedDotData:CreateRedDotState(redDotSynopsisItemId, "Proficiency_SynopsisItem_Num")
        local redDotSynopsisItemState = {
          ParentIdList = {redDotLegendTaskId}
        }
        if isSynopsisItemNewCreate then
          if (legandTaskState == ETaskState.Finished or legandTaskState == ETaskState.GotAward) and profyGroupUnlock then
            redDotSynopsisItemState.Num = 1
          else
            redDotSynopsisItemState.Num = 0
          end
        else
          redDotSynopsisItemState.IsStubborn = false
        end
        RedDotData:UpdateRedDotState(redDotSynopsisItemId, redDotSynopsisItemState)
      end
      local bIsFinished = Logic_MainTask.IsGroupFinish(taskGroupId)
      local redDotProfyLvBonusId = string.format("Proficiency_LevelBonus_Num_%d", taskGroupId)
      RedDotData:CreateRedDotState(redDotProfyLvBonusId, "Proficiency_LevelBonus_Num")
      local redDotProfyLvBonusState = {
        ParentIdList = {redDotProfyId}
      }
      if bIsFinished then
        redDotProfyLvBonusState.Num = 1
      else
        redDotProfyLvBonusState.Num = 0
      end
      RedDotData:UpdateRedDotState(redDotProfyLvBonusId, redDotProfyLvBonusState)
    end
  end
end

function RedDotModule:BindOnRefreshBattlePassTask()
  local LobbyMainViewModel = UIModelMgr:Get("LobbyMainViewModel")
  local OpenBattlePass = LobbyMainViewModel:CheckOpeningBattlePass()
  local BattlePassID = OpenBattlePass and OpenBattlePass.BattlePassID
  if not BattlePassID then
    print("RedDotModule:BindOnRefreshBattlePassTask, BattlePassID is nil")
    return
  end
  local TBBattlePassTask = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassTask)
  for index, value in ipairs(TBBattlePassTask) do
    if value.BattlePassID == BattlePassID then
      local TaskGroupId = value.TaskGroupID
      local TaskGroupRedDotId = "BattlePass_Task_Group_" .. TaskGroupId
      RedDotData:CreateRedDotState(TaskGroupRedDotId, "BattlePass_Task_Group")
      local TaskGroupDataTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
      local TaskGroupData = TaskGroupDataTable[TaskGroupId]
      local TaskIdList = TaskGroupData.tasklist
      for i, TaskId in ipairs(TaskIdList) do
        local TaskRedDotId = "BattlePass_Task_" .. TaskGroupId .. "_" .. TaskId
        RedDotData:CreateRedDotState(TaskRedDotId, "BattlePass_Task")
        local TaskRedDotState = {
          ParentIdList = {TaskGroupRedDotId}
        }
        if Logic_MainTask.GetStateByTaskId(TaskId) == ETaskState.Finished then
          TaskRedDotState.Num = 1
        else
          TaskRedDotState.Num = 0
        end
        RedDotData:UpdateRedDotState(TaskRedDotId, TaskRedDotState)
      end
    end
  end
end

function RedDotModule:BindOnRefreshPlotFragment()
  local AllPlotFragmentWorldIdList = IllustratedGuideData:GetPlotFragmentWorldIdList()
  for i, WorldId in ipairs(AllPlotFragmentWorldIdList) do
    local WorldRedDotId = "Piece_World_Num_" .. WorldId
    RedDotData:CreateRedDotState(WorldRedDotId, "Piece_World_Num")
    local ClueIdList = IllustratedGuideData:GetClueIdListByWorldId(WorldId)
    for j, ClueId in ipairs(ClueIdList) do
      local ClueRedDotId = "Piece_Clue_Num_" .. ClueId
      RedDotData:CreateRedDotState(ClueRedDotId, "Piece_Clue_Num")
      local ClueRedDotState = {
        ParentIdList = {WorldRedDotId}
      }
      RedDotData:UpdateRedDotState(ClueRedDotId, ClueRedDotState)
      local FragmentIdList = IllustratedGuideData:GetClueInfoByClueId(ClueId).fragmentIDList
      for k, FragmentId in ipairs(FragmentIdList) do
        local FragmentRedDotId = "Piece_Item_Num_" .. ClueId .. "_" .. FragmentId
        local IsNewCreate = RedDotData:CreateRedDotState(FragmentRedDotId, "Piece_Item_Num")
        local FragmentRedDotState = {
          ParentIdList = {ClueRedDotId}
        }
        if 2 == IllustratedGuideData:GetPlotFragmentStateById(FragmentId) then
          FragmentRedDotState.Num = 1
        else
          FragmentRedDotState.Num = 0
        end
        RedDotData:UpdateRedDotState(FragmentRedDotId, FragmentRedDotState)
      end
      if IllustratedGuideData:IsClueUnlock(ClueId) then
        local ClueStoryRedDotId = "Piece_LayerStory_Num_" .. ClueId
        local IsNewCreate = RedDotData:CreateRedDotState(ClueStoryRedDotId, "Piece_LayerStory_Num")
        local ClueRedDotState = {
          ParentIdList = {ClueRedDotId}
        }
        if IsNewCreate then
          ClueRedDotState.Num = 1
        end
        RedDotData:UpdateRedDotState(ClueStoryRedDotId, ClueRedDotState)
      end
    end
  end
end

function RedDotModule:BindPandoraActCenterRedpoint(MegObj)
  print("RedDotModule:BindPandoraActCenterRedpoint", MegObj)
  table.Print(MegObj)
end

function RedDotModule:BindOnMainTaskRefresh(TaskGroupIdList)
  self:RefreshRuleTaskRedDot(TaskGroupIdList)
end

function RedDotModule:RefreshRuleTaskRedDot(TaskGroupIdList)
  TaskGroupIdList = TaskGroupIdList or {}
  local RuleTaskTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRuleTask)
  for ActivityId, RuleTaskRowInfo in pairs(RuleTaskTable) do
    local ActivityItemRedDotId = "Activity_TabList_" .. ActivityId
    RedDotData:CreateRedDotState(ActivityItemRedDotId, "Activity_TabList")
    if table.Contain(TaskGroupIdList, RuleTaskRowInfo.creditExchangeTaskGroupId) then
      local Result, TaskGroupInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, RuleTaskRowInfo.creditExchangeTaskGroupId)
      if Result then
        for i, SingleTaskId in ipairs(TaskGroupInfo.tasklist) do
          local CreditTaskRedDotId = "Activity_GenericMission_RewardList_" .. SingleTaskId
          local IsNewCreate = RedDotData:CreateRedDotState(CreditTaskRedDotId, "Activity_GenericMission_RewardList")
          local CreditTaskDotState = {
            ParentIdList = {ActivityItemRedDotId}
          }
          if RuleTaskData:GetTaskState(SingleTaskId) == ETaskState.Finished then
            CreditTaskDotState.Num = 1
          else
            CreditTaskDotState.Num = 0
          end
          RedDotData:UpdateRedDotState(CreditTaskRedDotId, CreditTaskDotState)
        end
      end
    end
    for i, SingleRuleInfoId in ipairs(RuleTaskRowInfo.ruleInfoList) do
      local RuleTaskItemRedDotId = "Activity_GenericMission_DataBase_" .. SingleRuleInfoId
      local IsNewCreate = RedDotData:CreateRedDotState(RuleTaskItemRedDotId, "Activity_GenericMission_DataBase")
      local RuleTaskItemDotState = {
        ParentIdList = {ActivityItemRedDotId}
      }
      local Result, RuleInfoRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleInfo, SingleRuleInfoId)
      if Result and (table.Contain(TaskGroupIdList, RuleInfoRowInfo.MainTaskGroupId) or table.Contain(TaskGroupIdList, RuleInfoRowInfo.MinorTaskGroupId)) then
        local FinishedTaskNum = 0
        local Result, TaskGroupInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, RuleInfoRowInfo.MainTaskGroupId)
        if Result then
          for i, SingleTaskId in ipairs(TaskGroupInfo.tasklist) do
            if RuleTaskData:GetTaskState(SingleTaskId) == ETaskState.Finished then
              FinishedTaskNum = FinishedTaskNum + 1
            end
          end
        end
        local MainGroupState = RuleTaskData:GetTaskGroupState(RuleInfoRowInfo.MainTaskGroupId)
        if MainGroupState == ETaskGroupState.Finished then
          FinishedTaskNum = FinishedTaskNum + 1
        end
        local Result, TaskGroupInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, RuleInfoRowInfo.MinorTaskGroupId)
        if Result then
          for i, SingleTaskId in ipairs(TaskGroupInfo.tasklist) do
            if RuleTaskData:GetTaskState(SingleTaskId) == ETaskState.Finished then
              FinishedTaskNum = FinishedTaskNum + 1
            end
          end
        end
        if FinishedTaskNum > 0 then
          RuleTaskItemDotState.Num = 1
        else
          RuleTaskItemDotState.Num = 0
        end
      end
      RedDotData:UpdateRedDotState(RuleTaskItemRedDotId, RuleTaskItemDotState)
    end
  end
  local ActivityGeneralTable = LuaTableMgr.GetLuaTableByName(TableNames.TBActivityGeneral)
  for ActivityId, ActivityRowInfo in pairs(ActivityGeneralTable) do
    if ActivityRowInfo.name == "\228\184\131\230\151\165\231\173\190\229\136\176" then
      local TaskGroupId = ActivityRowInfo.taskGroupList[1]
      if table.Contain(TaskGroupIdList, TaskGroupId) then
        local ActivityItemRedDotId = "Activity_TabList_" .. ActivityId
        RedDotData:CreateRedDotState(ActivityItemRedDotId, "Activity_TabList")
        local TaskGroupDataTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
        local TaskGroupData = TaskGroupDataTable[TaskGroupId]
        local TaskIdList = TaskGroupData.tasklist
        for i, SingleTaskId in ipairs(TaskIdList) do
          local SignTaskRedDotId = "Activity_SevenDay_Reward_" .. SingleTaskId
          local IsNewCreate = RedDotData:CreateRedDotState(SignTaskRedDotId, "Activity_SevenDay_Reward")
          local SignTaskDotState = {
            ParentIdList = {ActivityItemRedDotId}
          }
          if Logic_MainTask.GetStateByTaskId(SingleTaskId) == ETaskState.Finished then
            SignTaskDotState.Num = 1
          else
            SignTaskDotState.Num = 0
          end
          RedDotData:UpdateRedDotState(SignTaskRedDotId, SignTaskDotState)
        end
      end
    end
  end
end

function RedDotModule:BindOnMainRewardStateChanged(...)
  local RuleTaskTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRuleTask)
  for ActivityId, RuleTaskRowInfo in pairs(RuleTaskTable) do
    local MainTaskGroupIdList = {}
    local Result, ActivityRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleTask, ActivityId)
    if Result then
      for i, SingleRuleInfoId in ipairs(ActivityRowInfo.ruleInfoList) do
        local BResult, RuleInfoRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleInfo, SingleRuleInfoId)
        if BResult then
          table.insert(MainTaskGroupIdList, RuleInfoRowInfo.MainTaskGroupId)
        end
      end
      local MaxNum = #MainTaskGroupIdList
      local FinishNum = 0
      for i, SingleTaskGroupId in ipairs(MainTaskGroupIdList) do
        local CurStatus = RuleTaskData:GetTaskGroupState(SingleTaskGroupId)
        if CurStatus == ETaskGroupState.Finished or CurStatus == ETaskGroupState.GotAward then
          FinishNum = FinishNum + 1
        end
      end
      local ActivityItemRedDotId = "Activity_TabList_" .. ActivityId
      RedDotData:CreateRedDotState(ActivityItemRedDotId, "Activity_TabList")
      local MainRewardRedDotId = "Activity_GenericMission_FinalReward_" .. ActivityId
      RedDotData:CreateRedDotState(MainRewardRedDotId, "Activity_GenericMission_FinalReward")
      local MainRewardDotState = {
        ParentIdList = {ActivityItemRedDotId}
      }
      if FinishNum == MaxNum and RuleTaskData:GetMainRewardState(ActivityId) == EMainRewardState.UnReceive then
        MainRewardDotState.Num = 1
      else
        MainRewardDotState.Num = 0
      end
      RedDotData:UpdateRedDotState(MainRewardRedDotId, MainRewardDotState)
    end
  end
end

function RedDotModule:BindOnWeaponListChanged()
  local allCharacterList = LogicRole.GetAllCanSelectCharacterList()
  for iHeroId, heroId in pairs(allCharacterList) do
    local redDotHeroId = string.format("Role_SingleItem_%d", heroId)
    RedDotData:CreateRedDotState(redDotHeroId, "Role_SingleItem")
    local redDotWeaponId = string.format("Role_Weapon_%d", heroId)
    RedDotData:CreateRedDotState(redDotWeaponId, "Role_Weapon")
    local redDotWeaponState = {
      ParentIdList = {redDotHeroId}
    }
    RedDotData:UpdateRedDotState(redDotWeaponId, redDotWeaponState)
    local redDotWeaponMainMenuId = string.format("Weapon_Menu_%d", heroId)
    RedDotData:CreateRedDotState(redDotWeaponMainMenuId, "Weapon_Menu")
    local redDotWeaponMenuState = {
      ParentIdList = {redDotWeaponId}
    }
    RedDotData:UpdateRedDotState(redDotWeaponMainMenuId, redDotWeaponMenuState)
    local redDotWeaponMenuId1 = string.format("Weapon_Menu_1_%d", heroId)
    RedDotData:CreateRedDotState(redDotWeaponMenuId1, "Weapon_Menu_1")
    local redDotWeaponMenuState1 = {
      ParentIdList = {redDotWeaponMainMenuId}
    }
    RedDotData:UpdateRedDotState(redDotWeaponMenuId1, redDotWeaponMenuState1)
    local weaponList = LogicOutsideWeapon.GetAllCanEquipWeaponDataList(heroId)
    if not weaponList then
      print("RedDotModule:BindOnWeaponListChanged weaponList Is Nil")
      return
    end
    for i, v in ipairs(weaponList) do
      local weaponResId = tonumber(v.resourceId)
      if v.WeaponData ~= nil then
        local redDotWeaponItemId = string.format("Weapon_WeaponItem_%d", weaponResId)
        local bIsWeaponItemNewCreate = RedDotData:CreateRedDotState(redDotWeaponItemId, "Weapon_WeaponItem")
        local redDotWeaponItemState = {
          ParentIdList = {redDotWeaponMenuId1}
        }
        if bIsWeaponItemNewCreate and -1 == v.WeaponData.equip then
          redDotWeaponItemState.Num = 1
        else
          local oldRedDotState = RedDotData:GetRedDotState(redDotWeaponItemId)
          if oldRedDotState then
            redDotWeaponItemState.Num = oldRedDotState.Num
          end
        end
        RedDotData:UpdateRedDotState(redDotWeaponItemId, redDotWeaponItemState)
      end
    end
  end
end

function RedDotModule:BindOnUpdateCommonTalentInfo()
  if not LogicTalent then
    return
  end
  local TalentRedDotClass = "Talent_SingleItem"
  local LobbySettings = UE.URGLobbySettings.GetLobbySettings()
  local AllTalentList = LobbySettings.AllCommonTalentList:ToTable()
  for TalentType, TalentIdList in pairs(AllTalentList) do
    if TalentType ~= UE.ETalentItemType.AccumulativeCost then
      for key, SingleTalentId in pairs(TalentIdList.TalentList) do
        local RedDotId = TalentRedDotClass .. "_" .. SingleTalentId
        RedDotData:CreateRedDotState(RedDotId, TalentRedDotClass)
        local RedDotState = {}
        if LogicTalent.IsMeetPreTalentGroupCondition(SingleTalentId) and LogicTalent.IsMeetTalentUpgradeCostCondition(SingleTalentId) then
          RedDotState.Num = 1
        else
          RedDotState.Num = 0
        end
        RedDotData:UpdateRedDotState(RedDotId, RedDotState)
      end
    end
  end
end

function RedDotModule:BindOnUpdateAllSpecificModifyInfo(OwnedSpecificModifyList)
  for k, v in pairs(OwnedSpecificModifyList) do
    local HeroIdList = IllustratedGuideData:GetHeroIdListBySpecificModifyId(v)
    if nil ~= HeroIdList and not IllustratedGuideData:GetIsInitUnlockBySpecificModifyId(v) then
      local RedDotId = "Specific_GenericList_Item_" .. v
      local IsNewCreate = RedDotData:CreateRedDotState(RedDotId, "Specific_GenericList_Item")
      local RedDotState = {}
      if IsNewCreate then
        RedDotState.Num = 1
      end
      RedDotState.ParentIdList = {}
      for i, SingleHeroId in ipairs(HeroIdList) do
        local Result, RowData = GetRowData(DT.DT_ModRefresh, tostring(v))
        if Result then
          local ParentRedDotId = "Specific_GenericList_" .. SingleHeroId .. "_" .. RowData.SkillType
          table.insert(RedDotState.ParentIdList, ParentRedDotId)
          RedDotData:CreateRedDotState(ParentRedDotId, "Specific_GenericList")
          local ParentRedDotState = {
            ParentIdList = {
              "Specific_HeroList_Item_" .. SingleHeroId
            }
          }
          RedDotData:CreateRedDotState("Specific_HeroList_Item_" .. SingleHeroId, "Specific_HeroList_Item")
          RedDotData:UpdateRedDotState(ParentRedDotId, ParentRedDotState)
        end
      end
      RedDotData:UpdateRedDotState(RedDotId, RedDotState)
    end
  end
end

function RedDotModule:BindOnGetHeroChipBag()
  for k, v in pairs(ChipData.ChipBags) do
    local ChipId = v.Chip.id
    local ChipRedDotId = "Chip_Item_" .. ChipId
    if not RedDotData:GetRedDotState(ChipRedDotId) then
      RedDotData:CreateRedDotState(ChipRedDotId, "Chip_Item")
      RedDotData:SetRedDotNum(ChipRedDotId, 1)
    end
  end
end

function RedDotModule:BindOnRefreshAchievement()
  local AchievementGroupList = AchievementData:GetAchievementTypeList()
  for i, AchievementGroupInfo in ipairs(AchievementGroupList) do
    local AchievementList = AchievementData:GetAchievementByType(AchievementGroupInfo.type)
    local TypeRedDotId = "Achievement_Filter_Num_" .. AchievementGroupInfo.type
    RedDotData:CreateRedDotState(TypeRedDotId, "Achievement_Filter_Num")
    local AchievementTaskGroupList = AchievementGroupInfo.taskgrouplist
    for j, AchievementTaskGroupId in ipairs(AchievementTaskGroupList) do
      local RedDotId = "Achievement_IconItem_" .. AchievementTaskGroupId
      RedDotData:CreateRedDotState(RedDotId, "Achievement_IconItem")
      local ActiveTask = Logic_MainTask.GetGroupActiveTask(AchievementTaskGroupId)
      local RedDotState = {
        ParentIdList = {TypeRedDotId}
      }
      if ActiveTask and ActiveTask.state == ETaskState.Finished then
        RedDotState.Num = 1
      else
        RedDotState.Num = 0
      end
      RedDotData:UpdateRedDotState(RedDotId, RedDotState)
    end
  end
  local CanReceivePhaseAward = false
  local AchievementViewModel = UIModelMgr:Get("AchievementViewModel")
  local TBAchievementPointSort = AchievementViewModel:GetTBAchievementPointSort()
  for i, v in ipairs(TBAchievementPointSort) do
    local state = Logic_MainTask.GetStateByTaskId(v.taskid)
    if state == ETaskState.Finished then
      CanReceivePhaseAward = true
      break
    end
  end
  RedDotData:SetRedDotNum("Achievement_PhaseAward", CanReceivePhaseAward and 1 or 0)
end

function RedDotModule:BindOnUpdateMyHeroInfo(...)
  if not LogicRole then
    return
  end
  local AllCharacterList = LogicRole.GetAllCanSelectCharacterList()
  for index, SingleHeroId in ipairs(AllCharacterList) do
    local RedDotProficiencyMenu = string.format("Proficiency_Menu_1_%d", SingleHeroId)
    RedDotData:CreateRedDotState(RedDotProficiencyMenu, "Proficiency_Menu_1")
    local redDotHeroId = string.format("Role_SingleItem_%d", SingleHeroId)
    RedDotData:CreateRedDotState(redDotHeroId, "Role_SingleItem")
    if LogicRole.CheckCharacterUnlock(SingleHeroId) then
      local redDotHeroLockId = string.format("Role_SingleItem_Lock_%d", SingleHeroId)
      local isHeroLockNewCreate = RedDotData:CreateRedDotState(redDotHeroLockId, "Role_SingleItem_Lock")
      local RedDotHeroLockState = {
        ParentIdList = {redDotHeroId}
      }
      if isHeroLockNewCreate then
        RedDotHeroLockState.Num = 1
      end
      RedDotData:UpdateRedDotState(redDotHeroLockId, RedDotHeroLockState)
    end
    local RedDotProficiencyMenuState = {
      ParentIdList = {redDotHeroId}
    }
    RedDotData:UpdateRedDotState(RedDotProficiencyMenu, RedDotProficiencyMenuState)
    local RedDotSynopsisMenu = string.format("Proficiency_LegendTask_%d", SingleHeroId)
    RedDotData:CreateRedDotState(RedDotSynopsisMenu, "Proficiency_LegendTask")
    local RedDotSynopsisState = {
      ParentIdList = {RedDotProficiencyMenu}
    }
    RedDotData:UpdateRedDotState(RedDotSynopsisMenu, RedDotSynopsisState)
    local AllProficiencyInfo = ProficiencyData:GetAllProficiencyInfoByHeroId(SingleHeroId)
    local MaxUnLockLevel = ProficiencyData:GetMaxUnlockProfyLevel(SingleHeroId)
    local LevelItemId = "Proficiency_LevelBonus_Num"
    local SynopsisItemId = "Proficiency_SynopsisItem_Num"
    if AllProficiencyInfo then
      for Level, GeneralRowId in pairs(AllProficiencyInfo) do
        local RedDotLevelId = string.format("%s_%d_%d", LevelItemId, SingleHeroId, Level)
        RedDotData:CreateRedDotState(RedDotLevelId, LevelItemId)
        local RedDotLevelState = {
          ParentIdList = {RedDotProficiencyMenu},
          Num = 0
        }
        if Level <= MaxUnLockLevel and not ProficiencyData:IsCurProfyLevelRewardReceived(SingleHeroId, Level) then
          RedDotLevelState.Num = 1
        end
        RedDotData:UpdateRedDotState(RedDotLevelId, RedDotLevelState)
        local RedDotSynopsisItemId = string.format("%s_%d_%d", SynopsisItemId, SingleHeroId, Level)
        RedDotData:CreateRedDotState(RedDotSynopsisItemId, SynopsisItemId)
        local RedDotSynopsisItemState = {
          ParentIdList = {RedDotSynopsisMenu},
          Num = 0
        }
        if Level <= MaxUnLockLevel and not ProficiencyData:IsCurProfyStoryRewardReceived(SingleHeroId, Level) then
          RedDotSynopsisItemState.Num = 1
        end
        RedDotData:UpdateRedDotState(RedDotSynopsisItemId, RedDotSynopsisItemState)
      end
    end
  end
end

function RedDotModule:BindOnGetCommList()
  if not LogicRole then
    return
  end
  local AllCharacterList = LogicRole.GetAllCanSelectCharacterList()
  for index, SingleHeroId in ipairs(AllCharacterList) do
    local RedDotAppearanceId = string.format("Role_Skin_%d", SingleHeroId)
    RedDotData:CreateRedDotState(RedDotAppearanceId, "Role_Skin")
    local RedDotCommunicationPageId = string.format("Skin_Menu3_%d", SingleHeroId)
    RedDotData:CreateRedDotState(RedDotCommunicationPageId, "Skin_Menu3")
    local RedDotCommunicationPageState = {
      ParentIdList = {RedDotAppearanceId}
    }
    RedDotData:UpdateRedDotState(RedDotCommunicationPageId, RedDotCommunicationPageState)
    local RedDotPaintMenuId = string.format("Roulette_Paint_%d", SingleHeroId)
    RedDotData:CreateRedDotState(RedDotPaintMenuId, "Roulette_Paint")
    local RedDotPaintMenuState = {
      ParentIdList = {RedDotCommunicationPageId}
    }
    RedDotData:UpdateRedDotState(RedDotPaintMenuId, RedDotPaintMenuState)
    local RedDotVoiceMenuId = string.format("Roulette_Voice_%d", SingleHeroId)
    RedDotData:CreateRedDotState(RedDotVoiceMenuId, "Roulette_Voice")
    local RedDotVoiceMenuState = {
      ParentIdList = {RedDotCommunicationPageId}
    }
    RedDotData:UpdateRedDotState(RedDotVoiceMenuId, RedDotVoiceMenuState)
    local SprayList = CommunicationData.GetSprayListByHeroId(SingleHeroId)
    for i, SprayItem in ipairs(SprayList) do
      local SprayId = SprayItem.ID
      if CommunicationData.CheckCommIsUnlock(SprayId) then
        local RedDotSprayId = string.format("Roulette_Paint_Item_%d", SprayId)
        local RedDotSprayState = {}
        if RedDotData:CreateRedDotState(RedDotSprayId, "Roulette_Paint_Item") then
          RedDotSprayState = {
            ParentIdList = {RedDotPaintMenuId}
          }
          RedDotSprayState.Num = 1
        else
          local RedDotSprayParentList = DeepCopy(RedDotData:GetRedDotState(RedDotSprayId).ParentIdList)
          if not table.Contain(RedDotSprayParentList, RedDotPaintMenuId) then
            table.insert(RedDotSprayParentList, RedDotPaintMenuId)
            RedDotSprayState = {ParentIdList = RedDotSprayParentList}
          end
        end
        RedDotData:UpdateRedDotState(RedDotSprayId, RedDotSprayState)
      end
    end
    local VoiceList = CommunicationData.GetVoiceListByHeroId(SingleHeroId)
    for i, VoiceItem in ipairs(VoiceList) do
      local VoiceId = VoiceItem.ID
      if CommunicationData.CheckCommIsUnlock(VoiceId) then
        local RedDotVoiceId = string.format("Roulette_Voice_Item_%d", VoiceId)
        local RedDotVoiceState = {}
        if RedDotData:CreateRedDotState(RedDotVoiceId, "Roulette_Voice_Item") then
          RedDotVoiceState = {
            ParentIdList = {RedDotVoiceMenuId}
          }
          RedDotVoiceState.Num = 1
        else
          local RedDotVoiceParentList = DeepCopy(RedDotData:GetRedDotState(RedDotVoiceId).ParentIdList)
          if not table.Contain(RedDotVoiceParentList, RedDotVoiceMenuId) then
            table.insert(RedDotVoiceParentList, RedDotVoiceMenuId)
            RedDotVoiceState = {ParentIdList = RedDotVoiceParentList}
          end
        end
        RedDotData:UpdateRedDotState(RedDotVoiceId, RedDotVoiceState)
      end
    end
  end
end

function RedDotModule:BindOnGetBattlePassData(BattlePassInfo, BattlePassID)
  local BPAwardList = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassReward)
  local BattlePassState = {
    Normal = 0,
    Premiun = 1,
    Ultra = 2
  }
  local AwardState = {
    Lock = 0,
    UnLock = 1,
    ReceiveNormal = 2,
    ReceivePremiun = 3
  }
  for i, AwardInfo in ipairs(BPAwardList) do
    if AwardInfo.BattlePassID ~= BattlePassID then
    else
      for index, NormalAward in ipairs(AwardInfo.NormalReward) do
        local RedDotAwardID = string.format("BattlePass_Reward_%d_%d_%s", AwardInfo.BattlePassLevel, NormalAward.key, "Normal")
        local isAwardCreate = RedDotData:CreateRedDotState(RedDotAwardID, "BattlePass_Reward")
        local NormalAwardState = {}
        NormalAwardState.Num = 0
        if BattlePassInfo.battlePassData[tostring(AwardInfo.BattlePassLevel)] and BattlePassInfo.battlePassData[tostring(AwardInfo.BattlePassLevel)] == AwardState.UnLock then
          NormalAwardState.Num = 1
        end
        RedDotData:UpdateRedDotState(RedDotAwardID, NormalAwardState)
      end
      for index, PremiumReward in ipairs(AwardInfo.PremiumReward) do
        local RedDotAwardID = string.format("BattlePass_Reward_%d_%d_%s", AwardInfo.BattlePassLevel, PremiumReward.key, "Premium")
        local isAwardCreate = RedDotData:CreateRedDotState(RedDotAwardID, "BattlePass_Reward")
        local PremiumRewardState = {}
        PremiumRewardState.Num = 0
        local isNormal = BattlePassInfo.battlePassActivateState == BattlePassState.Normal
        if AwardInfo.BattlePassLevel <= tonumber(BattlePassInfo.level) and not isNormal and BattlePassInfo.battlePassData[tostring(AwardInfo.BattlePassLevel)] < AwardState.ReceivePremiun then
          PremiumRewardState.Num = 1
        end
        RedDotData:UpdateRedDotState(RedDotAwardID, PremiumRewardState)
      end
    end
  end
end

function RedDotModule:BindOnDailyRewardChange()
  local ChipRedDotId = "ClimbTower_DailyRewards"
  if climbtowerdata.DailyRewardInfo and climbtowerdata.DailyRewardInfo.rewardCount ~= nil and climbtowerdata.DailyRewardInfo.rewardCount > 0 then
    if not RedDotData:GetRedDotState(ChipRedDotId) then
      RedDotData:CreateRedDotState(ChipRedDotId, ChipRedDotId)
    end
    RedDotData:SetRedDotNum(ChipRedDotId, 1)
  else
    RedDotData:SetRedDotNum(ChipRedDotId, 0)
  end
end

function RedDotModule:BindOnPassRewardStatusChange()
  local ItemRedDotId = "ClimbTower_PassReward_Item"
  local LayerRedDotId = "ClimbTower_PassReward_Layer"
  for Layer, Status in pairs(climbtowerdata.PassRewardStatusTable) do
    if not RedDotData:GetRedDotState(LayerRedDotId .. "_" .. Layer) then
      local LayerRed = RedDotData:CreateRedDotState(LayerRedDotId .. "_" .. Layer, LayerRedDotId)
    end
    if Status and Status.rewardStatusMap then
      for key, value in pairs(Status.rewardStatusMap) do
        if not RedDotData:GetRedDotState(ItemRedDotId .. "_" .. Layer .. "_" .. key) then
          local ItemRed = RedDotData:CreateRedDotState(ItemRedDotId .. "_" .. Layer .. "_" .. key, ItemRedDotId)
        end
        local RedDotState = {
          ParentIdList = {
            LayerRedDotId .. "_" .. Layer
          }
        }
        if 1 == value then
          RedDotState.Num = 1
          RedDotData:UpdateRedDotState(ItemRedDotId .. "_" .. Layer .. "_" .. key, RedDotState)
        else
          RedDotState.Num = 0
          RedDotData:UpdateRedDotState(ItemRedDotId .. "_" .. Layer .. "_" .. key, RedDotState)
        end
      end
    end
  end
end

return RedDotModule
