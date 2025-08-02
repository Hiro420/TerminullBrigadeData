local WBP_SingleTalentItem_C = UnLua.Class()
local CancelTalentName = "CancelTalent"

function WBP_SingleTalentItem_C:Construct()
  self.CurCostInfo = {}
  self.HoverPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  UpdateVisibility(self.HoverPanel_Big, false)
  UpdateVisibility(self.HoverPanel_AccumulativeCost, false)
  self.CurRealLevel = -1
  self.IsUpgrade = false
end

function WBP_SingleTalentItem_C:OnLeftMouseDown()
  if self.Type == UE.ETalentItemType.AccumulativeCost then
    print("\230\182\136\232\128\151\231\180\175\232\174\161\231\177\187\229\164\169\232\181\139\239\188\140\230\151\160\230\179\149\231\130\185\229\135\187")
    return
  end
  local TalentInfo = LogicTalent.GetTalentTableRow(self.TalentId)
  if not TalentInfo then
    return
  end
  local PreLevel = LogicTalent.GetPreCommonTalentLevel(self.TalentId)
  local MaxLevel = LogicTalent.GetMaxLevelByTalentId(self.TalentId)
  if PreLevel >= MaxLevel then
    print("\229\164\169\232\181\139\229\183\178\231\187\143\230\187\161\231\186\167\228\186\134")
    LogicAudio.OnTalentUnClick()
    return
  end
  if not LogicTalent.IsMeetPreTalentGroupCondition(self.TalentId) then
    print("\228\184\141\230\187\161\232\182\179\229\137\141\231\189\174\229\164\169\232\181\139\230\157\161\228\187\182")
    LogicAudio.OnTalentUnClick()
    self:ShowWaveWindow(1037)
    return
  end
  if not LogicTalent.IsMeetRoleLevelCondition(self.TalentId) then
    print("\231\173\137\231\186\167\228\184\141\232\182\179")
    LogicAudio.OnTalentUnClick()
    self:ShowWaveWindow(1040)
    return
  end
  if not LogicTalent.IsMeetTalentUpgradeCostCondition(self.TalentId) then
    print("\232\180\167\229\184\129\228\184\141\232\182\179")
    LogicAudio.OnTalentUnClick()
    self:ShowWaveWindow(1036)
    return
  end
  local TargetTalentInfo = TalentInfo[PreLevel + 1]
  if not TargetTalentInfo then
    print("\230\178\161\230\156\137\231\155\174\230\160\135\229\164\169\232\181\139\228\191\161\230\129\175, LevelId:", PreLevel + 1)
    LogicAudio.OnTalentUnClick()
    return
  end
  for i, SingleArrCostInfo in ipairs(TargetTalentInfo.ArrCost) do
    local CurPreCostNum = LogicTalent.GetPreRemainCostNum(SingleArrCostInfo.key)
    if CurPreCostNum >= SingleArrCostInfo.value then
      LogicTalent.SetPreRemainCostNum(SingleArrCostInfo.key, SingleArrCostInfo.value * -1)
      local TempTable = {}
      TempTable.CostId = SingleArrCostInfo.key
      TempTable.CostNum = SingleArrCostInfo.value
      self.CurCostInfo[PreLevel + 1] = TempTable
      break
    end
  end
  print(" WBP_SingleTalentItem_C:OnLeftMouseDown", self.TalentId, LogicTalent.GetPreRemainCostNum(99994))
  LogicTalent.SetPreCommonTalentLevel(self.TalentId, PreLevel + 1)
  self.IsUpgrade = true
  EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentInfo)
  if self.IsBigItem then
    UpdateVisibility(self.CanvasPanel_BigInAnim, true)
    self:PlayAnimation(self.Ani_big_in)
  else
    UpdateVisibility(self.CanvasPanel_SmallInAnim, true)
    self:PlayAnimation(self.Ani_small_in)
  end
  self:PlayAnimation(self.Ani_text)
  PlaySound2DEffect(16, "")
end

function WBP_SingleTalentItem_C:ShowWaveWindow(Id)
  local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not RGWaveWindowManager then
    return
  end
  RGWaveWindowManager:ShowWaveWindow(Id, {})
end

function WBP_SingleTalentItem_C:OnRightMouseDown()
  self.IsUpgrade = false
  if self.Type == UE.ETalentItemType.AccumulativeCost then
    print("\230\182\136\232\128\151\231\180\175\232\174\161\231\177\187\229\164\169\232\181\139\239\188\140\230\151\160\230\179\149\231\130\185\229\135\187")
    return
  end
  local TalentInfo = LogicTalent.GetTalentTableRow(self.TalentId)
  if not TalentInfo then
    return
  end
  local PreLevel = LogicTalent.GetPreCommonTalentLevel(self.TalentId)
  local RealLevel = DataMgr.GetCommonTalentLevelById(self.TalentId)
  if 0 == PreLevel or PreLevel <= RealLevel then
    print("\230\151\160\230\179\149\229\135\143\229\176\145")
    LogicAudio.OnTalentUnClick()
    return
  end
  local TargetTalentInfo = TalentInfo[PreLevel]
  if not TargetTalentInfo then
    print("\230\178\161\230\156\137\231\155\174\230\160\135\229\164\169\232\181\139\228\191\161\230\129\175, LevelId:", PreLevel)
    LogicAudio.OnTalentUnClick()
    return
  end
  for i, SingleArrCostInfo in ipairs(TargetTalentInfo.ArrCost) do
    LogicTalent.SetPreRemainCostNum(SingleArrCostInfo.key, SingleArrCostInfo.value)
    self.CurCostInfo[PreLevel] = nil
  end
  self.IsUpgrade = true
  print("WBP_SingleTalentItem_C:OnRightMouseDown", self.TalentId, LogicTalent.GetPreRemainCostNum(99994))
  LogicTalent.SetPreCommonTalentLevel(self.TalentId, PreLevel - 1)
  EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentInfo)
  PlaySound2DEffect(17, "")
end

function WBP_SingleTalentItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.IsBigItem then
    UpdateVisibility(self.HoverPanel_Big, true)
  elseif self.Type == UE.ETalentItemType.AccumulativeCost then
    UpdateVisibility(self.HoverPanel_AccumulativeCost, true)
  else
    UpdateVisibility(self.HoverPanel, true)
  end
  LogicAudio.OnTalentPick()
  if not IsListeningForInputAction(self, CancelTalentName) then
    ListenForInputAction(CancelTalentName, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.OnRightMouseDown
    })
  end
  self.IsMouseEnter = true
  local ClassPath = "/Game/Rouge/UI/Lobby/Talent/WBP_CommonTalentTip.WBP_CommonTalentTip_C"
  self.HoverTips = ShowCommonTips(nil, self, nil, ClassPath, nil)
  self.HoverTips:RefreshInfo(self.TalentId, self.Type)
end

function WBP_SingleTalentItem_C:OnMouseLeave(MouseEvent)
  if self.IsBigItem then
    UpdateVisibility(self.HoverPanel_Big, false)
  elseif self.Type == UE.ETalentItemType.AccumulativeCost then
    UpdateVisibility(self.HoverPanel_AccumulativeCost, false)
  else
    UpdateVisibility(self.HoverPanel, false, true, true)
  end
  if IsListeningForInputAction(self, CancelTalentName) then
    StopListeningForInputAction(self, CancelTalentName, UE.EInputEvent.IE_Pressed)
  end
  self.IsMouseEnter = false
  UpdateVisibility(self.HoverTips, false)
end

function WBP_SingleTalentItem_C:InitInfo(TalentId, Type)
  if 0 == TalentId then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.TalentId = TalentId
  self.Type = Type
  local OverlaySlot = UE.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.Txt_Progress)
  if OverlaySlot then
    if self.IsBigItem then
      OverlaySlot:SetPadding(self.BigTextPadding)
    else
      OverlaySlot:SetPadding(self.SmallTextPadding)
    end
  end
  UpdateVisibility(self.CanvasPanel_SmallInAnim, false)
  UpdateVisibility(self.CanvasPanel_BigInAnim, false)
  UpdateVisibility(self.CanvasPanel_SmallInRed, not self.IsBigItem and self.Type == UE.ETalentItemType.Attack)
  UpdateVisibility(self.CanvasPanel_SmallInGreen, not self.IsBigItem and self.Type == UE.ETalentItemType.Live)
  UpdateVisibility(self.CanvasPanel_SmallInBlue, not self.IsBigItem and self.Type == UE.ETalentItemType.Resource)
  UpdateVisibility(self.CanvasPanel_BigInRed, self.IsBigItem and self.Type == UE.ETalentItemType.Attack)
  UpdateVisibility(self.CanvasPanel_BigInGreen, self.IsBigItem and self.Type == UE.ETalentItemType.Live)
  UpdateVisibility(self.CanvasPanel_BigInBlue, self.IsBigItem and self.Type == UE.ETalentItemType.Resource)
  UpdateVisibility(self.CanvasPanel_SmallOpenAnimRed, not self.IsBigItem and self.Type == UE.ETalentItemType.Attack)
  UpdateVisibility(self.CanvasPanel_SmallOpenAnimGreen, not self.IsBigItem and self.Type == UE.ETalentItemType.Live)
  UpdateVisibility(self.CanvasPanel_SmallOpenAnimBlue, not self.IsBigItem and self.Type == UE.ETalentItemType.Resource)
  UpdateVisibility(self.CanvasPanel_BigOpenAnimRed, self.IsBigItem and self.Type == UE.ETalentItemType.Attack)
  UpdateVisibility(self.CanvasPanel_BigOpenAnimGreen, self.IsBigItem and self.Type == UE.ETalentItemType.Live)
  UpdateVisibility(self.CanvasPanel_BigOpenAnimBlue, self.IsBigItem and self.Type == UE.ETalentItemType.Resource)
  self:RefreshStatus()
  local TalentGroupInfo = LogicTalent.GetTalentTableRow(self.TalentId)
  if TalentGroupInfo then
    local TalentLevel = DataMgr.GetCommonTalentLevelById(self.TalentId)
    if 0 == TalentLevel then
      TalentLevel = 1
    end
    local TargetTalentInfo = TalentGroupInfo[TalentLevel]
    if TargetTalentInfo and not UE.UKismetStringLibrary.IsEmpty(TargetTalentInfo.Icon) then
      SetImageBrushByPath(self.Img_Icon, TargetTalentInfo.Icon)
    end
  end
  EventSystem.AddListener(self, EventDef.Lobby.UpdateCommonTalentInfo, WBP_SingleTalentItem_C.BindOnUpdateCommonTalentsInfo)
end

function WBP_SingleTalentItem_C:RefreshStatus()
  if not self.TalentId then
    return
  end
  local LastIsLock = self.IsLock ~= nil and self.IsLock or false
  self.IsLock = false
  local TargetType = self.Type
  local PreLevel = LogicTalent.GetPreCommonTalentLevel(self.TalentId)
  local MaxCanUpgradeLevel = LogicTalent.GetMaxCanUpgradeLevel(self.TalentId)
  local RealLevel = DataMgr.GetCommonTalentLevelById(self.TalentId)
  self.CurRealLevel = RealLevel
  if PreLevel > MaxCanUpgradeLevel and PreLevel > RealLevel then
    self:ResetLevelCost()
    LogicTalent.SetPreCommonTalentLevel(self.TalentId, MaxCanUpgradeLevel)
    EventSystem.Invoke(EventDef.Lobby.UpdateCommonTalentInfo)
  end
  if 0 == MaxCanUpgradeLevel or 0 == PreLevel and not LogicTalent.IsMeetRoleLevelCondition(self.TalentId) then
    if self.Type == UE.ETalentItemType.AccumulativeCost then
      TargetType = UE.ETalentItemType.AccumulativeCostUnLock
    end
    self.IsLock = true
  end
  local PreLevel = LogicTalent.GetPreCommonTalentLevel(self.TalentId)
  self.Txt_Progress:SetText(PreLevel .. "/" .. LogicTalent.GetMaxLevelByTalentId(self.TalentId))
  if self.Type == UE.ETalentItemType.AccumulativeCost then
    self.Txt_Progress:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.Img_Bottom_yy, false)
  else
    self.Txt_Progress:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    UpdateVisibility(self.Img_Bottom_yy, true)
  end
  local Style = LogicTalent.GetTalentStyleItemByType(TargetType)
  if Style then
    local Color = UE.FSlateColor()
    if PreLevel > DataMgr.GetCommonTalentLevelById(self.TalentId) then
      Color.SpecifiedColor = self.PreProgressTextColor
    else
      Color.SpecifiedColor = Style.ProgressTextColor
    end
    Color.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
    self.Txt_Progress:SetColorAndOpacity(Color)
    self.Img_Bottom:SetColorAndOpacity(Style.BottomColor)
    self.Img_Bottom_Zs:SetColorAndOpacity(Style.BottomDecorateColor)
    self.Img_Icon:SetColorAndOpacity(Style.IconColor)
    SetImageBrushBySoftObjectPath(self.Img_Hover, Style.HoverImg)
    if self.IsBigItem then
      SetImageBrushBySoftObjectPath(self.Img_Bottom, Style.BigBottomImg)
      SetImageBrushBySoftObjectPath(self.Img_Bottom_Zs, Style.BigBottomDecorateImg)
      self.SizeBox_Icon:SetRenderScale(UE.FVector2D(self.BigIconScale, self.BigIconScale))
    else
      SetImageBrushBySoftObjectPath(self.Img_Bottom, Style.BottomImg)
      SetImageBrushBySoftObjectPath(self.Img_Bottom_Zs, Style.BottomDecorateImg)
    end
  end
  UpdateVisibility(self.CanvasPanel_BigOpenAnim, self.IsBigItem and not self.IsLock and LastIsLock)
  UpdateVisibility(self.CanvasPanel_SmallOpenAnim, not self.IsBigItem and self.Type ~= UE.ETalentItemType.AccumulativeCost and not self.IsLock and LastIsLock)
  UpdateVisibility(self.CanvasPanel_AccumulativeOpenAnim, self.Type == UE.ETalentItemType.AccumulativeCost and not self.IsLock and LastIsLock)
  if self.IsLock then
    if self.IsBigItem then
      UpdateVisibility(self.LockPanel_Big, true)
    elseif self.Type == UE.ETalentItemType.AccumulativeCost then
      UpdateVisibility(self.LockPanel_Accumulative, true)
    else
      UpdateVisibility(self.LockPanel, true)
    end
    UpdateVisibility(self.Img_Bottom_Zs, false)
  else
    if self.IsBigItem then
      UpdateVisibility(self.LockPanel_Big, false)
    elseif self.Type == UE.ETalentItemType.AccumulativeCost then
      UpdateVisibility(self.LockPanel_Accumulative, false)
    else
      UpdateVisibility(self.LockPanel, false)
    end
    UpdateVisibility(self.Img_Bottom_Zs, true)
    if LastIsLock then
      if self.IsBigItem then
        self:PlayAnimation(self.Ani_big_open)
      elseif self.Type == UE.ETalentItemType.AccumulativeCost then
        self:PlayAnimation(self.Ani_up)
      else
        self:PlayAnimation(self.Ani_small_open)
      end
    end
  end
  self:RefreshCanUpgradePanelStatus()
end

function WBP_SingleTalentItem_C:ResetLevelCost()
  local PreLevel = LogicTalent.GetPreCommonTalentLevel(self.TalentId)
  local MaxCanUpgradeLevel = LogicTalent.GetMaxCanUpgradeLevel(self.TalentId)
  local TalentGroupInfo = LogicTalent.GetTalentTableRow(self.TalentId)
  if not TalentGroupInfo then
    return
  end
  for Level, SingleTalentInfo in pairs(TalentGroupInfo) do
    if Level <= PreLevel and Level > MaxCanUpgradeLevel and self.CurCostInfo[Level] then
      LogicTalent.SetPreRemainCostNum(self.CurCostInfo[Level].CostId, self.CurCostInfo[Level].CostNum)
    end
  end
end

function WBP_SingleTalentItem_C:RefreshCanUpgradePanelStatus()
  local CanUpgrade = self.Type ~= UE.ETalentItemType.AccumulativeCost and LogicTalent.IsMeetPreTalentGroupCondition(self.TalentId) and LogicTalent.IsMeetRoleLevelCondition(self.TalentId) and LogicTalent.IsMeetTalentUpgradeCostCondition(self.TalentId)
  UpdateVisibility(self.UpgradePanel, CanUpgrade)
  if CanUpgrade then
    self.NiagaraSystemWidget_CanUpgrade:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    UpdateVisibility(self.NiagaraSystemWidget_CanUpgrade, false)
  end
  if CanUpgrade then
    if not self.IsPlayUpgradeLoopAnim then
      self:PlayAnimation(self.Ani_Upgrade_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
      self.IsPlayUpgradeLoopAnim = true
    end
  elseif self.IsPlayUpgradeLoopAnim then
    self:StopAnimation(self.Ani_Upgrade_loop)
    self.IsPlayUpgradeLoopAnim = false
  end
end

function WBP_SingleTalentItem_C:BindOnUpdateCommonTalentsInfo()
  local CurLevel = DataMgr.GetCommonTalentLevelById(self.TalentId)
  if self.IsUpgrade and CurLevel > self.CurRealLevel then
    if self.IsBigItem then
      self:PlayAnimation(self.Ani_big_in)
    else
      self:PlayAnimation(self.Ani_small_in)
    end
    self:PlayAnimation()
  end
  self:RefreshStatus()
  if self.IsMouseEnter and self.HoverTips and self.HoverTips:IsVisible() then
    self.HoverTips:RefreshInfo(self.TalentId)
  end
end

function WBP_SingleTalentItem_C:Destruct()
  self:StopAllAnimations()
  self.IsPlayUpgradeLoopAnim = false
  EventSystem.RemoveListener(EventDef.Lobby.UpdateCommonTalentInfo, WBP_SingleTalentItem_C.BindOnUpdateCommonTalentsInfo, self)
  if IsListeningForInputAction(self, CancelTalentName) then
    StopListeningForInputAction(self, CancelTalentName, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_SingleTalentItem_C:HideTalentView()
  if IsListeningForInputAction(self, CancelTalentName) then
    StopListeningForInputAction(self, CancelTalentName, UE.EInputEvent.IE_Pressed)
  end
  UpdateVisibility(self.HoverTips, false)
end

return WBP_SingleTalentItem_C
