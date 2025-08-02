local BP_RGCheatManager_C = UnLua.Class()
local rapidjson = require("rapidjson")
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")
local BattleLagacyHandler = require("Protocol.BattleLagacy.BattleLagacyHandler")
local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local BatchCheatCfg = require("GameConfig.Cheat.BatchCheatConfig")
local ChipData = require("Modules.Chip.ChipData")
local ProficiencyHandler = require("Protocol.Proficiency.ProficiencyHandler")
local ChipHandler = require("Protocol.Chip.ChipHandler")
local PuzzleHandler = require("Protocol.Puzzle.PuzzleHandler")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local BeginnerGuideModule = require("Modules.Beginner.BeginnerGuideModule")
local SystemUnlockHandler = require("Protocol.SystemUnlock.SystemUnlockHandler")
local LoginData = require("Modules.Login.LoginData")
local PandoraModule = require("Modules.Pandora.PandoraModule")
local RechargeData = require("Modules.Recharge.RechargeData")
local MaxResourceNum = 10000

function BP_RGCheatManager_C:AddLobbyResourceCurrency(CurrencyId, CurrencyNum)
  local Param = {
    roleId = DataMgr.GetUserId(),
    resources = {
      {
        rid = CurrencyId,
        amount = math.min(CurrencyNum, MaxResourceNum)
      }
    },
    reason = "gm"
  }
  HttpCommunication.Request("dbg/resource/add", Param, {
    self,
    function(self, JsonResponse)
    end
  }, {
    self,
    function()
    end
  }, false, true)
end

function BP_RGCheatManager_C:FinishConsoleAchievement(TaskId, Percent)
  UE.UOnlineGameUtilsLibrary.MakeAchievement(GameInstance, TaskId, Percent)
end

function BP_RGCheatManager_C:NetBarClientPrivilegeType(PrivilegeType)
  DataMgr.SetNetBarPrivilegeType(PrivilegeType)
  EventSystem.Invoke(EventDef.Lobby.OnIigwRequestPrivilege)
end

function BP_RGCheatManager_C:AddChip(CurrencyId, CurrencyNum, BindHeroID, Inscription)
  Inscription = Inscription or 0
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local extraTb = {}
  if tbGeneral and tbGeneral[CurrencyId] and 21 == tbGeneral[CurrencyId].Type then
    extraTb = {
      inscription = Inscription,
      bindheroID = BindHeroID,
      subattr = {
        ["2"] = 4,
        ["6"] = 3
      }
    }
  end
  local Param = {
    roleId = DataMgr.GetUserId(),
    resources = {
      {
        rid = CurrencyId,
        amount = math.min(CurrencyNum, MaxResourceNum),
        extra = RapidJsonEncode(extraTb)
      }
    },
    reason = "GM Add Resource"
  }
  HttpCommunication.Request("dbg/resource/add", Param, {
    self,
    function(self, JsonResponse)
    end
  }, {
    self,
    function()
    end
  }, false, true)
end

function BP_RGCheatManager_C:AddLobbyExp(ExpNum)
  local Param = {value = ExpNum}
  HttpCommunication.Request("dbg/playerservice/addexp", Param, {
    self,
    self.DbgAddExpSuccess
  }, {
    self,
    function()
    end
  }, false, true)
end

function BP_RGCheatManager_C:DbgAddExpSuccess(JsonResponse)
  EventSystem.Invoke(EventDef.Lobby.DBGAddExp)
end

function BP_RGCheatManager_C:UpgradeAllCommonTalent()
  HttpCommunication.Request("dbg/hero/onekeyupgcommontalent", {}, {
    self,
    function()
      LogicTalent.RequestGetCommonTalentsToServer()
    end
  }, {
    self,
    function()
    end
  })
end

function BP_RGCheatManager_C:SetCommonTalentLevel(TalentId, Level)
  local Params = {groupId = TalentId, level = Level}
  local MaxLevel = LogicTalent.GetMaxLevelByTalentId(TalentId)
  if Level > MaxLevel then
    return
  end
  HttpCommunication.Request("dbg/hero/setcommontalentlv", Params, {
    self,
    function()
      LogicTalent.RequestGetCommonTalentsToServer()
    end
  }, {
    self,
    function()
    end
  })
end

function BP_RGCheatManager_C:SetHeroTalentLevel(HeroId, TalentId, Level)
  local Params = {
    heroId = HeroId,
    groupId = TalentId,
    level = Level
  }
  if not DataMgr.IsOwnHero(HeroId) then
    return
  end
  local MaxLevel = LogicTalent.GetMaxLevelByTalentId(TalentId)
  if Level > MaxLevel then
    return
  end
  HttpCommunication.Request("dbg/hero/setherotalentlv", Params, {
    self,
    function()
      LogicTalent.RequestGetHeroTalentsToServer(HeroId)
    end
  }, {
    self,
    function()
    end
  })
end

function BP_RGCheatManager_C:OneKeyAddLobbyResource()
  local GMDeveloperSettings = UE.UGMDeveloperSettings.GetGMDeveloperSettings()
  if not GMDeveloperSettings then
    return
  end
  for i, SingleCommandInfo in pairs(GMDeveloperSettings.LobbyResourceCheatCommandList.CommandList) do
    for i, SingleCheatFunction in pairs(SingleCommandInfo.CheatCommandFunction) do
      UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, SingleCheatFunction)
    end
  end
end

function BP_RGCheatManager_C:LobbyDebugUI()
  local settings = UE.URGLobbySettings.GetLobbySettings()
  if settings then
    settings:BroadcastLobbyDebugUIDelegate()
  end
end

function BP_RGCheatManager_C:SetSoundEnabled(Enabled)
  UE.UAudioManager.SetSoundEnabled(Enabled)
end

function BP_RGCheatManager_C:SetMusicEnabled(Enabled)
  UE.UAudioManager.SetMusicEnabled(Enabled)
end

function BP_RGCheatManager_C:SetVoiceEnabled(Enabled)
  UE.UAudioManager.SetVoiceEnabled(Enabled)
end

function BP_RGCheatManager_C:SetSoundVolume(Volume)
  UE.UAudioManager.SetSoundVolume(Volume)
end

function BP_RGCheatManager_C:SetMusicVolume(Type, Volume)
  if Type then
    UE.UAudioManager.SetBattleMusicVolume(Volume)
  else
    UE.UAudioManager.SetHallMusicVolume(Volume)
  end
end

function BP_RGCheatManager_C:SetVoiceVolume(Volume)
  UE.UAudioManager.SetVoiceVolume(Volume)
end

function BP_RGCheatManager_C:OpenGameMode(Index, ModeId, InFloor)
  LogicTeam.RequestSetTeamDataToServer(Index, ModeId, InFloor)
end

function BP_RGCheatManager_C:PreDeductTicket(SelectNum)
  if not DataMgr.IsInTeam() then
    LogicTeam.RequestCreateTeamToServer({
      self,
      function()
        LogicTeam.RequestPreDeductTicket(SelectNum)
      end
    })
  else
    LogicTeam.RequestPreDeductTicket(SelectNum)
  end
end

function BP_RGCheatManager_C:HideUI(IsHide)
  local VersionSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URGVersionSubsystem:StaticClass())
  if VersionSubsystem and CompareStringsIgnoreCase(VersionSubsystem.Branch, "shipping") then
    return
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:HideAllWidget(IsHide)
  end
end

function BP_RGCheatManager_C:PandoraOpenApp(AppID, AppArgs)
  local Pandora = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGPandoraSubsystem:StaticClass())
  if Pandora then
    Pandora:OpenApp(AppID, AppArgs)
  end
end

function BP_RGCheatManager_C:PandoraCloseApp(AppID)
  local Pandora = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGPandoraSubsystem:StaticClass())
  if Pandora then
    Pandora:CloseApp(AppID)
  end
end

function BP_RGCheatManager_C:PandoraRefreshADData(AdId)
  if 0 == AdId then
    PandoraModule:OnSDKMessage("{\"type\":\"pandoraActTabReady\",\"redPoint\":\"0\",\"appId\":\"6978\",\"appName\":\"actcenter\",\"sortPriority\":\"1\",\"tabName\":\"\231\178\190\233\128\137\"}")
  else
    PandoraModule:OnSDKMessage("{\"type\":\"pandoraActTabReady\",\"redPoint\":\"1\",\"appId\":\"6978\",\"appName\":\"actcenter\",\"sortPriority\":\"1\",\"tabName\":\"\231\178\190\233\128\137\"}")
  end
end

function BP_RGCheatManager_C:PandoraActTabReady(redPoint)
  if 0 == redPoint then
    PandoraModule:OnSDKMessage("{\"type\":\"pandoraActTabReady\",\"redPoint\":\"0\",\"appId\":\"6978\",\"appName\":\"actcenter\",\"sortPriority\":\"1\",\"tabName\":\"\231\178\190\233\128\137\"}")
  else
    PandoraModule:OnSDKMessage("{\"type\":\"pandoraActTabReady\",\"redPoint\":\"1\",\"appId\":\"6978\",\"appName\":\"actcenter\",\"sortPriority\":\"1\",\"tabName\":\"\231\178\190\233\128\137\"}")
  end
end

function BP_RGCheatManager_C:Revert3DLobbyPawnTransform()
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local Pawn = PC:K2_GetPawn()
  if not Pawn then
    return
  end
  if PC.PawnTransform then
    Pawn:K2_SetActorTransform(PC.PawnTransform, false, nil, false)
  else
    local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "SpawnArea", nil)
    local TargetArea
    for index, SingleActor in iterator(AllActors) do
      TargetArea = SingleActor
      break
    end
    if not TargetArea then
      return
    end
    local Transform = UE.FTransform()
    Transform = TargetArea:GetTransform()
    Transform.Translation = TargetArea:RandomPoint()
    Transform.Scale3D = UE.FVector(1.0, 1.0, 1.0)
    Pawn:K2_SetActorTransform(Transform, false, nil, false)
  end
end

function BP_RGCheatManager_C:ChangeNickName(InNickName)
  HttpCommunication.Request("playerservice/nickname", {val = InNickName}, {
    self,
    function()
      HttpCommunication.Request("playerservice/roles", {
        idList = {
          DataMgr.GetUserId()
        }
      }, {
        self,
        function(Target, JsonResponse)
          local Response = rapidjson.decode(JsonResponse.Content)
          for i, SingleInfo in ipairs(Response.players) do
            if SingleInfo.roleid == DataMgr.GetUserId() then
              DataMgr.SetBasicInfo(SingleInfo)
            end
          end
        end
      }, {
        self,
        function()
        end
      })
    end
  }, {
    self,
    function()
      print("\230\148\185\229\144\141\229\164\177\232\180\165")
    end
  })
end

function BP_RGCheatManager_C:CompleteSpecifiedModeFloor(ModeId, WorldId, Floor)
  HttpCommunication.Request("dbg/playergrowth/gamefloor/unlockgamefloor", {
    gamemode = ModeId,
    floor = Floor - 1,
    worldID = WorldId
  }, {
    self,
    function()
      print("DBGUnlockGameFloor Success")
      LogicLobby.RequestGetGameFloorDataToServer()
    end
  }, {
    self,
    function()
      print("DBGUnlockGameFloor Fail")
    end
  })
end

function BP_RGCheatManager_C:SetHeroProy(heroId, Profy)
  HttpCommunication.Request("dbg/hero/setheroprofy", {heroId = heroId, profy = Profy}, {
    self,
    function()
      print("SetHeroProy Success")
      LogicRole.RequestMyHeroInfoToServer()
    end
  }, {
    self,
    function()
      print("SetHeroProy Fail")
    end
  })
end

function BP_RGCheatManager_C:OpenBeginnerGuidanceLogic(IsExecute)
  LogicLobby.IsExecuteBeginnerGuidance = IsExecute
end

function BP_RGCheatManager_C:ForceOpenBeginnerGuidanceLevel(...)
  LogicLobby.IsForceOpenBeginnerGuidanceLevel = true
end

function BP_RGCheatManager_C:SetFakeTime(Date, TargetTime)
  print("\232\174\190\231\189\174\230\151\182\233\151\180", Date .. " " .. TargetTime)
  HttpCommunication.Request("dbg/hotfix/setfaketime", {
    faketime = Date .. " " .. TargetTime
  }, {
    self,
    function()
      print("\230\156\141\229\138\161\229\153\168\232\174\190\231\189\174\230\151\182\233\151\180\230\136\144\229\138\159 \232\175\183\232\176\131\231\148\168 ResetFakeTime\229\145\189\228\187\164 \229\133\179\233\151\173")
    end
  }, {
    self,
    function()
      print("\232\174\190\231\189\174\230\151\182\233\151\180\229\164\177\232\180\165")
    end
  })
end

function BP_RGCheatManager_C:ResetFakeTime()
  HttpCommunication.RequestByGet("dbg/hotfix/resetfaketime", {
    self,
    function()
      print("\233\135\141\231\189\174\230\151\182\233\151\180\230\136\144\229\138\159")
    end
  }, {
    self,
    function()
      print("\233\135\141\231\189\174\230\151\182\233\151\180\229\164\177\232\180\165")
    end
  })
end

function BP_RGCheatManager_C:SendMail(Title, Content, ItemId, ItemNum)
  local Params = {
    request = {
      Detail = {content = Content, title = Title},
      attach = {
        {
          itemId = ItemId,
          itemNum = tonumber(ItemNum)
        }
      },
      mailType = "SYSTEM"
    },
    roleId = {
      DataMgr.GetUserId()
    }
  }
  if UE.UKismetStringLibrary.IsEmpty(ItemId) or UE.UKismetStringLibrary.IsEmpty(ItemNum) then
    Params.request.attach = nil
  end
  HttpCommunication.Request("dbg/mail/send", Params, {
    self,
    function()
      print("SendMailSuccess!")
    end
  }, {
    self,
    function()
      print("SendMailFail!")
    end
  })
end

function BP_RGCheatManager_C:SendMailByTemplate(TemplateId)
  local Params = {
    request = {
      TemplateID = tonumber(TemplateId),
      mailType = "SYSTEM"
    },
    roleId = {
      DataMgr.GetUserId()
    }
  }
  HttpCommunication.Request("dbg/mail/send", Params, {
    self,
    function()
      print("SendMailSuccess!")
    end
  }, {
    self,
    function()
      print("SendMailFail!")
    end
  })
end

function BP_RGCheatManager_C:DeleteMail(Id)
  HttpCommunication.Request("dbg/mail/gmdelete", {
    ids = {Id}
  }, {
    GameInstance,
    function()
      print("DeleteMail Success!")
    end
  }, {
    GameInstance,
    function()
      print("DeleteMail Fail!")
    end
  })
end

function BP_RGCheatManager_C:DeleteMail(Id)
  HttpCommunication.Request("dbg/mail/gmdelete", {
    ids = {Id}
  }, {
    GameInstance,
    function()
      print("DeleteMail Success!")
    end
  }, {
    GameInstance,
    function()
      print("DeleteMail Fail!")
    end
  })
end

function BP_RGCheatManager_C:DoFinishAndGetAllProfyTaskByHeroId(HeroId)
  local tbProfyTask = LuaTableMgr.GetLuaTableByName(TableNames.TBProfyTask)
  local tbTaskGroup = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  if tbProfyTask and tbTaskGroup then
    local profyTaskList = {}
    for k, v in pairs(tbProfyTask) do
      if v.HeroID == HeroId then
        table.insert(profyTaskList, v)
      end
    end
    table.sort(profyTaskList, function(A, B)
      if A.Level ~= B.Level then
        return A.Level < B.Level
      end
      return A.TaskGroupID < B.TaskGroupID
    end)
    local taskGroupToTaskId = {}
    local count = 0
    local groupAwardCount = 0
    local reciveAwardGroupCallback = function(GroupId, taskId)
      if taskGroupToTaskId[GroupId] then
        table.insert(taskGroupToTaskId[GroupId], taskId)
      else
        taskGroupToTaskId[GroupId] = {taskId}
      end
      if 4 == #taskGroupToTaskId[GroupId] then
        count = count + 1
        print("DoFinishAndGotAllProfyTaskByHeroId ReceiveTaskGroupAward GroupId:", GroupId)
      end
      if 8 == count then
        UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
          GameInstance,
          function()
            for i, v in ipairs(profyTaskList) do
              local JsonParams = {
                groupID = v.TaskGroupID
              }
              HttpCommunication.Request("task/receivereward/taskgroup", JsonParams, {
                GameInstance,
                function(Target, JsonResponse)
                  print("DoFinishAndGotAllProfyTaskByHeroId ReceiveAward Group Succ", v.TaskGroupID)
                  groupAwardCount = groupAwardCount + 1
                  if 8 == groupAwardCount then
                    UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
                      GameInstance,
                      function()
                        Logic_MainTask.PullTask()
                      end
                    })
                  end
                end
              }, {
                GameInstance,
                function()
                  print("DoFinishAndGotAllProfyTaskByHeroId ReceiveAward Group Failed", v.TaskGroupID)
                end
              })
            end
          end
        })
      end
    end
    local callback = function(GroupId, taskId)
      print("DoFinishAndGotAllProfyTaskByHeroId ReceiveAward", GroupId, taskId)
      local JsonParams = {groupID = GroupId, taskID = taskId}
      HttpCommunication.Request("task/receivereward/task", JsonParams, {
        GameInstance,
        function(Target, JsonResponse)
          reciveAwardGroupCallback(GroupId, taskId)
          print("DoFinishAndGotAllProfyTaskByHeroId ReceiveAward Succ", GroupId, taskId)
        end
      }, {
        GameInstance,
        function()
          print("DoFinishAndGotAllProfyTaskByHeroId ReceiveAwardFaill", GroupId, taskId)
        end
      })
    end
    for i, v in ipairs(profyTaskList) do
      if tbTaskGroup[v.TaskGroupID] then
        for idxTasklist, vTasklist in ipairs(tbTaskGroup[v.TaskGroupID].tasklist) do
          HttpCommunication.Request("dbg/task/finish", {
            groupID = v.TaskGroupID,
            taskID = vTasklist
          }, {
            GameInstance,
            function()
              callback(v.TaskGroupID, vTasklist)
              print("DoFinishAndGotAllProfyTaskByHeroId DoFinishMainTask Success!", v.TaskGroupID, vTasklist)
            end
          }, {
            GameInstance,
            function()
              print("DoFinishAndGotAllProfyTaskByHeroId DoFinishMainTask Fail!", v.TaskGroupID, vTasklist)
            end
          })
          print("DoFinishAndGotAllProfyTaskByHeroId DoFinishMainTask", v.TaskGroupID, vTasklist)
        end
      end
    end
  end
end

function BP_RGCheatManager_C:DoFinishMainTask(GroupId, TaskId)
  if nil == TaskId or "" == TaskId then
    local TBTaskGroupTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
    local TBTaskGroupData = TBTaskGroupTable[tonumber(GroupId)]
    if TBTaskGroupData then
      for j, Id in ipairs(TBTaskGroupData.tasklist) do
        HttpCommunication.Request("dbg/task/finish", {groupID = GroupId, taskID = Id}, {
          GameInstance,
          function()
            print("DoFinishMainTask Success!")
          end
        }, {
          GameInstance,
          function()
            print("DoFinishMainTask Fail!")
          end
        })
      end
    end
    return
  end
  HttpCommunication.Request("dbg/task/finish", {groupID = GroupId, taskID = TaskId}, {
    GameInstance,
    function()
      print("DoFinishMainTask Success!")
    end
  }, {
    GameInstance,
    function()
      print("DoFinishMainTask Fail!")
    end
  })
end

function BP_RGCheatManager_C:DoFinishAllMainTasks()
  local TBMainStoryLineTable = LuaTableMgr.GetLuaTableByName(TableNames.TBMainStoryLine)
  local MainStoryGroupId = 1
  if not TBMainStoryLineTable[MainStoryGroupId] then
    return
  end
  local TBTaskGroupTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  local TaskGroupList = TBMainStoryLineTable[MainStoryGroupId].taskgrouplist
  for i, TaskGroupId in ipairs(TaskGroupList) do
    print("ljj# Try finish all task with TaskGroupId=", TaskGroupId)
    local TBTaskGroupData = TBTaskGroupTable[TaskGroupId]
    for j, TaskId in ipairs(TBTaskGroupData.tasklist) do
      self:DoFinishMainTask(TaskGroupId, TaskId)
    end
  end
end

function BP_RGCheatManager_C:SwitchFakeTeamDataWithMe()
  LogicLobby.IsFakeTeamData = LogicLobby.IsFakeTeamData == nil and true or not LogicLobby.IsFakeTeamData
  if LogicLobby.IsFakeTeamData then
    LogicTeam.RequestGetMyTeamDataToServer()
  end
end

function BP_RGCheatManager_C:CheckSensitiveWords(Path)
  if not Path or "" == Path then
    Path = "E:\\SensitiveWords.txt"
  end
  print("\232\175\187\229\143\150\232\183\175\229\190\132\228\184\186\239\188\154", Path)
  local file = io.open(Path, "r")
  if not file then
    print("\230\151\160\230\179\149\230\137\147\229\188\128\230\150\135\228\187\182")
    return
  end
  local fileWrite = io.open("E:\\NotSensitiveWords.txt", "w")
  if not fileWrite then
    print("fileWrite Is nil")
  end
  for line in file:lines() do
    print(line)
    local OnlineMessageSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlineMessageSystem:StaticClass())
    if OnlineMessageSystem then
      local func = function(Target, bWasSuccessful, OutputMessage)
        if bWasSuccessful then
          if OutputMessage == line then
            print("CheckSensitiveWords Pass", line)
            if fileWrite then
              fileWrite:write(line .. "\n")
            end
          else
            print("CheckSensitiveWords No Pass", line)
          end
        else
          print("CheckSensitiveWords Failed", line)
        end
      end
      OnlineMessageSystem:SanitizeMessage(line, {
        GameInstance,
        func
      })
    end
  end
end

function BP_RGCheatManager_C:CheatComLink(ComLinkRowName)
  ComLink(ComLinkRowName)
end

function BP_RGCheatManager_C:CheatOpenThreedUI()
  UIMgr:Show(ViewID.UI_ThreeDUITest)
end

function BP_RGCheatManager_C:CheatSetBattleLagacyList(Id1, Id2, Id3)
  BattleLagacyHandler:Setbattlelagacylist(Id1, Id2, Id3)
end

function BP_RGCheatManager_C:CheatSetBattleLagacy(Id)
  BattleLagacyHandler:Setbattlelagacy(Id)
end

function BP_RGCheatManager_C:SetVoiceLanguage(NewCulture)
  UE.UAudioManager.SetVoiceLanguage(NewCulture)
end

function BP_RGCheatManager_C:ChangeCulture(NewCulture)
  local LocalizationModule = ModuleManager:Get("LocalizationModule")
  LocalizationModule:LuaCustomSetCurrentCulture(NewCulture, false)
end

function BP_RGCheatManager_C:ToggleUIHideThenDestroy()
  UIMgr:ToggleViewHideThenDestroy()
end

function BP_RGCheatManager_C:AddHeroProfyExp(Exp)
  local Params = {
    exp = Exp,
    roleID = DataMgr.GetUserId()
  }
  HttpCommunication.Request("dbg/hero/addheroprofyexp", Params, {
    GameInstance,
    function()
      print("AddHeroProfyExp Success!")
      LogicRole.RequestMyHeroInfoToServer()
    end
  }, {
    GameInstance,
    function()
      print("AddHeroProfyExp Fail!")
    end
  })
end

function BP_RGCheatManager_C:FinishBeginnerBD()
  EventSystem.Invoke(EventDef.WSMessage.HeroesExpired, {
    DataMgr.GetMyHeroInfo().equipHero
  })
end

function BP_RGCheatManager_C:UnlockChipSlot(Slot)
  local LobbyModule = ModuleManager:Get("LobbyModule")
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if tbChipSlot[Slot] then
    if 0 == tbChipSlot[Slot].Type then
      local viewData = {
        ViewID = ViewID.UI_ChipSlotUnlockView,
        Params = {Slot}
      }
      LobbyModule:PushView(viewData)
    elseif 1 == tbChipSlot[Slot].Type then
      local viewData = {
        ViewID = ViewID.UI_ChipSeasonSlotUnlockView,
        Params = {Slot}
      }
      LobbyModule:PushView(viewData)
    end
  end
end

function BP_RGCheatManager_C:PrintServerTime()
  local url = "dbg/hotfix/getservertime"
  HttpCommunication.Request(url, {}, {
    self,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if JsonTable and JsonTable.timestamp then
        print("\229\189\147\229\137\141\230\156\141\229\138\161\229\153\168\230\151\182\233\151\180(" .. tostring(Timezone()) .. ")\239\188\154", TimestampToDateTimeText(tonumber(JsonTable.timestamp)), "\230\151\182\233\151\180\230\136\179\239\188\154", JsonTable.timestamp)
        UE4.UKismetSystemLibrary.PrintString(self, "\229\189\147\229\137\141\230\156\141\229\138\161\229\153\168\230\151\182\233\151\180(" .. tostring(Timezone()) .. ")\239\188\154" .. "     " .. TimestampToDateTimeText(tonumber(JsonTable.timestamp)))
        ShowWaveWindow(100001, {
          TimestampToDateTimeText(tonumber(JsonTable.timestamp))
        })
      end
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function BP_RGCheatManager_C:CompleteSpecifiedModeFloorWithCallback(WorldId, Floor, Callback)
  HttpCommunication.Request("dbg/playergrowth/gamefloor/unlockgamefloor", {
    gamemode = 1001,
    floor = Floor - 1,
    worldID = WorldId
  }, {
    self,
    function()
      print("DBGUnlockGameFloor Success")
      LogicLobby.RequestGetGameFloorDataToServer()
      if Callback then
        Callback()
      end
    end
  }, {
    self,
    function()
      print("DBGUnlockGameFloor Fail")
      if Callback then
        Callback()
      end
    end
  })
end

function BP_RGCheatManager_C:SetHeroProyWithCallback(heroId, Profy, Callback)
  HttpCommunication.Request("dbg/hero/setheroprofy", {heroId = heroId, profy = Profy}, {
    self,
    function()
      print("SetHeroProy Success")
      LogicRole.RequestMyHeroInfoToServer()
      if Callback then
        Callback()
      end
    end
  }, {
    self,
    function()
      print("SetHeroProy Fail")
      if Callback then
        Callback()
      end
    end
  })
end

function BP_RGCheatManager_C:DoFinishMainTaskWithCallback(GroupId, TaskId, Callback)
  HttpCommunication.Request("dbg/task/finish", {groupID = GroupId, taskID = TaskId}, {
    GameInstance,
    function()
      print("DoFinishMainTask Success!")
      if Callback then
        Callback()
      end
    end
  }, {
    GameInstance,
    function()
      print("DoFinishMainTask Fail!")
    end
  })
end

function BP_RGCheatManager_C:CheatAddLobbyResource(CurrencyId, CurrencyNum, Callback)
  local Param = {
    roleId = DataMgr.GetUserId(),
    resources = {
      {
        rid = CurrencyId,
        amount = math.min(CurrencyNum, 100000)
      }
    },
    reason = "gm"
  }
  HttpCommunication.Request("dbg/resource/add", Param, {
    self,
    function(self, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if Callback then
        Callback()
      end
    end
  }, {
    self,
    function()
      if Callback then
        Callback()
      end
    end
  }, false, true)
end

function BP_RGCheatManager_C:CheatAddChip(CurrencyId, CurrencyNum, BindHeroID, Inscription, SubAttr, Callback)
  Inscription = Inscription or 0
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local extraTb = {}
  if tbGeneral and tbGeneral[CurrencyId] and 21 == tbGeneral[CurrencyId].Type then
    local subAttr = {
      ["2"] = 4,
      ["6"] = 3
    }
    if SubAttr then
      subAttr = {}
      for i, v in ipairs(SubAttr) do
        subAttr[tostring(v.attrID)] = v.value
      end
    end
    extraTb = {
      inscription = Inscription,
      bindheroID = BindHeroID,
      subattr = subAttr
    }
  end
  local Param = {
    roleId = DataMgr.GetUserId(),
    resources = {
      {
        rid = CurrencyId,
        amount = math.min(CurrencyNum, MaxResourceNum),
        extra = RapidJsonEncode(extraTb)
      }
    },
    reason = "GM Add Resource"
  }
  HttpCommunication.Request("dbg/resource/add", Param, {
    self,
    function(self, JsonResponse)
      if Callback then
        Callback()
      end
    end
  }, {
    self,
    function()
      if Callback then
        Callback()
      end
    end
  }, false, true)
end

function BP_RGCheatManager_C:BatchCheatCB(CfgId)
  print("Start BatchCheatCB...........", CfgId)
  if BatchCheatCfg.ChipCfgListMap[CfgId] then
    local count = #BatchCheatCfg.ChipCfgListMap[CfgId]
    local callbackIdx = 1
    for i, v in ipairs(BatchCheatCfg.ChipCfgListMap[CfgId]) do
      local callback = function()
        if callbackIdx == count then
          local GetChipBagCllback = function()
            for idx, value in ipairs(BatchCheatCfg.ChipCfgListMap[CfgId]) do
              local chipBagItemData = ChipData:CreateChipBagItemData(value.ResId, value.SubAttr, {}, value.BindHeroID or 0, 0, value.Inscription, -1)
              for idxChipBag, vChipBag in pairs(ChipData.ChipBags) do
                if ChipData:CheckChipEqual(chipBagItemData, vChipBag) then
                  ChipHandler.RequestEquipChip(idxChipBag, value.EquipHeroID, value.EquipSlot)
                  break
                end
              end
            end
          end
          ChipHandler.RequestGetHeroChipBag(GetChipBagCllback)
        else
          callbackIdx = callbackIdx + 1
        end
      end
      print("Start CheatAddChip...........", v.ResId, v.Num, v.BindHeroID, v.Inscription, v.SubAttr)
      self:CheatAddChip(v.ResId, v.Num, v.BindHeroID or 0, v.Inscription, v.SubAttr, callback)
    end
  end
  if BatchCheatCfg.TalentCfgListMap[CfgId] then
    local callback = function()
      local TempParams = {}
      for i, v in ipairs(BatchCheatCfg.TalentCfgListMap[CfgId]) do
        local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTalent, v.TalentId)
        if result then
          local talentLvRowMap = LogicTalent.GetTalentTableRow(row.GroupID)
          for idx = 1, row.Level do
            if talentLvRowMap[idx] then
              local TempTable = {}
              TempTable.groupId = row.GroupID
              TempTable.level = idx
              table.insert(TempParams, TempTable)
            end
          end
        end
      end
      local FinalParams = {}
      FinalParams.Talents = TempParams
      if table.count(TempParams) > 0 then
        LogicTalent.RequestUpgradeCommonTalentToServer(FinalParams)
      end
    end
    self:CheatAddLobbyResource(99994, 100000, callback)
  end
  if BatchCheatCfg.PlotFragmentCfg[CfgId] then
    for i, v in ipairs(BatchCheatCfg.PlotFragmentCfg[CfgId]) do
      local taskGroupId = v.TaskGroupID
      local taskId = v.TaskID
      local callback = function()
        Logic_MainTask.ReceiveAward(taskGroupId, taskId, false, nil, nil, true)
      end
      local result, row = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData, v.TaskGroupID)
      if result then
        self:DoFinishMainTaskWithCallback(v.TaskGroupID, v.TaskID, callback)
      end
    end
  end
  if BatchCheatCfg.ProfyCfgListMap[CfgId] then
    for key, value in pairs(BatchCheatCfg.ProfyCfgListMap[CfgId]) do
      local callback = function()
        for i = 1, value.ProfyLv do
          ProficiencyHandler:RequestGetHeroProfyLevelRewardToServer(key, i)
          ProficiencyHandler:RequestGetHeroProfyStoryRewardToServer(key, i)
        end
      end
      self:SetHeroProyWithCallback(key, value.ProfyLv, callback)
    end
  end
  if BatchCheatCfg.EXPCfg[CfgId] then
    self:CheatAddLobbyResource(99996, BatchCheatCfg.EXPCfg[CfgId])
  end
end

function BP_RGCheatManager_C:BatchCheat(CfgId)
  local result, batchCheatInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBLobbyBatchCheat, CfgId)
  if not result then
    return
  end
  self:FinishAllBeginnerGuide()
  local HeroId = DataMgr.GetMyHeroInfo().equipHero
  local CfgHeroId = tonumber(batchCheatInfo.HeroID)
  if HeroId ~= CfgHeroId then
    local CharacterRow = LogicRole.GetCharacterTableRow(CfgHeroId)
    local HeroResId = CharacterRow.ResourceId
    if not LogicRole.CheckCharacterUnlock(CfgHeroId) then
      self:CheatAddLobbyResource(HeroResId, 1, function()
        self:BatchCheat(CfgId)
      end)
    else
      self:RequestEquipHeroToServer(CfgHeroId, function()
        self:BatchCheat(CfgId)
      end)
    end
    return
  end
  local batchWorldInfo = batchCheatInfo.World
  for i, v in ipairs(batchWorldInfo) do
    for i = 2, v.value do
      self:CompleteSpecifiedModeFloor(1001, v.key, i)
    end
  end
  self:SetHeroProy(HeroId, batchCheatInfo.Proficiencylevel)
  for i = 1, batchCheatInfo.Proficiencylevel do
    if not ProficiencyData:IsCurProfyLevelRewardReceived(HeroId, i) then
      ProficiencyHandler:RequestGetHeroProfyLevelRewardToServer(HeroId, i)
    end
  end
  local batchPuzzleInfo = batchCheatInfo.Puzzle
  PuzzleHandler:RequestUnEquipHeroAllPuzzleToServer(HeroId)
  local resources = {}
  for i, v in ipairs(batchPuzzleInfo) do
    table.insert(resources, {
      rid = v.Id,
      amount = 1
    })
  end
  table.insert(resources, {rid = 99010, amount = 999999})
  table.insert(resources, {rid = 99011, amount = 999999})
  table.insert(resources, {rid = 99012, amount = 999999})
  table.insert(resources, {rid = 99013, amount = 999999})
  table.insert(resources, {rid = 99014, amount = 999999})
  table.insert(resources, {rid = 99015, amount = 999999})
  local Param = {
    roleId = DataMgr.GetUserId(),
    resources = resources,
    reason = "GM BatchCheat"
  }
  HttpCommunication.Request("dbg/resource/add", Param, {
    self,
    function(self, JsonResponse)
      UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        GameInstance,
        function()
          for i, v in ipairs(batchPuzzleInfo) do
            local PuzzleId = PuzzleData:GetUnEquipPuzzleUidByResIdAndLevel(v.Id, v.Level)
            if PuzzleId then
              PuzzleData:SetPuzzleEquipHeroId(PuzzleId, HeroId)
              PuzzleHandler:RequestEquipPuzzleToServer(PuzzleId, HeroId, v.Pos)
              PuzzleHandler:RequestUpgradePuzzleToServer(PuzzleId, v.Level)
            end
          end
        end
      }, 0.5, false)
    end
  }, {
    self,
    function()
    end
  }, false, true)
  self:CheatAddLobbyResource(99994, 100000, function()
    local batchTalentInfo = batchCheatInfo.Talent
    local TempParams = {}
    for i, v in ipairs(batchTalentInfo) do
      local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTalent, v)
      if result then
        local talentLvRowMap = LogicTalent.GetTalentTableRow(row.GroupID)
        for idx = 1, row.Level do
          if talentLvRowMap[idx] then
            local TempTable = {}
            TempTable.groupId = row.GroupID
            TempTable.level = idx
            table.insert(TempParams, TempTable)
          end
        end
      end
    end
    local FinalParams = {}
    FinalParams.Talents = TempParams
    if table.count(TempParams) > 0 then
      LogicTalent.RequestUpgradeCommonTalentToServer(FinalParams)
    end
  end)
  local batchCollectionInfo = batchCheatInfo.Collection
  local resources = {}
  for i, v in ipairs(batchCollectionInfo) do
    table.insert(resources, {rid = v, amount = 1})
  end
  local Param = {
    roleId = DataMgr.GetUserId(),
    resources = resources,
    reason = "GM BatchCheat"
  }
  HttpCommunication.Request("dbg/resource/add", Param, {
    self,
    function(self, JsonResponse)
    end
  }, {
    self,
    function()
    end
  }, false, true)
end

function BP_RGCheatManager_C:CheatChatSystem(SystemMsgID, MsgType)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemMsg, tonumber(SystemMsgID))
  if not result then
    return
  end
  local msg = {
    systemMsgID = tonumber(SystemMsgID),
    params = {""},
    msgType = MsgType
  }
  local url = "dbg/chatservice/sendsystemmsg"
  HttpCommunication.Request(url, msg, {
    GameInstance,
    function(Target, JsonResponse)
    end
  }, {
    GameInstance,
    function()
    end
  })
end

function BP_RGCheatManager_C:ForceActivateGuide(GuideId)
  BeginnerGuideModule:ForceInitByGuideId(GuideId)
end

function BP_RGCheatManager_C:RequestUnlockSystem(SysId)
  SystemUnlockHandler:RequestUnlockSystem(SysId)
end

function BP_RGCheatManager_C:FinishAllFragmentTask()
  local ClueTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClue)
  local TaskGroupTable = LuaTableMgr.GetLuaTableByName(TableNames.TBTaskGroupData)
  for k, ClueInfo in pairs(ClueTable) do
    local taskGroupId = ClueInfo.taskGroupID
    local taskIdList = TaskGroupTable[taskGroupId].tasklist
    for i, taskId in ipairs(taskIdList) do
      local taskState = Logic_MainTask.GetStateByTaskId(taskId)
      if taskState ~= ETaskState.Finished and taskState ~= ETaskState.GotAward then
        self:DoFinishMainTask(taskGroupId, taskId)
      end
    end
  end
end

function BP_RGCheatManager_C:FinishAllBeginnerGuide()
  local TotalGuideTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)
  for GuideId, GuideInfo in pairs(TotalGuideTable) do
    BeginnerGuideModule:FinishGuide(GuideId)
  end
end

function BP_RGCheatManager_C:BuyMidasProduct(ProductId, Quantity)
  if not UE.URGPlatformFunctionLibrary.IsLIPassEnabled() then
    local OnlinePurchaseSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.UOnlinePurchaseSystem:StaticClass())
    if not OnlinePurchaseSystem then
      return
    end
    local OnlinePurchaseItem = UE.FOnlinePurchaseItem()
    OnlinePurchaseItem.Id = ProductId
    OnlinePurchaseItem.Quantity = Quantity
    local Items = {OnlinePurchaseItem}
    local Result = OnlinePurchaseSystem:AsyncPurchaseProducts(Items, RapidJsonEncode({
      roleID = DataMgr.GetUserId()
    }), LoginData:GetLobbyServerId())
    print("BP_RGCheatManager_C:BuyMidasProduct", Result)
  else
    if not ProductId or not Quantity then
      return
    end
    UE.URGPlatformFunctionLibrary.InitCTIUserInfo(DataMgr.GetUserId(), LoginData:GetLobbyServerId())
    local Param = {
      language = "zh-CN",
      products = {
        {productID = ProductId, quantity = Quantity}
      },
      transaction = {
        currencyType = "CNY",
        payChannel = "os_steam",
        region = "CN"
      }
    }
    HttpCommunication.Request("pay/oversea/createorder", Param, {
      GameInstance,
      function(Target, JsonResponse)
        print("CreateOrder Success!", JsonResponse.Content)
        local JsonTable = rapidjson.decode(JsonResponse.Content)
        UE.URGPlatformFunctionLibrary.CTIPay(JsonTable.payInfo)
      end
    })
  end
end

function BP_RGCheatManager_C:GetMidasProductInfo(ProductId)
  if not ProductId then
    return
  end
  if UE.URGPlatformFunctionLibrary.IsLIPassEnabled() then
    UE.URGPlatformFunctionLibrary.InitCTIUserInfo(DataMgr.GetUserId(), LoginData:GetLobbyServerId())
    UE.URGPlatformFunctionLibrary.CTIGetProductInfo({ProductId})
  end
end

function BP_RGCheatManager_C:RequestEquipHeroToServer(HeroId, Callback)
  LogicRole.RequestEquipHeroToServer(HeroId, Callback)
end

function BP_RGCheatManager_C:EnableChannelInfoLog(bEnable)
  DataMgr.EnableChannelInfoLog = bEnable
end

function BP_RGCheatManager_C:ShowUI(UIName, bHideOther)
  local SeasonModule = ModuleManager:Get("SeasonModule")
  SeasonModule.bShowSeasonModeSelectPop = true
  UIMgr:Show(ViewID[UIName], bHideOther)
end

function BP_RGCheatManager_C:CheatShowCustomerServiceUrl(bShow)
  EventSystem.Invoke(EventDef.CustomerService.CheatShow, bShow > 0)
end

function BP_RGCheatManager_C:CheatSwitchTestINTLUrl(bTest)
  EventSystem.Invoke(EventDef.CustomerService.CheatSwitchTest, bTest > 0)
end

function BP_RGCheatManager_C:SetPlayerInvisible(Type, Invisible)
  DataMgr.SetPlayerInvisible(Type, Invisible)
end

function BP_RGCheatManager_C:GetPlayerInvisible(Type)
  return DataMgr.GetPlayerInvisible(Type)
end

function BP_RGCheatManager_C:SetCurRechargeTimestamp(Timestamp)
  RechargeData.SetCurRechargeTimestamp(Timestamp)
end

function BP_RGCheatManager_C:GetCurRechargeTimestamp()
  local DateStr1 = os.date("%Y\229\185\180%m\230\156\136%d\230\151\165", RechargeData.GetMonthRechargeTimestamp())
  local DateStr2 = os.date("%Y\229\185\180%m\230\156\136%d\230\151\165", RechargeData.GetCurRechargeTimestamp())
  print("MonthRechargeTimestamp:", DateStr1)
  print("CurRechargeTimestamp:", DateStr2)
end

function BP_RGCheatManager_C:CheatMarquee(Content, Interval, RepeatCount, PriorityLevel)
  local MarqueeData = UE.FMarqueeData()
  MarqueeData = UE.URGBlueprintLibrary.InitMarqueeData(nil, Content, Interval, RepeatCount, PriorityLevel)
  UE.URGMarqueeSubsystem.Get(GameInstance):AddMarqueeData(MarqueeData)
  UIMgr.ActiveViews:Get(ViewID.UI_Marquee):InitMarquee()
end

return BP_RGCheatManager_C
