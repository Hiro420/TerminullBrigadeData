local WBP_DyingMark_C = UnLua.Class()
local DyingTimeTxt = NSLOCTEXT("WBP_DyingMark_C", "DyingTimeTxt", "\229\183\178\229\128\146\229\156\176{0}\230\172\161")
local DyingIdxTxt = NSLOCTEXT("WBP_DyingMark_C", "DyingIdxTxt", "\231\172\172{0}\230\172\161")
local SecTxt = NSLOCTEXT("WBP_DyingMark_C", "SecTxt", "{0}\231\167\146")
local RescueTxt = NSLOCTEXT("WBP_DyingMark_C", "RescueTxt", "\233\149\191\230\140\137 <keyname id=\"17\"/> \232\191\155\232\161\140\230\149\145\230\143\180")
local RescuingTxt = NSLOCTEXT("WBP_DyingMark_C", "RescuingTxt", "\230\173\163\229\156\168\230\149\145\230\143\180")

function WBP_DyingMark_C:Construct()
  self.Target = nil
  self.RGRichTextBlock_Interact:SetText(RescueTxt)
end

function WBP_DyingMark_C:InitNative()
  self.Overridden.InitNative(self)
  self.Ratio = 0
  UpdateVisibility(self.RGTextRescueTime, false)
  self:PlayAnimation(self.ani_DyingMark_in)
  self.WBP_DyingIconItem_Edge:PlayAnimation(self.WBP_DyingIconItem_Edge.ShowAni)
  self.WBP_DyingIconItem:PlayAnimation(self.WBP_DyingIconItem.ShowAni)
end

function WBP_DyingMark_C:OnCharacterDying(Character)
  self:ShowDyingInfo(true)
  if Character and Character:IsValid() then
    self.DyingCount = Character:GetDyingCount()
    local dyingIdx = UE.FTextFormat(DyingIdxTxt(), self.DyingCount)
    self.TextBlock_DyingCount:SetText(dyingIdx)
    local settings = UE.URGCharacterSettings.GetSettings()
    if settings and settings:IsValid() then
      self.RescueTotalTime = settings:GetRescueTotalTime(self.DyingCount)
    end
  end
end

function WBP_DyingMark_C:OnRescueRatioChange(Character, Ratio)
  if self.Target == Character then
    UpdateVisibility(self.RGTextRescueTime, false)
    local DyingCount = Character:GetDyingCount()
    local settings = UE.URGCharacterSettings.GetSettings()
    local RescueTotalTime = 0
    if settings and settings:IsValid() then
      RescueTotalTime = settings:GetRescueTotalTime(DyingCount)
    end
    local time = UE.UKismetMathLibrary.FCeil(RescueTotalTime - Ratio * RescueTotalTime)
    local secTxt = UE.FTextFormat(SecTxt(), time)
    self.RGTextRescueTime:SetText(secTxt)
    self.RGRichTextBlock_Interact:SetText(Ratio < self.Ratio and RescueTxt or RescuingTxt)
    self.Ratio = Ratio
  end
end

function WBP_DyingMark_C:ChangeState(bIsNear)
  if self.bIsNear ~= bIsNear then
    if bIsNear then
      self:StopAnimation(self.ani_leave)
      self:PlayAnimation(self.ani_near)
    else
      self:StopAnimation(self.ani_near)
      self:PlayAnimation(self.ani_leave)
    end
  end
  self.bIsNear = bIsNear
end

function WBP_DyingMark_C:ResetNative()
  self.Overridden.ResetNative(self)
  self.Target = nil
  self.RGRichTextBlock_Interact:SetText(RescueTxt)
  self.WBP_DyingIconItem_Edge:StopAnimation(self.WBP_DyingIconItem_Edge.Flushni)
  self.WBP_DyingIconItem:StopAnimation(self.WBP_DyingIconItem.Flushni)
  UpdateVisibility(self.VerticalBox_CloseToShow, false)
  self.bIsNear = nil
end

function WBP_DyingMark_C:LuaTick(InDeltaTime)
  if not self.Target then
    self.Target = UE.URGBlueprintLibrary.GetMarkInfoById(self, self:GetMarkID()).TargetActor
    if self.Target and self.Target:IsValid() then
      self.TargetRescueCom = self.Target:GetComponentByClass(UE.URGInteractComponent_Rescue:StaticClass())
      self.InteracHandle = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGCharacterInteractHandle:StaticClass())
      self.WBP_DyingIconItem.WBP_DyingMaterial.Target = self.Target
      self.WBP_DyingIconItem_Edge.WBP_DyingMaterial.Target = self.Target
      local nickName = self.Target:GetUserNickName()
      self.RGTextFunctional_NickNameEdge:SetText(nickName)
      self.RGTextFunctional_NickName:SetText(nickName)
      self.RGTextFunctional_NickNameClose:SetText(nickName)
      local dyingTime = UE.FTextFormat(DyingTimeTxt(), self.Target:GetDyingCount())
      self.RGTextFunctional_DyingTime:SetText(dyingTime)
    end
  end
  if self.CanvasPanelNormal:GetVisibility() == UE.ESlateVisibility.SelfHitTestInvisible then
    local CanInteract = self.TargetRescueCom:CanInteract(self.InteracHandle)
    if CanInteract then
      self.VerticalBox_CloseToHide:SetVisibility(UE.ESlateVisibility.Collapsed)
      UpdateVisibility(self.VerticalBox_CloseToShow, true)
      self.WBP_DyingIconItem.CloseRange = true
      self.WBP_DyingIconItem.Image_BackGround:SetVisibility(UE.ESlateVisibility.Hidden)
      local dyingTime = UE.FTextFormat(DyingTimeTxt(), self.Target:GetDyingCount())
      self.RGTextFunctional_DyingTime:SetText(dyingTime)
      self:ChangeState(true)
    else
      self.VerticalBox_CloseToHide:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      UpdateVisibility(self.VerticalBox_CloseToShow, true)
      self.WBP_DyingIconItem.CloseRange = false
      self.WBP_DyingIconItem.Image_BackGround:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:ChangeState(false)
    end
  end
end

return WBP_DyingMark_C
