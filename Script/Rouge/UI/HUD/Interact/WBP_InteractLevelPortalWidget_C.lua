local WBP_InteractLevelPortalWidget_C = UnLua.Class()
function WBP_InteractLevelPortalWidget_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_InteractLevelPortalWidget_C:Destruct()
  if self.AsyncLoadTipsImgHandleID and self.AsyncLoadTipsImgHandleID > 0 then
    UE.URGAssetManager.CancelAsyncLoad(self.AsyncLoadTipsImgHandleID)
    self.AsyncLoadTipsImgHandleID = nil
  end
end
function WBP_InteractLevelPortalWidget_C:UpdateInteractInfo(InteractTipRow, TargetActor)
  if not UE.RGUtil.IsUObjectValid(TargetActor) then
    return
  end
  self:InitInteractItem(TargetActor, InteractTipRow.Info)
end
function WBP_InteractLevelPortalWidget_C:InitInteractItem(TargetActor, Info)
  UpdateVisibility(self.CanvasPanelRoot, true)
  local Result, Row = GetRowData(DT.DT_WorldLevelPool, tostring(TargetActor:GetLevelId()))
  if Result then
    local LevelNameStr = Row.LevelName
    local TypeName = self.LevelTypeToName:Find(Row.LogicType)
    if TypeName then
      LevelNameStr = string.format("%s(%s)", LevelNameStr, TypeName)
    end
    self.RGTextLevelName:SetText(LevelNameStr)
    self.Txt_InteractTip:SetText(Info)
    if self.RGTextDesc then
      self.RGTextDesc:SetText(Row.LevelPortalDesc)
    end
    local IsBoss = Row.LevelType == UE.ERGLevelType.BossRoom
    UpdateVisibility(self.CanvasPanel_red, IsBoss)
    UpdateVisibility(self.CanvasPanel_purple, not IsBoss)
    local Bg = self.LevelTypeToBg:Find(Row.LogicType)
    if self.URGImageBg and Bg then
      if self.AsyncLoadTipsImgHandleID and self.AsyncLoadTipsImgHandleID > 0 then
        UE.URGAssetManager.CancelAsyncLoad(self.AsyncLoadTipsImgHandleID)
      end
      local Path = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(Bg)
      self.AsyncLoadTipsImgHandleID = UE.URGAssetManager.Lua_AsyncLoadAsset(Path, function(IconObj)
        self.AsyncLoadTipsImgHandleID = nil
        if IconObj then
          local x = 0
          local y = 0
          if Size then
            x = math.ceil(Size.X)
            y = math.ceil(Size.Y)
          end
          local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, x, y)
          if Brush then
            self.URGImageBg:SetBrush(Brush)
          end
        end
      end, function()
        print("Failid async load asset: ", Path)
        self.AsyncLoadTipsImgHandleID = nil
      end)
    end
    if self.Ani_in then
      self:PlayAnimation(self.Ani_in)
    end
    if self.Ani_loop then
      self:PlayAnimation(self.Ani_loop, 0, 0)
    end
  end
end
function WBP_InteractLevelPortalWidget_C:HideWidget()
  UpdateVisibility(self.CanvasPanelRoot, false)
end
return WBP_InteractLevelPortalWidget_C
