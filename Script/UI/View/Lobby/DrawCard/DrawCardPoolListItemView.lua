local DrawCardPoolListItemView = UnLua.Class()

function DrawCardPoolListItemView:Construct()
  self.Btn_Main.OnClicked:Add(self, self.OnCardPoolClicked)
  self.Btn_Main.OnHovered:Add(self, self.OnCardPoolHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.OnCardPoolUnhovered)
  EventSystem.AddListener(self, EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.BindOnChangeDrawCardPoolSelected)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateResourceInfo, self.BindOnResourceUpdate)
end

function DrawCardPoolListItemView:Destruct()
  self.ParentView = nil
  self.PoolInfo = nil
  self.PoolId = nil
  self.Btn_Main.OnClicked:Remove(self, self.OnCardPoolClicked)
  self.Btn_Main.OnHovered:Remove(self, self.OnCardPoolHovered)
  self.Btn_Main.OnUnhovered:Remove(self, self.OnCardPoolUnhovered)
  EventSystem.RemoveListener(EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.BindOnChangeDrawCardPoolSelected, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateResourceInfo, self.BindOnResourceUpdate, self)
end

function DrawCardPoolListItemView:InitInfo(ParentView, PoolId, PoolInfo)
  self.ParentView = ParentView
  self.PoolInfo = PoolInfo
  self.PoolId = PoolId
  self.Text_CardPoolName:SetText(self.PoolInfo.Name)
  UpdateVisibility(self.Canvas_Tag, tostring(self.PoolInfo.TagName) ~= "")
  self.Txt_TagName:SetText(self.PoolInfo.TagName)
  SetImageBrushByPath(self.Img_TagBg, self.PoolInfo.TagBgPath)
  SetImageBrushByPath(self.Img_Bg, self.PoolInfo.BgPath)
  self:BindOnResourceUpdate()
end

function DrawCardPoolListItemView:OnCardPoolClicked()
  EventSystem.Invoke(EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.PoolId)
end

function DrawCardPoolListItemView:OnCardPoolHovered()
  self.RGStateController_Hover:ChangeStatus("Hover")
end

function DrawCardPoolListItemView:OnCardPoolUnhovered()
  self.RGStateController_Hover:ChangeStatus("UnHover")
end

function DrawCardPoolListItemView:BindOnChangeDrawCardPoolSelected(PoolId)
  if self.PoolId == PoolId then
    self.RGStateController_Select:ChangeStatus("Select")
  else
    self.RGStateController_Select:ChangeStatus("UnSelect")
  end
end

function DrawCardPoolListItemView:BindOnResourceUpdate()
  local CostResId, CostNum, bIsEnough = UIModelMgr:Get("DrawCardViewModel"):GetCost(1, self.PoolId)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(CostResId)
  if not CurrencyInfo then
    print("not found CostResId", CostResId)
    return
  end
  if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
    self.Text_Count:SetText("x" .. DataMgr.GetOutsideCurrencyNumById(CostResId))
  else
    local Num = DataMgr.GetPackbackNumById(CostResId)
    self.Text_Count:SetText("x" .. Num)
  end
end

function DrawCardPoolListItemView:Hide()
  self:Setvisibility(UE.ESlateVisibility.Collapsed)
end

return DrawCardPoolListItemView
