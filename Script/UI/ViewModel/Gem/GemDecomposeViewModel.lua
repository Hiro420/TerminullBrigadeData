local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RapidJson = require("rapidjson")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemDecomposeViewModel = CreateDefaultViewModel()
GemDecomposeViewModel.propertyBindings = {}
GemDecomposeViewModel.subViewModels = {}
function GemDecomposeViewModel:OnInit()
  self.Super.OnInit(self)
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {}
  }
  self.CurSelectPuzzleIdList = {}
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  self.MaxSelectNum = ConstTable.MatrixPuzzleMaxDecomposeNum
end
function GemDecomposeViewModel:GetGemHoverWidget(GemId)
  if not self.GemItemTipWidget or not self.GemItemTipWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Gem/WBP_GemItemTip.WBP_GemItemTip_C", true)
    self.GemItemTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.GemItemTipWidgetRef = UnLua.Ref(self.GemItemTipWidget)
  end
  self.GemItemTipWidget:Show(GemId)
  return self.GemItemTipWidget
end
function GemDecomposeViewModel:CanSelectGem(GemId)
  if not table.Contain(self.CurSelectPuzzleIdList, GemId) and table.count(self.CurSelectPuzzleIdList) + 1 > self.MaxSelectNum then
    print("\229\183\178\232\182\133\229\135\186\230\156\128\229\164\167\233\128\137\230\139\169\230\149\176\233\135\143")
    ShowWaveWindow(300006)
    return false
  end
  return true
end
function GemDecomposeViewModel:GetMaxCanSelectNum(...)
  return self.MaxSelectNum
end
function GemDecomposeViewModel:SetCurSelectGemId(GemId)
  if not table.Contain(self.CurSelectPuzzleIdList, GemId) then
    table.insert(self.CurSelectPuzzleIdList, GemId)
  else
    table.RemoveItem(self.CurSelectPuzzleIdList, GemId)
  end
end
function GemDecomposeViewModel:RemoveAllCurSelectGemIdList(...)
  self.CurSelectPuzzleIdList = {}
  EventSystem.Invoke(EventDef.Gem.OnGemItemSelected)
end
function GemDecomposeViewModel:GetCurSelectGemIdList(...)
  return self.CurSelectPuzzleIdList
end
function GemDecomposeViewModel:SetPuzzleSortRule(InSortRule)
  self.PuzzleSortRule = InSortRule
end
function GemDecomposeViewModel:GetPuzzleSortRule(...)
  return self.PuzzleSortRule
end
function GemDecomposeViewModel:GetSortRuleFunction()
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  return PuzzleViewModel:GetSortRuleFunction(self.PuzzleSortRule, true)
end
function GemDecomposeViewModel:GetGemFilterSelectStatus(...)
  return self.FilterSelectStatus
end
function GemDecomposeViewModel:SetGemFilterSelectStatus(InFilter)
  self.FilterSelectStatus = DeepCopy(InFilter)
  if self:GetFirstView() then
    self:GetFirstView():RefreshGemItemList()
    self:GetFirstView():RefreshFilterIconStatus()
  end
end
function GemDecomposeViewModel:GetPuzzleFilterDiscardSelected(...)
  return self.FilterDiscardSelected
end
function GemDecomposeViewModel:SetPuzzleFilterDiscardSelected(IsSelect)
  self.FilterDiscardSelected = IsSelect
end
function GemDecomposeViewModel:GetPuzzleFilterLockSelected()
  return self.FilterLockSelected
end
function GemDecomposeViewModel:SetPuzzleFilterLockSelected(IsSelect)
  self.FilterLockSelected = IsSelect
end
function GemDecomposeViewModel:OnViewClose(...)
  if self.GemItemTipWidget then
    if self.GemItemTipWidget:IsValid() then
      self.GemItemTipWidget:Hide()
      UnLua.Unref(self.GemItemTipWidget)
    end
    self.GemItemTipWidget = nil
    self.GemItemTipWidgetRef = nil
  end
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {}
  }
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.CurSelectPuzzleIdList = {}
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
end
function GemDecomposeViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
return GemDecomposeViewModel
