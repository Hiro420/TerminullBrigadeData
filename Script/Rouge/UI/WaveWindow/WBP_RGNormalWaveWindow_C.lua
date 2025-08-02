local WBP_RGNormalWaveWindow_C = UnLua.Class()

function WBP_RGNormalWaveWindow_C:Construct()
  self:BindToAnimationFinished(self.EndAnim, {
    self,
    WBP_RGNormalWaveWindow_C.BindOnEndAnimAnimFinished
  })
end

function WBP_RGNormalWaveWindow_C:BindOnEndAnimAnimFinished()
  local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if RGWaveWindowManager then
    self.bOnlist = false
    RGWaveWindowManager:CloseWaveWindow(self)
  end
end

function WBP_RGNormalWaveWindow_C:K2_CloseWaveWindow()
  if self.DoOnce then
    return
  end
  self.DoOnce = true
  local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  local WaveList = RGWaveWindowManager:GetWaveWindowList()
  if nil == WaveList then
    return
  end
  if nil == self.Index then
    self.Index = WaveList.ItemLast
  end
  if not UE.RGUtil.IsUObjectValid(self) then
    WaveList.Items:Remove(self.Index)
    return
  end
  self:PlayAnimation(self.EndAnim)
  if RGWaveWindowManager then
    if WaveList.ItemLast == self.Index then
      WaveList.ItemLast = self.Index + 1
      WaveList.Items:Remove(self.Index)
      for index = WaveList.ItemLast, WaveList.ItemIndex do
        local OldTargetWidget = WaveList.Items:Find(index)
        if nil ~= OldTargetWidget then
          OldTargetWidget:AddPadding(WaveList.ItemHight * -1, 40)
        end
      end
    else
      if nil == WaveList.Items:Find(WaveList.ItemLast) then
        WaveList.ItemLast = self.Index + 1
      end
      WaveList.Items:Remove(self.Index)
      for index = self.Index, WaveList.ItemIndex do
        local OldTargetWidget = WaveList.Items:Find(index)
        if nil ~= OldTargetWidget then
          OldTargetWidget:AddPadding(WaveList.ItemHight * -1, 40)
        end
      end
    end
  end
end

function WBP_RGNormalWaveWindow_C:AddPadding(ItemHight, Speed)
  if self.Slot then
    self.InterpSpeed = Speed
    self.TargetPadding = self.Slot.Padding
    self.TargetPadding.Top = self.TargetPadding.Top + ItemHight
  end
end

return WBP_RGNormalWaveWindow_C
