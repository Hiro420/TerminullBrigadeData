local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local climbtowerdata = require("UI.View.ClimbTower.ClimbTowerData")
local seasonabilityhandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")
local ClimbTowerView = Class(ViewBase)
function ClimbTowerView:BindClickHandler()
end
function ClimbTowerView:UnBindClickHandler()
end
function ClimbTowerView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function ClimbTowerView:OnDestroy()
  self:UnBindClickHandler()
end
function ClimbTowerView:OnShowLink(...)
  print("ClimbTowerView:OnShowLink", ...)
end
function ClimbTowerView:OnShow(...)
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  climbtowerdata:PassRewardStatus(#ClimbTowerTable)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  LogicLobby.RequestGetGameFloorDataToServer(function()
    local PreChooseFloor = DataMgr.GetFloorByGameModeIndex(climbtowerdata.WorldId, climbtowerdata.GameMode)
    if DataMgr.IsInTeam() then
      local TeamInfo = DataMgr.GetTeamInfo()
      for i, SinglePlayerInfo in ipairs(TeamInfo.players) do
        local Floor = DataMgr.GetTeamMemberGameFloorByModeAndWorld(SinglePlayerInfo.id, climbtowerdata.GameMode, climbtowerdata.WorldId)
        if nil == PreChooseFloor or PreChooseFloor > Floor then
          PreChooseFloor = Floor
        end
      end
    end
    climbtowerdata.Floor = PreChooseFloor
    EventSystem.Invoke(EventDef.ClimbTowerView.OnLayerChange, climbtowerdata.Floor)
  end)
  self.Btn_Save.OnClicked:Add(self, self.OnBtn_Save)
  self.Button_FirstClear.OnClicked:Add(self, self.OnBtn_FirstClearance)
  self.Button_Rank.OnClicked:Add(self, self.OnBtn_LinkRank)
  self.Button_StartMatch.OnClicked:Add(self, self.OnStartMatch)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnLayerChange, ClimbTowerView.UpdateMyTeamInfo)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnDebuffChange, self.OnDebuffChange)
  self.WBP_ClimbTower_DailyRewards:InitDailyRewards()
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    local HeroSeasonAbility = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroSeasonAbility)
    for key, value in pairs(HeroSeasonAbility) do
      if value.HeroID == SingleHeroInfo.id then
        seasonabilityhandler:RequestGetSeasonAbilityInfoToServer(SingleHeroInfo.id)
        break
      end
    end
  end
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0, 0)
  self:SetEnhancedInputActionBlocking(true)
end
function ClimbTowerView:OnHide()
  if climbtowerdata:FaultScoreIsChange() then
    climbtowerdata:SetDebuff(climbtowerdata:GetFloor())
  end
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  EventSystem.RemoveListener(EventDef.ClimbTowerView.OnLayerChange, ClimbTowerView.UpdateMyTeamInfo)
  EventSystem.RemoveListener(EventDef.ClimbTowerView.OnDebuffChange, self.OnDebuffChange)
  self.Btn_Save.OnClicked:Remove(self, self.OnBtn_Save)
  self.Button_FirstClear.OnClicked:Remove(self, self.OnBtn_FirstClearance)
  self.Button_Rank.OnClicked:Remove(self, self.OnBtn_LinkRank)
  self.Button_StartMatch.OnClicked:Remove(self, self.OnStartMatch)
  self:SetEnhancedInputActionBlocking(false)
end
function ClimbTowerView:OnStartMatch()
  if not climbtowerdata:MeetFaultScore() then
    return
  end
  if DataMgr.IsInTeam() and not LogicTeam.IsCaptain() then
    return
  end
  if climbtowerdata:FaultScoreIsChange() then
    climbtowerdata:SetDebuff(climbtowerdata:GetFloor())
  end
  LogicTeam.RequestSetTeamDataToServer(climbtowerdata.WorldId, climbtowerdata.GameMode, climbtowerdata:GetFloor())
  UIMgr:Hide(ViewID.UI_ClimbTower, true)
  UIMgr:Hide(ViewID.UI_MainModeSelection, true)
  local LobbyPanelTagName = LogicLobby.GetLabelTagNameByUIName("UI_LobbyMain")
  LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName)
end
function ClimbTowerView:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_ClimbTower, true)
end
function ClimbTowerView:UpdateMyTeamInfo()
  local SingleFloor = climbtowerdata:GetFloor()
  self.WBP_ClimbTower_Heteromorphism:InitHeteromorphism(SingleFloor)
  self.WBP_ClimbTower_LayerSelection:InitLayerSelection()
  self.WBP_ClimbTower_DebuffList:InitDebuffList(SingleFloor, true)
  self.WBP_ClimbTower_Award:InitClimbTowerAward(SingleFloor)
  self:SetFloorDesc(SingleFloor)
end
function ClimbTowerView:OnDebuffChange()
  UpdateVisibility(self.CanvasPanel_UnderPoints, climbtowerdata:GetFaultScore() < climbtowerdata:GetTargetFaultScore())
  if climbtowerdata:FaultScoreIsChange() then
    self.RGStateController_HaveChange:ChangeStatus("HaveChange", true)
  else
    self.RGStateController_HaveChange:ChangeStatus("NotHaveChange", true)
  end
  if climbtowerdata:MeetFaultScore() then
    if not DataMgr.IsInTeam() or LogicTeam.IsCaptain() then
      self.RGStateController_Lock:ChangeStatus("UnLock", true)
    else
      self.RGStateController_Lock:ChangeStatus("NotCaptain", true)
    end
  else
    self.RGStateController_Lock:ChangeStatus("Lock", true)
  end
end
function ClimbTowerView:OnBtn_Save()
  if climbtowerdata:FaultScoreIsChange() then
    climbtowerdata:SetDebuff(climbtowerdata:GetFloor())
  else
    ShowWaveWindow(304006)
  end
end
function ClimbTowerView:OnBtn_LinkRank()
  UIMgr:Show(ViewID.UI_RankView_Nor, true)
end
function ClimbTowerView:OnBtn_FirstClearance()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr:IsSystemOpen(SystemOpenID.CLIMB_TOWER_RANK) == false then
    return
  end
  UIMgr:Show(ViewID.UI_ClimbTowerRank, false)
end
function ClimbTowerView:SetFloorDesc(Floor)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBClimbTowerFloor, Floor)
  if Result then
    if RowInfo.FloorDescription and RowInfo.FloorDescription then
      UpdateVisibility(self.WBP_ClimbTower_FloorDesc.FloorDescPanel, table.count(RowInfo.FloorDescription) > 0)
      UpdateVisibility(self.WBP_ClimbTower_FloorDesc.FloorExtraDescPanel, table.count(RowInfo.ExtraEffectsDesc) > 0)
      local Index = 1
      local Item
      for index, SingleDescription in ipairs(RowInfo.FloorDescription) do
        Item = GetOrCreateItem(self.WBP_ClimbTower_FloorDesc.FloorDescPanel, Index, self.WBP_ClimbTower_FloorDesc.FloorDescItemTemplate:StaticClass())
        Item:Show(SingleDescription)
        Index = Index + 1
      end
      HideOtherItem(self.WBP_ClimbTower_FloorDesc.FloorDescPanel, Index)
      for index, SingleDescription in ipairs(RowInfo.ExtraEffectsDesc) do
        Item = GetOrCreateItem(self.WBP_ClimbTower_FloorDesc.FloorExtraDescPanel, Index, self.WBP_ClimbTower_FloorDesc.FloorExtraDescItemTemplate:StaticClass())
        Item:Show(SingleDescription)
        Index = Index + 1
      end
      HideOtherItem(self.WBP_ClimbTower_FloorDesc.FloorExtraDescPanel, Index)
    end
    if RowInfo.RecommendedTeams then
      local Index = 1
      for index, HeroId in ipairs(RowInfo.RecommendedTeams) do
        local Item = GetOrCreateItem(self.RecommendedHero, Index, self.WBP_ClimbTower_HeroItem:StaticClass())
        if Item then
          UpdateVisibility(Item, true)
          local CharacterInfo = LogicRole.GetCharacterTableRow(HeroId)
          if not CharacterInfo then
            return
          end
          local SoftObjRef = MakeStringToSoftObjectReference(CharacterInfo.ActorIcon)
          if not UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
            return
          end
          local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef):Cast(UE.UPaperSprite)
          if IconObj then
            local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
            Item.Icon_Hero:SetBrush(Brush)
          end
        end
        Index = Index + 1
      end
      HideOtherItem(self.RecommendedHero, Index, true)
    end
  end
end
return ClimbTowerView
