local WBP_TeamInfoItem_C = UnLua.Class()
local FindPlayerOnlineInfo = function(InUserId)
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return nil
  end
  for i, v in pairs(TeamSubsystem.TeamInfo.OnlineInfos) do
    if v.UserId == InUserId then
      return v
    end
  end
  return nil
end
local FindCharacterByUserId = function(InUserId)
  local HeroCharacterCls = UE.ARGHeroCharacterBase:StaticClass()
  local AllHeroCharacter = UE.UGameplayStatics.GetAllActorsOfClass(GameInstance, HeroCharacterCls, nil)
  for i, v in pairs(AllHeroCharacter) do
    if v:GetUserId() == InUserId then
      return v
    end
  end
  return nil
end

function WBP_TeamInfoItem_C:Construct()
  ListenObjectMessage(nil, GMP.MSG_Level_OnTeamChange, self, self.OnTeamChange)
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    TeamVoiceSubSys.VoiceMuteDelegate:Add(self, WBP_TeamInfoItem_C.UpdateMuteTag)
  end
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      GVoice.RoomMemberVoiceStatusDelegate:Add(self, WBP_TeamInfoItem_C.UpdateSpeakingTag)
    end
  end
  self.AllBuffInfos = {}
  self.AllBuffIds = {}
  self.NeedInitMonthCard = true
end

function WBP_TeamInfoItem_C:OnTeamChange()
  self:UpdateTeamCaptainVis()
  self:RefreshOnlineStatus()
end

function WBP_TeamInfoItem_C:UpdateTeamCaptainVis()
  if not self:IsVisible() then
    return
  end
  self.Image_Leader:SetVisibility(UE.ESlateVisibility.Collapsed)
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  if self.PlayerInfo.roleid == TeamSubsystem:GetCaptain() then
    self.Image_Leader:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_TeamInfoItem_C:InitInfo(PlayerInfo, TeamIndex, IsTeamRevivalMode)
  if IsValidObj(self.Character) then
    local BuffComp = self.Character:GetComponentByClass(UE.UBuffComponent:StaticClass())
    if BuffComp then
      BuffComp.OnBuffAdded:Remove(self, self.BindOnBuffChanged)
      BuffComp.OnBuffRemove:Remove(self, self.BindOnBuffRemoved)
      BuffComp.OnBuffChanged:Remove(self, self.BindOnBuffChanged)
    end
  end
  self.PlayerInfo = PlayerInfo
  self.Character = FindCharacterByUserId(self.PlayerInfo.roleid)
  self.CurIndex = TeamIndex
  self:InitTeamIndexInfo()
  self:RefreshOnlineStatus()
  self.Txt_Name:SetText(self.PlayerInfo.name)
  self:InitListInfo()
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_TeamInfoItem_C self.PlayerInfo.roleid: %s", tostring(self.PlayerInfo.roleid)))
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_TeamInfoItem_C self.PlayerInfo.channelUID: %s", tostring(self.PlayerInfo.channelUID)))
  if self.PlatformIconPanel then
    self.PlatformIconPanel:UpdateChannelInfo(self.PlayerInfo.roleid, false, self.PlayerInfo.channelUID)
  end
  self:UpdatePlayerImage()
  self:UpdateTeamCaptainVis()
  self:UpdateRevivalInfo(IsTeamRevivalMode)
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    if self.Character then
      local MemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.roleid)
      local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
      UpdateVisibility(self.ImageMuteVoice, bIsMute)
    else
      UpdateVisibility(self.ImageMuteVoice, false)
    end
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  local PrivacySubSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserPrivacySubsystem:StaticClass())
  if PrivacySubSystem then
    local ChannelUserID = DataMgr.GetPlayerChannelUserIdById(self.PlayerInfo.roleid)
    if "" ~= ChannelUserID then
      local IsAllowed = PrivacySubSystem:IsCommunicateUsingTextOrVoiceAllowed(ChannelUserID, true)
      UpdateVisibility(self.ImageMuteVoice, IsAllowed ~= UE.EPermissionsResult.denied)
    end
  end
  if self.Character then
    self.Character.OnCharacterDying:Remove(self, WBP_TeamInfoItem_C.BindOnCharacterDying)
    self.Character.OnCharacterRescue:Remove(self, WBP_TeamInfoItem_C.BindOnCharacterRescue)
    self.Character.OnCharacterDying:Add(self, WBP_TeamInfoItem_C.BindOnCharacterDying)
    self.Character.OnCharacterRescue:Add(self, WBP_TeamInfoItem_C.BindOnCharacterRescue)
    local BuffComp = self.Character:GetComponentByClass(UE.UBuffComponent:StaticClass())
    if BuffComp then
      BuffComp.OnBuffAdded:Add(self, self.BindOnBuffChanged)
      BuffComp.OnBuffRemove:Add(self, self.BindOnBuffRemoved)
      BuffComp.OnBuffChanged:Add(self, self.BindOnBuffChanged)
    end
  end
  if self.NeedInitMonthCard then
    self.WBP_MonthCardIcon:Show(tostring(self.PlayerInfo.roleid))
    self.NeedInitMonthCard = false
  end
end

function WBP_TeamInfoItem_C:RefreshOnlineStatus()
  if not self.PlayerInfo then
    self.OnlineInfo = nil
    return
  end
  local OnlineInfo = FindPlayerOnlineInfo(self.PlayerInfo.roleid)
  self.OnlineInfo = OnlineInfo
  if OnlineInfo then
    if OnlineInfo.State == UE.ERGPlayerOnlineState.Disconnected then
      UpdateVisibility(self.ImageOffline, true)
      UpdateVisibility(self.ImageLeaveBattle, false)
      UpdateVisibility(self.RGImageHealthMask, true)
      UpdateVisibility(self.RGImageShieldMask, true)
      self:UpdateSpeakingStatus(false)
    elseif OnlineInfo.State == UE.ERGPlayerOnlineState.LeaveBattle then
      UpdateVisibility(self.ImageOffline, false)
      UpdateVisibility(self.ImageLeaveBattle, true)
      UpdateVisibility(self.RGImageHealthMask, true)
      UpdateVisibility(self.RGImageShieldMask, true)
      self:UpdateSpeakingStatus(false)
    else
      UpdateVisibility(self.ImageOffline, false)
      UpdateVisibility(self.ImageLeaveBattle, false)
      UpdateVisibility(self.RGImageHealthMask, false)
      UpdateVisibility(self.RGImageShieldMask, false)
    end
  else
    UpdateVisibility(self.ImageOffline, false)
    UpdateVisibility(self.ImageLeaveBattle, true)
    UpdateVisibility(self.RGImageHealthMask, true)
    UpdateVisibility(self.RGImageShieldMask, true)
    self:UpdateSpeakingStatus(false)
  end
end

function WBP_TeamInfoItem_C:BindOnCharacterDying(Character, CountDownTime)
  if Character == self.Character then
    UpdateVisibility(self.RGTextDyingNum, true)
    UpdateVisibility(self.BuffList, false)
    local dyingTimeTxtFmt = NSLOCTEXT("WBP_DyingMark_C", "DyingTimeTxt", "\229\183\178\229\128\146\229\156\176{0}\230\172\161")
    local dyingTimeTxt = UE.FTextFormat(dyingTimeTxtFmt(), self.Character:GetDyingCount())
    self.RGTextDyingNum:SetText(dyingTimeTxt)
    self.Txt_Name:SetColorAndOpacity(self.DyingNameColor)
  end
end

function WBP_TeamInfoItem_C:BindOnCharacterRescue(Character)
  if Character == self.Character then
    UpdateVisibility(self.RGTextDyingNum, false)
    UpdateVisibility(self.BuffList, true)
    self.Txt_Name:SetColorAndOpacity(self.NormalNameColor)
  end
end

function WBP_TeamInfoItem_C:BindOnBuffChanged(AddedBuff)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local BuffData = BuffDataSubsystem:GetDataFormID(AddedBuff.ID)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if BuffData and BuffData.IsNeedShowOnHUD then
    local BuffInfo = {}
    BuffInfo.ID = AddedBuff.ID
    BuffInfo.CurrentCount = AddedBuff.CurrentCount
    BuffInfo.BuffData = BuffData
    BuffInfo.IsElement = false
    BuffInfo.Target = Character
    if not self.AllBuffInfos[AddedBuff.ID] then
      table.insert(self.AllBuffIds, AddedBuff.ID)
    end
    self.AllBuffInfos[AddedBuff.ID] = BuffInfo
    self:RefreshBuffList()
  end
end

function WBP_TeamInfoItem_C:BindOnBuffRemoved(RemovedBuff)
  table.RemoveItem(self.AllBuffIds, RemovedBuff.ID)
  self.AllBuffInfos[RemovedBuff.ID] = nil
  self:RefreshBuffList()
end

function WBP_TeamInfoItem_C:RefreshBuffList()
  local BuffIconSize = self.BuffIconSize
  local BuffIndex = 0
  for i, SingleWidget in iterator(self.BuffList:GetAllChildren()) do
    LogicBuffList.ListContainer:HideItem(SingleWidget)
  end
  for i, SingleBuffId in ipairs(self.AllBuffIds) do
    if BuffIndex > self.MaxBuffNum - 1 then
      break
    end
    local BuffInfo = self.AllBuffInfos[SingleBuffId]
    local List
    local Index = 0
    local IsShowOmitIcon = false
    List = self.BuffList
    BuffIndex = BuffIndex + 1
    Index = BuffIndex
    if Index == self.MaxBuffNum then
      IsShowOmitIcon = true
    end
    local Item = self.BuffList:GetChildAt(Index - 1)
    if List then
      if not Item then
        Item = LogicBuffList.ListContainer:GetOrCreateItem()
        List:AddChild(Item)
      end
      if Item then
        Item:SetRenderTransformPivot(UE.FVector2D(0.0, 0.0))
        local ItemSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
        if ItemSlot then
          ItemSlot:SetSize(UE.FVector2D(BuffIconSize, BuffIconSize))
          local X = (Index - 1) * (Item.RenderTransform.Scale.X * ItemSlot:GetSize().X + 5.0)
          local Y = 0
          ItemSlot:SetPosition(UE.FVector2D(X, Y))
        end
        LogicBuffList.ListContainer:ShowItem(Item, self.AllBuffInfos[SingleBuffId], IsShowOmitIcon, self.Character)
      end
    end
  end
end

function WBP_TeamInfoItem_C:InitTeamIndexInfo()
  self.Txt_TeamIndex:SetText(self.CurIndex)
  if LogicHUD.TeamIndexColor[self.CurIndex] then
    self.Img_TeamIndex:SetColorAndOpacity(LogicHUD.TeamIndexColor[self.CurIndex])
  else
    self.Img_TeamIndex:SetColorAndOpacity(LogicHUD.TeamIndexColor[1])
  end
end

function WBP_TeamInfoItem_C:InitListInfo()
  local ShieldSize = UE.USlateBlueprintLibrary.GetLocalSize(self.ShieldList:GetCachedGeometry())
  local HealthSize = UE.USlateBlueprintLibrary.GetLocalSize(self.HealthList:GetCachedGeometry())
  local Character = self.Character
  if not Character or self.OnlineInfo and (self.OnlineInfo.State == UE.ERGPlayerOnlineState.LeaveBattle or self.OnlineInfo.State == UE.ERGPlayerOnlineState.Disconnected) then
    self.ShieldList:InitInfo(nil)
    self.HealthList:InitInfo(nil)
    self.ArmorBar:InitInfo(nil)
    self.ShieldList:UpdateBarGrid(ShieldSize.X, ShieldSize.Y)
    self.HealthList:UpdateBarGrid(HealthSize.X, HealthSize.Y)
    self.ShieldList:SetBarValue(0, 0)
    self.HealthList:SetBarValue(0, 0)
    self.ArmorBar:SetBarInfo(0)
    return
  end
  self.ShieldList:InitInfo(Character)
  self.ShieldList:UpdateBarGrid(ShieldSize.X, ShieldSize.Y)
  self.HealthList:InitInfo(Character)
  self.HealthList:UpdateBarGrid(HealthSize.X, HealthSize.Y)
  self.ArmorBar:InitInfo(Character)
end

function WBP_TeamInfoItem_C:UpdateReadyState()
  local Character = self.Character
  if not Character then
    print("WBP_TeamInfoItem_C:UpdateReadyState() not Character")
    return
  end
  local ReadyIcon = self.Image_Ready
  print("WBP_TeamInfoItem_C:UpdateReadyState(): ", Character, Character.bPortalReadyState)
  if Character.bPortalReadyState then
    ReadyIcon:SetVisibility(UE.ESlateVisibility.Visible)
  else
    ReadyIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_TeamInfoItem_C:UpdateMuteTag(Result, RoomName, MemberId)
  if not LogicTeam.CheckIsOwnerVoiceRoom(RoomName) then
    return
  end
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys and 0 == Result then
    local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.roleid)
    if SelfMemberId == MemberId then
      local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
      UpdateVisibility(self.ImageMuteVoice, bIsMute)
    end
  end
end

function WBP_TeamInfoItem_C:UpdateSpeakingTag(RoomName, OpenId, MemberId, Status)
  if not LogicTeam.CheckIsOwnerVoiceRoom(RoomName) then
    return
  end
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
    if bIsMute then
      self:UpdateSpeakingStatus(false)
    elseif Status == UE.EVoiceRoomMemberStatus.SayingFromSilence or Status == UE.EVoiceRoomMemberStatus.ContinueSaying then
      local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.roleid)
      if SelfMemberId == MemberId then
        self:UpdateSpeakingStatus(true)
      end
    elseif Status == UE.EVoiceRoomMemberStatus.SilenceFromSaying then
      local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(self.PlayerInfo.roleid)
      if SelfMemberId == MemberId then
        self:UpdateSpeakingStatus(false)
      end
    end
  end
end

function WBP_TeamInfoItem_C:UpdateSpeakingStatus(bIsShow)
  UpdateVisibility(self.ImageVoice, bIsShow)
  if bIsShow then
    math.randomseed(os.time())
    local Amplitude = math.random() * 0.5
    local Mat = self.ImageVoice:GetDynamicMaterial()
    if Mat then
      Mat:SetScalarParameterValue("amplitude", Amplitude)
    end
  end
end

function WBP_TeamInfoItem_C:UpdatePlayerImage()
  if not self.OwningCharacter then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = GetRowDataForCharacter(self.OwningCharacter:GetTypeId())
  if not Result then
    return
  end
  SetImageBrushBySoftObject(self.Img_HeadIcon, RowInfo.RoleIcon, self.IconSize)
end

function WBP_TeamInfoItem_C:UpdateRevivalInfo(IsTeamRevivalMode)
  self.IsTeamRevivalMode = IsTeamRevivalMode
  if IsTeamRevivalMode then
    UpdateVisibility(self.Overlay_RevivalCount, false)
  else
    UpdateVisibility(self.Overlay_RevivalCount, true)
    local GS = UE.UGameplayStatics.GetGameState(self)
    if not GS then
      print("WBP_DyingRevival: GameState is Null")
      return
    end
    local PlayerRevivalManager = GS:GetComponentByClass(UE.URGPlayerRevivalManager:StaticClass())
    local SelfPlayerRevivalInfo = PlayerRevivalManager:GetPlayerInfo(self.PlayerInfo.roleid)
    self.Txt_RevivalTime:SetText(SelfPlayerRevivalInfo.RevivalCount)
    local StatusStr = 0 == SelfPlayerRevivalInfo.RevivalCount and "Zero" or "NoZero"
    self.RGStateController_EqualToZero:ChangeStatus(StatusStr)
  end
end

function WBP_TeamInfoItem_C:Bind_MSG_Game_PlayerRevivalSuccess(UserId, RevivalCount, RevivalCoinNum)
  if self.IsTeamRevivalMode or self.PlayerInfo.roleid ~= UserId then
    return
  end
  self.Txt_RevivalTime:SetText(RevivalCount)
  local StatusStr = 0 == RevivalCount and "Zero" or "NoZero"
  self.RGStateController_EqualToZero:ChangeStatus(StatusStr)
end

function WBP_TeamInfoItem_C:Destruct()
  if IsValidObj(self.Character) then
    local BuffComp = self.Character:GetComponentByClass(UE.UBuffComponent:StaticClass())
    if BuffComp then
      BuffComp.OnBuffAdded:Remove(self, self.BindOnBuffChanged)
      BuffComp.OnBuffRemove:Remove(self, self.BindOnBuffRemoved)
      BuffComp.OnBuffChanged:Remove(self, self.BindOnBuffChanged)
    end
    self.Character = nil
  end
  UnListenObjectMessage(GMP.MSG_Level_OnTeamChange, self)
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    TeamVoiceSubSys.VoiceMuteDelegate:Remove(self, WBP_TeamInfoItem_C.UpdateMuteTag)
  end
  if nil ~= UE.UGVoiceSubsystem then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      GVoice.RoomMemberVoiceStatusDelegate:Remove(self, WBP_TeamInfoItem_C.UpdateSpeakingTag)
    end
  end
end

return WBP_TeamInfoItem_C
