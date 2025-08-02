local WBP_RGBeginnerGuidanceTaskTip_C = UnLua.Class()

function WBP_RGBeginnerGuidanceTaskTip_C:RefreshInfo(BeginnerGuidanceTipRowId, MissionId)
  self.BeginnerGuidanceTipRowId = BeginnerGuidanceTipRowId
  self.MissionId = MissionId
  if self:IsAnimationPlaying(self.Ani_out) then
    print("WBP_RGBeginnerGuidanceTaskTip_C:RefreshInfo \230\173\163\229\156\168\230\146\173\230\148\190\231\187\147\230\157\159\229\138\168\231\148\187\239\188\140\229\136\157\229\167\139\229\140\150\230\142\168\232\191\159")
    self.IsWaitInit = true
    return
  end
  if self:IsAnimationPlaying(self.Ani_in) then
    self:StopAnimation(self.Ani_in)
  end
  self:PlayAnimationForward(self.Ani_in)
  local Result, RowInfo = GetRowData(DT.DT_RGBeginnerGuidanceTip, BeginnerGuidanceTipRowId)
  if Result then
    self.Txt_Title:SetText(RowInfo.Title)
    local Text = ""
    if RowInfo.DescList[1] then
      Text = RowInfo.DescList[1]
    end
    self.Txt_Desc:SetText(Text)
  end
end

function WBP_RGBeginnerGuidanceTaskTip_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out and not self.IsInitiativeStop then
    if self.IsWaitInit then
      self:RefreshInfo(self.BeginnerGuidanceTipRowId)
    else
      self:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function WBP_RGBeginnerGuidanceTaskTip_C:Hide()
  self.IsWaitInit = false
  if self.Ani_out and self:IsAnimationPlaying(self.Ani_out) then
    self.IsInitiativeStop = true
    self:StopAnimation(self.Ani_out)
  end
  self.IsInitiativeStop = false
  if self.Ani_out then
    self:PlayAnimationForward(self.Ani_out)
  else
    UpdateVisibility(self, false)
  end
end

return WBP_RGBeginnerGuidanceTaskTip_C
