local BP_Pickup_StoryPiece_C = UnLua.Class()

function BP_Pickup_StoryPiece_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  self.MarkId = UE.URGBlueprintLibrary.TriggerMark(self, self, "StoryPiece")
end

function BP_Pickup_StoryPiece_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
end

function BP_Pickup_StoryPiece_C:NotifyPickup(Picker)
  self.Overridden.NotifyPickup(self, Picker)
  if UE.RGUtil.IsEditor() or not UE.UKismetSystemLibrary.IsDedicatedServer(self) then
    local Pawn = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if Pawn == Picker then
      UE.URGBlueprintLibrary.RemoveMarkById(self, self.MarkId)
    end
  end
end

return BP_Pickup_StoryPiece_C
