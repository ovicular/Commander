--[[

Checking Types:

Commander.CheckType("string", "Hello") --> No error, doesn't return anything
Commander.CheckType("string", true) --> Throws an error with a message: "string expected, got boolean"

Adding Commands:
Commander.AddCommand({ "test" }, "Test command", print) 

Getting Command Information:
local commandInfo = Commander.GetCommandInfo("test") --> { Name = "test", Description = "Test command" }
print(commandInfo.Name) --> "test"
print(commandInfo.Description) --> "Test command"

Running Commands:
Commander.RunCommand("test") --> prints "Hello"

]]

local Commander = {
	Prefix = "'",
	Commands = {},
}

-- Checks the type of value. Throws an error if type is invalid
-- @param The type to check
-- @param The value to check
function Commander.CheckType(Type, Value)
	assert(type(Value) == Type, debug.traceback(Type.." expected, got "..type(Value)))
end

-- Add a command to the list of commands
-- @param Name: The name of the command.
-- @param Description: The description of the command.
-- @param Callback: The function to call when the command is executed.
function Commander.AddCommand(Name, Description, Callback)
	Commander.CheckType("table", Name)
	Commander.CheckType("string", Description)
	Commander.CheckType("function", Callback)

	Commander.Commands[#Commander.Commands + 1] = {
		Name = Name or {},
		Description = Description or "",
		Callback = Callback or function() end,
	}
end

-- Execute a command (Step 1)
-- @param Name: The name of the command to execute.
function Commander.RunCommandI(Name)
	Commander.CheckType("string", Name)

	local Name = Name:match("^%s*(.-)%s*$")

	if Name:sub(1, #Commander.Prefix):lower() == Commander.Prefix then
		Name = Name:sub(#Commander.Prefix + 1)
	end

	local Parsed = Name:split(" ")
	table.remove(Parsed, 1)

	for _, v in ipairs(Commander.Commands) do
		local Cached = Name:split(" ")[1]:lower()

		if table.find(v.Name, Cached) then
			return task.spawn(xpcall, v.Callback, function(err)
				warn(debug.traceback(err):gsub("[\n\r]+", "\n    "))
			end, unpack(Parsed))
		end
	end
end

-- Execute a command (Step 2)
-- @param Name: The name of the command or commands to execute.
function Commander.RunCommand(Name)
	Commander.CheckType("string", Name)

	for v in Name:match("^%s*(.-)%s*$"):gsub("\\+", "\\"):match("^\\*(.-)\\*$"):gmatch("[^\\]+") do
		Commander.RunCommandI(v)
	end
end

-- Get information about a command
-- @param Name: The name of the command to get information about.
-- @return returns the name of the command and the description of the command in a table.
function Commander.GetCommandInfo(Name)
	Commander.CheckType("string", Name)

	for _, v in ipairs(Commander.Commands) do
		if table.find(v.Name, Name:lower()) then
			return {
				Name = v.Name,
				Description = v.Description
			}
		end
	end
end


