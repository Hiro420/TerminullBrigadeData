local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local OrderedMap = require("Framework.DataStruct.OrderedMap")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local IllustratedGuideHandler = require("Protocol.IllustratedGuide.IllustratedGuideHandler")
local IllustratedGuidePlotFragmentsView = Class(ViewBase)

function IllustratedGuidePlotFragmentsView:OnBindUIInput()
  if not IsListeningForInputAction(self, "PauseGame") then
    ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindCloseSelf
    })
  end
  self.WBP_InteractTipWidgetPrevious:BindInteractAndClickEvent(self, self.PreChangeWorld)
  self.WBP_InteractTipWidgetNext:BindInteractAndClickEvent(self, self.NextChangeWorld)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Add(self, self.BindCloseSelf)
end

function IllustratedGuidePlotFragmentsView:OnUnBindUIInput()
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  self.WBP_InteractTipWidgetPrevious:UnBindInteractAndClickEvent(self, self.PreChangeWorld)
  self.WBP_InteractTipWidgetNext:UnBindInteractAndClickEvent(self, self.NextChangeWorld)
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Remove(self, self.BindCloseSelf)
end

function IllustratedGuidePlotFragmentsView:BindClickHandler()
  self.Btn_ChangeWorld.OnClicked:Add(self, self.BindOnShowChangeWorld)
end

function IllustratedGuidePlotFragmentsView:UnBindClickHandler()
  self.Btn_ChangeWorld.OnClicked:Remove(self, self.BindOnShowChangeWorld)
end

function IllustratedGuidePlotFragmentsView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function IllustratedGuidePlotFragmentsView:OnDestroy()
  self:UnBindClickHandler()
end

function IllustratedGuidePlotFragmentsView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, self.BindOnPlotFragmentsWorldChange)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnPlotFragmentsItemChanged, self.BindOnPlotFragmentsItemChanged)
  local WorldIdList = IllustratedGuideData:GetPlotFragmentWorldIdList()
  self:BindOnPlotFragmentsWorldChange(IllustratedGuideData.CurrentWorldId, true)
  self:PlayAnimationForward(self.Ani_in)
end

function IllustratedGuidePlotFragmentsView:BindCloseSelf()
  print("IllustratedGuidePlotFragmentsView:BindCloseSelf")
  if self:IsAnyAnimationPlaying() then
    return
  end
  if self.WBP_IGuide_PlotFragmentsDetail:IsVisible() then
    self.WBP_IGuide_PlotFragmentsDetail:Hide()
    EventSystem.Invoke(EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, IllustratedGuideData.CurrentWorldId)
  else
    self:PlayAnimationForward(self.Ani_out)
  end
end

function IllustratedGuidePlotFragmentsView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, self.BindOnPlotFragmentsWorldChange, self)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnPlotFragmentsItemChanged, self.BindOnPlotFragmentsItemChanged, self)
  UpdateVisibility(self.WBP_IGuide_PlotFragmentsChangeWorldTips, false)
end

function IllustratedGuidePlotFragmentsView:BindOnShowChangeWorld()
  self.WBP_IGuide_PlotFragmentsChangeWorldTips:InitPlotFragmentsChangeWorldTip(self)
  UpdateVisibility(self.WBP_IGuide_PlotFragmentsChangeWorldTips, true)
end

function IllustratedGuidePlotFragmentsView:BindOnPlotFragmentsWorldChange(WorldId, bResetPageIndex)
  IllustratedGuideData.CurrentWorldId = WorldId
  IllustratedGuideData.CurrentClueId = -1
  IllustratedGuideData.CurrentFragmentId = -1
  local WorldInfo = IllustratedGuideData:GetWorldInfoByWorldId(WorldId)
  SetImageBrushByPath(self.Img_Bg, WorldInfo.Icon)
  self.Txt_WorldName:SetText(WorldInfo.Name)
  local ClueIdList = WorldInfo.ClueIdList
  for k, ClueId in pairs(ClueIdList) do
    local item = GetOrCreateItem(self.SclBox_ClueList, k, self.WBP_IGuide_PlotFragmentsGroupItem:GetClass())
    item:InitInfo(ClueId, k, bResetPageIndex)
  end
  HideOtherItem(self.SclBox_ClueList, #ClueIdList + 1)
  self.WBP_IGuide_PlotFragmentsDetail:Hide()
  if self.Level ~= nil then
    if self:IsAnimationPlaying(self["Ani_Floor_in_" .. self.Level]) then
      self:StopAnimation(self["Ani_Floor_in_" .. self.Level])
    end
    self:PlayAnimationForward(self["Ani_Floor_out_" .. self.Level])
    for k, v in iterator(self.SclBox_ClueList:GetAllChildren()) do
      if v.Level == self.Level then
        if v:IsAnimationPlaying(v["Ani_Floor_in_" .. self.Level]) then
          v:StopAnimation(v["Ani_Floor_in_" .. self.Level])
        end
        v:PlayAnimationForward(v["Ani_Floor_out_" .. self.Level])
      end
    end
    self.Level = nil
  end
end

function IllustratedGuidePlotFragmentsView:BindOnPlotFragmentsItemChanged(ClueId, FragmentId)
  if IllustratedGuideData.CurrentClueId == ClueId and IllustratedGuideData.CurrentFragmentId == FragmentId then
    return
  end
  if IllustratedGuideData.CurrentClueId ~= ClueId then
    for k, v in iterator(self.SclBox_ClueList:GetAllChildren()) do
      if v.ClueId ~= ClueId then
        v:Hide()
      else
        self.Level = v.Level
        self:PlayAnimationForward(self["Ani_Floor_in_" .. self.Level])
        v:PlayAnimationForward(v["Ani_Floor_in_" .. self.Level])
      end
    end
  end
  IllustratedGuideData.CurrentClueId = ClueId
  IllustratedGuideData.CurrentFragmentId = FragmentId
  if FragmentId then
    UpdateVisibility(self.WBP_IGuide_PlotFragmentsDetail, true)
    if -1 ~= FragmentId then
      self.WBP_IGuide_PlotFragmentsDetail:InitInfo(FragmentId, self.Level)
    elseif -1 ~= ClueId then
      self.WBP_IGuide_PlotFragmentsDetail:InitInfoByClueId(ClueId, self.Level)
    end
  end
end

function IllustratedGuidePlotFragmentsView:PreChangeWorld()
  if self:IsAnyAnimationPlaying() then
    return
  end
  local WorldIdList = IllustratedGuideData:GetPlotFragmentWorldIdList()
  local index = 1
  for k, v in pairs(WorldIdList) do
    if v == IllustratedGuideData.CurrentWorldId then
      index = k
      break
    end
  end
  if 1 == index then
    index = #WorldIdList
  else
    index = index - 1
  end
  EventSystem.Invoke(EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, WorldIdList[index])
end

function IllustratedGuidePlotFragmentsView:NextChangeWorld()
  if self:IsAnyAnimationPlaying() then
    return
  end
  local WorldIdList = IllustratedGuideData:GetPlotFragmentWorldIdList()
  local index = 1
  for k, v in pairs(WorldIdList) do
    if v == IllustratedGuideData.CurrentWorldId then
      index = k
      break
    end
  end
  if index == #WorldIdList then
    index = 1
  else
    index = index + 1
  end
  EventSystem.Invoke(EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, WorldIdList[index])
end

function IllustratedGuidePlotFragmentsView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UIMgr:Hide(ViewID.UI_IllustratedGuidePlotFragments, true)
  end
end

return IllustratedGuidePlotFragmentsView
