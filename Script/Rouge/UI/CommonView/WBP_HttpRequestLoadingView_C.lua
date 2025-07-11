local ViewBase = require("Framework.UIMgr.ViewBase")
local WBP_HttpRequestLoadingView_C = UnLua.Class(ViewBase)
local Max_Loading_Duration = 20
local EscName = "PauseGame"
local HttpLoadingCustomZOrder = GetCustomZOrderByLayer(UE.ECustomLayer.ELayer_HttpLoading)
function WBP_HttpRequestLoadingView_C:Construct()
  self:PlayAnimation(self.ani_matchloading_loop, 0, 0)
end
function WBP_HttpRequestLoadingView_C:Destruct()
  self:StopAnimation(self.ani_matchloading_loop)
end
function WBP_HttpRequestLoadingView_C:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("LoadingViewModel")
end
function WBP_HttpRequestLoadingView_C:OnDestroy()
end
function WBP_HttpRequestLoadingView_C:OnShow()
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  if self.SetCustomZOrder then
    self:SetCustomZOrder(HttpLoadingCustomZOrder)
  end
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  self:PlayAnimation(self.ani_matchloading_loop, 0, 0)
  self:PlayAnimation(self.ani_in)
  self.Timer = 0
  self:SetEnhancedInputActionBlocking(true)
end
function WBP_HttpRequestLoadingView_C:OnPreHide()
  self:StopAnimation(self.ani_matchloading_loop)
  self:StopAnimation(self.ani_in)
  self.viewModel:ClearRequestIdDic()
  self:SetEnhancedInputActionBlocking(false)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function WBP_HttpRequestLoadingView_C:OnHide()
end
function WBP_HttpRequestLoadingView_C:ListenForEscInputAction()
end
function WBP_HttpRequestLoadingView_C:Refresh()
  self.Timer = 0
end
function WBP_HttpRequestLoadingView_C:OnTick(deltaSeconds)
  if self.Timer < 0 then
    return
  end
  if self.Timer > Max_Loading_Duration then
    UIMgr:Hide(ViewID.UI_HttpRequestLoadingView)
    local Param = {}
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
    if WaveWindowManager then
      WaveWindowManager:ShowWaveWindow(1151, Param, nil)
    end
    self.Timer = -1
  else
    self.Timer = self.Timer + deltaSeconds
  end
end
return WBP_HttpRequestLoadingView_C
