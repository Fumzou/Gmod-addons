--[[
  Server logic for the RankUp system.
  Handles XP gain, level ups and automatic bonuses.
]]

RankUp = RankUp or {}
RankUp.Config = {
  XPperSalaryRatio = 0.1,   -- XP gained = salary * ratio
  ArrestXP         = 20,    -- Bonus XP for police arrests
  LevelBase        = 100,   -- XP needed to reach level n+1 = LevelBase * n
  HealthPerLevel       = 10,    -- Additional max health per level
  SpeedPerLevel        = 5,     -- Additional walk/run speed per level
  WaterBuffMultiplier  = 20,    -- Multiplier for walk/run speed in water
  WaterBuffHealth      = 50     -- Extra max health while in water
}

RankUp.Data = RankUp.Data or {}

--[[
  Initializes player data when they join the server.
]]
hook.Add("PlayerInitialSpawn", "RankUp_InitData", function(ply)
  local steam = ply:SteamID()
  if not RankUp.Data[steam] then
    RankUp.Data[steam] = {xp = 0, level = 1}
  end
  ply:SetNWInt("RankUp_XP", RankUp.Data[steam].xp)
  ply:SetNWInt("RankUp_Level", RankUp.Data[steam].level)
end)

--[[
  Grant XP whenever the player receives a paycheck.
]]
hook.Add("playerGetSalary", "RankUp_GiveXpOnPaycheck", function(ply, salary)
  local steam = ply:SteamID()
  local gain = math.floor(salary * RankUp.Config.XPperSalaryRatio)
  RankUp.Data[steam].xp = RankUp.Data[steam].xp + gain
  ply:SetNWInt("RankUp_XP", RankUp.Data[steam].xp)
  RankUp:CheckLevelUp(ply)
  DarkRP.notify(ply, 0, 4, "Tu as gagné "..gain.." XP (Total : "..RankUp.Data[steam].xp..")")
end)

--[[
  Grant XP to police players when they arrest someone.
]]
hook.Add("playerArrested", "RankUp_GiveXpOnArrest", function(criminal, police)
  if IsValid(police) and police:IsPlayer() then
    local steam = police:SteamID()
    RankUp.Data[steam].xp = RankUp.Data[steam].xp + RankUp.Config.ArrestXP
    police:SetNWInt("RankUp_XP", RankUp.Data[steam].xp)
    RankUp:CheckLevelUp(police)
    DarkRP.notify(police, 0, 4, "Arrestation réussie ! +"..RankUp.Config.ArrestXP.." XP (Total : "..RankUp.Data[steam].xp..")")
  end
end)

--[[
  Check whether the player should level up based on current XP.
  Applies bonuses when a level is gained.
]]
function RankUp:CheckLevelUp(ply)
  local steam = ply:SteamID()
  local data = RankUp.Data[steam]
  while data.xp >= (RankUp.Config.LevelBase * data.level) do
    data.xp = data.xp - (RankUp.Config.LevelBase * data.level)
    data.level = data.level + 1

    local newMaxHealth = 100 + (data.level - 1) * RankUp.Config.HealthPerLevel
    ply:SetMaxHealth(newMaxHealth)
    ply:SetHealth(newMaxHealth)

    local newWalk = ply:GetWalkSpeed() + RankUp.Config.SpeedPerLevel
    local newRun  = ply:GetRunSpeed() + RankUp.Config.SpeedPerLevel
    ply:SetWalkSpeed(newWalk)
    ply:SetRunSpeed(newRun)

    ply:SetNWInt("RankUp_Level", data.level)
    ply:SetNWInt("RankUp_XP", data.xp)
    DarkRP.notify(ply, 0, 5, "Félicitations ! Tu es passé au niveau "..data.level.." !")
  end
end

--[[
  Handles water buff when players swim.
  Boosts speed and health while in water.
]]
hook.Add("Think", "RankUp_HandleWaterBuff", function()
  for _, ply in ipairs(player.GetAll()) do
    if ply:Alive() then
      local steam = ply:SteamID()
      local data = RankUp.Data[steam]
      if ply:WaterLevel() > 1 then
        if not ply.RankUp_WaterBuff then
          ply.RankUp_WaterBuff = true
          ply.RankUp_OrigWalk = ply:GetWalkSpeed()
          ply.RankUp_OrigRun  = ply:GetRunSpeed()
          ply:SetWalkSpeed(ply.RankUp_OrigWalk * RankUp.Config.WaterBuffMultiplier)
          ply:SetRunSpeed(ply.RankUp_OrigRun * RankUp.Config.WaterBuffMultiplier)
          local newHealth = ply:GetMaxHealth() + RankUp.Config.WaterBuffHealth
          ply:SetMaxHealth(newHealth)
          ply:SetHealth(math.min(ply:Health() + RankUp.Config.WaterBuffHealth, newHealth))
          ply:SetNWBool("RankUp_WaterBuff", true)
        end
      else
        if ply.RankUp_WaterBuff then
          ply.RankUp_WaterBuff = false
          if ply.RankUp_OrigWalk then ply:SetWalkSpeed(ply.RankUp_OrigWalk) end
          if ply.RankUp_OrigRun  then ply:SetRunSpeed(ply.RankUp_OrigRun)  end
          local baseHealth = 100 + (data.level - 1) * RankUp.Config.HealthPerLevel
          ply:SetMaxHealth(baseHealth)
          if ply:Health() > baseHealth then ply:SetHealth(baseHealth) end
          ply:SetNWBool("RankUp_WaterBuff", false)
        end
      end
    else
      if ply.RankUp_WaterBuff then
        ply.RankUp_WaterBuff = false
        if ply.RankUp_OrigWalk then ply:SetWalkSpeed(ply.RankUp_OrigWalk) end
        if ply.RankUp_OrigRun  then ply:SetRunSpeed(ply.RankUp_OrigRun)  end
        local steam = ply:SteamID()
        local data = RankUp.Data[steam]
        local baseHealth = 100 + (data.level - 1) * RankUp.Config.HealthPerLevel
        ply:SetMaxHealth(baseHealth)
        ply:SetNWBool("RankUp_WaterBuff", false)
      end
    end
  end
end)


