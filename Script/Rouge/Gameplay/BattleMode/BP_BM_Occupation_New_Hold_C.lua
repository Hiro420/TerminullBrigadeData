local BP_BM_Occupation_New_Hold_C = UnLua.Class()

function BP_BM_Occupation_New_Hold_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  self.OnShutdown:Add(self, self.OnShutdownBp)
end

function BP_BM_Occupation_New_Hold_C:NotifyStartup()
  if not UE.UKismetSystemLibrary.IsServer(self) then
    NotifyObjectMessage(nil, GMP.MSG_World_LevelGameplay_EnterOccupancyLevel)
    self.MarkId = UE.URGBlueprintLibrary.TriggerMark(self, self, "Box")
  end
  self.Overridden.NotifyStartup(self)
end

function BP_BM_Occupation_New_Hold_C:OnShutdownBp()
  NotifyObjectMessage(nil, GMP.MSG_TriggerMarkUIRemove, self.Object)
end

function BP_BM_Occupation_New_Hold_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if UE.UKismetSystemLibrary.IsServer(self) then
    return
  end
  NotifyObjectMessage(nil, GMP.MSG_TriggerMarkUIRemove, self.Object)
  self.OnShutdown:Remove(self, self.OnShutdownBp)
end

return BP_BM_Occupation_New_Hold_C
