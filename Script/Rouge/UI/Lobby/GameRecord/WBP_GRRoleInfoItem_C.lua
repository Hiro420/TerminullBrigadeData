local rapidjson = require("rapidjson")
local WBP_GRRoleInfoItem_C = UnLua.Class()

function WBP_GRRoleInfoItem_C:Construct()
  self.Button_GRRoleInfo.OnClicked:Add(self, WBP_GRRoleInfoItem_C.OnClicked_Button)
  self.Button_GRRoleInfo.OnHovered:Add(self, WBP_GRRoleInfoItem_C.OnHovered_Button)
  self.Button_GRRoleInfo.OnUnhovered:Add(self, WBP_GRRoleInfoItem_C.OnUnhovered_Button)
  self.bSelected = false
  EventSystem.AddListener(self, EventDef.GameRecordPanel.RoleInfoItemChanged, WBP_GRRoleInfoItem_C.OnRoleInfoItemChanged)
end

function WBP_GRRoleInfoItem_C:Destruct()
  self.Button_GRRoleInfo.OnClicked:Remove(self, WBP_GRRoleInfoItem_C.OnClicked_Button)
  self.Button_GRRoleInfo.OnHovered:Remove(self, WBP_GRRoleInfoItem_C.OnHovered_Button)
  self.Button_GRRoleInfo.OnUnhovered:Remove(self, WBP_GRRoleInfoItem_C.OnUnhovered_Button)
  EventSystem.RemoveListener(EventDef.GameRecordPanel.RoleInfoItemChanged, WBP_GRRoleInfoItem_C.OnRoleInfoItemChanged, self)
end

function WBP_GRRoleInfoItem_C:UpdateRoleInfo(UserId)
  self.UserId = UserId
  self:RequestRoleInfo(self.UserId)
end

function WBP_GRRoleInfoItem_C:OnClicked_Button()
  if self.bSelected == false then
    self.bSelected = true
    self.Image_Choose:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    EventSystem.Invoke(EventDef.GameRecordPanel.RoleInfoItemChanged, self)
  end
end

function WBP_GRRoleInfoItem_C:OnHovered_Button()
end

function WBP_GRRoleInfoItem_C:OnUnhovered_Button()
end

function WBP_GRRoleInfoItem_C:OnRoleInfoItemChanged(ActiveWidget)
  if ActiveWidget ~= self then
    self.bSelected = false
    self.Image_Choose:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_GRRoleInfoItem_C:OnGetRoleSuccess(JsonResponse)
  print("OnGetRoleSuccess", JsonResponse.Content)
  local Response = rapidjson.decode(JsonResponse.Content)
  for i, SingleInfo in ipairs(Response.players) do
    if SingleInfo.roleid == self.UserId then
      self.SingleInfo = SingleInfo
      if self.SingleInfo then
        self.TextBlock_GRRoleName:SetText(SingleInfo.nickname)
      end
    else
      self.TextBlock_PlayerName:SetText("\230\151\160\230\149\136\230\149\176\230\141\174")
    end
  end
end

function WBP_GRRoleInfoItem_C:OnGetRoleFail(ErrorMessage)
  print("OnGetRoleFail", ErrorMessage.ErrorMessage)
end

function WBP_GRRoleInfoItem_C:RequestRoleInfo(UserId)
  print("\232\175\183\230\177\130\231\154\132roleId : " .. UserId)
end

return WBP_GRRoleInfoItem_C
