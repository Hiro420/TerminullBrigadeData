local WBP_LikeAttributeModifyWindowItem_C = UnLua.Class()
local RefuseKeyName = "OKeyEvent"
local AgreeKeyName = "PKeyEvent"
function WBP_LikeAttributeModifyWindowItem_C:Construct()
  self.Overridden.Construct(self)
end
function WBP_LikeAttributeModifyWindowItem_C:InitInfo(RequestData, ParentView)
  self.RequestData = RequestData
  self.ParentView = ParentView
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  local PlayerInfo = RGTeamSubsystem:GetPlayerInfo(RequestData.FromUserId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(RequestData.Id, nil)
  if ResultModify then
    self.Txt_Name:SetText(PlayerInfo.name)
    local CharacterId = PlayerInfo.hero.id
    local CharacterInfo = LogicRole.GetCharacterTableRow(CharacterId)
    if not CharacterInfo then
      return
    end
    local SoftObjRef = MakeStringToSoftObjectReference(CharacterInfo.ActorIcon)
    if not UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
      return
    end
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef):Cast(UE.UPaperSprite)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_Head:SetBrush(Brush)
    end
    self.WBP_TeamDamageActivatedModifyItem:UpdateScrollData(RequestData.Id, nil, nil, nil, nil)
    for i, v in iterator(AttributeModifyRow.SetArray) do
      local ActivatedModifySetIcon_Other = GetOrCreateItem(self.HrzBox_OtherSet, i, self.WBP_ActivatedModifySetIcon:GetClass())
      ActivatedModifySetIcon_Other:InitInfo(v, self:GetAttributeModifySetLevelBySetId(RequestData.FromUserId, v))
      local ActivatedModifySetIcon_My = GetOrCreateItem(self.HrzBox_MySet, i, self.WBP_ActivatedModifySetIcon:GetClass())
      ActivatedModifySetIcon_My:InitInfo(v, self:GetAttributeModifySetLevelBySetId(RequestData.TargetUserId, v))
    end
    HideOtherItem(self.HrzBox_OtherSet, AttributeModifyRow.SetArray:Length() + 1)
    HideOtherItem(self.HrzBox_MySet, AttributeModifyRow.SetArray:Length() + 1)
  end
  self.WBP_TeamDamageActivatedModifyItem_Mini:UpdateScrollData(RequestData.Id, nil, nil, nil, nil)
  self:SetPercent(0)
end
function WBP_LikeAttributeModifyWindowItem_C:SetPercent(Percent)
  self.ProgressBar_Time:SetPercent(Percent)
  self.ProgressBar_Time_Mini:SetPercent(Percent)
  self.Img_ProgressCover_Main:SetClippingValue(Percent)
  self.Img_ProgressCover_Mini:SetClippingValue(Percent)
  UpdateVisibility(self.ProgressPanel_1, Percent > 0, false, true)
  local CountDownTxtFmt = NSLOCTEXT("WBP_LikeAttributeModifyWindowItem_C", "CountDownTxt", "{0}\231\167\146\229\144\142\233\187\152\232\174\164\230\139\146\231\187\157\229\175\185\230\150\185\232\175\183\230\177\130")
  local CountDownTxt = UE.FTextFormat(CountDownTxtFmt(), tostring(math.floor(Percent * self.RequestData.CountDownTime)))
  self.Txt_CountDown:SetText(string.format(CountDownTxt))
end
function WBP_LikeAttributeModifyWindowItem_C:SetState(State)
  if self.State == State then
    return
  end
  if self:IsAnimationPlaying(self.Ani_change_in) then
    return
  end
  local oldState = self.State
  self.State = State
  if oldState then
    self:StopAllAnimations()
    if self.State == "Main" then
      self:PlayAnimationReverse(self.Ani_change_out)
    else
      self:PlayAnimation(self.Ani_change_in)
    end
  end
end
function WBP_LikeAttributeModifyWindowItem_C:GetAttributeModifySetLevelBySetId(UserId, SetId)
  local SetData = self:GetAttributeModifySetDataBySetId(UserId, SetId)
  if SetData then
    return SetData.Level
  end
  return 0
end
function WBP_LikeAttributeModifyWindowItem_C:GetAttributeModifySetDataBySetId(UserId, SetId)
  local PC = self:GetPlayerControllerByUserId(UserId)
  if PC and PC.AttributeModifyComponent then
    for i, v in iterator(PC.AttributeModifyComponent.ActivatedSets) do
      if v.SetId == SetId then
        return v
      end
    end
  end
  return nil
end
function WBP_LikeAttributeModifyWindowItem_C:GetPlayerStateByUserId(UserId)
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return nil
  end
  for i, SinglePS in iterator(GS.PlayerArray) do
    if SinglePS:GetUserId() == UserId then
      return SinglePS
    end
  end
  return nil
end
function WBP_LikeAttributeModifyWindowItem_C:GetPlayerControllerByUserId(UserId)
  local PC
  local PS = self:GetPlayerStateByUserId(UserId)
  local HeroCharacterCls = UE.ARGHeroCharacterBase:StaticClass()
  local AllHeroCharacter = UE.UGameplayStatics.GetAllActorsOfClass(self, HeroCharacterCls, nil)
  for i, SinglePlayerCharacter in iterator(AllHeroCharacter) do
    if SinglePlayerCharacter and SinglePlayerCharacter.PlayerState == PS then
      PC = SinglePlayerCharacter
    end
  end
  return PC
end
function WBP_LikeAttributeModifyWindowItem_C:Hide()
  UpdateVisibility(self, false)
end
function WBP_LikeAttributeModifyWindowItem_C:PlayInAnimation(ParentView, FinishCallBack)
  local CurInAni = self["Ani_" .. self.State .. "_in"]
  self:PlayAnimation(CurInAni)
end
function WBP_LikeAttributeModifyWindowItem_C:PlayOutAnimation(ParentView, FinishCallBack)
  local CurOutAni = self["Ani_" .. self.State .. "_out"]
  self:PlayAnimation(CurOutAni)
  self:UnbindAllFromAnimationFinished(CurOutAni)
  self:BindToAnimationFinished(CurOutAni, {ParentView, FinishCallBack})
end
function WBP_LikeAttributeModifyWindowItem_C:PlayExpandAnimation(ParentView, FinishCallBack)
  self:PlayAnimation(self.Ani_Main_up)
  self.State = "Main"
end
function WBP_LikeAttributeModifyWindowItem_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_change_in and self.ParentView.ShowModel == "Main" then
    self:SetState("Main")
  end
end
return WBP_LikeAttributeModifyWindowItem_C
