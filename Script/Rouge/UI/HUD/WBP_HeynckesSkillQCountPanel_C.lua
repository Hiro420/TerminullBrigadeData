local WBP_HeynckesSkillQCountPanel_C = UnLua.Class()

function WBP_HeynckesSkillQCountPanel_C:Construct()
  ListenObjectMessage(nil, GMP.MSG_CharacterSkill_Heynckes_OnPrimaryMoveCountUpdate, self, self.BindOnPrimaryMoveCountUpdate)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
  end
  self.PrimaryMoveCount = 0
end

function WBP_HeynckesSkillQCountPanel_C:Show()
  self:BindOnInputMethodChanged()
  UpdateVisibility(self, true)
  local Character = self:GetOwningPlayerPawn()
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  self.MaxNum = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, self.MaxMoveCountAttr, nil)
  self.Progress_Count:SetPercent(1)
  self.PrimaryMoveCount = self.MaxNum
  self.RGStateController_Skill:ChangeStatus("Normal")
  for i = 1, self.MaxNum do
    local QCountItem = GetOrCreateItem(self.HrzBox_CountItemList, i, self.WBP_HeynckesSkillQCountItem:GetClass())
    QCountItem.RGStateController:ChangeStatus("Enable")
  end
  HideOtherItem(self.HrzBox_CountItemList, self.MaxNum + 1, true)
end

function WBP_HeynckesSkillQCountPanel_C:BindOnPrimaryMoveCountUpdate(CurrentCount)
  self.PrimaryMoveCount = CurrentCount
  self.Txt_Count:SetText(tostring(CurrentCount))
  print("BindOnPrimaryMoveCountUpdate:", CurrentCount)
  if 0 == CurrentCount then
    self.RGStateController_Skill:ChangeStatus("NoMoveCount")
  end
  local QCountItem = GetOrCreateItem(self.HrzBox_CountItemList, CurrentCount + 1, self.WBP_HeynckesSkillQCountItem:GetClass())
  QCountItem.RGStateController:ChangeStatus("Disable")
end

function WBP_HeynckesSkillQCountPanel_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_HeynckesSkillQCountPanel_C:Destruct()
  UnListenObjectMessage(GMP.MSG_CharacterSkill_Heynckes_OnPrimaryMoveCountUpdate, self)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
end

function WBP_HeynckesSkillQCountPanel_C:BindOnInputMethodChanged()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
    self.RGStateController_Input:ChangeStatus(UE.ECommonInputType.GetNameStringByValue(UE.ECommonInputType.MouseAndKeyboard))
  end
end

function WBP_HeynckesSkillQCountPanel_C:LuaTick()
  local Character = self:GetOwningPlayerPawn()
  if self.PrimaryMoveCount > 0 then
    local bResult, TimeRemaining, CoolDownDuration = UE.URGBlueprintLibrary.GetCooldownRemainingForTag(Character, self.CooldownTagContainer, nil, nil)
    if bResult then
      self.Progress_Count:SetPercent(1 - TimeRemaining / CoolDownDuration)
      if TimeRemaining > 0 then
        self.Progress_Count:SetFillColorAndOpacity(self.CoolDownColor)
        if self.SkillState ~= "CoolDown" then
          self.SkillState = "CoolDown"
          self.RGStateController_Skill:ChangeStatus("CoolDown")
        end
      else
        self.Progress_Count:SetFillColorAndOpacity(self.NormalColor)
        if self.SkillState ~= "Normal" then
          self.SkillState = "Normal"
          self.RGStateController_Skill:ChangeStatus("Normal")
        end
      end
    else
      UpdateVisibility(self.Progress_Count, false)
    end
  end
end

return WBP_HeynckesSkillQCountPanel_C
