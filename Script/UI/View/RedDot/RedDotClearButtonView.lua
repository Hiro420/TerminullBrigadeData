local RedDotClearButtonView = UnLua.Class()
local RedDotData = require("Modules.RedDot.RedDotData")

function RedDotClearButtonView:Construct()
  self.Overridden.Construct(self)
end

function RedDotClearButtonView:Destruct()
  self.Overridden.Destruct(self)
end

function RedDotClearButtonView:BindOnRedDotClearButtonClicked()
  for k, v in pairs(self.RedDotClassList) do
    local NeedClearRedDotIdList = RedDotData:GetRedDotIdListByClass(v)
    for k, v in pairs(NeedClearRedDotIdList) do
      if 0 == self.HeroId or tostring(self.HeroId) == self:GetHeroId(v) then
        RedDotData:SetRedDotNum(v, 0)
      end
    end
  end
  for k, v in pairs(self.RedDotIdList) do
    RedDotData:SetRedDotNum(v, 0)
  end
end

function RedDotClearButtonView:GetHeroId(RedDotId)
  local result = string.match(RedDotId, "_(%d%d%d%d)")
  return result
end

function RedDotClearButtonView:UpdateRedDotIdList(RedDotIdList)
  self.RedDotIdList = RedDotIdList
end

function RedDotClearButtonView:BindInteractAndClickEvent()
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnRedDotClearButtonClicked)
end

function RedDotClearButtonView:UnBindInteractAndClickEvent()
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnRedDotClearButtonClicked)
end

return RedDotClearButtonView
