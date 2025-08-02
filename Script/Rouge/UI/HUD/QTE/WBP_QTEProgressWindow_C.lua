local WBP_QTEProgressWindow_C = UnLua.Class()

function WBP_QTEProgressWindow_C:Construct()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  ListenObjectMessage(Character, GMP.MSG_Skill_QTE_OnQTEFailed, self, self.BindOnSkillQTEFailed)
  ListenObjectMessage(Character, GMP.MSG_Skill_QTE_OnQTESuccessful, self, self.BindOnSkillQTESuccessful)
  ListenObjectMessage(Character, GMP.MSG_Skill_QTE_OnQTEEnd, self, self.BindOnSkillQTEEnd)
end

function WBP_QTEProgressWindow_C:BindOnSkillQTEFailed(Index)
  print("WBP_QTEProgressWindow_C:BindOnSkillQTEFailed", Index)
  self:UpdateQTEProgressStatus(Index, false)
end

function WBP_QTEProgressWindow_C:BindOnSkillQTESuccessful(Index)
  print("WBP_QTEProgressWindow_C:BindOnSkillQTESuccessful", Index)
  self:UpdateQTEProgressStatus(Index, true)
end

function WBP_QTEProgressWindow_C:BindOnSkillQTEEnd()
  self:Hide()
end

function WBP_QTEProgressWindow_C:Show(ConfigData)
  UpdateVisibility(self, true)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayHideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.DelayHideTimer)
  end
  local Index = 1
  self.CurrentTime = 0
  self.TotalTime = 0
  local Item
  local MainPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MainPanel)
  local MainPanelSize = MainPanelSlot:GetSize()
  local SectionDataList = {}
  for key, SingleConfigData in pairs(ConfigData) do
    local TempTable = {}
    TempTable.StartTime = self.TotalTime + SingleConfigData.WaitWindowTime
    TempTable.EndTime = self.TotalTime + SingleConfigData.WaitWindowTime + SingleConfigData.QTEWindowTime
    table.insert(SectionDataList, TempTable)
    self.TotalTime = self.TotalTime + SingleConfigData.WaitWindowTime + SingleConfigData.QTEWindowTime
  end
  if self.TotalTime <= 0 then
    print("WBP_QTEProgressWindow_C:Show Total Time is 0")
    UpdateVisibility(self, false)
    return
  end
  self.StartTime = UE.UKismetSystemLibrary.GetGameTimeInSeconds(self)
  self.EndTime = UE.UKismetSystemLibrary.GetGameTimeInSeconds(self) + self.TotalTime
  local Slot
  local ItemSize = UE.FVector2D()
  ItemSize.Y = MainPanelSize.Y
  local ItemPosition = UE.FVector2D()
  ItemPosition.Y = 0
  for index, SingleData in ipairs(SectionDataList) do
    Item = self.QTESectionPanel:GetChildAt(Index - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.SingleQTESectionItemTemplate:StaticClass())
      self.QTESectionPanel:AddChild(Item)
    end
    Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
    ItemSize.X = (SingleData.EndTime - SingleData.StartTime) / self.TotalTime * MainPanelSize.X
    ItemPosition.X = SingleData.StartTime / self.TotalTime * MainPanelSize.X
    Slot:SetSize(ItemSize)
    Slot:SetPosition(ItemPosition)
    Item:Show(Index - 1)
    Index = Index + 1
  end
  HideOtherItem(self.QTESectionPanel, Index)
end

function WBP_QTEProgressWindow_C:UpdateQTEProgressStatus(Index, IsSuccess)
  local Item = self.QTESectionPanel:GetChildAt(Index)
  if Item then
    Item:UpdateStatus(IsSuccess)
  end
end

function WBP_QTEProgressWindow_C:HidePanel()
  UpdateVisibility(self, false)
end

function WBP_QTEProgressWindow_C:Hide()
  if 0.0 == self.DelayHideDuration then
    self:HidePanel()
  else
    self.DelayHideTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.HidePanel
    }, self.DelayHideDuration, false)
  end
end

function WBP_QTEProgressWindow_C:Destruct()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.DelayHideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.DelayHideTimer)
  end
  UnListenObjectMessage(GMP.MSG_Skill_QTE_OnQTESuccessful, self)
  UnListenObjectMessage(GMP.MSG_Skill_QTE_OnQTEFailed, self)
  UnListenObjectMessage(GMP.MSG_Skill_QTE_OnQTEEnd, self)
end

return WBP_QTEProgressWindow_C
