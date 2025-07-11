EFollowStatus = {
  UnFocusOn = 0,
  FocusOn = 1,
  PreFocusOn = 2
}
local WBP_FocusOnMarkWidget = UnLua.Class()
function WBP_FocusOnMarkWidget:Construct()
  local Player = self:GetOwningPlayerPawn()
  if Player then
    local RGGenericModifyComponent = Player:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
    if RGGenericModifyComponent then
      Logic_IllustratedGuide.CurFocusGenericModifySubGroup = RGGenericModifyComponent.FocusModifySubGroupList:ToTable()
      RGGenericModifyComponent.OnFocusModifySubGroupListChanged:Add(self, WBP_FocusOnMarkWidget.OnFocusModifySubGroupListChanged)
    end
  end
end
function WBP_FocusOnMarkWidget:Destruct()
end
function WBP_FocusOnMarkWidget:OnFocusModifySubGroupListChanged(SubGroupList)
  if self.ModifyId then
    self:Init(self.ModifyId)
  end
end
function WBP_FocusOnMarkWidget:Init(ModifyId)
  if GetCurSceneStatus() ~= UE.ESceneStatus.EBattle then
    self:SetFollowStatus(EFollowStatus.FocusOn)
    return EFollowStatus.UnFocusOn
  end
  self.ModifyId = ModifyId
  local Result = false
  local RowInfo = UE.FRGGenericModifyTableRow
  Result, RowInfo = GetRowData(DT.DT_GenericModify, ModifyId)
  if Result then
    for index, value in ipairs(Logic_IllustratedGuide.CurFocusGenericModifySubGroup) do
      if RowInfo.SubGroupId == value then
        self:SetFollowStatus(EFollowStatus.FocusOn)
        return EFollowStatus.FocusOn
      end
      for k, v in pairs(Logic_IllustratedGuide.GenericModifySubGroup[value]) do
        local FocusResult = false
        local FocusRowInfo = UE.FRGGenericModifyTableRow
        FocusResult, FocusRowInfo = GetRowData(DT.DT_GenericModify, v)
        for key1, FrontConditions in pairs(FocusRowInfo.FrontConditions:ToTable()) do
          for index, SubGroupId in ipairs(FrontConditions.SubGroupIds:ToTable()) do
            if RowInfo.SubGroupId == SubGroupId and not Logic_IllustratedGuide.MeetFrontCondition(FrontConditions) then
              self:SetFollowStatus(EFollowStatus.PreFocusOn)
              return EFollowStatus.PreFocusOn
            end
          end
        end
      end
    end
  end
  self:SetFollowStatus(EFollowStatus.UnFocusOn)
  return EFollowStatus.UnFocusOn
end
function WBP_FocusOnMarkWidget:SetFollowStatus(Status)
  self.FollowStatus = Status
  UpdateVisibility(self.Img_FocusOn, false)
  UpdateVisibility(self.Img_PerFocusOn, false)
  if Status == EFollowStatus.FocusOn then
    UpdateVisibility(self.Img_FocusOn, true)
  elseif EFollowStatus.PreFocusOn == Status then
    UpdateVisibility(self.Img_PerFocusOn, true)
  end
end
return WBP_FocusOnMarkWidget
