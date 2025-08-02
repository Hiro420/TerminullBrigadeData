local WBP_ScrollPickUpAttributeIcon_C = UnLua.Class()

function WBP_ScrollPickUpAttributeIcon_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ScrollPickUpAttributeIcon_C:InitPickUpAttributeIcon(AttributeModifyId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollPickUpAttributeIcon_C:InitScrollItem not DTSubsystem")
    return nil
  end
  print("WBP_ScrollPickUpAttributeIcon_C:InitScrollItem AttributeModifyId:", AttributeModifyId)
  local Result, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(AttributeModifyId, nil)
  if Result then
    SetImageBrushBySoftObject(self.URGImageIcon, AttributeModifyRow.SpriteIcon)
    self.StateCtrl_Rare:ChangeStatus(tostring(AttributeModifyRow.Rarity))
  end
  self.URGImageIcon:SetRenderOpacity(1.0)
end

function WBP_ScrollPickUpAttributeIcon_C:Destruct()
  self.Overridden.Destruct(self)
end

return WBP_ScrollPickUpAttributeIcon_C
