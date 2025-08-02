local WBP_SeasonAbilityTip = UnLua.Class()
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")

function WBP_SeasonAbilityTip:Show(HeroId, AbilityId)
  self.CurHeroId = HeroId
  self.AbilityId = AbilityId
  local SeasonAbilityGroupInfo = SeasonAbilityData:GetAbilityTableRow(self.AbilityId)
  if not SeasonAbilityGroupInfo then
    self:Hide()
    return
  end
  UpdateVisibility(self, true)
  local FirstLevelInfo = SeasonAbilityGroupInfo[1]
  self.Txt_Name:SetText(FirstLevelInfo.Name)
  if UE.UKismetStringLibrary.IsEmpty(FirstLevelInfo.MovieUrl) then
    UpdateVisibility(self.MainMovieWidget, false)
  else
    local ObjRef = MakeStringToSoftObjectReference(TargetSkillInfo.VideoUrl)
    if ObjRef and UE.UKismetSystemLibrary.IsValidSoftObjectReference(ObjRef) then
      UpdateVisibility(self.MainMovieWidget, true)
      local Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ObjRef)
      if Obj and Obj:Cast(UE.UFileMediaSource) then
        self.MediaPlayer:SetLooping(true)
        self.MediaPlayer:OpenSource(Obj)
        self.MediaPlayer:Rewind()
      end
    else
      UpdateVisibility(self.MainMovieWidget, false)
    end
  end
  local MaxLevel = SeasonAbilityData:GetAbilityMaxLevel(self.AbilityId)
  local PreLevel = SeasonAbilityData:GetPreAbilityLevel(self.AbilityId, self.CurHeroId)
  UpdateVisibility(self.Txt_Desc, 1 == MaxLevel)
  UpdateVisibility(self.AbilityLevelDescList, 1 ~= MaxLevel)
  if 1 == MaxLevel then
    self.Txt_Desc:SetText(FirstLevelInfo.Desc)
  else
    local Index = 1
    for Level, SingleRowInfo in pairs(SeasonAbilityGroupInfo) do
      local Item = GetOrCreateItem(self.AbilityLevelDescList, Index, self.DescTemplate:StaticClass())
      Item:Show(PreLevel, Level, SingleRowInfo.Desc)
      Index = Index + 1
    end
    HideOtherItem(self.AbilityLevelDescList, Index)
  end
  local RealLevel = SeasonAbilityData:GetSeasonAbilityLevel(self.AbilityId, self.CurHeroId)
  if RealLevel == MaxLevel then
    UpdateVisibility(self.Overlay_AcquireSpecialPoint, false)
  else
    UpdateVisibility(self.Overlay_AcquireSpecialPoint, true)
    local AllAcquiredPointNum = 0
    for Level, SingleRowInfo in pairs(SeasonAbilityGroupInfo) do
      if Level > RealLevel and Level <= PreLevel + 1 then
        AllAcquiredPointNum = AllAcquiredPointNum + SingleRowInfo.AcquiredSpecialPoint
      end
    end
    local TargetText = ""
    if 0 == PreLevel then
      TargetText = self.ActivateText
    else
      TargetText = self.UpgradeText
    end
    self.Txt_AcquireSpecialAbilityPoint:SetText(UE.FTextFormat(self.AcquireSpecialAbilitPointText, TargetText, AllAcquiredPointNum))
  end
  if MaxLevel < PreLevel + 1 then
    UpdateVisibility(self.SizeBox_Bottom, false)
  else
    UpdateVisibility(self.SizeBox_Bottom, true)
    local IsMeetPreCondition = SeasonAbilityData:IsMeetPreAbilityGroupCondition(self.AbilityId, self.CurHeroId)
    local IsMeetCostCondition, NeedExchangePointNum = SeasonAbilityData:IsMeetAbilityUpgradeCostCondition(self.AbilityId, self.CurHeroId)
    UpdateVisibility(self.WBP_InteractTipWidget, IsMeetPreCondition and IsMeetCostCondition)
    UpdateVisibility(self.ConditionNotMeetPanel, not IsMeetPreCondition or not IsMeetCostCondition)
    if IsMeetPreCondition and IsMeetCostCondition then
      if 0 == PreLevel then
        self.WBP_InteractTipWidget:UpdateKeyDesc(self.ActivateText)
      else
        self.WBP_InteractTipWidget:UpdateKeyDesc(self.UpgradeText)
      end
    else
      UpdateVisibility(self.SizeBox_CostNotMeet, IsMeetPreCondition and not IsMeetCostCondition)
      UpdateVisibility(self.SizeBox_PreConditionNotMeet, not IsMeetPreCondition)
    end
    UpdateVisibility(self.SizeBox_CostIcon, 0 ~= NeedExchangePointNum)
    local CurHaveNum = 0
    local NeedCostNum = 0
    if 0 == NeedExchangePointNum then
      self.Txt_CostUseDesc:SetText(self.UsePointText)
      CurHaveNum = SeasonAbilityData:GetPreRemainSeasonAbilityPointNum(self.CurHeroId)
      self.Txt_HaveNum:SetText(CurHaveNum)
      local NextLevelRowInfo = SeasonAbilityGroupInfo[PreLevel + 1]
      NeedCostNum = NextLevelRowInfo.ConsumerResourceNum
      self.Txt_CostNum:SetText(NeedCostNum)
    else
      self.Txt_CostUseDesc:SetText(self.UseExchangeText)
      local TotalHeroAbilityPointNum = SeasonAbilityData:GetTotalExchangeAbilityPointNumByHeroId(HeroId)
      local NeedCostResourceInfo = {}
      for i = 1, NeedExchangePointNum do
        local CurExchangePointRowInfo = SeasonAbilityData.ExchangeAbilityPointTable[TotalHeroAbilityPointNum + i]
        if CurExchangePointRowInfo then
          local ResourceNum = NeedCostResourceInfo[CurExchangePointRowInfo.ExchangeResource.key]
          ResourceNum = ResourceNum or 0
          NeedCostResourceInfo[CurExchangePointRowInfo.ExchangeResource.key] = ResourceNum + CurExchangePointRowInfo.ExchangeResource.value
        end
      end
      for Key, Value in pairs(NeedCostResourceInfo) do
        local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, Key)
        if Result then
          SetImageBrushByPath(self.Img_CostIcon, ResourceRowInfo.Icon)
        end
        CurHaveNum = SeasonAbilityData:GetPreRemainCostResourceNum(Key)
        NeedCostNum = Value
        self.Txt_HaveNum:SetText(CurHaveNum)
        self.Txt_CostNum:SetText(NeedCostNum)
      end
    end
    if CurHaveNum >= NeedCostNum then
      self.Txt_HaveNum:SetColorAndOpacity(self.CurrencyEnoughColor)
    else
      self.Txt_HaveNum:SetColorAndOpacity(self.CurrencyNotEnoughColor)
    end
  end
end

function WBP_SeasonAbilityTip:Hide(...)
  UpdateVisibility(self, false)
  if self.MediaPlayer:IsPlaying() then
    self.MediaPlayer:Close()
  end
end

function WBP_SeasonAbilityTip:Destruct(...)
  self:Hide()
end

return WBP_SeasonAbilityTip
