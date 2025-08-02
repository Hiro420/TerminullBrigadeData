local BP_MC_Chest_C = UnLua.Class()

function BP_MC_Chest_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_MC_Chest_C:ReceiveBeginPlay", self)
  self.RGInteractComponent_Chest.OnChestStateChanged:Add(self, BP_MC_Chest_C.OnChestStateChangedFunc)
end

function BP_MC_Chest_C:OnChestStateChangedFunc(InState)
  if InState == UE.ERGChestState.Finished then
    print("BP_MC_Chest_C:OnChestStateChangedFunc Change to Finish")
    UE.URGBlueprintLibrary.RemoveInteractMark(self)
  end
end

function BP_MC_Chest_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  print("BP_MC_Chest_C:ReceiveEndPlay")
  self:OnChestStateChangedFunc(UE.ERGChestState.Finished)
  self.RGInteractComponent_Chest.OnChestStateChanged:Remove(self, BP_MC_Chest_C.OnChestStateChangedFunc)
end

return BP_MC_Chest_C
