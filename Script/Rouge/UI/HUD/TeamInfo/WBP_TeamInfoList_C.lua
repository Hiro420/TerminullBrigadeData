local WBP_TeamInfoList_C = UnLua.Class()

function WBP_TeamInfoList_C:Construct()
  self.Overridden.Construct(self)
  self:SetRevivalInfo()
  self.TeamTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    WBP_TeamInfoList_C.InitTeamInfoList
  }, 1.0, true)
  ListenObjectMessage(nil, GMP.MSG_Game_PlayerRevivalSuccess, self, self.Bind_MSG_Game_PlayerRevivalSuccess)
end

function WBP_TeamInfoList_C:InitTeamInfoList()
  local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
  if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, true)
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/HUD/TeamInfo/WBP_TeamInfoItem.WBP_TeamInfoItem_C")
  local CurNum = 0
  for i, v in iterator(TeamSubsystem.TeamInfo.AllPlayerInfos) do
    if v.roleid ~= Character:GetUserId() then
      local Item = self.TeamInfoList:GetChildAt(CurNum)
      if not Item then
        Item = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
        self.TeamInfoList:AddChild(Item)
      else
        Item:SetVisibility(UE.ESlateVisibility.Visible)
      end
      Item:InitInfo(v, i, self.IsTeamRevivalMode)
      local VerticalSlot = UE.UWidgetLayoutLibrary.SlotAsVerticalBoxSlot(Item)
      VerticalSlot:SetPadding(self.ItemPadding)
      CurNum = CurNum + 1
    else
    end
  end
  local ItemInvalid = self.TeamInfoList:GetChildAt(CurNum)
  if ItemInvalid then
    UpdateVisibility(ItemInvalid, false)
  end
end

function WBP_TeamInfoList_C:UpdateReadyState()
  print("WBP_TeamInfoList_C:UpdateReadyState()")
  for i, SingleWidget in iterator(self.TeamInfoList:GetAllChildren()) do
    SingleWidget:UpdateReadyState()
  end
end

function WBP_TeamInfoList_C:SetRevivalInfo()
  self.IsTeamRevivalMode = UE.URGLevelLibrary.IsTeamRevivalMode(self)
  if self.IsTeamRevivalMode then
    UpdateVisibility(self.Overlay_TeamRevivalCount, true)
    local GS = UE.UGameplayStatics.GetGameState(self)
    if not GS then
      print("WBP_TeamInfoList_C: GameState is Null")
      return
    end
    local PlayerRevivalManager = GS:GetComponentByClass(UE.URGPlayerRevivalManager:StaticClass())
    local TeamRevivalInfo = PlayerRevivalManager.TeamRevivalInfo
    self.Txt_RevivalTime:SetText(TeamRevivalInfo.TeamRevivalCount)
    local StatusStr = 0 == TeamRevivalInfo.RevivalCount and "Zero" or "NoZero"
    self.RGStateController_EqualToZero:ChangeStatus(StatusStr)
  else
    UpdateVisibility(self.Overlay_TeamRevivalCount, false)
  end
end

function WBP_TeamInfoList_C:Bind_MSG_Game_PlayerRevivalSuccess(UserId, RevivalCount, RevivalCoinNum)
  if self.IsTeamRevivalMode then
    self.Txt_RevivalTime:SetText(RevivalCount)
    local StatusStr = 0 == RevivalCount and "Zero" or "NoZero"
    self.RGStateController_EqualToZero:ChangeStatus(StatusStr)
  end
end

function WBP_TeamInfoList_C:FocusInput()
end

function WBP_TeamInfoList_C:Destruct()
  self.Overridden.Destruct(self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TeamTimer) then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TeamTimer)
  end
  UnListenObjectMessage(GMP.MSG_Game_PlayerRevivalSuccess, self)
end

return WBP_TeamInfoList_C
