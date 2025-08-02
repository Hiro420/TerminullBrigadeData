local WBP_FightAndSkillNotifyIcon_C = UnLua.Class()

function WBP_FightAndSkillNotifyIcon_C:SetShowType(ShowType)
  if ShowType == UE.ERGFightSkillType.SkillStart then
    self:SetIconBrush(self.SkillStartIcon)
  elseif ShowType == UE.ERGFightSkillType.SkillDone then
    self:SetIconBrush(self.SkillDownIcon)
  elseif ShowType == UE.ERGFightSkillType.BeginFight then
    self:SetIconBrush(self.InScreenIcon)
  elseif ShowType == UE.ERGFightSkillType.AfterFight then
    self:SetIconBrush(self.OutScreenIcon)
  end
end

function WBP_FightAndSkillNotifyIcon_C:SetShowAngel(Target)
  self:SetRenderTransformAngle(self:GetAngle(Target))
end

function WBP_FightAndSkillNotifyIcon_C:GetAngle(Target)
  local LocalLocation = UE.URGBlueprintLibrary.ConvertWorldLocationToLocal(self, Target, 25.0)
  local ASind = UE.UKismetMathLibrary.DegAsin(LocalLocation.X / UE.UKismetMathLibrary.Distance2D(LocalLocation, UE.FVector2D(0, 0)))
  if LocalLocation.Y <= 0 then
    return ASind - UE.UKismetMathLibrary.SelectFloat(180, -180, ASind < 0)
  else
    return ASind * -1
  end
end

function WBP_FightAndSkillNotifyIcon_C:SetIconBrush(Sprite)
  self.NotifyIcon:SetBrush(UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(Sprite, 0, 0))
end

return WBP_FightAndSkillNotifyIcon_C
