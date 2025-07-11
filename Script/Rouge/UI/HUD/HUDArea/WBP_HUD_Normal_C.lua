local WBP_HUD_Normal_C = UnLua.Class()
local LowHelalthValue = 60
function WBP_HUD_Normal_C:Init()
  EventSystem.AddListener(self, EventDef.GenericModify.OnAddModify, WBP_HUD_Normal_C.AddGenericModifyList)
  EventSystem.AddListener(self, EventDef.GenericModify.OnRemoveModify, WBP_HUD_Normal_C.UpdateGenericModifyList)
  EventSystem.AddListener(self, EventDef.GenericModify.OnUpgradeModify, WBP_HUD_Normal_C.UpdateGenericModifyList)
  EventSystem.AddListener(self, EventDef.SpecificModify.OnAddModify, WBP_HUD_Normal_C.AddSpecificModifyList)
  EventSystem.AddListener(self, EventDef.Battle.OnControlledPawnChanged, WBP_HUD_Normal_C.BindOnControlledPawnChanged)
  self:BindOnControlledPawnChanged()
  LogicHUD:RegistWidgetToManager(self.GenericModifyListPanel)
end
function WBP_HUD_Normal_C:UnInit()
  EventSystem.RemoveListener(EventDef.GenericModify.OnAddModify, WBP_HUD_Normal_C.AddGenericModifyList, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnRemoveModify, WBP_HUD_Normal_C.UpdateGenericModifyList, self)
  EventSystem.RemoveListener(EventDef.GenericModify.OnUpgradeModify, WBP_HUD_Normal_C.UpdateGenericModifyList, self)
  EventSystem.RemoveListener(EventDef.SpecificModify.OnAddModify, WBP_HUD_Normal_C.AddSpecificModifyList, self)
  EventSystem.RemoveListener(EventDef.Battle.OnControlledPawnChanged, WBP_HUD_Normal_C.BindOnControlledPawnChanged, self)
  LogicHUD:UnRegistWidgetToManager(self.GenericModifyListPanel)
end
function WBP_HUD_Normal_C:BindOnControlledPawnChanged()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    Character.AttributeModifyComponent.OnAddSet:Remove(self, self.OnSetAdd)
    Character.AttributeModifyComponent.OnChangeSet:Remove(self, self.OnSetChanged)
    Character.AttributeModifyComponent.OnRemoveSet:Remove(self, self.UpdateScrollSetList)
    Character.AttributeModifyComponent.OnAddSet:Add(self, self.OnSetAdd)
    Character.AttributeModifyComponent.OnChangeSet:Add(self, self.OnSetChanged)
    Character.AttributeModifyComponent.OnRemoveSet:Add(self, self.UpdateScrollSetList)
  end
  self:UpdateGenericModifyList()
end
function WBP_HUD_Normal_C:AddGenericModifyList(RGGenericModifyParam)
  if RGGenericModifyParam and LogicGenericModify:CheckIsPassiveModify(RGGenericModifyParam.ModifyId) then
    self.WBP_HUD_GenericModifyList:RefreshPassiveSlotSource(false)
  end
  self:UpdateGenericModifyList(RGGenericModifyParam)
end
function WBP_HUD_Normal_C:AddSpecificModifyList(RGSpecificModifyParam)
  LogicGenericModify:UpdateLastPassiveSlotStatus(ELastPassiveSlotStatus.bIsFromGenericModify)
  self:UpdateGenericModifyList(RGSpecificModifyParam)
end
function WBP_HUD_Normal_C:UpdateGenericModifyList(RGGenericModify)
  self.WBP_HUD_GenericModifyList:SelectClick(false, true)
end
function WBP_HUD_Normal_C:UpdateGenericModifyListShow(bIsShow)
  UpdateVisibility(self.WBP_HUD_GenericModifyList, bIsShow)
  self.WBP_HUD_GenericModifyList:SelectClick(false)
end
function WBP_HUD_Normal_C:UpdateScrollSetList()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    local Index = 1
    for i, v in iterator(Character.AttributeModifyComponent.ActivatedSets) do
      if Logic_Scroll:CheckSetIsActived(v) then
        local ScrollSetItem = GetOrCreateItem(self.ScrollBoxScrollSet, Index, self.WBP_HUD_ScrollSetItem:GetClass())
        ScrollSetItem:InitHudScrollSetItem(v)
        Index = Index + 1
      end
    end
    HideOtherItem(self.ScrollBoxScrollSet, Index)
  end
end
function WBP_HUD_Normal_C:UpdateScrollSetList()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and Character.AttributeModifyComponent then
    local Index = 1
    for i, v in iterator(Character.AttributeModifyComponent.ActivatedSets) do
      if Logic_Scroll:CheckSetIsActived(v) then
        local ScrollSetItem = GetOrCreateItem(self.ScrollBoxScrollSet, Index, self.WBP_HUD_ScrollSetItem:GetClass())
        ScrollSetItem:InitHudScrollSetItem(v)
        Index = Index + 1
      end
    end
    HideOtherItem(self.ScrollBoxScrollSet, Index)
  end
end
function WBP_HUD_Normal_C:OnSetAdd(SetData)
  self:UpdateScrollSetList()
end
function WBP_HUD_Normal_C:OnSetChanged(SetData, OldSetData)
  self:UpdateScrollSetList()
end
return WBP_HUD_Normal_C
