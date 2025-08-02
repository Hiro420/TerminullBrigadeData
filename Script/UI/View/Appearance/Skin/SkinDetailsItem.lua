local SkinData = require("Modules.Appearance.Skin.SkinData")
local BlackColorAsset = "/Game/Rouge/UI/Atlas/RoleMain/Frames/Icon_Swatches_03.Icon_Swatches_03"
local LightColorAsset = "/Game/Rouge/UI/Atlas/RoleMain/Frames/Icon_Swatches_04.Icon_Swatches_04"
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local EffectText = NSLOCTEXT("WBP_SkinView_C", "EffectText", "\231\137\185\230\149\136")
local UnlockPanelTitle = NSLOCTEXT("WBP_SkinView_C", "UnlockPanelTitle", "\232\167\163\233\148\129\231\161\174\232\174\164")
local UnlockPanelContent = NSLOCTEXT("WBP_SkinView_C", "UnlockPanelContent", "\230\152\175\229\144\166\232\138\177\232\180\185\228\187\165\228\184\139\232\181\132\230\186\144\232\167\163\233\148\129\227\128\144{0}\227\128\145?")
local SkillTipsClassPath = "/Game/Rouge/UI/Lobby/Role/WBP_RoleNormalSkillTip.WBP_RoleNormalSkillTip"
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end
local CheckHeroSkinCanEquip = function(self, SkinResId)
  local skinData
  local bEquiped = false
  for k, v in pairs(SkinData.HeroSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.HeroSkinTb.SkinID then
        skinData = vSkinData
        bEquiped = v.EquipedSkinId == vSkinData.HeroSkinTb.SkinID
        break
      end
    end
  end
  if not skinData or not skinData.bUnlocked then
    return false
  end
  if bEquiped then
    return false
  end
  return true
end
local CheckWeaponSkinCanEquip = function(self, SkinResId)
  local skinData
  local bEquiped = false
  for k, v in pairs(SkinData.WeaponSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.WeaponSkinTb.SkinID then
        skinData = vSkinData
        bEquiped = v.EquipedSkinId == vSkinData.WeaponSkinTb.SkinID
        break
      end
    end
  end
  if not skinData or not skinData.bUnlocked then
    return false
  end
  if bEquiped then
    return false
  end
  return true
end
local CheckHeroIsUnLock = function(self, HeroId)
  local ownHeros = DataMgr.GetMyHeroInfo()
  for i, heroInfo in ipairs(ownHeros.heros) do
    if HeroId == heroInfo.id then
      return true
    end
  end
  return false
end
local CheckHaveCustomSkin = function(self, SkinID)
  local ResID = GetTbSkinRowNameBySkinID(SkinID)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, ResID)
  if not Result then
    return false
  end
  return #RowInfo.AttachList > 0, RowInfo.AttachList
end
local CheckWeaponIsUnLock = function(self, WeaponId)
  local AllWeaponList = DataMgr.AllWeaponList
  for i, v in ipairs(AllWeaponList) do
    if tonumber(v.resourceId) == WeaponId then
      return true
    end
  end
  return false
end
local SkinDetailsItem = UnLua.Class()

function SkinDetailsItem:OnBindUIInput()
  if self.WBP_CommonButton_Main.KeyRowName ~= nil and self.WBP_CommonButton_Main.KeyRowName ~= "" then
    if IsListeningForInputAction(self, self.WBP_CommonButton_Main.KeyRowName) then
      StopListeningForInputAction(self, self.WBP_CommonButton_Main.KeyRowName, UE.EInputEvent.IE_Pressed)
    end
    ListenForInputAction(self.WBP_CommonButton_Main.KeyRowName, UE.EInputEvent.IE_Pressed, false, {
      self,
      self.OnAccessClick
    })
  end
end

function SkinDetailsItem:OnUnBindUIInput()
  if self.WBP_CommonButton_Main.KeyRowName ~= nil and self.WBP_CommonButton_Main.KeyRowName ~= "" then
    StopListeningForInputAction(self, self.WBP_CommonButton_Main.KeyRowName, UE.EInputEvent.IE_Pressed)
  end
end

function SkinDetailsItem:GetHeroSkinDataBySkinResId(SkinResId)
  for k, v in pairs(SkinData.HeroSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.HeroSkinTb.SkinID then
        return vSkinData
      end
    end
  end
  return nil
end

function SkinDetailsItem:GetWeaponSkinDataBySkinResId(SkinResId)
  for k, v in pairs(SkinData.WeaponSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.WeaponSkinTb.SkinID then
        return vSkinData
      end
    end
  end
  return nil
end

function SkinDetailsItem:Construct()
  self.Overridden.Construct(self)
  self.WBP_CommonButton_Equip.OnMainButtonClicked:Add(self, self.OnEquipClick)
  self.WBP_CommonButton_Main.OnMainButtonClicked:Add(self, self.OnAccessClick)
  self.WBP_CommonButton_Main.OnMainButtonHovered:Add(self, self.OnAccessHovered)
  self.WBP_CommonButton_Main.OnMainButtonUnhovered:Add(self, self.OnAccessUnhovered)
  self.Btn_Effect.OnHovered:Add(self, self.OnEffectHover)
  self.Btn_Effect.OnUnhovered:Add(self, self.OnEffectUnhover)
  self.Btn_Hide.OnClicked:Add(self, self.BindOnBtnHideClicked)
  self.Btn_Hide.OnHovered:Add(self, self.BindOnBtnHideHovered)
  self.Btn_Hide.OnUnhovered:Add(self, self.BindOnBtnHideUnhovered)
  self.Btn_Display.OnClicked:Add(self, self.BindOnBtnDisplayClicked)
  self.Btn_Display.OnHovered:Add(self, self.BindOnBtnDisplayHovered)
  self.Btn_Display.OnUnhovered:Add(self, self.BindOnBtnDisplayUnhovered)
  EventSystem.AddListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.OnGetHeroSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.OnGetWeaponSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnSetSkinEffectState, self, self.OnGetHeroSkinList)
  EventSystem.AddListenerNew(EventDef.Skin.OnEffectStateChange, self, self.OnEffectStateChange)
  EventSystem.AddListenerNew(EventDef.Lobby.WeaponListChanged, self, self.OnWeaponInfoChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.OnWeaponInfoChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.OnUpdateMyHeroInfo)
  EventSystem.AddListenerNew(EventDef.Heirloom.OnHeirloomInfoChanged, self, self.OnHeirloomInfoChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.RoleSkillTip, self, self.BindOnShowHeroSkillTips)
  EventSystem.AddListenerNew(EventDef.Weapon.WeaponSkillTip, self, self.BindOnShowWeaponSkillTips)
end

function SkinDetailsItem:Destruct()
  self.Overridden.Destruct(self)
  self.WBP_CommonButton_Equip.OnMainButtonClicked:Remove(self, self.OnEquipClick)
  self.WBP_CommonButton_Main.OnMainButtonClicked:Remove(self, self.OnAccessClick)
  self.WBP_CommonButton_Main.OnMainButtonHovered:Remove(self, self.OnAccessHovered)
  self.WBP_CommonButton_Main.OnMainButtonUnhovered:Remove(self, self.OnAccessUnhovered)
  self.Btn_Effect.OnHovered:Remove(self, self.OnEffectHover)
  self.Btn_Effect.OnUnhovered:Remove(self, self.OnEffectUnhover)
  self.Btn_Hide.OnClicked:Remove(self, self.BindOnBtnHideClicked)
  self.Btn_Hide.OnHovered:Remove(self, self.BindOnBtnHideHovered)
  self.Btn_Hide.OnUnhovered:Remove(self, self.BindOnBtnHideUnhovered)
  self.Btn_Display.OnClicked:Remove(self, self.BindOnBtnDisplayClicked)
  self.Btn_Display.OnHovered:Remove(self, self.BindOnBtnDisplayHovered)
  self.Btn_Display.OnUnhovered:Remove(self, self.BindOnBtnDisplayUnhovered)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.OnGetHeroSkinList)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.OnGetWeaponSkinList)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnSetSkinEffectState, self, self.OnGetHeroSkinList)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnEffectStateChange, self, self.OnEffectStateChange)
  EventSystem.RemoveListenerNew(EventDef.Lobby.WeaponListChanged, self, self.OnWeaponInfoChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.OnWeaponInfoChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateMyHeroInfo, self, self.OnUpdateMyHeroInfo)
  EventSystem.RemoveListenerNew(EventDef.Heirloom.OnHeirloomInfoChanged, self, self.OnHeirloomInfoChanged)
  EventSystem.RemoveListenerNew(EventDef.Lobby.RoleSkillTip, self, self.BindOnShowHeroSkillTips)
  EventSystem.RemoveListenerNew(EventDef.Weapon.WeaponSkillTip, self, self.BindOnShowWeaponSkillTips)
end

function SkinDetailsItem:OnHeirloomInfoChanged()
  self:UpdateEquipButton()
end

function SkinDetailsItem:OnGetHeroSkinList(HeroSkinList)
  self:UpdateEquipButton()
end

function SkinDetailsItem:OnEffectStateChange(EffectState, SkinId)
  self:SetEffectState(EffectState, SkinId)
end

function SkinDetailsItem:SetEffectState(EffectState, SkinId)
  local result, rowInfo = GetRowData(DT.DT_DisplaySkin, SkinId)
  if result then
    local Effects = rowInfo.Effects
    local EffectKeys = {}
    local SkinSystem = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.URGSkinSystem:StaticClass())
    for i, v in pairs(Effects:ToTable()) do
      if v.bDynamicCreate then
        table.insert(EffectKeys, v.NiagaraComponentKey)
      end
    end
    local Actor = GetAppearanceActor(self).ChildActor.ChildActor.ChildActor.ChildActor
    if EffectState then
      SkinSystem:CreateDynamicSubNiagaraComponent(Actor, EffectKeys)
    else
      SkinSystem:DestroyDynamic(Actor, EffectKeys)
    end
  end
end

function SkinDetailsItem:OnGetWeaponSkinList(WeaponSkinList)
  self:UpdateWeaponEquipButton()
end

function SkinDetailsItem:OnWeaponInfoChanged(SkinId, WeaponId)
  self:UpdateWeaponEquipButton()
end

function SkinDetailsItem:OnUpdateMyHeroInfo()
  self:UpdateEquipButton()
end

function SkinDetailsItem:SendEquipHeroSkinReq(HeroId, skinId)
  SkinHandler.SendEquipHeroSkinReq(HeroId, skinId)
end

function SkinDetailsItem:SendGetHeroSkinList()
  SkinHandler.SendGetHeroSkinList()
end

function SkinDetailsItem:SendEquipWeaponSkinReq(SkinId, WeaponId)
  SkinHandler.SendEquipWeaponSkinReq(SkinId, WeaponId)
end

function SkinDetailsItem:EquipWeaponSkin(SelectSkinResId)
  if self.ItemType ~= TableEnums.ENUMResourceType.WeaponSkin then
    return
  end
  if CheckWeaponSkinCanEquip(self, SelectSkinResId) then
    local weaponSkinData = self:GetWeaponSkinDataBySkinResId(self.CurSelectResId)
    local weaponResId = -1
    if weaponSkinData then
      weaponResId = weaponSkinData.WeaponSkinTb.WeaponID
    end
    local weaponInfo
    if weaponResId > 0 then
      weaponInfo = LogicOutsideWeapon.GetWeaponInfoByWeaponResId(weaponResId)
    end
    if weaponInfo then
      self:SendEquipWeaponSkinReq(SelectSkinResId, weaponInfo.uuid)
    end
  end
end

function SkinDetailsItem:CheckUnLockOriSkin(SkinResID)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, SkinResID)
  if result then
    local ParentSkinID = rowinfo.ParentSkinId
    local ParentSkinData = self:GetHeroSkinDataBySkinResId(ParentSkinID)
    return ParentSkinData.bUnlocked
  end
  return false
end

function SkinDetailsItem:CheckSkinCost(PackageID, SkinId)
  local OwnPackageNum = DataMgr.GetPackbackNumById(PackageID)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroSkinExchange, SkinId)
  if result then
    local NeedNum = rowinfo.CostResources[1].value
    return OwnPackageNum >= NeedNum
  end
  return false
end

function SkinDetailsItem:LinkPurchaseConfirm(LinkId, ParamList)
  if tonumber(LinkId) ~= 1007 then
    return false
  end
  ComLink(LinkId, nil, ParamList[2], ParamList[1], 1)
  return true
end

function SkinDetailsItem:OnAccessClick()
  if self.ItemType == TableEnums.ENUMResourceType.HeroSkin and not self.GoodsId then
    local heroSkinData = self:GetHeroSkinDataBySkinResId(self.CurSelectResId)
    if heroSkinData then
      if 0 ~= heroSkinData.HeroSkinTb.ParentSkinId then
        if self:CheckUnLockOriSkin(heroSkinData.HeroSkinTb.ID) then
          local Content = UE.FTextFormat(UnlockPanelContent, heroSkinData.HeroSkinTb.SkinName)
          local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroSkinExchange, heroSkinData.HeroSkinTb.SkinID)
          if Result then
            if self:CheckSkinCost(RowInfo.CostResources[1].key, heroSkinData.HeroSkinTb.SkinID) then
              UIMgr:ShowLink(ViewID.UI_CommonSmallPopups, nil, ECommonSmallPopupTypes.UnlockSchemePanel, UnlockPanelTitle, Content, RowInfo.CostResources[1].key, RowInfo.CostResources[1].value, heroSkinData.HeroSkinTb.SkinID)
            else
              local GoodsId = RowInfo.GoodsID
              local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMall, GoodsId)
              if result then
                local OwnPackageNum = DataMgr.GetPackbackNumById(RowInfo.CostResources[1].key)
                ComLink(1007, nil, GoodsId, rowinfo.Shelfs[1], nil, RowInfo.CostResources[1].value - OwnPackageNum)
                LogicLobby.ShowOrHideGround(true)
              end
            end
          end
        else
          ShowWaveWindow(308001)
        end
        return
      end
      if heroSkinData.HeroSkinTb.LinkId and heroSkinData.HeroSkinTb.LinkId ~= "" then
        if self:LinkPurchaseConfirm(heroSkinData.HeroSkinTb.LinkId, heroSkinData.HeroSkinTb.ParamList) then
          return
        end
        local result, row = GetRowData(DT.DT_CommonLink, heroSkinData.HeroSkinTb.LinkId)
        if result then
          local callback = function()
            if row.bHideOther and self.ParentView and self.ParentView.SkinDetailsCallBack then
              self.ParentView:SkinDetailsCallBack()
            end
          end
          if ViewID[row.UIName] == ViewID.UI_DevelopMain then
            ComLink(heroSkinData.HeroSkinTb.LinkId, callback, self.CurHeroId, self.CurHeroId)
          elseif tonumber(heroSkinData.HeroSkinTb.LinkId) == 1008 then
            ComLink(heroSkinData.HeroSkinTb.LinkId, callback, heroSkinData.HeroSkinTb.ParamList[1], heroSkinData.HeroSkinTb.ParamList[2], heroSkinData.HeroSkinTb.ParamList[3])
          elseif tonumber(heroSkinData.HeroSkinTb.LinkId) == 9999 then
            PandoraHandler.GoPandoraActivity(heroSkinData.HeroSkinTb.ParamList[1], "\232\167\146\232\137\178\231\154\174\232\130\164" .. tostring(heroSkinData.HeroSkinTb.SkinID))
          else
            if heroSkinData.HeroSkinTb.LinkId == "1005" or heroSkinData.HeroSkinTb.LinkId == "1023" or heroSkinData.HeroSkinTb.LinkId == "1015" then
              local luaInst = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
              if UE.RGUtil.IsUObjectValid(luaInst) then
                luaInst:ListenForEscInputAction(true)
              end
              EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, "LobbyLabel.LobbyMain")
            end
            ComLink(heroSkinData.HeroSkinTb.LinkId, callback, self.CurHeroId, heroSkinData.HeroSkinTb.ParamList)
          end
        end
      end
    end
  elseif self.ItemType == TableEnums.ENUMResourceType.WeaponSkin and not self.GoodsId then
    local weaponSkinData = self:GetWeaponSkinDataBySkinResId(self.CurSelectResId)
    if weaponSkinData and weaponSkinData.WeaponSkinTb.LinkId and "" ~= weaponSkinData.WeaponSkinTb.LinkId then
      if self:LinkPurchaseConfirm(weaponSkinData.WeaponSkinTb.LinkId, weaponSkinData.WeaponSkinTb.ParamList) then
        return
      end
      local result, row = GetRowData(DT.DT_CommonLink, weaponSkinData.WeaponSkinTb.LinkId)
      if result then
        local callback = function()
          if row.bHideOther and self.ParentView and self.ParentView.SkinDetailsCallBack then
            self.ParentView:SkinDetailsCallBack()
          end
        end
        if ViewID[row.UIName] == ViewID.UI_DevelopMain then
          ComLink(weaponSkinData.WeaponSkinTb.LinkId, callback, self.CurHeroId, self.CurHeroId)
        elseif 1008 == tonumber(weaponSkinData.WeaponSkinTb.LinkId) then
          ComLink(weaponSkinData.WeaponSkinTb.LinkId, callback, weaponSkinData.WeaponSkinTb.ParamList[1], weaponSkinData.WeaponSkinTb.ParamList[2], weaponSkinData.WeaponSkinTb.ParamList[3])
        elseif 9999 == tonumber(weaponSkinData.WeaponSkinTb.LinkId) then
          PandoraHandler.GoPandoraActivity(weaponSkinData.WeaponSkinTb.ParamList[1], "\230\173\166\229\153\168\231\154\174\232\130\164" .. tostring(weaponSkinData.WeaponSkinTb.SkinID))
        else
          if "1005" == weaponSkinData.WeaponSkinTb.LinkId or "1015" == weaponSkinData.WeaponSkinTb.LinkId or "1023" == weaponSkinData.WeaponSkinTb.LinkId then
            local luaInst = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
            if UE.RGUtil.IsUObjectValid(luaInst) then
              luaInst:ListenForEscInputAction(true)
            end
            local DevelopMainInst = UIMgr:GetLuaFromActiveView(ViewID.UI_DevelopMain)
            if UE.RGUtil.IsUObjectValid(DevelopMainInst) then
              DevelopMainInst.WBP_ViewSet:HideView(true)
            end
            EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, "LobbyLabel.LobbyMain")
          end
          ComLink(weaponSkinData.WeaponSkinTb.LinkId, callback, self.CurHeroId, weaponSkinData.WeaponSkinTb.ParamList)
        end
      end
    end
  elseif self.GoodsId then
    local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMall, self.GoodsId)
    ComLink(1007, nil, self.GoodsId, rowinfo.Shelfs[1], self.ItemAmount)
  end
end

function SkinDetailsItem:OnAccessHovered()
  self:StopAnimation(self.Ani_hover_out)
  self:PlayAnimation(self.Ani_hover_in, 0)
end

function SkinDetailsItem:OnAccessUnhovered()
  self:StopAnimation(self.Ani_hover_in)
  self:PlayAnimation(self.Ani_hover_out, 0)
end

function SkinDetailsItem:SelectHeroSkin(HeroSkinResId, bUpdateMovie)
  if self.ParentView and self.ParentView.SelectHeroSkin then
    self.ParentView:SelectHeroSkin(HeroSkinResId, bUpdateMovie)
  elseif self.ParentView and self.ParentView.WBP_ComShowGoodsItem then
    local ResID = GetTbSkinRowNameBySkinID(HeroSkinResId)
    self.ParentView.WBP_ComShowGoodsItem:InitCharacterSkin(ResID)
  end
end

function SkinDetailsItem:UpdateCustomSkinItemSelct(SkinID)
  for i, v in ipairs(self.SBox_CustomSkin:GetAllChildren():ToTable()) do
    v:SetSel(v.SkinID == SkinID)
  end
end

function SkinDetailsItem:OnEffectHover()
  if self.ItemType ~= TableEnums.ENUMResourceType.HeroSkin then
    return
  end
  local AttachID = self.CurSelectResId
  local SkinDataFromSoure = self:GetHeroSkinDataBySkinResId(self.CurSelectResId)
  if 0 ~= SkinDataFromSoure.HeroSkinTb.ParentSkinId then
    AttachID = SkinDataFromSoure.HeroSkinTb.ParentSkinId
  end
  local HeroEffectState = self:GetSpecialEffectStateByHeroID(self.CurHeroId)
  if HeroEffectState[tostring(AttachID)] then
    return
  end
  local ProEffType = TableEnums.ENUMResourceEffProType.NONE
  local ResultGenerl, RowGeneral = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, AttachID)
  if ResultGenerl then
    ProEffType = RowGeneral.ProEffType
  end
  local WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonTips.WBP_CommonTips_C"
  self.TipsWidget = ShowCommonTips(nil, self.Btn_Effect, nil, WidgetClassPath, nil, nil, UE.FVector2D(-40, 0))
  self.TipsWidget:ShowTips(EffectText, self.EffectContent, nil, nil, nil, nil, ProEffType)
end

function SkinDetailsItem:OnEffectUnhover()
  UpdateVisibility(self.TipsWidget, false)
end

function SkinDetailsItem:BindOnBtnDisplayClicked()
  if self.LocalEffectState then
    return
  end
  self:SwitchEffectState(true)
end

function SkinDetailsItem:BindOnBtnDisplayHovered()
  self.RGStateController_Display_Hover:ChangeStatus("Hover")
end

function SkinDetailsItem:BindOnBtnDisplayUnhovered()
  self.RGStateController_Display_Hover:ChangeStatus("UnHover")
end

function SkinDetailsItem:BindOnBtnHideClicked()
  if not self.LocalEffectState then
    return
  end
  self:SwitchEffectState(false)
end

function SkinDetailsItem:BindOnBtnHideHovered()
  self.RGStateController_Hide_Hover:ChangeStatus("Hover")
end

function SkinDetailsItem:BindOnBtnHideUnhovered()
  self.RGStateController_Hide_Hover:ChangeStatus("Hover")
end

function SkinDetailsItem:SwitchEffectState(IsShow)
  if self.ItemType ~= TableEnums.ENUMResourceType.HeroSkin then
    return
  end
  self.RGStateController_Display_Select:ChangeStatus(IsShow and "Select" or "Normal")
  self.RGStateController_Hide_Select:ChangeStatus(IsShow and "Normal" or "Select")
  self.LocalEffectState = IsShow
  local CurSkinData = self:GetHeroSkinDataBySkinResId(self.CurSelectResId)
  local EffectState = self:GetSpecialEffectStateByHeroID(self.CurHeroId)
  local AttachID = CurSkinData.HeroSkinTb.SkinID
  if EffectState == {} and self:CheckAllChildSkinUnlocked(CurSkinData.HeroSkinTb.ID) then
    EffectState[tostring(AttachID)] = 1
  end
  if 0 ~= CurSkinData.HeroSkinTb.ParentSkinId then
    AttachID = CurSkinData.HeroSkinTb.ParentSkinId
  end
  if EffectState[tostring(AttachID)] then
    self:SendSetSkinEffectState(IsShow and 1 or 0, AttachID)
  end
  local ShowActor = GetAppearanceActor(self).ChildActor.ChildActor.ChildActor.ChildActor
  LogicRole.SetEffectState(ShowActor, CurSkinData.HeroSkinTb.SkinID, nil, IsShow)
end

function SkinDetailsItem:SendSetSkinEffectState(EffectState, SkinID)
  SkinHandler.SendSetHeroSkinEffectState(EffectState, SkinID)
end

function SkinDetailsItem:OnEquipClick()
  if self.ItemType == TableEnums.ENUMResourceType.HeroSkin then
    self:SendEquipHeroSkinReq(self.CurHeroId, self.CurSelectResId)
  elseif self.ItemType == TableEnums.ENUMResourceType.WeaponSkin then
    self:EquipWeaponSkin(self.CurSelectResId)
  end
end

function SkinDetailsItem:UpdateEquipButton()
  if self.bDisableButtonPanel then
    self:ShowOrHideButtonPanel(false)
    return
  end
  if self.ItemType ~= TableEnums.ENUMResourceType.HeroSkin then
    return
  end
  local canEquip = CheckHeroSkinCanEquip(self, self.CurSelectResId)
  local ownHero = CheckHeroIsUnLock(self, self.CurHeroId)
  UpdateVisibility(self.CanvasPanelEquip, ownHero and canEquip)
  UpdateVisibility(self.CanvasPanelNeedUnLock, not ownHero and canEquip)
  if not ownHero and canEquip then
    UpdateVisibility(self.RGTextAccessDesc_3, true)
    UpdateVisibility(self.RGTextAccessDesc_4, false)
  end
  local isEquiping = SkinData.HeroSkinMap[self.CurHeroId] and SkinData.HeroSkinMap[self.CurHeroId].EquipedSkinId == self.CurSelectResId
  UpdateVisibility(self.CanvasPanelEquiping, isEquiping)
end

function SkinDetailsItem:GetHeroIDEquipID(curHeroId)
  return SkinData.HeroSkinMap[curHeroId].EquipedSkinId
end

function SkinDetailsItem:InitAttachBuyPanel(SkinId)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroSkinExchange, SkinId)
  if result then
    UpdateVisibility(self.ScaleBox_8, true)
    UpdateVisibility(self.WBP_Price_2, true)
    self.WBP_CommonButton_Main:SetStyleByBottomStyleRowName("Buy")
    self.WBP_Price_2:SetPrice(rowinfo.CostResources[1].value, nil, rowinfo.CostResources[1].key)
  end
end

function SkinDetailsItem:UpdateUIColor(SkinId)
  local result, row = GetRowData(DT.DT_DisplaySkinUIColor, SkinId)
  if not result then
    result, row = GetRowData(DT.DT_DisplaySkinUIColor, "Default")
  end
  if result then
    self.RGTextDetailsSkinName:SetColorAndOpacity(row.UIColor)
  end
end

function SkinDetailsItem:CheckAllChildSkinUnlocked(ResID)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, ResID)
  if Result then
    for i, v in pairs(RowInfo.AttachList) do
      local AttachSkinData = self:GetHeroSkinDataBySkinResId(v)
      if not AttachSkinData.bUnlocked then
        return false
      end
    end
    return true
  end
end

function SkinDetailsItem:UpdateHeroSkinDetailsView(HeroSkinData, AppearanceMovieList)
  if not HeroSkinData then
    return
  end
  if UE.RGUtil.IsUObjectValid(AppearanceMovieList) then
    local ShowSkinID = HeroSkinData.HeroSkinTb.SkinID
    self.WBP_AppearanceMoviePreview:UpdateMoviePreview(ShowSkinID, AppearanceMovieList)
  else
    self.WBP_AppearanceMoviePreview:UpdateMoviePreview(-1)
  end
  if self.GoodsId then
    self:UpdateBuyButton()
  elseif HeroSkinData.HeroSkinTb.LinkId and HeroSkinData.HeroSkinTb.LinkId ~= "" then
    self:InitBuyPanel(HeroSkinData.HeroSkinTb.LinkId, HeroSkinData.HeroSkinTb.ParamList[2], HeroSkinData.bUnlocked, HeroSkinData.HeroSkinTb.LinkDesc)
    if 0 ~= HeroSkinData.HeroSkinTb.ParentSkinId then
      self:InitAttachBuyPanel(HeroSkinData.HeroSkinTb.SkinID)
    end
  else
    UpdateVisibility(self.CanvasPanelButtonMain, false)
  end
  self:UpdateEquipButton()
  self.RGTextDetailsSkinName:SetText(HeroSkinData.HeroSkinTb.SkinName)
  self.RGTextDetailsSkinDesc:SetText(HeroSkinData.HeroSkinTb.Desc)
  self:UpdateDetailsSkinDescByGoodsId()
  local result, itemRarityRow = GetRowData(DT.DT_ItemRarity, tostring(HeroSkinData.HeroSkinTb.SkinRarity))
  if result then
    self.RGTextTag:SetText(itemRarityRow.DisplayName)
  end
  local resultRarity, rowRarity = GetRowData(DT.DT_ItemRarity, tostring(HeroSkinData.HeroSkinTb.SkinRarity))
  if resultRarity then
    self.URGImageTag:SetColorAndOpacity(rowRarity.SkinRareBgColor)
  end
  self:UpdateUIColor(tostring(HeroSkinData.HeroSkinTb.SkinID))
  local AttachID = HeroSkinData.HeroSkinTb.SkinID
  if 0 ~= HeroSkinData.HeroSkinTb.ParentSkinId then
    AttachID = HeroSkinData.HeroSkinTb.ParentSkinId
  end
  local HaveCustomSkin, SkinList = CheckHaveCustomSkin(self, AttachID)
  UpdateVisibility(self.SBox_CustomSkin, HaveCustomSkin or 0 ~= HeroSkinData.HeroSkinTb.ParentSkinId)
  UpdateVisibility(self.Overlay_EffectToggle, HaveCustomSkin or 0 ~= HeroSkinData.HeroSkinTb.ParentSkinId)
  UpdateVisibility(self.CanvasPanel_DefaultSkin, false)
  if HaveCustomSkin then
    local index = 1
    local EquipSkinId = self:GetHeroIDEquipID(HeroSkinData.HeroSkinTb.CharacterID)
    local DefaultSkinID = HeroSkinData.HeroSkinTb.SkinID
    if 0 ~= HeroSkinData.HeroSkinTb.ParentSkinId then
      DefaultSkinID = HeroSkinData.HeroSkinTb.ParentSkinId
    end
    self.OldEffectState = self.EffectState
    self.EffectState = self:GetSpecialEffectStateByHeroID(self.CurHeroId)
    if self.EffectState == {} and self:CheckAllChildSkinUnlocked(HeroSkinData.HeroSkinTb.ID) then
      self.EffectState[tostring(AttachID)] = 1
    end
    if self.OldEffectState and not self.OldEffectState[tostring(AttachID)] and self.EffectState[tostring(AttachID)] then
      self:PlayAnimation(self.Ani_unlock)
    end
    UpdateVisibility(self.Img_Lock, not self.EffectState[tostring(AttachID)])
    local AttachSkinData = self:GetHeroSkinDataBySkinResId(AttachID)
    UpdateVisibility(self.CanvasPanel_DefaultSkin, not AttachSkinData.bUnlocked and AttachID ~= HeroSkinData.HeroSkinTb.SkinID)
    if self.EffectState[tostring(AttachID)] then
      self.LocalEffectState = 1 == self.EffectState[tostring(AttachID)]
      self.RGStateController_Hide_Select:ChangeStatus(1 == self.EffectState[tostring(AttachID)] and "Normal" or "Select")
      self.RGStateController_Display_Select:ChangeStatus(1 == self.EffectState[tostring(AttachID)] and "Select" or "Normal")
      local ShowActor = GetAppearanceActor(self).ChildActor.ChildActor.ChildActor.ChildActor
      LogicRole.SetEffectState(ShowActor, HeroSkinData.HeroSkinTb.SkinID, nil, 1 == self.EffectState[tostring(AttachID)])
    else
      self.RGStateController_Display_Select:ChangeStatus(self.LocalEffectState and "Select" or "Normal")
      self.RGStateController_Hide_Select:ChangeStatus(self.LocalEffectState and "Normal" or "Select")
      local ShowActor = GetAppearanceActor(self).ChildActor.ChildActor.ChildActor.ChildActor
      LogicRole.SetEffectState(ShowActor, HeroSkinData.HeroSkinTb.SkinID, nil, self.LocalEffectState)
    end
    local item = GetOrCreateItem(self.SBox_CustomSkin, index, self.WBP_CustomSkinItem:GetClass())
    item:InitInfo(DefaultSkinID, self, true)
    local DefaultSkinData = self:GetHeroSkinDataBySkinResId(DefaultSkinID)
    UpdateVisibility(item.Overlay_Lock, false)
    UpdateVisibility(item.Txt_Default, true)
    item:SetEquip(DefaultSkinID == EquipSkinId)
    item:SetSel(DefaultSkinID == HeroSkinData.HeroSkinTb.SkinID)
    index = index + 1
    UpdateVisibility(self.Overlay_EffectToggle, DefaultSkinData.HeroSkinTb.HaveEffect)
    for i, v in ipairs(SkinList) do
      local item = GetOrCreateItem(self.SBox_CustomSkin, index, self.WBP_CustomSkinItem:GetClass())
      item:InitInfo(v, self, false)
      local AttachSkinData = self:GetHeroSkinDataBySkinResId(v)
      item:SetUnLock(AttachSkinData.bUnlocked)
      item:SetEquip(AttachSkinData.HeroSkinTb.SkinID == EquipSkinId)
      item:SetSel(HeroSkinData.HeroSkinTb.SkinID == v)
      SetImageBrushByPath(item.Icon_Normal, AttachSkinData.HeroSkinTb.IsLight and LightColorAsset or BlackColorAsset)
      index = index + 1
    end
  end
end

function SkinDetailsItem:GetSpecialEffectStateByHeroID(HeroID)
  local HeroInfo = DataMgr.GetMyHeroInfo()
  for i, HeroInfo in ipairs(HeroInfo.heros) do
    if HeroInfo.id == HeroID then
      return HeroInfo.specialEffectState
    end
  end
  return {}
end

function SkinDetailsItem:GetOldSpecialEffectStateByHeroID(HeroID)
  local HeroInfo = DataMgr.GetMyOldHeroInfo()
  for i, HeroInfo in ipairs(HeroInfo.heros) do
    if HeroInfo.id == HeroID then
      return HeroInfo.specialEffectState
    end
  end
  return {}
end

function SkinDetailsItem:ShowOrHideButtonPanel(bShow)
  self.bDisableButtonPanel = not bShow
  if not bShow then
    UpdateVisibility(self.CanvasPanelEquip, false)
    UpdateVisibility(self.CanvasPanelEquiping, false)
    UpdateVisibility(self.CanvasPanelNeedUnLock, false)
    UpdateVisibility(self.CanvasPanelButtonMain, false)
  end
end

function SkinDetailsItem:InitBuyPanel(LinkId, GoodsId, bUnlocked, AccessDesc)
  if self.bDisableButtonPanel then
    self:ShowOrHideButtonPanel(false)
    return
  end
  if bUnlocked then
    UpdateVisibility(self.CanvasPanelButtonMain, false)
    return
  end
  UpdateVisibility(self.WBP_Price_3, false)
  UpdateVisibility(self.WBP_Price_2, false)
  UpdateVisibility(self.CanvasPanelEquiping, false)
  UpdateVisibility(self.CanvasPanelEquiped, false)
  UpdateVisibility(self.CanvasPanelButtonMain, true)
  if tonumber(LinkId) == nil or 0 == tonumber(LinkId) then
    self.WBP_CommonButton_Main:SetStyleByBottomStyleRowName("UnAccess")
  elseif tonumber(LinkId) == 1007 then
    if self.GoodsId then
      AccessDesc = NSLOCTEXT("SkinDetailsItem", "LinkDescForSkinDetailsItem", "\232\180\173\228\185\176")
    end
    self.WBP_CommonButton_Main:SetStyleByBottomStyleRowName("Buy")
    self.WBP_CommonButton_Main:SetInfoText(AccessDesc)
    self.WBP_CommonButton_Main:SetContentText("")
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[GoodsId] then
      local GoodsInfo = TBMall[GoodsId]
      UpdateVisibility(self.WBP_Price_3, nil ~= GoodsInfo.ConsumeResources[1])
      self.WBP_Price_3:SetPrice(GoodsInfo.ConsumeResources[1].z, GoodsInfo.ConsumeResources[1].y, GoodsInfo.ConsumeResources[1].x)
      UpdateVisibility(self.WBP_Price_2, nil ~= GoodsInfo.ConsumeResources[2])
      if GoodsInfo.ConsumeResources[2] then
        self.WBP_Price_2:SetPrice(GoodsInfo.ConsumeResources[2].y, GoodsInfo.ConsumeResources[2].z, GoodsInfo.ConsumeResources[2].x)
      end
    end
  else
    self.WBP_CommonButton_Main:SetStyleByBottomStyleRowName("Access")
    self.WBP_CommonButton_Main:SetContentText(AccessDesc)
  end
end

function SkinDetailsItem:UpdateWeaponSkinDetailsView(WeaponSkinData, AppearanceMovieList)
  if UE.RGUtil.IsUObjectValid(AppearanceMovieList) then
    self.WBP_AppearanceMoviePreview:UpdateMoviePreview(WeaponSkinData.WeaponSkinTb.SkinID, AppearanceMovieList)
  else
    self.WBP_AppearanceMoviePreview:UpdateMoviePreview(-1)
  end
  if self.GoodsId then
    self:UpdateBuyButton()
  elseif WeaponSkinData.WeaponSkinTb.LinkId and WeaponSkinData.WeaponSkinTb.LinkId ~= "" then
    self:InitBuyPanel(WeaponSkinData.WeaponSkinTb.LinkId, WeaponSkinData.WeaponSkinTb.ParamList[2], WeaponSkinData.bUnlocked, WeaponSkinData.WeaponSkinTb.LinkDesc)
  else
    UpdateVisibility(self.CanvasPanelButtonMain, false)
  end
  self:UpdateWeaponEquipButton(WeaponSkinData.WeaponSkinTb.WeaponID)
  self.RGTextDetailsSkinName:SetText(WeaponSkinData.WeaponSkinTb.SkinName)
  self.RGTextDetailsSkinDesc:SetText(WeaponSkinData.WeaponSkinTb.Desc)
  self:UpdateDetailsSkinDescByGoodsId()
  UpdateVisibility(self.SBox_CustomSkin, false)
  UpdateVisibility(self.Overlay_EffectToggle, false)
  UpdateVisibility(self.CanvasPanel_DefaultSkin, false)
  local resultRarity, rowRarity = GetRowData(DT.DT_ItemRarity, tostring(WeaponSkinData.WeaponSkinTb.SkinRarity))
  if resultRarity then
    self.RGTextTag:SetText(rowRarity.DisplayName)
    self.URGImageTag:SetColorAndOpacity(rowRarity.SkinRareBgColor)
  end
  self:UpdateUIColor(tostring(WeaponSkinData.WeaponSkinTb.SkinID))
end

function SkinDetailsItem:GetWeaponResIdBySkinId(SkinId)
  return SkinData.GetWeaponResIdBySkinId(SkinId)
end

function SkinDetailsItem:UpdateWeaponEquipButton(WeaponSkinData)
  if self.bDisableButtonPanel then
    self:ShowOrHideButtonPanel(false)
    return
  end
  if self.ItemType ~= TableEnums.ENUMResourceType.WeaponSkin then
    return
  end
  local curSelectWeapon = WeaponSkinData
  curSelectWeapon = curSelectWeapon or self:GetWeaponSkinDataBySkinResId(self.CurSelectResId).WeaponSkinTb.WeaponID
  if curSelectWeapon then
    local canEquip = CheckWeaponSkinCanEquip(self, self.CurSelectResId)
    local ownWeapon = CheckWeaponIsUnLock(self, curSelectWeapon)
    UpdateVisibility(self.CanvasPanelEquip, ownWeapon and canEquip)
    UpdateVisibility(self.CanvasPanelNeedUnLock, not ownWeapon and canEquip)
    if not ownWeapon and canEquip then
      UpdateVisibility(self.RGTextAccessDesc_3, false)
      UpdateVisibility(self.RGTextAccessDesc_4, true)
    end
    local isEquiping = SkinData.WeaponSkinMap[curSelectWeapon].EquipedSkinId == self.CurSelectResId
    UpdateVisibility(self.CanvasPanelEquiping, isEquiping)
  end
end

function SkinDetailsItem:UpdateCommonDetailsView(ResourcesID)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local resourceData = TBGeneral[ResourcesID]
  local Re, Info = GetRowData(DT.DT_ItemRarity, TBGeneral[ResourcesID].Rare)
  self.URGImageTag:SetColorAndOpacity(Info.SkinRareBgColor)
  self.RGTextTag:SetText(Info.DisplayName)
  self.RGTextDetailsSkinName:SetText(resourceData.Name)
  self.RGTextDetailsSkinDesc:SetText(resourceData.Desc)
  self:UpdateDetailsSkinDescByGoodsId()
  if self.ItemType == TableEnums.ENUMResourceType.Weapon then
    self:RefreshWeaponSkill(ResourcesID)
  elseif self.ItemType == TableEnums.ENUMResourceType.HERO then
    self:RefreshHeroSkill(ResourcesID)
  end
  self:UpdateBuyButton()
end

function SkinDetailsItem:UpdateDetailsSkinDescByGoodsId()
  if self.GoodsId then
    local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMall, self.GoodsId)
    if result then
      self.RGTextDetailsSkinName:SetText(rowinfo.Name)
      self.RGTextDetailsSkinDesc:SetText(rowinfo.Desc)
    end
  end
end

function SkinDetailsItem:UpdateBuyButton()
  if self.GoodsId then
    self:InitBuyPanel(1007, self.GoodsId, self.bUnlocked, "")
  else
    UpdateVisibility(self.CanvasPanelButtonMain, false)
  end
end

function SkinDetailsItem:ResetAllPanel()
  self.WBP_AppearanceMoviePreview:UpdateMoviePreview(-1)
  UpdateVisibility(self.CanvasPanelButtonMain, false)
  UpdateVisibility(self.SBox_CustomSkin, false)
  UpdateVisibility(self.Overlay_EffectToggle, false)
  UpdateVisibility(self.CanvasPanelEquip, false)
  UpdateVisibility(self.CanvasPanelNeedUnLock, false)
  UpdateVisibility(self.CanvasPanelEquiping, false)
  UpdateVisibility(self.CanvasPanel_DefaultSkin, false)
  UpdateVisibility(self.VerticalBoxWeaponSkill, false)
  UpdateVisibility(self.WBP_CommonExpireAt, false)
  UpdateVisibility(self.CanvasHeroSkin, false)
  UpdateVisibility(self.ScaleBox_8, false)
end

function SkinDetailsItem:UpdateBuyButtonByGoodsId(GoodsId, bUnlocked)
  self.GoodsId = GoodsId
  self.bUnlocked = bUnlocked
  if self.OnlyShowBuyButton then
    self:ShowOrHideButtonPanel(not bUnlocked)
  end
  self:UpdateBuyButton()
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local resourceData = TBGeneral[self.ResourcesID]
  self.RGTextDetailsSkinName:SetText(resourceData.Name)
  self.RGTextDetailsSkinDesc:SetText(resourceData.Desc)
end

function SkinDetailsItem:UpdateDetailsView(ResourcesID, AppearanceMovieList, ParentView, bUnlocked, GoodsId, OnlyShowBuyButton, ItemAmount)
  UpdateVisibility(self.CanvasPanel_Limit, false)
  if not ResourcesID then
    return
  end
  self:InitProEff(ResourcesID)
  self:ResetAllPanel()
  if OnlyShowBuyButton then
    self:ShowOrHideButtonPanel(not bUnlocked)
  end
  self.OnlyShowBuyButton = OnlyShowBuyButton
  self.CurSelectResId = nil
  self.CurHeroId = nil
  self.bUnlocked = bUnlocked
  self.ParentView = ParentView
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local ItemType = TBGeneral[ResourcesID].Type
  self.ItemType = ItemType
  self.GoodsId = GoodsId
  self.ResourcesID = ResourcesID
  self.ItemAmount = ItemAmount or 0
  local resourceData = Logic_Mall.GetDetailRowDataByResourceId(ResourcesID)
  if self.ItemType == TableEnums.ENUMResourceType.HeroSkin then
    self.CurHeroId = resourceData.CharacterID
    self.CurSelectResId = resourceData.SkinID
    local heroSkinData = self:GetHeroSkinDataBySkinResId(self.CurSelectResId)
    if heroSkinData.expireAt and heroSkinData.expireAt ~= "0" then
      UpdateVisibility(self.WBP_CommonExpireAt, true)
      self.WBP_CommonExpireAt:InitCommonExpireAt(heroSkinData.expireAt)
    else
      UpdateVisibility(self.WBP_CommonExpireAt, false)
    end
    self:UpdateHeroSkinDetailsView(heroSkinData, AppearanceMovieList)
    if heroSkinData.HeroSkinTb.SpecialText or heroSkinData.HeroSkinTb.SpecialBgIcon then
      print(1)
    end
    UpdateVisibility(self.TXT_SpecialText, heroSkinData.HeroSkinTb.SpecialText ~= "")
    UpdateVisibility(self.TXT_SpecialText_1, heroSkinData.HeroSkinTb.SpecialText ~= "")
    UpdateVisibility(self.Img_BgIcon, heroSkinData.HeroSkinTb.SpecialBgIcon ~= "")
    self.TXT_SpecialText:SetText(heroSkinData.HeroSkinTb.SpecialText)
    self.TXT_SpecialText_1:SetText(heroSkinData.HeroSkinTb.SpecialText)
    SetImageBrushByPath(self.Img_BgIcon, heroSkinData.HeroSkinTb.SpecialBgIcon)
  elseif self.ItemType == TableEnums.ENUMResourceType.WeaponSkin then
    self.CurSelectResId = resourceData.SkinID
    self.CurHeroId = LogicOutsideWeapon.GetHeroIdByWeaponId(resourceData.WeaponID)
    local weaponSkinData = self:GetWeaponSkinDataBySkinResId(self.CurSelectResId)
    self:UpdateWeaponSkinDetailsView(weaponSkinData, AppearanceMovieList)
    if weaponSkinData.expireAt and weaponSkinData.expireAt ~= "0" then
      UpdateVisibility(self.WBP_CommonExpireAt, true)
      self.WBP_CommonExpireAt:InitCommonExpireAt(weaponSkinData.expireAt)
    else
      UpdateVisibility(self.WBP_CommonExpireAt, false)
    end
    UpdateVisibility(self.TXT_SpecialText, "" ~= weaponSkinData.WeaponSkinTb.SpecialText)
    UpdateVisibility(self.TXT_SpecialText_1, "" ~= weaponSkinData.WeaponSkinTb.SpecialText)
    UpdateVisibility(self.Img_BgIcon, "" ~= weaponSkinData.WeaponSkinTb.SpecialBgIcon)
    self.TXT_SpecialText:SetText(weaponSkinData.WeaponSkinTb.SpecialText)
    self.TXT_SpecialText_1:SetText(weaponSkinData.WeaponSkinTb.SpecialText)
    SetImageBrushByPath(self.Img_BgIcon, weaponSkinData.WeaponSkinTb.SpecialBgIcon)
  else
    UpdateVisibility(self.TXT_SpecialText, false)
    UpdateVisibility(self.TXT_SpecialText_1, false)
    UpdateVisibility(self.Img_BgIcon, false)
    self:UpdateCommonDetailsView(ResourcesID)
  end
end

function SkinDetailsItem:InitProEff(ItemID)
  local ItemId = tonumber(ItemID)
  if not ItemId then
    UpdateVisibility(self.AutoLoad_ComNameProEff, false)
    return
  end
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemId)
  if not Result then
    UpdateVisibility(self.AutoLoad_ComNameProEff, false)
    return
  end
  if Row.ProEffType == TableEnums.ENUMResourceEffProType.NONE then
    UpdateVisibility(self.AutoLoad_ComNameProEff, false)
    return
  end
  UpdateVisibility(self.AutoLoad_ComNameProEff, true)
  self.AutoLoad_ComNameProEff.ChildWidget:InitComProEff(ItemId)
end

function SkinDetailsItem:Hide()
end

function SkinDetailsItem:RefreshWeaponSkill(WeaponId)
  local Result, RowData = GetRowData(DT.DT_Weapon, tostring(WeaponId))
  local index = 1
  if Result and RowData.WeaponSkillDataAry:Num() > 0 then
    for i, v in iterator(RowData.WeaponSkillDataAry) do
      local item = GetOrCreateItem(self.VerticalBoxWeaponSkill, i, self.WBP_WeaponTipsSkillItem:GetClass())
      UpdateVisibility(item, true)
      item:RefreshWeaponTipsSkillItemInfo(v, i, true)
      index = index + 1
    end
  end
  UpdateVisibility(self.VerticalBoxWeaponSkill, true)
  HideOtherItem(self.VerticalBoxWeaponSkill, index)
end

function SkinDetailsItem:RefreshHeroSkill(ResourcesID)
  local TBHero = LuaTableMgr.GetLuaTableByName(TableNames.TBHero)
  if not TBHero[ResourcesID] then
    print("WBP_RoleMain_C:RefreshSkillInfo TBHero not found, ResourcesID:", ResourcesID)
    return
  end
  local HeroId = TBHero[ResourcesID].HeroID
  local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
  local AllSkillItems = self.SkillList:GetAllChildren()
  local SkillItemList = {}
  for i, SingleItem in pairs(AllSkillItems) do
    SkillItemList[SingleItem.Type] = SingleItem
  end
  local RoleStar = DataMgr.GetHeroLevelByHeroId(RowInfo.ID)
  for i, SingleSkillId in ipairs(RowInfo.SkillList) do
    local SkillRowInfo = LogicRole.GetSkillTableRow(SingleSkillId)
    if SkillRowInfo then
      local TargetSkillLevelInfo = SkillRowInfo[RoleStar]
      if TargetSkillLevelInfo then
        local Item = SkillItemList[TargetSkillLevelInfo.Type]
        if Item then
          Item:RefreshInfo(TargetSkillLevelInfo)
        end
      elseif SkillRowInfo[1] then
        local Item = SkillItemList[SkillRowInfo[1].Type]
        if Item then
          Item:RefreshInfo(SkillRowInfo[1])
        end
      else
        print("WBP_RoleMain_C:RefreshSkillInfo not found star1 info, skillgroupid:", SingleSkillId)
      end
    end
  end
  UpdateVisibility(self.CanvasHeroSkin, true)
end

function SkinDetailsItem:BindOnShowHeroSkillTips(IsShow, SkillGroupId, KeyName, SkillInputNameAry, inputNameAryPad, SkillItem)
  if IsShow then
    if not self:CheckSelfVisible() then
      return
    end
    self.NormalSkillTip = ShowCommonTips(nil, SkillItem, nil, SkillTipsClassPath)
    self.NormalSkillTip:RefreshInfo(SkillGroupId, KeyName, nil, SkillInputNameAry, inputNameAryPad)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.NormalSkillTip:SetRenderShear(self.SkillTipsShear)
  elseif self.NormalSkillTip then
    self.NormalSkillTip:Hide()
  end
end

function SkinDetailsItem:BindOnShowWeaponSkillTips(IsShow, WeaponSkillData, KeyName, SkillItem)
  if IsShow then
    if not self:CheckSelfVisible() then
      return
    end
    self.NormalSkillTip = ShowCommonTips(nil, SkillItem, nil, SkillTipsClassPath)
    self.NormalSkillTip:RefreshInfoByWeaponSkillData(WeaponSkillData, KeyName)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    self.NormalSkillTip:SetRenderShear(self.SkillTipsShear)
  elseif self.NormalSkillTip then
    self.NormalSkillTip:Hide()
  end
end

function SkinDetailsItem:CheckSelfVisible()
  if not self.ParentView or not self.ParentView:IsVisible() then
    return false
  end
  if self:GetParent() and not self:GetParent():IsVisible() then
    return false
  end
  return self:IsVisible()
end

function SkinDetailsItem:ShowLimit(LimitType, LimitProgress)
  UpdateVisibility(self.CanvasPanel_Limit, true)
  self.LimitTypeText:SetText(LimitType)
  self.LimitProgressText:SetText(LimitProgress)
end

function SkinDetailsItem:ChangeStatus(Status)
  self.RGStateController_Style:ChangeStatus(Status)
end

return SkinDetailsItem
