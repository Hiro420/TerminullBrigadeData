local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local WBP_CommonTalent_C = UnLua.Class()

function WBP_CommonTalent_C:OnBindUIInput()
  self.WBP_InteractTipWidgetWrite:BindInteractAndClickEvent(self, self.BindOnConfirmButtonClicked)
end

function WBP_CommonTalent_C:OnUnBindUIInput()
  self.WBP_InteractTipWidgetWrite:UnBindInteractAndClickEvent(self, self.BindOnConfirmButtonClicked)
end

function WBP_CommonTalent_C:Construct()
  self.Overridden.Construct(self)
  self.AllTalentItems = {}
  self.CanClickUpgrade = false
  self:InitInfo()
  self:CollectLinePosition()
  self.Btn_Confirm.OnClicked:Add(self, WBP_CommonTalent_C.BindOnConfirmButtonClicked)
  self.Btn_TipConfirm.OnClicked:Add(self, WBP_CommonTalent_C.BindOnTipConfirmButtonClicked)
  self.Btn_TipCancel.OnClicked:Add(self, WBP_CommonTalent_C.BindOnTipCancelButtonClicked)
  local ItemStyleList = self.ItemStyleList:ToTable()
  LogicTalent.InitTalentItemStyle(ItemStyleList)
  self.MovePanelTopLeftPos = UE.FVector2D(-600, -1000)
  local ViewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(self) / UE.UWidgetLayoutLibrary.GetViewportScale(self)
  local MovePanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MovePanel)
  local MovePanelOffset = MovePanelSlot:GetOffsets()
  local SizeX = ViewportSize.X - MovePanelOffset.Left - MovePanelOffset.Right
  local SizeY = ViewportSize.Y - MovePanelOffset.Bottom - MovePanelOffset.Top
  self.MovePanelSize = UE.FVector2D(SizeX, SizeY)
end

function WBP_CommonTalent_C:InitInfo()
  self:InitTalentItemInfo(self.ResourceItemPanel, UE.ETalentItemType.Resource)
  self:InitTalentItemInfo(self.LiveItemPanel, UE.ETalentItemType.Live)
  self:InitTalentItemInfo(self.SkillItemPanel, UE.ETalentItemType.Skill)
  self:InitTalentItemInfo(self.AttackItemPanel, UE.ETalentItemType.Attack)
  self:InitTalentItemInfo(self.AccumulativeTalentList, UE.ETalentItemType.AccumulativeCost)
  self:InitTalentLine()
end

function WBP_CommonTalent_C:InitTalentLine()
  local LobbySettings = UE.URGLobbySettings.GetLobbySettings()
  local AllChildren = self.CanvasPanel_TalentLine:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    local ItemInfoList, TalentId
    if LobbySettings.AllCommonTalentList:Find(SingleItem.Type) then
      ItemInfoList = LobbySettings.AllCommonTalentList:FindRef(SingleItem.Type).TalentList
    end
    if ItemInfoList and ItemInfoList:IsValidIndex(SingleItem.Index + 1) then
      TalentId = ItemInfoList[SingleItem.Index + 1]
    end
    SingleItem:Show(TalentId)
  end
end

function WBP_CommonTalent_C:InitTalentItemInfo(ItemPanel, Type)
  local ItemInfoList
  local LobbySettings = UE.URGLobbySettings.GetLobbySettings()
  if LobbySettings.AllCommonTalentList:Find(Type) then
    ItemInfoList = LobbySettings.AllCommonTalentList:FindRef(Type).TalentList
  end
  if not ItemInfoList then
    return
  end
  local AllItems = ItemPanel:GetAllChildren()
  for i, SingleItem in pairs(AllItems) do
    if ItemInfoList:IsValidIndex(i) then
      if Type == UE.ETalentItemType.AccumulativeCost then
        local NextTalentId, PreTalentId
        if ItemInfoList:IsValidIndex(i + 1) then
          NextTalentId = ItemInfoList[i + 1]
        end
        if ItemInfoList:IsValidIndex(i - 1) then
          PreTalentId = ItemInfoList[i - 1]
        end
        SingleItem:InitInfo(i, ItemInfoList[i], Type, PreTalentId, NextTalentId)
      else
        SingleItem:InitInfo(ItemInfoList[i], Type)
      end
      if ItemInfoList[i] then
        self.AllTalentItems[ItemInfoList[i]] = SingleItem
      end
    else
      SingleItem:InitInfo(0, Type)
    end
  end
end

function WBP_CommonTalent_C:CollectLinePosition()
  local LineInfos = {}
  for TalentId, TalentItem in pairs(self.AllTalentItems) do
    local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
    if TalentInfo and TalentInfo[1] then
      for i, SinglePreItemId in ipairs(TalentInfo[1].FrontGroupsId) do
        if 0 ~= SinglePreItemId then
          local PreItem = self.AllTalentItems[SinglePreItemId]
          if PreItem then
            local TempTable = {}
            local PreItemSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(PreItem)
            local CurItemSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(TalentItem)
            local ViewPortSize = UE.UWidgetLayoutLibrary.GetViewportSize(self)
            local ViewPortScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
            local RealViewPortSize = ViewPortSize / ViewPortScale
            local MovePanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MovePanel)
            local MovePanelOffset = MovePanelSlot:GetOffsets()
            local LeftDiff = (MovePanelOffset.Left + MovePanelOffset.Right) / 2
            local TopDiff = (MovePanelOffset.Top + MovePanelOffset.Bottom) / 2
            TempTable.BeginPos = UE.FVector2D(PreItemSlot.LayoutData.Offsets.Left + RealViewPortSize.X / 2 - LeftDiff, PreItemSlot.LayoutData.Offsets.Top + RealViewPortSize.Y / 2 - TopDiff)
            TempTable.EndPos = UE.FVector2D(CurItemSlot.LayoutData.Offsets.Left + RealViewPortSize.X / 2 - LeftDiff, CurItemSlot.LayoutData.Offsets.Top + RealViewPortSize.Y / 2 - TopDiff)
            TempTable.BeginItem = PreItem
            TempTable.EndItem = TalentItem
            TempTable.ParentPanel = self.MovePanel
            table.insert(LineInfos, TempTable)
          end
        end
      end
    end
  end
  self.TalentLine:SetLineInfos(LineInfos)
end

function WBP_CommonTalent_C:Show()
  self.IsInitiativeStop = false
  self:StopAllAnimations()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateCommonTalentPresetCost, self.BindOnUpdateCommonTalentPresetCost)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateCommonTalentInfo, self.BindOnUpdateCommonTalentInfo)
  self:RefreshItemStatus()
  self:RefreshPreAccumulativeCostNum()
  self:RefreshAccumulativeCostNum()
  self:RefreshAccumulativeCostIcon()
  self:InitTalentLine()
  self:ChangePreventMisContactImgDuringMovingPanelVis(false)
  BeginnerGuideData:UpdateWBP("WBP_CommonTalent", self)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnTalentPanelShow)
  self:PlayAnimation(self.Ani_in, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, true)
end

function WBP_CommonTalent_C:GetRealViewportSize(...)
  return UE.UWidgetLayoutLibrary.GetViewportSize(self) / UE.UWidgetLayoutLibrary.GetViewportScale(self)
end

function WBP_CommonTalent_C:ChangePreventMisContactImgDuringMovingPanelVis(IsShow)
  if IsShow then
    self.PreventMisContactImgDuringMovePanel:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self.PreventMisContactImgDuringMovePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_CommonTalent_C:RefreshAccumulativeCostIcon()
  local FirstAccumulativeCostTalentId
  local LobbySettings = UE.URGLobbySettings.GetLobbySettings()
  local AccumulativeCostLists = LobbySettings.AllCommonTalentList:Find(UE.ETalentItemType.AccumulativeCost)
  if not AccumulativeCostLists then
    return
  end
  if AccumulativeCostLists.TalentList:IsValidIndex(1) then
    FirstAccumulativeCostTalentId = AccumulativeCostLists.TalentList:Get(1)
  end
  if not FirstAccumulativeCostTalentId then
    print("WBP_CommonTalent_C:RefreshAccumulativeCostIcon not found FirstAccumulativeCostTalentId")
    return
  end
  local TalentGroupInfo = LogicTalent.GetTalentTableRow(FirstAccumulativeCostTalentId)
  if not TalentGroupInfo then
    print("WBP_CommonTalent_C:RefreshAccumulativeCostIcon not found talentInfo, talentId:", FirstAccumulativeCostTalentId)
    return
  end
  local FirstTalentInfo = TalentGroupInfo[1]
  local GeneralTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local ResourceRow = GeneralTable[FirstTalentInfo.ArrCost[1].key]
  if ResourceRow then
    SetImageBrushByPath(self.Img_AccumulativeCostIcon, ResourceRow.Icon)
  end
end

function WBP_CommonTalent_C:RefreshItemStatus()
  self.SaveTipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.IsShowTip = false
  LogicTalent.ResetPreCommonTalentLevelList()
  LogicTalent.ResetPreRemainCostList()
  for TalentId, TalentItem in pairs(self.AllTalentItems) do
    TalentItem:RefreshStatus()
  end
end

function WBP_CommonTalent_C:RefreshPreAccumulativeCostNum()
  local PreCostNum = LogicTalent.GetPreCostNum(self.AccumulativeCostId)
  if 0 == PreCostNum then
    if not self:IsAnimationPlaying(self.Ani_put) then
      self.Txt_PreAccumulativeCostNum:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  else
    self.Txt_PreAccumulativeCostNum:SetText(string.format("+%d", PreCostNum))
    self.Txt_PreAccumulativeCostNum:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Ani_put_in)
  end
  self:PlayCanClickUpgradeAnim(0 ~= PreCostNum)
end

function WBP_CommonTalent_C:PlayCanClickUpgradeAnim(IsCan)
  if self.IsInCanClickUpgradeAnim == IsCan then
    return
  end
  self.IsInCanClickUpgradeAnim = IsCan
  if IsCan then
    if self:IsAnimationPlaying(self.Ani_xieru_out) then
      self:StopAnimation(self.Ani_xieru_out)
    end
    if not self:IsAnimationPlaying(self.Ani_xieru_in) then
      self:PlayAnimationForward(self.Ani_xieru_in)
    end
  else
    if self:IsAnimationPlaying(self.Ani_xieru_in) then
      self:StopAnimation(self.Ani_xieru_in)
    end
    if not self:IsAnimationPlaying(self.Ani_xieru_out) and not self:IsAnimationPlaying(self.Ani_xieru_click) then
      self:PlayAnimationForward(self.Ani_xieru_out)
    end
  end
end

function WBP_CommonTalent_C:RefreshAccumulativeCostNum()
  self.Txt_AccumulativeCostNum:SetText(DataMgr.GetCommonTalentsAccumulativeCostById(self.AccumulativeCostId))
end

function WBP_CommonTalent_C:BindOnUpdateCommonTalentPresetCost()
  self:RefreshPreAccumulativeCostNum()
end

function WBP_CommonTalent_C:BindOnUpdateCommonTalentInfo()
  self:RefreshAccumulativeCostNum()
end

function WBP_CommonTalent_C:BindOnConfirmButtonClicked()
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("WriteNode")
  end
  local PreCommonTalentList = LogicTalent.GetPreCommonTalentLevelList()
  local Params = {}
  for TalentId, TalentLevel in pairs(PreCommonTalentList) do
    local RealLevel = DataMgr.GetCommonTalentLevelById(TalentId)
    if TalentLevel > RealLevel then
      Params[TalentId] = TalentLevel
    end
  end
  local HeroTalentList = {}
  for GroupId, Level in pairs(Params) do
    local TempList = {}
    self:GetHeroTalentPre(GroupId, TempList)
    for i, SingleId in ipairs(TempList) do
      if not table.Contain(HeroTalentList, SingleId) and Params[SingleId] then
        table.insert(HeroTalentList, SingleId)
      end
    end
  end
  local TempParams = {}
  for i, TalentId in ipairs(HeroTalentList) do
    local TempTable = {}
    TempTable.groupId = TalentId
    TempTable.level = Params[TalentId]
    table.insert(TempParams, TempTable)
  end
  local FinalParams = {}
  FinalParams.Talents = TempParams
  if table.count(TempParams) > 0 then
    LogicTalent.RequestUpgradeCommonTalentToServer(FinalParams)
    self:PlayAnimationForward(self.Ani_xieru_click)
    self:PlayAnimation(self.Ani_put)
    PlaySound2DEffect(15, "")
    print("WBP_CommonTalent_C:BindOnConfirmButtonClicked CurResourceNum", LogicOutsidePackback.GetResourceNumById(99994))
  end
  LogicTalent.ResetPreCommonTalentLevelList()
  LogicTalent.ResetPreRemainCostList()
  if LogicSettlement then
    LogicSettlement:HideSettlement()
  end
end

function WBP_CommonTalent_C:GetHeroTalentPre(TalentId, HeroTalentList)
  local TalentInfo = LogicTalent.GetTalentTableRow(TalentId)
  if TalentInfo and TalentInfo[1] then
    table.insert(HeroTalentList, 1, TalentId)
    for i, SingleFrontGroupId in ipairs(TalentInfo[1].FrontGroupsId) do
      self:GetHeroTalentPre(SingleFrontGroupId, HeroTalentList)
    end
    return
  end
  return
end

function WBP_CommonTalent_C:BindOnTipConfirmButtonClicked()
  self:BindOnConfirmButtonClicked()
  self:PlayAnimOutAnimation()
  self.SaveTipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_CommonTalent_C:BindOnTipCancelButtonClicked()
  self.SaveTipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  LogicTalent.ResetPreCommonTalentLevelList()
  LogicTalent.ResetPreRemainCostList()
  self:PlayAnimOutAnimation()
  if LogicSettlement then
    LogicSettlement:HideSettlement()
  end
end

function WBP_CommonTalent_C:PlayAnimOutAnimation()
  self.IsInitiativeStop = true
  self:PlayAnimation(self.Ani_out, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, true)
end

function WBP_CommonTalent_C:OnAnimationFinished(InAnimation)
  if not self.IsInitiativeStop then
    return
  end
  if InAnimation == self.Ani_out then
    if LogicLobby.GetPendingSelectedLabelTagName() then
      EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LogicLobby.GetPendingSelectedLabelTagName())
    end
    if LogicSettlement then
      LogicSettlement:HideSettlement()
    end
  end
end

function WBP_CommonTalent_C:CanDirectSwitch()
  local PreCommonTalentList = LogicTalent.GetPreCommonTalentLevelList()
  local Params = {}
  for TalentId, TalentLevel in pairs(PreCommonTalentList) do
    local RealLevel = DataMgr.GetCommonTalentLevelById(TalentId)
    if TalentLevel > RealLevel then
      Params[TalentId] = TalentLevel
    end
  end
  local HeroTalentList = {}
  for GroupId, Level in pairs(Params) do
    local TempList = {}
    self:GetHeroTalentPre(GroupId, TempList)
    for i, SingleId in ipairs(TempList) do
      if not table.Contain(HeroTalentList, SingleId) and Params[SingleId] then
        table.insert(HeroTalentList, SingleId)
      end
    end
  end
  local TempConfirmParams = {}
  for i, TalentId in ipairs(HeroTalentList) do
    local TempTable = {}
    TempTable.groupId = TalentId
    TempTable.level = Params[TalentId]
    table.insert(TempConfirmParams, TempTable)
  end
  if table.count(TempConfirmParams) > 0 then
    self.SaveTipPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    return false
  else
    self:PlayAnimOutAnimation()
    if self:IsAnimationPlaying(self.Ani_out) then
      return false
    end
    return true
  end
end

function WBP_CommonTalent_C:CanDirectExit()
  local PreCommonTalentList = LogicTalent.GetPreCommonTalentLevelList()
  local Params = {}
  for TalentId, TalentLevel in pairs(PreCommonTalentList) do
    local RealLevel = DataMgr.GetCommonTalentLevelById(TalentId)
    if TalentLevel > RealLevel then
      Params[TalentId] = TalentLevel
    end
  end
  local HeroTalentList = {}
  for GroupId, Level in pairs(Params) do
    local TempList = {}
    self:GetHeroTalentPre(GroupId, TempList)
    for i, SingleId in ipairs(TempList) do
      if not table.Contain(HeroTalentList, SingleId) and Params[SingleId] then
        table.insert(HeroTalentList, SingleId)
      end
    end
  end
  local TempConfirmParams = {}
  for i, TalentId in ipairs(HeroTalentList) do
    local TempTable = {}
    TempTable.groupId = TalentId
    TempTable.level = Params[TalentId]
    table.insert(TempConfirmParams, TempTable)
  end
  if table.count(TempConfirmParams) > 0 then
    self.SaveTipPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    return false
  else
    return true
  end
end

function WBP_CommonTalent_C:Hide()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateCommonTalentPresetCost, self.BindOnUpdateCommonTalentPresetCost, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateCommonTalentInfo, self.BindOnUpdateCommonTalentInfo, self)
  local AllChildren = self.CanvasPanel_TalentLine:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  for i = 1, self.LiveItemPanel:GetChildrenCount() do
    local item = self.LiveItemPanel:GetChildAt(i - 1)
    if item and item.HideTalentView then
      item:HideTalentView()
    end
  end
  for i = 1, self.AttackItemPanel:GetChildrenCount() do
    local item = self.AttackItemPanel:GetChildAt(i - 1)
    if item and item.HideTalentView then
      item:HideTalentView()
    end
  end
  for i = 1, self.LiveItemPanel:GetChildrenCount() do
    local item = self.LiveItemPanel:GetChildAt(i - 1)
    if item and item.HideTalentView then
      item:HideTalentView()
    end
  end
end

function WBP_CommonTalent_C:Destruct()
end

return WBP_CommonTalent_C
