require("Rouge.UI.Battle.Logic.Logic_Settlement")
local SaveGrowthSnapModule = LuaClass()

function SaveGrowthSnapModule:Ctor()
end

function SaveGrowthSnapModule:OnInit()
  print("SaveGrowthSnapModule:OnInit...........")
end

function SaveGrowthSnapModule:OnShutdown()
  print("SaveGrowthSnapModule:OnShutdown...........")
  LogicSettlement:CheckAndAutoSaveGrowth()
end

return SaveGrowthSnapModule
