local WBP_CommonTalentTip_C = UnLua.Class()

function WBP_CommonTalentTip_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateCommonTalentPresetCost, WBP_CommonTalentTip_C.BindOnUpdateCommonTalentPresetCost)
end

function WBP_CommonTalentTip_C:BindOnUpdateCommonTalentPresetCost()
  self.Txt_HaveNum:SetText(LogicTalent.GetPreRemainCostNum(self.CostId))
  self.CurHaveNum = LogicTalent.GetPreRemainCostNum(self.CostId)
  self:UpdateHaveCurrencyColor()
end

function WBP_CommonTalentTip_C:RefreshInfo(TalentId, Type)
  self:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  local PreLevel = LogicTalent.GetPreCommonTalentLevel(TalentId)
  self.Txt_Level:SetText(tostring(PreLevel) .. "/" .. LogicTalent.GetMaxLevelByTalentId(TalentId))
  local Style = LogicTalent.GetTalentStyleItemByType(Type)
  if Style then
    SetImageBrushByPath(self.Img_Bottom, Style.BottomNormalImg)
    SetImageBrushByPath(self.Img_Icon, Style.IconImg)
  end
  local TalentGroupInfo = LogicTalent.GetTalentTableRow(TalentId)
  if not TalentGroupInfo then
    return
  end
  local FirstTalentInfo = TalentGroupInfo[1]
  if not FirstTalentInfo then
    return
  end
  self.Txt_Desc:SetText(FirstTalentInfo.Desc)
  local CurLevelTalentInfo = TalentGroupInfo[PreLevel]
  if 0 == PreLevel then
    CurLevelTalentInfo = TalentGroupInfo[1]
  end
  local NextLevelTalentInfo = TalentGroupInfo[PreLevel + 1]
  if CurLevelTalentInfo then
    self.Txt_Name:SetText(CurLevelTalentInfo.Name)
  end
  if Type == UE.ETalentItemType.AccumulativeCost then
    self.CostPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.AccumulativeCostPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local MaxUnLockLevel = DataMgr.GetCommonTalentLevelById(TalentId)
    local MaxLevel = LogicTalent.GetMaxLevelByTalentId(TalentId)
    if MaxUnLockLevel >= MaxLevel then
      local CostInfo = CurLevelTalentInfo.ArrCost[1]
      self.Txt_AccumulativeCostDesc:SetText(string.format(self.AccumulativeCostUnlockDesc, CostInfo.value))
    else
      local CostInfo = NextLevelTalentInfo.ArrCost[1]
      local FinalValue = CostInfo.value - DataMgr.GetCommonTalentsAccumulativeCostById(CostInfo.key)
      self.Txt_AccumulativeCostDesc:SetText(string.format(self.AccumulativeCostLockDesc, FinalValue))
    end
  else
    self.AccumulativeCostPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    if not NextLevelTalentInfo then
      if PreLevel == LogicTalent.GetMaxLevelByTalentId(TalentId) then
        self.CostPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.ConditionNotMeetPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      else
        print("invalid config,Talent group id:", TalentId)
      end
    else
      self.CostPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      self.ConditionNotMeetPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
      local NextLevelArrCostKey = NextLevelTalentInfo.ArrCost[1] and NextLevelTalentInfo.ArrCost[1].key or 0
      local NextLevelArrCostValue = NextLevelTalentInfo.ArrCost[1] and NextLevelTalentInfo.ArrCost[1].value or 0
      self.Txt_CostNum:SetText(NextLevelArrCostValue)
      self.CurCostNum = NextLevelArrCostValue
      self.CostId = NextLevelArrCostKey
      self.Txt_HaveNum:SetText(LogicTalent.GetPreRemainCostNum(NextLevelArrCostKey))
      self.CurHaveNum = LogicTalent.GetPreRemainCostNum(NextLevelArrCostKey)
      self:UpdateHaveCurrencyColor()
      local GeneralTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      local ResourceRow = GeneralTable[NextLevelArrCostKey]
      if ResourceRow then
        SetImageBrushByPath(self.Img_CostIcon, ResourceRow.Icon)
      end
    end
  end
  local AllChildren = self.TalentLevelDescList:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local Index = 0
  for Level, SingleTalentInfo in pairs(TalentGroupInfo) do
    local Item = self.TalentLevelDescList:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.DescTemplate:StaticClass())
      self.TalentLevelDescList:AddChild(Item)
    end
    Item:Show(PreLevel, Level, SingleTalentInfo.Desc)
    Index = Index + 1
  end
  self:UpdateTalentStatus(TalentId, Type)
end

function WBP_CommonTalentTip_C:UpdateHaveCurrencyColor()
  if not (self.CurHaveNum and self.CurCostNum) or self.CurHaveNum >= self.CurCostNum then
    self.Txt_HaveNum:SetColorAndOpacity(self.CurrencyEnoughColor)
  else
    self.Txt_HaveNum:SetColorAndOpacity(self.CurrencyNotEnoughColor)
  end
end

function WBP_CommonTalentTip_C:UpdateTalentStatus(TalentId, Type)
  if Type == UE.ETalentItemType.AccumulativeCost then
    self.ConditionNotMeetPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  if not LogicTalent.IsMeetPreTalentGroupCondition(TalentId) then
    local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
    if TalentInfo then
      local PreLevel = LogicTalent.GetPreCommonTalentLevel(TalentId)
      local TargetLevelTalentInfo = TalentInfo[PreLevel + 1]
      if TargetLevelTalentInfo then
        self.Txt_PreConditionNotMeet:SetText(UE.FTextFormat(self.PreConditionNotMeetTipText, TargetLevelTalentInfo.FrontGroupsLevel))
      else
        self.Txt_PreConditionNotMeet:SetText("")
        print("WBP_CommonTalentTip_C:UpdateTalentStatus invalid config,Talent group id:", TalentId, "level", PreLevel + 1)
      end
    else
      self.Txt_PreConditionNotMeet:SetText("")
      print("WBP_CommonTalentTip_C:UpdateTalentStatus invalid config,Talent group id:", TalentId)
    end
    self.Txt_PreConditionNotMeet:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.Txt_LevelNotMeet:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_CostNotMeet:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanvasPanel_UpgradeOperate:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Txt_PreConditionNotMeet:SetVisibility(UE.ESlateVisibility.Collapsed)
    local IsMeetRoleLevel, IsMeetTalentUpgradeCost = false, false
    if not LogicTalent.IsMeetRoleLevelCondition(TalentId) then
      self.Txt_LevelNotMeet:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    else
      self.Txt_LevelNotMeet:SetVisibility(UE.ESlateVisibility.Collapsed)
      IsMeetRoleLevel = true
    end
    if not LogicTalent.IsMeetTalentUpgradeCostCondition(TalentId) then
      self.Txt_CostNotMeet:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    else
      self.Txt_CostNotMeet:SetVisibility(UE.ESlateVisibility.Collapsed)
      IsMeetTalentUpgradeCost = true
    end
    if IsMeetRoleLevel and IsMeetTalentUpgradeCost then
      self.CanvasPanel_UpgradeOperate:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.CanvasPanel_UpgradeOperate:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function WBP_CommonTalentTip_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateCommonTalentPresetCost, WBP_CommonTalentTip_C.BindOnUpdateCommonTalentPresetCost, self)
end

return WBP_CommonTalentTip_C
