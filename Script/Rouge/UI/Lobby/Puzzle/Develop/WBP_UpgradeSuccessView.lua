local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_UpgradeSuccessView = Class(ViewBase)
local PuzzleData = require("Modules.Puzzle.PuzzleData")
function WBP_UpgradeSuccessView:BindClickHandler()
end
function WBP_UpgradeSuccessView:UnBindClickHandler()
end
function WBP_UpgradeSuccessView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_UpgradeSuccessView:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_UpgradeSuccessView:OnShow(PuzzleId, OldLevel, OldDetailInfo)
  self:PlayAnimation(self.Ani_in)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.ListenForEscKeyPressed)
  self.Txt_CurLevel:SetText(OldLevel)
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
  self.Txt_TargetLevel:SetText(PackageInfo.level)
  local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
  local Result, PuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
  local Size = self.BoardItemSize
  local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_SingleHexItem)
  local Index = 1
  local Result, ShapeRowInfo = PuzzleData:GetPuzzleShapeRowInfo(PuzzleId)
  for k, SingleCoordinate in pairs(ShapeRowInfo.initPositions) do
    local Item = GetOrCreateItem(self.CanvasPanel_Puzzle, Index, self.WBP_SingleHexItem:StaticClass())
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
    if Slot then
      Slot:SetAnchors(TemplateSlot:GetAnchors())
      Slot:SetAlignment(TemplateSlot:GetAlignment())
      local PosX = 1.5 * Size.X * SingleCoordinate.key
      local PosY = Size.Y * (0 - (-SingleCoordinate.key - SingleCoordinate.value) + SingleCoordinate.value)
      Slot:SetPosition(UE.FVector2D(PosX, PosY))
      Slot:SetAutoSize(true)
    end
    Item:Show(PuzzleId, SingleCoordinate, ShapeRowInfo.initPositions)
    Item:UpdateEquipPanelVis(true)
    Item:ShowOrHideEquipAnimImage(true)
    UpdateVisibility(Item, true)
    Index = Index + 1
  end
  HideOtherItem(self.CanvasPanel_Puzzle, Index, true)
  if PuzzleResRowInfo.UpgradeSuccessOffsetAndScale[1] then
    local OffsetAndScale = PuzzleResRowInfo.UpgradeSuccessOffsetAndScale[1]
    self.CanvasPanel_Puzzle:SetRenderTranslation(UE.FVector2D(OffsetAndScale.x, OffsetAndScale.y))
    self.CanvasPanel_Puzzle:SetRenderScale(UE.FVector2D(OffsetAndScale.z, OffsetAndScale.z))
  else
    self.CanvasPanel_Puzzle:SetRenderTranslation(UE.FVector2D(0.0, 0.0))
    self.CanvasPanel_Puzzle:SetRenderScale(UE.FVector2D(1.0, 1.0))
  end
  local DetailInfo = PuzzleData:GetPuzzleDetailInfo(PuzzleId)
  local ChangedMainAttr = {}
  for Attr, Growth in pairs(DetailInfo.MainAttrGrowth) do
    if not OldDetailInfo.MainAttrGrowth[Attr] or OldDetailInfo.MainAttrGrowth[Attr] ~= Growth then
      local Temp = {
        OldGrowth = OldDetailInfo.MainAttrGrowth[Attr] or 0,
        NewGrowth = Growth
      }
      ChangedMainAttr[tonumber(Attr)] = Temp
    end
  end
  UpdateVisibility(self.Vertical_CoreAttribute, next(ChangedMainAttr) ~= nil)
  if next(ChangedMainAttr) ~= nil then
    local Index = 1
    for Attr, AttrGrowthInfo in pairs(ChangedMainAttr) do
      local Item = GetOrCreateItem(self.Vertical_CoreAttribute, Index, self.WBP_PuzzleCoreAttrListItem:StaticClass())
      for i, SingleAttrInfo in ipairs(PuzzleResRowInfo.MainAttr) do
        if SingleAttrInfo.key == Attr then
          Item.BottomColor = self.WBP_PuzzleCoreAttrListItem.BottomColor
          Item.DescTextColor = self.WBP_PuzzleCoreAttrListItem.DescTextColor
          Item.ArrowColor = self.WBP_PuzzleCoreAttrListItem.ArrowColor
          Item.ValueTextColor = self.WBP_PuzzleCoreAttrListItem.ValueTextColor
          Item:Show(Attr, SingleAttrInfo.value + AttrGrowthInfo.OldGrowth, SingleAttrInfo.value + AttrGrowthInfo.NewGrowth)
          Item:SetRenderShear(self.WBP_PuzzleCoreAttrListItem.RenderTransform.Shear)
          Index = Index + 1
          break
        end
      end
    end
    HideOtherItem(self.Vertical_CoreAttribute, Index, true)
  end
  local OldSubAttrInit = {}
  for i, AttrInfo in ipairs(OldDetailInfo.SubAttrInitV2) do
    OldSubAttrInit[AttrInfo.attrID] = AttrInfo.value
  end
  local SubAttrInit = {}
  for i, AttrInfo in ipairs(DetailInfo.SubAttrInitV2) do
    SubAttrInit[AttrInfo.attrID] = AttrInfo.value
  end
  local ChangedSubAttr = {}
  for Attr, Value in pairs(SubAttrInit) do
    if not OldSubAttrInit[Attr] then
      local Temp = {OldValue = 0, NewValue = Value}
      ChangedSubAttr[tonumber(Attr)] = Temp
    end
  end
  for Attr, Value in pairs(DetailInfo.SubAttrGrowth) do
    if not OldDetailInfo.SubAttrGrowth[Attr] or OldDetailInfo.SubAttrGrowth[Attr] ~= Value then
      local OldGrowth = OldDetailInfo.SubAttrGrowth[Attr] or 0
      local Temp = {
        OldValue = SubAttrInit[Attr] + OldGrowth,
        NewValue = SubAttrInit[Attr] + Value
      }
      ChangedSubAttr[Attr] = Temp
    end
  end
  UpdateVisibility(self.Vertical_SubAttribute, next(ChangedSubAttr) ~= nil)
  if next(ChangedSubAttr) ~= nil then
    local Index = 1
    for Attr, AttrInfo in pairs(ChangedSubAttr) do
      local Item = GetOrCreateItem(self.Vertical_SubAttribute, Index, self.WBP_PuzzleSubAttrListItem:StaticClass())
      local IsGodAttr = PuzzleData:IsGodSubAttr(PuzzleId, nil, Attr)
      Item:Show(Attr, AttrInfo.OldValue, AttrInfo.NewValue, IsGodAttr)
      Item:SetRenderShear(self.WBP_PuzzleSubAttrListItem.RenderTransform.Shear)
      Index = Index + 1
    end
    HideOtherItem(self.Vertical_SubAttribute, Index, true)
  end
end
function WBP_UpgradeSuccessView:ListenForEscKeyPressed(...)
  UIMgr:Hide(ViewID.UI_PuzzleUpgradeSuccess)
end
function WBP_UpgradeSuccessView:OnPreHide(...)
  local PuzzleDevelopView = UIMgr:GetLuaFromActiveView(ViewID.UI_PuzzleDevelop)
  if PuzzleDevelopView then
    PuzzleDevelopView:PlayUpgradeSuccessAnim()
  end
end
function WBP_UpgradeSuccessView:OnHide()
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.ListenForEscKeyPressed)
end
function WBP_UpgradeSuccessView:Destruct(...)
  self:OnHide()
end
return WBP_UpgradeSuccessView
