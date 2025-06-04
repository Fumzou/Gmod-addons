--[[
  Server logic for the RankUp system.
  Handles XP gain, level ups and automatic bonuses.
]]

RankUp = RankUp or {}
RankUp.Config = {
  XPperSalaryRatio = 0.1,   -- XP gained = salary * ratio
  ArrestXP         = 20,    -- Bonus XP for police arrests
  LevelBase        = 100,   -- XP needed to reach level n+1 = LevelBase * n
  HealthPerLevel   = 10,    -- Additional max health per level
  SpeedPerLevel    = 5      -- Additional walk/run speed per level
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

