local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RapidJson = require("rapidjson")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleDevelopViewModel = CreateDefaultViewModel()
PuzzleDevelopViewModel.propertyBindings = {}
PuzzleDevelopViewModel.subViewModels = {}
function PuzzleDevelopViewModel:OnInit()
  self.Super.OnInit(self)
  self.IsShowPuzzleDetailList = false
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.PuzzleLevelInfo = {}
  self:DealWithTable()
end
function PuzzleDevelopViewModel:DealWithTable(...)
  local PuzzleLevelUpTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPuzzleLevelUp)
  for Level, LevelInfo in pairs(PuzzleLevelUpTable) do
    for i, SingleUpgradeInfo in ipairs(LevelInfo.upgradeCostResources) do
      if not self.PuzzleLevelInfo[SingleUpgradeInfo.quality] then
        self.PuzzleLevelInfo[SingleUpgradeInfo.quality] = {}
      end
      if not self.PuzzleLevelInfo[SingleUpgradeInfo.quality][Level] then
        self.PuzzleLevelInfo[SingleUpgradeInfo.quality][Level] = {
          UpgradeCostResource = {},
          ResetGetResource = {}
        }
      end
      self.PuzzleLevelInfo[SingleUpgradeInfo.quality][Level].UpgradeCostResource = SingleUpgradeInfo.resources
    end
    for i, SingleResetResourceInfo in ipairs(LevelInfo.resetGetResources) do
      if not self.PuzzleLevelInfo[SingleResetResourceInfo.quality] then
        self.PuzzleLevelInfo[SingleResetResourceInfo.quality] = {}
      end
      if not self.PuzzleLevelInfo[SingleResetResourceInfo.quality][Level] then
        self.PuzzleLevelInfo[SingleResetResourceInfo.quality][Level] = {
          UpgradeCostResource = {},
          ResetGetResource = {}
        }
      end
      self.PuzzleLevelInfo[SingleResetResourceInfo.quality][Level].ResetGetResource = SingleResetResourceInfo.resources
    end
  end
end
function PuzzleDevelopViewModel:GetMaxLevelByQuality(InQuality)
  local QualityLevelInfo = self.PuzzleLevelInfo[InQuality]
  if not QualityLevelInfo then
    return 0
  end
  local MaxLevel = 0
  for Level, v in pairs(QualityLevelInfo) do
    if Level > MaxLevel then
      MaxLevel = Level
    end
  end
  return MaxLevel
end
function PuzzleDevelopViewModel:GetLevelInfoByQuality(InQuality)
  return self.PuzzleLevelInfo[InQuality]
end
function PuzzleDevelopViewModel:GetPuzzleHoverWidget(PuzzleId)
  if not self.PuzzleItemTipWidget or not self.PuzzleItemTipWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleItemTip.WBP_PuzzleItemTip_C", true)
    self.PuzzleItemTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.PuzzleItemTipWidgetRef = UnLua.Ref(self.PuzzleItemTipWidget)
  end
  self.PuzzleItemTipWidget:Show(PuzzleId)
  return self.PuzzleItemTipWidget
end
function PuzzleDevelopViewModel:GetIsShowPuzzleDetailList(...)
  return self.IsShowDetailPuzzleList
end
function PuzzleDevelopViewModel:SetIsShowPuzzleDetailList(InIsShowPuzzleDetailList)
  self.IsShowDetailPuzzleList = InIsShowPuzzleDetailList
end
function PuzzleDevelopViewModel:SetCurSelectPuzzleId(PuzzleId)
  self.CurSelectPuzzleId = PuzzleId
end
function PuzzleDevelopViewModel:GetCurSelectPuzzleId(...)
  return self.CurSelectPuzzleId
end
function PuzzleDevelopViewModel:SetPuzzleSortRule(InSortRule)
  self.PuzzleSortRule = InSortRule
end
function PuzzleDevelopViewModel:GetPuzzleSortRule(...)
  return self.PuzzleSortRule
end
function PuzzleDevelopViewModel:GetSortRuleFunction()
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  return PuzzleViewModel:GetSortRuleFunction(self.PuzzleSortRule)
end
function PuzzleDevelopViewModel:GetPuzzleFilterSelectStatus(...)
  return self.FilterSelectStatus
end
function PuzzleDevelopViewModel:SetPuzzleFilterSelectStatus(InFilter)
  self.FilterSelectStatus = DeepCopy(InFilter)
  if self:GetFirstView() then
    self:GetFirstView():RefreshPuzzleItemList()
    self:GetFirstView():RefreshFilterIconStatus()
  end
end
function PuzzleDevelopViewModel:OnViewClose(...)
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
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.CurSelectPuzzleId = nil
end
function PuzzleDevelopViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
return PuzzleDevelopViewModel
