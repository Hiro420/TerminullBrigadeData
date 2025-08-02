local WBP_LevelReadyItem_C = UnLua.Class()

function WBP_LevelReadyItem_C:Construct()
end

function WBP_LevelReadyItem_C:Show(InPlayerInfo, InIndex)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.PlayerInfo = InPlayerInfo
  self.Index = InIndex
  self.TextBlock_Num:SetText(tostring(self.Index))
  self:UpdatePlayerImage()
  self:UpdateTeamCaptainVis()
  self:RefreshOnlineStatus()
  self.TextBlock_Name:SetText(self.PlayerInfo.name)
  ListenObjectMessage(nil, "Level.OnTeamChange", self, self.BindOnTeamChange)
end

function WBP_LevelReadyItem_C:GetUserId()
  return self.PlayerInfo.roleid
end

function WBP_LevelReadyItem_C:UpdateTeamCaptainVis()
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  if self.PlayerInfo and self.PlayerInfo.roleid == TeamSubsystem:GetCaptain() then
    self.Img_Captain:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Captain:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_LevelReadyItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:InitReadyState()
  self.Ready = false
  UnListenObjectMessage("Level.OnTeamChange")
  self.PlayerInfo = nil
end

function WBP_LevelReadyItem_C:UpdateReadyState()
  self.Ready = true
  self.Image_Ready:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Overlay_Ready:SetRenderOpacity(0.6)
end

function WBP_LevelReadyItem_C:InitReadyState()
  local IsReady = false
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if GS then
    local VoteSystemComp = GS:GetComponentByClass(UE.URGVoteSystem:StaticClass())
    if VoteSystemComp then
      local CurrentVoteData = VoteSystemComp.CurrentVoteData
      for key, SingleUserId in pairs(CurrentVoteData.UserIds) do
        if self:GetUserId() == SingleUserId then
          IsReady = true
          break
        end
      end
    end
  end
  if IsReady then
    self:UpdateReadyState()
  else
    self.Image_Ready:SetVisibility(UE.ESlateVisibility.Hidden)
    self.Overlay_Ready:SetRenderOpacity(1.0)
  end
end

function WBP_LevelReadyItem_C:UpdatePlayerImage()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = GetRowDataForCharacter(self.PlayerInfo.hero.id)
  if not Result then
    return
  end
  SetImageBrushBySoftObject(self.Img_HeadIcon, RowInfo.LevelReadyRoleIcon, self.IconSize)
end

function WBP_LevelReadyItem_C:OnPortalStateChange(PortalState)
  if PortalState == UE.EPortalState.Ready or PortalState == UE.EPortalState.Confirm then
    self:UpdateReadyState()
  end
end

function WBP_LevelReadyItem_C:BindOnTeamChange()
  self:UpdateTeamCaptainVis()
  self:RefreshOnlineStatus()
end

function WBP_LevelReadyItem_C:RefreshOnlineStatus()
  if not self.PlayerInfo then
    print("WBP_LevelReadyItem_C:RefreshOnlineStatus \230\178\161\230\137\190\229\136\176PlayerInfo")
    return
  end
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  local State = TeamSubsystem:GetPlayerOnlineState(self.PlayerInfo.roleid)
  print("WBP_LevelReadyItem_C:RefreshOnlineStatus OnlineState", State, self.PlayerInfo.roleid)
  if State == UE.ERGPlayerOnlineState.Disconnected then
    UpdateVisibility(self.Img_Offline, true)
    UpdateVisibility(self.Img_LeaveBattle, false)
  elseif State == UE.ERGPlayerOnlineState.LeaveBattle then
    UpdateVisibility(self.Img_Offline, false)
    UpdateVisibility(self.Img_LeaveBattle, true)
  else
    UpdateVisibility(self.Img_Offline, false)
    UpdateVisibility(self.Img_LeaveBattle, false)
  end
end

function WBP_LevelReadyItem_C:Destruct()
  UnListenObjectMessage("Level.OnTeamChange")
end

return WBP_LevelReadyItem_C
