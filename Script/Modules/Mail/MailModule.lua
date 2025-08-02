local MailModule = ModuleManager:Get("MailModule") or LuaClass()
local MailHandler = require("Protocol.Mail.MailHandler")

function MailModule:Ctor()
end

function MailModule:OnInit()
  EventSystem.AddListener(nil, EventDef.WSMessage.NewMail, MailModule.BindOnReceiveNewMail)
  EventSystem.AddListener(nil, EventDef.WSMessage.CheckMail, MailModule.BindOnCheckMail)
  EventSystem.AddListener(nil, EventDef.WSMessage.RefreshMail, MailModule.BindOnRefreshMail)
end

function MailModule:BindOnReceiveNewMail()
  print("MailModule:BindOnReceiveNewMail")
  MailHandler:RequestGetMailListToServer()
end

function MailModule:BindOnCheckMail()
  print("MailModule:BindOnCheckMail")
  MailHandler:RequestCheckToServer()
end

function MailModule:BindOnRefreshMail()
  print("MailModule:BindOnRefreshMail")
  MailHandler:RequestCheckToServer()
end

function MailModule:OnShutdown()
  EventSystem.RemoveListener(EventDef.WSMessage.NewMail, MailModule.BindOnReceiveNewMail)
  EventSystem.RemoveListener(EventDef.WSMessage.CheckMail, MailModule.BindOnCheckMail)
  EventSystem.RemoveListener(EventDef.WSMessage.RefreshMail, MailModule.BindOnRefreshMail)
end

return MailModule
