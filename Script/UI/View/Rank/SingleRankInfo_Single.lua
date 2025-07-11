local RankData = require("UI.View.Rank.RankData")
local rapidjson = require("rapidjson")
local SingleRankInfo_Single = UnLua.Class()
function SingleRankInfo_Single:Construct()
  EventSystem.AddListener(self, EventDef.Rank.OnRequestServerElementDataSuccess, SingleRankInfo_Single.OnRequestServerElementDataSuccess)
end
function SingleRankInfo_Single:OnRequestServerElementDataSuccess(Data)
  if self.RankInfo == nil then
    return
  end
  if RankData.ElementData[self.RankInfo.uniqueID] then
    self.Txt_TotalDamage:SetText(RankData.ElementData[self.RankInfo.uniqueID].totalDamage)
    self:SetProficiency(RankData.ElementData[self.RankInfo.uniqueID].totalPractice)
  end
end
function SingleRankInfo_Single:SetProficiency(Exp)
  local ProficiencyTable = LuaTableMgr.GetLuaTableByName(TableNames.TBProfyLevel)
  for i = 1, 9 do
    if Exp >= ProficiencyTable[i].Exp and Exp < ProficiencyTable[i + 1].Exp then
      self.Txt_Proficiency:SetText(i)
      return
    end
  end
  self.Txt_Proficiency:SetText(10)
end
function SingleRankInfo_Single:InitSingleRankInfo(ListItemObj, bSelf, RankChange)
  self.bSelf = bSelf
  self.RankNumber = math.floor(ListItemObj.RankNumber)
  if ListItemObj.RankInfo == nil then
    print("ListItemObj.RankInfo is nil")
    return
  end
  self.ListItemObj = ListItemObj
  self.Switcher:SetActiveWidgetIndex(1)
  self.RankInfo = ListItemObj.RankInfo
  self.TextBlock_RankNumber:SetText(tostring(self.RankNumber))
  UpdateVisibility(self.BgTopOne, 1 == self.RankNumber and false == bSelf)
  UpdateVisibility(self.BgTopTwo, 2 == self.RankNumber and false == bSelf)
  UpdateVisibility(self.BgTopThree, 3 == self.RankNumber and false == bSelf)
  if self.RankNumber > 3 then
    self.RGStateController:ChangeStatus("NotTopNormal")
  else
    self.RGStateController:ChangeStatus("TopNormal")
  end
  local tempPaperSprite
  if 1 == self.RankNumber then
    tempPaperSprite = self.NumberOne
  end
  if 2 == self.RankNumber then
    tempPaperSprite = self.NumberTwo
  end
  if 3 == self.RankNumber then
    tempPaperSprite = self.NumberThree
  end
  UpdateVisibility(self.URGImage_89, 0 ~= self.RankNumber % 10)
  UpdateVisibility(self.URGImage_89, self.RankNumber > 3 or not bSelf)
  if self.RankNumber > 3 then
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
  self:RequestRoleInfo(Split(self.RankInfo.uniqueID, "_"))
  self:RequestServerElementData()
  if bSelf then
    self.Txt_Proficiency:SetColorAndOpacity(self.FontColor)
    self.Txt_TotalDamage:SetColorAndOpacity(self.FontColor)
    self.TextBlock_Difficulty:SetColorAndOpacity(self.FontColor)
    self.TextBlock_Time:SetColorAndOpacity(self.FontColor)
    self.TextBlock_RankNumber:SetColorAndOpacity(self.FontColor)
    if 0 ~= RankChange then
      self.Text_Up:SetText(RankChange)
    end
  end
end
function SingleRankInfo_Single:RequestRoleInfo(RoleIds)
  if nil == RoleIds or 0 == #RoleIds then
    return
  end
  for i, SingleInfo in ipairs(self.ListItemObj.PlayerInfoList) do
    for index, value in ipairs(RoleIds) do
      if value == SingleInfo.roleid then
        RankData.SetPlayerInfo(SingleInfo.roleid, SingleInfo)
        self.WBP_Rank_PlayerItem:InitPlayerItem(SingleInfo.roleid, SingleInfo.nickname, SingleInfo.portrait, self.bSelf, self, SingleInfo.rankInvisible)
        self.SingleInfo = SingleInfo
      end
    end
  end
end
function SingleRankInfo_Single:EnterGameRecordPanel_lua()
  UIMgr:Show(ViewID.UI_GRInfoView, nil, self.RankInfo.uniqueID, self.ListItemObj.WorldMode, self.ListItemObj.GameMode, self.RankInfo.score, false, self.ListItemObj.HeroId, self.ListItemObj.SeasonId)
end
function SingleRankInfo_Single:OnGetRoleSuccess(PlayerCacheInfoList)
  local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
end
function SingleRankInfo_Single:GetPlayerNamme(Response, roleId)
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
function SingleRankInfo_Single:OnGetRoleFail(ErrorMessage)
  print("OnGetRoleFail", ErrorMessage.ErrorMessage)
end
function SingleRankInfo_Single:OnMouseButtonDown(MyGeometry, MouseEvent)
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.RightMouseButton then
    self:EnterGameRecordPanel_lua()
    self:StopListeningInput()
  end
  return UE.UWidgetBlueprintLibrary.UnHandled()
end
function SingleRankInfo_Single:RequestServerElementData()
  RankData.RequestServerElementData(self.ListItemObj.SeasonId, self.ListItemObj.GameMode, self.ListItemObj.WorldMode, self.ListItemObj.HeroId, self.RankInfo.uniqueID)
end
function SingleRankInfo_Single:OnConsoleXButtonDown(MyGeometry, MouseEvent)
  if self.HoverIconWidget then
    self.HoverIconWidget:OnButtonPlayerClicked()
  else
    self:EnterGameRecordPanel_lua()
  end
  self:StopListeningInput()
end
function SingleRankInfo_Single:OnMouseEnter(MyGeometry, MouseEvent)
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
function SingleRankInfo_Single:OnMouseLeave(MouseEvent)
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
function SingleRankInfo_Single:BP_OnItemSelectionChanged(bIsSelected)
  if bIsSelected then
    self:StopAnimation(self.Ani_hover_in)
    self:PlayAnimation(self.Ani_hover_out)
  end
end
function SingleRankInfo_Single:StopListeningInput()
  if IsListeningForInputAction(self, "CommonFaceButtonLeft") then
    StopListeningForInputAction(self, "CommonFaceButtonLeft", UE.EInputEvent.IE_Pressed)
  end
  self.HoverIconWidget = nil
end
function SingleRankInfo_Single:OnHoveredPlayerIcon(HoverIconWidget)
  self.HoverIconWidget = HoverIconWidget
end
function SingleRankInfo_Single:Destruct()
  self:StopListeningInput()
end
return SingleRankInfo_Single
