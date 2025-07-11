local WBP_AttributeModifyRequestMsg_C = UnLua.Class()
function WBP_AttributeModifyRequestMsg_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_AttributeModifyRequestMsg_C:InitInfo(FromUserId, TargetUserId, AttributeModifyId)
  UpdateVisibility(self, true)
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  local FromPlayerInfo = RGTeamSubsystem:GetPlayerInfo(FromUserId)
  local TargetPlayerInfo = RGTeamSubsystem:GetPlayerInfo(TargetUserId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(AttributeModifyId, nil)
  local ResultItemRarity, ItemRarityRow = DTSubsystem:GetItemRarityTableRow(AttributeModifyRow.Rarity, nil)
  if tostring(FromUserId) ~= tostring(DataMgr.GetUserId()) then
    local OtherRequestTextFmt = NSLOCTEXT("WBP_AttributeModifyRequestMsg_C", "OtherRequestText", "<PlayerName>[{0}]</>\230\131\179\232\166\129\230\136\145\231\154\132<{1}>[{2}]</>")
    local OtherRequestText = UE.FTextFormat(OtherRequestTextFmt(), FromPlayerInfo.name, ItemRarityRow.AttributeModifyRichTextStyleName, AttributeModifyRow.Name)
    self.RGRichText:SetText(OtherRequestText)
  else
    local MyRequestTextFmt = NSLOCTEXT("WBP_AttributeModifyRequestMsg_C", "MyRequestText", "\230\136\145\230\131\179\232\166\129{0}\231\154\132<{1}>[{2}]</>")
    local MyRequestText = UE.FTextFormat(MyRequestTextFmt(), TargetPlayerInfo.name, ItemRarityRow.AttributeModifyRichTextStyleName, AttributeModifyRow.Name)
    self.RGRichText:SetText(MyRequestText)
  end
end
function WBP_AttributeModifyRequestMsg_C:Hide()
  UpdateVisibility(self, false)
end
return WBP_AttributeModifyRequestMsg_C
