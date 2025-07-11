local UnLua = _G.UnLua
local ComBannerItem = UnLua.Class()
function ComBannerItem:Construct()
  self.Overridden.Construct(self)
end
function ComBannerItem:Destruct()
  self.Overridden.Destruct(self)
end
function ComBannerItem:InitComBannerItem(IconPath, EffectPath)
  SetImageBrushByPath(self.URGImageBanner, IconPath)
  local EffObj = self:GetOrCreateEffObj(EffectPath)
  if not EffObj then
    UpdateVisibility(self.CanvasPanelEffect, false)
  end
end
function ComBannerItem:InitComBannerItemByBannerID(BannerID)
  local result, BannerRow = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBanner, BannerID)
  if result then
    self:InitComBannerItem(BannerRow.BannerIconPath, BannerRow.EffectPath)
  end
end
function ComBannerItem:GetOrCreateEffObj(EffectPath)
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
return ComBannerItem
