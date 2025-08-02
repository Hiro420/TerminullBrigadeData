local BP_Pickup_MatrixMod_Base = UnLua.Class()

function BP_Pickup_MatrixMod_Base:OnModPickup(Picker, PuzzleIds)
  EventSystem.Invoke(EventDef.Puzzle.OnPuzzlePickup, Picker, PuzzleIds)
end

return BP_Pickup_MatrixMod_Base
