local WBP_PlatformIcon_C = UnLua.Class()
function WBP_PlatformIcon_C:UpdateChannelInfo(UserID, bIsDarkIcon, ChannelUID)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformIcon_C UserID: %s", tostring(UserID)))
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformIcon_C ChannelUID: %s", tostring(ChannelUID)))
  UpdateVisibility(self, false)
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    return
  end
  local ChannelInfo = DataMgr.GetChannelUserInfo(UserID, ChannelUID)
  if ChannelInfo and ChannelInfo.ChannelUserId then
    self:DoUpdateWidget(ChannelInfo, bIsDarkIcon)
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformIcon_C ChannelUID exist: %s", tostring(ChannelUID)))
  else
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformIcon_C ChannelUID Request"))
    DataMgr.GetOrQueryPlayerInfo({UserID}, false, function(PlayerInfoList)
      if not self then
        return
      end
      for index, SinglePlayerInfo in ipairs(PlayerInfoList) do
        if SinglePlayerInfo.playerInfo.roleid == UserID then
          local ChannelInfo = DataMgr.GetChannelUserInfo(UserID, SinglePlayerInfo.playerInfo.channelUID)
          DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformIcon_C ChannelUID Request Response: %s", tostring(SinglePlayerInfo.playerInfo.channelUID)))
          if ChannelInfo and ChannelInfo.ChannelUserId then
            self:DoUpdateWidget(ChannelInfo, bIsDarkIcon)
          end
        end
      end
    end, nil, DataMgr.PLAYER_INFO_CACHE_DURATION, true)
  end
end
function WBP_PlatformIcon_C:DoUpdateWidget(ChannelInfo, bIsDarkIcon)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_PlatformIcon_C DoUpdateWidget ChannelUserId: %s", tostring(ChannelInfo.ChannelUserId)))
  if not ChannelInfo or not DataMgr.CanChannelIconShow(ChannelInfo) then
    UpdateVisibility(self, false)
    return false
  else
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
    else
      UpdateVisibility(self, false)
      return false
    end
    UpdateVisibility(self, true)
    return true
  end
end
function WBP_PlatformIcon_C:UpdateChannelInfoByPlatform(PlatformName, bIsDarkIcon)
  Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPlatformIcon, PlatformName)
  if Result then
    if bIsDarkIcon then
      SetImageBrushByPath(self.Img_PlatformIcon, RowInfo.DarkIconPath, self.Img_PlatformIcon.Brush.ImageSize)
    else
      SetImageBrushByPath(self.Img_PlatformIcon, RowInfo.LightIconPath, self.Img_PlatformIcon.Brush.ImageSize)
    end
    UpdateVisibility(self, true)
  else
    UpdateVisibility(self, false)
    return false
  end
  return true
end
return WBP_PlatformIcon_C
