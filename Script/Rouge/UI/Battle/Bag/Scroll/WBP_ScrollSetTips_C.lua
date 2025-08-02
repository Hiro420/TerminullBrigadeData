local WBP_ScrollSetTips_C = UnLua.Class()
local ScrollSetDescItemPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetDescItem.WBP_ScrollSetDescItem_C"

function WBP_ScrollSetTips_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ScrollSetTips_C:InitScrollSetTips(ActivatedSetData)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollSetTips_C:InitScrollSetTips not DTSubsystem")
    return nil
  end
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(ActivatedSetData.SetId, nil)
  if ResultModifySet then
    SetImageBrushBySoftObject(self.URGImageIcon, AttributeModifySetRow.SetIconWithBg)
    self.RGTextName:SetText(AttributeModifySetRow.SetName)
    self.RGTextLevel:SetText(string.format("x%d", ActivatedSetData.Level))
    local ScrollSetDescItemCls = UE.UClass.Load(ScrollSetDescItemPath)
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    local Index = 1
    local MaxLevel = Logic_Scroll:GetModifySetMaxLevel(ActivatedSetData)
    for i = 1, MaxLevel do
      local InscriptionIdPtr = Logic_Scroll:GetInscriptionBySetLv(i, ActivatedSetData.SetId)
      if InscriptionIdPtr then
        local ScrollSetDescItem = GetOrCreateItem(self.VerticalBoxDesc, Index, ScrollSetDescItemCls)
        Index = Index + 1
        local InscriptionDesc = ""
        if RGLogicCommandDataSubsystem then
          InscriptionDesc = GetLuaInscriptionDesc(InscriptionIdPtr, 1)
        end
        local FinalDesc = InscriptionDesc
        if Logic_Scroll.NumToZh[i] then
          FinalDesc = UE.FTextFormat(Logic_Scroll.NumToZh[i](), InscriptionDesc)
        end
        ScrollSetDescItem.RichTextBlockDesc:SetText(FinalDesc)
        local bIsEnabled = i <= ActivatedSetData.Level
        if bIsEnabled then
          ScrollSetDescItem.RichTextBlockDesc:SetDefaultColorAndOpacity(self.ActivatedColor)
        else
          ScrollSetDescItem.RichTextBlockDesc:SetDefaultColorAndOpacity(self.InActivatedColor)
        end
        UpdateVisibility(ScrollSetDescItem.URGImageNotActived, not bIsEnabled)
        UpdateVisibility(ScrollSetDescItem.URGImageActived, bIsEnabled)
        ScrollSetDescItem:SetIsEnabled(bIsEnabled)
      end
    end
    HideOtherItem(self.VerticalBoxDesc, Index)
  end
end

function WBP_ScrollSetTips_C:Destruct()
  self.Overridden.Destruct(self)
end

return WBP_ScrollSetTips_C
