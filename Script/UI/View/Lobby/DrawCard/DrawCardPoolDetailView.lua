local DrawCardPoolDetailView = UnLua.Class()
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Red = UE.FLinearColor(1.0, 0.0, 0.0, 1.0)
}
local GetAppearanceActor = function(self)
  if not UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
    local CameraActorList = UE.UGameplayStatics.GetAllActorsOfClass(self, self.AppearanceActorCls, nil)
    self.AppearanceActor = CameraActorList:Get(1)
  end
  return self.AppearanceActor
end

function DrawCardPoolDetailView:Construct()
  EventSystem.AddListener(self, EventDef.Heirloom.OnHeirloomSelectedItemChanged, self.BindOnHeirloomSelectedItemChanged)
  EventSystem.AddListener(self, EventDef.DrawCard.OnChangeDrawCardAppearanceActor, self.BindOnChangeDrawCardAppearanceActor)
end

function DrawCardPoolDetailView:Destruct()
  EventSystem.RemoveListener(EventDef.Heirloom.OnHeirloomSelectedItemChanged, self.BindOnHeirloomSelectedItemChanged, self)
  EventSystem.RemoveListener(EventDef.DrawCard.OnChangeDrawCardAppearanceActor, self.BindOnChangeDrawCardAppearanceActor, self)
  self.ParentView = nil
end

function DrawCardPoolDetailView:InitCardPoolInfo(PondId, ParentView)
  self.PondId = PondId
  self.ParentView = ParentView
  self:UpdateDrawCardItemList()
end

function DrawCardPoolDetailView:UpdateDrawCardItemList()
  local TotalRandomGiftTable = LuaTableMgr.GetLuaTableByName(TableNames.TBRandomGift)
  local TotalGachaPondTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGachaPond)
  local CardPoolGiftId = TotalGachaPondTable[self.PondId].RandomGiftId
  local CardPoolResources = TotalRandomGiftTable[CardPoolGiftId].Resources
  self.TileView_CardItemList:RecyleAllData()
  local TileViewAry = UE.TArray(UE.UObject)
  TileViewAry:Reserve(#CardPoolResources)
  for i, v in ipairs(CardPoolResources) do
    local DataObj = self.TileView_CardItemList:GetOrCreateDataObj()
    TileViewAry:Add(DataObj)
    DataObj.ResourceId = v.x
    DataObj.ParentView = self
  end
  self.TileView_CardItemList:SetRGListItems(TileViewAry, true, true)
  if #CardPoolResources > 0 then
    EventSystem.Invoke(EventDef.DrawCard.OnChangeDrawCardAppearanceActor, CardPoolResources[1].x)
  end
end

function DrawCardPoolDetailView:HideSelf()
  self:OnHide()
  EventSystem.Invoke(EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.PondId)
end

function DrawCardPoolDetailView:OnHide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ParentView = nil
  self.WBP_ComShowGoodsItem:Hide()
end

function DrawCardPoolDetailView:BindOnHeirloomSelectedItemChanged(ResourceId)
  if self.ParentView then
    self:UpdateAppearanceActorInfo(ResourceId)
  end
end

function DrawCardPoolDetailView:BindOnChangeDrawCardAppearanceActor(ResourceId)
  if self.ParentView then
    self:UpdateAppearanceActorInfo(ResourceId)
  end
end

function DrawCardPoolDetailView:UpdateAppearanceActorInfo(ResourceId)
  self.ResourceId = ResourceId
  self.WBP_SkinDetailsItem:ShowOrHideButtonPanel(false)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  self.WBP_SkinDetailsItem:UpdateDetailsView(ResourceId, self.ParentView.WBP_AppearanceMovieList, self)
  self.WBP_ComShowGoodsItem:ShowItem(ResourceId, true)
end

function DrawCardPoolDetailView:PlayAnimationIn()
  self:PlayAnimation(self.Ani_in)
end

function DrawCardPoolDetailView:SelectHeroSkin(HeroSkinResId, bUpdateMovie)
  local ResID = GetTbSkinRowNameBySkinID(HeroSkinResId)
  self.WBP_ComShowGoodsItem:InitCharacterSkin(ResID)
end

return DrawCardPoolDetailView
