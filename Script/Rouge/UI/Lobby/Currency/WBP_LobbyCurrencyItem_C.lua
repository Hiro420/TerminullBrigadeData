local rapidjson = require("rapidjson")
local TopupHandler = require("Protocol.Topup.TopupHandler")
local WBP_LobbyCurrencyItem_C = UnLua.Class()
local JumpToTopupCurrencyPanelWaveId = 306004
local TipPath = "/Game/Rouge/UI/Lobby/Currency/WBP_LobbyCurrencyItemTip.WBP_LobbyCurrencyItemTip_C"

function WBP_LobbyCurrencyItem_C:Construct()
  self.Btn_Add.OnClicked:Add(self, WBP_LobbyCurrencyItem_C.BindOnAddButtonClicked)
  self.Btn_Subtract.OnClicked:Add(self, WBP_LobbyCurrencyItem_C.BindOnSubtractButtonClicked)
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
end

function WBP_LobbyCurrencyItem_C:BindOnAddButtonClicked()
  local Param = {
    roleId = DataMgr.GetUserId(),
    resources = {
      {
        rid = self.CurrencyId,
        amount = 10
      }
    },
    reason = "GM Add Resource"
  }
  HttpCommunication.Request("dbg/resource/add", Param, {
    self,
    function(self, JsonResponse)
      print("\229\162\158\229\138\160\232\180\167\229\184\129", rapidjson.decode(JsonResponse.Content))
    end
  }, {
    self,
    function()
    end
  }, false, true)
end

function WBP_LobbyCurrencyItem_C:BindOnSubtractButtonClicked()
  local Param = {
    roleId = DataMgr.GetUserId(),
    resources = {
      {
        rid = self.CurrencyId,
        amount = 1
      }
    },
    reason = "GM Del Resource"
  }
  HttpCommunication.Request("dbg/resource/del", Param, {
    self,
    function(self, JsonResponse)
      print("\230\182\136\232\128\151\232\180\167\229\184\129", rapidjson.decode(JsonResponse.Content))
    end
  }, {
    self,
    function()
    end
  })
end

function WBP_LobbyCurrencyItem_C:BindOnMainButtonClicked(...)
  local CurSceneStatus = GetCurSceneStatus()
  if CurSceneStatus ~= UE.ESceneStatus.ELobby then
    return
  end
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(self.CurrencyId)
  if not CurrencyInfo then
    return
  end
  if CurrencyInfo.Type == TableEnums.ENUMResourceType.PaymentCurrency then
    if not UIMgr:IsShow(ViewID.UI_TopupCurrencyPanel) then
      ShowWaveWindowWithDelegate(JumpToTopupCurrencyPanelWaveId, {}, {
        self,
        function()
          local TopupCurrencyPanelLabel = LogicLobby.GetLabelTagNameByUIName("UI_TopupCurrencyPanel")
          LogicLobby.ChangeLobbyPanelLabelSelected(TopupCurrencyPanelLabel)
        end
      })
    end
    return
  end
  local Result, ExchangeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResourceExchange, self.CurrencyId)
  if Result then
    local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
    if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.EXCHANGE) then
      return
    end
    local TargetExchangeId = self:GetTargetExchangeResourceId(self.CurrencyId)
    if TargetExchangeId then
      UIMgr:Show(ViewID.UI_ExchangePanel, false, TargetExchangeId)
      if TargetExchangeId ~= self.CurrencyId then
        local View = UIMgr:GetLuaFromActiveView(ViewID.UI_ExchangePanel)
        if View then
          View:SetRealNeedExchangeResourceId(self.CurrencyId)
        end
      end
    end
    return
  end
end

function WBP_LobbyCurrencyItem_C:GetTargetExchangeResourceId(TargetExchangeId)
  local Result, ExchangeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResourceExchange, TargetExchangeId)
  if not Result then
    return nil
  end
  local ExchangedResourceNum = LogicOutsidePackback.GetResourceNumById(ExchangeRowInfo.ExchangedResourceID)
  local MaxExchangeNum = math.floor(ExchangedResourceNum / (ExchangeRowInfo.ExchangeRatio.key / ExchangeRowInfo.ExchangeRatio.value))
  if 0 == MaxExchangeNum then
    local CurExchangeCurrencyInfo = LogicOutsidePackback.GetResourceInfoById(ExchangeRowInfo.ExchangedResourceID)
    if CurExchangeCurrencyInfo.Type == TableEnums.ENUMResourceType.PaymentCurrency then
      TopupHandler:JumpToTopupPanel()
      return nil
    else
      return self:GetTargetExchangeResourceId(ExchangeRowInfo.ExchangedResourceID)
    end
  else
    return TargetExchangeId
  end
end

function WBP_LobbyCurrencyItem_C:OnUseResource()
  local Param = {
    uniqueId = "32895548603662336",
    rid = 200003,
    reason = "Test UseResource"
  }
  HttpCommunication.Request("resource/use", Param, {
    self,
    function()
      print("Use Resource Success")
    end
  }, {
    self,
    function()
    end
  })
end

function WBP_LobbyCurrencyItem_C:BindOnResourceUpdate()
  self:SetCurrencyNum()
end

function WBP_LobbyCurrencyItem_C:SetCurrencyNum()
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(self.CurrencyId)
  if not CurrencyInfo then
    print("not found CurrencyId", self.CurrencyId)
    return
  end
  local LastCurrencyNum = self.CurCurrencyNum
  self.CurCurrencyNum = LogicOutsidePackback.GetResourceNumById(self.CurrencyId)
  self.Txt_Num:SetText(self.CurCurrencyNum)
  UpdateVisibility(self.Add_money, nil ~= LastCurrencyNum and self.CurCurrencyNum - LastCurrencyNum > 0)
  if nil ~= LastCurrencyNum and self.CurCurrencyNum - LastCurrencyNum > 0 then
    self.Txt_AddNum_Anim:SetText(self.CurCurrencyNum - LastCurrencyNum)
    if self.IsNeedPlayAddMoneyAnim then
      self:PlayAddMoneyAnim()
    end
  end
end

function WBP_LobbyCurrencyItem_C:PlayAddMoneyAnim()
  if self.Add_money:IsVisible() then
    self:PlayAnimationForward(self.Ani_add_money)
    self.IsNeedPlayAddMoneyAnim = false
  else
    self.IsNeedPlayAddMoneyAnim = true
  end
end

function WBP_LobbyCurrencyItem_C:OnAnimationFinished(InAnimation)
  if InAnimation == self.Ani_add_money then
    UpdateVisibility(self.Add_money, false)
  end
end

function WBP_LobbyCurrencyItem_C:Show(CurrencyId)
  self.CurrencyId = CurrencyId
  local RowInfo = LogicOutsidePackback.GetResourceInfoById(self.CurrencyId)
  if not RowInfo then
    print("Invalid Currency Num")
    return
  end
  local Result, ExchangeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResourceExchange, self.CurrencyId)
  UpdateVisibility(self.Overlay_CanExchange, Result)
  local SoftObjRef = MakeStringToSoftObjectReference(RowInfo.Icon)
  if RowInfo.CurrencyIcon ~= "" then
    SoftObjRef = MakeStringToSoftObjectReference(RowInfo.CurrencyIcon)
  end
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
    local obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef)
    local iconObj
    if obj then
      iconObj = obj:Cast(UE.UPaperSprite)
    end
    if iconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(iconObj, 0, 0)
      self.Img_CurrencyIcon:SetBrush(Brush)
    end
  end
  self:SetCurrencyNum()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateResourceInfo, WBP_LobbyCurrencyItem_C.BindOnResourceUpdate)
  self:SetVisibility(UE.ESlateVisibility.Visible)
end

function WBP_LobbyCurrencyItem_C:GetToolTipWidget()
  local CurrencyTable = DataMgr.GetOutsideCurrencyTableById(self.CurrencyId)
  if 0 == #CurrencyTable then
    CurrencyTable = DataMgr.GetPackbackTableById(self.CurrencyId)
  end
  local Widget = GetTips(self.CurrencyId, self.TipsClass)
  if Widget and CurrencyTable then
    Widget:ShowCurrencyExpireAt(CurrencyTable)
  end
  return Widget
end

function WBP_LobbyCurrencyItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CurrencyId = 0
  EventSystem.RemoveListener(EventDef.Lobby.UpdateResourceInfo, WBP_LobbyCurrencyItem_C.BindOnResourceUpdate, self)
end

function WBP_LobbyCurrencyItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateResourceInfo, WBP_LobbyCurrencyItem_C.BindOnResourceUpdate, self)
end

return WBP_LobbyCurrencyItem_C
