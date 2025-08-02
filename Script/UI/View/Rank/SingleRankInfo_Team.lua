local RankData = require("UI.View.Rank.RankData")
local rapidjson = require("rapidjson")
local SingleRankInfo_Team = UnLua.Class()

function SingleRankInfo_Team:InitSingleRankInfo(ListItemObj, bSelf, RankChange)
  self.bSelf = bSelf
  self.RankNumber = math.floor(ListItemObj.RankNumber)
  if ListItemObj.RankInfo == nil then
    print("ListItemObj.RankInfo is nil")
    return
  end
  self.ListItemObj = ListItemObj
  self.Switcher:SetActiveWidgetIndex(1)
  self.RankInfo = ListItemObj.RankInfo
  self.RoleIdTable = Split(self.RankInfo.uniqueID, "_")
  self:RequestRoleInfo(self.RoleIdTable)
  self.TextBlock_RankNumber:SetText(tostring(self.RankNumber))
  local tempPaperSprite
  self.Top3 = true
  UpdateVisibility(self.BgTopOne, 1 == self.RankNumber and false == bSelf)
  UpdateVisibility(self.BgTopTwo, 2 == self.RankNumber and false == bSelf)
  UpdateVisibility(self.BgTopThree, 3 == self.RankNumber and false == bSelf)
  UpdateVisibility(self.URGImage_89, 0 ~= self.RankNumber % 10)
  UpdateVisibility(self.URGImage_89, self.RankNumber > 3 or not bSelf)
  if self.RankNumber > 3 then
    self.RGStateController:ChangeStatus("NotTopNormal")
  else
    self.RGStateController:ChangeStatus("TopNormal")
  end
  if 1 == self.RankNumber then
    tempPaperSprite = self.NumberOne
  end
  if 2 == self.RankNumber then
    tempPaperSprite = self.NumberTwo
  end
  if 3 == self.RankNumber then
    tempPaperSprite = self.NumberThree
  end
  if self.RankNumber > 3 then
    self.Top3 = false
    tempPaperSprite = self.Other
  end
  local rankIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(tempPaperSprite)
  local rankBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(rankIconObj, 0, 0)
  self.Image_NumberBack:SetBrush(rankBrush)
  local scoreNumber = tonumber(self.RankInfo.score)
  local gameHardNumber = scoreNumber >> 44
  local result, row = GetRowData(DT.DT_DifficultyMode, gameHardNumber)
  if result then
    self.TextBlock_Difficulty:SetText(tostring(row.Difficulty))
  else
    self.TextBlock_Difficulty:SetText(tostring(gameHardNumber))
  end
  local seconds = 65535 - (scoreNumber - (gameHardNumber << 44) >> 28)
  self.TextBlock_Time:SetText(Format(seconds, "hh:mm:ss"))
  if bSelf then
    self.TextBlock_Difficulty:SetColorAndOpacity(self.FontColor)
    self.TextBlock_Time:SetColorAndOpacity(self.FontColor)
    self.TextBlock_RankNumber:SetColorAndOpacity(self.FontColor)
    if 0 ~= RankChange then
      self.Text_Up:SetText(RankChange)
    end
  end
end

function SingleRankInfo_Team:RequestRoleInfo(RoleIds)
  if nil == RoleIds or 0 == #RoleIds then
    return
  end
  UpdateVisibility(self.Player1, false)
  UpdateVisibility(self.Player2, false)
  UpdateVisibility(self.Player3, false)
  for i, SingleInfo in ipairs(self.ListItemObj.PlayerInfoList) do
    RankData.SetPlayerInfo(SingleInfo.roleid, SingleInfo)
    if self.RoleIdTable[1] and self.RoleIdTable[1] == SingleInfo.roleid then
      self.WBP_Rank_PlayerItem:InitPlayerItem(SingleInfo.roleid, SingleInfo.nickname, SingleInfo.portrait, self.bSelf, self, SingleInfo.rankInvisible)
      UpdateVisibility(self.Player1, true)
      self.SingleInfo = SingleInfo
    end
    if self.RoleIdTable[2] and self.RoleIdTable[2] == SingleInfo.roleid then
      self.WBP_Rank_PlayerItem_1:InitPlayerItem(SingleInfo.roleid, SingleInfo.nickname, SingleInfo.portrait, self.bSelf, self, SingleInfo.rankInvisible)
      UpdateVisibility(self.Player2, true)
    end
    if self.RoleIdTable[3] and self.RoleIdTable[3] == SingleInfo.roleid then
      self.WBP_Rank_PlayerItem_2:InitPlayerItem(SingleInfo.roleid, SingleInfo.nickname, SingleInfo.portrait, self.bSelf, self, SingleInfo.rankInvisible)
      UpdateVisibility(self.Player3, true)
    end
  end
end

function SingleRankInfo_Team:EnterGameRecordPanel_lua()
  UIMgr:Show(ViewID.UI_GRInfoView, nil, self.RankInfo.uniqueID, self.ListItemObj.WorldMode, self.ListItemObj.GameMode, self.RankInfo.score, true, nil, self.ListItemObj.SeasonId)
end

function SingleRankInfo_Team:GetPlayerNamme(Response, roleId)
  for i, SingleInfo in ipairs(Response.players) do
    if SingleInfo.roleid == roleId then
      self.SingleInfo = SingleInfo
      if self.SingleInfo then
        return SingleInfo.nickname
      end
    else
      return "\230\151\160\230\149\136\230\149\176\230\141\174"
    end
  end
end

function SingleRankInfo_Team:OnGetRoleFail(ErrorMessage)
  print("OnGetRoleFail", ErrorMessage.ErrorMessage)
end

function SingleRankInfo_Team:OnMouseButtonDown(MyGeometry, MouseEvent)
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    self:EnterGameRecordPanel_lua()
    self:StopListeningInput()
  end
  return UE.UWidgetBlueprintLibrary.UnHandled()
end

function SingleRankInfo_Team:OnConsoleXButtonDown(MyGeometry, MouseEvent)
  if self.HoverIconWidget then
    self.HoverIconWidget:OnButtonPlayerClicked()
  else
    self:EnterGameRecordPanel_lua()
  end
  self:StopListeningInput()
end

function SingleRankInfo_Team:OnMouseEnter(MyGeometry, MouseEvent)
  if self.bSelf then
    return
  end
  if not self.bIsSelected then
    UpdateVisibility(self.Pnl_Hover, true)
    UpdateVisibility(self.HoverBg, true)
    self:StopAnimation(self.Ani_hover_out)
    self:PlayAnimation(self.Ani_hover_in)
  end
  if not IsListeningForInputAction(self, "CommonFaceButtonLeft") then
    ListenForInputAction("CommonFaceButtonLeft", UE.EInputEvent.IE_Pressed, false, {
      self,
      self.OnConsoleXButtonDown
    })
  end
end

function SingleRankInfo_Team:OnMouseLeave(MouseEvent)
  self:StopListeningInput()
  if self.bSelf then
    return
  end
  if not self.bIsSelected then
    UpdateVisibility(self.Pnl_Hover, false)
    UpdateVisibility(self.HoverBg, false)
    self:StopAnimation(self.Ani_hover_in)
    self:PlayAnimation(self.Ani_hover_out)
  end
end

function SingleRankInfo_Team:BP_OnItemSelectionChanged(bIsSelected)
  if bIsSelected then
    self:StopAnimation(self.Ani_hover_in)
    self:PlayAnimation(self.Ani_hover_out)
  end
end

function SingleRankInfo_Team:OnHoveredPlayerIcon(HoverIconWidget)
  self.HoverIconWidget = HoverIconWidget
end

function SingleRankInfo_Team:StopListeningInput()
  if IsListeningForInputAction(self, "CommonFaceButtonLeft") then
    StopListeningForInputAction(self, "CommonFaceButtonLeft", UE.EInputEvent.IE_Pressed)
  end
  self.HoverIconWidget = nil
end

function SingleRankInfo_Team:Destruct()
  self:StopListeningInput()
end

return SingleRankInfo_Team
