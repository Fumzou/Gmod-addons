--[[
  Server networking for RankUp.
  Defines chat commands and network messages to open the rank menu.
]]

util.AddNetworkString("rankup_open_menu")

--[[
  Chat command allowing players to open the RankUp menu.
]]
DarkRP.defineChatCommand("rang", function(ply, args)
  net.Start("rankup_open_menu")
  net.Send(ply)
end)

