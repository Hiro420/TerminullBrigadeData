local WBP_InteractScrollList_C = UnLua.Class()
local Timer = -1
local Interval = 0.3

function WBP_InteractScrollList_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_InteractScrollList_C:UpdateInteractScrollListByIndex(Index)
  local interactList = LogicHUD:GetCanInteractTargetList()
  self:UpdateInteractScrollList(Index, interactList)
end

function WBP_InteractScrollList_C:UpdateInteractScrollList(Index, interactList)
  self.CurIdx = Index
  UpdateVisibility(self, true)
  local totalNum = 0
  if interactList then
    totalNum = interactList:Length()
  end
  self.CurTotalNum = totalNum
  if totalNum <= 1 then
    HideOtherItem(self.VerticalBoxInteract, 1)
    UpdateVisibility(self.URGImageInteractScrollTag, false)
  else
    UpdateVisibility(self.URGImageInteractScrollTag, true)
    if totalNum <= self.MaxShowItemNum then
      for i, v in iterator(interactList) do
        local interactItem = GetOrCreateItem(self.VerticalBoxInteract, i, self.WBP_InteractScrollItem:GetClass())
        interactItem:InitInteractScrollIten(v, i == Index)
      end
    else
      local middleIdx = -1
      if 0 == self.MaxShowItemNum % 2 then
        middleIdx = self.MaxShowItemNum / 2
      else
        middleIdx = math.floor(self.MaxShowItemNum / 2) + 1
      end
      local interactTb = interactList:ToTable()
      local interactSort = {}
      if Index < middleIdx then
        do
          local startIdx = #interactTb - (middleIdx - Index) + 1
          table.move(interactTb, startIdx, #interactTb, #interactSort + 1, interactSort)
          for i = #interactTb, startIdx, -1 do
            table.remove(interactTb, i)
          end
          table.move(interactTb, 1, #interactTb, #interactSort + 1, interactSort)
          for i = middleIdx, 1, -1 do
            table.remove(interactTb, i)
          end
        end
      else
        table.move(interactTb, Index - middleIdx + 1, #interactTb, #interactSort + 1, interactSort)
        for i = #interactTb, Index - middleIdx + 1, -1 do
          table.remove(interactTb, i)
        end
        table.move(interactTb, 1, #interactTb, #interactSort + 1, interactSort)
      end
      for i, v in ipairs(interactSort) do
        local interactItem = GetOrCreateItem(self.VerticalBoxInteract, i, self.WBP_InteractScrollItem:GetClass())
        interactItem:InitInteractScrollIten(v, i == middleIdx)
      end
    end
    HideOtherItem(self.VerticalBoxInteract, totalNum + 1)
  end
end

function WBP_InteractScrollList_C:Hide()
  UpdateVisibility(self, false)
  self.CurIdx = -1
end

return WBP_InteractScrollList_C
