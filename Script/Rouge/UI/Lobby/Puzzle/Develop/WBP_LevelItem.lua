local WBP_LevelItem = UnLua.Class()
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemData = require("Modules.Gem.GemData")
function WBP_LevelItem:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
end
function WBP_LevelItem:Show(Id, Level, IsGem)
  UpdateVisibility(self, true)
  self.Id = Id
  self.Level = Level
  self.IsGem = IsGem
  self.Txt_Level:SetText(UE.FTextFormat(self.LevelText, Level))
  self:RefreshUnSelectStatus()
  EventSystem.AddListenerNew(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, self, self.BindOnChangePuzzleUpgradeLevelSelected)
  if self.IsGem then
    EventSystem.AddListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
  else
    EventSystem.AddListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePackageInfo)
  end
end
function WBP_LevelItem:RefreshUnSelectStatus(...)
  local PackageInfo = self.IsGem and GemData:GetGemPackageInfoByUId(self.Id) or PuzzleData:GetPuzzlePackageInfo(self.Id)
  UpdateVisibility(self.Overlay_UnSelected, PackageInfo.level >= self.Level)
end
function WBP_LevelItem:BindOnMainButtonClicked(...)
  EventSystem.Invoke(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, self.Level)
end
function WBP_LevelItem:BindOnChangePuzzleUpgradeLevelSelected(Level)
  self.CurSelectedLevel = Level
  UpdateVisibility(self.Overlay_Selected, self.Level == Level)
end
function WBP_LevelItem:BindOnUpdatePackageInfo(PuzzleIdList)
  if PuzzleIdList and not table.Contain(PuzzleIdList, self.Id) then
    return
  end
  self:RefreshUnSelectStatus()
end
function WBP_LevelItem:BindOnUpdateGemPackageInfo(GemId)
  if GemId and GemId ~= self.Id then
    return
  end
  self:RefreshUnSelectStatus()
end
function WBP_LevelItem:Hide(...)
  UpdateVisibility(self, false)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnChangePuzzleUpgradeLevelSelected, self, self.BindOnChangePuzzleUpgradeLevelSelected)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, self, self.BindOnUpdatePackageInfo)
  EventSystem.RemoveListenerNew(EventDef.Gem.OnUpdateGemPackageInfo, self, self.BindOnUpdateGemPackageInfo)
end
function WBP_LevelItem:Destruct(...)
  self:Hide()
end
return WBP_LevelItem
