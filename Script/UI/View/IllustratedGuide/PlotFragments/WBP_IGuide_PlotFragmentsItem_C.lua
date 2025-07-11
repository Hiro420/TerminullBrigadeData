local OrderedMap = require("Framework.DataStruct.OrderedMap")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_IGuide_PlotFragmentsItem_C = UnLua.Class()
function WBP_IGuide_PlotFragmentsItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  self.FragmentId = -1
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnPlotFragmentsItemChanged, self.BindOnPlotFragmentsItemChanged)
end
function WBP_IGuide_PlotFragmentsItem_C:Destruct()
  self.Btn_Main.OnClicked:Remove(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Remove(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Remove(self, self.BindOnMainButtonUnhovered)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnPlotFragmentsItemChanged, self.BindOnPlotFragmentsItemChanged, self)
end
function WBP_IGuide_PlotFragmentsItem_C:InitInfo(ClueId, FragmentId)
  self.ClueId = ClueId
  self.FragmentId = FragmentId
  UpdateVisibility(self.Canvas_Checked, false)
  UpdateVisibility(self.Canvas_Locked, false)
  UpdateVisibility(self, true)
  local FragmentInfo = IllustratedGuideData:GetPlotFragmentInfoByFragmentId(FragmentId)
  if FragmentInfo then
    SetImageBrushByPath(self.Img_Icon, FragmentInfo.icon)
  end
  if IllustratedGuideData.CurrentClueId == ClueId and IllustratedGuideData.CurrentFragmentId == FragmentId then
    UpdateVisibility(self.Canvas_Checked, true)
  end
  local ClueInfo = IllustratedGuideData:GetClueInfoByClueId(ClueId)
  local ClueColor = ClueInfo.color
  local FColor = UE4.FColor(ClueColor[1], ClueColor[2], ClueColor[3], ClueColor[4])
  local LinearColor = UE.UKismetMathLibrary.Conv_ColorToLinearColor(FColor)
  self.Image_bg:SetColorAndOpacity(LinearColor)
  local FragmentState = IllustratedGuideData:GetPlotFragmentStateById(FragmentId)
  if not table.Contain({2, 3}, FragmentState) then
    UpdateVisibility(self.Canvas_Locked, true)
    UpdateVisibility(self.Canvas_Unlocked, false)
  else
    UpdateVisibility(self.Canvas_Locked, false)
    UpdateVisibility(self.Canvas_Unlocked, true)
  end
  self.WBP_RedDotView:ChangeRedDotIdByTag(ClueId .. "_" .. FragmentId)
  if self.ToolTipWidget then
    self.ToolTipWidget:Hide()
  end
  self:BindOnMainButtonUnhovered()
end
function WBP_IGuide_PlotFragmentsItem_C:Hide()
  UpdateVisibility(self.Canvas_Hover, false)
  UpdateVisibility(self.Canvas_Checked, false)
  UpdateVisibility(self.Canvas_Locked, false)
  UpdateVisibility(self, false)
end
function WBP_IGuide_PlotFragmentsItem_C:BindOnMainButtonClicked()
  local PlotFragmentsView = UIMgr:GetLuaFromActiveView(ViewID.UI_IllustratedGuidePlotFragments)
  if PlotFragmentsView and PlotFragmentsView:IsAnyAnimationPlaying() then
    return
  end
  EventSystem.Invoke(EventDef.IllustratedGuide.OnPlotFragmentsItemChanged, self.ClueId, self.FragmentId)
end
function WBP_IGuide_PlotFragmentsItem_C:BindOnMainButtonHovered()
  UpdateVisibility(self.Canvas_Hover, true)
  self.SclBox_Main:SetRenderScale(UE.FVector2D(1.1))
  local WidgetClassPath = "/Game/Rouge/UI/IllustratedGuide/PlotFragments/WBP_IGuide_PlotFragmentsTips.WBP_IGuide_PlotFragmentsTips_C"
  local Offset = UE.FVector2D(-80, 0)
  self.HoverTips = ShowCommonTips(nil, self, nil, WidgetClassPath, nil, false, Offset)
  self.HoverTips:InitInfo(self.ClueId, self.FragmentId)
end
function WBP_IGuide_PlotFragmentsItem_C:BindOnMainButtonUnhovered()
  UpdateVisibility(self.Canvas_Hover, false)
  UpdateVisibility(self.HoverTips, false)
  self.SclBox_Main:SetRenderScale(UE.FVector2D(1))
end
function WBP_IGuide_PlotFragmentsItem_C:BindOnPlotFragmentsItemChanged(ClueId, FragmentId)
  if FragmentId == self.FragmentId then
    UpdateVisibility(self.Canvas_Checked, true)
  else
    UpdateVisibility(self.Canvas_Checked, false)
  end
end
function WBP_IGuide_PlotFragmentsItem_C:SetIndex(Index)
  self.Txt_Num_1:SetText(tostring(Index))
  self.Txt_Num_2:SetText(tostring(Index))
end
return WBP_IGuide_PlotFragmentsItem_C
