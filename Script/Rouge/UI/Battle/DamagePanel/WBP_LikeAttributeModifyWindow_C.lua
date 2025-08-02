local WBP_LikeAttributeModifyWindow_C = UnLua.Class()
local RefuseKeyName = "OKeyEvent"
local AgreeKeyName = "PKeyEvent"

function WBP_LikeAttributeModifyWindow_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_LikeAttributeModifyWindow_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  self.IsHover = false
  self.RequestDataList = {}
  ListenForInputAction(AgreeKeyName, UE.EInputEvent.IE_Pressed, true, {
    self,
    WBP_LikeAttributeModifyWindow_C.BindOnAgreeRequest
  })
  ListenForInputAction(RefuseKeyName, UE.EInputEvent.IE_Pressed, true, {
    self,
    WBP_LikeAttributeModifyWindow_C.BindOnRefuseRequest
  })
end

function WBP_LikeAttributeModifyWindow_C:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  StopListeningForInputAction(self, AgreeKeyName, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, RefuseKeyName, UE.EInputEvent.IE_Pressed)
  self.RequestDataList = {}
end

function WBP_LikeAttributeModifyWindow_C:InitByRequestData(RequestData)
  self:AddRequestData(RequestData)
end

function WBP_LikeAttributeModifyWindow_C:AddRequestData(RequestData)
  table.insert(self.RequestDataList, RequestData)
  self:UpdateByRequestDataList()
  local LastWindowItem = self.VerticalBox_LikeInfoList:GetChildAt(#self.RequestDataList - 1)
  if LastWindowItem then
    LastWindowItem:PlayInAnimation()
  end
end

function WBP_LikeAttributeModifyWindow_C:RemoveFirstRequestData()
  local FirstWindowItem = self.VerticalBox_LikeInfoList:GetChildAt(0)
  local StartAniTime = GetCurrentUTCTimestamp()
  self.RequestData = nil
  if FirstWindowItem then
    FirstWindowItem:PlayOutAnimation(self, function()
      table.remove(self.RequestDataList, 1)
      self.VerticalBox_LikeInfoList:RemoveChildAt(0)
      if 0 == #self.RequestDataList then
        RGUIMgr:HideUI(UIConfig.WBP_LikeAttributeModifyWindow_C.UIName)
        return
      end
      self.RequestData = self.RequestDataList[1]
      self.RequestData.Timestamp = StartAniTime
      self:UpdateByRequestDataList(true)
    end)
  end
end

function WBP_LikeAttributeModifyWindow_C:UpdateByRequestDataList(bIsRemoveFirst)
  for i, v in ipairs(self.RequestDataList) do
    local LikeWindowItem = GetOrCreateItem(self.VerticalBox_LikeInfoList, i, self.WBP_LikeAttributeModifyWindowItem:GetClass())
    LikeWindowItem:InitInfo(v, self)
    if 1 == i and bIsRemoveFirst and self.ShowModel == "Main" then
      LikeWindowItem:PlayExpandAnimation()
    end
  end
  HideOtherItem(self.VerticalBox_LikeInfoList, #self.RequestDataList + 1, true)
  self.RequestData = self.RequestDataList[1]
  self.CurCountDownTime = self.RequestData.CountDownTime - (GetCurrentUTCTimestamp() - self.RequestData.Timestamp)
  self.CountDownTime = self.RequestData.CountDownTime
  self:UpdateShowModelByMouse(true)
end

function WBP_LikeAttributeModifyWindow_C:OnMouseEnter(MyGeometry, MouseEvent)
  self.IsHover = true
  self:ChangeShowModel("Main")
end

function WBP_LikeAttributeModifyWindow_C:OnMouseLeave(MyGeometry, MouseEvent)
  self.IsHover = false
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC and PC.bShowMouseCursor then
    self:ChangeShowModel("Mini")
  end
end

function WBP_LikeAttributeModifyWindow_C:LuaTick(DeltaTime)
  if not self.RequestData then
    return
  end
  self.CurCountDownTime = math.max(self.CurCountDownTime - DeltaTime, 0)
  local FirstWindowItem = self.VerticalBox_LikeInfoList:GetChildAt(0)
  if FirstWindowItem then
    FirstWindowItem:SetPercent(self.CurCountDownTime / self.CountDownTime)
  end
  if self.CurCountDownTime <= 0 then
    self:RemoveFirstRequestData()
  end
  self:UpdateShowModelByMouse()
end

function WBP_LikeAttributeModifyWindow_C:UpdateShowModelByMouse(bForce)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC and not self.IsHover then
    self:ChangeShowModel(PC.bShowMouseCursor and "Mini" or "Main", bForce)
  end
end

function WBP_LikeAttributeModifyWindow_C:BindOnAgreeRequest()
  if self.RequestData == nil then
    print("ywtao, WBP_LikeAttributeModifyWindow_C:BindOnAgreeRequest, RequestData is nil")
    return
  end
  UE.URGGameplayLibrary.ConfirmRequestItem(self, self.RequestData.TargetUserId)
  self:RemoveFirstRequestData()
end

function WBP_LikeAttributeModifyWindow_C:BindOnRefuseRequest()
  if self.RequestData == nil then
    print("ywtao, WBP_LikeAttributeModifyWindow_C:BindOnRefuseRequest, RequestData is nil")
    return
  end
  UE.URGGameplayLibrary.RefuseRequestItem(self, self.RequestData.TargetUserId)
  PlayVoice("Voice.Attributemodify.Refuse", UE.UGameplayStatics.GetPlayerCharacter(self, 0), self:GetPlayerControllerByUserId(self.RequestData.FromUserId))
  self:RemoveFirstRequestData()
end

function WBP_LikeAttributeModifyWindow_C:ChangeShowModel(ShowModel, bForce)
  if not bForce and self.ShowModel == ShowModel then
    return
  end
  local oldShowModel = self.ShowModel
  self.ShowModel = ShowModel
  local AllChildren = self.VerticalBox_LikeInfoList:GetAllChildren()
  for index, SingleItem in pairs(AllChildren) do
    if 1 == index then
      SingleItem:SetState(ShowModel)
    else
      SingleItem:SetState("Mini")
    end
  end
end

function WBP_LikeAttributeModifyWindow_C:GetPlayerStateByUserId(UserId)
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

function WBP_LikeAttributeModifyWindow_C:GetPlayerControllerByUserId(UserId)
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

return WBP_LikeAttributeModifyWindow_C
