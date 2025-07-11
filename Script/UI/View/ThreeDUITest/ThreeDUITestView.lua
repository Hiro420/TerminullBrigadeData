local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local EscName = "PauseGame"
local ThreeDUITestView = Class(ViewBase)
function ThreeDUITestView:BindClickHandler()
end
function ThreeDUITestView:UnBindClickHandler()
end
function ThreeDUITestView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function ThreeDUITestView:OnDestroy()
end
function ThreeDUITestView:OnShow(...)
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
  local threeDUITestActor = self:GetOrCreateThreeDUITestActor()
  threeDUITestActor:OnShow(...)
  self.BP_ButtonWithSoundAni1.OnClicked:Add(self, self.OnPlayAniClick1)
  self.BP_ButtonWithSoundAni2.OnClicked:Add(self, self.OnPlayAniClick2)
  self.BP_ButtonWithSoundAni3.OnClicked:Add(self, self.OnPlayAniClick3)
  self.BP_ButtonWithSoundAni4.OnClicked:Add(self, self.OnPlayAniClick4)
  self.BP_ButtonWithSoundAni5.OnClicked:Add(self, self.OnPlayAniClick5)
end
function ThreeDUITestView:GetOrCreateThreeDUITestActor()
  if UE.RGUtil.IsUObjectValid(self.ThreeDUITestActor) then
    return self.ThreeDUITestActor
  end
  local World = self:GetWorld()
  if World then
    local Transform = UE.FTransform()
    self.ThreeDUITestActor = World:SpawnActor(self.ThreeDUITestActorCls, Transform)
    local Result = UE.FHitResult()
    self.ThreeDUITestActor:K2_SetActorLocation(UE.FVector(0, 0, 2000), true, Result, true)
  end
  return self.ThreeDUITestActor
end
function ThreeDUITestView:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_ThreeDUITest)
end
function ThreeDUITestView:OnHide()
  local threeDUITestActor = self:GetOrCreateThreeDUITestActor()
  threeDUITestActor:OnHide()
  self.BP_ButtonWithSoundAni1.OnClicked:Remove(self, self.OnPlayAniClick1)
  self.BP_ButtonWithSoundAni2.OnClicked:Remove(self, self.OnPlayAniClick2)
  self.BP_ButtonWithSoundAni3.OnClicked:Remove(self, self.OnPlayAniClick3)
  self.BP_ButtonWithSoundAni4.OnClicked:Remove(self, self.OnPlayAniClick4)
  self.BP_ButtonWithSoundAni5.OnClicked:Remove(self, self.OnPlayAniClick5)
end
function ThreeDUITestView:OnPlayAniClick1()
  local threeDUITestActor = self:GetOrCreateThreeDUITestActor()
  threeDUITestActor:PlayAnimation1()
end
function ThreeDUITestView:OnPlayAniClick2()
  local threeDUITestActor = self:GetOrCreateThreeDUITestActor()
  threeDUITestActor:PlayAnimation2()
end
function ThreeDUITestView:OnPlayAniClick3()
  local threeDUITestActor = self:GetOrCreateThreeDUITestActor()
  threeDUITestActor:PlayAnimation3()
end
function ThreeDUITestView:OnPlayAniClick4()
  local threeDUITestActor = self:GetOrCreateThreeDUITestActor()
  threeDUITestActor:PlayAnimation4()
end
function ThreeDUITestView:OnPlayAniClick5()
  local threeDUITestActor = self:GetOrCreateThreeDUITestActor()
  threeDUITestActor:PlayAnimation5()
end
return ThreeDUITestView
