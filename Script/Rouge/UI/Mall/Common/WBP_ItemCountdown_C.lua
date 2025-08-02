local WBP_ItemCountdown_C = UnLua.Class()
local DefaultFormat = NSLOCTEXT("WBP_ItemCountdown_C", "DefaultFormat", "00\229\136\134\233\146\15900\231\167\146")
local DHFormat = NSLOCTEXT("WBP_ItemCountdown_C", "DHFormat", "{0}\229\164\169")
local HMFormat = NSLOCTEXT("WBP_ItemCountdown_C", "HMFormat", "{0}\229\176\143\230\151\182")
local MSFormat = NSLOCTEXT("WBP_ItemCountdown_C", "MSFormat", "{0}\229\136\134")

function WBP_ItemCountdown_C:Construct()
end

function WBP_ItemCountdown_C:Destruct()
end

function WBP_ItemCountdown_C:SetCountdownInfo(EndTime)
  self.CurTime = os.time()
  if EndTime < self.CurTime then
    self.TextBlock:SetText(DefaultFormat)
    return
  end
  self.TimeDifference = EndTime - self.CurTime
  self:SetCountdownText()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ExitGameTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ExitGameTimer)
  end
  if self.TimeDifference < 86400 then
    self.ExitGameTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function(self)
        self.TimeDifference = self.TimeDifference - 1
        self:SetCountdownText()
      end
    }, 1, true)
  end
end

function WBP_ItemCountdown_C:SetCountdownText()
  if self.TimeDifference == nil then
    return
  end
  if 86400 < self.TimeDifference then
    self.TextBlock:SetText(UE.FTextFormat(DHFormat(), math.floor(self.TimeDifference / 86400)))
    return
  end
  if 3600 < self.TimeDifference then
    self.TextBlock:SetText(UE.FTextFormat(HMFormat(), math.floor(self.TimeDifference / 3600)))
    return
  end
  if self.TimeDifference <= 0 then
    UIModelMgr:Get("BundleViewModel"):GetMallInfo()
    UIModelMgr:Get("MallExteriorViewModel"):GetMallInfo()
    UIModelMgr:Get("PropsViewModel"):GetMallInfo()
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ExitGameTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ExitGameTimer)
    end
    return
  end
  self.TextBlock:SetText(UE.FTextFormat(MSFormat(), math.floor(self.TimeDifference / 60)))
end

return WBP_ItemCountdown_C
