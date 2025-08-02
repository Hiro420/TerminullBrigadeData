local WBP_SettlementResStoneItem_C = UnLua.Class()

function WBP_SettlementResStoneItem_C:Construct()
end

function WBP_SettlementResStoneItem_C:Destruct()
end

function WBP_SettlementResStoneItem_C:InitSettlementResStoneItem(resStoneIdParam, num, ParentView)
  UpdateVisibility(self, true, true)
  self.ParentView = ParentView
  local resStoneId = tonumber(resStoneIdParam)
  self.StoneId = resStoneId
  self.RGTextNum:SetText(num)
  local ToralResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if ToralResourceTable and ToralResourceTable[resStoneId] then
    local IconObj = UE.UObject.Load(ToralResourceTable[resStoneId].Icon)
    local BrushIconDraw = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.URGImageIcon:SetBrush(BrushIconDraw)
  end
end

function WBP_SettlementResStoneItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowResStoneTips(true, self.StoneId, self)
  end
end

function WBP_SettlementResStoneItem_C:OnMouseLeave(MyGeometry, MouseEvent)
  if UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowResStoneTips(false)
  end
end

function WBP_SettlementResStoneItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_SettlementResStoneItem_C
