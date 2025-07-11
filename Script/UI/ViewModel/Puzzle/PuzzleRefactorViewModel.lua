local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RapidJson = require("rapidjson")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleRefactorViewModel = CreateDefaultViewModel()
PuzzleRefactorViewModel.propertyBindings = {}
PuzzleRefactorViewModel.subViewModels = {}
function PuzzleRefactorViewModel:OnInit()
  self.Super.OnInit(self)
  self.IsShowPuzzleDetailList = false
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.MarkAreaList = {}
  self.CurSelectResourceId = nil
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
end
function PuzzleRefactorViewModel:GetPuzzleHoverWidget(PuzzleId)
  if not self.PuzzleItemTipWidget or not self.PuzzleItemTipWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleItemTip.WBP_PuzzleItemTip_C", true)
    self.PuzzleItemTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.PuzzleItemTipWidgetRef = UnLua.Ref(self.PuzzleItemTipWidget)
  end
  self.PuzzleItemTipWidget:Show(PuzzleId)
  return self.PuzzleItemTipWidget
end
function PuzzleRefactorViewModel:GetIsShowPuzzleDetailList(...)
  return self.IsShowDetailPuzzleList
end
function PuzzleRefactorViewModel:SetIsShowPuzzleDetailList(InIsShowPuzzleDetailList)
  self.IsShowDetailPuzzleList = InIsShowPuzzleDetailList
end
function PuzzleRefactorViewModel:SetCurSelectPuzzleId(PuzzleId)
  self.CurSelectPuzzleId = PuzzleId
end
function PuzzleRefactorViewModel:GetCurSelectPuzzleId(...)
  return self.CurSelectPuzzleId
end
function PuzzleRefactorViewModel:SetPuzzleSortRule(InSortRule)
  self.PuzzleSortRule = InSortRule
end
function PuzzleRefactorViewModel:GetPuzzleSortRule(...)
  return self.PuzzleSortRule
end
function PuzzleRefactorViewModel:GetSortRuleFunction()
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  return PuzzleViewModel:GetSortRuleFunction(self.PuzzleSortRule)
end
function PuzzleRefactorViewModel:GetPuzzleFilterSelectStatus(...)
  return self.FilterSelectStatus
end
function PuzzleRefactorViewModel:SetPuzzleFilterSelectStatus(InFilter)
  self.FilterSelectStatus = DeepCopy(InFilter)
  if self:GetFirstView() then
    self:GetFirstView():RefreshPuzzleItemList()
    self:GetFirstView():RefreshFilterIconStatus()
  end
end
function PuzzleRefactorViewModel:SetCurSelectResourceId(InResourceId)
  self.CurSelectResourceId = InResourceId
end
function PuzzleRefactorViewModel:GetCurSelectResourceId()
  return self.CurSelectResourceId
end
function PuzzleRefactorViewModel:GetMarkAreaList()
  return self.MarkAreaList
end
function PuzzleRefactorViewModel:RegisitMarkArea(ResourceId, MarkArea)
  if not self.MarkAreaList[ResourceId] then
    self.MarkAreaList[ResourceId] = {}
  end
  table.insert(self.MarkAreaList[ResourceId], MarkArea)
end
function PuzzleRefactorViewModel:UnRegisitMarkArea(ResourceId)
  if self.MarkAreaList[ResourceId] then
    for k, SingleItem in pairs(self.MarkAreaList[ResourceId]) do
      UpdateVisibility(SingleItem, false)
    end
  end
  self.MarkAreaList[ResourceId] = nil
end
function PuzzleRefactorViewModel:ClearMarkArea()
  self.MarkAreaList = {}
end
function PuzzleRefactorViewModel:GetPuzzleFilterDiscardSelected(...)
  return self.FilterDiscardSelected
end
function PuzzleRefactorViewModel:SetPuzzleFilterDiscardSelected(IsSelect)
  self.FilterDiscardSelected = IsSelect
end
function PuzzleRefactorViewModel:GetPuzzleFilterLockSelected()
  return self.FilterLockSelected
end
function PuzzleRefactorViewModel:SetPuzzleFilterLockSelected(IsSelect)
  self.FilterLockSelected = IsSelect
end
function PuzzleRefactorViewModel:OnViewClose(...)
  if self.PuzzleItemTipWidget then
    if self.PuzzleItemTipWidget:IsValid() then
      UnLua.Unref(self.PuzzleItemTipWidget)
      self.PuzzleItemTipWidget:Hide()
    end
    self.PuzzleItemTipWidget = nil
    self.PuzzleItemTipWidgetRef = nil
  end
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.CurSelectPuzzleId = nil
  self.CurSelectResourceId = nil
  self:ClearMarkArea()
end
function PuzzleRefactorViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
return PuzzleRefactorViewModel
