local WBP_WeaponHandBookAccessoryAdditionalDescTips_C = UnLua.Class()
local WeaponDescItemClsPath = "/Game/Rouge/UI/Lobby/WeaponHandBook/WBP_WeaponHandBookAccessoryAdditionalDescItem.WBP_WeaponHandBookAccessoryAdditionalDescItem_C"
function WBP_WeaponHandBookAccessoryAdditionalDescTips_C:Construct()
end
function WBP_WeaponHandBookAccessoryAdditionalDescTips_C:Destruct()
end
function WBP_WeaponHandBookAccessoryAdditionalDescTips_C:InitInfo(AccessoryInscription)
  UpdateVisibility(self.VerticalBoxDesc, AccessoryInscription)
  local finalKeyArray = UE.TArray(0)
  if AccessoryInscription then
    for i, v in iterator(AccessoryInscription.Inscriptions) do
      local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
      if v and v.bIsShowInUI and RGLogicCommandDataSubsystem then
        local inscriptionInfo = GetLuaInscription(v.InscriptionId)
        if inscriptionInfo and inscriptionInfo.ModAdditionalNoteMap then
          for k, v in pairs(inscriptionInfo.ModAdditionalNoteMap) do
            finalKeyArray:Add(k)
          end
        else
          print("inscriptionInfo Is Null.")
        end
      end
    end
  end
  local Index = 1
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local WeaponDescItemCls = UE.UClass.Load(WeaponDescItemClsPath)
    for i, v in iterator(finalKeyArray) do
      local Result, RowInfo = DTSubsystem:GetModAdditionalNoteTableRow(v, nil)
      if Result then
        local Item = GetOrCreateItem(self.VerticalBoxDesc, Index, WeaponDescItemCls)
        Item.RGTextTitle:SetText(RowInfo.ModNoteTitle)
        Item.RGTextDesc:SetText(RowInfo.ModAdditionalNote)
        Index = Index + 1
      end
    end
  end
  HideOtherItem(self.VerticalBoxDesc, Index)
end
return WBP_WeaponHandBookAccessoryAdditionalDescTips_C
