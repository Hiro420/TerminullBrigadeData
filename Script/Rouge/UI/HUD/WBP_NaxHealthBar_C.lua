local WBP_NaxHealthBar_C = UnLua.Class()

function WBP_NaxHealthBar_C:Show()
  local Character = self:GetOwningPlayerPawn()
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  CoreComp:BindAttributeChanged(self.HealthAttribute, {
    self,
    self.BindOnHealthAttributeChanged
  })
  self:InitHealthSignPos()
  self:UpdateLowHealthVis()
end

function WBP_NaxHealthBar_C:BindOnHealthAttributeChanged(NewValue, OldValue)
  self:UpdateLowHealthVis()
end

function WBP_NaxHealthBar_C:InitHealthSignPos()
  local Character = self:GetOwningPlayerPawn()
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  local MainPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MainPanel)
  local SizeX = MainPanelSlot:GetSize().X
  local FirstSignSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Img_FirstSign)
  local SecondSignSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Img_SecondSign)
  local FirstSignPos = FirstSignSlot:GetPosition()
  FirstSignPos.X = SizeX * self.FirstHealthSignPercent
  FirstSignSlot:SetPosition(FirstSignPos)
  local SecondSignPos = SecondSignSlot:GetPosition()
  SecondSignPos.X = SizeX * self.SecondHealthSignPercent
  SecondSignSlot:SetPosition(SecondSignPos)
end

function WBP_NaxHealthBar_C:UpdateLowHealthVis()
  local Character = self:GetOwningPlayerPawn()
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  local CurHealth = CoreComp:GetHealth()
  UpdateVisibility(self.Img_OneHealthBottom, CurHealth <= self.LowHealthSign)
  UpdateVisibility(self.Img_OneHealthSign, CurHealth <= self.LowHealthSign)
end

function WBP_NaxHealthBar_C:Destruct()
  local Character = self:GetOwningPlayerPawn()
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  CoreComp:UnBindAttributeChanged(self.HealthAttribute, {
    self,
    self.BindOnHealthAttributeChanged
  })
end

return WBP_NaxHealthBar_C
