local rapidjson = require("rapidjson")
local WBP_GameTypePanel_C = UnLua.Class()

function WBP_GameTypePanel_C:Construct()
  self.Button_Confirm.OnClicked:Add(self, WBP_GameTypePanel_C.OnClicked_Confirm)
  self.Button_Test.OnClicked:Add(self, WBP_GameTypePanel_C.OnClicked_Test)
  self.Button_Debug.OnClicked:Add(self, WBP_GameTypePanel_C.OnClicked_Debug)
  self.Button_Temp_Mod.OnClicked:Add(self, WBP_GameTypePanel_C.OnClicked_Temp_Mod)
  self:OnLobbyDebugUI()
  self:BindOnLobbyDebugUI(true)
  self.WBP_WorldChoosePanel.WBP_GameTypePanel = self
  self.Image_EnableClicked:SetVisibility(UE.ESlateVisibility.selfHitTestInvisible)
  local settings = UE.URGLobbySettings.GetSettings()
  if not settings then
    return
  end
  self:RequestDBGUnlockGameFloor(settings.InitLockFloor - 1)
end

function WBP_GameTypePanel_C:Destruct()
  self.Button_Confirm.OnClicked:Remove(self, WBP_GameTypePanel_C.OnClicked_Confirm)
  self.Button_Test.OnClicked:Remove(self, WBP_GameTypePanel_C.OnClicked_Test)
  self.Button_Debug.OnClicked:Remove(self, WBP_GameTypePanel_C.OnClicked_Debug)
  self.Button_Temp_Mod.OnClicked:Remove(self, WBP_GameTypePanel_C.OnClicked_Temp_Mod)
  self:BindOnLobbyDebugUI(false)
end

function WBP_GameTypePanel_C:Show(selfHitTestInvisible, Activate)
  self.Overridden.Show(self, selfHitTestInvisible, Activate)
  self:PlayWidgetAnimation(true)
end

function WBP_GameTypePanel_C:OnAnimationFinished(Animation)
  if Animation == self.ani_gametypepanel_out then
    self:HideGameTypePanel()
  end
end

function WBP_GameTypePanel_C:RequestRoleInfo()
end

function WBP_GameTypePanel_C:RequestSetGameFloor(game_floor)
  self.Image_EnableClicked:SetVisibility(UE.ESlateVisibility.Visible)
  local RoomInfo = DataMgr.GetRoomInfo()
  HttpCommunication.Request("roomservice/floor", {
    roomId = RoomInfo.id,
    floor = game_floor
  }, {
    self,
    WBP_GameTypePanel_C.OnSetGameFloorSuccess
  }, {
    self,
    WBP_GameTypePanel_C.OnSetGameFloorFail
  })
end

function WBP_GameTypePanel_C:RequestSetGameMod(game_mod)
  self.Image_EnableClicked:SetVisibility(UE.ESlateVisibility.Visible)
  local RoomInfo = DataMgr.GetRoomInfo()
  HttpCommunication.Request("roomservice/setgamemod", {
    roomId = RoomInfo.id,
    mod = game_mod
  }, {
    self,
    WBP_GameTypePanel_C.OnSetGameModSuccess
  }, {
    self,
    WBP_GameTypePanel_C.OnSetGameModFail
  })
end

function WBP_GameTypePanel_C:RequestDBGUnlockGameFloor(InFloor)
  HttpCommunication.Request("dbg/playerservice/unlockgamefloor", {gamemode = 1, floor = InFloor}, {
    self,
    WBP_GameTypePanel_C.OnDBGUnlockGameFloorSuccess
  }, {
    self,
    WBP_GameTypePanel_C.OnDBGUnlockGameFloorFail
  })
end

function WBP_GameTypePanel_C:BindOnLobbyDebugUI(Bind)
  local setting = UE.URGLobbySettings.GetSettings()
  if setting then
    if Bind then
      setting.LobbyDebugUIDelegate:Add(self, WBP_GameTypePanel_C.OnLobbyDebugUI)
    else
      setting.LobbyDebugUIDelegate:Remove(self, WBP_GameTypePanel_C.OnLobbyDebugUI)
    end
  end
end

function WBP_GameTypePanel_C:OnClicked_Confirm()
  local game_floor = self.WBP_DifficultPanel.ChooseDifficultySlot.TableRow.DifficultyID
  self:RequestSetGameFloor(game_floor)
  self:RequestSetGameMod(1)
end

function WBP_GameTypePanel_C:OnSetGameFloorSuccess()
  print("SetGameFloor Success")
  self.SetGameFloorSuccess = true
  if self.SetGameFloorSuccess and self.SetGameModSuccess then
    self.GameTypeChooseDelegate:Broadcast(self.WBP_WorldChoosePanel.ChooseWorldSlot.TableRow, self.WBP_DifficultPanel.ChooseDifficultySlot.TableRow)
    self.SetGameFloorSuccess = false
    self.SetGameModSuccess = false
    self:PlayWidgetAnimation(false)
  end
end

function WBP_GameTypePanel_C:OnSetGameFloorFail()
  print("SetGameFloor Fail")
  self.SetGameFloorSuccess = false
  self.Image_EnableClicked:SetVisibility(UE.ESlateVisibility.selfHitTestInvisible)
end

function WBP_GameTypePanel_C:OnSetGameModSuccess()
  print("SetGameMod Success")
  self.SetGameModSuccess = true
  if self.SetGameFloorSuccess and self.SetGameModSuccess then
    self.GameTypeChooseDelegate:Broadcast(self.WBP_WorldChoosePanel.ChooseWorldSlot.TableRow, self.WBP_DifficultPanel.ChooseDifficultySlot.TableRow)
    self.SetGameFloorSuccess = false
    self.SetGameModSuccess = false
    self:PlayWidgetAnimation(false)
  end
end

function WBP_GameTypePanel_C:OnSetGameModFail()
  print("SetGameMod Fail")
  self.SetGameModSuccess = false
  self.Image_EnableClicked:SetVisibility(UE.ESlateVisibility.selfHitTestInvisible)
end

function WBP_GameTypePanel_C:OnClicked_Test()
  if self.Overlay_Debug:IsVisible() then
    self.Overlay_Debug:SetVisibility(UE.ESlateVisibility.Hidden)
  else
    self.Overlay_Debug:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_GameTypePanel_C:OnClicked_Debug()
  self.Overlay_Debug:SetVisibility(UE.ESlateVisibility.Hidden)
  local floor = tonumber(self.EditableText_Difficult:GetText())
  self:RequestDBGUnlockGameFloor(floor)
end

function WBP_GameTypePanel_C:OnClicked_Temp_Mod()
  local game_floor = 1
  self:RequestSetGameFloor(game_floor)
end

function WBP_GameTypePanel_C:OnDBGUnlockGameFloorSuccess()
  print("DBGUnlockGameFloor Success")
  self:RequestRoleInfo()
end

function WBP_GameTypePanel_C:OnDBGUnlockGameFloorFailed()
  print("DBGUnlockGameFloor Fail")
end

function WBP_GameTypePanel_C:OnGetRoleSuccess(JsonResponse)
  print("OnGetRoleSuccess", JsonResponse.Content)
  local Response = rapidjson.decode(JsonResponse.Content)
  for i, SingleInfo in ipairs(Response.players) do
    if SingleInfo.roleid == DataMgr.GetUserId() then
      DataMgr.SetBasicInfo(SingleInfo)
    end
  end
  self.WBP_DifficultPanel:InitScrollBox()
end

function WBP_GameTypePanel_C:OnGetRoleFail(ErrorMessage)
  print("OnGetRoleFail", ErrorMessage.ErrorMessage)
  self:RequestRoleInfo()
end

function WBP_GameTypePanel_C:OnLobbyDebugUI()
  local setting = UE.URGLobbySettings.GetSettings()
  if setting then
    if setting.bShowDebugButton then
      self.Button_Test:SetVisibility(UE.ESlateVisibility.Visible)
    else
      self.Button_Test:SetVisibility(UE.ESlateVisibility.Hidden)
    end
  end
end

function WBP_GameTypePanel_C:HideGameTypePanel()
  local rgUIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGUIManager:StaticClass())
  if rgUIManager then
    local findSessionPanel_class = UE.UClass.Load("/Game/Rouge/UI/Lobby/MainLobby/WBP_GameTypePanel.WBP_GameTypePanel_C")
    if findSessionPanel_class then
      self.GameTypeChooseDelegate:Clear()
      rgUIManager:Switch(findSessionPanel_class, false)
    end
  end
end

function WBP_GameTypePanel_C:PlayWidgetAnimation(InAnimation)
  if InAnimation then
    self:PlayAnimation(self.ani_gametypepanel_in)
    self.WBP_DifficultPanel:PlayAnimation(self.WBP_DifficultPanel.ani_difficultypanel_in)
    self.WBP_WorldChoosePanel:PlayAnimation(self.WBP_WorldChoosePanel.ani_worldchoosepanel_in)
  else
    self.WBP_DifficultPanel:PlayAnimation(self.WBP_DifficultPanel.ani_difficultypanel_out)
    self.WBP_WorldChoosePanel:PlayAnimation(self.WBP_WorldChoosePanel.ani_worldchoosepanel_out)
    self:PlayAnimation(self.ani_gametypepanel_out)
  end
end

return WBP_GameTypePanel_C
