require("Rouge.UI.Battle.Logic.Logic_Scroll")
local OrderedMap = require("Framework.DataStruct.OrderedMap")
local WBP_SettlementPlayerInfoView_C = UnLua.Class()
local FinisCountDown = 9
local MinGenericShowNum = 20
local EscActionName = "PauseGame"
local MainPanelLeftSwitchName = "MainPanelLeftSwitch"
local MainPanelRightSwitchName = "MainPanelRightSwitch"
function WBP_SettlementPlayerInfoView_C:Construct()
  self.RGToggleGroupPlayerInfoTitle.OnCheckStateChanged:Add(self, self.OnPlayerInfoTitleChanged)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Add(self, self.ListenForEscInputAction)
  self.WBP_CommonButton_Save.OnMainButtonClicked:Add(self, self.OnOpenSaveGrowthSnap)
end
function WBP_SettlementPlayerInfoView_C:InitSettlemntPlayerInfo(SelectPlayerId)
  UpdateVisibility(self, true)
  self:PlayAnimation(self.Ani_in)
  if not IsListeningForInputAction(self, EscActionName) then
    ListenForInputAction(EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_SettlementPlayerInfoView_C.ListenForEscInputAction
    })
  end
  if not IsListeningForInputAction(self, MainPanelLeftSwitchName) then
    ListenForInputAction(MainPanelLeftSwitchName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_SettlementPlayerInfoView_C.ListenForLeftInputAction
    })
  end
  if not IsListeningForInputAction(self, MainPanelRightSwitchName) then
    ListenForInputAction(MainPanelRightSwitchName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_SettlementPlayerInfoView_C.ListenForRightInputAction
    })
  end
  self.SelectPlayerId = SelectPlayerId
  self:InitTitle()
  self:UpdateGenericList()
  self:UpdateScrollList()
  self:UpdateScrollSetList()
  self:UpdateWorldList()
  self:UpdateModel()
  self:UpdateView()
  print("WBP_SettlementPlayerInfoView_C:InitSettlemntPlayerInfo", SelectPlayerId)
  self:UpdateIncomeInfo()
end
function WBP_SettlementPlayerInfoView_C:InitTitle()
  local playerList = LogicSettlement:GetOrInitPlayerList()
  self.RGToggleGroupPlayerInfoTitle:ClearGroup()
  print(" WBP_SettlementPlayerInfoView_C:InitTitle111", #playerList)
  for i, v in ipairs(playerList) do
    local item = GetOrCreateItem(self.HorizontalBoxPlayerInfoTitle, i, self.WBP_SettlementPlayerInfoTitle:GetClass())
    item:InitSettlementPlayerInfoTitle(v, self.SelectPlayerId, self.bIsFromBattleHistory)
    print(" WBP_SettlementPlayerInfoView_C:InitTitle", v.name, v.roleid)
    self.RGToggleGroupPlayerInfoTitle:AddToGroup(v.roleid, item)
  end
  HideOtherItem(self.HorizontalBoxPlayerInfoTitle, #playerList + 1)
  if self.SelectPlayerId and self.SelectPlayerId > 0 then
    print("WBP_SettlementPlayerInfoView_C:InitTitle SelectId", self.SelectPlayerId)
    self.RGToggleGroupPlayerInfoTitle:SelectId(self.SelectPlayerId)
  end
  UpdateVisibility(self.CanvasPanelLeft, #playerList > 1)
  UpdateVisibility(self.CanvasPanelRight, #playerList > 1)
end
function WBP_SettlementPlayerInfoView_C:ListenForEscInputAction()
  if self:IsAnimationPlaying(self.Ani_out) then
    return
  end
  self:StopAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_out)
end
function WBP_SettlementPlayerInfoView_C:OnOpenSaveGrowthSnap()
  if LogicSettlement:GetClearanceStatus() ~= SettlementStatus.Finish then
    ShowWaveWindow(1405)
    return
  end
  local settlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
  if LogicSettlement:GetClearanceDifficulty() < settlementView.ShowSaveGrowthDiffcult then
    ShowWaveWindow(1412, {
      settlementView.ShowSaveGrowthDiffcult
    })
    return
  end
  local settlementView = RGUIMgr:GetUI(UIConfig.WBP_SettlementView_C.UIName)
  if UE.RGUtil.IsUObjectValid(settlementView) then
    settlementView:OpenSaveGrowthSnap()
  end
end
function WBP_SettlementPlayerInfoView_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    if IsListeningForInputAction(self, EscActionName) then
      StopListeningForInputAction(self, EscActionName, UE.EInputEvent.IE_Pressed)
    end
    if IsListeningForInputAction(self, MainPanelLeftSwitchName) then
      StopListeningForInputAction(self, MainPanelLeftSwitchName, UE.EInputEvent.IE_Pressed)
    end
    if IsListeningForInputAction(self, MainPanelRightSwitchName) then
      StopListeningForInputAction(self, MainPanelRightSwitchName, UE.EInputEvent.IE_Pressed)
    end
    UpdateVisibility(self, false)
  end
end
function WBP_SettlementPlayerInfoView_C:ListenForLeftInputAction()
  local leftRoleId = -1
  local preRoleId = -1
  if self.bIsFromBattleHistory then
    local userIdList = {}
    for i, v in ipairs(self.HistoryData) do
      table.insert(userIdList, tonumber(v.roleID))
      if self.SelectPlayerId == tonumber(v.roleID) then
        leftRoleId = preRoleId
        break
      end
      preRoleId = tonumber(v.roleID)
    end
  else
    local playerList = LogicSettlement:GetOrInitPlayerList()
    for i, v in ipairs(playerList) do
      if self.SelectPlayerId == v.roleid then
        leftRoleId = preRoleId
        break
      end
      preRoleId = playerList[i].roleid
    end
  end
  if leftRoleId > 0 then
    local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
    if UserClickStatisticsMgr and not self.bIsFromBattleHistory then
      UserClickStatisticsMgr:AddClickStatistics("SelectTeammates")
      print("WBP_SettlementPlayerInfoView_C:ListenForLeftInputAction SelectTeammates")
    end
    self.RGToggleGroupPlayerInfoTitle:SelectId(leftRoleId)
  end
end
function WBP_SettlementPlayerInfoView_C:ListenForRightInputAction()
  local rightRoleId = -1
  local preRoleId = -1
  if self.bIsFromBattleHistory then
    local userIdList = {}
    for i = #self.HistoryData, 1, -1 do
      local v = self.HistoryData[i]
      table.insert(userIdList, tonumber(v.roleID))
      if self.SelectPlayerId == tonumber(v.roleID) then
        rightRoleId = preRoleId
        break
      end
      preRoleId = tonumber(v.roleID)
    end
  else
    local playerList = LogicSettlement:GetOrInitPlayerList()
    for i = #playerList, 1, -1 do
      if self.SelectPlayerId == playerList[i].roleid then
        rightRoleId = preRoleId
        break
      end
      preRoleId = playerList[i].roleid
    end
  end
  if rightRoleId > 0 then
    local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
    if UserClickStatisticsMgr and not self.bIsFromBattleHistory then
      UserClickStatisticsMgr:AddClickStatistics("SelectTeammates")
      print("WBP_SettlementPlayerInfoView_C:ListenForRightInputAction SelectTeammates")
    end
    self.RGToggleGroupPlayerInfoTitle:SelectId(rightRoleId)
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateModel()
  local Difficulty = LogicSettlement:GetClearanceDifficulty()
  self.RGTextDiffculty:SetText(Difficulty)
  local gameMode = LogicSettlement:GetGameMode()
  local result, row = GetRowData(DT.DT_GameMode, tostring(gameMode))
  if result then
    self.RGTextWorld:SetText(row.Name)
    self.RGTextWorld_1:SetText(row.Name)
    self.RGTextWorld_2:SetText(row.Name)
  end
  local Duration = math.floor(LogicSettlement:GetClearanceDuration())
  local Hour = math.floor(Duration / 3600)
  local Min = math.floor((Duration - Hour * 3600) / 60)
  local Sec = Duration - Hour * 3600 - Min * 60
  local TimeStr = string.format("%02d:%02d:%02d", Hour, Min, Sec)
  self.RGTextTime:SetText(TimeStr)
end
function WBP_SettlementPlayerInfoView_C:UpdateGenericList()
  local passiveModifyAry = LogicSettlement:GetPassiveModifyAryByPlayerId(self.SelectPlayerId)
  local index = 1
  for i, v in ipairs(passiveModifyAry) do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    item:InitBagRoleGenericItem(v, -1, self.UpdateGenericModifyTipsFunc, self)
    index = index + 1
  end
  local activatedModifies = LogicSettlement:GetActivatedModifiesByPlayerId(self.SelectPlayerId)
  for i, v in ipairs(activatedModifies) do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    item:InitSpecificModifyItem(v, -1, self.UpdateGenericModifyTipsFunc, self)
    index = index + 1
  end
  for i = index, MinGenericShowNum do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    item:InitBagRoleGenericItem(nil, UE.ERGGenericModifySlot.None)
    index = index + 1
  end
  HideOtherItem(self.WrapBoxGenericModify, index)
  for i, v in iterator(self.SlotList) do
    local RGGenericModifyData = LogicSettlement:GetGenericModifyBySlotByPlayerId(self.SelectPlayerId, v)
    local GenericModifyItem = GetOrCreateItem(self.CanvasPanelSlotModifyList, v, self.WBP_BagRoleGenericItem_SettlementSlot:GetClass())
    if RGGenericModifyData and RGGenericModifyData.ModifyId > 0 then
      GenericModifyItem:InitBagRoleGenericItem(RGGenericModifyData, v, self.UpdateGenericModifyTipsFunc, self)
    else
      GenericModifyItem:InitBagRoleGenericItem(nil, v, self.UpdateGenericModifyTipsFunc, self)
    end
  end
  HideOtherItem(self.CanvasPanelSlotModifyList, self.SlotList:Num() + 1)
end
function WBP_SettlementPlayerInfoView_C:UpdateScrollList()
  for i = 1, Logic_Scroll.MaxScrollNum do
    local v
    local scrollList = LogicSettlement:GetScrollListByPlayerId(self.SelectPlayerId)
    if scrollList and scrollList[i] then
      v = scrollList[i]
    end
    local item = GetOrCreateItem(self.WrapBoxScrollList, i, self.WBP_ScrollItemSlot_Settlement:GetClass())
    item:UpdateScrollData(v, self.UpdateShowPickupTipsView, self, i, EScrollTipsOpenType.EFromScrollSlotSettlement)
  end
  HideOtherItem(self.WrapBoxScrollList, Logic_Scroll.MaxScrollNum + 1)
end
function WBP_SettlementPlayerInfoView_C:UpdateScrollSetList()
  local scrollSetList = LogicSettlement:GetScrollSetListByPlayerId(self.SelectPlayerId)
  for i, v in ipairs(scrollSetList) do
    local item = GetOrCreateItem(self.WrapBoxScrollSetList, i, self.WBP_SettlementScrollSetItem:GetClass())
    item:InitScrollSetItem(v, self.UpdateScrollSetTips, self, i)
  end
  HideOtherItem(self.WrapBoxScrollSetList, #scrollSetList + 1)
end
function WBP_SettlementPlayerInfoView_C:UpdateWorldList()
  if LogicSettlement:GetGameModeType() == UE.EGameModeType.TowerClimb or LogicSettlement:GetGameModeType() == UE.EGameModeType.Survivor or LogicSettlement:GetGameModeType() == UE.EGameModeType.BossRush then
    UpdateVisibility(self.ScrollBoxWorldList, false)
  else
    UpdateVisibility(self.ScrollBoxWorldList, true)
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
    local WorldList = LogicSettlement:GetWorldList()
    if DTSubsystem and WorldList then
      local Count = 1
      for iWorld, vWorld in ipairs(WorldList) do
        local WorldItem = GetOrCreateItem(self.ScrollBoxWorldList, Count, self.WBP_SettlementWorldItem:GetClass())
        local ResultWorld, World = DTSubsystem:GetWorldTableRow(vWorld.PassInfo.WorldId)
        if ResultWorld then
          local WorldInfo = {
            bIsFinish = vWorld.bPass,
            WorldIcon = World.WorldIcon,
            Name = World.WorldName,
            bIsFirst = 1 == iWorld,
            WorldBg = World.WorldBg,
            bUnKnow = vWorld.bUnKnow
          }
          WorldItem:Init(WorldInfo)
          Count = Count + 1
        end
      end
      HideOtherItem(self.ScrollBoxWorldList, Count)
    end
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot, item)
  if bIsShow then
    if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
      self.WBP_GenericModifyBagTips:InitGenericModifyTipsBySettlement(Data, Slot)
    elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
      self.WBP_GenericModifyBagTips:InitSpecificModifyTips(Data.ModifyId, false)
    end
    ShowCommonTips(nil, item, self.WBP_GenericModifyBagTips)
  else
    self.WBP_GenericModifyBagTips:Hide()
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateShowPickupTipsView(bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  print("WBP_SettlementPlayerInfoView_C:UpdateShowPickupTipsView", bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  if ScrollId and ScrollId > 0 then
    self.WBP_ScrollPickUpTipsView:InitScrollTipsView(ScrollId, ScrollTipsOpenType, TargetItem, bIsNeedInit, self.SelectPlayerId)
    self.WBP_ScrollPickUpTipsView:Show(true)
    ShowCommonTips(nil, TargetItem, self.WBP_ScrollPickUpTipsView)
  else
    UpdateVisibility(self.WBP_ScrollPickUpTipsView, false)
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateScrollSetTips(bIsShow, ActivatedSetData, ScrollSetItem)
  UpdateVisibility(self.WBP_ScrollSetTips, bIsShow)
  if bIsShow then
    self.WBP_ScrollSetTips:InitScrollSetTips(ActivatedSetData)
    local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_LobbyWeaponDisplayInfo)
    if TipsCanvasSlot then
      local GeometryScrollSetItem = ScrollSetItem:GetCachedGeometry()
      local GeometryCanvasPanelScroll = self.CanvasPanelScroll:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelScroll, GeometryScrollSetItem)
      TipsCanvasSlot:SetPosition(UE.FVector2D(TipsCanvasSlot:GetPosition().X, Pos.Y))
    end
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateView()
  local Diff = LogicSettlement:GetClearanceDifficulty()
  self.RGTextDiffculty:SetText(Diff)
  local Duration = math.floor(LogicSettlement:GetClearanceDuration())
  local Hour = math.floor(Duration / 3600)
  local Min = math.floor((Duration - Hour * 3600) / 60)
  local Sec = Duration - Hour * 3600 - Min * 60
  local TimeStr = string.format("%02d:%02d:%02d", Hour, Min, Sec)
  self.RGTextTime:SetText(TimeStr)
end
function WBP_SettlementPlayerInfoView_C:Destruct()
  self.RGToggleGroupPlayerInfoTitle.OnCheckStateChanged:Remove(self, self.OnPlayerInfoTitleChanged)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Remove(self, self.ListenForEscInputAction)
  self.WBP_CommonButton_Save.OnMainButtonClicked:Remove(self, self.OnOpenSaveGrowthSnap)
end
function WBP_SettlementPlayerInfoView_C:InitBattleHistoryPlayerInfo(SelectPlayerId, HistoryData)
  UpdateVisibility(self, true)
  self.bIsFromBattleHistory = true
  self.HistoryData = HistoryData
  self:PlayAnimation(self.Ani_in)
  if not IsListeningForInputAction(self, EscActionName) then
    ListenForInputAction(EscActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_SettlementPlayerInfoView_C.ListenForEscInputAction
    })
  end
  if not IsListeningForInputAction(self, MainPanelLeftSwitchName) then
    ListenForInputAction(MainPanelLeftSwitchName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_SettlementPlayerInfoView_C.ListenForLeftInputAction
    })
  end
  if not IsListeningForInputAction(self, MainPanelRightSwitchName) then
    ListenForInputAction(MainPanelRightSwitchName, UE.EInputEvent.IE_Pressed, true, {
      self,
      WBP_SettlementPlayerInfoView_C.ListenForRightInputAction
    })
  end
  self.SelectPlayerId = tonumber(SelectPlayerId)
  self:InitBattleHistoryTitle()
  local historyData = self:GetHistoryDataByRoleId(self.SelectPlayerId)
  if not historyData then
    return
  end
  self:UpdateBattleHistoryGenericList(historyData)
  self:UpdateBattleHistoryScrollList(historyData)
  self:UpdateBattleHistoryScrollSetList(historyData)
  self:UpdateBattleHistoryWorldList(historyData)
  self:UpdateBattleHistoryModel(historyData)
  self:UpdateBattleHistoryView(historyData)
  UpdateVisibility(self.CanvasPanelBattleHistory, true)
  UpdateVisibility(self.RGTextCoin, false)
  UpdateVisibility(self.URGImageCoinIcon, false)
  UpdateVisibility(self.RGTextCoinNum, false)
  print("WBP_SettlementPlayerInfoView_C:InitBattleHistoryPlayerInfo", SelectPlayerId)
  self:PushInputAction()
end
function WBP_SettlementPlayerInfoView_C:InitBattleHistoryTitle()
  local userIdList = {}
  for i, v in ipairs(self.HistoryData) do
    table.insert(userIdList, tonumber(v.roleID))
  end
  DataMgr.GetOrQueryPlayerInfo(userIdList, false, function()
    local playerList = {}
    for i, v in ipairs(self.HistoryData) do
      table.insert(playerList, {
        name = DataMgr.GetPlayerNickNameById(tonumber(v.roleID)),
        roleid = tonumber(v.roleID)
      })
    end
    self.RGToggleGroupPlayerInfoTitle:ClearGroup()
    print(" WBP_SettlementPlayerInfoView_C:InitTitle111", #playerList)
    for i, v in ipairs(playerList) do
      local item = GetOrCreateItem(self.HorizontalBoxPlayerInfoTitle, i, self.WBP_SettlementPlayerInfoTitle:GetClass())
      item:InitSettlementPlayerInfoTitle(v, self.SelectPlayerId, self.bIsFromBattleHistory)
      print(" WBP_SettlementPlayerInfoView_C:InitTitle", v.name, v.roleid)
      self.RGToggleGroupPlayerInfoTitle:AddToGroup(v.roleid, item)
    end
    HideOtherItem(self.HorizontalBoxPlayerInfoTitle, #playerList + 1)
    if self.SelectPlayerId and self.SelectPlayerId > 0 then
      print("WBP_SettlementPlayerInfoView_C:InitTitle SelectId", self.SelectPlayerId)
      self.RGToggleGroupPlayerInfoTitle:SelectId(self.SelectPlayerId)
    end
    UpdateVisibility(self.CanvasPanelLeft, #playerList > 1)
    UpdateVisibility(self.CanvasPanelRight, #playerList > 1)
  end)
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryModel(historyData)
  local Difficulty = historyData.hard
  self.RGTextDiffculty:SetText(Difficulty)
  local worldID = historyData.worldID
  local result, row = GetRowData(DT.DT_GameMode, tostring(worldID))
  if result then
    self.RGTextWorld:SetText(row.Name)
    self.RGTextWorld_1:SetText(row.Name)
    self.RGTextWorld_2:SetText(row.Name)
  end
  local Duration = tonumber(historyData.duration) or 0
  Duration = math.floor(tonumber(historyData.duration))
  local Hour = math.floor(Duration / 3600)
  local Min = math.floor((Duration - Hour * 3600) / 60)
  local Sec = Duration - Hour * 3600 - Min * 60
  local TimeStr = string.format("%02d:%02d:%02d", Hour, Min, Sec)
  self.RGTextTime:SetText(TimeStr)
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryGenericList(historyData)
  local passiveModifyAry = {}
  local slotModifyMap = {}
  for i, v in ipairs(historyData.Attributes) do
    local id = v
    if type(v) ~= "number" then
      id = v.ID
    end
    local resultGeneric, rowGeneric = GetRowData(DT.DT_GenericModify, tostring(id))
    if resultGeneric then
      if rowGeneric.Slot == UE.ERGGenericModifySlot.None then
        local genericModify = UE.FRGGenericModify()
        if type(v) == "number" then
          genericModify.ModifyId = v
          genericModify.Level = 1
        else
          genericModify.ModifyId = v.ID
          genericModify.Level = v.Level
        end
        table.insert(passiveModifyAry, genericModify)
      else
        local genericModify = UE.FRGGenericModify()
        if type(v) == "number" then
          genericModify.ModifyId = v
          genericModify.Level = 1
        else
          genericModify.ModifyId = v.ID
          genericModify.Level = v.Level
        end
        slotModifyMap[rowGeneric.Slot] = genericModify
      end
    end
  end
  local index = 1
  for i, v in ipairs(passiveModifyAry) do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    item:InitBagRoleGenericItem(v, -1, self.UpdateGenericModifyTipsFunc, self)
    index = index + 1
  end
  for i, v in ipairs(historyData.SpecificModifyList) do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    local specificModifyData = UE.FRGSpecificModify()
    specificModifyData.ModifyId = v
    item:InitSpecificModifyItem(specificModifyData, -1, self.UpdateGenericModifyTipsFunc, self)
    index = index + 1
  end
  for i = index, MinGenericShowNum do
    local item = GetOrCreateItem(self.WrapBoxGenericModify, index, self.WBP_BagRoleGenericItem_Settlement:GetClass())
    item:InitBagRoleGenericItem(nil, UE.ERGGenericModifySlot.None)
    index = index + 1
  end
  HideOtherItem(self.WrapBoxGenericModify, index)
  for i, v in iterator(self.SlotList) do
    local RGGenericModifyData = slotModifyMap[v]
    local GenericModifyItem = GetOrCreateItem(self.CanvasPanelSlotModifyList, v, self.WBP_BagRoleGenericItem_SettlementSlot:GetClass())
    if RGGenericModifyData and RGGenericModifyData.ModifyId > 0 then
      GenericModifyItem:InitBagRoleGenericItem(RGGenericModifyData, v, self.UpdateGenericModifyTipsFunc, self)
    else
      GenericModifyItem:InitBagRoleGenericItem(nil, v, self.UpdateGenericModifyTipsFunc, self)
    end
  end
  HideOtherItem(self.CanvasPanelSlotModifyList, self.SlotList:Num() + 1)
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryScrollList(historyData)
  for i = 1, Logic_Scroll.MaxScrollNum do
    local v = historyData.Collections[i]
    local item = GetOrCreateItem(self.WrapBoxScrollList, i, self.WBP_ScrollItemSlot_Settlement:GetClass())
    item:UpdateScrollData(v, self.UpdateShowPickupTipsView, self, i, EScrollTipsOpenType.EFromScrollSlotSettlement)
  end
  HideOtherItem(self.WrapBoxScrollList, Logic_Scroll.MaxScrollNum + 1)
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryScrollSetList(historyData)
  local setIdToNum = OrderedMap.New()
  for i, v in ipairs(historyData.Collections) do
    local resultScroll, rowScroll = GetRowData(DT.DT_AttributeModify, tostring(v))
    if resultScroll then
      for iSet, vSet in iterator(rowScroll.SetArray) do
        if setIdToNum[vSet] then
          setIdToNum[vSet] = setIdToNum[vSet] + 1
        else
          setIdToNum[vSet] = 1
        end
      end
    end
  end
  local idx = 1
  for k, v in pairs(setIdToNum) do
    local resultSet, rowSet = GetRowData(DT.DT_AttributeModifySet, tostring(v))
    if resultSet then
      local setData = {
        Level = v,
        SetId = tonumber(k)
      }
      local item = GetOrCreateItem(self.WrapBoxScrollSetList, idx, self.WBP_SettlementScrollSetItem:GetClass())
      item:InitScrollSetItem(setData, self.UpdateScrollSetTips, self)
      idx = idx + 1
    end
  end
  HideOtherItem(self.WrapBoxScrollSetList, idx)
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryWorldList(historyData)
  local Count = 1
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem and historyData.AllThemes then
    local unFinishWorldCnt = 0
    for iWorld, vTheme in pairs(historyData.AllThemes) do
      local vWorld = historyData.PassThemes[tostring(vTheme)]
      if nil ~= vWorld then
        local WorldItem = GetOrCreateItem(self.ScrollBoxWorldList, Count, self.WBP_SettlementWorldItem:GetClass())
        local ResultWorld, World = DTSubsystem:GetWorldTableRow(tonumber(vTheme))
        if ResultWorld then
          if not vWorld then
            unFinishWorldCnt = unFinishWorldCnt + 1
          end
          local bUnKnowTemp = false
          if not vWorld and unFinishWorldCnt > 1 then
            bUnKnowTemp = true
          end
          local WorldInfo = {
            bIsFinish = vWorld,
            WorldIcon = World.WorldIcon,
            Name = World.WorldName,
            bIsFirst = false,
            WorldBg = World.WorldBg,
            bUnKnow = bUnKnowTemp
          }
          WorldItem:Init(WorldInfo)
          Count = Count + 1
        end
      end
    end
  end
  HideOtherItem(self.ScrollBoxWorldList, Count)
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot, item)
  if bIsShow then
    if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
      self.WBP_GenericModifyBagTips:InitGenericModifyTipsBySettlement(Data, Slot)
    elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
      self.WBP_GenericModifyBagTips:InitSpecificModifyTips(Data.ModifyId, false)
    end
    ShowCommonTips(nil, item, self.WBP_GenericModifyBagTips)
    UpdateVisibility(self.WBP_GenericModifyBagTips, true)
  else
    self.WBP_GenericModifyBagTips:Hide()
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryShowPickupTipsView(bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  print("WBP_SettlementPlayerInfoView_C:UpdateShowPickupTipsView", bIsShowTipsView, ScrollId, TargetItem, ScrollTipsOpenType, bIsNeedInit)
  if ScrollId and ScrollId > 0 then
    self.WBP_ScrollPickUpTipsView:InitScrollTipsView(ScrollId, ScrollTipsOpenType, TargetItem, bIsNeedInit, self.SelectPlayerId)
    self.WBP_ScrollPickUpTipsView:Show(true)
    ShowCommonTips(nil, TargetItem, self.WBP_ScrollPickUpTipsView)
  else
    UpdateVisibility(self.WBP_ScrollPickUpTipsView, false)
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryScrollSetTips(bIsShow, ActivatedSetData, ScrollSetItem)
  UpdateVisibility(self.WBP_ScrollSetTips, bIsShow)
  if bIsShow then
    self.WBP_ScrollSetTips:InitScrollSetTips(ActivatedSetData)
    local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_LobbyWeaponDisplayInfo)
    if TipsCanvasSlot then
      local GeometryScrollSetItem = ScrollSetItem:GetCachedGeometry()
      local GeometryCanvasPanelScroll = self.CanvasPanelScroll:GetCachedGeometry()
      local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelScroll, GeometryScrollSetItem)
      TipsCanvasSlot:SetPosition(UE.FVector2D(TipsCanvasSlot:GetPosition().X, Pos.Y))
    end
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateBattleHistoryView(HistoryData)
  local Diff = HistoryData.hard
  self.RGTextDiffculty:SetText(Diff)
  local Duration = math.floor(tonumber(HistoryData.duration))
  local Hour = math.floor(Duration / 3600)
  local Min = math.floor((Duration - Hour * 3600) / 60)
  local Sec = Duration - Hour * 3600 - Min * 60
  local TimeStr = string.format("%02d:%02d:%02d", Hour, Min, Sec)
  self.RGTextTime:SetText(TimeStr)
  self.RGTextDamageValue:SetText(math.floor(HistoryData.harm))
  self.RGTextKillsValue:SetText(HistoryData.kills)
end
function WBP_SettlementPlayerInfoView_C:OnPlayerInfoTitleChanged(PlayerId)
  print("WBP_SettlementPlayerInfoView_C:OnPlayerInfoTitleChanged", PlayerId)
  self.SelectPlayerId = PlayerId
  if self.bIsFromBattleHistory then
    local historyData = self:GetHistoryDataByRoleId(self.SelectPlayerId)
    if historyData then
      self:UpdateBattleHistoryGenericList(historyData)
      self:UpdateBattleHistoryScrollList(historyData)
      self:UpdateBattleHistoryScrollSetList(historyData)
      self:UpdateBattleHistoryWorldList(historyData)
      self:UpdateBattleHistoryModel(historyData)
      self:UpdateBattleHistoryView(historyData)
    end
    UpdateVisibility(self.Btn_SaveGrowthSnap, false)
    UpdateVisibility(self.WBP_SaveGrowth_AutoSave, false)
  else
    self:UpdateGenericList()
    self:UpdateScrollList()
    self:UpdateScrollSetList()
    self:UpdateWorldList()
    self:UpdateModel()
    self:UpdateView()
    self:UpdateIncomeInfo()
    local bIsSelf = tostring(PlayerId) == tostring(DataMgr:GetUserId())
    local gameModeType = LogicSettlement:GetGameModeType()
    local bIsClimbTown = gameModeType == UE.EGameModeType.TowerClimb
    print("WBP_SettlementPlayerInfoView_C:OnPlayerInfoTitleChanged Save", PlayerId, DataMgr:GetUserId(), bIsSelf, bIsClimbTown)
    local bShow = bIsSelf and LogicSettlement:CheckCanShowSaveGrowthBtn()
    UpdateVisibility(self.Btn_SaveGrowthSnap, bShow, true)
    UpdateVisibility(self.WBP_SaveGrowth_AutoSave, bShow)
  end
end
function WBP_SettlementPlayerInfoView_C:UpdateIncomeInfo()
  print("WBP_SettlementPlayerInfoView_C:UpdateIncomeInfo", self.SelectPlayerId)
  local gold_num = UE.URGBlueprintLibrary.GetStatisticData(self.SelectPlayerId, 30056)
  self.RGTextCoinNum:SetText(gold_num)
  local num_damage = UE.URGDamageReportSystem.GetDamageReport(self.SelectPlayerId).AllDamageValue
  self.RGTextDamageValue:SetText(num_damage)
  local num_kill = UE.URGDamageReportSystem.GetKillReport(self.SelectPlayerId).KillCount
  self.RGTextKillsValue:SetText(num_kill)
  UpdateVisibility(self.CanvasPanelBattleHistory, true)
end
function WBP_SettlementPlayerInfoView_C:GetHistoryDataByRoleId(RoleId)
  for i, v in ipairs(self.HistoryData) do
    if tonumber(v.roleID) == tonumber(RoleId) then
      return v
    end
  end
  return nil
end
return WBP_SettlementPlayerInfoView_C
