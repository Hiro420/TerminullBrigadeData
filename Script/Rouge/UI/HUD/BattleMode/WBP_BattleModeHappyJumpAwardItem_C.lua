local WBP_BattleModeHappyJumpAwardItem_C = UnLua.Class()
local GameStage = {
  None = 0,
  BeginAssemblyStage = 1,
  EndAssemblyStage = 2,
  BeginChallengeStage = 3,
  EndChallengeStage = 4,
  FailedStage = 5,
  SuccessStage = 6
}
function WBP_BattleModeHappyJumpAwardItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_BattleModeHappyJumpAwardItem_C:Init(ItemId, Num)
  UpdateVisibility(self, true)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local ItemRowInfo = DTSubsystem:K2_GetItemTableRow(tostring(ItemId), nil)
    if ItemRowInfo then
      SetImageBrushBySoftObject(self.URGImageIcon, ItemRowInfo.SpriteIcon)
    end
  end
  self.RgTextAwardNum:SetText(Num)
end
function WBP_BattleModeHappyJumpAwardItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_BattleModeHappyJumpAwardItem_C:Destruct()
  self.Overridden.Destruct(self)
end
return WBP_BattleModeHappyJumpAwardItem_C
