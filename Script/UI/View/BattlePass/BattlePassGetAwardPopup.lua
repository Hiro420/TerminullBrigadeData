local BattlePassGetAwardPopup = UnLua.Class()
local EscName = "PauseGame"
local BattlePassState = {
  Normal = 0,
  Premiun = 1,
  Ultra = 2
}
local UnLockPremiun = NSLOCTEXT("BattlePassSubView", "UnLockPremiun", "\232\167\163\233\148\129\233\171\152\231\186\167\233\128\154\232\161\140\232\175\129")
local UnLockUltra = NSLOCTEXT("BattlePassSubView", "UnLockUltra", "\229\133\184\232\151\143\233\128\154\232\161\140\232\175\129")
function BattlePassGetAwardPopup:Construct()
  self.Button_Confirm.OnMainButtonClicked:Add(self, self.Button_Confirm_OnClicked)
  self.Button_UnLock.OnMainButtonClicked:Add(self, self.Button_UnLock_OnClicked)
end
function BattlePassGetAwardPopup:Destruct()
  self.Button_Confirm.OnMainButtonClicked:Remove(self, self.Button_Confirm_OnClicked)
  self.Button_UnLock.OnMainButtonClicked:Remove(self, self.Button_UnLock_OnClicked)
end
function BattlePassGetAwardPopup:ShowTip(UpAwardList, DownAwardList, BattlePassID, ActivateState)
  self.BattlePassID = BattlePassID
  self.ActivateState = ActivateState
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.Button_Confirm_OnClicked
    })
  end
  local ListViewAry = UE.TArray(UE.UObject)
  for AwardID, Num in pairs(UpAwardList) do
    local DataObj = self.RGListView_Normal:GetOrCreateDataObj()
    DataObj.ItemID = AwardID
    DataObj.Num = Num
    ListViewAry:Add(DataObj)
  end
  self.RGListView_Normal:SetRGListItems(ListViewAry, true, true)
  UpdateVisibility(self.CanvasPanel_DownAward, 0 == ActivateState)
  UpdateVisibility(self.RGListView_Premium, 0 == #DownAwardList)
  UpdateVisibility(self.Button_UnLock, self.ActivateState == BattlePassState.Normal)
  self.Button_UnLock:SetInfoText(self.ActivateState == BattlePassState.Normal and UnLockPremiun or UnLockUltra)
  local ListViewAry_2 = UE.TArray(UE.UObject)
  for AwardID, Num in pairs(DownAwardList) do
    local DataObj = self.RGListView_Premium:GetOrCreateDataObj()
    DataObj.ItemID = AwardID
    DataObj.Num = Num
    ListViewAry_2:Add(DataObj)
  end
  self.RGListView_Premium:SetRGListItems(ListViewAry_2, true, true)
  self:PlayAnimation(self.Anim_IN)
  self.WBP_CommonTipBg:PlayAnimation(self.WBP_CommonTipBg.Ani_in)
end
function BattlePassGetAwardPopup:Button_Confirm_OnClicked()
  UpdateVisibility(self, false)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
end
function BattlePassGetAwardPopup:Button_UnLock_OnClicked()
  UIMgr:Hide(ViewID.UI_BattlePassMainView, true)
  local UnlockView = UIMgr:Show(ViewID.UI_BattlePassUnLockView)
  UnlockView:InitInfo(self.BattlePassID, self.ActivateState)
end
return BattlePassGetAwardPopup
