local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RapidJson = require("rapidjson")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemData = require("Modules.Gem.GemData")
local PuzzleViewModel = CreateDefaultViewModel()
PuzzleViewModel.propertyBindings = {
  BasicInfo = {}
}
PuzzleViewModel.subViewModels = {}
function PuzzleViewModel:OnInit()
  self.Super.OnInit(self)
  self.IsShowPuzzleDetailList = false
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.GemFilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {}
  }
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
  PuzzleData:DealWithTable()
  EventSystem.AddListenerNew(EventDef.WSMessage.HeroesExpired, self, self.BindOnHeroesExpired)
end
function PuzzleViewModel:GetPuzzleDragOperation(DragCoordinate, PuzzleId)
  if not self.DragOperation or not self.DragOperation:IsValid() then
    local DragOperationClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Puzzle/DragOperation.DragOperation_C", true)
    local DragOperation = UE.UWidgetBlueprintLibrary.CreateDragDropOperation(DragOperationClass)
    DragOperation.Pivot = UE.EDragPivot.CenterCenter
    self.DragOperation = DragOperation
    self.DragOperationRef = UnLua.Ref(self.DragOperation)
  end
  self.DragOperation.DragCoordinate = DragCoordinate
  self.DragOperation.PuzzleId = PuzzleId
  self.DragOperation.IsGem = false
  self.DragOperation.DefaultDragVisual = self:GetPuzzleDragVisualWidget(DragCoordinate, PuzzleId)
  return self.DragOperation
end
function PuzzleViewModel:GetGemDragOperation(GemId)
  if not self.DragOperation or not self.DragOperation:IsValid() then
    local DragOperationClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Puzzle/DragOperation.DragOperation_C", true)
    local DragOperation = UE.UWidgetBlueprintLibrary.CreateDragDropOperation(DragOperationClass)
    DragOperation.Pivot = UE.EDragPivot.CenterCenter
    self.DragOperation = DragOperation
    self.DragOperationRef = UnLua.Ref(self.DragOperation)
  end
  self.DragOperation.GemId = GemId
  self.DragOperation.IsGem = true
  self.DragOperation.DefaultDragVisual = self:GetGemDragVisualWidget(GemId)
  return self.DragOperation
end
function PuzzleViewModel:UpdatePuzzleDragCoordinate(DragCoordinate)
  if not self.DragOperation or not self.DragOperation:IsValid() then
    return
  end
  self.DragOperation.DragCoordinate = DragCoordinate
  self.DragVisualWidget:RefreshItemPos(DragCoordinate)
end
function PuzzleViewModel:GetPuzzleDragVisualWidget(DragCoordinate, PuzzleId)
  if not self.DragVisualWidget or not self.DragVisualWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleDragWidget.WBP_PuzzleDragWidget_C", true)
    self.DragVisualWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.DragVisualWidgetRef = UnLua.Ref(self.DragVisualWidget)
  end
  self.DragVisualWidget:Show(DragCoordinate, PuzzleId)
  return self.DragVisualWidget
end
function PuzzleViewModel:GetGemDragVisualWidget(GemId)
  if not self.GemDragVisualWidget or not self.GemDragVisualWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Gem/WBP_GemDragWidget.WBP_GemDragWidget_C", true)
    self.GemDragVisualWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.GemDragVisualWidgetRef = UnLua.Ref(self.GemDragVisualWidget)
  end
  self.GemDragVisualWidget:Show(GemId)
  return self.GemDragVisualWidget
end
function PuzzleViewModel:GetPuzzleHoverWidget(PuzzleId, HoverItem)
  if HoverItem then
    self.PuzzleItemTipWidget = ShowCommonTips(nil, HoverItem, nil, "/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleItemTip.WBP_PuzzleItemTip_C")
  elseif not self.PuzzleItemTipWidget or not self.PuzzleItemTipWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleItemTip.WBP_PuzzleItemTip_C", true)
    self.PuzzleItemTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.PuzzleItemTipWidgetRef = UnLua.Ref(self.PuzzleItemTipWidget)
  end
  if PuzzleId then
    self.PuzzleItemTipWidget:Show(PuzzleId)
  end
  return self.PuzzleItemTipWidget
end
function PuzzleViewModel:GetGemHoverWidget(GemId, HoverItem)
  if HoverItem then
    self.GemItemTipWidget = ShowCommonTips(nil, HoverItem, nil, "/Game/Rouge/UI/Lobby/Gem/WBP_GemItemTip.WBP_GemItemTip_C")
  elseif not self.GemItemTipWidget or not self.GemItemTipWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Gem/WBP_GemItemTip.WBP_GemItemTip_C", true)
    self.GemItemTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.GemItemTipWidgetRef = UnLua.Ref(self.GemItemTipWidget)
  end
  if GemId then
    self.GemItemTipWidget:Show(GemId)
  end
  return self.GemItemTipWidget
end
function PuzzleViewModel:HidePuzzleHoverWidget(...)
  if self.PuzzleItemTipWidget and self.PuzzleItemTipWidget:IsValid() then
    self.PuzzleItemTipWidget:Hide()
  end
end
function PuzzleViewModel:GetPuzzleLockBoardHoverWidget(SlotId)
  if not self.PuzzleLockBoardTipWidget or not self.PuzzleLockBoardTipWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleLockBoardTip.WBP_PuzzleLockBoardTip_C", true)
    self.PuzzleLockBoardTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.PuzzleLockBoardTipWidgetRef = UnLua.Ref(self.PuzzleLockBoardTipWidget)
  end
  self.PuzzleLockBoardTipWidget:Show(SlotId)
  return self.PuzzleLockBoardTipWidget
end
function PuzzleViewModel:SetCurHeroId(InHeroId)
  self.CurHeroId = InHeroId
end
function PuzzleViewModel:GetCurHeroId(...)
  return self.CurHeroId
end
function PuzzleViewModel:GetIsShowPuzzleDetailList(...)
  return self.IsShowDetailPuzzleList
end
function PuzzleViewModel:SetIsShowPuzzleDetailList(InIsShowPuzzleDetailList)
  self.IsShowDetailPuzzleList = InIsShowPuzzleDetailList
end
function PuzzleViewModel:SetCurSelectPuzzleId(PuzzleId)
  self.CurSelectPuzzleId = PuzzleId
end
function PuzzleViewModel:GetCurSelectPuzzleId(...)
  return self.CurSelectPuzzleId
end
function PuzzleViewModel:SetCurSelectGemId(GemId)
  self.CurSelectGemId = GemId
end
function PuzzleViewModel:GetCurSelectGemId(...)
  return self.CurSelectGemId
end
function PuzzleViewModel:SetPuzzleSortRule(InSortRule, IsGem)
  if IsGem then
    self.GemSortRule = InSortRule
  else
    self.PuzzleSortRule = InSortRule
  end
end
function PuzzleViewModel:GetPuzzleSortRule(IsGem)
  return IsGem and self.GemSortRule or self.PuzzleSortRule
end
function PuzzleViewModel:GetSortRuleFunction(SortRule, IsGem)
  local TargetSortRule = SortRule
  TargetSortRule = TargetSortRule or self.PuzzleSortRule
  if TargetSortRule == EPuzzleSortRule.LevelDesc then
    return function(A, B)
      local APackageInfo, BPackageInfo, AResourceId, BResourceId
      if IsGem then
        APackageInfo = GemData:GetGemPackageInfoByUId(A)
        BPackageInfo = GemData:GetGemPackageInfoByUId(B)
        AResourceId = GemData:GetGemResourceIdByUId(A)
        BResourceId = GemData:GetGemResourceIdByUId(B)
      else
        APackageInfo = PuzzleData:GetPuzzlePackageInfo(A)
        BPackageInfo = PuzzleData:GetPuzzlePackageInfo(B)
        AResourceId = PuzzleData:GetPuzzleResourceIdByUid(A)
        BResourceId = PuzzleData:GetPuzzleResourceIdByUid(B)
      end
      local AResult, AResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, AResourceId)
      local BResult, BResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, BResourceId)
      if APackageInfo.level == BPackageInfo.level then
        if AResourceRowInfo.Rare == BResourceRowInfo.Rare then
          return tonumber(A) > tonumber(B)
        end
        return AResourceRowInfo.Rare > BResourceRowInfo.Rare
      end
      return APackageInfo.level > BPackageInfo.level
    end
  elseif TargetSortRule == EPuzzleSortRule.LevelAsc then
    return function(A, B)
      local APackageInfo, BPackageInfo, AResourceId, BResourceId
      if IsGem then
        APackageInfo = GemData:GetGemPackageInfoByUId(A)
        BPackageInfo = GemData:GetGemPackageInfoByUId(B)
        AResourceId = GemData:GetGemResourceIdByUId(A)
        BResourceId = GemData:GetGemResourceIdByUId(B)
      else
        APackageInfo = PuzzleData:GetPuzzlePackageInfo(A)
        BPackageInfo = PuzzleData:GetPuzzlePackageInfo(B)
        AResourceId = PuzzleData:GetPuzzleResourceIdByUid(A)
        BResourceId = PuzzleData:GetPuzzleResourceIdByUid(B)
      end
      local AResult, AResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, AResourceId)
      local BResult, BResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, BResourceId)
      if APackageInfo.level == BPackageInfo.level then
        if AResourceRowInfo.Rare == BResourceRowInfo.Rare then
          return tonumber(A) > tonumber(B)
        end
        return AResourceRowInfo.Rare > BResourceRowInfo.Rare
      end
      return APackageInfo.level < BPackageInfo.level
    end
  elseif TargetSortRule == EPuzzleSortRule.QualityDesc then
    return function(A, B)
      local APackageInfo, BPackageInfo, AResourceId, BResourceId
      if IsGem then
        APackageInfo = GemData:GetGemPackageInfoByUId(A)
        BPackageInfo = GemData:GetGemPackageInfoByUId(B)
        AResourceId = GemData:GetGemResourceIdByUId(A)
        BResourceId = GemData:GetGemResourceIdByUId(B)
      else
        APackageInfo = PuzzleData:GetPuzzlePackageInfo(A)
        BPackageInfo = PuzzleData:GetPuzzlePackageInfo(B)
        AResourceId = PuzzleData:GetPuzzleResourceIdByUid(A)
        BResourceId = PuzzleData:GetPuzzleResourceIdByUid(B)
      end
      local AResult, AResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, AResourceId)
      local BResult, BResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, BResourceId)
      if AResourceRowInfo.Rare == BResourceRowInfo.Rare then
        if not IsGem then
          local AResult, APuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, AResourceId)
          local BResult, BPuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, BResourceId)
          if APuzzleResRowInfo.Grade == BPuzzleResRowInfo.Grade then
            return tonumber(A) > tonumber(B)
          end
          return APuzzleResRowInfo.Grade > BPuzzleResRowInfo.Grade
        end
        if APackageInfo.level == BPackageInfo.level then
          return tonumber(A) > tonumber(B)
        end
        return APackageInfo.level > BPackageInfo.level
      end
      return AResourceRowInfo.Rare > BResourceRowInfo.Rare
    end
  elseif TargetSortRule == EPuzzleSortRule.QualityAsc then
    return function(A, B)
      local APackageInfo, BPackageInfo, AResourceId, BResourceId
      if IsGem then
        APackageInfo = GemData:GetGemPackageInfoByUId(A)
        BPackageInfo = GemData:GetGemPackageInfoByUId(B)
        AResourceId = GemData:GetGemResourceIdByUId(A)
        BResourceId = GemData:GetGemResourceIdByUId(B)
      else
        APackageInfo = PuzzleData:GetPuzzlePackageInfo(A)
        BPackageInfo = PuzzleData:GetPuzzlePackageInfo(B)
        AResourceId = PuzzleData:GetPuzzleResourceIdByUid(A)
        BResourceId = PuzzleData:GetPuzzleResourceIdByUid(B)
      end
      local AResult, AResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, AResourceId)
      local BResult, BResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, BResourceId)
      if AResourceRowInfo.Rare == BResourceRowInfo.Rare then
        if not IsGem then
          local AResult, APuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, AResourceId)
          local BResult, BPuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, BResourceId)
          if APuzzleResRowInfo.Grade == BPuzzleResRowInfo.Grade then
            return tonumber(A) > tonumber(B)
          end
          return APuzzleResRowInfo.Grade > BPuzzleResRowInfo.Grade
        end
        if APackageInfo.level == BPackageInfo.level then
          return tonumber(A) > tonumber(B)
        end
        return APackageInfo.level > BPackageInfo.level
      end
      return AResourceRowInfo.Rare < BResourceRowInfo.Rare
    end
  elseif TargetSortRule == EPuzzleSortRule.TimeDesc then
    return function(A, B)
      return tonumber(A) > tonumber(B)
    end
  else
    return function(A, B)
      return tonumber(A) < tonumber(B)
    end
  end
end
function PuzzleViewModel:GetPuzzleFilterSelectStatus(...)
  return self.FilterSelectStatus
end
function PuzzleViewModel:GetPuzzleFilterDiscardSelected(...)
  return self.FilterDiscardSelected
end
function PuzzleViewModel:SetPuzzleFilterDiscardSelected(IsSelect)
  self.FilterDiscardSelected = IsSelect
end
function PuzzleViewModel:GetPuzzleFilterLockSelected()
  return self.FilterLockSelected
end
function PuzzleViewModel:SetPuzzleFilterLockSelected(IsSelect)
  self.FilterLockSelected = IsSelect
end
function PuzzleViewModel:SetPuzzleFilterSelectStatus(InFilter)
  self.FilterSelectStatus = DeepCopy(InFilter)
  if self:GetFirstView() then
    self:GetFirstView():RefreshPuzzleItemList()
    self:GetFirstView():RefreshFilterIconStatus()
  end
end
function PuzzleViewModel:GetGemFilterSelectStatus(...)
  return self.GemFilterSelectStatus
end
function PuzzleViewModel:SetGemFilterSelectStatus(InFilter)
  self.GemFilterSelectStatus = DeepCopy(InFilter)
  if self:GetFirstView() then
    self:GetFirstView():RefreshGemItemList()
    self:GetFirstView():RefreshFilterIconStatus()
  end
end
function PuzzleViewModel:GetGemFilterSelectStatus(...)
  return self.GemFilterSelectStatus
end
function PuzzleViewModel:SetGemFilterSelectStatus(InFilter)
  self.GemFilterSelectStatus = DeepCopy(InFilter)
  if self:GetFirstView() then
    self:GetFirstView():RefreshGemItemList()
    self:GetFirstView():RefreshFilterIconStatus()
  end
end
function PuzzleViewModel:OnViewClose(...)
  if self.DragOperation then
    if self.DragOperation:IsValid() then
      UnLua.Unref(self.DragOperation)
    end
    self.DragOperation = nil
    self.DragOperationRef = nil
  end
  if self.DragVisualWidget then
    if self.DragVisualWidget:IsValid() then
      UnLua.Unref(self.DragVisualWidget)
    end
    self.DragVisualWidget = nil
    self.DragVisualWidgetRef = nil
  end
  if self.PuzzleLockBoardTipWidget then
    if self.PuzzleLockBoardTipWidget:IsValid() then
      UnLua.Unref(self.PuzzleLockBoardTipWidget)
    end
    self.PuzzleLockBoardTipWidget = nil
    self.PuzzleLockBoardTipWidgetRef = nil
  end
  if self.PuzzleItemTipWidget then
    if self.PuzzleItemTipWidget:IsValid() then
      UnLua.Unref(self.PuzzleItemTipWidget)
      self.PuzzleItemTipWidget:Hide()
    end
    self.PuzzleItemTipWidget = nil
    self.PuzzleItemTipWidgetRef = nil
  end
  if self.GemItemTipWidget then
    if self.GemItemTipWidget:IsValid() then
      UnLua.Unref(self.GemItemTipWidget)
      self.GemItemTipWidget:Hide()
    end
    self.GemItemTipWidget = nil
    self.GemItemTipWidgetRef = nil
  end
  if self.GemDragVisualWidget then
    if self.GemDragVisualWidget:IsValid() then
      UnLua.Unref(self.GemDragVisualWidget)
    end
    self.GemDragVisualWidget = nil
    self.GemDragVisualWidgetRef = nil
  end
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.GemFilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {}
  }
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
end
function PuzzleViewModel:BindOnHeroesExpired(Message)
  print("PuzzleViewModel:BindOnHeroesExpired", Message)
  local JsonTable = rapidjson.decode(Message)
  table.Print(JsonTable.heroIDs)
  for i, SingleHeroId in ipairs(JsonTable.heroIDs) do
    local EquipPuzzleIdList = PuzzleData:GetEquipPuzzleIdListByHeroId(SingleHeroId)
    for i, SinglePuzzleId in ipairs(EquipPuzzleIdList) do
      local OldSlotIdList = PuzzleData:GetSlotListByPuzzleId(SinglePuzzleId)
      if OldSlotIdList then
        for i, SingleSlotId in ipairs(OldSlotIdList) do
          PuzzleData:RefreshSlotStatus(SingleSlotId, EPuzzleSlotStatus.Empty)
        end
      end
      PuzzleData:SetSlotEquipId(SinglePuzzleId, nil)
      PuzzleData:SetPuzzleEquipHeroId(SinglePuzzleId, 0)
    end
    PuzzleData:RemoveEquipPuzzleIdListByHeroId(SingleHeroId)
  end
  EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
  EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo)
end
function PuzzleViewModel:OnShutdown()
  self.Super.OnShutdown(self)
  EventSystem.RemoveListenerNew(EventDef.WSMessage.HeroesExpired, self, self.BindOnHeroesExpired)
end
return PuzzleViewModel
