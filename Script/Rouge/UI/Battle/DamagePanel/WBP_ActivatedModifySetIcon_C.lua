local WBP_ActivatedModifySetIcon_C = UnLua.Class()

function WBP_ActivatedModifySetIcon_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ActivatedModifySetIcon_C:InitInfo(SetId, Level)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ActivatedModifySetIcon_C:InitInfo not DTSubsystem")
    return nil
  end
  local Result, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(SetId, nil)
  if Result then
    SetImageBrushBySoftObject(self.Img_SetIcon, AttributeModifySetRow.SetIconWithBg)
  end
  self.Txt_Progress:SetText(string.format("%d/%d", Level, 6))
end

function WBP_ActivatedModifySetIcon_C:Hide()
  UpdateVisibility(self, false)
end

return WBP_ActivatedModifySetIcon_C
