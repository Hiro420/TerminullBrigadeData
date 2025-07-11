local OrderedMap = require("Framework.DataStruct.OrderedMap")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_IGuide_PlotFragmentsTips_C = UnLua.Class()
function WBP_IGuide_PlotFragmentsTips_C:Construct()
  self.FragmentId = -1
end
function WBP_IGuide_PlotFragmentsTips_C:Destruct()
end
function WBP_IGuide_PlotFragmentsTips_C:InitInfo(ClueId, FragmentId)
  self.ClueId = ClueId
  self.FragmentId = FragmentId
  local FragmentInfo = IllustratedGuideData:GetPlotFragmentInfoByFragmentId(FragmentId)
  local FragmentState = IllustratedGuideData:GetPlotFragmentStateById(FragmentId)
  self.Txt_FragmentName:SetText(FragmentInfo.title)
  self.Txt_InteractText:SetText(UE.URGBlueprintLibrary.TextFromStringTable("1201"))
  if not table.Contain({2, 3}, FragmentState) then
    self.Txt_FragmentName:SetText(UE.URGBlueprintLibrary.TextFromStringTable("1203"))
    self.Txt_InteractText:SetText(UE.URGBlueprintLibrary.TextFromStringTable("1202"))
  end
  UpdateVisibility(self, true)
end
function WBP_IGuide_PlotFragmentsTips_C:Hide()
  UpdateVisibility(self, false)
end
return WBP_IGuide_PlotFragmentsTips_C
