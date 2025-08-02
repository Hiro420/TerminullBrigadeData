local rapidjson = require("rapidjson")
local M = {IsInit = false}
_G.LogicAvatar = _G.LogicAvatar or M

function LogicAvatar.Init()
  LogicAvatar.AllItemList = {}
  LogicAvatar.DefaultAvatar = {}
  LogicAvatar.PreAvatarInfo = {}
  LogicAvatar.OtherMeshGenderList = {}
  LogicAvatar.AttactTypeList = {
    [UE.EAvatarPartType.Hair] = UE.EAvatarPartType.HairColor,
    [UE.EAvatarPartType.Tattoo] = UE.EAvatarPartType.TattooColor,
    [UE.EAvatarPartType.Face] = UE.EAvatarPartType.SkinColor
  }
  LogicAvatar.DealWithTable()
  LogicAvatar.RefreshDefaultAvatarData()
  LogicAvatar.CurGender = UE.EGender.Male
  local RGLobbySettings = UE.URGLobbySettings.GetLobbySettings()
  if RGLobbySettings then
    LogicAvatar.CurGender = RGLobbySettings.DefaultGender
  end
  EventSystem.AddListener(self, EventDef.Avatar.OnAvatarChooseItemClicked, LogicAvatar.BindOnAvatarChooseItemClicked)
end

function LogicAvatar.BindOnAvatarChooseItemClicked(Id, Type)
  LogicAvatar.SetPreAvatarInfoByType(Type, Id)
  if Type == UE.EAvatarPartType.MainBody then
    LogicAvatar.RefreshAvatarRoleAllMesh()
  else
    LogicAvatar.RefreshAvatarRoleById(Type, Id)
  end
end

function LogicAvatar.DealWithTable()
  local AllAvatarItemRowNames = GetDataLibraryObj().GetAllAvatarRowNames():ToTable()
  for index, SingleItemRowName in ipairs(AllAvatarItemRowNames) do
    local Result, RowInfo = GetDataLibraryObj().GetAvatarItemRowInfo(tonumber(SingleItemRowName))
    if Result and RowInfo.IsDefaultOwn then
      local TargetTypeList = LogicAvatar.AllItemList[RowInfo.Type]
      if TargetTypeList then
        table.insert(TargetTypeList, RowInfo.Id)
      else
        local TempTable = {}
        table.insert(TempTable, RowInfo.Id)
        LogicAvatar.AllItemList[RowInfo.Type] = TempTable
      end
      if RowInfo.Type ~= UE.EAvatarPartType.MainBody then
        local MeshDataList = {}
        if RowInfo.ConfigType == UE.EConfigType.Mesh then
          MeshDataList = RowInfo.MeshData:ToTable()
        elseif RowInfo.ConfigType == UE.EConfigType.Material then
          MeshDataList = RowInfo.MaterialData:ToTable()
        elseif RowInfo.ConfigType == UE.EConfigType.MaterialParam then
          MeshDataList = RowInfo.MaterialParamData:ToTable()
        end
        for Gender, SingleMeshData in pairs(MeshDataList) do
          if LogicAvatar.OtherMeshGenderList[Gender] then
            table.insert(LogicAvatar.OtherMeshGenderList[Gender], RowInfo.Id)
          else
            LogicAvatar.OtherMeshGenderList[Gender] = {
              RowInfo.Id
            }
          end
        end
      end
    end
  end
end

function LogicAvatar.RefreshDefaultAvatarData()
  local Index = UE.EAvatarPartType.None + 1
  for i = Index, UE.EAvatarPartType.TattooColor do
    local TargetTypeList = LogicAvatar.AllItemList[i]
    if not TargetTypeList or not TargetTypeList[1] then
      LogicAvatar.DefaultAvatar[i] = 0
    else
      LogicAvatar.DefaultAvatar[i] = TargetTypeList[1]
    end
  end
end

function LogicAvatar.GetDefaultAvatarDataByGender(Gender)
  local RGLobbySettings = UE.URGLobbySettings.GetLobbySettings()
  if not RGLobbySettings then
    return
  end
  local AvatarDefaultConfigList = RGLobbySettings.AvatarDefaultConfig:ToTable()
  return AvatarDefaultConfigList[Gender] and AvatarDefaultConfigList[Gender].Config:ToTable()
end

function LogicAvatar.GetPreAvatarInfo()
  return LogicAvatar.PreAvatarInfo
end

function LogicAvatar.SetPreAvatarInfo(InAvatarInfo)
  if not InAvatarInfo or next(InAvatarInfo) == nil or 0 == InAvatarInfo.MainBody then
    local DefaultAvatarConfig = LogicAvatar.GetDefaultAvatarDataByGender(LogicAvatar.CurGender)
    for Type, Id in pairs(DefaultAvatarConfig) do
      LogicAvatar.PreAvatarInfo[Type] = Id
    end
  else
    for Type, Id in pairs(InAvatarInfo) do
      LogicAvatar.PreAvatarInfo[Type] = Id
    end
  end
end

function LogicAvatar.SetPreAvatarInfoByType(Type, AvatarId)
  if Type == UE.EAvatarPartType.MainBody then
    local Result, RowInfo = GetDataLibraryObj().GetAvatarItemRowInfo(AvatarId)
    LogicAvatar.SetCurGender(RowInfo.Gender)
    local GenderMeshList = LogicAvatar.GetCurGenderMeshList()
    local DefaultAvatarConfig = LogicAvatar.GetDefaultAvatarDataByGender(LogicAvatar.CurGender)
    for Type, SingleId in pairs(LogicAvatar.PreAvatarInfo) do
      if Type ~= UE.EAvatarPartType.MainBody and not table.Contain(GenderMeshList, SingleId) then
        if not table.Contain(GenderMeshList, DefaultAvatarConfig[Type]) then
          LogicAvatar.PreAvatarInfo[Type] = 0
        else
          local TargetId = DefaultAvatarConfig[Type]
          LogicAvatar.PreAvatarInfo[Type] = TargetId
        end
        EventSystem.Invoke(EventDef.Avatar.OnPreAvatarInfoChanged, Type, LogicAvatar.PreAvatarInfo[Type])
      end
    end
  end
  LogicAvatar.PreAvatarInfo[Type] = AvatarId
  EventSystem.Invoke(EventDef.Avatar.OnPreAvatarInfoChanged, Type, AvatarId)
end

function LogicAvatar.RefreshAvatarRoleById(Type, Id)
  if not LogicAvatar.MainAvatarRole or not LogicAvatar.MainAvatarRole:IsValid() then
    local TargetActorList = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "MainAvatarRole", nil)
    for key, SingleActor in pairs(TargetActorList) do
      LogicAvatar.MainAvatarRole = SingleActor
      break
    end
  end
  LogicAvatar.MainAvatarRole:RefreshSkeletalMesh(Type, Id)
  local TargetType = LogicAvatar.AttactTypeList[Type]
  if TargetType then
    LogicAvatar.MainAvatarRole:RefreshSkeletalMesh(TargetType, LogicAvatar.PreAvatarInfo[TargetType])
  end
end

function LogicAvatar.RefreshAvatarRoleAllMesh()
  LogicAvatar.RefreshAvatarRoleById(UE.EAvatarPartType.MainBody, LogicAvatar.PreAvatarInfo[UE.EAvatarPartType.MainBody])
  for Type, Id in pairs(LogicAvatar.PreAvatarInfo) do
    if Type ~= UE.EAvatarPartType.MainBody then
      LogicAvatar.RefreshAvatarRoleById(Type, Id)
    end
  end
end

function LogicAvatar.RefreshTargetAllAvatarMesh(TargetActor, AvatarInfo)
  local TargetAvatarInfo = AvatarInfo
  if not AvatarInfo or next(AvatarInfo) == nil or 0 == AvatarInfo[UE.EAvatarPartType.MainBody] then
    local DefaultAvatarConfig = LogicAvatar.GetDefaultAvatarDataByGender(LogicAvatar.CurGender)
    for Type, Id in pairs(DefaultAvatarConfig) do
      TargetAvatarInfo[Type] = Id
    end
  end
  TargetActor:RefreshSkeletalMesh(UE.EAvatarPartType.MainBody, TargetAvatarInfo[UE.EAvatarPartType.MainBody])
  for Type, Id in pairs(TargetAvatarInfo) do
    if Type ~= UE.EAvatarPartType.MainBody then
      TargetActor:RefreshSkeletalMesh(Type, Id)
    end
  end
end

function LogicAvatar.SetCurGender(InGender)
  LogicAvatar.CurGender = InGender
end

function LogicAvatar.GetCurGender()
  return LogicAvatar.CurGender
end

function LogicAvatar.GetAllItemListByType(Type)
  return LogicAvatar.AllItemList[Type]
end

function LogicAvatar.GetCurGenderMeshList()
  return LogicAvatar.OtherMeshGenderList[LogicAvatar.CurGender]
end

function LogicAvatar.ShowAvatarPanel(SaveButtonFunction)
  local AllCameraActors = UE.UGameplayStatics.GetAllActorsWithTag(GameInstance, "AvatarMainCamera", nil)
  local TargetCamera
  for key, SingleCameraActor in pairs(AllCameraActors) do
    TargetCamera = SingleCameraActor
    break
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if TargetCamera then
    PC:SetViewTargetWithBlend(TargetCamera)
  end
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    local AvatarMainClassPath = "/Game/Rouge/UI/Lobby/Avatar/WBP_AvatarMain.WBP_AvatarMain_C"
    local AvatarMainClass = UE.UClass.Load(AvatarMainClassPath)
    UIManager:OpenUI(AvatarMainClass)
    local UI = UIManager:K2_GetUI(AvatarMainClass, nil)
    UI:SetSaveButtonFunction(SaveButtonFunction)
  end
end

function LogicAvatar.RequestSetAvatarInfoToServer(SuccessFunction)
  local PreAvatarInfo = LogicAvatar.GetPreAvatarInfo()
  local CurAvatarInfo = DataMgr.GetAvatarInfo()
  local Table = {}
  local IsNeedRequest = false
  for key, value in pairs(PreAvatarInfo) do
    if value ~= CurAvatarInfo[key] then
      IsNeedRequest = true
    end
    Table[tostring(key)] = value
  end
  if not IsNeedRequest then
    print("\230\149\176\230\141\174\228\184\128\230\160\183\239\188\140\230\151\160\233\156\128\228\191\174\230\148\185")
    return
  end
end

function LogicAvatar.Clear()
  LogicAvatar.IsInit = false
  LogicAvatar.AllItemList = {}
  LogicAvatar.DefaultAvatar = {}
  LogicAvatar.PreAvatarInfo = {}
  EventSystem.RemoveListener(EventDef.Avatar.OnAvatarChooseItemClicked, LogicAvatar.BindOnAvatarChooseItemClicked)
end
