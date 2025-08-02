local WBP_PlatformInfo_C = UnLua.Class()
local CurChannelInfo

function WBP_PlatformInfo_C:Construct()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
  if UserOnlineSubsystem then
    UserOnlineSubsystem.OnUpdateUserInfoCompleteDelegate:Add(self, self.OnUpdateUserInfoComplete)
  end
end

function WBP_PlatformInfo_C:Destruct()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
  if UserOnlineSubsystem then
    UserOnlineSubsystem.OnUpdateUserInfoCompleteDelegate:Remove(self, self.OnUpdateUserInfoComplete)
  end
end

function WBP_PlatformInfo_C:OnUpdateUserInfoComplete(ChannelUserId)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C OnUpdateUserInfoComplete: %s", tostring(ChannelUserId)))
  self:UpdateUserNickName(ChannelUserId)
end

function WBP_PlatformInfo_C:UpdateUserNickName(OnlineID)
  if self.Txt_ChannelID and CurChannelInfo.ChannelUserId == OnlineID then
    local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
    local UserOnlineSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UUserOnlineSubsystem:StaticClass())
    if UserOnlineSubsystem and UserOnlineSubsystem:CheckRequestLoginStatus() then
      local Res, NickName = UserOnlineSubsystem:GetPlayerNickName(OnlineID)
      DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C UpdateUserNickName OnlineID: %s", tostring(OnlineID)))
      DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C UpdateUserNickName NickName: %s", tostring(NickName)))
      if Res == UE.EUserQueryResult.valid then
        self.Txt_ChannelID:SetText(NickName)
      end
    end
  end
end

function WBP_PlatformInfo_C:UpdateChannelInfo(UserID, bIsDarkIcon, ChannelUID, CallBackFunc)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C UserID: %s", tostring(UserID)))
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C ChannelUID: %s", tostring(ChannelUID)))
  if CallBackFunc then
    CallBackFunc(false)
  end
  UpdateVisibility(self, false)
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    return
  end
  local ChannelInfo = DataMgr.GetChannelUserInfo(UserID, ChannelUID)
  if ChannelInfo and ChannelInfo.ChannelUserId then
    self:DoUpdateWidget(ChannelInfo, bIsDarkIcon, CallBackFunc)
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C ChannelUID exist: %s", tostring(ChannelUID)))
  else
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C ChannelUID Request"))
    DataMgr.GetOrQueryPlayerInfo({UserID}, false, function(PlayerInfoList)
      if not self then
        return
      end
      for index, SinglePlayerInfo in ipairs(PlayerInfoList) do
        if SinglePlayerInfo.playerInfo.roleid == UserID then
          local ChannelInfo = DataMgr.GetChannelUserInfo(UserID, SinglePlayerInfo.playerInfo.channelUID)
          DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C ChannelUID Request Response: %s", tostring(SinglePlayerInfo.playerInfo.channelUID)))
          if ChannelInfo and ChannelInfo.ChannelUserId then
            self:DoUpdateWidget(ChannelInfo, bIsDarkIcon, CallBackFunc)
          end
        end
      end
    end, nil, DataMgr.PLAYER_INFO_CACHE_DURATION, true)
  end
end

function WBP_PlatformInfo_C:DoUpdateWidget(ChannelInfo, bIsDarkIcon, CallBackFunc)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformInfo_C DoUpdateWidget ChannelUserId: %s", tostring(ChannelInfo.ChannelUserId)))
  if not ChannelInfo or not DataMgr.CanChannelIDShow(ChannelInfo) then
    UpdateVisibility(self, false)
    if CallBackFunc then
      CallBackFunc(false)
    end
  else
    CurChannelInfo = ChannelInfo
    if ChannelInfo.ChannelUserId then
      local ChannelIDWithoutPrefix = ChannelInfo.ChannelUserId
      if string.find(ChannelInfo.ChannelUserId, "sony-") then
        ChannelIDWithoutPrefix = string.sub(ChannelInfo.ChannelUserId, 6, string.len(ChannelInfo.ChannelUserId))
      elseif string.find(ChannelInfo.ChannelUserId, "ms-") then
        ChannelIDWithoutPrefix = string.sub(ChannelInfo.ChannelUserId, 4, string.len(ChannelInfo.ChannelUserId))
      end
      self:UpdateUserNickName(ChannelIDWithoutPrefix)
    end
    local Result, RowInfo
    if ChannelInfo.PlatformName == "Windows" then
      Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPlatformIcon, "Windows")
    elseif ChannelInfo.IsSamePlatform then
      Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPlatformIcon, ChannelInfo.PlatformName)
    else
      Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPlatformIcon, "OhterConsole")
    end
    if Result then
      if bIsDarkIcon then
        SetImageBrushByPath(self.Img_PlatformIcon, RowInfo.DarkIconPath, self.Img_PlatformIcon.Brush.ImageSize)
      else
        SetImageBrushByPath(self.Img_PlatformIcon, RowInfo.LightIconPath, self.Img_PlatformIcon.Brush.ImageSize)
      end
    end
    UpdateVisibility(self, true)
    if CallBackFunc then
      CallBackFunc(true)
    end
  end
end

return WBP_PlatformInfo_C
