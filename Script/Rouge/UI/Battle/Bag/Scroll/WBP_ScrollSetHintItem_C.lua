local WBP_ScrollSetHintItem_C = UnLua.Class()

function WBP_ScrollSetHintItem_C:InitScrollSetHintItem(AttributeModifySetData, AttributeModifyId, Duration)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollSetHintItem_C:InitHudScrollSetItem not DTSubsystem")
    return nil
  end
  UpdateVisibility(self, true)
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(AttributeModifySetData.SetId, nil)
  if ResultModifySet then
    SetImageBrushBySoftObject(self.URGImageScrollIcon, AttributeModifySetRow.SetIconWithBg)
    local activeSetFmt = NSLOCTEXT("WBP_ScrollSetHintItem_C", "activeSetFmt", "{0}\230\191\128\230\180\187\230\150\176\232\175\141\230\157\161")
    local activeSetTxt = UE.FTextFormat(activeSetFmt(), AttributeModifySetRow.SetName)
    self.RGTextDesc:SetText(activeSetTxt)
    local InscriptionId = Logic_Scroll:GetInscriptionBySetLv(AttributeModifySetData.Level, AttributeModifySetData.SetId)
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if RGLogicCommandDataSubsystem and InscriptionId and InscriptionId > 0 then
      local InscriptionDesc = GetLuaInscriptionDesc(InscriptionId)
      if Logic_Scroll.NumToZh[AttributeModifySetData.Level] then
        local Desc = UE.FTextFormat(Logic_Scroll.NumToZh[AttributeModifySetData.Level](), InscriptionDesc)
        self.RGTextSetDesc:SetText(Desc)
      end
    end
    local aniName = "ani_HUD_ScrollSetItem_in_" .. AttributeModifySetData.Level
    if self[aniName] then
      self:PlayAnimation(self[aniName])
    end
    local Index = 1
    local WBP_HUD_ScrollSetLevelItemName = string.format("WBP_HUD_ScrollSetLevelItem%d", Index)
    if self[WBP_HUD_ScrollSetLevelItemName] then
      do
        local baseLevel = AttributeModifySetRow.BaseInscription.Level
        local bPlayAni = self.AttributeModifySetData and self.AttributeModifySetData.Level < AttributeModifySetData.Level and AttributeModifySetData.Level == baseLevel
        self[WBP_HUD_ScrollSetLevelItemName]:UpdateScrollSetLevelItem(baseLevel <= AttributeModifySetData.Level, bPlayAni, not self.AttributeModifySetData)
      end
    end
    Index = Index + 1
    for k, v in pairs(AttributeModifySetRow.LevelInscriptionMap) do
      WBP_HUD_ScrollSetLevelItemName = string.format("WBP_HUD_ScrollSetLevelItem%d", Index)
      if self[WBP_HUD_ScrollSetLevelItemName] then
        local bPlayAni = self.AttributeModifySetData and self.AttributeModifySetData.Level < AttributeModifySetData.Level and AttributeModifySetData.Level == k
        self[WBP_HUD_ScrollSetLevelItemName]:UpdateScrollSetLevelItem(k <= AttributeModifySetData.Level, bPlayAni, not self.AttributeModifySetData)
      end
      Index = Index + 1
    end
  end
  local ResultModify, ModifyRow = GetRowData(DT.DT_AttributeModify, AttributeModifyId)
  if ResultModify then
    local ScrollNameFmt = NSLOCTEXT("WBP_ScrollSetHintItem_C", "ScrollNameFmt", "\230\157\165\232\135\170{0}")
    self.RGTextScrollName:SetText(UE.FTextFormat(ScrollNameFmt, ModifyRow.Name))
  end
  self.AttributeModifySetData = AttributeModifySetData
  local StartTime = Duration - self.ani_HUD_ScrollSetItem_out:GetEndTime()
  if StartTime < 0 then
    StartTime = 0
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
  if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.FadeOut
    }, StartTime, false)
  end
end

function WBP_ScrollSetHintItem_C:FadeOut()
  self:PlayAnimation(self.ani_HUD_ScrollSetItem_out)
end

function WBP_ScrollSetHintItem_C:Hide()
  self.AttributeModifySetData = nil
  UpdateVisibility(self, false)
end

function WBP_ScrollSetHintItem_C:Destruct()
  self.Overridden.Destruct(self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
end

return WBP_ScrollSetHintItem_C
