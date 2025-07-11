local TabList = {
  "ROLE",
  "MALL",
  "SEASON",
  "DRAW CARD",
  "TALENT",
  "ILLUSTRATED",
  "FRIENDS",
  "TASK"
}
local Duration = 0.5
local WBP_UITest_C = UnLua.Class()
function WBP_UITest_C:Construct()
  self.Overridden.Construct(self)
  self.Timer = Duration + 1
  self.BP_ButtonEsc.OnClicked:Add(self, self.EscContent)
end
function WBP_UITest_C:Destruct()
  self.RGToggleGroup.OnCheckStateChanged:Remove(self, self.OnCheckStateChanged)
  self.Overridden.Destruct(self)
end
function WBP_UITest_C:LuaTick(InDeltaTime)
  if self.Timer < Duration then
    local TitleSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.RGTextTitle)
    local PosY = UE.UKismetMathLibrary.FInterpTo(TitleSlot:GetPosition().Y, -208, InDeltaTime, 1 / Duration)
    TitleSlot:SetPosition(UE.FVector2D(TitleSlot:GetPosition().X, PosY))
    self.Timer = self.Timer + InDeltaTime
  end
end
function WBP_UITest_C:Init()
  self.RGToggleGroup:ClearGroup()
  self.ItemTab = {}
  local Cls = self.WBP_UITestToggle:GetClass()
  for i, v in ipairs(TabList) do
    local Item = GetOrCreateItem(self.ScrollBoxRoot, i, Cls)
    self.RGToggleGroup:AddToGroup(i, Item)
    Item.RGTextUnSelect:SetText(v)
    Item.RGTextSelect:SetText(v)
    self.ItemTab[i] = Item
  end
  self.RGToggleGroup.OnCheckStateChanged:Add(self, self.OnCheckStateChanged)
end
function WBP_UITest_C:OnCheckStateChanged(SelectId)
  if SelectId > 0 then
    UpdateVisibility(self.CanvasPanelDetails, true)
    self.RGTextTitle:SetText(TabList[SelectId])
    self.SelecItem = self.ItemTab[SelectId]
    local SelectItem = self.ItemTab[SelectId]
    local TitleSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.RGTextTitle)
    local GeometrySelectItem = SelectItem:GetCachedGeometry()
    local GeometryCanvasPanelDetails = self.CanvasPanelDetails:GetCachedGeometry()
    local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelDetails, GeometrySelectItem)
    TitleSlot:SetPosition(UE.FVector2D(TitleSlot:GetPosition().X, Pos.Y - 319))
    for k, v in pairs(self.RGToggleGroup.ToggleMap) do
      v:PlayAnimation(v.FadeOut)
      if SelectId == k then
        v:SetVisibility(UE.ESlateVisibility.Hidden)
      end
    end
    self.Timer = 0
  else
    self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_UITest_C:EscContent()
  self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.Hidden)
  UpdateVisibility(self.ScrollBoxRoot, true)
  for k, v in pairs(self.RGToggleGroup.ToggleMap) do
    v:PlayAnimationReverse(v.FadeOut, 4)
    UpdateVisibility(v, true)
  end
end
return WBP_UITest_C
