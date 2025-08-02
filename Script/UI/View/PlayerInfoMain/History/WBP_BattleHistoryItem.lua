require("Rouge.UI.Battle.Logic.Logic_Settlement")
local PlayerInfoConfig = require("GameConfig.PlayerInfo.PlayerInfoConfig")
local WBP_BattleHistoryItem = Class()
local MatchName = {
  [0] = NSLOCTEXT("WBP_BattleHistoryItem", "0", "\229\141\149\228\186\186"),
  [1] = NSLOCTEXT("WBP_BattleHistoryItem", "1", "\231\187\132\233\152\159")
}

function WBP_BattleHistoryItem:Construct()
  self.Overridden.Construct(self)
end

function WBP_BattleHistoryItem:InitBattleHistoryItem(HistoryData, HeroIdParam, ParentView)
  self:SetRootOpacity(0)
  local playerInfoMainVM = UIModelMgr:Get("PlayerInfoMainViewModel")
  local roleID = playerInfoMainVM:GetCurRoleID()
  local ownerData
  local battleHistoryData = HistoryData.battleHistoryData
  for i, v in ipairs(battleHistoryData) do
    if v.roleID == roleID then
      ownerData = v
      break
    end
  end
  if nil == ownerData then
    error("WBP_BattleHistoryItem:InitBattleHistoryItem owner data is nil" .. roleID)
    return
  end
  self.ParentView = ParentView
  self.HistoryData = battleHistoryData
  local HeroId = ownerData.heroID
  UpdateVisibility(self, true)
  UpdateVisibility(self.RGTextAll, false)
  UpdateVisibility(self.URGImageHeroIcon_1, true)
  self.BP_ButtonWithSoundDetails.OnClicked:Add(self, self.ShowBattleHistoryPlayerInfo)
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if not tbHeroMonster or not tbHeroMonster[HeroId] then
    return
  end
  local tbHeroData = tbHeroMonster[HeroId]
  SetImageBrushByPath(self.URGImageHeroIcon_1, tbHeroData.ActorIcon)
  local result, row = GetRowData(DT.DT_GameMode, tostring(ownerData.worldID))
  if result then
    self.RGTextWorld:SetText(row.Name)
  end
  self.RGTextDiff:SetText(ownerData.hard)
  self.RGTextDifficult:SetText(MatchName[ownerData.match]())
  self.RGTextDamageValue:SetText(math.floor(ownerData.harm))
  UpdateVisibility(self.CanvasPanelFailed, 1 ~= ownerData.state)
  UpdateVisibility(self.CanvasPanelSucc, 1 == ownerData.state)
  for idxSlot, vSlot in ipairs(BattleHistoryGenericSlotList) do
    local bFind = false
    for idxAttr, v in ipairs(ownerData.Attributes) do
      local id = v
      if type(v) ~= "number" then
        id = v.ID
      end
      local resultGeneric, rowGeneric = GetRowData(DT.DT_GenericModify, tostring(id))
      if resultGeneric and rowGeneric.Slot == vSlot then
        local genericModify = UE.FRGGenericModify()
        if type(v) == "number" then
          genericModify.ModifyId = v
          genericModify.Level = 1
        else
          genericModify.ModifyId = v.ID
          genericModify.Level = v.Level
        end
        local RGGenericModifyData = genericModify
        local GenericModifyItem = GetOrCreateItem(self.HorizontalBoxModify, idxSlot, self.WBP_BagRoleGenericItem_History:GetClass())
        if RGGenericModifyData and RGGenericModifyData.ModifyId > 0 then
          GenericModifyItem:InitBagRoleGenericItem(RGGenericModifyData, v, self.UpdateGenericModifyTipsFunc, self)
        else
          GenericModifyItem:InitBagRoleGenericItem(nil, v, self.UpdateGenericModifyTipsFunc, self)
        end
        bFind = true
        break
      end
    end
    if not bFind then
      local GenericModifyItem = GetOrCreateItem(self.HorizontalBoxModify, idxSlot, self.WBP_BagRoleGenericItem_History:GetClass())
      UpdateVisibility(GenericModifyItem, false, false, true)
    end
  end
  HideOtherItem(self.HorizontalBoxModify, #BattleHistoryGenericSlotList + 1)
  local formattedDate = os.date("%Y/%m/%d", ownerData.GameStartTime)
  self.RGTextDate:SetText(formattedDate)
  if SettlementDamageTitle[ownerData.UserTitleID] then
    self.RGTextTitle:SetText(SettlementDamageTitle[ownerData.UserTitleID]())
    UpdateVisibility(self.CanvasPanelTitle, true)
  else
    UpdateVisibility(self.CanvasPanelTitle, false)
  end
  local Duration = math.floor(tonumber(ownerData.duration))
  local Hour = math.floor(Duration / 3600)
  local Min = math.floor((Duration - Hour * 3600) / 60)
  local Sec = Duration - Hour * 3600 - Min * 60
  local TimeStr = string.format("%02d:%02d:%02d", Hour, Min, Sec)
  self.RGTextDuration:SetText(TimeStr)
end

function WBP_BattleHistoryItem:SetRootOpacity(Opacity)
  self.CanvasPanelRoot:SetRenderOpacity(Opacity)
end

function WBP_BattleHistoryItem:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot, HoverItem)
  if not UE.RGUtil.IsUObjectValid(self.ParentView) then
    return
  end
  self.ParentView:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot, HoverItem)
end

function WBP_BattleHistoryItem:InitWBP_BattleHistoryItemByAll()
  UpdateVisibility(self.RGTextAll, true)
  UpdateVisibility(self.URGImageHeroIcon, false)
end

function WBP_BattleHistoryItem:Hide()
  UpdateVisibility(self, false)
  self.BP_ButtonWithSoundDetails.OnClicked:Remove(self, self.ShowBattleHistoryPlayerInfo)
end

function WBP_BattleHistoryItem:ShowBattleHistoryPlayerInfo()
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowBattleHistoryPlayerInfo(self.HistoryData)
  end
end

return WBP_BattleHistoryItem
