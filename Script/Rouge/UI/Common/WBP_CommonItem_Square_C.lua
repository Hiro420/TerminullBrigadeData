local WBP_CommonItem_Square_C = UnLua.Class()
function WBP_CommonItem_Square_C:InitCommonItem(Id, Num, bShowName, HoveredFunc, UnHoveredFunc, ClickFunc, IsInscription)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TotalResourceTable then
    return
  end
  self.Id = Id
  self.IsInscription = IsInscription
  UpdateVisibility(self.Text_Name, bShowName)
  if 0 ~= Num then
    self.WBP_Item:InitItem(self.Id, Num, IsInscription)
  else
    self.WBP_Item:InitItem(self.Id, nil, IsInscription)
  end
  if IsInscription then
    self.Text_Name:SetText(name)
  else
    local ItemInfo = TotalResourceTable[Id]
    if ItemInfo then
      self.Text_Name:SetText(ItemInfo.Name)
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
function WBP_CommonItem_Square_C:UpdateNumPanelVis(IsShow)
end
function WBP_CommonItem_Square_C:UpdateNum(InNum)
  self.Text_Num:SetText(InNum)
end
function WBP_CommonItem_Square_C:UpdateReceivedPanelVis(IsShow)
  UpdateVisibility(self.CanvasPanel_Received, IsShow)
end
function WBP_CommonItem_Square_C:SetQuality(Quality)
  local Re, Info = GetRowData(DT.DT_ItemRarity, Quality)
  if Re then
    UpdateVisibility(self.Img_Quality_4, true, false)
    self.Img_Quality_4:SetColorAndOpacity(Info.DisplayNameColor.SpecifiedColor)
  end
end
function WBP_CommonItem_Square_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_CommonItem_Square_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.HoveredFunc then
    self.HoveredFunc()
  end
end
function WBP_CommonItem_Square_C:OnMouseLeave(MyGeometry, MouseEvent)
  if self.UnHoveredFunc then
    self.UnHoveredFunc()
  end
end
function WBP_CommonItem_Square_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.ClickFunc then
    self.ClickFunc()
  end
end
function WBP_CommonItem_Square_C:GetToolTipWidget()
  if self.HoveredFunc then
    return nil
  end
  if self.HoveredTipWidget == nil or not self.HoveredTipWidget:IsValid() then
    self.HoveredTipWidget = GetItemDetailWidget()
  end
  self.HoveredTipWidget:InitCommonItemDetail(self.Id, self.IsInscription)
  return self.HoveredTipWidget
end
return WBP_CommonItem_Square_C
