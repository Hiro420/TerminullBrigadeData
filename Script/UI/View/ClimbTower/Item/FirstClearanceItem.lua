local rapidjson = require("rapidjson")
local FirstClearanceItem = UnLua.Class()
function FirstClearanceItem:SetRoleInfo(RoleId)
  self:RequestRoleInfo(RoleId)
end
function FirstClearanceItem:RequestRoleInfo(RoleIds)
  if nil == RoleIds or 0 == #RoleIds then
    return
  end
  self.RoleId = RoleIds[1]
  DataMgr.GetOrQueryPlayerInfo(RoleIds, false, function(PlayerInfoList)
    self:OnGetRoleSuccess(PlayerInfoList)
  end)
end
function FirstClearanceItem:OnGetRoleSuccess(PlayerCacheInfoList)
  local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
  for i, SingleInfo in ipairs(PlayerInfoList) do
    local Name = SingleInfo.nickname
    local PortraitRowInfo = LogicLobby.GetPlayerPortraitTableRowInfo(SingleInfo.portrait)
    if PortraitRowInfo then
      SetImageBrushByPath(self.Img_HeadIcon, PortraitRowInfo.portraitIconPath)
    end
    self.Name:SetText(Name)
    self.Txt_Level:SetText(SingleInfo.level)
    self.PlayerInfo = SingleInfo
  end
end
function FirstClearanceItem:OnGetRoleFail(JsonResponse)
end
function FirstClearanceItem:OnMouseButtonDown(MyGeometry, MouseEvent)
  local MousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
  UIMgr:Show(ViewID.UI_ContactPersonOperateButtonPanel, nil, MousePosition, self.PlayerInfo, EOperateButtonPanelSourceFromType.Rank)
end
return FirstClearanceItem
