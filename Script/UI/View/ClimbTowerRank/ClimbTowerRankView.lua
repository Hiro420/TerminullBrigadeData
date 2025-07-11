local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local ClimbTowerRankView = Class(ViewBase)
function ClimbTowerRankView:BindClickHandler()
end
function ClimbTowerRankView:UnBindClickHandler()
end
function ClimbTowerRankView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function ClimbTowerRankView:OnDestroy()
  self:UnBindClickHandler()
end
function ClimbTowerRankView:OnShow(...)
  self:SetEnhancedInputActionBlocking(true)
  self:RefreshDifficultLevelList()
  self:BindOnPassRewardFloorChange(1)
  self.Btn_ChangeMode.OnClicked:Add(self, ClimbTowerRankView.ChangeMode)
  self.Btn_LeftChangeMode.OnClicked:Add(self, ClimbTowerRankView.LeftChangeMode)
  self.Btn_RightChangeMode.OnClicked:Add(self, ClimbTowerRankView.RightChangeMode)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnPassTeamDataChange, self.BindOnPassTeamDataChange)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnPassRewardStatusChange, self.BindOnPassRewardStatusChange)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnPassRewardFloorChange, self.BindOnPassRewardFloorChange)
  self:PlayAnimation(self.Ani_in)
  UpdateVisibility(self.DifficultLevelBottomPanel, false)
end
function ClimbTowerRankView:OnHide()
  EventSystem.RemoveListener(EventDef.ClimbTowerView.OnPassTeamDataChange, self.BindOnPassTeamDataChange, self)
  EventSystem.RemoveListener(EventDef.ClimbTowerView.OnPassRewardStatusChange, self.BindOnPassRewardStatusChange, self)
  EventSystem.RemoveListener(EventDef.ClimbTowerView.OnPassRewardFloorChange, self.BindOnPassRewardFloorChange, self)
  self:SetEnhancedInputActionBlocking(false)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
end
function ClimbTowerRankView:BindOnEscKeyPressed()
  if self:IsPlayingAnimation() then
    return
  end
  self:PlayAnimation(self.Ani_out)
end
function ClimbTowerRankView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UIMgr:Hide(ViewID.UI_ClimbTowerRank)
  end
end
function ClimbTowerRankView:BindOnPassTeamDataChange()
  if ClimbTowerData.PassTeamDataMap and ClimbTowerData.PassTeamDataMap[tostring(self.CurFloor)] and ClimbTowerData.PassTeamDataMap[tostring(self.CurFloor)].passTeamDatas then
    local TeamData = ClimbTowerData.PassTeamDataMap[tostring(self.CurFloor)].passTeamDatas
    self:UpdateRankList(TeamData)
  else
    self:UpdateRankList(nil)
    return
  end
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  for index, value in ipairs(ClimbTowerTable[self.CurFloor].GlobalPassReward) do
    self.Txt_Num:SetText(string.format("(%d/%d)", ClimbTowerData.PassTeamDataMap[tostring(self.CurFloor)].passTeamNum, value.key))
    self.ProgressBar_49:SetPercent(ClimbTowerData.PassTeamDataMap[tostring(self.CurFloor)].passTeamNum / value.key)
  end
end
function ClimbTowerRankView:BindOnPassRewardStatusChange()
  self:BindOnPassRewardFloorChange(self.CurFloor)
end
function ClimbTowerRankView:BindOnPassRewardFloorChange(Floor)
  ClimbTowerData:GetFirstPassTeam(Floor, Floor)
  self.Txt_CurSelectDifficultLevel:SetText(Floor)
  self.CurFloor = Floor
  local ProgressNum = 0
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  if #ClimbTowerTable[Floor].GlobalPassReward > 0 then
    self.RGStateController_GlobalPassReward:ChangeStatus("Have", true)
  else
    self.RGStateController_GlobalPassReward:ChangeStatus("NotHave", true)
  end
  for index, value in ipairs(ClimbTowerTable[Floor].GlobalPassReward) do
    local ItemWidget = self[string.format("WBP_Item_%d", 10000)]
    local RedDotWidget = self[string.format("WBP_RedDot_%d", 10000)]
    if ItemWidget then
      local TBClimbTowerGlobalPassReward = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerGlobalPassReward)
      if TBClimbTowerGlobalPassReward[value.value] then
        for i, v in ipairs(TBClimbTowerGlobalPassReward[value.value].Reward) do
          if RedDotWidget then
            RedDotWidget:ChangeRedDotId("ClimbTower_PassReward_Item_" .. Floor .. "_" .. index - 1)
          end
          ItemWidget:InitItem(v.key, v.value, false)
          if ClimbTowerData.PassRewardStatusTable then
            local ItemStatus = ClimbTowerData.PassRewardStatusTable[tostring(Floor)].rewardStatusMap[tostring(index - 1)]
            ItemWidget:UpdateReceivedPanelVis(2 == ItemStatus)
            if nil ~= ItemStatus and ItemStatus >= 1 then
              ProgressNum = ProgressNum + 1
            end
          else
            ItemWidget:UpdateReceivedPanelVis(false)
          end
          ItemWidget:BindOnMainButtonClicked(function()
            ClimbTowerData:ReceiveGlobalPassReward(Floor, index - 1)
          end)
        end
      end
    end
  end
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  local Index = 1
  for index = 1, #ClimbTowerTable do
    local Item = GetOrCreateItem(self.DifficultLevelList, index, self.WBP_ClimbTower_Rank_LevelItem:GetClass())
    if Item then
      if Item.Index == Floor then
        Item.RGStateController_Select:ChangeStatus("Select", true)
      elseif Item.Index > DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode) then
        Item.RGStateController_Select:ChangeStatus("Lock", true)
      else
        Item.RGStateController_Select:ChangeStatus("Normal", true)
      end
    end
    Index = Index + 1
  end
  HideOtherItem(self.DifficultLevelList, Index)
  self.WBP_RedDotView:ChangeRedDotId("ClimbTower_PassReward_Layer_" .. Floor)
end
function ClimbTowerRankView:ChangeMode()
  UpdateVisibility(self.DifficultLevelBottomPanel, true)
end
function ClimbTowerRankView:LeftChangeMode()
  if self.CurFloor - 1 <= 0 then
    return
  end
  EventSystem.Invoke(EventDef.ClimbTowerView.OnPassRewardFloorChange, self.CurFloor - 1)
end
function ClimbTowerRankView:RightChangeMode()
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  if self.CurFloor + 1 > #ClimbTowerTable then
    return
  end
  if self.CurFloor + 1 > DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode) then
    ShowWaveWindow(15008)
    return
  end
  EventSystem.Invoke(EventDef.ClimbTowerView.OnPassRewardFloorChange, self.CurFloor + 1)
end
function ClimbTowerRankView:RefreshDifficultLevelList()
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  local Index = 1
  for index = 1, #ClimbTowerTable do
    local Item = GetOrCreateItem(self.DifficultLevelList, index, self.WBP_ClimbTower_Rank_LevelItem:GetClass())
    if Item then
      Item.Txt_Level:SetText(index)
      Item.Index = index
      Item.Btn_Main.OnClicked:Add(self, function()
        if index > DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode) then
          ShowWaveWindow(15008)
          return
        end
        EventSystem.Invoke(EventDef.ClimbTowerView.OnPassRewardFloorChange, index)
        UpdateVisibility(self.DifficultLevelBottomPanel, false)
      end)
      Item.WBP_RedDotView:ChangeRedDotId("ClimbTower_PassReward_Layer_" .. index)
    end
    Index = Index + 1
  end
  HideOtherItem(self.DifficultLevelList, Index)
end
function ClimbTowerRankView:UpdateRankList(TeamData)
  if nil == TeamData or 0 == #TeamData then
    UpdateVisibility(self.RankList, false)
    UpdateVisibility(self.Txt_Empty, true)
    return
  end
  UpdateVisibility(self.RankList, true)
  UpdateVisibility(self.Txt_Empty, false)
  local Index = 1
  for index, value in ipairs(TeamData) do
    local RnakItem = GetOrCreateItem(self.RankList, Index, self.WBP_ClimbTower_Rank_Item:GetClass())
    if RnakItem then
      RnakItem:InitRankItem(value.teamMemberRoleIDs, value.passTime, Index)
      UpdateVisibility(RnakItem, true)
    end
    Index = Index + 1
  end
  HideOtherItem(self.RankList, Index, true)
end
return ClimbTowerRankView
