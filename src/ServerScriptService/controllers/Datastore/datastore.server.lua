--[[
Scripted BY ROBLOXTUTOR - AKA DeathToTheStadium
Date: 9/16/2021,
Time: 8:30AM PST
]]

local ENV = require(game:GetService('ServerStorage').models.utilitiy.ENV)
local Profileservice = require(ENV.Modules.ProfileService)
local DataStoreClass = require(ENV.Modules.datastore)
local PlayerClass    = require(ENV.Modules.Player)

_G['Profiles'] = {}

local Datastore = DataStoreClass:Extend({
	ProfileService = Profileservice,
	Profiles       = _G['Profiles']
})

Datastore:initProfileStore("PlayerStorage",ENV.Tables._PlayerDataTemplate,false)

local FunctionTable = {}
FunctionTable[1] = PlayerClass:ManagePlayerData()
FunctionTable[2] = function(Player,Profile)
	local Data = Profile.Data
	local leaderstats = ENV.Functions.MakeFolder('leaderstats',Player)
	local Wins   = ENV.Functions.MakeValue('Int','Wins',leaderstats,Data.Stats.Wins)
	local Losses =  ENV.Functions.MakeValue('Int','Losses',leaderstats,Data.Stats.Losses)
	local Rank   = ENV.Functions.MakeValue('String','Rank',leaderstats,'['..Data.Rank.Title..']')
	
	coroutine.wrap(function()
		repeat wait(.3)
			Wins.Value   = Data.Stats.Wins
			Losses.Value = Data.Stats.Losses
			Rank.Value   = '['..Data.Rank.Title..']'
		until not Player:IsDescendantOf(ENV.Service.Players)
	end)()
end


ENV.Service.Players.PlayerAdded:Connect(function(Player)
	local PlayerObject = PlayerClass:Extend({Player = Player})
	local Middleware,List = Datastore.Middleware(PlayerObject:CreatePlayerData(),FunctionTable)
	PlayerObject:SpawnRemotes()
	PlayerObject:SetUpScreenInterface()
	Datastore:LoadProfileStore("PlayerStorage",Player,Middleware,List)
end)

ENV.Service.Players.PlayerRemoving:Connect(function(Player)
	Datastore:ReleaseProfile(Player)
end)

