local WBP_LevelDoorUI_C = UnLua.Class()
function WBP_LevelDoorUI_C:ShowUIByEnum(Type)
  self:HideUI()
  if Type == UE.ERGLevelLogicType.Easy then
    self.Img_Normal:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  elseif Type == UE.ERGLevelLogicType.Hard then
    self.Img_Advanced:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  elseif Type == UE.ERGLevelLogicType.Boss then
    self.Img_Boss:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WBP_LevelDoorUI_C:HideUI()
  self.Img_Normal:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Img_Advanced:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Img_Boss:SetVisibility(UE.ESlateVisibility.Hidden)
end
return WBP_LevelDoorUI_C
