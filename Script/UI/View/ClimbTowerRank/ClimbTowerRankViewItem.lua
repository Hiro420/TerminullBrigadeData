local ClimbTowerRankViewItem = UnLua.Class()
function ClimbTowerRankViewItem:InitRankItem(RoleIds, PassTime, Index)
  UpdateVisibility(self.Player1, false)
  UpdateVisibility(self.Player2, false)
  UpdateVisibility(self.Player3, false)
  local OnGetRoleSuccess = function(PlayerCacheInfoList)
    local PlayerInfoList = DataMgr.CacheInfosToPlayerInfoList(PlayerCacheInfoList)
    for i, SingleInfo in ipairs(PlayerInfoList) do
      if 1 == i then
        self.WBP_Rank_PlayerItem:InitPlayerItem(SingleInfo.roleid, SingleInfo.nickname, SingleInfo.portrait, SingleInfo.roleid == DataMgr.GetUserId(), nil, SingleInfo.rankInvisible)
        self.WBP_Rank_PlayerItem.InRank = false
        UpdateVisibility(self.Player1, true)
      elseif 2 == i then
        self.WBP_Rank_PlayerItem_1:InitPlayerItem(SingleInfo.roleid, SingleInfo.nickname, SingleInfo.portrait, SingleInfo.roleid == DataMgr.GetUserId(), nil, SingleInfo.rankInvisible)
        self.WBP_Rank_PlayerItem_1.InRank = false
        UpdateVisibility(self.Player2, true)
      else
        self.WBP_Rank_PlayerItem_2:InitPlayerItem(SingleInfo.roleid, SingleInfo.nickname, SingleInfo.portrait, SingleInfo.roleid == DataMgr.GetUserId(), nil, SingleInfo.rankInvisible)
        self.WBP_Rank_PlayerItem_2.InRank = false
        UpdateVisibility(self.Player3, true)
      end
    end
  end
  DataMgr.GetOrQueryPlayerInfo(RoleIds, false, OnGetRoleSuccess, nil, 300)
  self.TextBlock_RankNumber:SetText(tostring(Index))
  local timestamp = math.floor(tonumber(PassTime) / 1000)
  local dateStr = os.date("%Y-%m-%d %H:%M:%S", timestamp)
  self.TextBlock_Time:SetText(dateStr)
  local tempPaperSprite
  if 1 == Index then
    tempPaperSprite = self.NumberOne
  end
  if 2 == Index then
    tempPaperSprite = self.NumberTwo
  end
  if 3 == Index then
    tempPaperSprite = self.NumberThree
  end
  if Index > 3 then
    self.Top3 = false
    tempPaperSprite = self.Other
  end
  local rankIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(tempPaperSprite)
  local rankBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(rankIconObj, 0, 0)
  self.Image_NumberBack:SetBrush(rankBrush)
end
function ClimbTowerRankViewItem:OnMouseEnter(MyGeometry, MouseEvent)
  self:PlayAnimation(self.Ani_hover_in)
end
function ClimbTowerRankViewItem:OnMouseLeave(MyGeometry, MouseEvent)
  self:PlayAnimation(self.Ani_hover_out)
end
return ClimbTowerRankViewItem
