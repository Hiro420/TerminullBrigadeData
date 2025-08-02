local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local OrderedMap = require("Framework.DataStruct.OrderedMap")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local IllustratedGuideHandler = require("Protocol.IllustratedGuide.IllustratedGuideHandler")
local IllustratedGuideSpecificModifyView = Class(ViewBase)

function IllustratedGuideSpecificModifyView:OnBindUIInput()
  if not IsListeningForInputAction(self, "PauseGame") then
    ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindCloseSelf
    })
  end
  if not IsListeningForInputAction(self, "ShowVideoTips") then
    ListenForInputAction("ShowVideoTips", UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnShowVideoTipsPressed
    })
    ListenForInputAction("ShowVideoTips", UE.EInputEvent.IE_Released, true, {
      self,
      self.BindOnShowVideoTipsReleased
    })
  end
  self.WBP_InteractTipWidgetPrevious:BindInteractAndClickEvent(self, self.PreChangeHero)
  self.WBP_InteractTipWidgetNext:BindInteractAndClickEvent(self, self.NextChangeHero)
end

function IllustratedGuideSpecificModifyView:OnUnBindUIInput()
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, "ShowVideoTips") then
    StopListeningForInputAction(self, "ShowVideoTips", UE.EInputEvent.IE_Pressed)
    StopListeningForInputAction(self, "ShowVideoTips", UE.EInputEvent.IE_Released)
  end
  self.WBP_InteractTipWidgetPrevious:UnBindInteractAndClickEvent(self, self.PreChangeHero)
  self.WBP_InteractTipWidgetNext:UnBindInteractAndClickEvent(self, self.NextChangeHero)
end

function IllustratedGuideSpecificModifyView:BindClickHandler()
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Add(self, self.BindCloseSelf)
  self.BP_ButtonWithSound_ChangeHero.OnClicked:Add(self, self.BindOnShowChangeTip)
  self.WBP_InteractTipWidgetVideo.Btn_Main.OnPressed:Add(self, self.BindOnShowVideoTipsPressed)
  self.WBP_InteractTipWidgetVideo.Btn_Main.OnReleased:Add(self, self.BindOnShowVideoTipsReleased)
end

function IllustratedGuideSpecificModifyView:UnBindClickHandler()
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Remove(self, self.BindCloseSelf)
  self.BP_ButtonWithSound_ChangeHero.OnClicked:Remove(self, self.BindOnShowChangeTip)
  self.WBP_InteractTipWidgetVideo.Btn_Main.OnPressed:Remove(self, self.BindOnShowVideoTipsPressed)
  self.WBP_InteractTipWidgetVideo.Btn_Main.OnReleased:Remove(self, self.BindOnShowVideoTipsReleased)
end

function IllustratedGuideSpecificModifyView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("IllustratedGuideSpecificModifyViewModel")
  self:BindClickHandler()
  UpdateVisibility(self.WBP_IGuide_GM_Detail.Txt_Desc, false)
end

function IllustratedGuideSpecificModifyView:OnDestroy()
  self:UnBindClickHandler()
end

function IllustratedGuideSpecificModifyView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  IllustratedGuideHandler.RequestGetOwnedSpecificModifyListFromServer()
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnShowSkillTips, self.BindOnShowSkillTips)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnSpecificModifyItemClicked, self.BindOnSpecificModifyItemClicked)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnUpdateAllSpecificModifyInfo, self.BindOnUpdateAllSpecificModifyInfo)
  self:SelectHeroId(DataMgr.GetMyHeroInfo().equipHero)
  self:InitHeroList()
  self:PlayAnimation(self.Ani_in)
end

function IllustratedGuideSpecificModifyView:BindCloseSelf()
  self:PlayAnimation(self.Ani_out)
end

function IllustratedGuideSpecificModifyView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnShowSkillTips, self.BindOnShowSkillTips, self)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnSpecificModifyItemClicked, self.BindOnSpecificModifyItemClicked, self)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnUpdateAllSpecificModifyInfo, self.BindOnUpdateAllSpecificModifyInfo, self)
end

function IllustratedGuideSpecificModifyView:InitHeroList()
  local allCharacterList = LogicRole.GetAllCanSelectCharacterList()
  table.sort(allCharacterList, function(A, B)
    if DataMgr.IsOwnHero(A) ~= DataMgr.IsOwnHero(B) then
      return DataMgr.IsOwnHero(A)
    end
    return A < B
  end)
  self.HeroToIdxOrderMap = OrderedMap.New()
  for i, v in ipairs(allCharacterList) do
    self.HeroToIdxOrderMap:Add(v, i)
  end
end

function IllustratedGuideSpecificModifyView:BindOnShowChangeTip()
  UpdateVisibility(self.RGAutoLoadPanelChangeHero, true)
  self.RGAutoLoadPanelChangeHero.ChildWidget:InitViewSetChangeHeroTip(self, self.HeroToIdxOrderMap, "Specific_HeroList_Item", false)
end

function IllustratedGuideSpecificModifyView:GetCurShowHeroId()
  return self.CurSelectHeroId
end

function IllustratedGuideSpecificModifyView:SelectHeroId(SelectId)
  self.SelectedSpecificModifyId = nil
  self.CurSelectHeroId = SelectId
  self:UpdateViewByHeroId(SelectId)
end

function IllustratedGuideSpecificModifyView:UpdateViewByHeroId(HeroId)
  local tbHeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if tbHeroMonster and tbHeroMonster[HeroId] then
    self.Text_HeroName:SetText(tbHeroMonster[HeroId].Name)
  end
  local NeedShowSpecificModifyGroupList = self.NeedShowSpecificModifyGroupList:ToTable()
  for index, SpecificModifyGroupInfo in ipairs(NeedShowSpecificModifyGroupList) do
    local item = GetOrCreateItem(self.Scl_SMGroupList, index, self.WBP_IGuide_SM_SMGroup:StaticClass())
    item:RefreshInfo(self, HeroId, SpecificModifyGroupInfo)
  end
  HideOtherItem(self.Scl_SMGroupList, #NeedShowSpecificModifyGroupList + 1)
  local Result, RowData = GetRowData(DT.DT_Hero, tostring(HeroId))
  if Result then
    SetImageBrushBySoftObject(self.Img_HeroAvatar, RowData.SpecificModifyIGuideRoleIcon)
    self.Img_HeroAvatarBG:SetColorAndOpacity(RowData.RoleColor)
  end
  if DataMgr.IsOwnHero(HeroId) then
    self.RGStateController_HeroLock:ChangeStatus(ELock.UnLock)
  else
    self.RGStateController_HeroLock:ChangeStatus(ELock.Lock)
  end
end

function IllustratedGuideSpecificModifyView:PreChangeHero(Step)
  local step = Step or 1
  local curSelectId = self:GetCurShowHeroId()
  local idx = self.HeroToIdxOrderMap[curSelectId]
  idx = idx - step
  if idx <= 0 then
    idx = #self.HeroToIdxOrderMap + idx
  end
  local heroId = self.HeroToIdxOrderMap:GetKeyByIdx(idx)
  if heroId then
    if DataMgr.IsOwnHero(heroId) then
      self:SelectHeroId(heroId)
    else
      self:SelectHeroId(heroId)
    end
  end
end

function IllustratedGuideSpecificModifyView:NextChangeHero(Step)
  local step = Step or 1
  local curSelectId = self:GetCurShowHeroId()
  local idx = self.HeroToIdxOrderMap[curSelectId]
  idx = idx + step
  if idx > #self.HeroToIdxOrderMap then
    idx = idx - #self.HeroToIdxOrderMap
  end
  local heroId = self.HeroToIdxOrderMap:GetKeyByIdx(idx)
  if heroId then
    if DataMgr.IsOwnHero(heroId) then
      self:SelectHeroId(heroId)
    else
      self:SelectHeroId(heroId)
    end
  end
end

function IllustratedGuideSpecificModifyView:UpdateSpecificModifyInfo(SpecificModifyId)
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if nil == logicCommandDataSubsystem then
    return
  end
  local ModifyData = {}
  ModifyData.ModifieConfig = {}
  ModifyData.ModifieConfig.Inscription = SpecificModifyId
  ModifyData.ModifieConfig.ModifyId = SpecificModifyId
  ModifyData.ModifieConfig.GenericModifyType = nil
  if not UIModelMgr:Get("IllustratedGuideSpecificModifyViewModel"):CheckOwnedSpecificModify(SpecificModifyId) then
    ModifyData.ModifieConfig.UnlockMethodDesc = IllustratedGuideData:GetUnlockMethodDescBySpecificModifyId(SpecificModifyId)
    ModifyData.ModifieConfig.UnlockTaskId = IllustratedGuideData:GetSpecificUnlockTaskId(SpecificModifyId)
  else
    ModifyData.ModifieConfig.UnlockMethodDesc = nil
  end
  UpdateVisibility(self.WBP_InteractTipWidgetVideo, false)
  local Result, RowData = GetRowData(DT.DT_ModRefresh, tostring(SpecificModifyId))
  if Result then
    self.RowData = RowData
    ModifyData.ModifieConfig.MediaSoftPtr = self.RowData.MediaSoftPtr
    if UE.UKismetSystemLibrary.IsValidSoftObjectReference(self.RowData.MediaSoftPtr) then
      UpdateVisibility(self.WBP_InteractTipWidgetVideo, true)
    end
  end
  self.WBP_IGuide_GM_Detail:RefreshDetailPanel(ModifyData, true, true)
  self:BindOnShowVideoTipsReleased()
end

function IllustratedGuideSpecificModifyView:BindOnShowSkillTips(bShow, Info)
  if self.ShowVideoTipsPressed and false == bShow then
    return
  end
  if Info.MediaSoftPtr == nil or not UE.UKismetSystemLibrary.IsValidSoftObjectReference(Info.MediaSoftPtr) then
    UpdateVisibility(self.SizeBox_Tips, false)
    return
  end
  UpdateVisibility(self.SizeBox_Tips, bShow)
  local bShowMovie = false
  local bHaveModAdditional = false
  if bShow and nil ~= Info then
    self.MediaPlayer:SetLooping(true)
    if Info.MediaSoftPtr ~= nil and UE.UKismetSystemLibrary.IsValidSoftObjectReference(Info.MediaSoftPtr) then
      self.Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(Info.MediaSoftPtr)
      UpdateVisibility(self.SizeBox_Movie, true)
      bShowMovie = true
      self.MediaPlayer:OpenSource(self.Obj)
      self.MediaPlayer:Rewind()
    else
      bShowMovie = false
      UpdateVisibility(self.SizeBox_Movie, false)
    end
  end
end

function IllustratedGuideSpecificModifyView:BindOnSpecificModifyItemClicked(SpecificModifyId)
  self.SelectedSpecificModifyId = SpecificModifyId
  self:UpdateSpecificModifyInfo(SpecificModifyId)
end

function IllustratedGuideSpecificModifyView:BindOnUpdateAllSpecificModifyInfo()
  self:SelectHeroId(self:GetCurShowHeroId())
end

function IllustratedGuideSpecificModifyView:BindOnShowVideoTipsPressed()
  self.ShowVideoTipsPressed = true
  local info = {}
  local Result, RowData = GetRowData(DT.DT_ModRefresh, tostring(self.SelectedSpecificModifyId))
  if Result then
    info.MediaSoftPtr = RowData.MediaSoftPtr
  end
  self:BindOnShowSkillTips(true, info)
end

function IllustratedGuideSpecificModifyView:BindOnShowVideoTipsReleased()
  self.ShowVideoTipsPressed = false
  local info = {}
  local Result, RowData = GetRowData(DT.DT_ModRefresh, tostring(self.SelectedSpecificModifyId))
  if Result then
    info.MediaSoftPtr = RowData.MediaSoftPtr
  end
  self:BindOnShowSkillTips(false, info)
end

function IllustratedGuideSpecificModifyView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UIMgr:Hide(ViewID.UI_IllustratedGuideSpecificModify, true)
    UpdateVisibility(self.RGAutoLoadPanelChangeHero, false)
  end
end

return IllustratedGuideSpecificModifyView
