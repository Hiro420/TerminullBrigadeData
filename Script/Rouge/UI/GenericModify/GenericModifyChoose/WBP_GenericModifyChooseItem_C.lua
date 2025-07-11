local GenericModifyConfig = require("GameConfig.GenericModify.GenericModifyConfig")
local WBP_GenericModifyChooseItem_C = UnLua.Class()
local CustomZOrder = GetCustomZOrderByLayer(UE.ECustomLayer.ELayer_HttpLoading)
local EModifyTypeStatus = {
  Normal = 1,
  LvUp = 2,
  Specific = 3
}
function WBP_GenericModifyChooseItem_C:Construct()
  self.BP_ButtonWithSoundSelect.OnClicked:Add(self, self.Select)
  self.BP_ButtonWithSoundSelect.OnHovered:Add(self, self.OnHovered)
  self.BP_ButtonWithSoundSelect.OnUnhovered:Add(self, self.OnUnhovered)
  EventSystem.AddListener(self, EventDef.GenericModify.OnRefreshGenericModify, self.Refresh)
end
function WBP_GenericModifyChooseItem_C:OnUnDisplay()
  self.ParentView = nil
  self.ModifyId = -1
  self.bIsInShop = false
  self.ModifyChooseType = ModifyChooseType.None
  self.Idx = -1
  self.RarityUpModifyData = nil
  self:StopAnimation(self.Ani_flushed)
end
function WBP_GenericModifyChooseItem_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_GenericModifyTips_close then
    local PC = self:GetOwningPlayer()
    if PC and PC.MiscHelper then
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChooseSell_C.UIName)
      PC.MiscHelper:GenericModifySell(ChoosePanel.InteractComp, {
        self.ModifyId
      })
      self.Selling = false
      PlaySound2DEffect(50003)
    end
  elseif Animation == self.Ani_Sell_flushed then
    UpdateVisibility(self.BP_ButtonWithSoundSelect, true, true)
  end
end
function WBP_GenericModifyChooseItem_C:InitGenericModifyChooseItem(ModifyData, ModifyChooseTypeParam, HoverFunc, ParentView, bIsInShop)
  self:StopAnimation(self.Ani_flushed)
  local ModifyId = ModifyData
  if ModifyChooseTypeParam == ModifyChooseType.RarityUpModify then
    ModifyId = ModifyData.Key
    self.RarityUpModifyData = ModifyData
  else
    ModifyId = ModifyData
  end
  UpdateVisibility(self.Img_Movie, false)
  UpdateVisibility(self.Movie, false)
  UpdateVisibility(self.WBP_GenericModifyTips.WBP_FocusOnMarkWidget, true)
  UpdateVisibility(self.WBP_GenericModifyChooseItemHover_Group_sell, false)
  self.WBP_GenericModifyChooseItemHover_Group_sell:StopAnimation(self.WBP_GenericModifyChooseItemHover_Group_sell.Ani_click)
  print("LJSInitGenericModifyChooseItem")
  self.ModifyChooseType = ModifyChooseTypeParam
  self.HoverFunc = HoverFunc
  self.ParentView = ParentView
  self.ModifyId = ModifyId
  self.bIsInShop = bIsInShop
  self.bSell = self.ModifyChooseType == ModifyChooseType.GenericModifySell
  local bIsUpgrade = self.ModifyChooseType == ModifyChooseType.UpgradeModify or ModifyChooseType.DoubleGenericModifyUpgrade == self.ModifyChooseType or self.ModifyChooseType == ModifyChooseType.SurvivalUpgradeModify
  if self.bSell then
    self.WBP_GenericModifyTips:InitGenericModifyTipsBySell(ModifyId, bIsUpgrade, self)
  else
    self.WBP_GenericModifyTips:InitGenericModifyTips(ModifyId, bIsUpgrade, self, self.ModifyChooseType)
  end
  UpdateVisibility(self.AutoLoad_RecommendMark, false)
  if ModifyChooseTypeParam == ModifyChooseType.GenericModify and UE.RGUtil.IsUObjectValid(self.ParentView) and UE.RGUtil.IsUObjectValid(self.ParentView.InteractComp) then
    local beginnerBuildId = self.ParentView.InteractComp.BeginnerBuildId
    local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem.StaticClass())
    if beginnerBuildId and beginnerBuildId > 0 and GameLevelSystem then
      local worldIdx = GameLevelSystem.WorldInfo.CurrentWorldIndex
      local levelIdx = GameLevelSystem.WorldInfo.CurrentLevelIndex
      local recommendedGenericModifyId = LogicGenericModify:GetRecommendGenericId(beginnerBuildId, worldIdx, levelIdx)
      if recommendedGenericModifyId == ModifyId then
        UpdateVisibility(self.AutoLoad_RecommendMark, true)
      end
    end
  end
  self.bCanSelect = false
  self.URGImageSelect:SetRenderOpacity(1)
  self.select_glow:SetRenderOpacity(1)
  self.URGImageSelect_1:SetRenderOpacity(1)
  if bIsUpgrade then
    self:UpdateHoverColor(self.ComHoverColor)
    self.StateCtrl_ModifyType:ChangeStatus(EModifyTypeStatus.LvUp)
  else
    local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(self.ModifyId))
    if ResultGenericModify then
      local color = GenericModifyConfig.GroupIdToHoverColor[tostring(GenericModifyRow.GroupId)]
      self:UpdateHoverColor(color)
    end
  end
  self.StateCtrl_ModifyType:ChangeStatus(EModifyTypeStatus.Normal)
end
function WBP_GenericModifyChooseItem_C:InitGenericModifyChooseItemByBattleLagacy(ModifyId, ParentView, Idx)
  self.bCanSelect = false
  UpdateVisibility(self.Img_Movie, false)
  UpdateVisibility(self.Movie, false)
  self.ParentView = ParentView
  self.ModifyId = tonumber(ModifyId)
  self.bIsInShop = false
  self.ModifyChooseType = ModifyChooseType.BattleLagacy
  self.Idx = Idx
  self.WBP_GenericModifyTips:InitGenericModifyTips(ModifyId, false, self)
  local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(self.ModifyId))
  if ResultGenericModify then
    local color = GenericModifyConfig.GroupIdToHoverColor[tostring(GenericModifyRow.GroupId)]
    self:UpdateHoverColor(color)
  end
end
function WBP_GenericModifyChooseItem_C:InitGenericModifyChooseItemByBattleLagacyReminder(ModifyId)
  self.bCanSelect = false
  UpdateVisibility(self.Img_Movie, false)
  UpdateVisibility(self.Movie, false)
  self.ParentView = nil
  self.ModifyId = tonumber(ModifyId)
  self.bIsInShop = false
  self.ModifyChooseType = ModifyChooseType.BattleLagacyReminder
  self.WBP_GenericModifyTips:InitGenericModifyTips(ModifyId, false, self)
  local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(self.ModifyId))
  if ResultGenericModify then
    local color = GenericModifyConfig.GroupIdToHoverColor[tostring(GenericModifyRow.GroupId)]
    self:UpdateHoverColor(color)
  end
  self:FadeIn()
end
function WBP_GenericModifyChooseItem_C:UpdateHoverColor(Color, GlowColor, Glow1Color)
  local glowColor = GlowColor or Color
  local glow1Color = Glow1Color or Color
  local matSelect1 = self.URGImageSelect_1:GetDynamicMaterial()
  if matSelect1 then
    matSelect1:SetVectorParameterValue("color", Color)
    matSelect1:SetScalarParameterValue("alpha", Color.A)
  end
  local mat = self.select_glow:GetDynamicMaterial()
  if mat then
    mat:SetVectorParameterValue("color", glowColor)
    mat:SetScalarParameterValue("alpha", glowColor.A)
  end
  local mat = self.select_glow_1:GetDynamicMaterial()
  if mat then
    mat:SetVectorParameterValue("color", glow1Color)
    mat:SetScalarParameterValue("alpha", glow1Color.A)
  end
end
function WBP_GenericModifyChooseItem_C:InitSpecificModifyChooseItem(ModifyId, ModifyChooseTypeParam, HoverFunc, ParentView, bRefresh)
  UpdateVisibility(self.Img_Movie, false)
  UpdateVisibility(self.Image_Movie_di, false)
  UpdateVisibility(self.Movie, false)
  print("WBP_GenericModifyChooseItem_C:InitSpecificModifyChooseItem", ModifyId, ModifyChooseTypeParam)
  self.bIsInShop = false
  self.ModifyChooseType = ModifyChooseTypeParam
  self.HoverFunc = HoverFunc
  self.ParentView = ParentView
  self.ModifyId = ModifyId
  self.WBP_GenericModifyTips:InitSpecificModifyTips(ModifyId)
  if not bRefresh then
    self.bCanSelect = false
  end
  self.URGImageSelect:SetRenderOpacity(1)
  self.select_glow:SetRenderOpacity(1)
  self.URGImageSelect_1:SetRenderOpacity(1)
  self.StateCtrl_ModifyType:ChangeStatus(EModifyTypeStatus.Specific)
  if ModifyChooseTypeParam == ModifyChooseType.SpecificModifyReplace then
    local color = GenericModifyConfig.GroupIdToHoverColor[tostring(0)]
    self:UpdateHoverColor(color, self.SpecificColor, self.SpecificGlow1Color)
  elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
    self:UpdateHoverColor(self.SpecificColor, nil, self.SpecificGlow1Color)
  elseif ModifyChooseTypeParam == ModifyChooseType.SurvivalSpecificModify then
    self:UpdateHoverColor(self.SpecificColor, nil, self.SpecificGlow1Color)
  end
end
function WBP_GenericModifyChooseItem_C:Select()
  if not LogicGenericModify.bCanOperator then
    print("WBP_GenericModifyChooseItem_C:Select LogicGenericModify.bCanOperator false")
    return
  end
  if self.bCanSelect == false then
    print("WBP_GenericModifyChooseItem_C:Select bCanSelect false")
    return
  end
  local bIsValidType = false
  if self.bIsInShop then
    print("WBP_GenericModifyChooseItem_C:Select IsInShop")
    if LogicGenericModify:CheckIsChangeModify(self.ModifyId, self.ModifyChooseType) then
      local Wnd = ShowWaveWindowWithDelegate(1167, {}, {
        GameInstance,
        function()
          if self then
            local shipNPC
            if UE.RGUtil.IsUObjectValid(self.ParentView) then
              shipNPC = self.ParentView.ShopNPC
            end
            LogicShop:ShopSelectPreviewModifyListEx(self.ModifyId, self.ModifyChooseType, shipNPC)
            print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify Shop", self.ModifyId)
          else
            print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify Shop self Is NIL")
          end
        end
      })
      if Wnd then
        local oldData, newData = LogicGenericModify:GetChangeModifyList(self.ModifyId)
        Wnd:InitGenericMsgWaveWindow(oldData, newData)
        Wnd:SetCustomZOrder(CustomZOrder)
      end
    elseif self then
      local shipNPC
      if UE.RGUtil.IsUObjectValid(self.ParentView) then
        shipNPC = self.ParentView.ShopNPC
      end
      LogicShop:ShopSelectPreviewModifyListEx(self.ModifyId, self.ModifyChooseType, shipNPC)
    end
  else
    local PC = self:GetOwningPlayer()
    print("WBP_GenericModifyChooseItem_C:Select IsNotInShop self.ModifyChooseType Is:", self.ModifyChooseType)
    if self.ModifyChooseType == ModifyChooseType.GenericModify then
      print("WBP_GenericModifyChooseItem_C:Select", self.ModifyId)
      if LogicGenericModify:CheckIsChangeModify(self.ModifyId, self.ModifyChooseType) then
        local Wnd = ShowWaveWindowWithDelegate(1167, {}, {
          GameInstance,
          function()
            if UE.RGUtil.IsUObjectValid(self) then
              LogicGenericModify:AddGenericModify(PC, self.ModifyId)
              if UE.RGUtil.IsUObjectValid(self.ParentView) then
                self.ParentView:SelectModifyId(self.ModifyId)
                self.ParentView:FinishInteractGenericModify()
                print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify", self.ModifyId)
                self.bCanSelect = false
              else
                print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify self.ParentView Is NIL")
              end
            else
              print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify self Is NIL")
            end
          end
        })
        if Wnd then
          local oldData, newData = LogicGenericModify:GetChangeModifyList(self.ModifyId)
          Wnd:InitGenericMsgWaveWindow(oldData, newData)
          Wnd:SetCustomZOrder(CustomZOrder)
        end
      else
        if not self.ModifyId then
          if UE.RGUtil.IsUObjectValid(self.ParentView) then
            LogicGenericModify:AddGenericModify(PC, -1)
            self.ParentView:SelectModifyId(-1)
            self.ParentView:FinishInteractGenericModify()
            print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify", self.ModifyId)
            self.bCanSelect = false
          else
            print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify self.ParentView Is NIL")
          end
          return
        end
        LogicGenericModify:AddGenericModify(PC, self.ModifyId)
        bIsValidType = true
      end
    elseif self.ModifyChooseType == ModifyChooseType.UpgradeModify then
      print("WBP_GenericModifyChooseItem_C:Select UpgradeModify", self.ModifyId)
      LogicGenericModify:UpgradeModify(PC, self.ModifyId)
      bIsValidType = true
    elseif self.ModifyChooseType == ModifyChooseType.SpecificModify then
      print("WBP_GenericModifyChooseItem_C:Select SpecificModify", self.ModifyId)
      LogicGenericModify:AddSpecificModify(PC, self.ModifyId)
      bIsValidType = true
    elseif self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
      print("WBP_GenericModifyChooseItem_C:Select ReplaceSpecificModify", self.ModifyId)
      local wnd = ShowWaveWindowWithDelegate(1219, {}, {
        GameInstance,
        function()
          if UE.RGUtil.IsUObjectValid(self) then
            local PCTemp = self:GetOwningPlayer()
            LogicGenericModify:ReplaceSpecificModify(PCTemp, self.ModifyId)
            if UE.RGUtil.IsUObjectValid(self.ParentView) then
              self.ParentView:SelectModifyId(self.ModifyId)
              self.ParentView:FinishInteractGenericModify()
              print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify SpecificReplace", self.ModifyId)
              self.bCanSelect = false
            end
          end
        end
      })
      if wnd then
        local curSpecificModify = LogicGenericModify:GetFirstSpecificModify()
        local curSpecificModifyID = 0
        if curSpecificModify then
          curSpecificModifyID = curSpecificModify.ModifyId
        end
        wnd:InitSpecificReplaceMsgWaveWindow(curSpecificModifyID, self.ModifyId)
      end
    elseif self.ModifyChooseType == ModifyChooseType.BattleLagacy then
      print("WBP_GenericModifyChooseItem_C:Select BattleLagacy", self.ModifyId)
      self.ParentView:SelectModifyId(self.ModifyId)
      LogicGenericModify:AddBattleLagacyModify(self.Idx - 1, self.ModifyId)
      bIsValidType = false
      self.bCanSelect = false
    elseif self.ModifyChooseType == ModifyChooseType.GenericModifySell then
      local RGWaveWindowManagr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
      if not RGWaveWindowManagr then
        return
      end
      if self.Selling then
        return
      end
      local WaveWindow = RGWaveWindowManagr:ShowWaveWindowWithDelegate(201001, {}, nil, {
        self,
        function()
          self:SellFunc()
        end
      })
    elseif self.ModifyChooseType == ModifyChooseType.DoubleGenericModifyUpgrade then
      print("WBP_GenericModifyChooseItem_C:Select DoubleGenericModifyUpgrade", self.ModifyId)
      self.ParentView:SelectModifyId(self.ModifyId)
      LogicGenericModify:DoubleGenericModifyUpgrade(self.ModifyId)
      bIsValidType = false
      self.bCanSelect = false
    elseif self.ModifyChooseType == ModifyChooseType.RarityUpModify then
      print("WBP_GenericModifyChooseItem_C:Select RarityUpModify", self.ModifyId)
      LogicGenericModify:UpgradeGenericModifyRarity(PC, self.ModifyId)
      bIsValidType = true
    elseif self.ModifyChooseType == ModifyChooseType.SurvivalAddModify then
      print("WBP_GenericModifyChooseItem_C:Select SurvivalModify", self.ModifyId)
      self.ParentView:SelectModifyId(self.ModifyId)
      LogicGenericModify:SurvivalAddModify(self.ModifyId)
    elseif self.ModifyChooseType == ModifyChooseType.SurvivalUpgradeModify then
      self.ParentView:SelectModifyId(self.ModifyId)
      LogicGenericModify:SurvivalUpgradeModify(self.ModifyId)
      bIsValidType = true
    elseif self.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
      self.ParentView:SelectModifyId(self.ModifyId)
      LogicGenericModify:SurvivalAddSpecificModify(self.ModifyId)
      bIsValidType = true
    end
  end
  if bIsValidType and self.ParentView and self.ParentView.FinishInteractGenericModify then
    self.ParentView:SelectModifyId(self.ModifyId)
    self.ParentView:FinishInteractGenericModify()
    print("WBP_GenericModifyChooseItem_C:Select FinishInteractGenericModify", self.ModifyId)
    self.bCanSelect = false
  end
end
function WBP_GenericModifyChooseItem_C:OnHovered()
  self:HoveredItem(self.ModifyId)
end
function WBP_GenericModifyChooseItem_C:OnUnhovered()
  self:UnhoveredItem(self.ModifyId)
end
function WBP_GenericModifyChooseItem_C:OnShowModifyChange(ModifyId)
  self:PlayAnimation(self.Ani_flushed)
  if self.ModifyChooseType == ModifyChooseType.UpgradeModify or self.ModifyChooseType == ModifyChooseType.SpecificModify then
    self.RGStateControllerChangeHover:ChangeStatus("common")
  else
    local result, modifyRow = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
    if result then
      self.RGStateControllerChangeHover:ChangeStatus(tostring(modifyRow.GroupId))
    else
      self.RGStateControllerChangeHover:ChangeStatus("common")
    end
  end
  UpdateVisibility(self.select_glow_1, true)
  local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if ResultGenericModify then
    local color = GenericModifyConfig.GroupIdToHoverColor[tostring(GenericModifyRow.GroupId)]
    self:UpdateHoverColor(color)
  else
    self:UpdateHoverColor(self.ComHoverColor)
  end
end
function WBP_GenericModifyChooseItem_C:OnHideModifyChange(ModifyId)
  self:PlayAnimation(self.Ani_flushed)
  UpdateVisibility(self.select_glow_1, false)
  self.RGStateControllerChangeHover:ChangeStatus(EHover.UnHover)
  local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if ResultGenericModify then
    local color = GenericModifyConfig.GroupIdToHoverColor[tostring(GenericModifyRow.GroupId)]
    self:UpdateHoverColor(color)
  else
    self:UpdateHoverColor(self.ComHoverColor)
  end
end
function WBP_GenericModifyChooseItem_C:HoveredItem(ModifyId)
  local screenX = UE.UWidgetLayoutLibrary.GetViewportSize(self).X
  local screenY = UE.UWidgetLayoutLibrary.GetViewportSize(self).Y
  local screenRate = screenX / screenY
  if NearlyEquals(screenRate, self.ScreenRate, 1.0E-6) then
    self.VerticalBoxAdditionNote:SetRenderScale(self.NoteScaleDPIAdapt)
  else
    self.VerticalBoxAdditionNote:SetRenderScale(UE.FVector2D(1, 1))
  end
  if self.bSell then
    if not self.WBP_GenericModifyChooseItemHover_Group_sell:IsPlayingAnimation() then
      UpdateVisibility(self.WBP_GenericModifyChooseItemHover_Group_sell, true)
    end
    UpdateVisibility(self.WBP_GenericModifyTips.URGImageHover, true)
    UpdateVisibility(self.WBP_GenericModifyTips.URGImageChangeBg_2, false)
    UpdateVisibility(self.WBP_GenericModifyTips.URGImage_6, false)
    return
  end
  if self.ModifyChooseType == ModifyChooseType.UpgradeModify then
    self.RGStateControllerChooseItemHover:ChangeStatus("common")
  elseif self.ModifyChooseType == ModifyChooseType.SpecificModify then
    self.RGStateControllerChooseItemHover:ChangeStatus("Specific")
  elseif self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace then
    self.RGStateControllerChooseItemHover:ChangeStatus("Specific")
    if UE.RGUtil.IsUObjectValid(self.ParentView) then
      self.ParentView:ShowSpecificModifyReplaceHover(true, self.ModifyId, true)
    end
  else
    local result, modifyRow = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
    if result then
      self.RGStateControllerChooseItemHover:ChangeStatus(tostring(modifyRow.GroupId))
    else
      self.RGStateControllerChooseItemHover:ChangeStatus("common")
    end
  end
  self:SetRenderScale(UE.FVector2D(1.01, 1.01) * self.ScaleOffset)
  self:PlayAnimation(self.ani_hover)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local bIsShowTips = false
  local slot = UE.ERGGenericModifySlot.None
  if self.ModifyChooseType == ModifyChooseType.GenericModify or self.ModifyChooseType == ModifyChooseType.UpgradeModify or self.ModifyChooseType == ModifyChooseType.BattleLagacy or self.ModifyChooseType == ModifyChooseType.BattleLagacyReminder or self.ModifyChooseType == ModifyChooseType.SpecificModify or self.ModifyChooseType == ModifyChooseType.RarityUpModify or self.ModifyChooseType == ModifyChooseType.SurvivalAddModify or self.ModifyChooseType == ModifyChooseType.SurvivalUpgradeModify or self.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
    local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(ModifyId), nil)
    if ResultGenericModify then
      bIsShowTips = self:UpdateAdditionNotes(GenericModifyRow.Inscription, ModifyId)
      slot = GenericModifyRow.Slot
      if self.HoverFunc and UE.ERGGenericModifySlot.None ~= GenericModifyRow.Slot then
        if self.HoverSlot then
          self.HoverFunc(self.ParentView, self.HoverSlot, false)
        end
        self.HoverSlot = GenericModifyRow.Slot
        self.HoverFunc(self.ParentView, GenericModifyRow.Slot, true)
      end
      if self.ModifyChooseType == ModifyChooseType.RarityUpModify then
        self:PlayAnimation(self.Ani_flushed, 0, 1, 0, 1, true)
        local newModifyId
        if self.RarityUpModifyData then
          newModifyId = self.RarityUpModifyData.Value
        end
        if newModifyId then
          local resultNewModify, newGenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(newModifyId), nil)
          if resultNewModify then
            bIsShowTips = self:UpdateAdditionNotes(newGenericModifyRow.Inscription, newModifyId)
          end
          self.WBP_GenericModifyTips:InitGenericModifyTips(newModifyId, false, self, self.ModifyChooseType)
        end
      end
    else
      bIsShowTips = self:UpdateAdditionNotes(ModifyId, ModifyId)
      slot = GenericModifyRow.Slot
      if self.HoverFunc and UE.ERGGenericModifySlot.None ~= GenericModifyRow.Slot then
        if self.HoverSlot then
          self.HoverFunc(self.ParentView, self.HoverSlot, false)
        end
        self.HoverSlot = GenericModifyRow.Slot
        self.HoverFunc(self.ParentView, GenericModifyRow.Slot, true)
      end
    end
  end
  UpdateVisibility(self.URGImageSelect, true)
  UpdateVisibility(self.select_glow, true)
  UpdateVisibility(self.URGImageSelect_1, true)
  self:RefresVideohInfo(ModifyId, slot)
  UpdateVisibility(self.CanvasPanelAdditionNote, bIsShowTips)
end
function WBP_GenericModifyChooseItem_C:UnhoveredItem(ModifyId)
  self:SetRenderScale(UE.FVector2D(1, 1) * self.ScaleOffset)
  UpdateVisibility(self.URGImageSelect, false)
  UpdateVisibility(self.select_glow, false)
  UpdateVisibility(self.CanvasPanelAdditionNote, false)
  UpdateVisibility(self.URGImageSelect_1, false)
  self:StopAnimation(self.ani_hover)
  self.RGStateControllerChooseItemHover:ChangeStatus(EHover.UnHover)
  if self.ModifyChooseType == ModifyChooseType.SpecificModifyReplace and UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowSpecificModifyReplaceHover(false, self.ModifyId, true)
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if self.ModifyChooseType == ModifyChooseType.GenericModify or self.ModifyChooseType == ModifyChooseType.UpgradeModify or self.ModifyChooseType == ModifyChooseType.BattleLagacy or self.ModifyChooseType == ModifyChooseType.BattleLagacyReminder or self.ModifyChooseType == ModifyChooseType.RarityUpModify then
    if self.HoverSlot then
      self.HoverFunc(self.ParentView, self.HoverSlot, false)
      self.HoverSlot = nil
    else
      local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(ModifyId), nil)
      if ResultGenericModify and self.HoverFunc and GenericModifyRow.Slot ~= UE.ERGGenericModifySlot.None then
        self.HoverFunc(self.ParentView, GenericModifyRow.Slot, false)
      end
    end
    if self.ModifyChooseType == ModifyChooseType.RarityUpModify then
      self.WBP_GenericModifyTips:InitGenericModifyTips(self.ModifyId, false, self, self.ModifyChooseType)
    end
  end
  if self.MediaPlayer then
    self.MediaPlayer:Close()
  end
  UpdateVisibility(self.Img_Movie, false)
  UpdateVisibility(self.Image_Movie_di, false)
  UpdateVisibility(self.Movie, false)
  if self.bSell then
    if not self.WBP_GenericModifyChooseItemHover_Group_sell:IsPlayingAnimation() then
      UpdateVisibility(self.WBP_GenericModifyChooseItemHover_Group_sell, false)
    end
    UpdateVisibility(self.WBP_GenericModifyTips.URGImageHover, false)
    UpdateVisibility(self.WBP_GenericModifyTips.URGImage_6, true)
    UpdateVisibility(self.WBP_GenericModifyTips.URGImageChangeBg_2, true)
  end
end
function WBP_GenericModifyChooseItem_C:OnMouseEnter(MyGeometry, MouseEvent)
end
function WBP_GenericModifyChooseItem_C:RefresVideohInfo(ModifyId, Slot, bIsSpecify)
  if self.ModifyChooseType == ModifyChooseType.GenericModify or self.ModifyChooseType == ModifyChooseType.UpgradeModify or self.ModifyChooseType == ModifyChooseType.BattleLagacy or self.ModifyChooseType == ModifyChooseType.BattleLagacyReminder or self.ModifyChooseType == ModifyChooseType.RarityUpModify then
    local Result, RowData = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
    if Result then
      self:RefreshMedia(RowData.MediaSoftPtr)
    end
  else
    local Result, RowData = GetRowData(DT.DT_ModRefresh, tostring(ModifyId))
    if Result then
      self:RefreshMedia(RowData.MediaSoftPtr)
    end
  end
end
function WBP_GenericModifyChooseItem_C:RefreshMedia(ObjRef)
  self.MediaPlayer:SetLooping(true)
  if ObjRef and UE.UKismetSystemLibrary.IsValidSoftObjectReference(ObjRef) then
    UpdateVisibility(self.Img_Movie, true)
    UpdateVisibility(self.Image_Movie_di, true)
    UpdateVisibility(self.Movie, true)
    local Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ObjRef)
    if Obj and Obj:Cast(UE.UFileMediaSource) then
      self.MediaPlayer:OpenSource(Obj)
      self.MediaPlayer:Rewind()
    end
  else
    UpdateVisibility(self.Img_Movie, false)
    UpdateVisibility(self.Image_Movie_di, false)
    UpdateVisibility(self.Movie, false)
  end
end
function WBP_GenericModifyChooseItem_C:UpdateAdditionNotes(Inscription, ModifyId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local bIsShowTips = false
  if not Inscription then
    return
  end
  local OutSaveData = GetLuaInscription(Inscription)
  if OutSaveData then
    local Index = 1
    if self:FocusSelf() and #Logic_IllustratedGuide.CurFocusGenericModifySubGroup > 0 then
      UpdateVisibility(self.WBP_GenericModifyPrefix, true)
      local NoteItem = GetOrCreateItem(self.VerticalBoxAdditionNote, Index, self.WBP_GenericModifyPrefix:GetClass())
      if NoteItem then
        NoteItem:InitGenericModifyPrefix(ModifyId)
        bIsShowTips = true
      end
    else
      UpdateVisibility(self.WBP_GenericModifyPrefix, false)
    end
    Index = Index + 1
    if OutSaveData.ModAdditionalNoteMap then
      for k, v in pairs(OutSaveData.ModAdditionalNoteMap) do
        local Result, ModAdditionalNoteRow = DTSubsystem:GetModAdditionalNoteTableRow(k, nil)
        if Result then
          local NoteItem = GetOrCreateItem(self.VerticalBoxAdditionNote, Index, self.WBP_GenericModifyAdditionNoteItem:GetClass())
          NoteItem:InitGenericModifyAdditionNote(ModAdditionalNoteRow)
          Index = Index + 1
          bIsShowTips = true
        end
      end
    end
    HideOtherItem(self.VerticalBoxAdditionNote, Index)
  end
  return bIsShowTips
end
function WBP_GenericModifyChooseItem_C:FadeIn()
  print("WBP_GenericModifyChooseItem_C:FadeIn()")
  self.CanvasPanelAdditionNote:SetRenderOpacity(0)
  self.URGImageSelect:SetRenderOpacity(0)
  self.select_glow:SetRenderOpacity(0)
  self.URGImageSelect_1:SetRenderOpacity(0)
  self.WBP_GenericModifyTips:SetRenderOpacity(0)
  self.CanvasPanel_0:SetRenderOpacity(1)
  self:PlayAnimation(self.AniFadeIn)
end
function WBP_GenericModifyChooseItem_C:FadeInFinished()
  print("WBP_GenericModifyChooseItem_C:FadeInFinished()")
  self.bCanSelect = true
  self.CanvasPanel_0:SetRenderOpacity(1)
end
function WBP_GenericModifyChooseItem_C:OnMouseLeave(MouseEvent)
end
function WBP_GenericModifyChooseItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_GenericModifyChooseItem_C:FadeOut(GroupId, bIsShowEffect)
  if UE.RGUtil.IsUObjectValid(self.ParentView) and self.ParentView.ModifyChooseType == ModifyChooseType.RarityUpModify then
    if bIsShowEffect then
      self:PlayAnimation(self.Ani_Upgrades_effect, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
    else
      self:PlayAnimation(self.ani_click, 0, 1, UE.EUMGSequencePlayMode.Forward, 2, true)
    end
    return
  end
  self:PlayAnimation(self.ani_click, 0, 1, UE.EUMGSequencePlayMode.Forward, 2, true)
  if bIsShowEffect then
    if UE.RGUtil.IsUObjectValid(self.ParentView) and self.ParentView.ModifyChooseType == ModifyChooseType.UpgradeModify and LogicGenericModify:CheckMultiLvUpgrade() then
      self.WBP_GenericModifyTips:PlayAnimation(self.WBP_GenericModifyTips.Ani_Upgrade_touch, 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
    end
    UpdateVisibility(self.AutoLoad_ChooseItem_Group_Common, false)
    self.AutoLoad_ChooseItem_Group_Common:StopAnimation("ani_click")
    self.AutoLoad_ChooseItem_Group_Common:StopAnimation("ani_click_upgrade")
    if GroupId then
      self.StateCtrl_GroupToEffect:ChangeStatus(tostring(GroupId))
    else
      self.StateCtrl_GroupToEffect:ChangeStatus("common")
      UpdateVisibility(self.AutoLoad_ChooseItem_Group_Common, true)
      if self.ModifyChooseType == ModifyChooseType.UpgradeModify then
        self.AutoLoad_ChooseItem_Group_Common:PlayAnimation("ani_click_upgrade", 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
      else
        self.AutoLoad_ChooseItem_Group_Common:PlayAnimation("ani_click", 0, 1, UE.EUMGSequencePlayMode.Forward, 2)
      end
    end
  end
end
function WBP_GenericModifyChooseItem_C:Destruct()
  self.HoverFunc = nil
  self.ParentView = nil
end
function WBP_GenericModifyChooseItem_C:FocusSelf()
  local Result = false
  local RowInfo = UE.FRGGenericModifyTableRow
  Result, RowInfo = GetRowData(DT.DT_GenericModify, self.ModifyId)
  if Result then
    for index, value in ipairs(Logic_IllustratedGuide.CurFocusGenericModifySubGroup) do
      if RowInfo.SubGroupId == value then
        return true
      end
      for k, v in pairs(Logic_IllustratedGuide.GenericModifySubGroup[value]) do
        local FocusResult = false
        local FocusRowInfo = UE.FRGGenericModifyTableRow
        FocusResult, FocusRowInfo = GetRowData(DT.DT_GenericModify, v)
        for key1, FrontConditions in pairs(FocusRowInfo.FrontConditions:ToTable()) do
          for index, SubGroupId in ipairs(FrontConditions.SubGroupIds:ToTable()) do
            if RowInfo.SubGroupId == SubGroupId then
              return true
            end
          end
        end
      end
    end
  end
  return false
end
function WBP_GenericModifyChooseItem_C:Refresh()
  UpdateVisibility(self.BP_ButtonWithSoundSelect, true, false)
  self:PlayAnimation(self.Ani_Sell_flushed, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1, true)
end
function WBP_GenericModifyChooseItem_C:SellFunc()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.SellTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.SellTimer)
  end
  if not self.WBP_GenericModifyChooseItemHover_Group_sell:IsPlayingAnimation() then
    UpdateVisibility(self.WBP_GenericModifyChooseItemHover_Group_sell, true)
  end
  self.WBP_GenericModifyChooseItemHover_Group_sell:PlayAnimation(self.WBP_GenericModifyChooseItemHover_Group_sell.Ani_click, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, true)
  self:PlayAnimation(self.Ani_GenericModifyTips_close)
  self.Selling = true
  self.SellTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
    end
  }, 0.9, false)
end
function WBP_GenericModifyChooseItem_C:ShowGold(ParentView)
  self.ParentView = ParentView
  UpdateVisibility(self.WBP_GenericModifyTips, false)
  self.bCanSelect = true
  self.ModifyChooseType = ModifyChooseType.GenericModify
  LogicGenericModify.bCanOperator = true
end
return WBP_GenericModifyChooseItem_C
