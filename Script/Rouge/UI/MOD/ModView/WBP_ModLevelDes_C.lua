local WBP_ModLevelDes_C = UnLua.Class()
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Gray = UE.FLinearColor(0.135633, 0.132868, 0.132868, 1.0)
}

function WBP_ModLevelDes_C:InitLevelDes(CurrentModLevel, LevelIndex, ModID)
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if logicCommandDataSubsystem then
    local levelString = "\231\173\137\231\186\167" .. LevelIndex .. ":"
    local des = GetLuaInscriptionDesc(ModID, -1)
    local finalDes = levelString .. des
    self.TextBlock_Level:SetText(finalDes)
    local SlateColor = UE.FSlateColor()
    SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
    if CurrentModLevel < LevelIndex then
      self.Image_Level:SetVisibility(UE.ESlateVisibility.Hidden)
      SlateColor.SpecifiedColor = CostTextColor.Gray
    else
      self.Image_Level:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      SlateColor.SpecifiedColor = CostTextColor.White
    end
    self.TextBlock_Level:SetDefaultColorAndOpacity(SlateColor)
  end
end

return WBP_ModLevelDes_C
