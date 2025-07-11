local WBP_ScrollSetTipsItem_C = UnLua.Class()
function WBP_ScrollSetTipsItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_ScrollSetTipsItem_C:InitScrollSetTipsItem(AttributeModifySetId, AttributeModifyId, ScrollTipsOpenTypeParam)
  UpdateVisibility(self, true)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollSetTipsItem_C:InitScrollItem not DTSubsystem")
    return nil
  end
  local Result, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(AttributeModifySetId, nil)
  if Result then
    SetImageBrushBySoftObject(self.URGImageScrollSetIcon, AttributeModifySetRow.SetIconWithBg)
    self.RGTextName:SetText(AttributeModifySetRow.SetName)
    local AttributeModifySetData = self:GetAttributeModifySetDataBySetId(AttributeModifySetId)
    UpdateVisibility(self.RGTextCurNum, false)
    local HaveScroll = self:CheckHaveScroll(AttributeModifyId)
    UpdateVisibility(self.RGTextNextNum, not HaveScroll)
    local ShowLv = 0
    if ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromAllScrollDetailsTips then
      if AttributeModifySetData then
        ShowLv = AttributeModifySetData.Level
      end
      UpdateVisibility(self.URGImageBg, false)
    elseif ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromTeamDamage then
      if AttributeModifySetData then
        ShowLv = AttributeModifySetData.Level
      end
      UpdateVisibility(self.URGImageBg, true)
    elseif ScrollTipsOpenTypeParam ~= EScrollTipsOpenType.EFromBag then
      if HaveScroll then
        if AttributeModifySetData then
          ShowLv = AttributeModifySetData.Level
        end
      else
        ShowLv = 1
        if AttributeModifySetData then
          ShowLv = AttributeModifySetData.Level + 1
        end
      end
      UpdateVisibility(self.URGImageBg, true)
    else
      if AttributeModifySetData then
        ShowLv = AttributeModifySetData.Level
      end
      UpdateVisibility(self.URGImageBg, true)
    end
    self.RGTextNextNum:SetText(string.format("(%d)", ShowLv))
    if ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromAllScrollDetailsTips then
      local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
      local Index = 1
      local MaxLv = Logic_Scroll:GetModifySetMaxLevel(AttributeModifySetData)
      for i = 1, MaxLv do
        local InscriptionIdPtr = Logic_Scroll:GetInscriptionBySetLv(i, AttributeModifySetId)
        if InscriptionIdPtr then
          local bIsActivated = ShowLv >= i
          if ShowLv >= 6 and 4 == i then
            bIsActivated = false
          end
          local InscriptionDesc = GetLuaInscriptionDesc(InscriptionIdPtr, 1)
          local ScrollSetTipsDescItemTemp = GetOrCreateItem(self.VerticalBoxDesc, Index, self.WBP_ScrollSetTipsDescItem:GetClass())
          ScrollSetTipsDescItemTemp:InitScrollSetTipsDescItem(bIsActivated, InscriptionDesc, i)
          Index = Index + 1
        end
      end
      HideOtherItem(self.VerticalBoxDesc, Index)
    else
      local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
      local Index = 1
      local MaxLv = Logic_Scroll:GetModifySetMaxLevel(AttributeModifySetData)
      for i = 1, MaxLv do
        local InscriptionIdPtr = Logic_Scroll:GetInscriptionBySetLv(i, AttributeModifySetId)
        if InscriptionIdPtr then
          local InscriptionDesc = GetLuaInscriptionDesc(InscriptionIdPtr, 1)
          local ScrollSetTipsDescItemTemp = GetOrCreateItem(self.VerticalBoxDesc, Index, self.WBP_ScrollSetTipsDescItem:GetClass())
          ScrollSetTipsDescItemTemp:InitScrollSetTipsDescItem(ShowLv >= i, InscriptionDesc, i)
          Index = Index + 1
        end
      end
      HideOtherItem(self.VerticalBoxDesc, Index)
    end
  end
end
function WBP_ScrollSetTipsItem_C:GetAttributeModifySetDataBySetId(SetId)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    for i, v in iterator(Character.AttributeModifyComponent.ActivatedSets) do
      if v.SetId == SetId then
        return v
      end
    end
  end
  return nil
end
function WBP_ScrollSetTipsItem_C:CheckHaveScroll(AttributeModifId)
  return false
end
function WBP_ScrollSetTipsItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_ScrollSetTipsItem_C:Destruct()
end
return WBP_ScrollSetTipsItem_C
