local WBP_MainTask_C = UnLua.Class()

function WBP_MainTask_C:Construct()
  if self.ActiveIndex == nil then
    self.ActiveIndex = 1
  end
  self.MainTaskWorldMode = {}
  self.MainTaskWorldMode[23] = 4001
  self.MainTaskWorldMode[24] = 5001
  self.ActiveGroups = Logic_MainTask.GetActiveGroups()
  if self.MainTaskWorldMode[LogicTeam.GetWorldId()] then
    for i, value in ipairs(self.ActiveGroups) do
      print("MainTaskWorldMode", value, self.MainTaskWorldMode[LogicTeam.GetWorldId()])
      if value == self.MainTaskWorldMode[LogicTeam.GetWorldId()] then
        self.ActiveIndex = i
      end
    end
  end
  EventSystem.AddListener(self, EventDef.MainTask.OnMainTaskRefres, WBP_MainTask_C.OnMainTaskRefres)
  EventSystem.Invoke(EventDef.MainTask.OnMainTaskRefres)
end

function WBP_MainTask_C:OnMainTaskRefres()
  self.ActiveGroups = Logic_MainTask.GetActiveGroups()
  UpdateVisibility(self.WBP_Selector, #self.ActiveGroups > 1)
  UpdateVisibility(self.WBP_MainTask_Item, #self.ActiveGroups > 0)
  self.WBP_Selector:InitSelector(#self.ActiveGroups, self.ActiveIndex, function(Index)
    self.ActiveIndex = Index
    self:SelectIndex(Index)
  end)
  self:SelectIndex(self.ActiveIndex)
end

function WBP_MainTask_C:SelectIndex(Index)
  for i, value in ipairs(self.ActiveGroups) do
    if i == Index then
      self.WBP_MainTask_Item:InitMainTaskItem(value)
      return
    end
  end
end

function WBP_MainTask_C:CheckMainTaskUnLockTip(Id)
  local FilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/MainTask/" .. DataMgr.GetUserId() .. "Cache.txt"
  local OutString = ""
  local Result, FileStr = UE.URGBlueprintLibrary.LoadFileToString(FilePath, nil)
  local GroupIds = Split(FileStr, "|")
  if table.Contain(GroupIds, tostring(Id)) then
    return false
  end
  table.insert(GroupIds, tostring(Id))
  local OutStr = "0"
  for key, value in pairs(GroupIds) do
    if tonumber(value) then
      OutStr = OutStr .. "|" .. value
    end
  end
  UE.URGBlueprintLibrary.SaveStringToFile(FilePath, OutStr)
  return true
end

return WBP_MainTask_C
