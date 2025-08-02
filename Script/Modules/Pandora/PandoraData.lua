local PandoraAppIdTable = {
  CN = {
    Announce = {
      ID = "5157",
      bCustWidget = false,
      bDisruptiveUI = false
    },
    Survey = {
      ID = "6568",
      bCustWidget = false,
      bDisruptiveUI = true
    },
    EventApp = {
      ID = "",
      bCustWidget = false,
      bDisruptiveUI = false
    },
    CarouselImage = {
      ID = "7479",
      bCustWidget = true,
      bDisruptiveUI = false
    },
    Treasure = {
      ID = "7485",
      bCustWidget = true,
      bDisruptiveUI = false
    }
  },
  INTL = {
    Announce = {
      ID = "3007",
      bCustWidget = false,
      bDisruptiveUI = false
    },
    Survey = {
      ID = "3020",
      bCustWidget = false,
      bDisruptiveUI = true
    },
    EventApp = {
      ID = "",
      bCustWidget = false,
      bDisruptiveUI = false
    },
    CarouselImage = {
      ID = "3208",
      bCustWidget = true,
      bDisruptiveUI = false
    },
    Treasure = {
      ID = "3209",
      bCustWidget = true,
      bDisruptiveUI = false
    }
  }
}
local PandoraData = {
  AdList = {},
  DisruptiveUI = {}
}

function PandoraData:GetAnnounceAppId()
  local openAppId = ""
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.INTL.Announce.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  else
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.CN.Announce.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  end
  return openAppId
end

function PandoraData:GetEventAppId()
  local openAppId = ""
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.INTL.EventApp.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  else
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.CN.EventApp.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  end
  return openAppId
end

function PandoraData:GetPayAppId()
  local openAppId = ""
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.INTL.Pay.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  else
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.CN.Pay.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  end
  return openAppId
end

function PandoraData:GetProductInfoAppId()
  local openAppId = ""
  for key, SingleADInfo in pairs(PandoraData.AdList) do
    if SingleADInfo.OpenAppId == PandoraAppIdTable.INTL.ProductInfo.ID then
      openAppId = SingleADInfo.OpenAppId
      break
    end
  end
  return openAppId
end

function PandoraData:GetCarouselImageAppId()
  local openAppId
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.INTL.CarouselImage.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  else
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.CN.CarouselImage.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  end
  return openAppId
end

function PandoraData:GetTreasureAppId()
  local openAppId
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.INTL.Treasure.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  else
    for key, SingleADInfo in pairs(PandoraData.AdList) do
      if SingleADInfo.OpenAppId == PandoraAppIdTable.CN.Treasure.ID then
        openAppId = SingleADInfo.OpenAppId
        break
      end
    end
  end
  return openAppId
end

function PandoraData:ClearData()
  PandoraData.AdList = {}
end

function PandoraData:AddAdInfo(AdId, AdInfo)
  PandoraData.AdList[AdId] = AdInfo
end

function PandoraData:HasApp()
  return table.count(PandoraData.AdList) > 0
end

function PandoraData:ShowPandoraPanle(AppId)
  local Config = {}
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    Config = PandoraAppIdTable.INTL
  else
    Config = PandoraAppIdTable.CN
  end
  for k, value in pairs(Config) do
    if value.ID == AppId then
      return not value.bCustWidget
    end
  end
  return false
end

function PandoraData:IsDisruptiveUI(AppId)
  local Config = {}
  if UE.URGPlatformFunctionLibrary.IsIntlEdition() then
    Config = PandoraAppIdTable.INTL
  else
    Config = PandoraAppIdTable.CN
  end
  for k, value in pairs(Config) do
    if value.ID == AppId then
      return value.bDisruptiveUI
    end
  end
  return false
end

return PandoraData
