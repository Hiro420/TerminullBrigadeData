local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RapidJson = require("rapidjson")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleDecomposeViewModel = CreateDefaultViewModel()
PuzzleDecomposeViewModel.propertyBindings = {}
PuzzleDecomposeViewModel.subViewModels = {}

function PuzzleDecomposeViewModel:OnInit()
  self.Super.OnInit(self)
  self.IsShowPuzzleDetailList = false
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.CurSelectPuzzleIdList = {}
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  self.MaxSelectNum = ConstTable.MatrixPuzzleMaxDecomposeNum
end

function PuzzleDecomposeViewModel:GetPuzzleHoverWidget(PuzzleId)
  if not self.PuzzleItemTipWidget or not self.PuzzleItemTipWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleItemTip.WBP_PuzzleItemTip_C", true)
    self.PuzzleItemTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.PuzzleItemTipWidgetRef = UnLua.Ref(self.PuzzleItemTipWidget)
  end
  self.PuzzleItemTipWidget:Show(PuzzleId)
  return self.PuzzleItemTipWidget
end

function PuzzleDecomposeViewModel:CanSelectPuzzle(PuzzleId)
  if not table.Contain(self.CurSelectPuzzleIdList, PuzzleId) and table.count(self.CurSelectPuzzleIdList) + 1 > self.MaxSelectNum then
    print("\229\183\178\232\182\133\229\135\186\230\156\128\229\164\167\233\128\137\230\139\169\230\149\176\233\135\143")
    ShowWaveWindow(300006)
    return false
  end
  return true
end

function PuzzleDecomposeViewModel:GetMaxCanSelectNum(...)
  return self.MaxSelectNum
end

function PuzzleDecomposeViewModel:SetCurSelectPuzzleId(PuzzleId)
  if not table.Contain(self.CurSelectPuzzleIdList, PuzzleId) then
    table.insert(self.CurSelectPuzzleIdList, PuzzleId)
  else
    table.RemoveItem(self.CurSelectPuzzleIdList, PuzzleId)
  end
end

function PuzzleDecomposeViewModel:RemoveAllCurSelectPuzzleIdList(...)
  self.CurSelectPuzzleIdList = {}
  EventSystem.Invoke(EventDef.Puzzle.OnPuzzleItemSelected)
end

function PuzzleDecomposeViewModel:GetCurSelectPuzzleIdList(...)
  return self.CurSelectPuzzleIdList
end

function PuzzleDecomposeViewModel:SetPuzzleSortRule(InSortRule)
  self.PuzzleSortRule = InSortRule
end

function PuzzleDecomposeViewModel:GetPuzzleSortRule(...)
  return self.PuzzleSortRule
end

function PuzzleDecomposeViewModel:GetSortRuleFunction()
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  return PuzzleViewModel:GetSortRuleFunction(self.PuzzleSortRule)
end

function PuzzleDecomposeViewModel:GetPuzzleFilterSelectStatus(...)
  return self.FilterSelectStatus
end

function PuzzleDecomposeViewModel:SetPuzzleFilterSelectStatus(InFilter)
  self.FilterSelectStatus = DeepCopy(InFilter)
  if self:GetFirstView() then
    self:GetFirstView():RefreshPuzzleItemList()
    self:GetFirstView():RefreshFilterIconStatus()
  end
end

function PuzzleDecomposeViewModel:GetPuzzleFilterDiscardSelected(...)
  return self.FilterDiscardSelected
end

function PuzzleDecomposeViewModel:SetPuzzleFilterDiscardSelected(IsSelect)
  self.FilterDiscardSelected = IsSelect
end

function PuzzleDecomposeViewModel:GetPuzzleFilterLockSelected()
  return self.FilterLockSelected
end

function PuzzleDecomposeViewModel:SetPuzzleFilterLockSelected(IsSelect)
  self.FilterLockSelected = IsSelect
end

function PuzzleDecomposeViewModel:OnViewClose(...)
  if self.PuzzleItemTipWidget then
    if self.PuzzleItemTipWidget:IsValid() then
      self.PuzzleItemTipWidget:Hide()
      UnLua.Unref(self.PuzzleItemTipWidget)
    end
    self.PuzzleItemTipWidget = nil
    self.PuzzleItemTipWidgetRef = nil
  end
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.CurSelectPuzzleIdList = {}
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
end

function PuzzleDecomposeViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

return PuzzleDecomposeViewModel
