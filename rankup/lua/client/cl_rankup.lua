--[[
  Client HUD elements for RankUp.
  Draws XP bar and level information on the player's screen.
]]

hook.Add("HUDPaint", "RankUp_DrawHUD", function()
  local ply = LocalPlayer()
  if not IsValid(ply) or not ply:Alive() then return end

  local xp  = ply:GetNWInt("RankUp_XP", 0)
  local lvl = ply:GetNWInt("RankUp_Level", 1)
  local nextXP = RankUp.Config.LevelBase * lvl

  local barW, barH = 200, 20
  local xPos, yPos = 20, ScrH() - 50

  draw.RoundedBox(4, xPos, yPos, barW, barH, Color(50,50,50,180))
  local fillW = math.Clamp((xp / nextXP) * barW, 0, barW)
  draw.RoundedBox(4, xPos, yPos, fillW, barH, Color(100,255,100,200))
  draw.SimpleText("Niveau "..lvl.." - XP : "..xp.."/"..nextXP, "DermaDefaultBold", xPos + barW/2, yPos + barH/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

