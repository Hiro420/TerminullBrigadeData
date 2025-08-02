local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local WBP_MainTask_RequestConversation_C = UnLua.Class()

function WBP_MainTask_RequestConversation_C:Construct()
  self.NPCDynamicMaterial = self.Image_NPC:GetDynamicMaterial()
  self.BtnOpenDialogue.OnClicked:Add(self, self.BindOpenDialogue)
  BeginnerGuideData:UpdateWBP("WBP_MainTask_RequestConversation", self)
end

function WBP_MainTask_RequestConversation_C:OnAnimationFinished(Animation)
  if Animation == self.ani_out then
    EventSystem.Invoke(EventDef.Lobby.OnInviteDialogue, false, self.RequestConversationId)
    UIMgr:Show(ViewID.UI_MainTaskDialogueView, nil, self.RequestConversationId)
    EventSystem.Invoke(EventDef.BeginnerGuide.OnMainTaskDialogueShow)
  end
end

function WBP_MainTask_RequestConversation_C:InitRequestConversation(Id)
  self.RequestConversationId = Id
  local Result, RowInfo = GetRowData("MainTaskDialogue", self.RequestConversationId)
  if Result then
    self.SpeakerName:SetText(RowInfo.InviteDialogue.SperkerName)
    self.Content:SetText(RowInfo.InviteDialogue.Content)
    local Texture = GetAssetBySoftObjectPtr(RowInfo.InviteDialogue.NPCPaint, true)
    if self.NPCDynamicMaterial and Texture then
      self.NPCDynamicMaterial:SetTextureParameterValue("renwu", Texture)
    end
    SetImageBrushByTexture2DSoftObject(self.Image_BG, RowInfo.InviteDialogue.Background)
  end
  self:PlayAnimation(self.ani_in, 0)
end

function WBP_MainTask_RequestConversation_C:BindOpenDialogue()
  self:PlayAnimation(self.ani_out)
end

function WBP_MainTask_RequestConversation_C:RefreshList()
  self.List:ClearChildren()
  local ChildWidgetClass = UE.UClass.Load("/Game/Rouge/UI/MainTask/WBP_MainTask_RequestConversation_Item.WBP_MainTask_RequestConversation_Item_C")
  UpdateVisibility(self.CanvasPanel_4, #Logic_MainTask.CacheInviteDialogue > 1)
  self.RequestConversationNum:SetText(#Logic_MainTask.CacheInviteDialogue)
  for index, value in ipairs(Logic_MainTask.CacheInviteDialogue) do
    if 1 ~= index then
      local ChildWidget = UE.UWidgetBlueprintLibrary.Create(self, ChildWidgetClass)
      local Result, RowInfo = GetRowData("MainTaskDialogue", value)
      if Result then
        SetImageBrushBySoftObject(ChildWidget.Image_NPC, RowInfo.InviteDialogue.NPCPaint)
      end
      ChildWidget.BtnOpenDialogue.OnClicked:Add(self, function()
        EventSystem.Invoke(EventDef.Lobby.OnInviteDialogue, false, value)
        UIMgr:Show(ViewID.UI_MainTaskDialogueView, nil, value)
      end)
      self.List:AddChild(ChildWidget)
    else
      self:InitRequestConversation(value)
    end
  end
end

return WBP_MainTask_RequestConversation_C
