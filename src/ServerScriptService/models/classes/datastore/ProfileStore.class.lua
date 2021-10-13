--[[
Scripted BY ROBLOXTUTOR - AKA DeathToTheStadium
Date: 9/16/2021,
Time: 2:50AM PST
]]

local ENV = require(script.Parent)
local DatastoreClass = ENV.Classes:new('DatastoreClass')
DatastoreClass.ProfileStore = {}


--[[
EXAMPLE OF HOW THE CLASS SHOULD BE EXTENDED
DatastoreClass:Extend({
	ProfileService,
  })
  
  WARNNINGS:ONLY MAKE ONE DATASTORE OBJECT OTHERWISE YOU WILL OVERLOAD YOUR SAVE LIMITS
  AND CAUSE OTHER UNFORSEEN ERRORS

  THIS MODULE IS EQUIPPED WITH PARAMETER AND FUNCTION PURPOSE DOCUMENTATION
]]


--Methods


--[[
Purpose: Initializes a Profile Store that Can be Used With ProfileService or with middlewares

Parameters:
	1.[Name]<string>: Name is the Name of the ProfileStore your Creating,
	
	2.[Template]<table>: Template is the Dataset you are going to use to make 
				  Player Profiles
	
	3.[LoadNow]<boolean>: Specifies wether you just want to get the ProfileStore Now 
				 by returning The ProfileStore so you can Load Profiles for Things
				 Like Leaderboards Instead of Saving Internally for use with a player Functions
]]
function DatastoreClass:initProfileStore(Name:string,Template,LoadNow:boolean)
	local LoadNow = LoadNow or false
	self.ProfileStore[Name] = self.ProfileService.GetProfileStore(
		Name,
		Template
	)
	if LoadNow then
		return self.ProfileStore[Name]
	end
end

--[[
Purpose: Loads a ProfileStore To Be Used to SaveData for the Player and Pass data Around
using _G.Profiles To Be Accessed By Other Scripts

Parameters:
	1.[Name]<string>: Name is the Name of the ProfileStore your Accessing,
	
	2.[Player]<object>: This Parameter Is Basically the Player Object
	
	3.[Middleware]<function>: Middleware is Used to Make Use of Any Data 
	and To run a list of Functions to get Data From the ProfileStore if you Choose
]]
function DatastoreClass:LoadProfileStore(Name,Player,middleware,List)
	local profile = self.ProfileStore[Name]:LoadProfileAsync('User_'..Player.UserId)
	if profile ~= nil then
		profile:AddUserId(Player.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function()self.Profiles[Player] = nil;Player:Kick();end)
		if Player:IsDescendantOf(ENV.Service.Players) == true then
			self.Profiles[Player] = profile
			local _middleware,_next = middleware,List -- ignore warning
			_middleware(Player,profile)
			if _next then
				--print(_next)
				for i=1,#_next,1 do 
					_next[i](Player,profile)
				end
			end
		else
			Player:Kick() 
		end
	end
end

--[[
Purpose: Middleware Function Used with LoadProfile Store to make Allow Chaining of functions
as well as the ability to do something with the Data or pass it on

Parameters:
	1.[Func]<function>: this is a Top Function Used to do something with the profile once its Created,
	
	2.[funcList]<ARRAY>: Func list is a an array of functions that get Player, And Profile Returned in to them
]]
function DatastoreClass.Middleware(func,funcList)
	if func and #funcList > 0 then
		return func, funcList
	elseif func and not funcList then
		return func, nil
	elseif not func then
		error('function required To load Middleware')
	end
end


--[[
Purpose: To Release a profile From a Player 

Parameters:
	1.[Player]<string>: This Parameter Is Basically the Player Object
]]
function DatastoreClass:ReleaseProfile(Player)
	local profile = self.Profiles[Player]
	if profile ~= nil then
		profile:Release()
		print(Player.Name.." Profile has been Released")
	end
end



return DatastoreClass