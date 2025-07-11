local WBP_ProfySettlementView = UnLua.Class()
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
function WBP_ProfySettlementView:Show()
  local PlayerInfo = LogicSettlement:GetPlayerInfoByPlayerId(tonumber(DataMgr.GetUserId()))
  if not PlayerInfo then
    return
  end
  local CurHeroId = PlayerInfo.hero.id
  local CurLevel = ProficiencyData:GetMaxUnlockProfyLevel(CurHeroId)
  local CurExp = ProficiencyData:GetCurProfyExp(CurHeroId)
  self.Txt_Level:SetText(CurLevel)
  self.Txt_CurExp:SetText(CurExp)
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(CurHeroId)
  local AResult, LevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, CurLevel)
  if not AResult then
    print("WBP_ProfySettlementView:Show ProfyLevel RowInfo is nil! RowId:", CurLevel)
    return
  end
  self.Txt_LevelName:SetText(LevelRowInfo.Name)
  local RGStatisticsSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGStatisticsSubsystem:StaticClass())
  self.Txt_AddExp:SetText(tostring(RGStatisticsSubsystem.ProficiencyExp))
  local BResult, NextLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, CurLevel + 1)
  if CurLevel < MaxLevel and BResult then
    self.ExpPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Overlay_Exp:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_NextLevelExp:SetText(NextLevelRowInfo.Exp)
    self.Img_ExpOrigin:SetClippingValue((CurExp - LevelRowInfo.Exp) / (NextLevelRowInfo.Exp - LevelRowInfo.Exp))
    self.Img_ExpAdded:SetClippingValue((CurExp + RGStatisticsSubsystem.ProficiencyExp - LevelRowInfo.Exp) / (NextLevelRowInfo.Exp - LevelRowInfo.Exp))
  else
    self.ExpPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Overlay_Exp:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
return WBP_ProfySettlementView
