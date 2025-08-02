local WBP_Price_C = UnLua.Class()

function WBP_Price_C:Construct()
end

function WBP_Price_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateResourceInfo, self.BindOnResourceUpdate, self)
end

function WBP_Price_C:SetPrice(CurPrice, OldPrice, CurrencyId)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateResourceInfo, WBP_Price_C.BindOnResourceUpdate)
  self.Text_CurrentPrice:SetText(CurPrice)
  self.Text_OriginalPrice:SetText(OldPrice)
  if nil == CurrencyId then
    CurrencyId = 300001
  end
  self.CurrencyId = CurrencyId
  local IconInfo = LogicOutsidePackback.GetResourceInfoById(CurrencyId).Icon
  if IconInfo then
    SetImageBrushByPath(self.Image_Icon, IconInfo)
    if self.Image_Icon_1 then
      SetImageBrushByPath(self.Image_Icon_1, IconInfo)
    end
  end
  self.CurPrice = CurPrice
  self.OldPrice = OldPrice
  if self.Text_CurrentPrice_1 then
    self.Text_CurrentPrice_1:SetText(CurPrice)
  end
  if self.Text_OriginalPrice_1 then
    self.Text_OriginalPrice_1:SetText(OldPrice)
  end
  self:BindOnResourceUpdate()
end

function WBP_Price_C:BindOnResourceUpdate()
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(self.CurrencyId)
  if not CurrencyInfo then
    print("not found CurrencyId", self.CurrencyId)
  end
  local CurNum = 0
  if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
    CurNum = DataMgr.GetOutsideCurrencyNumById(self.CurrencyId)
  else
    CurNum = DataMgr.GetPackbackNumById(self.CurrencyId)
  end
  self.ShowColor = self.DefColor
  self.ShowFont = self.DefFont
  if CurNum < self.CurPrice then
    self.ShowColor = self.ErrorColor
    self.ShowFont = self.ErrorFont
  end
  self.Text_CurrentPrice:SetColorAndOpacity(self.ShowColor)
  self.Text_CurrentPrice:SetFont(self.ShowFont)
  UpdateVisibility(self.Text_OriginalPrice, self.CurPrice ~= self.OldPrice and self.CurPrice ~= nil)
  if self.Text_CurrentPrice_1 then
    self.Text_CurrentPrice_1:SetColorAndOpacity(self.ShowColor)
    self.Text_CurrentPrice_1:SetFont(self.ShowFont)
  end
  if self.Text_OriginalPrice_1 then
    UpdateVisibility(self.Text_OriginalPrice_1, self.CurPrice ~= self.OldPrice and self.CurPrice ~= nil)
  end
end

return WBP_Price_C
