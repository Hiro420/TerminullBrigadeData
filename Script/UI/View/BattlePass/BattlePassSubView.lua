local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local battlepassdata = require("Modules.BattlePass.BattlePassData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local URGBlueprintLibrary = UE.URGBlueprintLibrary
local ESlateVisibility = UE.ESlateVisibility
local BattlePassSubView = Class(ViewBase)
local PageNum = 5
local ShowEntryNum = 6.6
local UnLockPremiun = NSLOCTEXT("BattlePassSubView", "UnLockPremiun", "\232\167\163\233\148\129\233\171\152\231\186\167\233\128\154\232\161\140\232\175\129")
local UnLockUltra = NSLOCTEXT("BattlePassSubView", "UnLockUltra", "\232\167\163\233\148\129\229\133\184\232\151\143\233\128\154\232\161\140\232\175\129")
local LastTIme = NSLOCTEXT("BattlePassSubView", "LastTIme", "\229\137\169\228\189\153\230\151\182\233\151\180\239\188\154{0}\229\164\169{1}\229\176\143\230\151\182")
local TotalLevelAniDuration = 0.7
local BattlePassState = {
  Normal = 0,
  Premiun = 1,
  Ultra = 2
}
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end
function BattlePassSubView:BindClickHandler()
  self.RGListView_Award.ListViewScrolledChanged:Add(self, self.RGListView_Award_OnUserScrolled)
  self.Btn_Left.OnClicked:Add(self, self.Btn_Left_OnClicked)
  self.Btn_Right.OnClicked:Add(self, self.Btn_Right_OnClicked)
  self.Btn_UnLock.OnMainButtonClicked:Add(self, self.Btn_UnLock_OnClicked)
  self.Btn_BuyLevel.OnMainButtonClicked:Add(self, self.Btn_BuyLevel_OnClicked)
  self.Btn_ReceiveAll.OnMainButtonClicked:Add(self, self.Btn_ReceiveAll_OnClicked)
  self.Btn_Tips.OnMainButtonHovered:Add(self, self.Btn_Tips_OnHovered)
  self.Btn_Tips.OnMainButtonUnhovered:Add(self, self.Btn_Tips_OnUnhovered)
end
function BattlePassSubView:UnBindClickHandler()
  self.ScrollBox_Award.OnUserScrolled:Remove(self, self.RGListView_Award_OnUserScrolled)
  self.Btn_Left.OnClicked:Remove(self, self.Btn_Left_OnClicked)
  self.Btn_Right.OnClicked:Remove(self, self.Btn_Right_OnClicked)
  self.Btn_UnLock.OnMainButtonClicked:Remove(self, self.Btn_UnLock_OnClicked)
  self.Btn_BuyLevel.OnMainButtonClicked:Remove(self, self.Btn_BuyLevel_OnClicked)
  self.Btn_Tips.OnMainButtonHovered:Remove(self, self.Btn_Tips_OnHovered)
  self.Btn_Tips.OnMainButtonUnhovered:Remove(self, self.Btn_Tips_OnUnhovered)
end
function BattlePassSubView:Construct()
  self.viewModel = UIModelMgr:Get("BattlePassSubViewModel")
  self.GrandPrizeItemList = {}
  self.IsFirstShow = true
  self.PlayUpgradeAni = false
  self.StartTime = -1
  self.SoundId = -1
  self.DataBindTable = {}
  self.SelectGroup = {
    SelectLevel = 1,
    SelectIndex = 1,
    SelectItemID = 1
  }
  self:BindClickHandler()
  if not self.TotallevelExp then
    local BPAwardList = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassReward)
    self.TotallevelExp = BPAwardList[2].Exp - BPAwardList[1].Exp
  end
end
function BattlePassSubView:Destruct()
  self:UnBindClickHandler()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function BattlePassSubView:OnShow(BattlePassID)
  if self.viewModel then
    self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  end
  if self.CurLevel == self.TargetLevel and self.PlayUpgradeAni then
    self:PlayAnimation(self.Ani_level_up)
  end
  self.BattlePassID = BattlePassID
  if not self.ListViewOffset then
    self.ListViewOffset = 0.0
  end
  self:BindClickHandler()
  LogicRole.ShowOrHideRoleMainHero(false)
  self.viewModel:SendGetBattlePassData(BattlePassID)
  local AppearanceActorTemp = GetAppearanceActor(self)
  AppearanceActorTemp:UpdateActived(true)
  AppearanceActorTemp:SetAllActorShow(false)
  local battlePassTable = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePass)
  local UTCTimestamp = GetCurrentTimestamp(true)
  local ClientTimeOffset = GetCurrentTimestamp(false) - GetCurrentTimestamp(true)
  local CurTimestamp = ConvertTimestampToServerTimeByServerTimeZone(UTCTimestamp - ClientTimeOffset)
  local EndTimestamp = ConvertTimeStrToServerTimeByServerTimeZone(battlePassTable[BattlePassID].EndTime)
  local LastTime = EndTimestamp - CurTimestamp
  local days = math.floor(LastTime / 86400)
  local hours = math.floor(LastTime % 86400 / 3600)
  self.TXT_Time:SetText(UE.FTextFormat(LastTIme, days, hours))
  UpdateVisibility(self.WBP_BattlePassGetAwardPopup, false)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0, 0)
  local actor = GetAppearanceActor(self)
  actor:SetCommonCameraTransform()
end
function BattlePassSubView:OnAnimationFinished(Animation)
  if Animation == self.Ani_in then
    self.StartTime = 0
  end
end
function BattlePassSubView:OnPreHide()
end
function BattlePassSubView:LuaTick(InDeltaTime)
  if self.IsScrolled then
    local curOffset = UE.UKismetMathLibrary.FInterpTo(self.ListViewOffset, self.EndOffset, InDeltaTime, 10)
    self.RGListView_Award:SetScrollOffset(curOffset)
    if NearlyEquals(self.ListViewOffset, self.EndOffset, 0.01) then
      self.IsScrolled = false
      self.RGListView_Award:SetVisibility(ESlateVisibility.Visible)
    end
  end
  if self.StartTime < 0 or not self.PlayUpgradeAni then
    return
  end
  if self.StartTime <= self.DurationPerLevel then
    local Percent = self.StartTime / self.DurationPerLevel
    if self.TargetLevel == self.OldLevel then
      Percent = ((self.SurplusExp - self.OldLevelExp) * Percent + self.OldLevelExp) / self.TotallevelExp
    elseif self.CurLevel == self.TargetLevel then
      Percent = Percent * (self.SurplusExp / self.TotallevelExp)
    elseif self.CurLevel == self.OldLevel then
      Percent = ((self.TotallevelExp - self.OldLevelExp) * Percent + self.OldLevelExp) / self.TotallevelExp
    end
    self.Img_Process_1:SetClippingValue(Percent)
    self.Img_Process_2:SetClippingValue(Percent)
    self.Img_Process_3:SetClippingValue(Percent)
    self.ProgressBar_Exp:SetPercent(Percent)
    self.StartTime = self.StartTime + InDeltaTime
  elseif self.CurLevel < self.TargetLevel then
    self.CurLevel = self.TargetLevel
    self.ProgressBar_Exp:SetPercent(0)
    self.TXT_Level:SetText(self.CurLevel)
    self.StartTime = 0
    self:PlayAnimation(self.Ani_level_up)
    EventSystem.Invoke(EventDef.BattlePass.OnUpgrade)
  else
    self.PlayUpgradeAni = false
    self.StartTime = -1
    self.TXT_CurExp:SetText(self.SurplusExp)
    self.ProgressBar_Exp:SetPercent(self.SurplusExp / self.TotallevelExp)
    self.BattlePassInfo = self.CurBattlePassInfo
    battlepassdata[self.BattlePassID].IsUpgrade = false
    UpdateVisibility(self.CanvasPanel_jindu_loop, false)
    if 0 == self.OldLevelExp then
      EventSystem.Invoke(EventDef.BattlePass.OnUpgrade)
    end
    self:UpdateView(self.CurBattlePassInfo)
  end
end
function BattlePassSubView:OnHide()
  self:StopAllAnimations()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end
function BattlePassSubView:UpdateBattlePassData(BattlePassInfo)
  if self.PlayUpgradeAni then
    return
  end
  self.BattlePassInfo = BattlePassInfo
  local SBox_Geometry = self.ScrollBox_Award:GetCachedGeometry()
  self.ScrollBox_Size = UE.USlateBlueprintLibrary.GetLocalSize(SBox_Geometry)
  if not self.CurPage then
    self.CurPage = 1
  end
  self.AwardItemSizeX = 0.0
  self.Level = BattlePassInfo.level
  self.ActivateState = BattlePassInfo.battlePassActivateState
  self.AwardListInfo = {}
  if battlepassdata[self.BattlePassID].IsUpgrade then
    self:UpdateView(battlepassdata.OldBattlePasData[self.BattlePassID])
    self.CurBattlePassInfo = BattlePassInfo
    UpdateVisibility(self.CanvasPanel_jindu_loop, true)
    self.TargetLevel = tonumber(BattlePassInfo.level)
    self.CurLevel = tonumber(battlepassdata.OldBattlePasData[self.BattlePassID].level)
    self.OldLevel = tonumber(battlepassdata.OldBattlePasData[self.BattlePassID].level)
    self.TotallevelExp = 1000
    self.SurplusExp = tonumber(BattlePassInfo.exp) % self.TotallevelExp
    if self.TargetLevel == self.MaxLevel then
      self.SurplusExp = self.TotallevelExp
    end
    self.OldLevelExp = tonumber(battlepassdata.OldBattlePasData[self.BattlePassID].exp) % self.TotallevelExp
    self.DurationPerLevel = TotalLevelAniDuration
    self.PlayUpgradeAni = true
    self.StartTime = 0
  else
    self.PlayUpgradeAni = false
    self:UpdateView(BattlePassInfo)
  end
end
function BattlePassSubView:UpdateView(BattlePassInfo)
  print(" BattlePassSubView : UpdateBattlePassData")
  table.Print(self.ScrollBox_Award)
  if self.ActivateState == BattlePassState.Ultra then
    UpdateVisibility(self.Btn_UnLock, false)
  else
    UpdateVisibility(self.Btn_UnLock, true)
    self.Btn_UnLock:SetContentText(self.ActivateState == BattlePassState.Normal and UnLockPremiun or UnLockUltra)
  end
  local level = tonumber(BattlePassInfo.level)
  local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattlePass, self.BattlePassID)
  if result then
    self.TXT_BattlePassTitle:SetText(rowInfo.Name)
  end
  local BPAwardList = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassReward)
  local curLevelInfo, nextLevelInfo
  self.PageHeadItemList = {}
  self.AwardItemList = {}
  self.GrandPrizeItemList = {}
  local ListViewAry = UE.TArray(UE.UObject)
  local AwardCount = 0
  for i, v in ipairs(BPAwardList) do
    if v.BattlePassID == self.BattlePassID then
      if v.BattlePassLevel == level then
        curLevelInfo = v
      elseif v.BattlePassLevel == level + 1 then
        nextLevelInfo = v
      end
      AwardCount = AwardCount + 1
      goto lbl_91
      goto lbl_148
      ::lbl_91::
      local CurAwardState = 0
      if BattlePassInfo.battlePassData[tostring(v.BattlePassLevel)] then
        CurAwardState = BattlePassInfo.battlePassData[tostring(v.BattlePassLevel)]
      end
      local isNormal = BattlePassInfo.battlePassActivateState == BattlePassState.Normal
      local DataObj = self.RGListView_Award:GetOrCreateDataObj()
      table.insert(self.AwardListInfo, {
        NormalAward = v.NormalReward,
        PremiumAward = v.PremiumReward
      })
      DataObj.BattlePassLevel = v.BattlePassLevel
      DataObj.ParentView = self
      DataObj.Level = v.BattlePassLevel
      DataObj.State = CurAwardState
      DataObj.IsNormal = isNormal
      ListViewAry:Add(DataObj)
      table.insert(self.AwardItemList, {Item = DataObj})
      if 1 == v.IsGrandPrize then
        table.insert(self.GrandPrizeItemList, v.BattlePassLevel)
      end
    end
    ::lbl_148::
  end
  self.MaxLevel = AwardCount
  self.MaxPage = self.MaxLevel / PageNum
  self.TXT_MaxPage:SetText(math.ceil(self.MaxPage))
  self.RGListView_Award:SetRGListItems(ListViewAry, true, true)
  if self.IsFirstShow then
    local ItemID = self.AwardListInfo[self.GrandPrizeItemList[1]].PremiumAward[1].key
    local Level = self.GrandPrizeItemList[1]
    local Index = #self.AwardListInfo[self.GrandPrizeItemList[1]].NormalAward + 1
    self:OnItemClicked(ItemID, Level, Index, true)
    self.IsFirstShow = false
  else
    self:OnItemClicked(self.SelectGroup.SelectItemID, self.SelectGroup.SelectLevel, self.SelectGroup.SelectIndex, true)
  end
  UpdateVisibility(self.Btn_BuyLevel, tonumber(self.Level) < self.MaxLevel, true)
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
        self,
        function()
          local pageIndex = 0
          local size = self.WBP_GrandPrizeItem:GetDesiredSize()
          self.AwardItemSizeX = size.X
          for i, v in ipairs(self.AwardItemList) do
            if i == 1 + pageIndex * PageNum then
              table.insert(self.PageHeadItemList, {
                PosX = self.AwardItemSizeX * pageIndex * PageNum
              })
              pageIndex = pageIndex + 1
            end
            v.PosX = self.AwardItemSizeX * i
          end
          self:UpdateGrandPrize(self.ListViewOffset)
        end
      })
    end
  })
  UpdateVisibility(self.Btn_ReceiveAll, self:CheckAllReceiveBtnShow(), true)
  self.TotallevelExp = BPAwardList[2].Exp - BPAwardList[1].Exp
  local curExp = math.clamp(tonumber(BattlePassInfo.exp) - curLevelInfo.Exp, 0, self.TotallevelExp)
  if level == self.MaxLevel then
    curExp = self.TotallevelExp
  end
  self.TXT_CurExp:SetText(curExp)
  self.TXT_MaxLevel:SetText(self.TotallevelExp)
  self.ProgressBar_Exp:SetPercent(curExp / self.TotallevelExp)
  self.TXT_Level:SetText(level)
end
function BattlePassSubView:UpdateGrandPrize(CurrentOffset)
  for i, v in ipairs(self.GrandPrizeItemList) do
    if CurrentOffset * self.AwardItemSizeX + self.RGListView_Award.Slot:GetSize().X < v * self.AwardItemSizeX then
      local state = 0
      if self.BattlePassInfo.battlePassData[tostring(v)] then
        state = self.BattlePassInfo.battlePassData[tostring(v)]
      else
        state = 0
      end
      local normalAward = self.AwardListInfo[v].NormalAward
      local premiumAward = self.AwardListInfo[v].PremiumAward
      self.WBP_GrandPrizeItem:InitItem(normalAward, premiumAward, v, self, state, self.ActivateState == BattlePassState.Normal)
      return
    end
  end
end
function BattlePassSubView:OnItemClicked(ItemID, Level, Index, NotReceive)
  self.SelectGroup.SelectItemID = ItemID
  self.SelectGroup.SelectLevel = Level
  self.SelectGroup.SelectIndex = Index
  for i, v in ipairs(self.RGListView_Award:GetDisplayedEntryWidgets():ToTable()) do
    self:UpdateAwardItemClickedState(v)
  end
  self:UpdateAwardItemClickedState(self.WBP_GrandPrizeItem, Level, Index)
  self:UpdateItemDetail(ItemID)
  self:StopSound()
  if Level > tonumber(self.BattlePassInfo.level) then
    return
  end
  if self.ActivateState == BattlePassState.Normal then
    if self.BattlePassInfo.battlePassData[tostring(Level)] >= AwardState.ReceiveNormal then
      return
    end
  elseif self.BattlePassInfo.battlePassData[tostring(Level)] == AwardState.ReceivePremiun then
    return
  end
  if NotReceive or self.PlayUpgradeAni then
    return
  end
  self.viewModel:SendReceiveAward(self.BattlePassID, Level)
end
function BattlePassSubView:UpdateAwardItemClickedState(AwardItem, Level, Index)
  for NormalIndex, NormalItem in ipairs(AwardItem.VBox_Normal:GetAllChildren():ToTable()) do
    if NormalItem.Level == Level and NormalItem.Index == Index then
      NormalItem.WBP_Item:SetSel(true)
    else
      NormalItem.WBP_Item:SetSel(false)
    end
  end
  for PreIndex, Preitem in ipairs(AwardItem.VBox_Premium:GetAllChildren():ToTable()) do
    if Preitem.Level == Level and Preitem.Index == Index then
      Preitem.WBP_Item:SetSel(true)
    else
      Preitem.WBP_Item:SetSel(false)
    end
  end
end
function BattlePassSubView:UpdateItemDetail(ItemID)
  local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemID)
  local bRoulette = false
  ComInitProEff(ItemID, self.AutoLoad_ComNameProEff)
  if result then
    local resultRarity, rowRarity = GetRowData(DT.DT_ItemRarity, rowInfo.Rare)
    if resultRarity then
      self.RGTextTag:SetText(rowRarity.DisplayName)
      self.URGImageTag:SetColorAndOpacity(rowRarity.SkinRareBgColor)
    end
    self.RGTextDetailsSkinName:SetText(rowInfo.Name)
    self.RGTextDetailsSkinDesc:SetText(rowInfo.Desc)
    bRoulette = rowInfo.Type == TableEnums.ENUMResourceType.HeroCommuniRoulette
  end
  if bRoulette then
    UpdateVisibility(self.WBP_VoiceItem, false)
    UpdateVisibility(self.Img_Icon, false)
    UpdateVisibility(self.CanvasPanelEffect, false)
    local AppearanceActorTemp = GetAppearanceActor(self)
    AppearanceActorTemp:SetAllActorShow(false)
    local type = CommunicationData.GetTypeByCommId(ItemID)
    if 1 == type then
      UpdateVisibility(self.CanvasPanelEffect, true)
      self.WBP_SprayPreviewItem:InitSprayPreviewItemById(ItemID)
    else
      UpdateVisibility(self.WBP_VoiceItem, true)
      local voiceData = {
        CommId = ItemID,
        bIsUnlocked = CommunicationData.CheckCommIsUnlock(ItemID),
        bIsEquiped = CommunicationData.CheckCommIsEquiped(ItemID),
        bIsSelected = false,
        ParentView = self
      }
      self.WBP_VoiceItem:InitVoiceItem(voiceData)
    end
    return
  end
  UpdateVisibility(self.WBP_VoiceItem, false)
  local result1, rowInfo1 = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattlePassRewardShow, 10501502)
  local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattlePassRewardShow, ItemID)
  if result then
    local AppearanceActorTemp = GetAppearanceActor(self)
    if 1 == rowInfo.IsShowModel then
      if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
        local resultGeneral, generalInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemID)
        local ItemShowResult, weaponSkinInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattlePassRewardShow, ItemID)
        local transform = UE.FTransform()
        if ItemShowResult then
          if 0 ~= #weaponSkinInfo.ModeLocation then
            transform.Translation = UE.FVector(weaponSkinInfo.ModeLocation[1], weaponSkinInfo.ModeLocation[2], weaponSkinInfo.ModeLocation[3])
          end
          if 0 ~= #weaponSkinInfo.ModelScale then
            transform.Scale3D = UE.FVector(weaponSkinInfo.ModelScale[1], weaponSkinInfo.ModelScale[2], weaponSkinInfo.ModelScale[3])
          end
        end
        if resultGeneral then
          AppearanceActorTemp:UpdateActived(true)
          if generalInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
            local result, weaponSkinInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, ItemID)
            if result then
              AppearanceActorTemp:InitBattlePassWeaponMesh(weaponSkinInfo.SkinID, weaponSkinInfo.WeaponID, nil, transform)
            end
          elseif generalInfo.Type == TableEnums.ENUMResourceType.Weapon then
            local BResult, WeaponRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, ItemID)
            if not BResult then
              print("BP_LobbyRoleActor_C:ChangeWeaponMesh not OwnHero not found Weapon RowInfo!", ItemID)
              return
            end
            local WeaponSkinId = WeaponRowInfo.SkinID
            AppearanceActorTemp:InitBattlePassWeaponMesh(WeaponSkinId, ItemID, nil, transform)
          elseif generalInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
            local result, characterSkinInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, ItemID)
            if result then
              local resultTBHeroMonster, monsterRow = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, characterSkinInfo.CharacterID)
              if resultTBHeroMonster then
                local defaultWeaponID = monsterRow.WeaponID
                local resultTBWeapon, weaponInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, defaultWeaponID)
                if resultTBWeapon then
                  AppearanceActorTemp:InitCommonActor(characterSkinInfo.CharacterID, characterSkinInfo.SkinID, weaponInfo.SkinID, nil, transform)
                end
              end
            end
          elseif generalInfo.Type == TableEnums.ENUMResourceType.HERO then
            local result, characterSkinInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHero, ItemID)
            if result then
              local resultTBHeroMonster, monsterRow = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, characterSkinInfo.HeroID)
              if resultTBHeroMonster then
                local defaultWeaponID = monsterRow.WeaponID
                local defaultHeroID = monsterRow.SkinID
                local resultTBWeapon, weaponInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, defaultWeaponID)
                if resultTBWeapon then
                  AppearanceActorTemp:InitCommonActor(characterSkinInfo.HeroID, defaultHeroID, weaponInfo.SkinID, nil, transform)
                end
              end
            end
          end
        end
      end
      UpdateVisibility(self.Img_Icon, false)
      UpdateVisibility(self.CanvasPanelEffect, false)
    else
      AppearanceActorTemp:SetAllActorShow(false)
      if rowInfo.IconPath then
        URGBlueprintLibrary.SetImageBrushFromAssetPath(self.Img_Icon, rowInfo.IconPath, true)
      else
        local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ItemID)
        if result then
          URGBlueprintLibrary.SetImageBrushFromAssetPath(self.Img_Icon, rowInfo.Icon, true)
        end
      end
      UpdateVisibility(self.Img_Icon, true)
      UpdateVisibility(self.CanvasPanelEffect, false)
    end
  end
end
function BattlePassSubView:SendGetBattlePassData(BattlePassID)
  self.BattlePassID = BattlePassID
  self.viewModel:SendGetBattlePassData(BattlePassID)
end
function BattlePassSubView:ReceiveReward(Level, AwardList)
  local ShowAward = {}
  for i, v in ipairs(AwardList.resources) do
    table.insert(ShowAward, {
      key = v.rid,
      value = v.acquiredAmount + v.exchangedAmount
    })
  end
  local PremiumAward = self.AwardListInfo[Level].PremiumAward
  if self.ActivateState > BattlePassState.Normal then
    PremiumAward = {}
  end
  self.viewModel:SendGetBattlePassData(self.BattlePassID)
  self:ShowGetAwardTip(ShowAward, PremiumAward)
end
function BattlePassSubView:ReceiveAllReward(AwardList)
  local NormalAwardList = {}
  local PremiumAwardList = {}
  local ShowAward = {}
  for i, v in ipairs(AwardList.resources) do
    table.insert(ShowAward, {
      key = v.rid,
      value = v.acquiredAmount + v.exchangedAmount
    })
  end
  for Level, State in pairs(self.BattlePassInfo.battlePassData) do
    local item = self.AwardListInfo[tonumber(Level)]
    if State == AwardState.UnLock then
      table.move(item.NormalAward, 1, #item.NormalAward, #NormalAwardList + 1, NormalAwardList)
      table.move(item.PremiumAward, 1, #item.PremiumAward, #PremiumAwardList + 1, PremiumAwardList)
    elseif State == AwardState.ReceiveNormal then
      table.move(item.PremiumAward, 1, #item.PremiumAward, #PremiumAwardList + 1, PremiumAwardList)
    end
  end
  if self.ActivateState > BattlePassState.Normal then
    PremiumAwardList = {}
  end
  self:ShowGetAwardTip(ShowAward, PremiumAwardList)
end
function BattlePassSubView:ShowGetAwardTip(NormalAward, PremiumAward)
  UpdateVisibility(self.WBP_BattlePassGetAwardPopup, true)
  local showUpAward = {}
  local showDownAward = {}
  local showMergeUpAward = {}
  local showMergeDownAward = {}
  if self.ActivateState == BattlePassState.Normal then
    showUpAward = NormalAward
    showDownAward = PremiumAward
  else
    table.move(NormalAward, 1, #NormalAward, 1, showUpAward)
    table.move(PremiumAward, 1, #PremiumAward, #showUpAward + 1, showUpAward)
  end
  for i, v in ipairs(showUpAward) do
    table.insert(showMergeUpAward, {
      AwardID = v.key,
      Num = v.value
    })
  end
  for i, v in ipairs(showDownAward) do
    table.insert(showMergeDownAward, {
      AwardID = v.key,
      Num = v.value
    })
  end
  local showReward = battlepassdata:MergeAwardList(showMergeUpAward)
  local showReward_2 = battlepassdata:MergeAwardList(showMergeDownAward)
  self.WBP_BattlePassGetAwardPopup:ShowTip(showReward, showReward_2, self.BattlePassID, self.ActivateState)
end
function BattlePassSubView:CheckBuyBtnShow()
  UpdateVisibility(self.Btn_BuyLevel, tonumber(self.Level) < #self.AwardItemList, true)
end
function BattlePassSubView:CheckAllReceiveBtnShow()
  for i, v in pairs(self.BattlePassInfo.battlePassData) do
    if self.ActivateState == BattlePassState.Normal then
      if v == AwardState.UnLock then
        return true
      end
    elseif v == AwardState.UnLock or v == AwardState.ReceiveNormal then
      return true
    end
  end
  return false
end
function BattlePassSubView:ReOpenSubView()
  if self.BattlePassID then
    self.viewModel:SendGetBattlePassData(self.BattlePassID)
  end
end
function BattlePassSubView:Btn_Left_OnClicked()
  if 1 == self.CurPage then
    return
  end
  self.CurPage = self.CurPage - 1
  local selectOffset = math.clamp(self.PageHeadItemList[self.CurPage].PosX, 0, self.AwardItemSizeX * #self.AwardItemList)
  self.TXT_CurPage:SetText(self.CurPage)
  self.EndOffset = (self.CurPage - 1) * PageNum
  self.RGListView_Award:SetVisibility(ESlateVisibility.HitTestInvisible)
  self.IsScrolled = true
end
function BattlePassSubView:Btn_Right_OnClicked()
  if self.CurPage == self.MaxPage then
    return
  end
  self.CurPage = self.CurPage + 1
  self.EndOffset = (self.CurPage - 1) * PageNum
  self.RGListView_Award:SetVisibility(ESlateVisibility.HitTestInvisible)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ScrollTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ScrollTimer)
  end
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.IsScrolled = false
      self.RGListView_Award:SetVisibility(ESlateVisibility.Visible)
    end
  }, 0.3)
  self.IsScrolled = true
end
function BattlePassSubView:Btn_UnLock_OnClicked()
  UIMgr:Hide(ViewID.UI_BattlePassMainView, true)
  local UnlockView = UIMgr:Show(ViewID.UI_BattlePassUnLockView)
  UnlockView:InitInfo(self.BattlePassID, self.ActivateState)
end
function BattlePassSubView:Btn_BuyLevel_OnClicked()
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  self.buyView = WaveWindowManager:ShowWaveWindowWithDelegate(1202, {}, nil, {
    GameInstance,
    function()
      local buyView = self.buyView
      if buyView.IsNotEnoughMoney then
        ShowWaveWindow(103001)
        return true
      end
      if buyView.BuyLevel + tonumber(self.Level) >= self.MaxLevel then
        UpdateVisibility(self.Btn_BuyLevel, false)
      end
      local amountNum = buyView.BuyLevel
      local goodsId = buyView.battlePassGoodsID
      HttpCommunication.Request("mallservice/buybyresource", {
        amount = amountNum,
        goodsID = goodsId,
        resourceID = buyView.ConsumeResourcesID,
        shelfID = buyView.ShelfsId
      }, {
        self,
        function(self, JsonResponse)
          print(amountNum)
          Logic_Mall.RecordData(amountNum, goodsId, buyView.ShelfsId)
          SkinHandler.SendGetHeroSkinList()
          SkinHandler.SendGetWeaponSkinList()
          Logic_Mall.PushExteriorInfo(false)
          Logic_Mall.PushBundleInfo(false)
          Logic_Mall.PushPropsInfo(false)
          self:SendGetBattlePassData(self.BattlePassID)
        end
      }, {
        GameInstance,
        function(self, JsonResponse)
          print("\232\180\173\228\185\176\229\164\177\232\180\165", JsonResponse.Content)
        end
      })
    end
  }, {
    GameInstance,
    function()
      self:CheckBuyBtnShow()
    end
  })
  self.buyView:InitWindow(self.BattlePassInfo, self.BattlePassID)
end
function BattlePassSubView:Btn_ReceiveAll_OnClicked()
  self.viewModel:SendReceiveAllReward(self.BattlePassID)
end
function BattlePassSubView:Btn_Tips_OnHovered()
  ShowCommonTips(nil, self.Btn_Tips, self.WBP_RuleDescription, nil, nil, nil, nil, nil, 0.5)
end
function BattlePassSubView:Btn_Tips_OnUnhovered()
  UpdateVisibility(self.WBP_RuleDescription, false)
end
function BattlePassSubView:RGListView_Award_OnUserScrolled(CurrentOffset)
  self:UpdateGrandPrize(CurrentOffset)
  self.ListViewOffset = CurrentOffset
  if CurrentOffset > self.MaxLevel - ShowEntryNum then
    self.CurPage = math.ceil(self.MaxPage)
  end
  for i = #self.PageHeadItemList, 1, -1 do
    if CurrentOffset * self.AwardItemSizeX + 5.0 > self.PageHeadItemList[i].PosX then
      self.TXT_CurPage:SetText(self.CurPage)
      if self.IsScrolled then
        return
      end
      self.CurPage = i
      return
    end
  end
end
function BattlePassSubView:SelectVoice(CommId)
  self:PlaySound(CommId)
end
function BattlePassSubView:PlaySound(CommId)
  local RouletteId = CommunicationData.GetRoulleteIdByCommId(CommId)
  local Result, CommunicationRowInfo = GetRowData(DT.DT_CommunicationWheel, RouletteId)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if Result and CommunicationRowInfo.AudioRowName ~= "None" then
    local HeroName = CommunicationData.GetHeroNameByCommId(CommId)
    local SoundEventName = CommunicationRowInfo.AudioRowName .. "_" .. HeroName
    if -1 ~= self.SoundId then
      UE.URGBlueprintLibrary.StopVoice(self.SoundId)
    end
    self.SoundId = PlaySound2DByName(SoundEventName, "BattlePassSubView:PlaySound")
  end
end
function BattlePassSubView:StopSound()
  if -1 == self.SoundId then
    return
  end
  UE.URGBlueprintLibrary.StopVoice(self.SoundId)
end
return BattlePassSubView
