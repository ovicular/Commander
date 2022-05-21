--[[
	nickk#5538
	Commander | 5/21/2022
]]

_VERSION = "1.1.0"

local Commander = {
	Prefix = "'",
	Commands = {},

	Types = {
		["string"] = function(String)
			return String
		end,
		["number"] = function(Number)
			return tonumber(Number)
		end,
		["boolean"] = function(Bool)
			return (Bool == "true") or false
		end,
		["integer"] = function(Number)
			return math.floor(tonumber(Number))
		end,
	},
}

Commander.__index = Commander

-- Asserts that the given argument is the given type.
-- @param Value The argument to check
-- @param Type The type to check for
-- @return true or false
function Commander.assertType(Type, Value)
	assert(type(Value) == Type, debug.traceback(Type .. " expected, got " .. type(Value)))
	return true
end

-- Adds a command to the commander table.
-- @param Data table containing the command data
function Commander.addCommand(Data)
	Commander.assertType("table", Data)
	Commander.Commands[Data.Name] = Data
end

-- Runs a command with the given arguments.
-- @param Name The command to run and the arguments to pass following the prefix
function Commander.singleRun(Name)
	Commander.assertType("string", Name)

	local Name = Name:match("^%s*(.-)%s*$")

	local Prefix = Commander.Prefix
	if Name:sub(1, #Prefix):lower() == Prefix then
		Name = Name:sub(#Prefix + 1)
	end

	local function splitName()
		return Name:split(" ")
	end

	local commandName = splitName()[1]:lower()
	local Parsed = splitName()
	table.remove(Parsed, 1)

	for _, Command in next, Commander.Commands do
		if table.find(Command.Name, commandName) then
			for Index, Argument in next, Parsed do
				local Type = Command.Type
				assert(Commander.Types[Type], "Type '" .. Type .. "' not found")
				Parsed[Index] = Commander.Types[Type](Argument)
			end

			return task.spawn(xpcall, Command.Callback, function(err)
				warn(debug.traceback(err):gsub("[\n\r]+", "\n    "))
			end, unpack(Parsed))
		end
	end
end

-- Runs a command with the given arguments (Multiple in one line split using the given delimiter).
-- @param Name The command to run and the arguments to pass following the prefix
-- @param Delimiter The delimiter to split the commands with
function Commander.bulkRun(Name, Delimiter)
	local Delimiter = Delimiter or "\\"

	Commander.assertType("string", Name)
	Commander.assertType("string", Delimiter)

	for v in
		Name
			:match("^%s*(.-)%s*$")
			:gsub(Delimiter .. "+", Delimiter)
			:match("^" .. Delimiter .. "*(.-)" .. Delimiter .. "*$")
			:gmatch("[^" .. Delimiter .. "]+")
	do
		Commander.singleRun(v)
	end
end

return Commander, warn("[Commander]: v" .. _VERSION .. " loaded")
