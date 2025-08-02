local SaveGrowthSnapData = require("Modules.SaveGrowthSnap.SaveGrowthSnapData")
local WBP_SaveGrowth_AutoSave = UnLua.Class()

function WBP_SaveGrowth_AutoSave:Construct()
  EventSystem.AddListenerNew(EventDef.SaveGrowthSnap.OnRefreshAutoSave, self, self.InitSaveGrowthAutoSave)
  self.Btn_Check.OnClicked:Add(self, self.OnCheckClicked)
  self:InitSaveGrowthAutoSave()
end

function WBP_SaveGrowth_AutoSave:InitSaveGrowthAutoSave()
  if SaveGrowthSnapData.bAutoSave then
    self.StateCtrl_Check:ChangeStatus(ECheck.Check)
  else
    self.StateCtrl_Check:ChangeStatus(ECheck.UnCheck)
  end
end

function WBP_SaveGrowth_AutoSave:OnCheckClicked()
  SaveGrowthSnapData.bAutoSave = not SaveGrowthSnapData.bAutoSave
  EventSystem.Invoke(EventDef.SaveGrowthSnap.OnRefreshAutoSave)
  local LobbyModule = ModuleManager.Get("LobbyModule")
  if LobbyModule then
    LobbyModule:SaveGrowthSnapDataToLocal()
  end
end

function WBP_SaveGrowth_AutoSave:Destruct()
  print("WBP_SaveGrowth_AutoSave:Destruct()")
  EventSystem.RemoveListenerNew(EventDef.SaveGrowthSnap.OnRefreshAutoSave, self, self.InitSaveGrowthAutoSave)
  self.Btn_Check.OnClicked:Remove(self, self.OnCheckClicked)
end

return WBP_SaveGrowth_AutoSave
