local SkinData = require("Modules.Appearance.Skin.SkinData")
local WBP_OptionalGiftItem_C = UnLua.Class()

function WBP_OptionalGiftItem_C:Construct()
  EventSystem.AddListener(self, EventDef.Gift.OnOptionalGiftItemSelect, WBP_OptionalGiftItem_C.OnItemSelectionChanged)
  self.Btn_Add.OnClicked:Add(self, self.BindOnAddClicked)
  self.Btn_Cut.OnClicked:Add(self, self.BindOnCutClicked)
end

function WBP_OptionalGiftItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Gift.OnOptionalGiftItemSelect, WBP_OptionalGiftItem_C.OnItemSelectionChanged, self)
  self.Btn_Add.OnClicked:Clear()
  self.Btn_Cut.OnClicked:Clear()
end

function WBP_OptionalGiftItem_C:BindOnAddClicked()
  if self.bHave then
    ShowWaveWindow(self.WaveWindow_Have)
    print("\229\183\178\231\187\143\230\139\165\230\156\137")
    return
  end
  local SumNum = 0
  if self.SelItems == nil then
    self.SelItems = {}
  end
  for k, v in pairs(self.SelItems) do
    SumNum = SumNum + v
  end
  if SumNum >= self.Data.MaxNum and 1 ~= self.Data.MaxNum then
    ShowWaveWindow(self.WaveWindow_Max)
    print("\233\128\137\230\139\169\230\149\176\233\135\143\229\164\167\228\186\142\230\128\187\230\149\176")
    return
  end
  self.SelectNum = self.SelectNum + 1
  if self.SelectNum > self.Data.MaxNum then
    self.SelectNum = self.Data.MaxNum
  end
  self.SelNum:SetText(self.SelectNum)
  EventSystem.Invoke(EventDef.Gift.OnOptionalGiftItemSelect, self.Data.ResourcesIndex, self.SelectNum)
end

function WBP_OptionalGiftItem_C:BindOnCutClicked()
  self.SelectNum = self.SelectNum - 1
  if self.SelectNum < 0 then
    self.SelectNum = 0
  end
  self.SelNum:SetText(self.SelectNum)
  EventSystem.Invoke(EventDef.Gift.OnOptionalGiftItemSelect, self.Data.ResourcesIndex, self.SelectNum)
end

function WBP_OptionalGiftItem_C:OnListItemObjectSet(ItemObj)
  self.Data = ItemObj
  self.WBP_Item:InitItem(ItemObj.ResourcesId)
  self.WBP_Item.MainBtn.OnClicked:Clear()
  self.WBP_Item.MainBtn.OnClicked:Add(self, self.BindOnMainBtnClicked)
  self.Text_Num:SetText(ItemObj.ResourcesNum)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TBGeneral[ItemObj.ResourcesId] then
    return
  end
  local GeneralCopnfig = TBGeneral[ItemObj.ResourcesId]
  self.bHave = false
  if GeneralCopnfig.Type == TableEnums.ENUMResourceType.HeroSkin then
    if SkinData.FindHeroSkin(ItemObj.ResourcesId) then
      self.bHave = true
    end
  elseif GeneralCopnfig.Type == TableEnums.ENUMResourceType.WeaponSkin then
    if SkinData.FindWeaponSkin(ItemObj.ResourcesId) then
      self.bHave = true
    end
  elseif GeneralCopnfig.Type == TableEnums.ENUMResourceType.Weapon then
  elseif GeneralCopnfig.Type == TableEnums.ENUMResourceType.HERO then
    local TBHero = LuaTableMgr.GetLuaTableByName(TableNames.TBHero)
    local HeroID
    if TBHero[ItemObj.ResourcesId] then
      HeroID = TBHero[ItemObj.ResourcesId].HeroID
    end
    for index, value in ipairs(DataMgr.GetMyHeroInfo().heros) do
      if HeroID == value.id then
        self.bHave = true
        break
      end
    end
  end
  self.SelectNum = 0
  self.SelNum:SetText(self.SelectNum)
  UpdateVisibility(self.Overlay_AlreadyHad, self.bHave)
  UpdateVisibility(self.MultipleOpt, 1 ~= ItemObj.MaxNum)
end

function WBP_OptionalGiftItem_C:BindOnMainBtnClicked()
  if self.bHave then
    return
  end
  self:BindOnAddClicked()
end

function WBP_OptionalGiftItem_C:OnItemSelectionChanged(Index, SelectNum)
  if self.SelItems == nil or 1 == self.Data.MaxNum then
    self.SelItems = {}
  end
  self.SelItems[Index] = SelectNum
  self:SetSelect(self.SelItems[self.Data.ResourcesIndex] and self.SelItems[self.Data.ResourcesIndex] > 0)
end

function WBP_OptionalGiftItem_C:SetSelect(bSel)
  UpdateVisibility(self.Overlay_Sel_Choose, bSel)
end

return WBP_OptionalGiftItem_C
