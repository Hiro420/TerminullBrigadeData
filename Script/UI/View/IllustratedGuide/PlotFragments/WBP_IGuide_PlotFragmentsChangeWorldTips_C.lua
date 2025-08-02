local OrderedMap = require("Framework.DataStruct.OrderedMap")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_IGuide_PlotFragmentsChangeWorldTips_C = UnLua.Class()

function WBP_IGuide_PlotFragmentsChangeWorldTips_C:Construct()
  self.Btn_close.OnClicked:Add(self, self.Hide)
  self.Btn_Mask.OnClicked:Add(self, self.Hide)
  self.RGToggleGroupWorld.OnCheckStateChanged:Add(self, self.BindOnFirstGroupCheckStateChanged)
end

function WBP_IGuide_PlotFragmentsChangeWorldTips_C:Destruct()
  self.Btn_close.OnClicked:Remove(self, self.Hide)
  self.Btn_Mask.OnClicked:Remove(self, self.Hide)
  self.RGToggleGroupWorld.OnCheckStateChanged:Remove(self, self.BindOnFirstGroupCheckStateChanged)
end

function WBP_IGuide_PlotFragmentsChangeWorldTips_C:InitPlotFragmentsChangeWorldTip(ParentView)
  self:PlayAnimationForward(self.Ani_in)
  self.ParentView = ParentView
  local WorldIdList = IllustratedGuideData:GetPlotFragmentWorldIdList()
  if self.RGToggleGroupWorld then
    self.RGToggleGroupWorld:ClearGroup()
  end
  local idx = 1
  local selectId
  for k, WorldId in ipairs(WorldIdList) do
    local item = GetOrCreateItem(self.Scl_WorldList, idx, self.WBP_IGuide_FragmentWorldItem:GetClass())
    item:InitInfo(WorldId)
    idx = idx + 1
  end
  HideOtherItem(self.Scl_WorldList, idx)
  UpdateVisibility(self, true)
end

function WBP_IGuide_PlotFragmentsChangeWorldTips_C:BindOnFirstGroupCheckStateChanged(selectId)
end

function WBP_IGuide_PlotFragmentsChangeWorldTips_C:Hide()
  self:PlayAnimationForward(self.Ani_out)
end

function WBP_IGuide_PlotFragmentsChangeWorldTips_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end

return WBP_IGuide_PlotFragmentsChangeWorldTips_C
