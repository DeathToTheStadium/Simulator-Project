-- Scripted By DeathToTheStadium/ AKA ROBLOXTUTOR
-- Date: 09/25/2021
-- Time: 3:35PM PST


local ENV = {}
ENV.Service      = {}

ENV.Modules      = {}
ENV.Methods      = {}
ENV.Functions    = {}
ENV.Where        = {}
ENV.Variable     = {}
ENV.Tables       = {}
ENV.Classes      = {}



--services
ENV.Service.Work         = game:GetService('Workspace')
ENV.Service.Replicated   = game:GetService('ReplicatedStorage')
ENV.Service.Lighting     = game:GetService('Lighting')
ENV.Service.Debri        = game:GetService('Debris')
ENV.Service.Datastore    = game:GetService('DataStoreService')
ENV.Service.Http         = game:GetService('HttpService')
ENV.Service.Players      = game:GetService('Players')
ENV.Service.Server       = game:GetService('ServerScriptService')
ENV.Service.Storage      = game:GetService('ServerStorage')
ENV.Service.Market       = game:GetService('MarketplaceService')
ENV.Service.Run          = game:GetService('RunService')
ENV.Service.Friends      = game:GetService('FriendService')
ENV.Service.Chat         = game:GetService('Chat')

--methods

--<number handling>--
ENV.Methods.abs          = math.abs
ENV.Methods.acos         = math.acos
ENV.Methods.asin         = math.asin
ENV.Methods.atan         = math.atan
ENV.Methods.atan2        = math.atan2
ENV.Methods.ceil         = math.ceil
ENV.Methods.clamp        = math.clamp
ENV.Methods.cos          = math.cos
ENV.Methods.cosh         = math.cosh
ENV.Methods.deg          = math.deg
ENV.Methods.exp          = math.exp
ENV.Methods.floor        = math.floor
ENV.Methods.fmod         = math.fmod
ENV.Methods.frexp        = math.frexp
ENV.Methods.huge         = math.huge
ENV.Methods.idexp        = math.ldexp
ENV.Methods.log          = math.log
ENV.Methods.log10        = math.log10
ENV.Methods.max          = math.max
ENV.Methods.min          = math.min
ENV.Methods.pi           = math.pi
ENV.Methods.sqrt         = math.sqrt
ENV.Methods.sin          = math.sin
ENV.Methods.tan          = math.tan

--<OS handling>--
ENV.Methods.time         = os.time
ENV.Methods.clock        = os.clock
ENV.Methods.date         = os.date
ENV.Methods.difftime     = os.difftime

--<DateTime handling>--
ENV.Methods.dtnow        = DateTime.now
ENV.Methods.dtiso        = DateTime.fromIsoDate
ENV.Methods.dtlocal      = DateTime.fromLocalTime
ENV.Methods.dtuniversal  = DateTime.fromUniversalTime
ENV.Methods.dtunix       = DateTime.fromUnixTimestamp
ENV.Methods.dtunixmils   = DateTime.fromUnixTimestampMillis

--<Task handling>--
ENV.Methods.defer        = task.defer
ENV.Methods.spawn        = task.spawn
ENV.Methods.wait         = task.wait
ENV.Methods.delay        = task.delay
ENV.Methods.sync         = task.synchronize
ENV.Methods.desync       = task.desynchronize

--ENV.Where



--modules
function LoopModules(Value)
	local Children = Value:GetChildren()
	for i =1 ,#Children  do
		if Children[i]:IsA('Folder') then
			--print(Children[i],Value)
			LoopModules(Children[i])
		elseif Children[i]:IsA('ModuleScript') and Children[i].Name ~= 'ENV' then
			print(Children[i])
			ENV.Modules[Children[i].Name] = Children[i]
		end
	end
end

for Name,_Instance in pairs(ENV.Where) do
	LoopModules(_Instance)
end

--print(ENV.Modules)
--variables

--Env.Table


--ENV.Variable


--Functions
function ENV.Functions.MakeNil(Value)
	local Type = typeof(Value)
	print(Type)
	if Type == 'table' then
		if getmetatable(Value) ~= nil then setmetatable(Value,nil);end
		for i,_ in pairs(Value) do Value[i] = nil;end
	elseif Type == 'RBXScriptConnection' then
		Value:Disconnect()
	else
		Value = nil
	end
end

function ENV.Functions.MakeInstance(ClassName,Parent,Props)
	local instance = Instance.new(ClassName,Parent)
	for i,v in pairs(Props) do
		if instance[i] then
			instance[i] = v
		else
			debug.traceback("Property Name ".."["..i.."]".."is Invalid")
		end
	end
	return instance
end

function ENV.Functions.MakeFolder(Name,Parent)
	local Folder = Instance.new('Folder',Parent)
	Folder.Name = Name
	return Folder
end

function ENV.Functions.MakeValue(TypeValue,Name,Parent,Value)
	local DataValue = Instance.new(TypeValue.."Value",Parent)
	DataValue.Name = Name
	if Value then
		DataValue.Value = Value
	end
	return DataValue
end

function ENV.Functions.LoopLogic(Data,Logic,ChooseLoop)
    local Value
    if ChooseLoop     == true then
        for i,v in pairs(Data) do
            Value,Data = Logic(i,v)
            if Value == 'break' then
                return Data
            end
        end
    elseif ChooseLoop == false then
        for i=1, #Data ,1 do
            Value = Logic(i,Data)
            if Value == 'break' then
                return Data
            end
        end
    elseif ChooseLoop == nil then
        for i= Data.Integer, Data.MaxVal, Data.IncrementBy do
            Value = Logic(i)
            if Value == 'break' then
                return Data
            end
        end
    end
end

--Class Making
ENV.Classes.__index = ENV.Classes

-->This is where a Class is made
function ENV.Classes:new(Name:string)
	ENV.Classes[Name] = {}
	ENV.Classes[Name].__index      = ENV.Classes[Name]
	ENV.Classes[Name].ClassName    = Name
	ENV.Classes[Name]['class-id']  = ENV.Service.Http:GenerateGUID(false)
	return setmetatable(ENV.Classes[Name],ENV.Classes)
end

--> Pass In Your Props in the Tupple
function ENV.Classes:Extend(Table)
	local This = Table
	local Events = {}
	Events.WillDestroy = Instance.new('BindableEvent')
	Events.CanDestroy  = false
	This.__index = self -- self Reference 
	This['object-id'] = ENV.Service.Http:GenerateGUID(false)
	This.ClassName = self.name
	This.GetObjectID = function()
		return This['object-id']
	end
	This.WillDestroy = {}
	function This.WillDestroy:Connect(func)
		if type(func) == 'function' then
			Events.Disconnects = {Events.WillDestroy.Event:Connect(func)}
		else
			error('expected a function not type'.. type(func))
		end
	end

	-->To Completely Destroy the object Set the Variable to nil
	function This:Destroy()
		Events.WillDestroy:Fire(Events)
		Events.CanDestroy = true
		if Events.CanDestroy == true then
			ENV.Functions.MakeNil(This)
			for i=1 , #Events.Disconnects ,1 do ENV.Functions.MakeNil(Events.Disconnects[i])end
			ENV.Functions.MakeNil(Events)
		else 
			warn(debug.traceback('Object:'..This['object-id']..' did not get destroyed',2))
		end
	end

	return setmetatable(This,self)
end

function ENV.Classes:GetClassID()
	return self['class-id']
end

function ENV.Classes:GetClassName()
	return self.ClassName
end

return ENV 

