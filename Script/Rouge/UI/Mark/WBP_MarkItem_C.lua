local WBP_MarkItem_C = UnLua.Class()

function WBP_MarkItem_C:Show(MarkInfo)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.Ani_In, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  self.MarkInfo = MarkInfo
  self.MarkType = self:GetMarkType()
  self:SetItemStyle()
  self:UpdateCancelMarkPanelVis()
  if LogicHUD.UIWidget and LogicHUD.UIWidget:IsValid() then
    local CanvasSlot = LogicHUD.GetUIWidget():AddMarkItemToPanel(self)
    local Anchors = UE.FAnchors()
    Anchors.Minimum = UE.FVector2D(0.5, 0.5)
    Anchors.Maximum = UE.FVector2D(0.5, 0.5)
    CanvasSlot:SetAnchors(Anchors)
    CanvasSlot:SetAlignment(UE.FVector2D(0.5, 0.5))
    LogicHUD.UIWidget.OnOptimalMarkItemChanged:Add(self, WBP_MarkItem_C.BindOnOptimalMarkItemChanged)
  end
end

function WBP_MarkItem_C:BindOnOptimalMarkItemChanged()
  self:UpdateCancelMarkPanelVis()
end

function WBP_MarkItem_C:UpdateCancelMarkPanelVis()
  self.MarkCancelPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  local OptimalTargetInstanceId = LogicHUD.UIWidget:GetOptimalMarkInstanceId()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character and self:CanCancelMark() and OptimalTargetInstanceId == self.MarkInfo.InstanceId then
    self.MarkCancelPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function WBP_MarkItem_C:SetItemStyle()
  self:SetNormalStyle()
  self:SetEnemyStyle()
  self:SetInteractStyle()
end

function WBP_MarkItem_C:SetNormalStyle()
  if self.MarkType ~= UE.EMarkType.Normal then
    return
  end
  local MarkSettings = UE.URGMarkSettings.GetMarkSettings()
  if not MarkSettings then
    return
  end
  SetImageBrushBySoftObject(self.Img_Icon, MarkSettings.NormalIcon, self.IconSize)
  self:SetDefaultStyle()
end

function WBP_MarkItem_C:SetEnemyStyle()
  if self.MarkType ~= UE.EMarkType.Enemy then
    return
  end
  local MarkSettings = UE.URGMarkSettings.GetMarkSettings()
  if not MarkSettings then
    return
  end
  SetImageBrushBySoftObject(self.Img_Icon, MarkSettings.EnemyIcon, self.IconSize)
  if self.MarkInfo.TargetActor.IsEliteAI and self.MarkInfo.TargetActor:IsEliteAI() then
    SetImageBrushBySoftObject(self.Img_Icon, MarkSettings.EliteEnemyIcon, self.IconSize)
  end
  if 0 ~= self.MarkInfo.HitBoneIndex then
    SetImageBrushBySoftObject(self.Img_Icon, MarkSettings.BodyPartIcon, self.IconSize)
  end
  self:SetDefaultStyle()
end

function WBP_MarkItem_C:SetInteractStyle()
  if self.MarkType ~= UE.EMarkType.Interact then
    return
  end
  local MarkSettings = UE.URGMarkSettings.GetMarkSettings()
  if not MarkSettings then
    return
  end
  local MarkConfigComp = self.MarkInfo.TargetActor:GetComponentByClass(UE.URGMarkConfigComponent:StaticClass())
  if not MarkConfigComp then
    SetImageBrushBySoftObject(self.Img_Icon, MarkSettings.DefaultInteractIcon, self.IconSize)
    self:SetDefaultStyle()
    return
  end
  if not MarkConfigComp.IsUseCustomConfig then
    SetImageBrushBySoftObject(self.Img_Icon, MarkSettings.DefaultInteractIcon, self.IconSize)
    self:SetDefaultStyle()
    return
  end
  SetImageBrushBySoftObject(self.Img_Icon, MarkConfigComp.MarkIcon, self.IconSize)
  SetImageBrushBySoftObject(self.Img_Bottom, MarkConfigComp.MarkBottomIcon, self.BottomSize)
  self.Img_Bottom:SetColorAndOpacity(MarkSettings.MarkTypeBottomColorList:Find(self.MarkType))
  self.Img_Arrow:SetColorAndOpacity(MarkConfigComp.ArrowColor)
  self.StateCtrl_Eff:ChangeStatus(UE.EMarkType.None)
end

function WBP_MarkItem_C:SetDefaultStyle()
  local MarkSettings = UE.URGMarkSettings.GetMarkSettings()
  if not MarkSettings then
    return
  end
  SetImageBrushBySoftObject(self.Img_Bottom, MarkSettings.BottomList:Find(self.MarkType), self.BottomSize)
  self.Img_Bottom:SetColorAndOpacity(MarkSettings.MarkTypeBottomColorList:Find(self.MarkType))
  self.Img_Arrow:SetColorAndOpacity(MarkSettings.MarkTypeArrowColorList:Find(self.MarkType))
  self.StateCtrl_Eff:ChangeStatus(self.MarkType)
end

function WBP_MarkItem_C:IsValidMarkItem()
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return false
  end
  local MarkManager = GS:GetComponentByClass(UE.URGMarkManager:StaticClass())
  if not MarkManager then
    return false
  end
  return MarkManager.MarkList:Contains(self.MarkInfo)
end

function WBP_MarkItem_C:GetMarkType()
  return UE.URGMarkManager.GetMarkTypeByActor(self.MarkInfo.TargetActor)
end

function WBP_MarkItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.OwnPS = nil
  self.MarkInfo = nil
  if LogicHUD.UIWidget and LogicHUD.UIWidget:IsValid() then
    LogicHUD.UIWidget.OnOptimalMarkItemChanged:Remove(self, WBP_MarkItem_C.BindOnOptimalMarkItemChanged)
  end
end

function WBP_MarkItem_C:HidePanel()
  LogicMark.ListContainer:HideItem(self)
end

function WBP_MarkItem_C:IsShowInPanel()
  if not LogicMark.ListContainer then
    return false
  end
  local AllUseItems = LogicMark.ListContainer:GetAllUseWidgetsList()
  return table.Contain(AllUseItems, self)
end

return WBP_MarkItem_C
