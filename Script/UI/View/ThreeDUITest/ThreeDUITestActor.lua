local ThreeDUITestData = require("Modules.ThreeDUITest.ThreeDUITestData")
local ThreeDUITestActor = Class()
function ThreeDUITestActor:OnInit()
end
function ThreeDUITestActor:OnDestroy()
end
function ThreeDUITestActor:OnShow(...)
  self:InitWidgetItem()
  self:UpdateActived(true)
end
function ThreeDUITestActor:OnHide()
  self:UpdateActived(false)
end
function ThreeDUITestActor:HoverChanged(HoverWidget, PreviousHoverWidget)
  if HoverWidget then
    HoverWidget:GetWidget():Hover()
  end
  if PreviousHoverWidget then
    PreviousHoverWidget:GetWidget():UnHover()
  end
end
function ThreeDUITestActor:InitWidgetItem()
  for i, v in ipairs(ThreeDUITestData.ItemData) do
    local str = "RGWidget" .. i
    if self[str] then
      self[str]:GetWidget():InitThreeDUIItem(v)
    end
  end
end
function ThreeDUITestActor:UpdateActived(bIsActived)
  self:SetActorHiddenInGame(not bIsActived)
  if bIsActived then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      self:EnableInput(PC)
      PC:SetViewTargetwithBlend(self.ChildActorCamera.ChildActor)
    end
  else
    local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "MainCamera", nil)
    local TargetCamera
    for i, SingleActor in iterator(AllActors) do
      TargetCamera = SingleActor
      break
    end
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      self:DisableInput(PC)
      PC:SetViewTargetwithBlend(TargetCamera)
    end
  end
end
return ThreeDUITestActor
