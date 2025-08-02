local WBP_Item_C = UnLua.Class()

function WBP_Item_C:Construct()
  if self.MainBtnOverride then
    self.MainBtnOverride.OnClicked:Add(self, self.OnMainButtonClicked)
    self.MainBtnOverride.OnHovered:Add(self, self.OnMainButtonHovered)
    self.MainBtnOverride.OnUnhovered:Add(self, self.OnMainButtonUnhovered)
  else
    self.MainBtn.OnClicked:Add(self, self.OnMainButtonClicked)
    self.MainBtn.OnHovered:Add(self, self.OnMainButtonHovered)
    self.MainBtn.OnUnhovered:Add(self, self.OnMainButtonUnhovered)
  end
end

function WBP_Item_C:Destruct()
  if self.MainBtnOverride then
    self.MainBtnOverride.OnClicked:Remove(self, self.OnMainButtonClicked)
    self.MainBtnOverride.OnHovered:Remove(self, self.OnMainButtonHovered)
    self.MainBtnOverride.OnUnhovered:Remove(self, self.OnMainButtonUnhovered)
  else
    self.MainBtn.OnClicked:Remove(self, self.OnMainButtonClicked)
    self.MainBtn.OnHovered:Remove(self, self.OnMainButtonHovered)
    self.MainBtn.OnUnhovered:Remove(self, self.OnMainButtonUnhovered)
  end
end

function WBP_Item_C:InitItem(ItemId, Num, IsInscription, bShowName)
  self:Init()
  self:InitItemProEff(ItemId)
  self.ItemId = ItemId
  UpdateVisibility(self.Text_Name_1, bShowName)
  UpdateVisibility(self.Overlay_SpecialTag, false)
  if self.Config and self.Config.InitFromLuaTable then
    local TableName = TableNames.TBGeneral
    if TableNames[self.Config.LuaTableName] then
      TableName = TableNames[self.Config.LuaTableName]
    end
    local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableName)
    if not TotalResourceTable then
      return
    end
    self.ItemInfo = TotalResourceTable[ItemId]
    if self.ItemInfo then
      SetImageBrushByPath(self.Img_Icon, self.ItemInfo.Icon)
      if bShowName then
        self.Text_Name_1:SetText(self.ItemInfo.Name)
      end
      if self.ItemInfo.Rare then
        self:SetQuality(self.ItemInfo.Rare)
      end
      if self.ItemInfo.SkinRarity then
        self:SetQuality(self.ItemInfo.SkinRarity)
      end
    end
  else
    local re, ItemInfo = GetRowData(DT.DT_Item, ItemId)
    if re then
      if bShowName then
        self.Text_Name_1:SetText(ItemInfo.Name)
      end
      SetImageBrushByPath(self.Img_Icon, ItemInfo.SpriteIcon)
      self:SetQuality(ItemInfo.ItemRarity)
    end
  end
  if IsInscription then
    local DA = GetLuaInscription(self.ItemId)
    local name = GetInscriptionName(self.ItemId)
    if bShowName then
      self.Text_Name_1:SetText(name)
    end
    SetImageBrushByPath(self.Img_Icon, DA.Icon)
    self:SetQuality(DA.Rarity)
  end
  if Num and Num > 0 then
    self.Text_Num:SetText(Num)
    UpdateVisibility(self.NumPanel, true)
  else
    UpdateVisibility(self.NumPanel, false)
  end
end

function WBP_Item_C:InitItemProEff(ItemID)
  local ItemId = tonumber(ItemID)
  if not ItemId then
    UpdateVisibility(self.AutoLoad_ComItemProEff, false)
    UpdateVisibility(self.AutoLoad_ComItemProEff_1, false)
    return
  end
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if not Result then
    UpdateVisibility(self.AutoLoad_ComItemProEff, false)
    UpdateVisibility(self.AutoLoad_ComItemProEff_1, false)
    return
  end
  if Row.ProEffType == TableEnums.ENUMResourceEffProType.NONE then
    UpdateVisibility(self.AutoLoad_ComItemProEff, false)
    UpdateVisibility(self.AutoLoad_ComItemProEff_1, false)
    return
  end
  UpdateVisibility(self.AutoLoad_ComItemProEff, true)
  self.AutoLoad_ComItemProEff.ChildWidget:InitComProEff(ItemId)
  UpdateVisibility(self.AutoLoad_ComItemProEff_1, true)
  self.AutoLoad_ComItemProEff_1.ChildWidget:InitComProEff(ItemId)
end

function WBP_Item_C:UpdateNum(InNum)
  self.Text_Num:SetText(InNum)
end

function WBP_Item_C:UpdateBrush(Icon)
  SetImageBrushBySoftObject(self.Img_Icon, Icon)
end

function WBP_Item_C:BindOnMainButtonClicked(Delegate, Target)
  self.OnClicked:Clear()
  if Target then
    self.OnClicked:Add(Target, Delegate)
  else
    self.OnClicked:Add(self, Delegate)
  end
end

function WBP_Item_C:BindOnMainButtonHovered(Delegate)
  self.OnHovered:Clear()
  self.OnHovered:Add(self, Delegate)
end

function WBP_Item_C:BindOnMainButtonUnHovered(Delegate)
  self.OnUnHovered:Clear()
  self.OnUnHovered:Add(self, Delegate)
end

function WBP_Item_C:SetSel(bSel)
  UpdateVisibility(self.Overlay_Sel, bSel)
end

function WBP_Item_C:SetLock(bLock)
  UpdateVisibility(self.Overlay_Lock, bLock)
end

function WBP_Item_C:SetMark(bMark)
  UpdateVisibility(self.Overlay_Mark, bMark)
end

function WBP_Item_C:SetOwn(bOwn)
  UpdateVisibility(self.Canvas_Own, bOwn)
end

function WBP_Item_C:SetDecompose(bDecompose, DecomposeNum, DecomposeId)
  UpdateVisibility(self.Canvas_Decompose, bDecompose)
  if bDecompose then
    self.WBP_Price_Decompose:SetPrice(DecomposeNum, DecomposeNum, DecomposeId)
  end
end

function WBP_Item_C:SetQuality(Quality)
  self.Rare = Quality
  if self.Config and self.Config.bUseQualityBg and self.Config.QualityBgConfig then
    local Image = self.Config.QualityBgConfig:Find(Quality)
    if Image then
      SetImageBrushBySoftObjectPath(self.Image_Bg, Image, self.Config.ItemSize, true)
    else
      print("\230\163\128\230\159\165DT_CommonItemStyle\228\184\173\229\147\129\232\180\168\232\131\140\230\153\175\233\133\141\231\189\174")
    end
  end
  local Re, Info = GetRowData(DT.DT_ItemRarity, Quality)
  if Re then
    UpdateVisibility(self.Img_Quality, true, false)
    self.Img_Quality:SetColorAndOpacity(Info.DisplayNameColor.SpecifiedColor)
  end
end

function WBP_Item_C:OnMainButtonClicked()
  self.OnClicked:Broadcast()
  PlaySound2DEffect(self.Config.ClickAkName, "WBP_Item_C OnMainButtonClicked")
end

function WBP_Item_C:OnMainButtonHovered()
  UpdateVisibility(self.Overlay_Hover, true)
  self.OnHovered:Broadcast()
  PlaySound2DEffect(self.Config.HoverAkName, "WBP_Item_C OnMainButtonHovered")
end

function WBP_Item_C:OnMainButtonUnhovered()
  UpdateVisibility(self.Overlay_Hover, false)
  self.OnUnHovered:Broadcast()
end

function WBP_Item_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_Item_C:GetToolTipWidget()
  if not self.TipsClass then
    return
  end
  local Widget = GetTips(self.ItemId, self.TipsClass)
  if Widget and Widget.ShowExpireAt and self.expireAt and self.expireAt ~= "" then
    Widget:ShowExpireAt(self.expireAt)
  end
  return Widget
end

function WBP_Item_C:UpdateReceivedPanelVis(IsShow)
  UpdateVisibility(self.CanvasPanel_Received, IsShow)
end

function WBP_Item_C:ShowOrHideLoopAnimWidget(IsShow)
  UpdateVisibility(self.WBP_RGMaskWidget_loop, IsShow)
  UpdateVisibility(self.CanvasPanel_loop, IsShow)
end

function WBP_Item_C:SetTargetExpirationTime(expireAt)
  self.expireAt = expireAt
  self.WBP_CommonCountdown:SetItemId(self.ItemId)
  if nil == expireAt or "" == expireAt then
    UpdateVisibility(self.Overlay_Countdown, false)
    self.WBP_CommonCountdown:SetTargetTimestamp(nil)
    return
  end
  if tonumber(expireAt) > 0 then
    UpdateVisibility(self.Overlay_Countdown, true)
    self.WBP_CommonCountdown:SetTargetTimestamp(tonumber(expireAt))
  else
    UpdateVisibility(self.Overlay_Countdown, false)
    self.WBP_CommonCountdown:SetTargetTimestamp(nil)
  end
end

function WBP_Item_C:SetTargetTimestampById(Id, resourceID)
  if nil ~= Id and Id > 0 then
    UpdateVisibility(self.Overlay_Countdown, true)
    self.WBP_CommonCountdown:SetTargetTimestampById(Id, resourceID)
  else
    UpdateVisibility(self.Overlay_Countdown, false)
  end
end

function WBP_Item_C:ShowSpecialTag(ItemId, expireAt)
  local TableName = TableNames.TBGeneral
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableName)
  if not TotalResourceTable then
    return
  end
  local ItemInfo = TotalResourceTable[ItemId]
  if not ItemInfo then
    return
  end
  local Type = ItemInfo.Type
  if Type == TableEnums.ENUMResourceType.HERO or Type == TableEnums.ENUMResourceType.Weapon then
    UpdateVisibility(self.NumPanel, false)
  end
  if 9 ~= Type and 10 ~= Type then
    return
  end
  UpdateVisibility(self.NumPanel, false)
  UpdateVisibility(self.Overlay_Countdown, false)
  UpdateVisibility(self.Overlay_SpecialTag, true)
  if nil == expireAt or "" == expireAt or tonumber(expireAt) <= 0 then
    UpdateVisibility(self.Image_Time, false)
  else
    UpdateVisibility(self.Image_Time, true)
  end
  if 9 == Type then
    self.ShowTag:SetText(self.WeaponSkinText)
  else
    self.ShowTag:SetText(self.CharacterSkinText)
  end
end

return WBP_Item_C
