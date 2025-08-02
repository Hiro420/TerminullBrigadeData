local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RapidJson = require("rapidjson")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemUpgradeViewModel = CreateDefaultViewModel()
GemUpgradeViewModel.propertyBindings = {}
GemUpgradeViewModel.subViewModels = {}

function GemUpgradeViewModel:OnInit()
  self.Super.OnInit(self)
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {}
  }
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
  self.GemLevelInfo = {}
  self:DealWithTable()
end

function GemUpgradeViewModel:DealWithTable(...)
  local GemLevelUpTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGemLevelUp)
  for Level, LevelInfo in pairs(GemLevelUpTable) do
    for i, SingleUpgradeInfo in ipairs(LevelInfo.upgradeCostResources) do
      if not self.GemLevelInfo[SingleUpgradeInfo.quality] then
        self.GemLevelInfo[SingleUpgradeInfo.quality] = {}
      end
      if not self.GemLevelInfo[SingleUpgradeInfo.quality][Level] then
        self.GemLevelInfo[SingleUpgradeInfo.quality][Level] = {
          UpgradeCostResource = {},
          DecomposeGetResource = {}
        }
      end
      self.GemLevelInfo[SingleUpgradeInfo.quality][Level].UpgradeCostResource = SingleUpgradeInfo.resources
    end
    for i, SingleDecomposeResourceInfo in ipairs(LevelInfo.decomposeGetResources) do
      if not self.GemLevelInfo[SingleDecomposeResourceInfo.quality] then
        self.GemLevelInfo[SingleDecomposeResourceInfo.quality] = {}
      end
      if not self.GemLevelInfo[SingleDecomposeResourceInfo.quality][Level] then
        self.GemLevelInfo[SingleDecomposeResourceInfo.quality][Level] = {
          UpgradeCostResource = {},
          DecomposeGetResource = {}
        }
      end
      self.GemLevelInfo[SingleDecomposeResourceInfo.quality][Level].DecomposeGetResource = SingleDecomposeResourceInfo.resources
    end
  end
end

function GemUpgradeViewModel:GetMaxLevelByQuality(InQuality)
  local QualityLevelInfo = self.GemLevelInfo[InQuality]
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

function GemUpgradeViewModel:GetLevelInfoByQuality(InQuality)
  return self.GemLevelInfo[InQuality]
end

function GemUpgradeViewModel:GetGemHoverWidget(GemId)
  if not self.GemItemTipWidget or not self.GemItemTipWidget:IsValid() then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/Gem/WBP_GemItemTip.WBP_GemItemTip_C", true)
    self.GemItemTipWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, WidgetClass)
    self.GemItemTipWidgetRef = UnLua.Ref(self.GemItemTipWidget)
  end
  self.GemItemTipWidget:Show(GemId)
  return self.GemItemTipWidget
end

function GemUpgradeViewModel:SetCurSelectGemId(GemId)
  self.CurSelectGemId = GemId
end

function GemUpgradeViewModel:GetCurSelectGemId(...)
  return self.CurSelectGemId
end

function GemUpgradeViewModel:SetPuzzleSortRule(InSortRule)
  self.PuzzleSortRule = InSortRule
end

function GemUpgradeViewModel:GetPuzzleSortRule(...)
  return self.PuzzleSortRule
end

function GemUpgradeViewModel:GetSortRuleFunction()
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  return PuzzleViewModel:GetSortRuleFunction(self.PuzzleSortRule, true)
end

function GemUpgradeViewModel:GetGemFilterSelectStatus(...)
  return self.FilterSelectStatus
end

function GemUpgradeViewModel:SetGemFilterSelectStatus(InFilter)
  self.FilterSelectStatus = DeepCopy(InFilter)
  if self:GetFirstView() then
    self:GetFirstView():RefreshGemItemList()
    self:GetFirstView():RefreshFilterIconStatus()
  end
end

function GemUpgradeViewModel:GetPuzzleFilterDiscardSelected(...)
  return self.FilterDiscardSelected
end

function GemUpgradeViewModel:SetPuzzleFilterDiscardSelected(IsSelect)
  self.FilterDiscardSelected = IsSelect
end

function GemUpgradeViewModel:GetPuzzleFilterLockSelected()
  return self.FilterLockSelected
end

function GemUpgradeViewModel:SetPuzzleFilterLockSelected(IsSelect)
  self.FilterLockSelected = IsSelect
end

function GemUpgradeViewModel:OnViewClose(...)
  if self.GemItemTipWidget then
    if self.GemItemTipWidget:IsValid() then
      UnLua.Unref(self.GemItemTipWidget)
      self.GemItemTipWidget:Hide()
    end
    self.GemItemTipWidget = nil
    self.GemItemTipWidgetRef = nil
  end
  self.FilterSelectStatus = {
    [EPuzzleFilterType.Quality] = {},
    [EPuzzleFilterType.SubAttr] = {},
    [EPuzzleFilterType.World] = {}
  }
  self.PuzzleSortRule = EPuzzleSortRule.QualityDesc
  self.CurSelectPuzzleId = nil
  self.FilterDiscardSelected = false
  self.FilterLockSelected = false
end

function GemUpgradeViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

return GemUpgradeViewModel
