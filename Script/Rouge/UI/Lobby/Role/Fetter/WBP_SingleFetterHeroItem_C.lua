local rapidjson = require("rapidjson")
local WBP_SingleFetterHeroItem_C = UnLua.Class()

function WBP_SingleFetterHeroItem_C:Show(HeroId, MainHeroId)
  self.HeroId = HeroId
  self.MainHeroId = MainHeroId
  self:InitStatusImgVis()
  local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
  if RowInfo then
    self.Txt_Name:SetText(RowInfo.Name)
  end
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self:RefreshItemStatus()
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroInfoUpdate, WBP_SingleFetterHeroItem_C.BindOnFetterHeroInfoUpdate)
end

function WBP_SingleFetterHeroItem_C:InitStatusImgVis()
  self.Img_Hover:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Dragging:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Equipped:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_SingleFetterHeroItem_C:RefreshItemStatus()
  self:UpdateDragStatusVis(false)
  self.Txt_Status:SetVisibility(UE.ESlateVisibility.Collapsed)
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(self.MainHeroId)
  self.Img_Equipped:SetVisibility(UE.ESlateVisibility.Collapsed)
  for i, SingleFetterHeroInfo in ipairs(FetterHeroInfo) do
    if SingleFetterHeroInfo.id == self.HeroId then
      self.Txt_Status:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Img_Equipped:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    end
  end
end

function WBP_SingleFetterHeroItem_C:Hide()
  self.HeroId = 0
  self.MainHeroId = 0
  self:RemoveFromParent()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_SingleFetterHeroItem_C.BindOnFetterHeroInfoUpdate, self)
end

function WBP_SingleFetterHeroItem_C:OnLeftMouseDown()
  EventSystem.Invoke(EventDef.Lobby.FetterHeroItemLeftClicked, self.HeroId)
end

function WBP_SingleFetterHeroItem_C:OnRightMouseDown()
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(self.MainHeroId)
  local Slot = 0
  local PosList = {}
  for i, SingleFetterHeroInfo in ipairs(FetterHeroInfo) do
    if SingleFetterHeroInfo.id == self.HeroId then
      HttpCommunication.Request("hero/unequipfetterhero", {
        slot = SingleFetterHeroInfo.slot,
        heroId = self.MainHeroId
      }, {
        self,
        WBP_SingleFetterHeroItem_C.OnFetterHeroChangeSuccess
      }, {
        self,
        function()
        end
      })
      return
    end
    if 0 ~= SingleFetterHeroInfo.id then
      table.insert(PosList, SingleFetterHeroInfo.slot)
    end
  end
  local HeroInfo = DataMgr.GetMyHeroInfo()
  for i, SinglePosStatus in ipairs(HeroInfo.slots) do
    if not table.Contain(PosList, i) and SinglePosStatus == TableEnums.ENUMSlotStatus.Open then
      Slot = i
      break
    end
  end
  if 0 == Slot then
    print("\230\178\161\230\156\137\228\189\141\231\189\174\232\163\133\229\164\135\231\190\129\231\187\138\232\139\177\233\155\132")
    return
  end
  self:EquipFetterHeroByPos(Slot)
end

function WBP_SingleFetterHeroItem_C:EquipFetterHeroByPos(Slot)
  local Param = {
    heroId = self.MainHeroId,
    slot = Slot,
    fetterHeroId = self.HeroId
  }
  HttpCommunication.Request("hero/equipfetterhero", Param, {
    self,
    WBP_SingleFetterHeroItem_C.OnFetterHeroChangeSuccess
  }, {
    self,
    function()
    end
  })
end

function WBP_SingleFetterHeroItem_C:OnFetterHeroChangeSuccess(JsonResponse)
  LogicRole.RequestGetHeroFetterInfoToServer(self.MainHeroId, {
    self,
    self.OnGetHeroFetterInfoSuccess
  })
end

function WBP_SingleFetterHeroItem_C:BindOnFetterHeroInfoUpdate()
  self:RefreshItemStatus()
end

function WBP_SingleFetterHeroItem_C:OnGetHeroFetterInfoSuccess(JsonResponse)
  print("OnGetHeroFetterInfoSuccess", JsonResponse.Content)
  LogicRole.InitFetterHeroesMesh(self.MainHeroId)
end

function WBP_SingleFetterHeroItem_C:OnBeginDragNotify()
  EventSystem.Invoke(EventDef.Lobby.FetterHeroBeginOrEndDrag, true)
  self:UpdateDragStatusVis(true)
end

function WBP_SingleFetterHeroItem_C:UpdateDragStatusVis(IsDrag)
  self:UpdateHoverStatusVis(IsDrag)
  self.IsDrag = IsDrag
  if IsDrag then
    self.Img_Dragging:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.Img_Dragging:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_SingleFetterHeroItem_C:UpdateHoverStatusVis(IsHover)
  if IsHover then
    self.Img_Hover:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.Img_Hover:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_SingleFetterHeroItem_C:OnDragCancelled(PointerEvent, Operation)
  EventSystem.Invoke(EventDef.Lobby.FetterHeroBeginOrEndDrag, false)
  self:UpdateDragStatusVis(false)
end

function WBP_SingleFetterHeroItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self:UpdateHoverStatusVis(true)
end

function WBP_SingleFetterHeroItem_C:OnMouseLeave(MouseEvent)
  if not self.IsDrag then
    self:UpdateHoverStatusVis(false)
  end
end

return WBP_SingleFetterHeroItem_C
