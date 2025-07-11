local WBP_ScrollDetailTipsView_C = UnLua.Class()
local ScrollSetTipsItemPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetTipsItem.WBP_ScrollSetTipsItem_C"
local InteractDuration = 1
local InteractTimerRate = 0.02
function WBP_ScrollDetailTipsView_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_ScrollDetailTipsView_C:UpdateScrollSetList(ActivatedSets)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollDetailTipsView_C:UpdateScrollSetList not DTSubsystem")
    return nil
  end
  local Index = 1
  for i, v in iterator(ActivatedSets) do
    if Logic_Scroll:CheckSetIsActived(v) then
      local ScrollSetTipsItem = GetOrCreateItem(self.VerticalBoxSetList, Index, self.WBP_ScrollSetTipsItem:GetClass())
      Index = Index + 1
      ScrollSetTipsItem:InitScrollSetTipsItem(v.SetId, -1, EScrollTipsOpenType.EFromAllScrollDetailsTips)
    end
  end
  HideOtherItem(self.VerticalBoxSetList, Index)
  UpdateVisibility(self.CanvasPanelSetNull, 1 == Index)
end
function WBP_ScrollDetailTipsView_C:UpdateScrollDescList(ActivatedModifies)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollDetailTipsView_C:UpdateScrollDescList not DTSubsystem")
    return nil
  end
  local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  local ActivatedModifyesLuaTb = ActivatedModifies:ToTable()
  table.sort(ActivatedModifyesLuaTb, self.ActivatedSort)
  local AttrBonusMap = {}
  local SortDataAry = {}
  for i, v in ipairs(ActivatedModifyesLuaTb) do
    local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(v, nil)
    if ResultModify then
      if AttributeModifyRow.bActivateOnceIfOwned then
        local bIsAlreadyInsert = false
        local Desc = GetLuaInscriptionDesc(AttributeModifyRow.Inscription, 1)
        for iSortData, vSortData in ipairs(SortDataAry) do
          if vSortData.Desc == Desc then
            bIsAlreadyInsert = true
            break
          end
        end
        if not bIsAlreadyInsert then
          table.insert(SortDataAry, {Desc = Desc})
        end
      else
        local InscriptionDA = RGLogicCommandDataSubsystem:GetInscriptionDAByID(AttributeModifyRow.Inscription)
        if InscriptionDA and InscriptionDA:IsValid() and InscriptionDA.bIstMergeEffectInUI then
          for iInscriptionData, vInscriptionData in pairs(InscriptionDA.InscriptionDataAry) do
            if vInscriptionData.Action then
              local Cls = vInscriptionData.Action:GetClass()
              if not AttrBonusMap[Cls] then
                AttrBonusMap[Cls] = {}
                table.insert(SortDataAry, {ActCls = Cls})
              end
              for iDesc, vDesc in pairs(vInscriptionData.Action.DescribeTextCombination) do
                if not AttrBonusMap[Cls][iDesc] then
                  AttrBonusMap[Cls][iDesc] = {DescFormat = vDesc}
                end
                local resultAry = ExtractStringsBetweenBraces(vDesc)
                for iResult, vResult in ipairs(resultAry) do
                  if not AttrBonusMap[Cls][iDesc][iResult] then
                    AttrBonusMap[Cls][iDesc][iResult] = {NumValue = 0, DescTag = vResult}
                  end
                  local numValue = vInscriptionData.Action[vResult]
                  AttrBonusMap[Cls][iDesc][iResult].NumValue = AttrBonusMap[Cls][iDesc][iResult].NumValue + numValue
                end
              end
            end
          end
        elseif InscriptionDA and InscriptionDA:IsValid() then
          local Desc = GetLuaInscriptionDesc(AttributeModifyRow.Inscription, 1)
          table.insert(SortDataAry, {Desc = Desc})
        end
      end
    end
  end
  local Index = 1
  for i, v in ipairs(SortDataAry) do
    if v.Desc ~= nil then
      local ScrollDescItem = GetOrCreateItem(self.VerticalBoxDesc, Index, self.WBP_ScrollDescItem:GetClass())
      ScrollDescItem:InitScrollDescItem(v.Desc)
      Index = Index + 1
    elseif v.ActCls ~= nil then
      local AttrBonusMapItem = AttrBonusMap[v.ActCls]
      if AttrBonusMapItem then
        for iDesc, vDesc in ipairs(AttrBonusMapItem) do
          local FinalDesc = vDesc.DescFormat
          for iResult, vResult in ipairs(vDesc) do
            local TargetStr = "{" .. vResult.DescTag .. "}"
            FinalDesc = StrReplace(FinalDesc, TargetStr, tostring(math.abs(vResult.NumValue)))
          end
          local ScrollDescItem = GetOrCreateItem(self.VerticalBoxDesc, Index, self.WBP_ScrollDescItem:GetClass())
          ScrollDescItem:InitScrollDescItem(FinalDesc)
          Index = Index + 1
        end
      end
    end
  end
  HideOtherItem(self.VerticalBoxDesc, Index)
  UpdateVisibility(self.URGImageDivider, Index > 1)
  UpdateVisibility(self.CanvasPanelAllNull, 1 == Index)
  if 1 == Index then
    self.CanvasPanelSetNull:SetRenderOpacity(0)
  else
    self.CanvasPanelSetNull:SetRenderOpacity(1)
  end
end
function WBP_ScrollDetailTipsView_C.ActivatedSort(First, Second)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollDetailTipsView_C:ActivatedSort not DTSubsystem")
    return false
  end
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(First, nil)
  local ResultModifySecond, AttributeModifySecondRow = DTSubsystem:GetAttributeModifyDataById(Second, nil)
  if ResultModify and ResultModifySecond then
    local ResultModifyWeight, AttributeModifyWeightRow = DTSubsystem:GetAttributeModifyAttrShowWeightDataById(AttributeModifyRow.Inscription)
    local ResultModifyWeightSecond, AttributeModifyWeightSecondRow = DTSubsystem:GetAttributeModifyAttrShowWeightDataById(AttributeModifySecondRow.Inscription)
    if not ResultModifyWeight and ResultModifyWeightSecond then
      return false
    end
    if ResultModifyWeight and not ResultModifyWeightSecond then
      return true
    end
    if ResultModifyWeight and ResultModifyWeightSecond then
      return AttributeModifyWeightRow.Weight > AttributeModifyWeightSecondRow.Weight
    end
  end
  return First < Second
end
function WBP_ScrollDetailTipsView_C:Reset()
end
function WBP_ScrollDetailTipsView_C:Destruct()
  self.Overridden.Destruct(self)
  self:Reset()
end
return WBP_ScrollDetailTipsView_C
