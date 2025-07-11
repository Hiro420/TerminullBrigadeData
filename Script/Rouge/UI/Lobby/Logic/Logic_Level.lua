local rapidjson = require("rapidjson")
Logic_Level = Logic_Level or {CurLevel = 1, CurLevelExp = 0}
local MaxLevel = 80
local LevelUpViewClsPath = "/Game/Rouge/UI/Grage/WBP_Grage.WBP_Grage_C"
function Logic_Level.Init()
  Logic_Level.CurLevel = 1
end
function Logic_Level.OnLevelUp(Exp)
  local NewLevel, NewExp = DataMgr.CalcUpLevel(Exp)
  local Info = DeepCopy(DataMgr.GetBasicInfo())
  Info.level = tostring(NewLevel)
  Info.exp = tostring(Exp + DataMgr.OldExp)
  DataMgr.SetBasicInfo(Info)
  local TargetLevel, SurplusExp = Logic_Level.CalcUpLevel(Exp)
  local OldLevel = Logic_Level.CurLevel
  local OldLevelExp = Logic_Level.CurLevelExp
  Logic_Level.CurLevel = TargetLevel
  Logic_Level.CurLevelExp = SurplusExp
  local RgUIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if RgUIManager then
    local LevelUpViewCls = UE.UClass.Load(LevelUpViewClsPath)
    local LevelUpView = RgUIManager:K2_GetUI(LevelUpViewCls)
    if LevelUpView and LevelUpView:IsShown() then
      LevelUpView:InitInfo(OldLevel, TargetLevel, OldLevelExp, SurplusExp)
    else
      RgUIManager:Switch(LevelUpViewCls)
      LevelUpView = RgUIManager:K2_GetUI(LevelUpViewCls)
      LevelUpView:InitInfo(OldLevel, TargetLevel, OldLevelExp, SurplusExp)
    end
  end
end
function Logic_Level.OnLevelUpNew(NewLevel, NewExp)
  local LobbyModule = ModuleManager:Get("LobbyModule")
  local viewData = {
    ViewID = ViewID.UI_LevelUp,
    Params = {
      tonumber(DataMgr.GetRoleLevel()),
      NewLevel,
      tonumber(DataMgr.GetExp()),
      NewExp
    }
  }
  LobbyModule:PushView(viewData)
end
function Logic_Level.HideSelf()
  UIMgr:Hide(ViewID.UI_LevelUp)
end
function Logic_Level.GetLevelTableRow(Level)
  return DataMgr.GetLevelTableRow(Level)
end
function Logic_Level.CalcUpLevel(Exp)
  return DataMgr.CalcUpLevel(Exp)
end
function Logic_Level.Clear()
end
