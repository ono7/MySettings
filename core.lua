-- 1. DEFINE THE LOGIC FUNCTION
print("Loading MySettings... have a wonderful time hunting")
local function OptimizeSettings(triggerSource)
  local _, _, _, worldLag = GetNetStats()

  -- Safety checks
  if worldLag < 20 then
    worldLag = 20
  end

  -- Calculate Queue Window
  local tolerance = 100
  local newSQW = worldLag + tolerance
  SetCVar("SpellQueueWindow", newSQW)

  -- PvP Check
  local isPvPInstance = C_PvP.IsPVPMap()
  local pvpStatusText = ""

  if isPvPInstance then
    SetCVar("TargetPriorityPVP", 3)
    pvpStatusText = "|cffFF0000[PvP-Targetting]|r"
  else
    SetCVar("TargetPriorityPVP", 1)
    pvpStatusText = "|cff00AAFF[PvE-Targetting]|r"
  end

  -- Output
  print(
    "|cff00ff00[MySettings]|r "
      .. pvpStatusText
      .. " (Src: "
      .. triggerSource
      .. ") | Latency: "
      .. worldLag
      .. "ms | Queue: "
      .. newSQW
      .. "ms"
  )
end

-- 2. EVENT LISTENER (Automated: Login / Zone / Reload)
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function()
  -- We still need the delay on zone/reload to let the network jitter settle
  C_Timer.After(5, function()
    OptimizeSettings("Auto")
  end)
end)

-- 3. SLASH COMMAND (Manual: Force Run)
SLASH_AUTOSQW1 = "/sqw"
SlashCmdList["AUTOSQW"] = function()
  -- No delay needed for manual trigger
  OptimizeSettings("Manual")
end
