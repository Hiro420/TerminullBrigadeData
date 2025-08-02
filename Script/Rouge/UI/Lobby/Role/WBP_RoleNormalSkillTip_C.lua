local WBP_RoleNormalSkillTip_C = UnLua.Class()
local StrTxtFmt = NSLOCTEXT("WBP_RoleNormalSkillTip_C", "StrFmt", "\229\183\178\232\142\183\229\190\151[%s]%s\230\149\136\230\158\156")

function WBP_RoleNormalSkillTip_C:RefreshInfo(SkillGroupId, KeyName, GenericList, KeyInputNameAry, KeyInputNameAryPad)
  local SkillGroupInfo = LogicRole.GetSkillTableRow(SkillGroupId)
  if not SkillGroupInfo then
    print("not found skill group info,SkillGroupId:", SkillGroupId)
    return
  end
  local TargetSkillInfo = SkillGroupInfo[1]
  if not TargetSkillInfo then
    return
  end
  self.Txt_Name:SetText(TargetSkillInfo.Name)
  self.Txt_Desc:SetText(TargetSkillInfo.Desc)
  self.Txt_KeyName:SetText(KeyName)
  self.MediaPlayer:SetLooping(true)
  self:RefreshInscriptionExplainList(TargetSkillInfo.InscriptionExplainInfoList)
  local ObjRef = MakeStringToSoftObjectReference(TargetSkillInfo.VideoUrl)
  if ObjRef and UE.UKismetSystemLibrary.IsValidSoftObjectReference(ObjRef) then
    self.MoviePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ObjRef)
    if Obj and Obj:Cast(UE.UFileMediaSource) then
      self.MediaPlayer:OpenSource(Obj)
      self.MediaPlayer:Rewind()
    end
  else
    self.MoviePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if not table.IsEmpty(KeyInputNameAry) or not table.IsEmpty(KeyInputNameAryPad) then
    self.WBP_CustomKeyName:SetCustomKeyDisplayInfoByRowNameAry(KeyInputNameAry, KeyInputNameAryPad)
    UpdateVisibility(self.WBP_CustomKeyName, true)
  else
    UpdateVisibility(self.WBP_CustomKeyName, false)
  end
  if table.count(TargetSkillInfo.SkillDetailDesc) > 0 then
    self.SkillDetailPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local AllChildren = self.SkillDetailPanel:GetAllChildren()
    for key, SingleItem in pairs(AllChildren) do
      SingleItem:Hide()
    end
    for i, SingleSkillDetailDescInfo in ipairs(TargetSkillInfo.SkillDetailDesc) do
      local Item = self.SkillDetailPanel:GetChildAt(i - 1)
      if not Item then
        Item = UE.UWidgetBlueprintLibrary.Create(self, self.SkillDetailItemTemplate:StaticClass())
        self.SkillDetailPanel:AddChild(Item)
      end
      Item:Show(SingleSkillDetailDescInfo)
    end
  else
    self.SkillDetailPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if GenericList and #GenericList > 0 then
    UpdateVisibility(self.SizeBoxGenericModify, true)
    UpdateVisibility(self.ImageLine, true)
    UpdateVisibility(self.SpacerGeneric, true)
    local str = tostring(StrTxtFmt())
    for i, v in ipairs(GenericList) do
      if i == #GenericList then
        str = string.format(str, v.Name, "")
      else
        str = string.format(str, v.Name, "[%s]%s")
      end
      self.RGRichTextBlockGeneric:SetText(str)
    end
  else
    UpdateVisibility(self.SizeBoxGenericModify, false)
    UpdateVisibility(self.ImageLine, false)
    UpdateVisibility(self.SpacerGeneric, false)
  end
end

function WBP_RoleNormalSkillTip_C:RefreshInscriptionExplainList(ExplainInfoList)
  local TargetList
  self.IsShowRightlist = false
  if self.IsShowLeftExplainList then
    TargetList = self.LeftSkillInscriptionExplainList
  else
    TargetList = self.RightSkillInscriptionExplainList
  end
  if not ExplainInfoList or next(ExplainInfoList) == nil then
    UpdateVisibility(TargetList, false)
    return
  end
  self.IsShowRightlist = not self.IsShowLeftExplainList
  UpdateVisibility(TargetList, true)
  local Index = 1
  for index, SingleExplainInfo in ipairs(ExplainInfoList) do
    local Item = GetOrCreateItem(TargetList, Index, self.SkillInscriptionExplainItemTemplate:StaticClass())
    Item:Show(SingleExplainInfo)
    Index = Index + 1
  end
  HideOtherItem(TargetList, Index)
end

function WBP_RoleNormalSkillTip_C:RefreshInfoByWeaponSkillData(WeaponSkillData, KeyName, GenericList)
  self.Txt_Name:SetText(WeaponSkillData.SkillName)
  self.Txt_Desc:SetText(WeaponSkillData.Desc)
  self.Txt_KeyName:SetText(KeyName)
  self.MediaPlayer:SetLooping(true)
  self.MoviePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.SkillDetailPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:RefreshInscriptionExplainList()
  UpdateVisibility(self.WBP_CustomKeyName, false)
  if GenericList and #GenericList > 0 then
    UpdateVisibility(self.SizeBoxGenericModify, true)
    UpdateVisibility(self.ImageLine, true)
    UpdateVisibility(self.SpacerGeneric, true)
    local str = tostring(StrTxtFmt())
    for i, v in ipairs(GenericList) do
      if i == #GenericList then
        str = string.format(str, v.Name, "")
      else
        str = string.format(str, v.Name, "[%s]%s")
      end
      self.RGRichTextBlockGeneric:SetText(str)
    end
  else
    UpdateVisibility(self.SizeBoxGenericModify, false)
    UpdateVisibility(self.ImageLine, false)
    UpdateVisibility(self.SpacerGeneric, false)
  end
end

function WBP_RoleNormalSkillTip_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self.MediaPlayer:IsPlaying() then
    self.MediaPlayer:Close()
  end
end

return WBP_RoleNormalSkillTip_C
