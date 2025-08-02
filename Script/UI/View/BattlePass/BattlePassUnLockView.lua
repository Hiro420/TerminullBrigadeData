local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local URGBlueprintLibrary = UE.URGBlueprintLibrary
local rapidjson = require("rapidjson")
local BattlePassData = require("Modules.BattlePass.BattlePassData")
local BattlePassHandler = require("Protocol.BattlePass.BattlePassHandler")
local TopupHandler = require("Protocol.Topup.TopupHandler")
local UIConsoleUtil = require("Framework.UIMgr.UIConsoleUtil")
local EscName = "PauseGame"
local BattlePassUnLockView = Class(ViewBase)
local UnlockType = {
  Normal = 0,
  Premium = 1,
  Ultra = 2
}
local ShowAwardSort = function(A, B)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local resourceDataA = TBGeneral[A.key]
  local resourceDataB = TBGeneral[B.key]
  if resourceDataA.Rare ~= resourceDataB.Rare then
    return resourceDataA.Rare > resourceDataB.Rare
  else
    return resourceDataA.ID > resourceDataB.ID
  end
end

function BattlePassUnLockView:BindClickHandler()
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.EscView)
  self.Btn_UnlockPremium.OnMainButtonClicked:Add(self, self.Btn_UnlockPremium_OnClicked)
  self.Btn_UnlockUltra.OnMainButtonClicked:Add(self, self.Btn_UnlockUltra_OnClicked)
  EventSystem.AddListenerNew(EventDef.BattlePass.UnlockUltra, self, self.UnlockBattlePass)
  EventSystem.AddListenerNew(EventDef.BattlePass.GetBattlePassData, self, self.BindOnUpdateBattlePass)
end

function BattlePassUnLockView:UnBindClickHandler()
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.EscView)
  self.Btn_UnlockPremium.OnMainButtonClicked:Remove(self, self.Btn_UnlockPremium_OnClicked)
  self.Btn_UnlockUltra.OnMainButtonClicked:Remove(self, self.Btn_UnlockUltra_OnClicked)
  EventSystem.RemoveListenerNew(EventDef.BattlePass.UnlockUltra, self, self.UnlockBattlePass)
  EventSystem.RemoveListenerNew(EventDef.BattlePass.GetBattlePassData, self, self.BindOnUpdateBattlePass)
end

function BattlePassUnLockView:Construct()
  self:BindClickHandler()
end

function BattlePassUnLockView:Destruct()
  self:UnBindClickHandler()
end

function BattlePassUnLockView:OnHide()
  UpdateVisibility(self, false)
  UIConsoleUtil.UpdateConsoleStoreUIVisible(false)
end

function BattlePassUnLockView:OnPreHide()
  UpdateVisibility(self, false)
end

function BattlePassUnLockView:OnShow()
  self:PlayAnimation(self.Ani_in)
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.EscView
    })
  end
  UIConsoleUtil.UpdateConsoleStoreUIVisible(true)
end

function BattlePassUnLockView:InitInfo(BattlePassID, State)
  self.BattlePassID = BattlePassID
  self.ActivateState = State
  local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattlePass, BattlePassID)
  if result then
    self.RTXT_Desc:SetText(rowInfo.NormalDesc)
    self.RTXT_UltraDesc:SetText(rowInfo.UltraDesc)
    self.TXT_Title:SetText(rowInfo.Name)
    self:InitAwardShow(BattlePassID)
    self:InitUltraAward(rowInfo.UltraReward)
    if rowInfo.IconPath then
      URGBlueprintLibrary.SetImageBrushFromAssetPath(self.Image_BG, rowInfo.IconPath, true)
    end
  else
    print("\233\128\154\232\161\140\232\175\129id\233\148\153\232\175\175\239\188\129 id\228\184\186", BattlePassID)
  end
  self:UpdateBtnInfo(self.ActivateState)
end

function BattlePassUnLockView:InitAwardShow(BattlePassID)
  local rowInfos = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassReward)
  if rowInfos then
    local GrandPrizeList = {}
    for i, v in pairs(rowInfos) do
      if 1 == v.IsGrandPrize and v.BattlePassID == BattlePassID then
        for index, value in pairs(v.NormalReward) do
          table.insert(GrandPrizeList, {
            AwardID = value.key,
            Num = value.value
          })
        end
        for index, value in pairs(v.PremiumReward) do
          table.insert(GrandPrizeList, {
            AwardID = value.key,
            Num = value.value
          })
        end
      end
    end
    local showAwards = BattlePassData:MergeAwardList(GrandPrizeList)
    local showtable = {}
    for i, v in pairs(showAwards) do
      table.insert(showtable, {key = i, value = v})
    end
    table.sort(showtable, ShowAwardSort)
    local grandPrize = {}
    for i, v in pairs(showtable) do
      local awardItem = GetOrCreateItem(self.SclBox_PremiumAwards, #grandPrize + 1, self.WBP_BattlePassSmallItem:GetClass())
      awardItem:InitItem(v.key, v.value)
      local awardItem_2 = GetOrCreateItem(self.SclBox_PremiumAwards_2, #grandPrize + 1, self.WBP_BattlePassSmallItem:GetClass())
      awardItem_2:InitItem(v.key, v.value)
      table.insert(grandPrize, awardItem)
    end
    HideOtherItem(self.SclBox_PremiumAwards, #grandPrize + 1)
    HideOtherItem(self.SclBox_PremiumAwards_2, #grandPrize + 1)
  end
end

function BattlePassUnLockView:InitUltraAward(UltraAwards)
  local awardList = {}
  table.sort(UltraAwards, ShowAwardSort)
  for i, v in ipairs(UltraAwards) do
    local awardItem = GetOrCreateItem(self.SclBox_UltraAwards, #awardList + 1, self.WBP_UltrraAwardItem:GetClass())
    UpdateVisibility(awardItem.CanvasPanel_Name, true)
    table.insert(awardList, awardItem)
    awardItem:InitItem(v.key, v.value)
  end
  HideOtherItem(self.SclBox_UltraAwards, #awardList + 1)
end

function BattlePassUnLockView:UpdateBtnInfo(ActivateState)
  if ActivateState == UnlockType.Normal then
    self:ChangeBtnState(self.Btn_UnlockPremium, 0)
    self:ChangeBtnState(self.Btn_UnlockUltra, 0)
  elseif ActivateState == UnlockType.Premium then
    self:ChangeBtnState(self.Btn_UnlockPremium, 1)
    self:ChangeBtnState(self.Btn_UnlockUltra, 0)
  else
    self:ChangeBtnState(self.Btn_UnlockPremium, 1)
    self:ChangeBtnState(self.Btn_UnlockUltra, 1)
  end
  local CurBattlePassPremiumPrice, OriginalBattlePassPremiumPrice = BattlePassData:GetBattlePassPriceById(self.BattlePassID, UnlockType.Premium)
  local CurBattlePassUltraPrice, OriginalBattlePassUltraPrice = BattlePassData:GetBattlePassPriceById(self.BattlePassID, UnlockType.Ultra)
  if ActivateState < UnlockType.Premium then
    self.Txt_CurPrice_Premium:SetText(CurBattlePassPremiumPrice)
  else
    self.Txt_CurPrice_Premium:SetText(self.OwningText)
  end
  if ActivateState < UnlockType.Ultra then
    self.Txt_CurPrice_Ultra:SetText(CurBattlePassUltraPrice)
  else
    self.Txt_CurPrice_Ultra:SetText(self.OwningText)
  end
  self.Txt_OriginalPrice_Ultra:SetText(OriginalBattlePassUltraPrice)
  UpdateVisibility(self.Txt_OriginalPrice_Ultra, CurBattlePassUltraPrice ~= OriginalBattlePassUltraPrice)
end

function BattlePassUnLockView:EscView()
  UIMgr:Hide(ViewID.UI_BattlePassUnLockView)
  local BPMainView = UIMgr:Show(ViewID.UI_BattlePassMainView, true)
  BPMainView:InitSubView(self.BattlePassID)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
end

function BattlePassUnLockView:Btn_UnlockPremium_OnClicked()
  local BattlePassProductId = BattlePassData:GetBattlePassProductIdById(self.BattlePassID, UnlockType.Premium)
  print("BattlePassUnLockView:BuyMisdasProduct", BattlePassProductId, 1)
  TopupHandler:RequestBuyMisdasProduct(BattlePassProductId, 1)
end

function BattlePassUnLockView:Btn_UnlockUltra_OnClicked()
  local BattlePassProductId = BattlePassData:GetBattlePassProductIdById(self.BattlePassID, UnlockType.Ultra)
  print("BattlePassUnLockView:BuyMisdasProduct", BattlePassProductId, 1)
  TopupHandler:RequestBuyMisdasProduct(BattlePassProductId, 1)
end

function BattlePassUnLockView:UnlockBattlePass(BattlePassID, UnLockType)
  UIMgr:Hide(ViewID.UI_BattlePassUnLockView)
  local BPMainView = UIMgr:Show(ViewID.UI_BattlePassMainView, true)
  BPMainView:InitSubView(BattlePassID)
end

function BattlePassUnLockView:BindOnUpdateBattlePass(BattlePassInfo, BattlePassID)
  local CurbattlePassState = BattlePassInfo.battlePassActivateState
  if self.BattlePassID == BattlePassID and CurbattlePassState ~= self.ActivateState then
    self:InitInfo(self.BattlePassID, CurbattlePassState)
  end
end

function BattlePassUnLockView:ChangeBtnState(Btn, State)
  if 0 == State then
    Btn:SetIsEnabled(true)
  elseif 1 == State then
    Btn:SetIsEnabled(false)
  end
end

return BattlePassUnLockView
