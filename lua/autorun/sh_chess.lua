﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA
if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("chess/sh_player_ext.lua")
    AddCSLuaFile("chess/cl_top.lua")
    include("chess/sh_player_ext.lua")
    include("chess/sv_sql.lua")
else
    include("chess/sh_player_ext.lua")
    include("chess/cl_top.lua")
end