-- 1. COLOR & LOGGING HELPERS
local Colors = {
  green = "00ff00",
  blue = "00aaff",
  red = "ff0000",
  white = "ffffff",
  yellow = "ffff00",
}

local function Colorize(text, color)
  local hex = Colors[color] or Colors.white
  return "|cff" .. hex .. tostring(text) .. "|r"
end

local function Log(message, value)
  local prefix = Colorize("[MySettings]", "green")
  local suffix = value and (": " .. Colorize(value, "blue")) or ""
  print(prefix .. " " .. message .. suffix)
end

-- 2. INITIALIZATION
Log("Loading MySettings... have a wonderful time hunting")

local nameplateOverlapV = "0.28"
SetCVar("nameplateOverlapV", nameplateOverlapV)
Log("[GUI] nameplateOverlapV", nameplateOverlapV)

SetCVar("nameplateShowFriends", 0)
Log("[GUI] ShowFriendlyPlates", "0")

SetCVar("nameplateShowFriendlyNPCs", 0)
Log("[GUI] ShowFriendlyNPC", "0")

SetCVar("floatingCombatTextCombatHealing", 0)
Log("[GUI] HideCombatHealing", "0")

-- 3. OPTIMIZATION LOGIC
local function OptimizeSettings(triggerSource)
  local _, _, _, worldLag = GetNetStats()

  if worldLag < 20 then
    worldLag = 20
  end

  local tolerance = 100
  local newSQW = worldLag + tolerance
  SetCVar("SpellQueueWindow", newSQW)

  local isPvPInstance = C_PvP.IsPVPMap()
  local pvpStatusText = isPvPInstance and Colorize("[PvP-Targetting]", "red") or Colorize("[PvE-Targetting]", "blue")

  -- Output using integrated colors
  Log(pvpStatusText .. " (Src: " .. triggerSource .. ") | Latency: " .. worldLag .. "ms", "Queue: " .. newSQW .. "ms")
end

-- 4. EVENT LISTENER
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
  C_Timer.After(5, function()
    OptimizeSettings("Auto")
  end)
end)

-- 5. SLASH COMMAND
SLASH_AUTOSQW1 = "/sqw"
SlashCmdList["AUTOSQW"] = function()
  OptimizeSettings("Manual")
end

-- 6. AUTO MERCHANT
local m = CreateFrame("Frame")
m:RegisterEvent("MERCHANT_SHOW")
m:SetScript("OnEvent", function()
  if CanMerchantRepair() then
    local cost = GetRepairAllCost()
    if cost > 0 then
      RepairAllItems()
      Log("Repaired", GetCoinTextureString(cost))
    end
  end

  for bag = 0, 4 do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info and info.quality == 0 and not info.hasNoValue then
        C_Container.UseContainerItem(bag, slot)
      end
    end
  end
end)
