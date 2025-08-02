local WBP_WeaponHandBookAccessoryTips_C = UnLua.Class()
local WeaponDescItemClsPath = "/Game/Rouge/UI/Lobby/WeaponHandBook/WBP_WeaponHandBookAccessoryDescItem.WBP_WeaponHandBookAccessoryDescItem_C"
local AccessaryItemPath = "/Game/Rouge/UI/Lobby/WeaponHandBook/WBP_WeaponHandBookParts.WBP_WeaponHandBookParts_C"

function WBP_WeaponHandBookAccessoryTips_C:Construct()
  self.RGToggleGroupAccessory.OnCheckStateChanged:Add(self, WBP_WeaponHandBookAccessoryTips_C.BindOnAccessoryCheckChanged)
end

function WBP_WeaponHandBookAccessoryTips_C:Destruct()
  self.RGToggleGroupAccessory.OnCheckStateChanged:Remove(self, WBP_WeaponHandBookAccessoryTips_C.BindOnAccessoryCheckChanged)
end

function WBP_WeaponHandBookAccessoryTips_C:InitInfo(AccessoryId, bIsAdditionalDescTipsLeft)
  self.AccessoryId = AccessoryId
  local AccessaryItemCls = UE.UClass.Load(AccessaryItemPath)
  local Result, AccessoryData = LogicWeaponHandBook:GetAccessoryById(self.AccessoryId)
  local Index = 1
  local FirstId = -1
  self.RGToggleGroupAccessory:ClearGroup()
  if AccessoryData then
    for i = UE.ERGItemRarity.EIR_Normal, UE.ERGItemRarity.EIR_Max do
      local bIsSpecify = i == UE.ERGItemRarity.EIR_Excellent or i == UE.ERGItemRarity.EIR_Rare or i == UE.ERGItemRarity.EIR_Legend
      local AccessoryInscription = AccessoryData.InscriptionMap:FindRef(i)
      if AccessoryInscription and bIsSpecify then
        local Item = GetOrCreateItem(self.ScrollBoxAccessory, Index, AccessaryItemCls)
        if 1 == Index then
          FirstId = i
        end
        Index = Index + 1
        Item:Init(AccessoryId, i)
        self.RGToggleGroupAccessory:AddToGroup(i, Item)
      end
    end
  end
  HideOtherItem(self.ScrollBoxAccessory, Index)
  if FirstId > 0 then
    self.RGToggleGroupAccessory:SelectId(FirstId)
  end
  UpdateVisibility(self.VerticalBoxDesc, self.AccessoryId > 0)
  local TipsCanvasSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_WeaponHandBookAccessoryAdditionalDescTips)
  if TipsCanvasSlot then
    if bIsAdditionalDescTipsLeft then
      TipsCanvasSlot:SetPosition(self.LeftPos)
    else
      TipsCanvasSlot:SetPosition(self.RightPos)
    end
  end
end

function WBP_WeaponHandBookAccessoryTips_C:BindOnAccessoryCheckChanged(SelectIdex)
  UpdateVisibility(self.VerticalBoxDesc, true)
  local WeaponDescItemCls = UE.UClass.Load(WeaponDescItemClsPath)
  local Result, AccessoryData = LogicWeaponHandBook:GetAccessoryById(self.AccessoryId)
  if AccessoryData then
    local AccessoryInscription = AccessoryData.InscriptionMap:FindRef(SelectIdex)
    if AccessoryInscription then
      self.WBP_WeaponHandBookAccessoryAdditionalDescTips:InitInfo(AccessoryInscription)
      local Index = 1
      for i, v in iterator(AccessoryInscription.Inscriptions) do
        local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
        if v and v.bIsShowInUI and RGLogicCommandDataSubsystem then
          local OutString = GetLuaInscriptionDesc(v.InscriptionId, 0)
          local Item = GetOrCreateItem(self.VerticalBoxDesc, Index, WeaponDescItemCls)
          Item:Init(OutString)
          Index = Index + 1
        end
      end
    end
  end
end

function WBP_WeaponHandBookAccessoryTips_C:Select(WeaponBarrelIdParam)
end

return WBP_WeaponHandBookAccessoryTips_C
