local UnLua = _G.UnLua
local RGAutoLoadPanel = UnLua.Class()

function RGAutoLoadPanel:OnCreateWidget()
  self.ChildWidget.AutoLoadPanel = self
  if self.ChildWidget.InitAutoLoadChild then
    self.ChildWidget:InitAutoLoadChild()
  end
end

function RGAutoLoadPanel:Bp_PlayAnimation(AniName, StartTime, NumLoopsToPlay, PlayMode, Speed, bRestoreState)
  self:PlayAnimation(AniName, StartTime, NumLoopsToPlay, PlayMode, Speed, bRestoreState)
end

function RGAutoLoadPanel:Bp_StopAnimation(AniName)
  if UE.RGUtil.IsUObjectValid(self.ChildWidget) and self.ChildWidget[AniName] then
    self.ChildWidget:Stop(self.ChildWidget[AniName])
  else
    print("RGAutoLoadPanel:Bp_StopAnimation ChildWidget Is Nil")
  end
end

function RGAutoLoadPanel:PlayAnimation(AniName, StartTime, NumLoopsToPlay, PlayMode, Speed, bRestoreState)
  StartTime = StartTime or 0
  NumLoopsToPlay = NumLoopsToPlay or 1
  PlayMode = PlayMode or UE.EUMGSequencePlayMode.Forward
  Speed = Speed or 1
  bRestoreState = bRestoreState or false
  if UE.RGUtil.IsUObjectValid(self.ChildWidget) and self.ChildWidget[AniName] then
    self.ChildWidget:PlayAnimation(self.ChildWidget[AniName], StartTime, NumLoopsToPlay, PlayMode, Speed, bRestoreState)
  else
    print("RGAutoLoadPanel:PlayAnimation ChildWidget Is Nil")
  end
end

function RGAutoLoadPanel:IsAnimationPlaying(AniName)
  if UE.RGUtil.IsUObjectValid(self.ChildWidget) and self.ChildWidget[AniName] then
    return self.ChildWidget:IsAnimationPlaying(self.ChildWidget[AniName])
  end
  return false
end

function RGAutoLoadPanel:StopAnimation(AniName)
  if UE.RGUtil.IsUObjectValid(self.ChildWidget) and self.ChildWidget[AniName] then
    self.ChildWidget:StopAnimation(self.ChildWidget[AniName])
  end
end

return RGAutoLoadPanel
