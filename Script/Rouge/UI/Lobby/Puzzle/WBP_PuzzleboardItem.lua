local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemHandler = require("Protocol.Gem.GemHandler")
local GemData = require("Modules.Gem.GemData")
local WBP_PuzzleboardItem = UnLua.Class()

function WBP_PuzzleboardItem:ShowBySpecifiedData(CoordinateQ, CoordinateR, SlotId, Status, PuzzlePackageInfo, PuzzleDetailInfo, AllSlotEquipList, GemPackageInfoList)
  UpdateVisibility(self, true)
  self.CoordinateQ = CoordinateQ
  self.CoordinateR = CoordinateR
  self.SlotId = SlotId
  self.SlotStatus = Status
  self.PuzzlePackageInfo = PuzzlePackageInfo
  self.PuzzleDetailInfo = PuzzleDetailInfo
  self.AllSlotEquipList = AllSlotEquipList
  self.GemPackageInfoList = GemPackageInfoList
  UpdateVisibility(self.Overlay_Debug, false)
  UpdateVisibility(self.Img_CanNotEquip, false)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  self:BindOnRefreshPuzzleboardItemStatus()
end

function WBP_PuzzleboardItem:Show(CoordinateQ, CoordinateR, SlotId)
  UpdateVisibility(self, true)
  self.CoordinateQ = CoordinateQ
  self.CoordinateR = CoordinateR
  self.SlotId = SlotId
  self.CanDrag = true
  UpdateVisibility(self.Overlay_Debug, self.IsShowDebugInfo)
  UpdateVisibility(self.Img_CanNotEquip, false)
  if self.IsShowDebugInfo then
    self.Txt_CoordinateQ:SetText(UE.UKismetMathLibrary.Round(CoordinateQ))
    self.Txt_CoordinateR:SetText(UE.UKismetMathLibrary.Round(CoordinateR))
    self.Txt_CoordinateS:SetText(UE.UKismetMathLibrary.Round(-CoordinateQ - CoordinateR))
    self.Txt_Index:SetText(self.SlotId)
  end
  EventSystem.AddListenerNew(EventDef.Puzzle.RefreshPuzzleboardItemStatus, self, self.BindOnRefreshPuzzleboardItemStatus)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnEquipPuzzleSuccess, self, self.BindOnEquipPuzzleSuccess)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzleSlotUnlockInfo, self, self.BindOnUpdatePuzzleSlotUnlockInfo)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemEquipSuccess, self, self.BindOnGemEquipSuccess)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemUnEquipSuccess, self, self.BindOnGemUnEquipSuccess)
  EventSystem.AddListenerNew(EventDef.Gem.OnRefreshGemStatus, self, self.BindOnRefreshGemStatus)
  EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemDrag, self, self.BindOnGemDrag)
  EventSystem.AddListenerNew(EventDef.Gem.OnGemDragCancel, self, self.BindOnGemDragCancel)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnWashPuzzleSlotAmountSuccess, self, self.BindOnWashPuzzleSlotAmountSuccess)
  self:BindOnRefreshPuzzleboardItemStatus()
  self.WBP_SingleHexItem:ChangeGemItemCanDragStatus(true)
end

function WBP_PuzzleboardItem:Hide(...)
  UpdateVisibility(self, false)
  self.WBP_SingleHexItem:StopAllAnimations()
  EventSystem.RemoveListenerNew(EventDef.Puzzle.RefreshPuzzleboardItemStatus, self, self.BindOnRefreshPuzzleboardItemStatus)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnEquipPuzzleSuccess, self, self.BindOnEquipPuzzleSuccess)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleSlotUnlockInfo, self, self.BindOnUpdatePuzzleSlotUnlockInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemEquipSuccess, self, self.BindOnGemEquipSuccess)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemUnEquipSuccess, self, self.BindOnGemUnEquipSuccess)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnRefreshGemStatus, self, self.BindOnRefreshGemStatus)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemItemHoverStatus, self, self.BindOnUpdateGemItemHoverStatus)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemDrag, self, self.BindOnGemDrag)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnGemDragCancel, self, self.BindOnGemDragCancel)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnWashPuzzleSlotAmountSuccess, self, self.BindOnWashPuzzleSlotAmountSuccess)
end

function WBP_PuzzleboardItem:BindOnRefreshPuzzleboardItemStatus()
  UpdateVisibility(self.WBP_SingleHexItem, false)
  local Status = self.SlotStatus
  Status = Status or PuzzleData:GetSlotStatus(self.SlotId)
  if not Status then
    print("WBP_PuzzleboardItem:BindOnRefreshPuzzleboardItemStatus Slot Status is nil !!!", self.SlotId)
    table.Print(PuzzleData.AllSlotStatus)
  end
  UpdateVisibility(self.Img_PendingEquip, Status == EPuzzleSlotStatus.PendingEquip)
  UpdateVisibility(self.Img_LockBottom, Status == EPuzzleSlotStatus.Lock, true, true)
  UpdateVisibility(self.Img_Main, Status ~= EPuzzleSlotStatus.Lock, true, true)
  UpdateVisibility(self.Img_CanNotEquip, Status == EPuzzleSlotStatus.PendingCanNotEquip)
  local RealStatus = self.SlotStatus
  RealStatus = RealStatus or PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
  if self.CurEquipPuzzleId and type(self.CurEquipPuzzleId) ~= "number" and RealStatus == EPuzzleSlotStatus.Empty then
    local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
    PuzzleViewModel:HidePuzzleHoverWidget()
  end
  self.CurEquipPuzzleId = RealStatus
  self.CurEquipGemId = nil
  self.CurSlotIndex = -1
  if type(Status) ~= "number" or type(RealStatus) ~= "number" and not PuzzleData:IsPendingDrag(self.SlotId) then
    UpdateVisibility(self.WBP_SingleHexItem, true)
    local SlotList
    if self.AllSlotEquipList then
      SlotList = self.AllSlotEquipList[Status]
    else
      SlotList = PuzzleData:GetSlotListByPuzzleId(RealStatus)
    end
    if not SlotList then
      print("WBP_PuzzleboardItem:BindOnRefreshPuzzleboardItemStatus SlotList is nil !!!")
      return
    end
    local CenterSlotId = SlotList[1]
    local Result, SlotRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSlots, CenterSlotId)
    local CenterOffsetX = 0 - SlotRowInfo.position.key
    local CenterOffsetY = 0 - SlotRowInfo.position.value
    local EquipSlotCoordinate = {
      [0] = {
        [0] = 1
      }
    }
    for i, SingleSlotId in ipairs(SlotList) do
      if SingleSlotId ~= CenterSlotId then
        local Result, SlotRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSlots, SingleSlotId)
        local Pos = SlotRowInfo.position
        if not EquipSlotCoordinate[Pos.key + CenterOffsetX] then
          EquipSlotCoordinate[Pos.key + CenterOffsetX] = {}
        end
        EquipSlotCoordinate[Pos.key + CenterOffsetX][Pos.value + CenterOffsetY] = 1
      end
      if SingleSlotId == self.SlotId then
        self.CurSlotIndex = i - 1
      end
    end
    self.WBP_SingleHexItem:Show(RealStatus, {
      key = self.CoordinateQ + CenterOffsetX,
      value = self.CoordinateR + CenterOffsetY
    }, EquipSlotCoordinate, self.PuzzlePackageInfo, self.CurSlotIndex, self.PuzzleDetailInfo, self.GemPackageInfoList)
    self.WBP_SingleHexItem:ShowOrHideEquipAnimImage(true)
    self.WBP_SingleHexItem:UpdateBoardEquipVis(true)
    self:RefreshGemStatus()
  end
end

function WBP_PuzzleboardItem:BindOnRefreshGemStatus()
  self:RefreshGemStatus()
end

function WBP_PuzzleboardItem:BindOnUpdateGemItemHoverStatus(IsHover, GemId)
  self.IsHoverGem = IsHover
  if not self.IsHoverGem and self.IsHover then
    local RealStatus = self.SlotStatus
    RealStatus = RealStatus or PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
    if type(RealStatus) ~= "number" and "0" ~= GemId then
      self:ShowOrHideHoverTip(true)
    end
  end
  if self.IsHoverGem then
    self:ShowOrHideHoverTip(false)
  end
end

function WBP_PuzzleboardItem:BindOnGemDrag(GemId)
  if self.CurEquipGemId and self.CurEquipGemId == "0" then
    self.WBP_SingleHexItem:ShowOrHideGemHoverAnim(true)
  end
end

function WBP_PuzzleboardItem:BindOnGemDragCancel(...)
  self.WBP_SingleHexItem:ShowOrHideGemHoverAnim(false)
end

function WBP_PuzzleboardItem:RefreshGemStatus()
  self.WBP_SingleHexItem:RefreshGemItemStatus(self.CurSlotIndex)
  local RealStatus = self.SlotStatus
  RealStatus = RealStatus or PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
  local DetailInfo = self.PuzzleDetailInfo
  DetailInfo = DetailInfo or PuzzleData:GetPuzzleDetailInfo(RealStatus)
  self.GemMainAttrList = {}
  local GemSlotInfo = DetailInfo and (DetailInfo.GemSlotInfo or DetailInfo.gemslotinfo) or {}
  for SlotIndex, GemId in pairs(GemSlotInfo) do
    local GemPackageInfo = self.GemPackageInfoList and self.GemPackageInfoList[GemId]
    GemPackageInfo = GemPackageInfo or GemData:GetGemPackageInfoByUId(GemId)
    if GemPackageInfo then
      for i, SingleAttrId in ipairs(GemPackageInfo.mainAttrIDs) do
        self.GemMainAttrList[SingleAttrId] = 1
      end
    end
  end
  local TargetGemId = GemSlotInfo[tostring(self.CurSlotIndex)] or nil
  self.CurEquipGemId = TargetGemId
end

function WBP_PuzzleboardItem:GetPuzzleEquipSlotList(PuzzleId)
  if self.AllSlotEquipList then
    return self.AllSlotEquipList[PuzzleId]
  else
    return PuzzleData:GetSlotListByPuzzleId(PuzzleId)
  end
end

function WBP_PuzzleboardItem:BindOnUpdatePuzzleItemHoverStatus(IsHover, PuzzleId, IsPuzzleBoard)
  if not IsPuzzleBoard then
    return
  end
  local EquipPuzzleId = self.SlotStatus
  EquipPuzzleId = EquipPuzzleId or PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
  if PuzzleId ~= EquipPuzzleId then
    return
  end
  local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self)
  if Slot then
    if IsHover then
      Slot:SetZOrder(1)
    else
      Slot:SetZOrder(0)
    end
  end
  self.WBP_SingleHexItem:UpdateSelectedVis(IsHover)
end

function WBP_PuzzleboardItem:BindOnEquipPuzzleSuccess(PuzzleId)
  local CurEquipPuzzleId = PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
  if CurEquipPuzzleId == PuzzleId then
    self.WBP_SingleHexItem:PlayEquipAnim()
  end
end

function WBP_PuzzleboardItem:BindOnUpdatePuzzleSlotUnlockInfo(...)
  self:BindOnRefreshPuzzleboardItemStatus()
end

function WBP_PuzzleboardItem:BindOnWashPuzzleSlotAmountSuccess(PuzzleIdList)
  local EquipPuzzleId = self.SlotStatus
  EquipPuzzleId = EquipPuzzleId or PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
  if not table.Contain(PuzzleIdList, EquipPuzzleId) then
    return
  end
  self:RefreshGemStatus()
end

function WBP_PuzzleboardItem:OnDragEnter(MyGeometry, PointerEvent, Operation)
  if Operation.IsGem then
    if not self.CurEquipGemId then
      print("WBP_PuzzleboardItem:OnDragEnter \230\178\161\230\156\137\229\174\157\231\159\179\230\167\189\228\189\141")
    else
      print("WBP_PuzzleboardItem:OnDragEnter \230\156\137\229\174\157\231\159\179\230\167\189\228\189\141", self.CurEquipGemId)
    end
  else
    EventSystem.Invoke(EventDef.Puzzle.OnPuzzleboardDragEnter, true, {
      key = self.CoordinateQ,
      value = self.CoordinateR
    }, Operation.DragCoordinate)
  end
end

function WBP_PuzzleboardItem:OnDragLeave(PointerEvent, Operation)
  if Operation.IsGem then
  else
    EventSystem.Invoke(EventDef.Puzzle.OnPuzzleboardDragEnter, false, {
      key = self.CoordinateQ,
      value = self.CoordinateR
    }, Operation.DragCoordinate)
  end
end

function WBP_PuzzleboardItem:OnDrop(MyGeometry, PointerEvent, Operation)
  if Operation.IsGem then
    if self.CurEquipGemId then
      local EquipGemId = Operation.GemId
      local EquipGemPackageInfo = GemData:GetGemPackageInfoByUId(EquipGemId)
      local RealStatus = self.SlotStatus
      RealStatus = RealStatus or PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
      local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(RealStatus)
      local IsEquip = false
      for SlotIndex, GemId in pairs(GemSlotInfo) do
        if GemId == EquipGemId then
          IsEquip = true
          break
        end
      end
      local IsContainAttr = false
      if not IsEquip then
        for i, SingleAttrId in ipairs(EquipGemPackageInfo.mainAttrIDs) do
          if self.GemMainAttrList[SingleAttrId] then
            if self.CurEquipGemId ~= "0" then
              local CurEquipGemPackageInfo = GemData:GetGemPackageInfoByUId(self.CurEquipGemId)
              if CurEquipGemPackageInfo and not table.Contain(CurEquipGemPackageInfo.mainAttrIDs, SingleAttrId) then
                IsContainAttr = true
                break
              end
            else
              IsContainAttr = true
              break
            end
          end
        end
      end
      if IsContainAttr then
        print("WBP_PuzzleboardItem:OnDrop \229\174\157\231\159\179\229\177\158\230\128\167\233\135\141\229\164\141")
        ShowWaveWindow(306006)
        return
      end
      local IsEquipInPuzzle = GemData:IsEquippedInPuzzle(EquipGemId)
      local EquippedPuzzleId = GemData:GetGemEquippedPuzzleId(EquipGemId)
      if IsEquipInPuzzle then
        local PuzzlePackageInfo = PuzzleData:GetPuzzlePackageInfo(EquippedPuzzleId)
        local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
        if PuzzlePackageInfo.equipHeroID ~= PuzzleViewModel:GetCurHeroId() then
          print("WBP_PuzzleboardItem:OnDrop \229\174\157\231\159\179\229\183\178\232\163\133\229\164\135\229\156\168\229\133\182\228\187\150\232\139\177\233\155\132\232\186\171\228\184\138")
          GemHandler:RequestEquipGemToServer(RealStatus, self.CurSlotIndex, Operation.GemId)
          return
        end
      end
      if self.CurEquipGemId == "0" then
        GemHandler:RequestEquipGemToServer(RealStatus, self.CurSlotIndex, Operation.GemId)
      else
        print("WBP_PuzzleboardItem:OnDrop \230\152\175\229\144\166\232\166\129\230\155\191\230\141\162")
        local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(RealStatus)
        local CurSlotIndex
        for SlotIndex, SingleGemId in pairs(GemSlotInfo) do
          if SingleGemId == Operation.GemId then
            CurSlotIndex = tonumber(SlotIndex)
            break
          end
        end
        if not (EquippedPuzzleId == RealStatus and CurSlotIndex) or CurSlotIndex ~= self.CurSlotIndex then
          GemHandler:RequestEquipGemToServer(RealStatus, self.CurSlotIndex, Operation.GemId)
        end
      end
    else
    end
    EventSystem.Invoke(EventDef.Gem.OnGemDragCancel)
  else
    EventSystem.Invoke(EventDef.Puzzle.OnPuzzleboardDrop, {
      key = self.CoordinateQ,
      value = self.CoordinateR
    }, Operation.DragCoordinate, Operation.PuzzleId)
  end
  return true
end

function WBP_PuzzleboardItem:OnDragDetected(MyGeometry, PointerEvent)
  if not self.CanDrag then
    return
  end
  if not self.SlotId then
    return
  end
  local Status = PuzzleData:GetSlotStatus(self.SlotId)
  if type(Status) == "number" then
    return
  end
  local PuzzleViewMode = UIModelMgr:Get("PuzzleViewModel")
  local SlotList = PuzzleData:GetSlotListByPuzzleId(Status)
  PuzzleData:SetPendingDragSlotList(SlotList)
  local CenterSlotId = SlotList[1]
  local Result, SlotRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSlots, CenterSlotId)
  local CenterOffsetX = 0 - SlotRowInfo.position.key
  local CenterOffsetY = 0 - SlotRowInfo.position.value
  local CoordinateList = {}
  table.insert(CoordinateList, {key = 0, value = 0})
  for i, SingleSlotId in ipairs(SlotList) do
    if SingleSlotId ~= CenterSlotId then
      local Result, SlotRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSlots, SingleSlotId)
      table.insert(CoordinateList, {
        key = SlotRowInfo.position.key + CenterOffsetX,
        value = SlotRowInfo.position.value + CenterOffsetY
      })
    end
  end
  local DragOperation = PuzzleViewMode:GetPuzzleDragOperation(CoordinateList, Status)
  self:ShowOrHideHoverTip(false)
  EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, false, nil, true)
  return DragOperation
end

function WBP_PuzzleboardItem:OnDragCancelled(MyGeometry, PointerEvent)
  print("WBP_PuzzleboardItem:OnDragCancelled")
  local RealStatus = self.SlotStatus
  RealStatus = RealStatus or PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
  local IsNeedUnEquip = false
  if type(RealStatus) ~= "number" then
    IsNeedUnEquip = true
  end
  EventSystem.Invoke(EventDef.Puzzle.OnPuzzleboardDragCancelled, RealStatus, IsNeedUnEquip)
end

function WBP_PuzzleboardItem:OnMouseEnter(...)
  self.IsHover = true
  local Status = self.SlotStatus
  Status = Status or PuzzleData:GetSlotStatus(self.SlotId)
  if type(Status) == "number" or Status == EPuzzleSlotStatus.Lock then
    return
  end
  if self.IsHoverGem then
    return
  end
  self:ShowOrHideHoverTip(true)
  PlaySound2DByName(self.HoverSoundName, "WBP_PuzzleboardItem:OnMouseEnter")
  EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, true, Status, true)
end

function WBP_PuzzleboardItem:ShowOrHideHoverTip(IsShow)
  if IsShow then
    local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
    local Status = self.SlotStatus
    Status = Status or PuzzleData:GetSlotStatus(self.SlotId)
    self.HoverWidget = PuzzleViewModel:GetPuzzleHoverWidget(Status, self)
    self.HoverWidget:Show(Status, self.PuzzlePackageInfo, self.PuzzleDetailInfo, self.GemPackageInfoList)
    if self.CanDrag then
      self.HoverWidget:ListenInputEvent(true)
    else
      self.HoverWidget:HideOperateTip()
    end
  elseif self.HoverWidget and self.HoverWidget:IsValid() then
    self.HoverWidget:Hide()
  end
end

function WBP_PuzzleboardItem:OnMouseLeave()
  self.IsHover = false
  local Status = self.SlotStatus
  Status = Status or PuzzleData:GetSlotStatus(self.SlotId)
  if type(Status) == "number" then
    return
  end
  self:ShowOrHideHoverTip(false)
  EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, false, Status, true)
end

function WBP_PuzzleboardItem:GetToolTipWidget(...)
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  local Status = self.SlotStatus
  Status = Status or PuzzleData:GetSlotStatus(self.SlotId)
  if Status == EPuzzleSlotStatus.Lock then
    return PuzzleViewModel:GetPuzzleLockBoardHoverWidget(self.SlotId)
  end
  if type(Status) == "number" then
    return nil
  end
  return nil
end

function WBP_PuzzleboardItem:BindOnGemEquipSuccess(PuzzleId, SlotId)
  local RealStatus = self.SlotStatus
  RealStatus = RealStatus or PuzzleData:GetSlotEquipPuzzleId(self.SlotId)
  if RealStatus == PuzzleId and self.CurSlotIndex == SlotId then
    self.WBP_SingleHexItem:PlayEquipGemAnim()
  end
end

function WBP_PuzzleboardItem:BindOnGemUnEquipSuccess(PuzzleId, SlotId)
end

function WBP_PuzzleboardItem:Destruct(...)
  self:Hide()
  EventSystem.RemoveListenerNew(EventDef.Puzzle.RefreshPuzzleboardItemStatus, self, self.BindOnRefreshPuzzleboardItemStatus)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzleItemHoverStatus, self, self.BindOnUpdatePuzzleItemHoverStatus)
end

return WBP_PuzzleboardItem
