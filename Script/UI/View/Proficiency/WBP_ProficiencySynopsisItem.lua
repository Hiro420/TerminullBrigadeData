local RedDotData = require("Modules.RedDot.RedDotData")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local WBP_ProficiencySynopsisItem = UnLua.Class()

function WBP_ProficiencySynopsisItem:Construct()
  self.OnRGToggleStateChanged:Bind(self, self.OnSelectToggle)
end

function WBP_ProficiencySynopsisItem:Destruct()
  self.OnRGToggleStateChanged:Unbind()
end

function WBP_ProficiencySynopsisItem:OnSelectToggle(bIsChecked, ToggleIdx)
  self.IsSelected = bIsChecked
  self:UpdatePanelVis()
end

function WBP_ProficiencySynopsisItem:InitProficiencySynopsisItem(HeroId, Level)
  self.CurHeroId = HeroId
  self.CurLevel = Level
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(HeroId) .. "_" .. tostring(Level))
  local Result, RowInfo = ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel(self.CurHeroId, self.CurLevel)
  if not Result then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, true)
  self:UpdatePanelVis()
  local PageText = NSLOCTEXT("WBP_ProficiencySynopsisItem", "PageText", "\231\172\172{0}\231\171\160")
  self.Txt_Num_UnSelect:SetText(UE.FTextFormat(PageText, NumToTxt(self.CurLevel - 1)))
  self.Txt_Num_Select:SetText(UE.FTextFormat(PageText, NumToTxt(self.CurLevel - 1)))
  self.Txt_Num_Unlock:SetText(UE.FTextFormat(PageText, NumToTxt(self.CurLevel - 1)))
  self:RefreshAwardInfo(RowInfo.StoryRewardList)
end

function WBP_ProficiencySynopsisItem:UpdatePanelVis(...)
  UpdateVisibility(self.CanvasPanel_UnSelect, false)
  UpdateVisibility(self.CanvasPanel_Lock, false)
  UpdateVisibility(self.CanvasPanel_Select, false)
  local CurUnLockLevel = ProficiencyData:GetMaxUnlockProfyLevel(self.CurHeroId)
  local Result, RowInfo = ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel(self.CurHeroId, self.CurLevel)
  local Str = "???"
  if self.IsSelected then
    if CurUnLockLevel < self.CurLevel then
      self.Txt_Name_Select:SetText(Str)
    else
      self.Txt_Name_Select:SetText(RowInfo.Name)
    end
    UpdateVisibility(self.CanvasPanel_Select, true)
  elseif CurUnLockLevel < self.CurLevel then
    UpdateVisibility(self.CanvasPanel_Lock, true)
    self.Txt_Name_Unlock:SetText(Str)
  else
    UpdateVisibility(self.CanvasPanel_UnSelect, true)
    self.Txt_Name_UnSelect:SetText(RowInfo.Name)
  end
end

function WBP_ProficiencySynopsisItem:RefreshAwardInfo(AwardList)
  local Index = 1
  for index, SingleAwardInfo in ipairs(AwardList) do
    local Item = GetOrCreateItem(self.AwardListPanel, Index, self.WBP_Item)
    Item:InitItem(SingleAwardInfo.key, SingleAwardInfo.value)
    UpdateVisibility(Item, true)
    Item:UpdateReceivedPanelVis(ProficiencyData:IsCurProfyStoryRewardReceived(self.CurHeroId, self.CurLevel))
    Index = Index + 1
  end
  HideOtherItem(self.AwardListPanel, Index, true)
end

function WBP_ProficiencySynopsisItem:OnMouseEnter()
  UpdateVisibility(self.CanvasPanelHover, true)
end

function WBP_ProficiencySynopsisItem:OnMouseLeave()
  UpdateVisibility(self.CanvasPanelHover, false)
end

return WBP_ProficiencySynopsisItem
