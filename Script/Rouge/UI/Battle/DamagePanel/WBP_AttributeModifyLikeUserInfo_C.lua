local WBP_AttributeModifyLikeUserInfo_C = UnLua.Class()
function WBP_AttributeModifyLikeUserInfo_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_AttributeModifyLikeUserInfo_C:InitInfo(UserId)
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  local PlayerInfo = RGTeamSubsystem:GetPlayerInfo(UserId)
  self.Txt_Name:SetText(PlayerInfo.name)
  local CharacterId = PlayerInfo.hero.id
  local CharacterInfo = LogicRole.GetCharacterTableRow(CharacterId)
  if not CharacterInfo then
    return
  end
  local SoftObjRef = MakeStringToSoftObjectReference(CharacterInfo.ActorIcon)
  if not UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
    return
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef):Cast(UE.UPaperSprite)
  if IconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.Img_Head:SetBrush(Brush)
  end
  UpdateVisibility(self, true)
end
function WBP_AttributeModifyLikeUserInfo_C:Hide()
  UpdateVisibility(self, false)
end
return WBP_AttributeModifyLikeUserInfo_C
