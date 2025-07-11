local WBP_SingleSeasonAbilityItem = UnLua.Class()
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityModule = require("Modules.SeasonAbility.SeasonAbilityModule")
function WBP_SingleSeasonAbilityItem:Construct()
  self.CurCostInfo = {}
end
function WBP_SingleSeasonAbilityItem:Show(AbilityId, Type, CurHeroId)
  if 0 == AbilityId then
    self:Hide()
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.AbilityId = AbilityId
  self.Type = Type
  self.CurHeroId = CurHeroId
  self:ChangeAnimationWidgetVis()
  self:RefreshStatus()
  local AbilityGroupInfo = SeasonAbilityData:GetAbilityTableRow(self.AbilityId)
  if AbilityGroupInfo then
    local AbilityLevel = SeasonAbilityData:GetSeasonAbilityLevel(self.AbilityId, self.CurHeroId)
    if 0 == AbilityLevel then
      AbilityLevel = 1
    end
    local TargetAbilityInfo = AbilityGroupInfo[AbilityLevel]
    if TargetAbilityInfo and not UE.UKismetStringLibrary.IsEmpty(TargetAbilityInfo.Icon) then
      SetImageBrushByPath(self.Img_Icon, TargetAbilityInfo.Icon)
    end
  end
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(self.LevelIconSoftObj) then
    UpdateVisibility(self.Img_Level, true)
    SetImageBrushBySoftObject(self.Img_Level, self.LevelIconSoftObj, self.LevelIconSize)
  else
    UpdateVisibility(self.Img_Level, false)
  end
  if not self.IsBind then
    EventSystem.AddListener(self, EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated, self.BindOnSeasonAbilityInfoUpdated)
    self.IsBind = true
  end
end
function WBP_SingleSeasonAbilityItem:ChangeAnimationWidgetVis(...)
  UpdateVisibility(self.CanvasPanel_Brighten_Big, self.IsBigItem)
  UpdateVisibility(self.CanvasPanel_Brighten_Small, not self.IsBigItem)
  UpdateVisibility(self.CanvasPanel_Write_Big, self.IsBigItem)
  UpdateVisibility(self.CanvasPanel_Write_Small, not self.IsBigItem)
  if self.IsBigItem then
    UpdateVisibility(self.CanvasPanel_Brighten_Big_Red, self.Type == TableEnums.ENUMAbilityType.Weapon)
    UpdateVisibility(self.CanvasPanel_Brighten_Big_Purple, self.Type == TableEnums.ENUMAbilityType.Skill)
    UpdateVisibility(self.CanvasPanel_Brighten_Big_Green, self.Type == TableEnums.ENUMAbilityType.Survival)
    UpdateVisibility(self.CanvasPanel_Write_Big_Red, self.Type == TableEnums.ENUMAbilityType.Weapon)
    UpdateVisibility(self.CanvasPanel_Write_Big_Purple, self.Type == TableEnums.ENUMAbilityType.Skill)
    UpdateVisibility(self.CanvasPanel_Write_Big_Green, self.Type == TableEnums.ENUMAbilityType.Survival)
  else
    UpdateVisibility(self.CanvasPanel_Brighten_Small_Red, self.Type == TableEnums.ENUMAbilityType.Weapon)
    UpdateVisibility(self.CanvasPanel_Brighten_Small_Purple, self.Type == TableEnums.ENUMAbilityType.Skill)
    UpdateVisibility(self.CanvasPanel_Brighten_Small_Green, self.Type == TableEnums.ENUMAbilityType.Survival)
    UpdateVisibility(self.CanvasPanel_Write_Small_Red, self.Type == TableEnums.ENUMAbilityType.Weapon)
    UpdateVisibility(self.CanvasPanel_Write_Small_Purple, self.Type == TableEnums.ENUMAbilityType.Skill)
    UpdateVisibility(self.CanvasPanel_Write_Small_Green, self.Type == TableEnums.ENUMAbilityType.Survival)
  end
end
function WBP_SingleSeasonAbilityItem:BindOnSeasonAbilityInfoUpdated(...)
  local CurLevel = SeasonAbilityData:GetSeasonAbilityLevel(self.AbilityId, self.CurHeroId)
  if self.IsUpgrade and CurLevel > self.CurRealLevel then
    self:PlayAnimationForward(self.Ani_write)
  end
  self:RefreshStatus()
end
function WBP_SingleSeasonAbilityItem:RefreshStatus()
  if not self.AbilityId then
    return
  end
  local IsLock = false
  local TargetType = self.Type
  local PreLevel = SeasonAbilityData:GetPreAbilityLevel(self.AbilityId, self.CurHeroId)
  local MaxCanUpgradeLevel = SeasonAbilityData:GetAbilityMaxCanUpgradeLevel(self.AbilityId, self.CurHeroId)
  local RealLevel = SeasonAbilityData:GetSeasonAbilityLevel(self.AbilityId, self.CurHeroId)
  local MaxLevel = SeasonAbilityData:GetAbilityMaxLevel(self.AbilityId)
  self.CurRealLevel = RealLevel
  if PreLevel > MaxCanUpgradeLevel and PreLevel > RealLevel then
    self:ResetLevelCost()
    SeasonAbilityData:SetPreAbilityLevel(self.AbilityId, MaxCanUpgradeLevel, self.CurHeroId)
    EventSystem.Invoke(EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated)
  end
  local PreLevel = SeasonAbilityData:GetPreAbilityLevel(self.AbilityId, self.CurHeroId)
  if 0 == MaxCanUpgradeLevel and 0 == PreLevel then
    IsLock = true
  end
  local CanUpgrade = false
  local Result, NeedExchangePointNum = SeasonAbilityData:IsMeetAbilityUpgradeCostCondition(self.AbilityId, self.CurHeroId)
  CanUpgrade = SeasonAbilityData:IsMeetPreAbilityGroupCondition(self.AbilityId, self.CurHeroId) and Result
  self.Txt_Progress:SetText(PreLevel .. "/" .. MaxLevel)
  self.Txt_Progress_Big:SetText(PreLevel .. "/" .. MaxLevel)
  self.Txt_Progress_Big_Can:SetText(PreLevel .. "/" .. MaxLevel)
  if not CanUpgrade and IsLock then
    TargetType = -1
    self.CanPlayBrightenAnim = true
  end
  local Style = SeasonAbilityModule:GetItemStyleByType(TargetType)
  if Style then
    local Color = UE.FSlateColor()
    if RealLevel < PreLevel then
      Color.SpecifiedColor = self.PreProgressTextColor
    else
      Color.SpecifiedColor = Style.ProgressTextColor
    end
    Color.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
    self.Txt_Progress:SetColorAndOpacity(Color)
    self.Txt_Progress_Big:SetColorAndOpacity(Color)
    self.Txt_Progress_Big_Can:SetColorAndOpacity(Color)
    self.Img_Bottom:SetColorAndOpacity(Style.BottomColor)
    if self.IsBigItem then
      SetImageBrushBySoftObject(self.Img_Bottom, Style.BigBottomImg)
      self.SizeBox_Icon:SetRenderScale(UE.FVector2D(self.BigIconScale, self.BigIconScale))
      self.URGImage_Prepare_Big:SetColorAndOpacity(Style.PrepareBigBottomColor)
      self.URGImage_Prepare_Big_1:SetColorAndOpacity(Style.PrepareBigOuterGlowColor)
      self:SetFontOutlineColor(Style.ProgressTextOutlineColor)
      if 0 == PreLevel then
        local TargetStyle = SeasonAbilityModule:GetItemStyleByType(-1)
        self.Img_Icon:SetColorAndOpacity(TargetStyle.IconColor)
      else
        self.Img_Icon:SetColorAndOpacity(UE.FLinearColor(1.0, 1.0, 1.0, 1.0))
      end
      self.Img_Icon:SetIsEnabled(0 ~= PreLevel)
    else
      SetImageBrushBySoftObject(self.Img_Bottom, Style.BottomImg)
      self.URGImage_Prepare:SetColorAndOpacity(Style.PrepareBottomColor)
      self.URGImage_Prepare_1:SetColorAndOpacity(Style.PrepareOuterGlowColor)
      self.Img_Icon:SetColorAndOpacity(Style.IconColor)
      self.Img_Icon:SetIsEnabled(not IsLock)
    end
  end
  UpdateVisibility(self.UpgradePanel, CanUpgrade)
  if CanUpgrade then
    self:PlayAnimation(self.Ani_Upgrade_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
    if self.CanPlayBrightenAnim then
      self:PlayAnimationForward(self.Ani_Brighten)
      self.CanPlayBrightenAnim = false
    end
  else
    self:StopAnimation(self.Ani_Upgrade_loop)
  end
  if self.IsBigItem then
    UpdateVisibility(self.LockPanel_Big, IsLock)
    UpdateVisibility(self.PreparePanel_Big, CanUpgrade or RealLevel < PreLevel)
    UpdateVisibility(self.Txt_Progress_Big_Can, CanUpgrade or RealLevel < PreLevel)
    UpdateVisibility(self.Txt_Progress_Big, true)
    UpdateVisibility(self.Txt_Progress, false)
    UpdateVisibility(self.URGImage_Prepare_Big, PreLevel > 0)
  else
    UpdateVisibility(self.LockPanel, IsLock)
    UpdateVisibility(self.PreparePanel, RealLevel < PreLevel)
    UpdateVisibility(self.Txt_Progress_Big_Can, false)
    UpdateVisibility(self.Txt_Progress_Big, false)
    UpdateVisibility(self.Txt_Progress, true)
  end
end
function WBP_SingleSeasonAbilityItem:ResetLevelCost()
  local PreLevel = SeasonAbilityData:GetPreAbilityLevel(self.AbilityId, self.CurHeroId)
  local MaxCanUpgradeLevel = SeasonAbilityData:GetAbilityMaxCanUpgradeLevel(self.AbilityId, self.CurHeroId)
  local AbilityGroupInfo = SeasonAbilityData:GetAbilityTableRow(self.AbilityId)
  if not AbilityGroupInfo then
    return
  end
  for Level, SingleAbilityInfo in pairs(AbilityGroupInfo) do
    if Level <= PreLevel and Level > MaxCanUpgradeLevel and self.CurCostInfo[Level] then
      SeasonAbilityData:SetPreCostSeasonAbilityPointNum(self.CurCostInfo[Level].PointNum * -1, self.CurCostInfo[Level].ExchangePointNum * -1, self.CurHeroId)
    end
  end
end
function WBP_SingleSeasonAbilityItem:OnLeftMouseDown(...)
  local AbilityGroupInfo = SeasonAbilityData:GetAbilityTableRow(self.AbilityId)
  if not AbilityGroupInfo then
    return
  end
  local PreLevel = SeasonAbilityData:GetPreAbilityLevel(self.AbilityId, self.CurHeroId)
  local MaxLevel = SeasonAbilityData:GetAbilityMaxLevel(self.AbilityId)
  if PreLevel >= MaxLevel then
    print("\232\181\155\229\173\163\232\131\189\229\138\155\229\183\178\231\187\143\230\187\161\231\186\167\228\186\134")
    return
  end
  local TargetAbilityGroupInfo = AbilityGroupInfo[PreLevel + 1]
  if not TargetAbilityGroupInfo then
    print("\230\178\161\230\156\137\231\155\174\230\160\135\232\181\155\229\173\163\232\131\189\229\138\155\228\191\161\230\129\175, LevelId:", PreLevel + 1)
    return
  end
  if not SeasonAbilityData:IsMeetPreAbilityGroupCondition(self.AbilityId, self.CurHeroId) then
    print("\228\184\141\230\187\161\232\182\179\229\137\141\231\189\174\232\181\155\229\173\163\232\131\189\229\138\155\230\157\161\228\187\182")
    ShowWaveWindow(self.NotMeetPreConditionTipId)
    return
  end
  local Result, NeedExchangePointNum = SeasonAbilityData:IsMeetAbilityUpgradeCostCondition(self.AbilityId, self.CurHeroId)
  if not Result then
    print("\232\180\167\229\184\129\228\184\141\232\182\179")
    ShowWaveWindow(self.NotMeetCostTipId)
    return
  end
  SeasonAbilityData:SetPreCostSeasonAbilityPointNum(TargetAbilityGroupInfo.ConsumerResourceNum, NeedExchangePointNum, self.CurHeroId)
  self.CurCostInfo[PreLevel + 1] = {
    PointNum = TargetAbilityGroupInfo.ConsumerResourceNum,
    ExchangePointNum = NeedExchangePointNum
  }
  SeasonAbilityData:SetPreAbilityLevel(self.AbilityId, PreLevel + 1, self.CurHeroId)
  self.IsUpgrade = true
  EventSystem.Invoke(EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated)
end
function WBP_SingleSeasonAbilityItem:OnRightMouseDown(...)
  self.IsUpgrade = false
  local AbilityInfo = SeasonAbilityData:GetAbilityTableRow(self.AbilityId)
  if not AbilityInfo then
    return
  end
  local PreLevel = SeasonAbilityData:GetPreAbilityLevel(self.AbilityId, self.CurHeroId)
  local RealLevel = SeasonAbilityData:GetSeasonAbilityLevel(self.AbilityId, self.CurHeroId)
  if 0 == PreLevel or PreLevel <= RealLevel then
    print("\230\151\160\230\179\149\229\135\143\229\176\145")
    return
  end
  local TargetAbilityInfo = AbilityInfo[PreLevel]
  if not TargetAbilityInfo then
    print("\230\178\161\230\156\137\231\155\174\230\160\135\232\181\155\229\173\163\232\131\189\229\138\155\228\191\161\230\129\175, LevelId:", PreLevel)
    return
  end
  SeasonAbilityData:SetPreCostSeasonAbilityPointNum(self.CurCostInfo[PreLevel].PointNum * -1, self.CurCostInfo[PreLevel].ExchangePointNum * -1, self.CurHeroId)
  self.CurCostInfo[PreLevel] = nil
  self.IsUpgrade = true
  SeasonAbilityData:SetPreAbilityLevel(self.AbilityId, PreLevel - 1, self.CurHeroId)
  EventSystem.Invoke(EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated)
end
function WBP_SingleSeasonAbilityItem:OnMouseEnter(MyGeometry, MouseEvent)
  if self.IsBigItem then
    UpdateVisibility(self.HoverPanel_Big, true)
  else
    UpdateVisibility(self.HoverPanel, true)
  end
  self:PlayAnimation(self.Ani_hover_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self:SetRenderScale(UE.FVector2D(1.1, 1.1))
  EventSystem.Invoke(EventDef.SeasonAbility.OnUpdateSeasonAbilityTipVis, true, self.AbilityId, self.Type)
end
function WBP_SingleSeasonAbilityItem:OnMouseLeave(MyGeometry, MouseEvent)
  if self.IsBigItem then
    UpdateVisibility(self.HoverPanel_Big, false)
  else
    UpdateVisibility(self.HoverPanel, false)
  end
  self:PlayAnimation(self.Ani_hover_out, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self:SetRenderScale(UE.FVector2D(1.0, 1.0))
  EventSystem.Invoke(EventDef.SeasonAbility.OnUpdateSeasonAbilityTipVis, false)
end
function WBP_SingleSeasonAbilityItem:Hide(...)
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:StopAllAnimations()
  self.IsBind = false
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated, self.BindOnSeasonAbilityInfoUpdated, self)
end
function WBP_SingleSeasonAbilityItem:Destruct(...)
  self:Hide()
end
return WBP_SingleSeasonAbilityItem
