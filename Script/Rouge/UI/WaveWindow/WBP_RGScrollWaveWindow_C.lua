local WBP_RGScrollWaveWindow_C = UnLua.Class()
local MaxNum = 4

function WBP_RGScrollWaveWindow_C:Construct()
end

function WBP_RGScrollWaveWindow_C:SetWaveWindowParam(WaveWindowParamParam)
  local SetData = UE.FRGAttributeModifySetContext()
  SetData.Level = WaveWindowParamParam.IntParam0
  SetData.SetId = WaveWindowParamParam.IntParam1
  self:Show(SetData)
end

function WBP_RGScrollWaveWindow_C:Show(ScrollSetData)
  local StartTime = self.Info.Duration - self.DesistAnim:GetEndTime()
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
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_RGScrollWaveWindow_C:Show not DTSubsystem")
    return nil
  end
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(ScrollSetData.SetId, nil)
  if ResultModifySet then
    SetImageBrushBySoftObject(self.URGImageScrollSetIcon, AttributeModifySetRow.SetIconWithBg)
  end
  local Index = 1
  local InscriptionId = -1
  local MaxLv = Logic_Scroll:GetModifySetMaxLevel(ScrollSetData)
  for i = 1, MaxLv do
    local InscriptionIdPtr = Logic_Scroll:GetInscriptionBySetLv(i, ScrollSetData.SetId)
    if InscriptionIdPtr then
      local WBP_HUD_ScrollSetLevelItemName = string.format("WBP_HUD_ScrollSetLevelItem%d", Index)
      if self[WBP_HUD_ScrollSetLevelItemName] then
        local bIsPlayAni = i == ScrollSetData.Level
        self[WBP_HUD_ScrollSetLevelItemName]:UpdateScrollSetLevelItem(i <= ScrollSetData.Level, bIsPlayAni, true)
        UpdateVisibility(self[WBP_HUD_ScrollSetLevelItemName], true)
        if i == ScrollSetData.Level then
          InscriptionId = InscriptionIdPtr
        end
      end
      Index = Index + 1
    end
  end
  local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if RGLogicCommandDataSubsystem and InscriptionId > 0 then
    local InscriptionDesc = GetLuaInscriptionDesc(InscriptionId, 1)
    if Logic_Scroll.NumToZh[ScrollSetData.Level] then
      local Desc = UE.FTextFormat(Logic_Scroll.NumToZh[ScrollSetData.Level](), InscriptionDesc)
      self.Txt_Info_1:SetText(Desc)
    end
  end
  for i = Index, MaxNum do
    local WBP_HUD_ScrollSetLevelItemName = string.format("WBP_HUD_ScrollSetLevelItem%d", i)
    if self[WBP_HUD_ScrollSetLevelItemName] then
      UpdateVisibility(self[WBP_HUD_ScrollSetLevelItemName], false)
    end
  end
end

function WBP_RGScrollWaveWindow_C:FadeOut()
  self:PlayAnimation(self.DesistAnim)
end

function WBP_RGScrollWaveWindow_C:Destruct()
  self.Overridden.Destruct(self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
end

function WBP_RGScrollWaveWindow_C:Hide()
end

return WBP_RGScrollWaveWindow_C
