local WBP_LevelPassCheck = UnLua.Class()
local RefuseKeyName = "OKeyEvent"
local AgreeKeyName = "PKeyEvent"

function WBP_LevelPassCheck:OnDisplay(...)
  if not IsListeningForInputAction(self, RefuseKeyName) then
    ListenForInputAction(RefuseKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.OnRefuseEnterLevel
    })
  end
  if not IsListeningForInputAction(self, AgreeKeyName) then
    ListenForInputAction(AgreeKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.OnAgreeEnterLevel
    })
  end
  self:PushInputAction()
  self.IsRequestCancel = false
  self:PlayAnimation(self.Ani_in)
end

function WBP_LevelPassCheck:OnShow(StartTime, Duration, ModeID)
  self.StartTime = StartTime
  self.EndTime = self.StartTime + Duration
  self.Txt_Title:SetText(ModeID == TableEnums.ENUMGameMode.TOWERClIMBING and self.TowerClimbText or self.NormalText)
end

function WBP_LevelPassCheck:OnRefuseEnterLevel(...)
  if self.IsRequestCancel then
    print("WBP_LevelPassCheck:OnRefuseEnterLevel \229\183\178\231\187\143\229\143\145\233\128\129\232\191\135\229\143\150\230\182\136\229\141\143\232\174\174\228\186\134")
    return
  end
  UE.URGGameplayLibrary.CancelCheckReward(self, tonumber(DataMgr.GetUserId()))
  self.IsRequestCancel = true
  RGUIMgr:HideUI(UIConfig.WBP_LevelPassCheck_C.UIName)
end

function WBP_LevelPassCheck:OnAgreeEnterLevel(...)
  UE.URGGameplayLibrary.ConfirmCheckReward(self, tonumber(DataMgr.GetUserId()))
  RGUIMgr:HideUI(UIConfig.WBP_LevelPassCheck_C.UIName)
end

function WBP_LevelPassCheck:OnUnDisplay(...)
  if IsListeningForInputAction(self, RefuseKeyName) then
    StopListeningForInputAction(self, RefuseKeyName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, AgreeKeyName) then
    StopListeningForInputAction(self, AgreeKeyName, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_LevelPassCheck:Destruct(...)
  self:OnUnDisplay()
end

return WBP_LevelPassCheck
