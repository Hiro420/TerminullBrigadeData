local BattleRoleInfoConfig = require("GameConfig.BattleRoleInfo.BattleRoleInfoConfig")
local WBP_BattleRoleSkillItem_C = UnLua.Class()
function WBP_BattleRoleSkillItem_C:Construct()
  self.Btn_Main.OnHovered:Add(self, WBP_BattleRoleSkillItem_C.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, WBP_BattleRoleSkillItem_C.BindOnMainButtonUnhovered)
  self.WeaponSkillId = -1
  self.SkillGroupId = -1
  self.LuaSkillTypeToName = self.SkillTypeToName:ToTable()
end
function WBP_BattleRoleSkillItem_C:RefreshInfo(RowInfo)
  self.SkillGroupId = RowInfo.Group
  local SoftObjectReference = MakeStringToSoftObjectReference(RowInfo.IconPath)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjectReference) then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjectReference)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_Icon:SetBrush(Brush)
    end
  end
  self.Txt_describe:SetText(RowInfo.SimpleDesc)
  self.Txt_Name:SetText(RowInfo.Name)
  if not self.LuaSkillTypeToName then
    self.LuaSkillTypeToName = self.SkillTypeToName:ToTable()
  end
  local skillTypeName = self.LuaSkillTypeToName[RowInfo.Type]
  if skillTypeName then
    self.TextSkillType:SetText(skillTypeName)
    UpdateVisibility(self.TextSkillType, true)
  else
    UpdateVisibility(self.TextSkillType, false)
  end
  local kmKeyRowNameAry = BattleRoleInfoConfig.KMKeyRowNameMap[RowInfo.Type]
  local padKeyRowNameAry = BattleRoleInfoConfig.PadKeyRowNameMap[RowInfo.Type]
  self.WBP_CustomKeyName:SetCustomKeyDisplayInfoByRowNameAry(kmKeyRowNameAry, padKeyRowNameAry)
  if not table.IsEmpty(kmKeyRowNameAry) or not table.IsEmpty(padKeyRowNameAry) then
    UpdateVisibility(self.WBP_CustomKeyName, true)
  else
    UpdateVisibility(self.WBP_CustomKeyName, false)
  end
end
function WBP_BattleRoleSkillItem_C:BindOnMainButtonHovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local PixelPos, ViewPos = UE.USlateBlueprintLibrary.LocalToViewport(self, self.Img_Frame:GetCachedGeometry(), UE.FVector2D(0.0, 0.0), nil, nil)
  local bIsWeaponSkill = false
  local Id = self.SkillGroupId
  if self.WeaponSkillId > 0 then
    bIsWeaponSkill = true
    Id = self.WeaponSkillId
  end
  EventSystem.Invoke(EventDef.Lobby.RoleSkillTip, true, Id, self.Name, bIsWeaponSkill, self)
end
function WBP_BattleRoleSkillItem_C:BindOnMainButtonUnhovered()
  self.Img_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.Invoke(EventDef.Lobby.RoleSkillTip, false)
end
return WBP_BattleRoleSkillItem_C
