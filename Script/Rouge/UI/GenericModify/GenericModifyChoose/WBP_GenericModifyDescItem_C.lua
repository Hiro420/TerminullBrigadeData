local WBP_GenericModifyDescItem_C = UnLua.Class()
require("Rouge.UI.Battle.Logic.Logic_GenericModify")
function WBP_GenericModifyDescItem_C:InitGenericModifyDescItem(GenericModifyLevelId, GenericModifyId, bIsUpgrade, ModifyLevelDescShowType, bIsShowHelpInUI)
  UpdateVisibility(self, true)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ResultGenericModifyLevel, GenericModifyLevelRow = DTSubsystem:GetGenericModifyLevelDataByName(tostring(GenericModifyLevelId), nil)
  if not ResultGenericModifyLevel then
    return
  end
  local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(GenericModifyId))
  if not ResultGenericModify then
    return
  end
  self.RGTextDesc:SetText(GenericModifyLevelRow.Desc)
  local Level2DataMap
  local Unit = ""
  local Key
  if GenericModifyLevelRow.LevelDataAry:IsValidIndex(1) then
    Level2DataMap = GenericModifyLevelRow.LevelDataAry:GetRef(1).Level2DataMap
    Unit = GenericModifyLevelRow.LevelDataAry:GetRef(1).Unit
    Key = GenericModifyLevelRow.LevelDataAry:GetRef(1).Key
  end
  local GroupId = GenericModifyRow.GroupId
  local Slot = GenericModifyRow.Slot
  local HeroId = LogicRole.GetCurUseHeroId()
  local WeaponId = LogicRole:GetCurWeaponId()
  local RowName = string.format("%s_%s_%s_%s", tostring(GroupId), tostring(Slot), tostring(HeroId), tostring(WeaponId))
  local Ratio = 1
  local ResultGenericModifyLevelRatio, GenericModifyLevelRatioRow = GetRowData(DT.DT_GenericModifyLevelRatio, RowName)
  if ResultGenericModifyLevelRatio then
    Ratio = GenericModifyLevelRatioRow.FallbackRatio
    for i, v in pairs(GenericModifyLevelRatioRow.RatioDataArray) do
      if v.Key == Key then
        Ratio = v.Ratio
        break
      end
    end
  end
  UpdateVisibility(self.URGImageArrow, bIsUpgrade)
  UpdateVisibility(self.RGTextNextValue, bIsUpgrade)
  if bIsUpgrade then
    self.RGTextBaseValue:SetColorAndOpacity(self.UpgradeColor)
  else
    self.RGTextBaseValue:SetColorAndOpacity(self.NormalColor)
  end
  local GenericModifyData = LogicGenericModify:GetGenericModifyData(GenericModifyId)
  local Level = 1
  if GenericModifyData then
    Level = GenericModifyData.Level
  end
  local upgradeLevel = LogicGenericModify:GetModifyUpgradeLevelByModifyId(GenericModifyId)
  if ModifyLevelDescShowType == UE.EModifyLevelDesc.Addition then
    local ParamPre
    if Level2DataMap then
      ParamPre = Level2DataMap:Find(Level)
    end
    if ParamPre then
      local PreValue = ParamPre.Param * Ratio
      if IsInterger(PreValue) then
        self.RGTextBaseValue:SetText(math.floor(PreValue) .. Unit)
      else
        local ValueStr = string.format("%.1f", PreValue)
        self.RGTextBaseValue:SetText(ValueStr .. Unit)
      end
    else
      self.RGTextBaseValue:SetText("0" .. Unit)
    end
    if bIsUpgrade and Level2DataMap then
      local ParamCur = Level2DataMap:Find(Level + upgradeLevel)
      if ParamCur then
        local NextValue = ParamCur.Param * Ratio
        if IsInterger(NextValue) then
          self.RGTextNextValue:SetText(math.floor(NextValue) .. Unit)
        else
          local ValueStr = string.format("%.1f", NextValue)
          self.RGTextNextValue:SetText(ValueStr .. Unit)
        end
      end
    end
  elseif ModifyLevelDescShowType == UE.EModifyLevelDesc.FinalValue then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    local value = UE.URGGenericModifyComponent.GetGenericModifyBaseDamageFormActor(Character, GenericModifyId, Level)
    print(" WBP_GenericModifyDescItem_C:InitGenericModifyDescItem", Level, value)
    if IsInterger(value) then
      local valueInt = math.floor(value)
      self.RGTextBaseValue:SetText(valueInt)
    else
      local ValueStr = string.format("%.1f", value)
      self.RGTextBaseValue:SetText(ValueStr)
    end
    if bIsUpgrade then
      local nextValue = UE.URGGenericModifyComponent.GetGenericModifyBaseDamageFormActor(Character, GenericModifyId, Level + upgradeLevel)
      print(" WBP_GenericModifyDescItem_C:InitGenericModifyDescItem1", Level + upgradeLevel, nextValue)
      if IsInterger(nextValue) then
        self.RGTextNextValue:SetText(math.floor(nextValue))
      else
        local ValueStr = string.format("%.1f", nextValue)
        self.RGTextNextValue:SetText(ValueStr)
      end
    end
  end
  UpdateVisibility(self.Btn_Help, bIsShowHelpInUI)
end
function WBP_GenericModifyDescItem_C:Hide()
  UpdateVisibility(self, false)
end
return WBP_GenericModifyDescItem_C
