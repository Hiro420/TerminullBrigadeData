local WBP_Room_C = UnLua.Class()
local rapidjson = require("rapidjson")
function WBP_Room_C:Construct()
  self.LastClickStartTime = 0
  self.WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Login/WBP_Room.WBP_Room_C")
  self.Button_QuitRoom.OnClicked:Add(self, WBP_Room_C.BindOnQuitRoomButtonClicked)
  self.Button_StartMatch.OnClicked:Add(self, WBP_Room_C.BindOnStartMatchButtonClicked)
  self.RoomInfoTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_Room_C.GetRoomInfo
  }, 1.0, true)
  self:GetRoomInfo()
end
function WBP_Room_C:GetRoomInfo()
  local RoomInfo = DataMgr.GetRoomInfo()
  local Path = "roomservice/myroom?roleID=" .. DataMgr.GetUserId()
  HttpCommunication.RequestByGet(Path, {
    self,
    function(self, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      DataMgr.SetRoomInfo(JsonTable.room)
      self:UpdateRoomInfo()
    end
  }, {
    self,
    function(self, ErrorMessage)
      print("GetRoomInfoFail", ErrorMessage.ErrorMessage)
      local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
      if UIManager then
        UIManager:K2_CloseUI(self.WidgetClass)
      end
      DataMgr.ClearRoomData()
      LogicLobby.CreateLobby()
    end
  })
end
function WBP_Room_C:UpdateRoomInfo()
  local RoomInfo = DataMgr.GetRoomInfo()
  self.Txt_RoomName:SetText("\230\136\191\233\151\180\229\144\141: " .. RoomInfo.name)
  self.Txt_MapName:SetText("\230\136\191\233\151\180\229\156\176\229\155\190ID: " .. tostring(RoomInfo.mapId))
  if RoomInfo.ownerPlayer == DataMgr.GetUserId() then
    self.Button_StartMatch:SetIsEnabled(true)
  else
    self.Button_StartMatch:SetIsEnabled(false)
  end
  self:RefreshPlayerList()
end
function WBP_Room_C:RefreshPlayerList()
  local RoomInfo = DataMgr.GetRoomInfo()
  local PlayerList = {}
  for i, SinglePlayerInfo in ipairs(RoomInfo.players) do
    table.insert(PlayerList, SinglePlayerInfo.id)
  end
end
function WBP_Room_C:OnGetRoleSuccess(JsonResponse)
  local JsonTable = rapidjson.decode(JsonResponse.Content)
  if JsonTable then
    for i, SinglePlayerItem in iterator(self.PlayerList:GetAllChildren()) do
      SinglePlayerItem:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    for i, SinglePlayerInfo in ipairs(JsonTable.players) do
      local Item = self.PlayerList:GetChildAt(i - 1)
      if Item then
        Item:UpdateInfo(SinglePlayerInfo)
        Item:SetVisibility(UE.ESlateVisibility.Visible)
      else
        Item = UE.UWidgetBlueprintLibrary.Create(self, self.WidgetClass)
        Item:UpdateInfo(SinglePlayerInfo)
        self.PlayerList:AddChild(Item)
      end
    end
  end
end
function WBP_Room_C:OnGetRoleFail(ErrorMessage)
  print("OnGetRoleFail", ErrorMessage.ErrorMessage)
end
function WBP_Room_C:BindOnQuitRoomButtonClicked()
  local RoomInfo = DataMgr.GetRoomInfo()
  HttpCommunication.Request("roomservice/quit", {
    roomId = RoomInfo.id
  }, {
    self,
    WBP_Room_C.OnQuitRoomSuccess
  }, {
    self,
    WBP_Room_C.OnQuitRoomFail
  })
end
function WBP_Room_C:OnQuitRoomSuccess(JsonResponse)
  print("OnQuitRoomSuccess" .. JsonResponse.Content)
  local JsonTable = rapidjson.decode(JsonResponse.Content)
  if 0 == JsonTable.code then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
    if UIManager then
      UIManager:K2_CloseUI(self.WidgetClass)
    end
    DataMgr.ClearRoomData()
    LogicLobby.CreateLobby()
  end
end
function WBP_Room_C:OnQuitRoomFail(ErrorMessage)
  print("OnQuitRoomFail" .. ErrorMessage.ErrorMessage)
end
function WBP_Room_C:BindOnStartMatchButtonClicked()
  if UE.UGameplayStatics.GetTimeSeconds(self) - self.LastClickStartTime <= 2.0 then
    print("\229\188\128\229\167\139\230\184\184\230\136\143\230\140\137\233\146\174\231\130\185\229\135\187\229\134\183\229\141\180\228\184\173")
    return
  end
  self.LastClickStartTime = UE.UGameplayStatics.GetTimeSeconds(self)
  local RoomInfo = DataMgr.GetRoomInfo()
  HttpCommunication.StartMatch(RoomInfo.id, {
    self,
    WBP_Room_C.OnStartMatchSuccess
  }, {
    self,
    WBP_Room_C.OnStartMatchFail
  })
end
function WBP_Room_C:OnStartMatchSuccess(JsonResponse)
  print("OnStartMatchSuccess", JsonResponse.Content)
end
function WBP_Room_C:OnStartMatchFail(ErrorMessage)
  print("OnStartMatchFail", ErrorMessage.ErrorMessage)
end
function WBP_Room_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RoomInfoTimer) then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.RoomInfoTimer)
  end
end
return WBP_Room_C
