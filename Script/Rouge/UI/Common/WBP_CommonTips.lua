local WBP_CommonTips = UnLua.Class()

function WBP_CommonTips:Construct()
end

function WBP_CommonTips:ShowTips(TxtTitle, TxtContent, Rare, SecondTitle, MediaObj, AwardList, ProEffType)
  UpdateVisibility(self, true)
  self:InitProEffByType(ProEffType)
  if SecondTitle then
    UpdateVisibility(self.RGTextSecondName, true)
    self.RGTextSecondName:SetText(SecondTitle)
  else
    UpdateVisibility(self.RGTextSecondName, false)
  end
  if TxtTitle then
    UpdateVisibility(self.RGTextName, true)
    self.RGTextName:SetText(TxtTitle)
  else
    UpdateVisibility(self.RGTextName, false)
  end
  if TxtContent then
    UpdateVisibility(self.RGRichTxt_Content, true)
    self.RGRichTxt_Content:SetText(TxtContent)
  else
    UpdateVisibility(self.RGRichTxt_Content, false)
  end
  if Rare then
    UpdateVisibility(self.Bg_Quality, true)
    UpdateVisibility(self.Bg_Quality_Normal, false)
    self.StateCtrl_Rare:ChangeStatus(Rare)
  else
    UpdateVisibility(self.Bg_Quality_Normal, true)
    UpdateVisibility(self.Bg_Quality, false)
  end
  self:UpdateMedia(MediaObj)
  self:ShowAwardList(AwardList)
end

function WBP_CommonTips:ShowAwardList(AwardList)
  if table.IsEmpty(AwardList) then
    UpdateVisibility(self.WrapBox_AwardList, false)
    return
  end
  UpdateVisibility(self.WrapBox_AwardList, true)
  for i, v in ipairs(AwardList) do
    local Item = GetOrCreateItem(self.WrapBox_AwardList, i, self.WBP_CommonTipsItem:GetClass())
    Item:SetRenderShear(self.AwardShear)
    Item.WBP_Item:InitItem(v.ItemID)
    Item.Txt_Num:SetText(v.Count)
    local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, v.ItemID)
    if result then
      Item.Txt_Name:SetText(row.Name)
      UpdateVisibility(Item.Txt_Name, true)
    else
      UpdateVisibility(Item.Txt_Name, false)
    end
  end
end

function WBP_CommonTips:ShowTipsByItemID(ItemID)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemID)
  if result then
    self:InitProEff(ItemID)
    local Name = row.Name
    local Desc = row.Desc
    local Rare = row.Rare
    local AwardList = {}
    if row.Type == TableEnums.ENUMResourceType.RandomGift then
      local resultGift, rowGift = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRandomGift, ItemID)
      if resultGift and rowGift.isShow then
        for i, v in ipairs(rowGift.Resources) do
          table.insert(AwardList, {
            ItemID = v.x,
            Count = v.y
          })
        end
      end
    elseif row.Type == TableEnums.ENUMResourceType.Gift then
      local resultGift, rowGift = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGift, ItemID)
      if resultGift and rowGift.isShow then
        for i, v in ipairs(rowGift.Resources) do
          table.insert(AwardList, {
            ItemID = v.key,
            Count = v.value
          })
        end
      end
    end
    self:ShowTips(Name, Desc, Rare, nil, nil, AwardList)
  end
end

function WBP_CommonTips:InitProEff(ItemID)
  local ItemId = tonumber(ItemID)
  if not ItemId then
    UpdateVisibility(self.AutoLoad_ComTipProEff, false)
    return
  end
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if not Result then
    UpdateVisibility(self.AutoLoad_ComTipProEff, false)
    return
  end
  if Row.ProEffType == TableEnums.ENUMResourceEffProType.NONE then
    UpdateVisibility(self.AutoLoad_ComTipProEff, false)
    return
  end
  UpdateVisibility(self.AutoLoad_ComTipProEff, true)
  self.AutoLoad_ComTipProEff.ChildWidget:InitComProEff(ItemId)
end

function WBP_CommonTips:InitProEffByType(ProEffType)
  if not ProEffType or ProEffType == TableEnums.ENUMResourceEffProType.NONE then
    UpdateVisibility(self.AutoLoad_ComTipProEff, false)
    return
  end
  UpdateVisibility(self.AutoLoad_ComTipProEff, true)
  self.AutoLoad_ComTipProEff.ChildWidget:InitComProEffByProEffType(ProEffType)
end

function WBP_CommonTips:UpdateMedia(ObjRef)
  self.MediaPlayer:SetLooping(true)
  if ObjRef and UE.UKismetSystemLibrary.IsValidSoftObjectReference(ObjRef) then
    UpdateVisibility(self.Img_Movie, true)
    local Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ObjRef)
    if Obj and Obj:Cast(UE.UFileMediaSource) then
      self.MediaPlayer:OpenSource(Obj)
      self.MediaPlayer:Rewind()
    end
  else
    UpdateVisibility(self.Img_Movie, false)
  end
end

function WBP_CommonTips:HideTips()
  UpdateVisibility(self, false)
end

function WBP_CommonTips:Destruct(...)
end

function WBP_CommonTips:ShowCurrencyExpireAt(CurrencyTable)
  UpdateVisibility(self.ExpireAtList, #CurrencyTable > 0)
  UpdateVisibility(self.URGImage_68, false)
  local Index = 1
  for index, value in ipairs(CurrencyTable) do
    local Item = GetOrCreateItem(self.ExpireAtList, Index, self.WBP_CurrencyExpireAt:GetClass())
    Item:InitCurrencyExpireAt(value)
    UpdateVisibility(Item, value.expireAt ~= "0")
    UpdateVisibility(self.URGImage_68, value.expireAt ~= "0")
    Index = Index + 1
  end
  HideOtherItem(self.ExpireAtList, Index, true)
end

function WBP_CommonTips:ShowExpireAt(ExpireAt)
  UpdateVisibility(self.WBP_CommonExpireAt, nil ~= ExpireAt and "0" ~= ExpireAt and "" ~= ExpireAt)
  UpdateVisibility(self.URGImage_68, nil ~= ExpireAt and "0" ~= ExpireAt and "" ~= ExpireAt)
  self.WBP_CommonExpireAt:InitCommonExpireAt(ExpireAt)
end

return WBP_CommonTips
