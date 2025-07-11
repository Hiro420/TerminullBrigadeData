local WBP_CommonItem_C = UnLua.Class()
function WBP_CommonItem_C:InitCommonItem(Id, Num, bShowName, HoveredFunc, UnHoveredFunc, ClickFunc, IsInscription)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TotalResourceTable then
    return
  end
  self.Id = Id
  self.IsInscription = IsInscription
  UpdateVisibility(self.Text_Num, 0 ~= Num)
  UpdateVisibility(self.Text_Name, bShowName)
  self.Text_Num:SetText(Num)
  if IsInscription then
    UpdateVisibility(self.Img_Quality_4, false)
    local DA = GetLuaInscription(self.Id)
    local name = GetInscriptionName(self.Id)
    self.Text_Name:SetText(name)
    SetImageBrushByPath(self.Img_Icon, DA.Icon)
    self:SetQuality(DA.Rarity)
  else
    local ItemInfo = TotalResourceTable[Id]
    if ItemInfo then
      SetImageBrushByPath(self.Img_Icon, ItemInfo.Icon)
      self.Text_Name:SetText(ItemInfo.Name)
      self:SetQuality(ItemInfo.Rare)
    end
  end
  if HoveredFunc then
    self.HoveredFunc = HoveredFunc
  end
  if UnHoveredFunc then
    self.UnHoveredFunc = UnHoveredFunc
  end
  self.ClickFunc = ClickFunc
end
function WBP_CommonItem_C:UpdateNumPanelVis(IsShow)
  UpdateVisibility(self.NumPanel, IsShow)
  UpdateVisibility(self.Text_Num, IsShow)
end
function WBP_CommonItem_C:UpdateNum(InNum)
  self.Text_Num:SetText(InNum)
end
function WBP_CommonItem_C:UpdateReceivedPanelVis(IsShow)
  UpdateVisibility(self.CanvasPanel_Received, IsShow)
end
function WBP_CommonItem_C:SetQuality(Quality)
  local Re, Info = GetRowData(DT.DT_ItemRarity, Quality)
  if Re then
    UpdateVisibility(self.Img_Quality_4, true, false)
    self.Img_Quality_4:SetColorAndOpacity(Info.DisplayNameColor.SpecifiedColor)
  end
end
function WBP_CommonItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_CommonItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.RGStateController_Hover then
    self.RGStateController_Hover:ChangeStatus("Hover")
  end
  if self.HoveredFunc then
    self.HoveredFunc()
  end
end
function WBP_CommonItem_C:OnMouseLeave(MyGeometry, MouseEvent)
  if self.RGStateController_Hover then
    self.RGStateController_Hover:ChangeStatus("UnHover")
  end
  if self.UnHoveredFunc then
    self.UnHoveredFunc()
  end
end
function WBP_CommonItem_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.ClickFunc then
    self.ClickFunc()
  end
end
function WBP_CommonItem_C:GetToolTipWidget()
  if self.HoveredFunc then
    return nil
  end
  if self.HoveredTipWidget == nil or not self.HoveredTipWidget:IsValid() then
    self.HoveredTipWidget = GetItemDetailWidget()
  end
  self.HoveredTipWidget:InitCommonItemDetail(self.Id, self.IsInscription)
  return self.HoveredTipWidget
end
return WBP_CommonItem_C
