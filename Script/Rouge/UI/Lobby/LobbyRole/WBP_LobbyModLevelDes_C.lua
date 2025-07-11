local WBP_LobbyModLevelDes_C = UnLua.Class()
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Gray = UE.FLinearColor(0.135633, 0.132868, 0.132868, 1.0)
}
function WBP_LobbyModLevelDes_C:InitLevelDes(LevelIndex, ModID)
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if logicCommandDataSubsystem then
    local levelString = "\231\173\137\231\186\167" .. LevelIndex .. ":"
    local des = GetLuaInscriptionDesc(ModID, -1)
    local finalDes = levelString .. des
    self.TextBlock_Level:SetText(finalDes)
    local SlateColor = UE.FSlateColor()
    SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
    self.Image_Level:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    SlateColor.SpecifiedColor = CostTextColor.White
    self.TextBlock_Level:SetDefaultColorAndOpacity(SlateColor)
  end
end
return WBP_LobbyModLevelDes_C
