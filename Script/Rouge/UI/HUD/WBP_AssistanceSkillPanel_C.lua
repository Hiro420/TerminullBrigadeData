local WBP_AssistanceSkillPanel_C = UnLua.Class()

function WBP_AssistanceSkillPanel_C:Construct()
  self.Overridden.Construct(self)
  EventSystem.AddListener(self, EventDef.GenericModify.OnAddModify, WBP_AssistanceSkillPanel_C.BindOnAddModify)
  self:InitAssistanceSkillInfo()
  local AllChildren = self.SkillFXPanel:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  ListenObjectMessage(nil, "World.Skill.AssistanceActivad", self, self.BindOnAssistanceActivated)
end

function WBP_AssistanceSkillPanel_C:BindOnAssistanceActivated(ActivatedActor)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if ActivatedActor == Character then
    self.VerticalPaintingPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    local AllChildren = self.SkillFXPanel:GetAllChildren()
    for key, SingleItem in pairs(AllChildren) do
      SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    local TargetPanel, TargetAnimWidget
    if 0 == self.GroupId then
      TargetPanel = self.BluePanel
      TargetAnimWidget = self.BlueSkillFX
    elseif 1 == self.GroupId then
      TargetPanel = self.RedPanel
      TargetAnimWidget = self.RedSkillFX
    elseif 5 == self.GroupId then
      TargetPanel = self.GreenPanel
      TargetAnimWidget = self.GreenSkillFX
    elseif 7 == self.GroupId then
      TargetPanel = self.PurplePanel
      TargetAnimWidget = self.PurpleSkillFX
    end
    if TargetPanel then
      TargetPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    end
    if TargetAnimWidget then
      TargetAnimWidget:PlayAnimationForward(TargetAnimWidget.ani_AssistanceSkillPanel)
    end
    self:PlayAnimationForward(self.ani_AssistanceSkillPanel)
  end
end

function WBP_AssistanceSkillPanel_C:InitAssistanceSkillInfo()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local ModifyComp = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not ModifyComp then
    return
  end
  local Result, ModifyParam = ModifyComp:TryGetModifyBySlot(UE.ERGGenericModifySlot.SLOT_Assistance, nil)
  if Result then
    self.AssistanceSkillCoolDown:InitInfo(ModifyParam.ModifyId)
  else
    self.AssistanceSkillCoolDown:InitInfo(0)
  end
  self.VerticalPaintingPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_AssistanceSkillPanel_C:BindOnAddModify(RGGenericModifyParam)
  local ModifyId = RGGenericModifyParam.ModifyId
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = DTSubsystem:GetGenericModifyDataByName(tostring(ModifyId), nil)
  if not Result then
    return
  end
  if RowInfo.Slot == UE.ERGGenericModifySlot.SLOT_Assistance then
    self.AssistanceSkillCoolDown:InitInfo(ModifyId)
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(RowInfo.VerticalPainting)
    if IconObj then
      self.Img_VerticalPainting:SetBrushResourceObject(IconObj)
    end
    self.GroupId = RowInfo.GroupId
    local BResult, GroupRowInfo = DTSubsystem:GetGenericModifyGroupDataByName(RowInfo.GroupId, nil)
    if BResult then
      local BGIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(GroupRowInfo.AssistanceBGIcon)
      if BGIconObj then
        self.Img_BG:SetBrushResourceObject(BGIconObj)
      end
    end
  end
end

function WBP_AssistanceSkillPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.GenericModify.OnAddModify, WBP_AssistanceSkillPanel_C.BindOnAddModify, self)
  UnListenObjectMessage("World.Skill.AssistanceActivad")
end

return WBP_AssistanceSkillPanel_C
