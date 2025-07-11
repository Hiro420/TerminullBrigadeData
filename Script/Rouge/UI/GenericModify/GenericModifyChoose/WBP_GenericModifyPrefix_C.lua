local WBP_GenericModifyPrefix_C = UnLua.Class()
function WBP_GenericModifyPrefix_C:InitGenericModifyPrefix(ModifyId)
  local index = 0
  self.VerticalBox_34:ClearChildren()
  for index3, SubGroupId in ipairs(Logic_IllustratedGuide.CurFocusGenericModifySubGroup) do
    index = index + 1
    local SubModifyId = 0
    for key, value in pairs(Logic_IllustratedGuide.GenericModifySubGroup[SubGroupId]) do
      if 0 == SubModifyId or value < SubModifyId then
        SubModifyId = value
      end
    end
    local Result = false
    local RowInfo = UE.FRGGenericModifyTableRow
    Result, RowInfo = GetRowData(DT.DT_GenericModify, SubModifyId)
    if Result then
      for index1, FrontConditionSet in ipairs(RowInfo.FrontConditions:ToTable()) do
        for index2, FrontConditionSubGroupId in ipairs(FrontConditionSet.SubGroupIds:ToTable()) do
          if table.Contain(Logic_IllustratedGuide.GenericModifySubGroup[FrontConditionSubGroupId], tostring(ModifyId)) and not Logic_IllustratedGuide.MeetFrontCondition(FrontConditionSet) then
            local NoteItem = GetOrCreateItem(self.VerticalBox_34, index, self.WBP_GenericModifyPrefix_Item:GetClass())
            if 1 == index1 then
              UpdateVisibility(NoteItem.Prefix1, #RowInfo.FrontConditions:ToTable() >= 1)
              UpdateVisibility(NoteItem.Prefix2, #RowInfo.FrontConditions:ToTable() >= 2)
              UpdateVisibility(NoteItem.Image_Have, 1 == index1)
              UpdateVisibility(NoteItem.Image_NotHave, 1 ~= index1)
              if RowInfo.FrontConditions:Num() >= 2 and RowInfo.FrontConditions:Get(2) then
                UpdateVisibility(NoteItem.Image_Have_1, Logic_IllustratedGuide.MeetFrontCondition(RowInfo.FrontConditions:Get(2)))
                UpdateVisibility(NoteItem.Image_NotHave_1, not Logic_IllustratedGuide.MeetFrontCondition(RowInfo.FrontConditions:Get(2)))
              end
            else
              UpdateVisibility(NoteItem.Image_Have_1, 2 == index1)
              UpdateVisibility(NoteItem.Image_NotHave_1, 2 ~= index1)
              if RowInfo.FrontConditions:Get(1) then
                UpdateVisibility(NoteItem.Image_Have, Logic_IllustratedGuide.MeetFrontCondition(RowInfo.FrontConditions:Get(1)))
                UpdateVisibility(NoteItem.Image_NotHave, not Logic_IllustratedGuide.MeetFrontCondition(RowInfo.FrontConditions:Get(1)))
              end
            end
            local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
            if nil == logicCommandDataSubsystem then
              return
            end
            local OutSaveData = GetLuaInscription(RowInfo.Inscription)
            if OutSaveData then
              local name = GetInscriptionName(RowInfo.Inscription)
              NoteItem.TextName:SetText(name)
            end
          end
        end
      end
    end
  end
  HideOtherItem(self.VerticalBox_34, 2)
end
return WBP_GenericModifyPrefix_C
