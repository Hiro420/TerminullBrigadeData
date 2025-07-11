local RougeTestKit = {}
function RougeTestKit.Hello(Args)
  print("Hello from RougeTestKit" .. Args.Msg)
end
local TestSendEvent = function(Event, Data)
  local TestSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URougeTestKit:StaticClass())
  if TestSubsystem then
    local EventName = Event
    local EventData = RapidJsonEncode(Data)
    TestSubsystem:SendEvent(Event, EventData)
  end
end
function RougeTestKit.ChangeLobbyPanelLabelSelected(Args)
  local Label = LogicLobby.GetLabelTagNameByUIName(Args.UIName)
  if Label then
    LogicLobby.ChangeLobbyPanelLabelSelected(Label)
  end
end
local GetViewIDByName = function(InName)
  for id, name in ipairs(ViewNameList) do
    if name == InName then
      return id - 1
    end
  end
  return nil
end
function RougeTestKit.ShowUI(Args)
  local ID = GetViewIDByName(Args.ViewID)
  if ID then
    UIMgr:Show(ID, true)
  end
end
function RougeTestKit.HideUI(Args)
  local ID = GetViewIDByName(Args.ViewID)
  if ID then
    UIMgr:Hide(ID, true)
  end
end
function RougeTestKit.ChangeQuality(Args)
  local Quality = Args.Quality
  local SettingsView = UIMgr:GetLuaFromActiveView(ViewID.UI_GameSettingsMain)
  if SettingsView then
    print("===Rgtk ChangeQuality", Quality)
    local TagName = "Settings.Screen.Quality.Overall"
    LogicGameSetting.SetTempGameSettingsValue(TagName, Quality, false)
    SettingsView:BindOnSaveButtonClicked()
  end
end
function RougeTestKit.Login(Args)
  local Account = Args.Account
  print("===Rgtk Login", Account)
  local LoginView = UIMgr:GetLuaFromActiveView(ViewID.UI_Login)
  if LoginView then
    LoginView.Text_Account:SetText(Account)
    LoginView:OnClicked_Join()
    LoginView.ViewModel:ChangeLoggedInWaitClickStepToNextStep()
  end
end
function RougeTestKit.StartBattle(Args)
  if DataMgr.IsInTeam() then
    LogicTeam.RequestStartGameToServer()
  else
    LogicTeam.RequestCreateTeamToServer({
      GameInstance,
      function()
        LogicTeam.RequestStartGameToServer()
      end
    })
  end
end
function RougeTestKit.PickHero(Args)
  LogicHeroSelect.RequestPickHeroDoneToServer()
end
function RougeTestKit.PrepareBattle(Args)
end
function RougeTestKit.Settlement(Args)
  local SettlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
  print(SettlementView)
  if SettlementView then
    SettlementView.WBP_SettleInComeView:FinishClick()
  end
end
function RougeTestKit.TeleportToLevelTrigger(Args)
  local TriggerIndex = Args.Index
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local ActorSubsystem = UE.URGActorSubsystem.GetSubsystem(GameInstance)
  local AllLevelTriggers = UE.TArray(UE.ARGLevelTrigger)
  ActorSubsystem:GetActorsOfClass(UE.ARGLevelTrigger:StaticClass(), AllLevelTriggers)
  local FoundLevelTrigger
  for i, LevelTrigger in iterator(AllLevelTriggers) do
    if i == TriggerIndex + 1 then
      FoundLevelTrigger = LevelTrigger
      break
    end
  end
  if FoundLevelTrigger then
    local FoundLevelTriggerLocation = FoundLevelTrigger:K2_GetActorLocation()
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    PC.CheatManager:TeleportMe(FoundLevelTriggerLocation.X, FoundLevelTriggerLocation.Y, FoundLevelTriggerLocation.Z)
  end
end
function RougeTestKit.ResetLevelTriggers(Args)
  local TestSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URougeTestKit:StaticClass())
  if TestSubsystem then
    local AllLevelTriggers = UE.TArray(UE.ARGLevelTrigger)
    local ActorSubsystem = UE.URGActorSubsystem.GetSubsystem(GameInstance)
    ActorSubsystem:GetActorsOfClass(UE.ARGLevelTrigger:StaticClass(), AllLevelTriggers)
    TestSubsystem:ResetLevelTrigger(AllLevelTriggers:Num())
  end
end
function RougeTestKit.TeleportToNextLevelTrigger(Args)
  local ResetIfLast = Args.ResetIfLast
  local TestSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.URougeTestKit:StaticClass())
  if TestSubsystem then
    local Ok, NextTriggerIndex = TestSubsystem:Blueprint_NextLevelTrigger()
    if Ok then
      RougeTestKit.TeleportToLevelTrigger({Index = NextTriggerIndex})
    elseif ResetIfLast then
      RougeTestKit.ResetLevelTriggers({})
    end
  end
end
local FindNearestActorOfClass = function(Class, PlayerCamp)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local ActorSubsystem = UE.URGActorSubsystem.GetSubsystem(GameInstance)
  local AllActors = UE.TArray(UE.ARGLevelTrigger)
  ActorSubsystem:GetActorsOfClass(Class, AllActors)
  local ClosestActor
  local ClosestDistance = math.huge
  for _, Actor in iterator(AllActors) do
    if PlayerCamp and Actor:InPlayerCamp() == false then
    else
      local Distance = Character:GetDistanceTo(Actor)
      if ClosestDistance > Distance then
        ClosestDistance = Distance
        ClosestActor = Actor
      end
    end
  end
  return ClosestActor
end
function RougeTestKit.FaceToNearestAI(Args)
  local Teleport = Args.Teleport
  local Enemy = FindNearestActorOfClass(UE.AAICharacterBase, true)
  if Enemy then
    local Ok, Location = UE.URougeTestKit.GetNearestNavMesh(GameInstance, Enemy:K2_GetActorLocation())
    if Ok then
      local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
      if Teleport then
        PC.CheatManager:TeleportMe(Location.X, Location.Y, Location.Z)
      end
    end
    UE.UAutoPlayerBPLibrary.AutoPlayer_LookAtTarget(GameInstance, Enemy, true, true)
  end
end
local GetActorByName = function(Name)
  return UE.URougeTestKit.GetActorByName(Name)
end
function RougeTestKit.GetActorsOfClass(Args)
  local ClassNameList = Args.ClassNameList
  local CallbackID = Args.CallbackID
  local ActorList = {}
  for _, ClassName in ipairs(ClassNameList) do
    local Class = UE.LoadClass(ClassName)
    if Class then
      local ActorSubsystem = UE.URGActorSubsystem.GetSubsystem(GameInstance)
      local AllActors = UE.TArray(UE.AActor)
      ActorSubsystem:GetActorsOfClass(Class, AllActors)
      for _, Actor in iterator(AllActors) do
        ActorList[#ActorList + 1] = {
          ClassName = ClassName,
          ActorName = Actor:GetName()
        }
      end
    end
  end
  TestSendEvent("OnGetActorsOfClass", {ActorList = ActorList, CallbackID = CallbackID})
end
function RougeTestKit.TeleportToActor(Args)
  local ActorName = Args.ActorName
  local Actor = GetActorByName(ActorName)
  if IsValidObj(Actor) then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    if PC then
      local Location = Actor:K2_GetActorLocation()
      PC.CheatManager:TeleportMe(Location.X + 100, Location.Y, Location.Z + 100)
    end
    UE.UAutoPlayerBPLibrary.AutoPlayer_LookAtTarget(GameInstance, Actor, true, false)
  end
end
function RougeTestKit.LookAtTarget(Args)
  local ActorName = Args.ActorName
  local Actor = GetActorByName(ActorName)
  if IsValidObj(Actor) then
    UE.UAutoPlayerBPLibrary.AutoPlayer_LookAtTarget(GameInstance, Actor, true, false)
  end
end
function RougeTestKit.ShopBuyItem(Args)
  local item_id = Args.ItemID
  local all_item_info = LogicShop.GetAllItemInfo()
  if all_item_info then
    all = all_item_info:ToTable()
    print("Rgtk", #all, item_id)
    local item_instance_id = all_item_info[item_id].InstanceId
    LogicShop.BuyShopItem(item_instance_id)
  end
end
function RougeTestKit.RandomSelectModify(Args)
  local Panel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
  if Panel then
    local ItemID = Args.ItemID
    local key = "WBP_GenericModifyChooseItem" .. ItemID
    local ChooseItem = Panel.WBP_GenericModifyChooseItemList[key]
    if ChooseItem then
      ChooseItem:Select()
    else
      Panel:CloseChoosePanel()
    end
  end
end
function RougeTestKit.RandomSelectModifyPack(Args)
  local Panel = RGUIMgr:GetUI(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName)
  if Panel then
    local ItemID = Args.ItemID
    local key = "WBP_GenericModify_Pack_ChooseItem_" .. ItemID
    local ChooseItem = Panel[key]
    if ChooseItem then
      ChooseItem:OnBtnSelectClicked()
    else
      Panel:CloseChoosePanel()
    end
  end
end
function RougeTestKit.OpenLobbyAppearanceView(Args)
  local RoleMain = UIMgr:GetLuaFromActiveView(ViewID.UI_RoleMain)
  if RoleMain then
    RoleMain:BindOnOpenAppearance()
  end
end
function RougeTestKit.LobbySelectHero(Args)
  local HeroID = Args.HeroID
  local Random = Args.Random
  local RoleMain = UIMgr:GetLuaFromActiveView(ViewID.UI_RoleMain)
  if RoleMain then
    local AllCharacterList = LogicRole.GetAllCanSelectCharacterList()
    if Random then
      local RandomIndex = math.random(1, #AllCharacterList)
      local SingleHeroId = AllCharacterList[RandomIndex]
      RoleMain:BindOnChangeRoleItemClicked(SingleHeroId, true, false)
    else
      RoleMain:BindOnChangeRoleItemClicked(HeroID, true, false)
    end
  end
end
function RougeTestKit.LobbyRandomSelectSkin(Args)
  local SkinView = UIMgr:GetLuaFromActiveView(ViewID.UI_Skin)
  local AllSkinEntryWidgets = SkinView.WBP_RoleSkinList.TileViewRoleSkin:GetDisplayedEntryWidgets():ToTable()
  local RandomIndex = math.random(1, #AllSkinEntryWidgets)
  AllSkinEntryWidgets[RandomIndex]:OnSelectClick()
end
return RougeTestKit
