local WBP_WaveWindowList_C = UnLua.Class()

function WBP_WaveWindowList_C:ShowWaveWindow(TargetWidget)
  if nil ~= TargetWidget then
    self.List:AddChild(TargetWidget)
    self.ItemIndex = self.ItemIndex + 1
    self.Items:Add(self.ItemIndex, TargetWidget)
    TargetWidget.Index = self.ItemIndex
    TargetWidget.DoOnce = false
    if self.ItemIndex - self.ItemLast >= 3 then
      if self.Items:Find(self.ItemLast) then
        self.Items:Find(self.ItemLast):K2_CloseWaveWindow()
      end
      self:PushUp()
    end
    TargetWidget:AddPadding(self.ItemHight * (self.ItemIndex - self.ItemLast), 0)
    TargetWidget.bOnlist = true
  end
end

function WBP_WaveWindowList_C:AddWaveWindow(TargetWidget)
  if TargetWidget then
    if self.WaitingShowList == nil then
      self.WaitingShowList = {}
    end
    table.insert(self.WaitingShowList, TargetWidget)
  end
end

function WBP_WaveWindowList_C:LuaTick(InDeltaTime)
  if table.count(self.WaitingShowList) >= 1 then
    if 5 == self.CountIndex then
      if self.WaitingShowList[1] ~= nil and UE.RGUtil.IsUObjectValid(self.WaitingShowList[1]) then
        self:ShowWaveWindow(self.WaitingShowList[1])
      end
      table.remove(self.WaitingShowList, 1)
      self.CountIndex = 1
    else
      self.CountIndex = self.CountIndex + 1
    end
  end
end

function WBP_WaveWindowList_C:PushUp()
  for index = self.ItemLast, self.ItemIndex - 1 do
    local OldTargetWidget = self.Items:Find(index)
    if OldTargetWidget then
      OldTargetWidget:AddPadding(self.ItemHight * -1, 40)
    end
  end
end

function WBP_WaveWindowList_C:Construct()
  self.ItemIndex = 0
  self.ItemLast = 1
  self.WaitingShowList = {}
  self.CountIndex = 1
end

function WBP_WaveWindowList_C:OnReset()
  self.List:ClearChildren()
  print("WBP_WaveWindowList_C:OnReset(")
end

return WBP_WaveWindowList_C
