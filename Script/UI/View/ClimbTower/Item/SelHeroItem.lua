local SelHeroItem = UnLua.Class()
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")

function SelHeroItem:ResetItem()
  UpdateVisibility(self.Hero, false)
  UpdateVisibility(self.AddHero, false)
  UpdateVisibility(self.Lock, false)
  EventSystem.RemoveListener(EventDef.ClimbTowerView.OnHeroPanelChange, self.OnSelChanged, self)
  self.MainButton.OnClicked:Clear()
  self.MainButton.OnHovered:Clear()
  self.MainButton.OnUnhovered:Clear()
  self.MainButton.OnHovered:Add(self, self.OnHovered)
  self.MainButton.OnUnhovered:Add(self, self.OnUnhovered)
end

function SelHeroItem:OnHovered()
  if 0 ~= self.HeroId then
    self:PlayAnimation(self.Ani_hover_hero_in)
  else
    self:PlayAnimation(self.Ani_hover_in)
  end
end

function SelHeroItem:OnUnhovered()
  if 0 ~= self.HeroId then
    self:PlayAnimation(self.Ani_hover_hero_out)
  else
    self:PlayAnimation(self.Ani_hover_out)
  end
end

function SelHeroItem:BindClicked(Func)
  self.MainButton.OnClicked:Add(self, function()
    if Func then
      if 0 == self.UnLock then
        local TBSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerSlotUnlock)
        ShowWaveWindow(TBSlot[self.SlotId].WaveWindowId)
        return
      end
      Func(self.HeroId, self.SlotId)
    end
  end)
end

function SelHeroItem:InitHero(HeroId, Speed, UnLock, SlotId)
  self.HeroId = HeroId
  self.SlotId = SlotId
  self.UnLock = UnLock
  if self.SlotId then
    EventSystem.AddListener(self, EventDef.ClimbTowerView.OnHeroPanelChange, self.OnSelChanged)
  end
  if 0 ~= HeroId then
    UpdateVisibility(self.Hero, true)
  else
    UpdateVisibility(self.AddHero, true)
  end
  UpdateVisibility(self.Lock, 0 == UnLock)
  if 0 == UnLock then
    UpdateVisibility(self.AddHero, false)
    local TBSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerSlotUnlock)
    if not TBSlot or not TBSlot[self.SlotId] then
      self.Text_Unlock:SetText("\230\178\161\230\156\137\233\133\141\231\189\174 " .. self.SlotId)
    else
      self.Text_Unlock:SetText(TBSlot[self.SlotId].UnLockDes)
    end
  end
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
    self.Icon:SetBrush(Brush)
  end
  self.Txt_Lv:SetText(DataMgr.GetHeroProfyByHeroId(HeroId))
  self:HeroSeasonAbilityPointNum()
end

function SelHeroItem:OnSelChanged(SlotId)
  print(SlotId == self.SlotId)
  UpdateVisibility(self.PanelSel, SlotId == self.SlotId)
end

function SelHeroItem:SetEquipStyle(bEquip)
  UpdateVisibility(self.Overlay_Equip, bEquip)
end

function SelHeroItem:HeroSeasonAbilityPointNum()
  local maxReceiveLv = ProficiencyData:GetMaxUnlockProfyLevel(self.HeroId)
  local Layer = DataMgr.GetFloorByGameModeIndex(ClimbTowerData.WorldId, ClimbTowerData.GameMode) - 1
  local BonusRate = 1
  local BasePoints = 0
  local ClimbTowerDailyRewardBonusRate = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDailyRewardBonusRate)
  if ClimbTowerDailyRewardBonusRate and ClimbTowerDailyRewardBonusRate[self.HeroId] then
    BonusRate = ClimbTowerDailyRewardBonusRate[self.HeroId].BonusRate
    BasePoints = ClimbTowerDailyRewardBonusRate[self.HeroId].BasePoints
  end
  local Pont = ClimbTowerDailyRewardBonusRate[self.HeroId].FloorRate ^ (Layer / 5)
  UpdateVisibility(self.Di_Addition, (BasePoints + maxReceiveLv * BonusRate) * Pont > 0)
  self.Txt_Speed:SetText(math.ceil((BasePoints + maxReceiveLv * BonusRate) * Pont))
end

return SelHeroItem
