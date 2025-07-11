local WBP_RGQueueRewardWaveWindow = UnLua.Class()
function WBP_RGQueueRewardWaveWindow:SetWaveWindowParam(WaveWindowParamParam)
  self.Overridden.SetWaveWindowParam(self, WaveWindowParamParam)
  local idx = 1
  self.Timer = 0
  self.RewardItemIdx = 2
  self.RewardCount = WaveWindowParamParam.IntArray0:Num()
  for i, v in iterator(WaveWindowParamParam.IntArray0) do
    local item = GetOrCreateItem(self.ScrollBox_RewardList, i, self.WBP_ChipRewardItem:GetClass())
    item:InitQueueChipRewardItem(v)
    if 1 == i then
      item:Show()
    end
    idx = idx + 1
  end
  HideOtherItem(self.ScrollBox_RewardList, idx)
  self:PlayAnimation(self.Ani_in)
  local result, row = GetRowData(DT.DT_WaveWindow, 1205)
  if result then
    self.DelayPlayFadeOut = row.Duration - self.Ani_out:GetEndTime()
  end
  if not self.DelayPlayFadeOut or self.DelayPlayFadeOut <= 0 then
    self:PlayAnimation(self.Ani_out)
  end
end
function WBP_RGQueueRewardWaveWindow:LuaTick(InDeltaTime)
  self.Overridden.LuaTick(self, InDeltaTime)
  if self.DelayPlayFadeOut and self.DelayPlayFadeOut > 0 then
    self.DelayPlayFadeOut = self.DelayPlayFadeOut - InDeltaTime
    if self.DelayPlayFadeOut <= 0 then
      self:PlayAnimation(self.Ani_out)
    end
  end
  if self.RewardItemIdx >= self.RewardCount then
    return
  end
  if self.Timer >= self.ShowRewardItemInterval then
    self.Timer = 0
    local item = GetOrCreateItem(self.ScrollBox_RewardList, self.RewardItemIdx, self.WBP_ChipRewardItem:GetClass())
    if item then
      item:Show()
    end
    self.RewardItemIdx = self.RewardItemIdx + 1
  else
    self.Timer = self.Timer + InDeltaTime
  end
end
return WBP_RGQueueRewardWaveWindow
