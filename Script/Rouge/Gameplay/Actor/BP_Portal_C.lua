local Portal_C = UnLua.Class()
local bListened = false

function Portal_C:ReceiveBeginPlay()
  bListened = false
  ListenObjectMessage(nil, "Level.OnLevelEntry", self, self.GetPortalTexture, 1)
end

function Portal_C:GetPortalTexture()
  if bListened then
    return
  end
  bListened = true
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem.StaticClass())
  local DataTableSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem.StaticClass())
  local NextLevelID = GameLevelSystem:GetNextLevelID()
  if NextLevelID < 0 then
    print("Warning: Invalid NextLevelID " .. NextLevelID)
    return
  end
  local OutRow = UE.FWorldLevelTableRow()
  DataTableSubsystem:GetWorldLevelPoolTableRow(NextLevelID, OutRow)
  if not OutRow then
    print("Warning: Failed to get data row")
    return
  else
    print("Display: Succed to load texture ")
  end
  local AssetSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGAssetSubsystem.StaticClass())
  AssetSubsystem:AsyncLoadAsset(OutRow.PortalTexturePath, {
    self,
    self.UpdatePortalTexture
  }, "PortalTexture")
end

function Portal_C:UpdatePortalTexture(GroupName, TextureCube)
  if not TextureCube then
    print("Warning: Failed to load portal texture")
    return
  end
  local BoxMeshComponent = self:GetComponentByClass(UE.UStaticMeshComponent.StaticClass())
  if not BoxMeshComponent then
    print("Warning: Failed to get box mesh")
    return
  end
  local Material = BoxMeshComponent:GetMaterial(0)
  if not Material then
    print("Warning: Failed to get material")
    return
  end
  local MaterialSubsystem = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.URGMaterialSubsystem.StaticClass())
  local MID = UE.UKismetMaterialLibrary.CreateDynamicMaterialInstance(self:GetWorld(), Material)
  MID:SetTextureParameterValue("PortalTexture", TextureCube)
  BoxMeshComponent:SetMaterial(0, MID)
  print("Display: Succed to set portal texture")
end

return Portal_C
