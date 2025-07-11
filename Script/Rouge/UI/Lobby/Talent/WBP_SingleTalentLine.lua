local WBP_SingleTalentLine = UnLua.Class()
local LineColor = {
  [UE.ETalentItemType.Live] = UE.FLinearColor(0.141263, 1.0, 0.651406, 1.0),
  [UE.ETalentItemType.Attack] = UE.FLinearColor(0.545725, 0.017642, 0.061246, 1.0),
  [UE.ETalentItemType.Resource] = UE.FLinearColor(0.005605, 0.366253, 1.0, 1.0)
}
function WBP_SingleTalentLine:Show(TalentId)
  if not TalentId then
    UpdateVisibility(self, false)
    print(string.format("WBP_SingleTalentLine:Show TalentId is nil! Index:%d, Type:%d", self.Index, self.Type))
    return
  end
  UpdateVisibility(self, true)
  self.TalentId = TalentId
  local TargetColor = LineColor[self.Type]
  if TargetColor then
    self.Progress_Line:SetColorAndOpacity(TargetColor)
  else
    print("WBP_SingleTalentLine:Show TargetColor is nil!", self.Type)
  end
  local MaterialLine = GetAssetBySoftObjectPtr(self.MaterialLineIcon, true)
  if MaterialLine then
    local DynamicMaterial = self.Img_PreLine:GetDynamicMaterial()
    if DynamicMaterial then
      DynamicMaterial:SetTextureParameterValue("renwu", MaterialLine)
    end
  end
  self:RefreshStatus()
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateCommonTalentInfo, self, self.BindOnUpdateCommonTalentInfo)
end
function WBP_SingleTalentLine:RefreshStatus(...)
  local CurLevel = LogicTalent.GetPreCommonTalentLevel(self.TalentId)
  local MaxLevel = LogicTalent.GetMaxLevelByTalentId(self.TalentId)
  local RealLevel = DataMgr.GetCommonTalentLevelById(self.TalentId)
  local GroupInfo = LogicTalent.GetTalentTableRow(self.TalentId)
  local MaxDisplayLevel = GroupInfo and GroupInfo[1] and GroupInfo[1].DisplayMaxLevel or 0
  if 0 ~= MaxDisplayLevel then
    MaxLevel = MaxDisplayLevel
  end
  UpdateVisibility(self.Progress_Line, CurLevel == RealLevel and CurLevel >= MaxLevel, false, true)
  UpdateVisibility(self.Img_PreLine, CurLevel ~= RealLevel and CurLevel >= MaxLevel)
end
function WBP_SingleTalentLine:BindOnUpdateCommonTalentInfo(...)
  self:RefreshStatus()
end
function WBP_SingleTalentLine:Hide(...)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateCommonTalentInfo, self, self.BindOnUpdateCommonTalentInfo)
end
function WBP_SingleTalentLine:Destruct(...)
  self:Hide()
end
return WBP_SingleTalentLine
