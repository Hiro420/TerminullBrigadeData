local HeirloomLevelItemView = UnLua.Class()
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
function HeirloomLevelItemView:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function HeirloomLevelItemView:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Heirloom.OnChangeHeirloomLevelSelected, self.HeirloomId, self.Level)
end
function HeirloomLevelItemView:BindOnMainButtonHovered()
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationForward(self.Ani_hover_in)
end
function HeirloomLevelItemView:BindOnMainButtonUnhovered()
  self:PlayAnimationForward(self.Ani_hover_out)
end
function HeirloomLevelItemView:OnAnimationFinished(Animation)
  if Animation == self.Ani_hover_out then
    self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  elseif Animation == self.Ani_unlock then
    self.UnLockEffectPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function HeirloomLevelItemView:Show(HeirloomId, Level)
  self.HeirloomId = HeirloomId
  self.Level = Level
  local HeirloomInfo = HeirloomData:GetHeirloomInfoByLevel(self.HeirloomId, self.Level)
  if not HeirloomInfo then
    print(string.format("HeirloomLevelItemView:Show not found RowInfo, HeirloomId: %d, Level: %d", HeirloomId, Level))
    return
  end
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(HeirloomId) .. "_" .. tostring(Level))
  self.IsUnLockStatus = HeirloomData:IsUnLockHeirloom(self.HeirloomId, self.Level)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.HoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.UnLockEffectPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  SetImageBrushByPath(self.Img_Icon, HeirloomInfo.IconPath)
  self:RefreshLockStatus()
  self:RefreshSelectedStatus()
end
function HeirloomLevelItemView:RefreshLockStatus()
  if HeirloomData:IsUnLockHeirloom(self.HeirloomId, self.Level) then
    self.Img_Lock:SetVisibility(UE.ESlateVisibility.Collapsed)
    if self.IsUnLockStatus ~= nil and not self.IsUnLockStatus then
      self.UnLockEffectPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAnimationForward(self.Ani_unlock)
      self.IsUnLockStatus = true
    end
    self.Img_Bottom:SetIsEnabled(true)
  else
    self.Img_Lock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Img_Bottom:SetIsEnabled(false)
  end
  self:UpdateItemColor()
end
function HeirloomLevelItemView:UpdateItemColor()
  if HeirloomData:IsUnLockHeirloom(self.HeirloomId, self.Level) then
    if self.IsSelected then
      self.Img_Bottom:SetColorAndOpacity(self.SelectedBottomColor)
      self.Img_Frame:SetColorAndOpacity(self.SelectedFrameColor)
      self.Img_Icon:SetColorAndOpacity(self.SelectedIconColor)
    else
      self.Img_Bottom:SetColorAndOpacity(self.NormalBottomColor)
      self.Img_Frame:SetColorAndOpacity(self.NormalFrameColor)
      self.Img_Icon:SetColorAndOpacity(self.NormalIconColor)
    end
  else
    self.Img_Bottom:SetColorAndOpacity(self.LockBottomColor)
    self.Img_Frame:SetColorAndOpacity(self.LockFrameColor)
    self.Img_Icon:SetColorAndOpacity(self.LockIconColor)
  end
end
function HeirloomLevelItemView:RefreshSelectedStatus()
  local CurSelectHeirloomId = HeirloomData:GetCurSelectHeirloomId()
  local CurSelectLevel = HeirloomData:GetCurSelectLevel()
  if self.HeirloomId == CurSelectHeirloomId and self.Level == CurSelectLevel then
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:SetRenderScale(self.SelectedScale)
    self.IsSelected = true
    self:UpdateItemColor()
    if HeirloomData:IsUnLockHeirloom(self.HeirloomId, self.Level) then
      self.Img_Dec:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Img_Dec:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  else
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:SetRenderScale(self.UnSelectedScale)
    self.IsSelected = false
    self:UpdateItemColor()
    self.Img_Dec:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function HeirloomLevelItemView:Hide()
  self:StopAllAnimations()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.HeirloomId = -1
  self.Level = -1
  self.IsUnLockStatus = nil
end
return HeirloomLevelItemView
