local OrderedMap = require("Framework.DataStruct.OrderedMap")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_IGuide_PlotFragmentsGroupItem_C = UnLua.Class()

function WBP_IGuide_PlotFragmentsGroupItem_C:Construct()
  self.Btn_ShowStory.OnClicked:Add(self, self.BindOnShowStoryButtonClicked)
  self.Btn_Left.OnClicked:Add(self, self.BindOnLeftButtonClicked)
  self.Btn_Right.OnClicked:Add(self, self.BindOnRightButtonClicked)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnPlotFragmentsItemChanged, self.BindOnPlotFragmentsItemChanged)
end

function WBP_IGuide_PlotFragmentsGroupItem_C:Destruct()
  self.Btn_ShowStory.OnClicked:Remove(self, self.BindOnShowStoryButtonClicked)
  self.Btn_Left.OnClicked:Remove(self, self.BindOnLeftButtonClicked)
  self.Btn_Right.OnClicked:Remove(self, self.BindOnRightButtonClicked)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnPlotFragmentsItemChanged, self.BindOnPlotFragmentsItemChanged, self)
end

function WBP_IGuide_PlotFragmentsGroupItem_C:InitInfo(ClueId, Level, bResetPageIndex)
  self.ClueId = ClueId
  if nil ~= Level then
    self.Level = Level
  end
  for i = 1, 3 do
    if i == self.Level then
      UpdateVisibility(self["WrapBox_FragmentList_" .. i], true)
    else
      UpdateVisibility(self["WrapBox_FragmentList_" .. i], false)
    end
  end
  local ClueInfo = IllustratedGuideData:GetClueInfoByClueId(ClueId)
  if ClueInfo then
    self.Txt_Name:SetText(ClueInfo.title)
  end
  if bResetPageIndex then
    self.PageIndex = 1
  end
  self:UpdateTargetFragmentList()
  UpdateVisibility(self.HrzBox_Progress, false)
  UpdateVisibility(self, true)
  self.WBP_RedDotView_Story:ChangeRedDotIdByTag(ClueId)
  self.WBP_RedDotView_Clue:ChangeRedDotIdByTag(ClueId)
  if IllustratedGuideData:CheckClueFinishedByClueId(self.ClueId) then
    UpdateVisibility(self.Canvas_BtnUnlock, true)
    UpdateVisibility(self.Canvas_BtnLock, false)
  else
    UpdateVisibility(self.Canvas_BtnUnlock, false)
    UpdateVisibility(self.Canvas_BtnLock, true)
  end
end

function WBP_IGuide_PlotFragmentsGroupItem_C:Hide()
  SetHitTestInvisible(self)
end

function WBP_IGuide_PlotFragmentsGroupItem_C:BindOnShowStoryButtonClicked()
  local PlotFragmentsView = UIMgr:GetLuaFromActiveView(ViewID.UI_IllustratedGuidePlotFragments)
  if PlotFragmentsView and PlotFragmentsView:IsAnyAnimationPlaying() then
    return
  end
  if IllustratedGuideData:CheckClueFinishedByClueId(self.ClueId) then
    EventSystem.Invoke(EventDef.IllustratedGuide.OnPlotFragmentsItemChanged, self.ClueId, -1)
    self.WBP_RedDotView_Story:SetNum(0)
  else
    ShowWaveWindow(1174)
  end
end

function WBP_IGuide_PlotFragmentsGroupItem_C:UpdateTargetFragmentList()
  local TargetFragmentList = self["WrapBox_FragmentList_" .. tostring(self.Level)]
  local NeedShowFragmentList = {}
  local ClueInfo = IllustratedGuideData:GetClueInfoByClueId(self.ClueId)
  local FragmentIdList = ClueInfo.fragmentIDList
  local TargetFragmentListItemMaxCount = TargetFragmentList:GetChildrenCount()
  self.MaxPage = math.ceil(#FragmentIdList / TargetFragmentListItemMaxCount)
  local StartIndex = 1 + (self.PageIndex - 1) * TargetFragmentListItemMaxCount
  for k, v in pairs(FragmentIdList) do
    if k >= StartIndex and k < StartIndex + TargetFragmentListItemMaxCount then
      table.insert(NeedShowFragmentList, v)
    end
  end
  for k, v in pairs(NeedShowFragmentList) do
    local Item = TargetFragmentList:GetChildAt(k - 1)
    Item:InitInfo(self.ClueId, v)
    Item:SetIndex(StartIndex + k - 1)
  end
  HideOtherItem(TargetFragmentList, #NeedShowFragmentList + 1)
  for i = 1, self.MaxPage do
    local item = GetOrCreateItem(self.HrzBox_Step, i, self.WBP_ChipStepItem:GetClass())
    if self.PageIndex == i then
      item.RGStateControllerSelect:ChangeStatus(ESelect.Select)
    else
      item.RGStateControllerSelect:ChangeStatus(ESelect.UnSelect)
    end
  end
  HideOtherItem(self.HrzBox_Step, self.MaxPage + 1, true)
  if TargetFragmentListItemMaxCount < #FragmentIdList then
    UpdateVisibility(self.Canvas_ChangePage, true)
  else
    UpdateVisibility(self.Canvas_ChangePage, false)
  end
end

function WBP_IGuide_PlotFragmentsGroupItem_C:BindOnLeftButtonClicked()
  self.PageIndex = (self.PageIndex - 2 + self.MaxPage) % self.MaxPage + 1
  self:UpdateTargetFragmentList()
end

function WBP_IGuide_PlotFragmentsGroupItem_C:BindOnRightButtonClicked()
  self.PageIndex = self.PageIndex % self.MaxPage + 1
  self:UpdateTargetFragmentList()
end

function WBP_IGuide_PlotFragmentsGroupItem_C:BindOnPlotFragmentsItemChanged(ClueId, FragmentId)
  if ClueId == self.ClueId then
    UpdateVisibility(self.HrzBox_Progress, true)
    local ClueProgress = IllustratedGuideData:ClueProgressByClueId(ClueId)
    self.Txt_Progress_Current:SetText(ClueProgress.FinishedCount)
    self.Txt_Progress_Total:SetText(ClueProgress.TotalCount)
  end
end

return WBP_IGuide_PlotFragmentsGroupItem_C
