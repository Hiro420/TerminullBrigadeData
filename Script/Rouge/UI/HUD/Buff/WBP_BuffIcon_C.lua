local WBP_BuffIcon_C = UnLua.Class()
local ResourceMgr = require("Framework.Resource.ResourceMgr")
local BattleResPreloadConfig = require("GameConfig.Preload.BattleResPreloadConfig")

function WBP_BuffIcon_C:Show(BuffInfo, IsShowOmitIcon, OwningCharacter, ParentView)
  if nil == BuffInfo then
    return
  end
  self.BuffInfo.ID = BuffInfo.ID
  self.BuffInfo.CurrentCount = BuffInfo.CurrentCount
  self.BuffInfo.BuffData = BuffInfo.BuffData
  self.BuffInfo.Target = BuffInfo.Target
  self.BuffInfo.IsInscription = BuffInfo.IsInscription
  self.BuffInfo.StartTime = BuffInfo.StartTime
  self.BuffInfo.RemainTime = BuffInfo.RemainTime
  self.BuffInfo.Duration = BuffInfo.Duration
  self.IsShowOmitIcon = IsShowOmitIcon
  self.OwningCharacter = OwningCharacter
  self.ParentView = ParentView
  self:RefreshInfo()
  self:SetVisibility(UE.ESlateVisibility.Visible)
end

function WBP_BuffIcon_C:RefreshBuffInfo(InBuffInfo)
  self.BuffInfo.ID = InBuffInfo.ID
  self.BuffInfo.CurrentCount = InBuffInfo.CurrentCount
  self.BuffInfo.BuffData = InBuffInfo.BuffData
  self.BuffInfo.Target = InBuffInfo.Target
  self.BuffInfo.IsInscription = InBuffInfo.IsInscription
  self.BuffInfo.StartTime = InBuffInfo.StartTime
  self.BuffInfo.RemainTime = InBuffInfo.RemainTime
  self.BuffInfo.Duration = InBuffInfo.Duration
  self:RefreshInfo()
  self:PlayAnimation(self.Ani_CDComplete, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end

function WBP_BuffIcon_C:Hide()
  self:ResetBuffInfo()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ParentView = nil
  if self._asyncLoadBuffIconHandleID and self._asyncLoadBuffIconHandleID > 0 then
    UE.URGAssetManager.CancelAsyncLoad(self._asyncLoadBuffIconHandleID)
    self._asyncLoadBuffIconHandleID = nil
  end
end

function WBP_BuffIcon_C:UpdateBuffIconSize(Size)
  self.MainSizeBox:SetWidthOverride(Size)
  self.MainSizeBox:SetHeightOverride(Size)
end

function WBP_BuffIcon_C:RefreshInfo()
  if self.BuffInfo.IsInscription then
    self.EndTime = self.BuffInfo.StartTime + self.BuffInfo.RemainTime
    if self.IsShowOmitIcon then
      self.Txt_BuffName:SetText("...")
      self.Txt_BuffStackCount:SetText("")
    else
      local DataAssest = GetLuaInscription(self.BuffInfo.ID)
      if not DataAssest then
        return
      end
      self.Txt_BuffName:SetText(DataAssest.InscriptionCDData.CDName)
      self.Txt_BuffStackCount:SetText("")
      SetImageBrushByPath(self.Img_BuffIcon, DataAssest.InscriptionCDData.CDIcon)
      SetImageBrushByPath(self.Img_BuffIconProjection, DataAssest.InscriptionCDData.CDIcon)
      local FrameIcon = ResourceMgr.GetPreloadedResByPath(BattleResPreloadConfig.ICON_BUFF_FRAME)
      if FrameIcon then
        self.Img_BuffFrame:SetBrushResourceObject(FrameIcon)
      end
    end
  else
    if self.IsShowOmitIcon then
      self.Txt_BuffName:SetText("...")
    else
      self.Txt_BuffName:SetText(self.BuffInfo.BuffData.BuffName)
    end
    if self.OwningCharacter == nil then
      self.Txt_BuffStackCount:SetText(tostring(self.BuffInfo.CurrentCount))
    else
      local BuffComp = self.OwningCharacter:GetComponentByClass(UE.UBuffComponent)
      if not BuffComp then
        print("BuffComp is nil")
        return
      end
      local BuffStateViewType = BuffComp:GetViewTypeFromID(self.BuffInfo.ID)
      local switchFun = {
        [UE.EBuffStateViewType.None] = function()
          self.Txt_BuffStackCount:SetText("")
        end,
        [UE.EBuffStateViewType.Health] = function()
          local health = BuffComp:GetBuffCurrentHealth(self.BuffInfo.ID, self.OwningCharacter)
          self.Txt_BuffStackCount:SetText(tostring(health))
        end,
        [UE.EBuffStateViewType.BuffCount] = function()
          self.Txt_BuffStackCount:SetText(tostring(self.BuffInfo.CurrentCount))
        end,
        [UE.EBuffStateViewType.Both] = function()
          self.Txt_BuffStackCount:SetText(tostring(self.BuffInfo.CurrentCount))
        end
      }
      local fSwitchFun = switchFun[BuffStateViewType]
      fSwitchFun()
    end
    if self.BuffInfo.BuffData.BuffIcon then
      if self._asyncLoadBuffIconHandleID and self._asyncLoadBuffIconHandleID > 0 then
        UE.URGAssetManager.CancelAsyncLoad(self._asyncLoadBuffIconHandleID)
        self._asyncLoadBuffIconHandleID = nil
      end
      UpdateVisibility(self.Img_BuffIcon, false)
      UpdateVisibility(self.Img_BuffIconProjection, false)
      local BuffIconPath = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(self.BuffInfo.BuffData.BuffIcon)
      self._asyncLoadBuffIconHandleID = UE.URGAssetManager.Lua_AsyncLoadAsset(BuffIconPath, function(IconObj)
        self._asyncLoadBuffIconHandleID = nil
        UpdateVisibility(self.Img_BuffIcon, true)
        UpdateVisibility(self.Img_BuffIconProjection, true)
        if IconObj then
          self.Img_BuffIcon:SetBrushResourceObject(IconObj)
          self.Img_BuffIconProjection:SetBrushResourceObject(IconObj)
        end
      end, function()
        print("Failid async load asset: ", BuffIconPath)
        self._asyncLoadBuffIconHandleID = nil
      end)
    end
    if self.BuffInfo.BuffData.IsPositiveBuff then
      local FrameIcon = ResourceMgr.GetPreloadedResByPath(BattleResPreloadConfig.ICON_BUFF_FRAME)
      if FrameIcon then
        self.Img_BuffFrame:SetBrushResourceObject(FrameIcon)
      end
    else
      local FrameIcon = ResourceMgr.GetPreloadedResByPath(BattleResPreloadConfig.ICON_DEBUFF_FRAME)
      if FrameIcon then
        self.Img_BuffFrame:SetBrushResourceObject(FrameIcon)
      end
    end
  end
end

function WBP_BuffIcon_C:GetIconToolTipWidget()
  if self.IsShowOmitIcon then
    return nil
  end
  local Widget = UE.UWidgetBlueprintLibrary.Create(self, UE.UClass.Load("/Game/Rouge/UI/HUD/Buff/WBP_BuffToolTip.WBP_BuffToolTip_C"))
  Widget:InitInfo(self.BuffInfo)
  return Widget
end

function WBP_BuffIcon_C:SetIconRenderShear(NewRenderShear)
  if self.Img_BuffIcon then
    self.Img_BuffIcon:SetRenderShear(NewRenderShear)
  end
  if self.Img_BuffIconProjection then
    self.Img_BuffIconProjection:SetRenderShear(NewRenderShear)
  end
end

function WBP_BuffIcon_C:OnMouseEnter(MyGeometry, MouseEvent)
  if self.ParentView and self.ParentView.Hover then
    self.ParentView:HoverBuffTips(true, self.BuffInfo, self)
  end
end

function WBP_BuffIcon_C:OnMouseLeave(MyGeometry, MouseEvent)
  if self.ParentView and self.ParentView.Hover then
    self.ParentView:HoverBuffTips(false)
  end
end

function WBP_BuffIcon_C:Destruct()
  self:Hide()
end

return WBP_BuffIcon_C
