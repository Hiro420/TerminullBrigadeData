local WBP_SingleDifficultItem_C = UnLua.Class()
function WBP_SingleDifficultItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, WBP_SingleDifficultItem_C.BindOnMainButtonClicked)
end
function WBP_SingleDifficultItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Lobby.OnModeInfoItemClicked, self.ModeId, self.Floor)
end
function WBP_SingleDifficultItem_C:Show(Floor, ModeLevelInfo, ModeId)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_DifficultName:SetText(ModeLevelInfo.LevelName)
  self.Floor = Floor
  self.ModeId = ModeId
  local MaxUnLockFloor = DataMgr.GetGameFloorByGameMode(self.ModeId)
  if Floor > MaxUnLockFloor then
    self.Img_Lock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_DifficultName:SetColorAndOpacity(self.LockTextColor)
  else
    self.Img_Lock:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Txt_DifficultName:SetColorAndOpacity(self.UnLockTextColor)
  end
end
function WBP_SingleDifficultItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_SingleDifficultItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_SingleDifficultItem_C
