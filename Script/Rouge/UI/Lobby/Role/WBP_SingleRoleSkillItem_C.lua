local WBP_SingleRoleSkillItem_C = UnLua.Class()
function WBP_SingleRoleSkillItem_C:Construct()
  self.Btn_Main.OnHovered:Add(self, WBP_SingleRoleSkillItem_C.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, WBP_SingleRoleSkillItem_C.BindOnMainButtonUnhovered)
  self.WeaponSkillId = -1
  self.SkillGroupId = -1
  self:InputTypeChanged()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Add(self, self.InputTypeChanged)
  end
end
function WBP_SingleRoleSkillItem_C:Destruct()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.InputTypeChanged)
  end
end
function WBP_SingleRoleSkillItem_C:InputTypeChanged()
  if not self.KMKeyRowNameList:IsValidIndex(1) then
    self.Txt_Name:SetText(self.Name)
    UpdateVisibility(self.Txt_Name, true)
    UpdateVisibility(self.Img_Bottom, true)
    UpdateVisibility(self.WBP_CustomKeyName, false)
  else
    UpdateVisibility(self.Txt_Name, false)
    UpdateVisibility(self.Img_Bottom, false)
    UpdateVisibility(self.WBP_CustomKeyName, true)
    self.WBP_CustomKeyName:SetCustomKeyDisplayInfoByRowNameAry(self.KMKeyRowNameList:ToTable(), self.PadKeyRowNameList:ToTable())
  end
end
function WBP_SingleRoleSkillItem_C:RefreshInfo(RowInfo)
  self.SkillGroupId = RowInfo.Group
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  SetImageBrushByPath(self.Img_Icon_Straight, RowInfo.IconPath, self.IconSize)
  SetImageBrushByPath(self.Img_Icon_Reverse, RowInfo.IconPath, self.IconSize)
  SetImageBrushBySoftObject(self.Img_Frame, self.BottomBrush)
  self:UpdateStyle()
  self.Img_Frame:SetColorAndOpacity(self.BottomColorAndOpacity)
  self:PlayAnimationForward(self.Ani_in)
end
function WBP_SingleRoleSkillItem_C:BindOnMainButtonHovered()
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local PixelPos, ViewPos = UE.USlateBlueprintLibrary.LocalToViewport(self, self.Img_Frame:GetCachedGeometry(), UE.FVector2D(0.0, 0.0), nil, nil)
  local bIsWeaponSkill = false
  local Id = self.SkillGroupId
  if self.WeaponSkillId > 0 then
    bIsWeaponSkill = true
    Id = self.WeaponSkillId
  end
  local bIsGamePad = GetCurInputType() == UE.ECommonInputType.Gamepad
  local inputNameAry = self.KMKeyRowNameList:ToTable()
  local inputNameAryPad = self.PadKeyRowNameList:ToTable()
  EventSystem.Invoke(EventDef.Lobby.RoleSkillTip, true, Id, self.Name, inputNameAry, inputNameAryPad, self)
end
function WBP_SingleRoleSkillItem_C:BindOnMainButtonUnhovered()
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  EventSystem.Invoke(EventDef.Lobby.RoleSkillTip, false)
end
return WBP_SingleRoleSkillItem_C
