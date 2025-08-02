local WBP_GenericModifyDialog_Content_C = UnLua.Class()

function WBP_GenericModifyDialog_Content_C:Destruct()
  self:StopSound()
end

function WBP_GenericModifyDialog_Content_C:SetContent(Content)
  local TBDialogue = LuaTableMgr.GetLuaTableByName(TableNames.TBGenericModifyDialog)
  if not TBDialogue or not TBDialogue[Content.DialogueId] then
    return
  end
  local ContentTable = TBDialogue[Content.DialogueId]
  self:StopSound()
  self.Txt_SpeakName:SetText(ContentTable.SpeakerName)
  self.Txt_Dislog:SetText(ContentTable.SpeechContent)
  self.AkEventName = ContentTable.SpeechRecording
  self.PlayingId = PlaySound2DByName(ContentTable.SpeechRecording, "GenericModifyDialog")
end

function WBP_GenericModifyDialog_Content_C:StopSound()
  if self.PlayingId and self.AkEventName then
    UE.UAudioManager.StopWwiseEventByName(self.AkEventName, nil, 0, self.PlayingId)
  end
  self.PlayingId = nil
  self.AkEventName = nil
end

return WBP_GenericModifyDialog_Content_C
