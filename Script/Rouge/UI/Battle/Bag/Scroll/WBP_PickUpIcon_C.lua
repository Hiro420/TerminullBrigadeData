local WBP_PickUpIcon_C = UnLua.Class()

function WBP_PickUpIcon_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_PickUpIcon_C:InitPickUpIcon(AttributeModifyId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_PickUpIcon_C:InitScrollItem not DTSubsystem")
    return nil
  end
  local Result, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(AttributeModifyId, nil)
  if Result then
    local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(AttributeModifyRow.Rarity, nil)
    if ResultItemRarity then
      local FrameSprite = self.RarityFrameMap:Find(AttributeModifyRow.Rarity)
      SetImageBrushBySoftObject(self.URGImageRarityFrame, FrameSprite)
      self.URGImageRarityBg:SetColorAndOpacity(ItemRarityRow.AttributeModifyRareBgColor)
    end
  end
end

function WBP_PickUpIcon_C:Destruct()
  self.Overridden.Destruct(self)
end

return WBP_PickUpIcon_C
