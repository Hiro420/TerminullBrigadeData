local WBP_ChatItem_C = UnLua.Class()
local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
function WBP_ChatItem_C:Construct()
  self.Overridden.Construct(self)
  self.RichTextBlockName.HyperLinkClick:Add(self, self.OnHyperLinkClick)
end
function WBP_ChatItem_C:OnListItemObjectSet(ListItemObj)
  self.DataObj = ListItemObj
  local ChannelRow = LogicChat:GetChannelRow(ListItemObj.ChannelId)
  if ChannelRow then
    self.RichTextBlockName:SetDefaultColorAndOpacity(ChannelRow.ChannelColor)
    self.URGImageChannelBgShadow:SetColorAndOpacity(ChannelRow.ChannelShadowColor.SpecifiedColor)
    self.URGImageChannelIcon:SetColorAndOpacity(ChannelRow.ChannelIconColor.SpecifiedColor)
    SetImageBrushBySoftObject(self.URGImageChannelIcon, ChannelRow.ChannelIconSoft)
    self.URGImageChannelBg:SetColorAndOpacity(ChannelRow.ChannelColor.SpecifiedColor)
  end
  local Name = ""
  if ListItemObj.MsgType ~= ChatDataMgr.EMsgType.Error then
    local PlatformIconPath = ""
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_ChatItem_C ListItemObj.SenderId: %s", tostring(ListItemObj.SenderId)))
    DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_ChatItem_C ListItemObj.ChannelId: %s", tostring(ListItemObj.ChannelId)))
    local ChannelInfo = DataMgr.GetChannelUserInfo(ListItemObj.SenderId)
    if ChannelInfo and DataMgr.CanChannelIconShow(ChannelInfo) then
      if ChannelInfo.IsSamePlatform then
        PlatformIconPath = "<img id=\"" .. ChannelInfo.PlatformName .. "\"/>"
      else
        PlatformIconPath = "<img id=\"" .. "Windows" .. "\"/>"
      end
    end
    local NameContent = ListItemObj.Name
    Name = "<a type=\"1\">" .. NameContent .. "</>"
    UpdateVisibility(self.URGImageChannelErrorIcon, false)
    UpdateVisibility(self.URGImageChannelWarningIcon, false)
    local str = UE.FTextFormat("{0}{1}  {2}", PlatformIconPath, Name, self.DataObj.Msg)
    if ListItemObj.MsgType == ChatDataMgr.EMsgType.System then
      str = UE.FTextFormat("{0}", self.DataObj.Msg)
    end
    self.RichTextBlockName:SetText(str)
  else
    self.MultiLineEditableTextErrorContent:SetText(ListItemObj.Msg)
    UpdateVisibility(self.URGImageChannelErrorIcon, true)
    UpdateVisibility(self.URGImageChannelWarningIcon, false)
    self.RichTextBlockName:SetText("")
  end
  if ListItemObj.MsgType == ChatDataMgr.EMsgType.Error then
    UpdateVisibility(self.CanvasPanelChannel, false)
  else
    if ListItemObj.ChatType == ChatDataMgr.EChatType.Battle then
      self.SizeBoxContent:SetWidthOverride(self.BattleSizeContentWidth)
      local slotSizeBox = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SizeBoxContent)
      slotSizeBox:SetPosition(UE.FVector2D(0, 0))
    else
      self.SizeBoxContent:SetWidthOverride(self.NormalSizeContentWidth)
      local slotSizeBox = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SizeBoxContent)
      slotSizeBox:SetPosition(UE.FVector2D(self.BattleSizeContentPosX, 0))
    end
    UpdateVisibility(self.CanvasPanelChannel, ListItemObj.ChatType ~= ChatDataMgr.EChatType.Battle)
  end
  UpdateVisibility(self.SizeBoxErrorContent, ListItemObj.MsgType == ChatDataMgr.EMsgType.Error)
  UpdateVisibility(self.SizeBoxContent, ListItemObj.MsgType ~= ChatDataMgr.EMsgType.Error)
end
function WBP_ChatItem_C:BP_OnEntryReleased()
  self.DataObj = nil
end
function WBP_ChatItem_C:BP_OnItemSelectionChanged(bIsSelected)
  print("WBP_ChatItem_C:BP_OnItemSelectionChanged", bIsSelected)
end
function WBP_ChatItem_C:OnHyperLinkClick(TypeParam, MetaData)
  if TypeParam == UE.ELinkType.ChatLinkPlayerClick then
    if self.DataObj.ChatType == ChatDataMgr.EChatType.Battle then
      return
    end
    LogicLobby.RequestGetRoleListInfoToServer({
      self.DataObj.SenderId
    }, {
      self,
      function(Target, JsonTable)
        local MousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
        EventSystem.Invoke(EventDef.ContactPerson.OnContactPersonItemClicked, MousePosition, JsonTable[1], EOperateButtonPanelSourceFromType.Chat, self.DataObj.Msg)
      end
    })
  elseif TypeParam == UE.ELinkType.ChatRecruitClick then
    if self.DataObj.ChatType == ChatDataMgr.EChatType.Battle then
      return
    end
    if LogicLobby.GetVersionID() ~= self.DataObj.Version then
      ShowWaveWindow(1196)
      return
    end
    if DataMgr.IsInTeam() and DataMgr.GetTeamInfo().teamid == self.DataObj.TeamID then
      ShowWaveWindow(1197)
      return
    end
    RecruitHandler:SendApplyRecruitTeam(LogicLobby.GetBrunchType(), self.DataObj.TeamID, self.DataObj.Version)
  end
end
function WBP_ChatItem_C:Destruct()
  self.Overridden.Destruct(self)
  self.DataObj = nil
  self.RichTextBlockName.HyperLinkClick:Remove(self, self.OnHyperLinkClick)
end
return WBP_ChatItem_C
