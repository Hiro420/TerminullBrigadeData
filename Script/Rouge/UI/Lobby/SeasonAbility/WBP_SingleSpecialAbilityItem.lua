local WBP_SingleSpecialAbilityItem = UnLua.Class()
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")
function WBP_SingleSpecialAbilityItem:Show(RowInfo, Index)
  UpdateVisibility(self, true)
  self.RowInfo = RowInfo
  self.Index = Index
  self.Txt_Num:SetText(RowInfo.SpecialAbilityPointNum)
  local DA = GetLuaInscription(self.RowInfo.Inscription)
  SetImageBrushByPath(self.Img_Icon, DA.Icon)
  self:RefreshStatus()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.AnimInTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.AnimInTimer)
  end
  local AnimInDelayTime = self.InitInAnimDelayTime + self.InAnimInterval * self.Index
  if AnimInDelayTime > 0 then
    UpdateVisibility(self, false)
    self.AnimInTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function()
        UpdateVisibility(self, true)
        self:PlayAnimationForward(self.Ani_in)
      end
    }, AnimInDelayTime, false)
  else
    UpdateVisibility(self, true)
    self:PlayAnimationForward(self.Ani_in)
  end
end
function WBP_SingleSpecialAbilityItem:RefreshStatus(...)
  if not self.RowInfo then
    return
  end
  local Status = SeasonAbilityData:GetSpecialAbilityStatus(self.RowInfo.SpecialAbilityID)
  UpdateVisibility(self.LockPanel, Status == SpecialAbilityStatus.Lock)
  UpdateVisibility(self.CanReceivePanel, Status == SpecialAbilityStatus.UnLock)
  UpdateVisibility(self.Img_ReceivedBottom, Status == SpecialAbilityStatus.Activated)
  UpdateVisibility(self.Img_Bottom, Status ~= SpecialAbilityStatus.Activated)
end
function WBP_SingleSpecialAbilityItem:GetToolTipWidget(...)
  if not self.ToolTipWidget then
    local WidgetClass = GetAssetByPath("/Game/Rouge/UI/Lobby/SeasonAbility/WBP_SpecialAbilityTip.WBP_SpecialAbilityTip_C", true)
    self.ToolTipWidget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass)
  end
  self.ToolTipWidget:RefreshInfo(self.RowInfo.SpecialAbilityID)
  return self.ToolTipWidget
end
function WBP_SingleSpecialAbilityItem:OnMouseEnter(...)
  UpdateVisibility(self.HoverPanel, true)
  self:PlayAnimationForward(self.Ani_hover_in)
end
function WBP_SingleSpecialAbilityItem:OnMouseLeave(...)
  UpdateVisibility(self.HoverPanel, false)
  self:PlayAnimationForward(self.Ani_hover_out)
end
function WBP_SingleSpecialAbilityItem:OnMouseButtonDown(...)
  local Status = SeasonAbilityData:GetSpecialAbilityStatus(self.RowInfo.SpecialAbilityID)
  if Status == SpecialAbilityStatus.UnLock then
    SeasonAbilityHandler:RequestActivateSpecialAbilityToServer(self.RowInfo.SpecialAbilityID)
  end
end
function WBP_SingleSpecialAbilityItem:Hide(...)
  UpdateVisibility(self, false)
  self.RowInfo = nil
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.AnimInTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.AnimInTimer)
  end
end
function WBP_SingleSpecialAbilityItem:Destruct(...)
  self:Hide()
end
return WBP_SingleSpecialAbilityItem
