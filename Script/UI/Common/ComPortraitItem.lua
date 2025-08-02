local UnLua = _G.UnLua
local ComPortraitItem = UnLua.Class()

function ComPortraitItem:Construct()
  self.Overridden.Construct(self)
end

function ComPortraitItem:Destruct()
  self.Overridden.Destruct(self)
end

function ComPortraitItem:InitComPortraitItem(IconPath, EffectPath)
  SetImageBrushByPath(self.URGImageHeadIcon, IconPath)
  self:InitEffect(EffectPath)
end

function ComPortraitItem:InitComPortraitItemByPortraitID(PortraitID)
  local result, portraitRow = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPortrait, PortraitID)
  if result then
    SetImageBrushByPath(self.URGImageHeadIcon, portraitRow.portraitIconPath)
    self:InitEffect(portraitRow.EffectPath)
  end
end

function ComPortraitItem:InitComPortraitItemByBrush(Brush, EffectPath)
  self.URGImageHeadIcon:SetBrush(Brush)
  self:InitEffect(EffectPath)
end

function ComPortraitItem:InitEffect(EffectPath)
  local EffObj = self:GetOrCreateEffObj(EffectPath)
  if not EffObj then
    UpdateVisibility(self.CanvasPanelEffect, false)
  end
end

function ComPortraitItem:GetOrCreateEffObj(EffectPath)
  if table.IsEmpty(self.EffMap) then
    self.EffMap = {}
  end
  local Result, LeftS, RightS = UE.UKismetStringLibrary.Split(EffectPath, ".", nil, nil, UE.ESearchCase.IgnoreCase, UE.ESearchDir.FromEnd)
  if not Result then
    return nil
  end
  for i, v in pairs(self.EffMap) do
    if i ~= RightS then
      UpdateVisibility(v, false)
    end
  end
  if self.EffMap[RightS] then
    SetHitTestInvisible(self.CanvasPanelEffect)
    UpdateVisibility(self.EffMap[RightS], true)
    return self.EffMap[RightS]
  end
  local EffCls = UE.LoadClass(EffectPath)
  if EffCls then
    local EffObj = UE.UWidgetBlueprintLibrary.Create(self, EffCls)
    self.EffMap[RightS] = EffObj
    local EffCanvasSlot = self.CanvasPanelEffect:AddChildToCanvas(EffObj)
    SetHitTestInvisible(self.CanvasPanelEffect)
    if EffCanvasSlot then
      EffCanvasSlot:SetAnchors(UE.FAnchors(0, 0, 1, 1))
      EffCanvasSlot:SetPosition(UE.FVector2D(0))
      EffCanvasSlot:SetSize(UE.FVector2D(0))
    end
    return self.EffMap[RightS]
  else
    return nil
  end
end

return ComPortraitItem
