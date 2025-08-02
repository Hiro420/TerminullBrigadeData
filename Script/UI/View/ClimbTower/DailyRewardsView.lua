local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local DailyRewardsView = Class(ViewBase)

function DailyRewardsView:BindClickHandler()
  self.Btn_Receive.OnClicked:Add(self, self.Receive)
  self.Button_Close.OnClicked:Add(self, function()
    self:CloseWidget()
  end)
end

function DailyRewardsView:UnBindClickHandler()
  self.Btn_Receive.OnClicked:Remove(self, self.Receive)
end

function DailyRewardsView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function DailyRewardsView:OnDestroy()
  self:UnBindClickHandler()
end

function DailyRewardsView:OnShow(...)
  self.Closeing = false
  self.EquipCaChe = {}
  self.bExpand = false
  EventSystem.Invoke(EventDef.ClimbTowerView.OnHeroPanelChange, -1)
  self:InitHeroSlot()
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    self.CloseWidget
  })
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.CloseWidget)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnDailyRewardChange, self.InitHeroSlot)
  self.BP_Link.OnClicked:Add(self, function()
    UIMgr:Hide(ViewID.UI_DailyRewards, false)
    UIMgr:Hide(ViewID.UI_ClimbTower, true)
    UIMgr:Hide(ViewID.UI_MainModeSelection, true)
    ComLink(1027)
  end)
  self:PlayAnimation(self.Anim_IN)
end

function DailyRewardsView:OnHide()
  EventSystem.RemoveListener(EventDef.ClimbTowerView.OnDailyRewardChange, self.InitHeroSlot)
  StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.CloseWidget)
end

function DailyRewardsView:CloseWidget()
  if self.bExpand then
    UpdateVisibility(self.HeroSel, false)
    EventSystem.Invoke(EventDef.ClimbTowerView.OnHeroPanelChange, -1)
    self.bExpand = false
    return
  end
  if self.Closeing then
    return
  end
  self.Closeing = true
  UIMgr:Hide(ViewID.UI_DailyRewards)
end

function DailyRewardsView:Receive()
  UpdateVisibility(self.HeroSel, false)
  EventSystem.Invoke(EventDef.ClimbTowerView.OnHeroPanelChange, -1)
  self.bExpand = false
  ShowWaveWindow(304005)
  self:EquipDailyRewardHero()
end

function DailyRewardsView:InitHeroSlot()
  self.PointsAvailable:SetText(ClimbTowerData.DailyRewardInfo.rewardCount)
  self.CumulativeSpeed_1:SetText(ClimbTowerData.DailyRewardInfo.rewardRate)
  if not ClimbTowerData.DailyRewardInfo then
    return
  end
  if not ClimbTowerData.DailyRewardInfo.heroSlots then
    return
  end
  local Index = 1
  for index, value in ipairs(ClimbTowerData.DailyRewardInfo.heroSlots) do
    local Item = GetOrCreateItem(self.HeroPanel, Index, self.WBP_SelHeroItem:GetClass())
    if Item then
      Item:ResetItem()
      Item:InitHero(value.heroID, value.rewardRate, value.unlock, index)
      Item:BindClicked(function(HeroId, SlotId)
        self:BindHeroItemClicked(HeroId, SlotId)
      end)
      Index = Index + 1
    end
  end
  for key, value in pairs(self.EquipCaChe) do
    local Item = self.HeroPanel:GetChildAt(value - 1)
    if Item then
      Item:InitHero(key, 0, true, value)
    end
  end
  HideOtherItem(self.HeroPanel, Index, true)
  Index = 1
  for i, SingleHeroInfo in ipairs(DataMgr.HeroInfo.heros) do
    local HeroSeasonAbility = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroSeasonAbility)
    for key, value in pairs(HeroSeasonAbility) do
      if value.HeroID == SingleHeroInfo.id then
        local Item = GetOrCreateItem(self.HeroList, Index, self.WBP_SelHeroItem:GetClass())
        UpdateVisibility(Item, true)
        if Item then
          Item:ResetItem()
          Item:InitHero(SingleHeroInfo.id, 0, 1, Index)
          local bEquip = false
          local SlotId = -1
          for i, v in ipairs(ClimbTowerData.DailyRewardInfo.heroSlots) do
            if v.heroID == SingleHeroInfo.id then
              bEquip = true
              SlotId = i
              break
            end
          end
          for k, v in pairs(self.EquipCaChe) do
            if bEquip and v == SlotId and SingleHeroInfo.id ~= k then
              bEquip = false
            end
            if k == SingleHeroInfo.id then
              bEquip = true
            end
          end
          Item:SetEquipStyle(bEquip)
          Item:BindClicked(function(HeroId, SlotId)
            self:BindHeroListItemClicked(HeroId, SlotId)
          end)
          Index = Index + 1
        end
      end
    end
  end
  HideOtherItem(self.HeroList, Index, true)
  self:SetGainAttributes()
end

function DailyRewardsView:BindHeroItemClicked(HeroId, SlotId)
  self.CurClickedSlotId = SlotId
  UpdateVisibility(self.HeroSel, true)
  self.bExpand = true
  print("BindHeroItemClicked", self.CurClickedSlotId)
  EventSystem.Invoke(EventDef.ClimbTowerView.OnHeroPanelChange, SlotId)
end

function DailyRewardsView:BindHeroListItemClicked(HeroId, SlotId)
  for k, v in pairs(ClimbTowerData.DailyRewardInfo.heroSlots) do
    if v.heroID == HeroId then
      ClimbTowerData:UnEquipDailyRewardHero(k)
      return
    end
  end
  for k, v in pairs(self.EquipCaChe) do
    if k == HeroId then
      self.EquipCaChe[HeroId] = nil
      self:InitHeroSlot()
      return
    elseif v == self.CurClickedSlotId then
      self.EquipCaChe[k] = nil
    end
  end
  self.EquipCaChe[HeroId] = self.CurClickedSlotId
  self:InitHeroSlot()
  table.Print(self.EquipCaChe)
end

function DailyRewardsView:EquipDailyRewardHero()
  for k, v in pairs(self.EquipCaChe) do
    ClimbTowerData:EquipDailyRewardHero(k, v)
  end
  self.EquipCaChe = {}
end

function DailyRewardsView:SetGainAttributes()
  local Layer = DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode) - 1
  self.Txt_LayerTitle:SetText(UE.FTextFormat(self.LayerTitleText, Layer))
  self.Txt_HeroTitle:SetText(UE.FTextFormat(self.HeroTitleText, Layer))
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  if not ClimbTowerTable[Layer] then
    self.TxtHeroSpeed:SetText(UE.FTextFormat(self.SpeedText, 0))
    self.TxtLayerSpeed:SetText(UE.FTextFormat(self.SpeedText, 0))
    return
  end
  self.TxtLayerSpeed:SetText(UE.FTextFormat(self.SpeedText, ClimbTowerTable[Layer].DailyRewardBaseValue))
  local BaseValue = ClimbTowerTable[Layer].DailyRewardBaseValue
  local HeroSpeed = 0
  for key, value in pairs(self.EquipCaChe) do
    local maxReceiveLv = ProficiencyData:GetMaxUnlockProfyLevel(key)
    local BonusRate = 1
    local BasePoints = 0
    local ClimbTowerDailyRewardBonusRate = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDailyRewardBonusRate)
    if ClimbTowerDailyRewardBonusRate and ClimbTowerDailyRewardBonusRate[key] then
      BonusRate = ClimbTowerDailyRewardBonusRate[key].BonusRate
      BasePoints = ClimbTowerDailyRewardBonusRate[key].BasePoints
    end
    local Pont = ClimbTowerDailyRewardBonusRate[self.HeroId].FloorRate ^ (Layer / 5)
    HeroSpeed = (BasePoints + maxReceiveLv * BonusRate) * Pont
    HeroSpeed = math.ceil(HeroSpeed)
  end
  for k, v in pairs(ClimbTowerData.DailyRewardInfo.heroSlots) do
    local maxReceiveLv = ProficiencyData:GetMaxUnlockProfyLevel(v.heroID)
    local BonusRate = 1
    local BasePoints = 0
    local Pont = 1
    local ClimbTowerDailyRewardBonusRate = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDailyRewardBonusRate)
    if ClimbTowerDailyRewardBonusRate and ClimbTowerDailyRewardBonusRate[v.heroID] then
      BonusRate = ClimbTowerDailyRewardBonusRate[v.heroID].BonusRate
      BasePoints = ClimbTowerDailyRewardBonusRate[v.heroID].BasePoints
      Pont = ClimbTowerDailyRewardBonusRate[v.heroID].FloorRate ^ (Layer / 5)
    end
    HeroSpeed = (BasePoints + maxReceiveLv * BonusRate) * Pont
    HeroSpeed = math.ceil(HeroSpeed)
  end
  self.TxtHeroSpeed:SetText(UE.FTextFormat(self.SpeedText, HeroSpeed))
end

return DailyRewardsView
