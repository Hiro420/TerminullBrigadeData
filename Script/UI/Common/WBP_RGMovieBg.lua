local WBP_RGMovieBg = UnLua.Class()
local ShowType = {
  Normal = 0,
  MaxForSmaller = 1,
  MaxForLarger = 2
}

function WBP_RGMovieBg:Construct(...)
  EventSystem.AddListenerNew(EventDef.Global.OnViewportResized, self, self.OnViewportResized)
  self:ShowImageOrMovieByPath(self.MediaSource, self.Asset, self.ShowType, self.loop)
end

function WBP_RGMovieBg:ShowImageOrMovieByPath(MediaSource, Asset, ShowType, loop, callback)
  UpdateVisibility(self.URGImageMovie, true)
  self.callback = callback
  self.MediaSource = MediaSource
  self.ShowType = ShowType
  self.loop = loop
  if self.IsImage and Asset then
    UE.URGBlueprintLibrary.SetImageBrushFromAsset(self.URGImageMovie, Asset, false)
  else
    if MediaSource then
      self.MediaPlayer:SetLooping(loop)
      self.MediaPlayer:OpenSource(MediaSource)
      self.MediaPlayer:Rewind()
      self.MediaPlayer:Play()
    end
    if not self.loop then
      self.MediaPlayer.OnMediaReachedEnd:Add(self, self.MediaPlayerFinish)
    end
  end
  self:OnViewportResized()
end

function WBP_RGMovieBg:RestartMedia()
  self.MediaPlayer:Rewind()
  self.MediaPlayer:Play()
end

function WBP_RGMovieBg:MediaPlayerFinish()
  print("WBP_RGMovieBg:MediaPlayerFinish")
  if not self.loop then
    UpdateVisibility(self.URGImageMovie, false)
    if self.callback then
      self.callback()
    end
  end
end

function WBP_RGMovieBg:OnViewportResized()
  local scale = UE.URGBlueprintLibrary.GetCurrentViewportScale(UE.RGUtil.GetWorld())
  local ViewportSize = UE.URGBlueprintLibrary.GetCurrentViewportSize(UE.RGUtil.GetWorld())
  local ScaleBoxSize = 1
  if self.ShowType == ShowType.MaxForLarger then
    if ViewportSize.X / ViewportSize.Y >= 1.7777777777777777 then
      ScaleBoxSize = math.max(ViewportSize.X / 1920, ViewportSize.Y / 1080) / scale
      if ViewportSize.X / ViewportSize.Y > 2.388888888888889 then
        ScaleBoxSize = ViewportSize.Y * 3440 / 1440 / 1920 / scale
        self.ScaleBoxForShow:SetRenderScale(UE.FVector2D(ScaleBoxSize, ScaleBoxSize))
        return
      end
    end
  elseif self.ShowType == ShowType.MaxForSmaller and ViewportSize.X / ViewportSize.Y <= 1.7777777777777777 then
    ScaleBoxSize = math.max(ViewportSize.X / 1920, ViewportSize.Y / 1080) / scale
    if ViewportSize.X / ViewportSize.Y < 1.3333333333333333 then
      ScaleBoxSize = ViewportSize.X * 3 / 4 / 1080 / scale
      self.ScaleBoxForShow:SetRenderScale(UE.FVector2D(ScaleBoxSize, ScaleBoxSize))
      return
    end
  end
  self.ScaleBoxForShow:SetRenderScale(UE.FVector2D(ScaleBoxSize, ScaleBoxSize))
end

function WBP_RGMovieBg:Destruct(...)
  EventSystem.RemoveListenerNew(EventDef.Global.OnViewportResized, self, self.OnViewportResized)
  self.MediaPlayer.OnMediaReachedEnd:Remove(self, self.MediaPlayerFinish)
end

return WBP_RGMovieBg
