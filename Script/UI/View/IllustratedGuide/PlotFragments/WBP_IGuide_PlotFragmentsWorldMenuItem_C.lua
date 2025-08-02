local OrderedMap = require("Framework.DataStruct.OrderedMap")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_IGuide_PlotFragmentsWorldMenuItem_C = UnLua.Class()

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  self.WorldId = -1
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, self.BindOnPlotFragmentsWorldChange)
end

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:Destruct()
  self.Btn_Main.OnClicked:Remove(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Remove(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Remove(self, self.BindOnMainButtonUnhovered)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, self.BindOnPlotFragmentsWorldChange, self)
end

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:InitInfo(WorldId)
  self.WorldId = WorldId
  local WorldInfo = IllustratedGuideData:GetWorldInfoByWorldId(WorldId)
  if WorldInfo then
    self.Txt_Name:SetText(WorldInfo.Name)
    self.Txt_Progress_Current:SetText(WorldInfo.FinishedPlotFragmentsCount)
    self.Txt_Progress_Total:SetText(WorldInfo.PlotFragmentsCount)
    SetImageBrushByPath(self.Img_Icon, WorldInfo.Icon)
  end
  UpdateVisibility(self.Canvas_Checked, false)
  if IllustratedGuideData.CurrentWorldId == WorldId then
    UpdateVisibility(self.Canvas_Checked, true)
  end
  if WorldInfo.FinishedPlotFragmentsCount == WorldInfo.PlotFragmentsCount then
    UpdateVisibility(self.Canvas_Finished, true)
  else
    UpdateVisibility(self.Canvas_Finished, false)
  end
  if DataMgr.GetFloorByGameModeIndex(WorldId, 1001) > 0 then
    UpdateVisibility(self.Canvas_Locked, false)
    UpdateVisibility(self.Canvas_Unlocked, true)
  else
    UpdateVisibility(self.Canvas_Locked, true)
    UpdateVisibility(self.Canvas_Unlocked, false)
  end
  self.WBP_RedDotView:ChangeRedDotIdByTag(WorldId)
end

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:InitInfoFromWorldMenu(WorldId)
  self:PlayAnimationForward(self.Ani_in)
  self.WBP_RedDotView:ChangeRedDotIdByTag(WorldId)
  self.WorldId = WorldId
  if -1 == WorldId then
    UpdateVisibility(self.Img_Icon, false)
    UpdateVisibility(self.Canvas_Finished, false)
    UpdateVisibility(self.Canvas_Locked, false)
    UpdateVisibility(self.Canvas_Bottom, false)
    UpdateVisibility(self.Canvas_ComingSoon, true)
    return
  else
    UpdateVisibility(self.Img_Icon, true)
    UpdateVisibility(self.Canvas_Bottom, true)
    UpdateVisibility(self.Canvas_ComingSoon, false)
  end
  local WorldInfo = IllustratedGuideData:GetWorldInfoByWorldId(WorldId)
  if WorldInfo then
    self.Txt_Name:SetText(WorldInfo.Name)
    self.Txt_Progress:SetText(string.format("%d/%d", WorldInfo.FinishedPlotFragmentsCount, WorldInfo.PlotFragmentsCount))
    self.Progress_Task:SetPercent(WorldInfo.FinishedPlotFragmentsCount / WorldInfo.PlotFragmentsCount)
    SetImageBrushByPath(self.Img_Icon, WorldInfo.Icon)
    if WorldInfo.FinishedPlotFragmentsCount == WorldInfo.PlotFragmentsCount then
      UpdateVisibility(self.Canvas_Finished, true)
    else
      UpdateVisibility(self.Canvas_Finished, false)
    end
    if DataMgr.GetFloorByGameModeIndex(WorldId, 1001) > 0 then
      UpdateVisibility(self.Canvas_Locked, false)
    else
      UpdateVisibility(self.Canvas_Locked, true)
    end
  end
end

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:BindOnMainButtonClicked()
  if -1 == self.WorldId then
    print("ywtao\239\188\140\230\149\172\232\175\183\230\156\159\229\190\133\228\184\150\231\149\140\228\184\141\232\131\189\231\130\185\229\135\187\239\188\129")
    return
  end
  EventSystem.Invoke(EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, self.WorldId)
end

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:BindOnMainButtonHovered()
  if -1 == self.WorldId then
    print("ywtao\239\188\140\230\149\172\232\175\183\230\156\159\229\190\133\228\184\150\231\149\140\228\184\141\232\131\189Hover\239\188\129")
    return
  end
  UpdateVisibility(self.Canvas_Hover, true)
  if self.HrzBox_ProgressText then
    UpdateVisibility(self.HrzBox_ProgressText, true)
  end
end

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:BindOnMainButtonUnhovered()
  UpdateVisibility(self.Canvas_Hover, false)
  if self.HrzBox_ProgressText then
    UpdateVisibility(self.HrzBox_ProgressText, false, false)
  end
end

function WBP_IGuide_PlotFragmentsWorldMenuItem_C:BindOnPlotFragmentsWorldChange(WorldId)
  if WorldId == self.WorldId then
    UpdateVisibility(self.Canvas_Checked, true)
  else
    UpdateVisibility(self.Canvas_Checked, false)
  end
end

return WBP_IGuide_PlotFragmentsWorldMenuItem_C
