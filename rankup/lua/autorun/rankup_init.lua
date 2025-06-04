--[[
  RankUp initialization file. Handles file inclusion on server and client.
]]

if SERVER then
  AddCSLuaFile("rankup/server/sv_rankup.lua")
  AddCSLuaFile("rankup/server/sv_networking.lua")
end
AddCSLuaFile("rankup/client/cl_rankup.lua")
AddCSLuaFile("rankup/client/cl_menu.lua")
AddCSLuaFile("rankup/client/cl_waterbuff.lua")
resource.AddFile("materials/rankup_icon.vmt")

if SERVER then
  include("rankup/server/sv_rankup.lua")
  include("rankup/server/sv_networking.lua")
else
  include("rankup/client/cl_rankup.lua")
  include("rankup/client/cl_menu.lua")
  include("rankup/client/cl_waterbuff.lua")
end
