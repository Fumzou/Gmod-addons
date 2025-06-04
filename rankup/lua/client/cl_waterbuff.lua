--[[
  Displays an indicator when the water buff is active.
]]

hook.Add("HUDPaint", "RankUp_DrawWaterBuff", function()
  local ply = LocalPlayer()
  if not IsValid(ply) then return end
  if not ply:GetNWBool("RankUp_WaterBuff", false) then return end

  surface.SetDrawColor(0, 150, 255, 180)
  surface.DrawRect(20, ScrH() - 80, 200, 18)
  draw.SimpleText("Water Buff Active", "DermaDefaultBold", 120, ScrH() - 71, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

