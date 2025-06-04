--[[
  Derma menu displayed when the player uses the !rang command.
]]

net.Receive("rankup_open_menu", function()
  local ply = LocalPlayer()
  local xp  = ply:GetNWInt("RankUp_XP", 0)
  local lvl = ply:GetNWInt("RankUp_Level", 1)
  local nextXP = RankUp.Config.LevelBase * lvl

  local frame = vgui.Create("DFrame")
  frame:SetTitle("Progression de Rang")
  frame:SetSize(300, 250)
  frame:Center()
  frame:MakePopup()

  local lvlLabel = vgui.Create("DLabel", frame)
  lvlLabel:SetPos(20, 40)
  lvlLabel:SetText("Niveau actuel : "..lvl)
  lvlLabel:SizeToContents()

  local xpLabel = vgui.Create("DLabel", frame)
  xpLabel:SetPos(20, 65)
  xpLabel:SetText("XP : "..xp.."/"..nextXP)
  xpLabel:SizeToContents()

  local perksLabel = vgui.Create("DLabel", frame)
  perksLabel:SetPos(20, 95)
  perksLabel:SetText("Bonus par niveau :")
  perksLabel:SizeToContents()

  local perksText = ""
  for i = 1, lvl + 2 do
    local healthBonus = (i - 1) * RankUp.Config.HealthPerLevel
    local speedBonus  = (i - 1) * RankUp.Config.SpeedPerLevel
    perksText = perksText.."\nNiveau "..i.." : +"..healthBonus.." HP, +"..speedBonus.." vitesse"
  end

  local perksDesc = vgui.Create("DTextEntry", frame)
  perksDesc:SetPos(20, 115)
  perksDesc:SetSize(260, 110)
  perksDesc:SetMultiline(true)
  perksDesc:SetEditable(false)
  perksDesc:SetText(perksText)
end)

