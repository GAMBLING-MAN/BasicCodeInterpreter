-- Hello
-- This is Wast3Iand's basic code interpreter
-- It interprets code of a proprietary language
--
-- Find previous update notes here: https://gist.github.com/GAMBLING-MAN/9b532b330fc438edd91b196c7d3f82d4/revisions
-- Find a history of all module versions (starting at 0.1.1) here: 
--
-- Bugs? Suggestions? Contributions? Comments? Feel free to get in touch!
-- @horrificpeeping on Twitter (while it, as a platform, lasts)

-- basic TODO:
-- An 'if' command
-- Differentiate between a 'debuglog' and 'log'
-- A method of end-user input (e.g. a popup textbox or yes/no prompt, and some method to access these inputs without the built-in popups for whatever purpose you may want)
-- Possibly loops of some kind, although a low priority.


local module = {}

local defaultMaxVars = 100 -- integer
local defaultLineDelay = 0 -- number, 0 = wait for minimum time between lines, a higher number means wait for that amount of seconds between lines, a negative number means do not wait between lines (may cause extremely long code to error due to long execution time)
local defaultLogging = true -- boolean

-- 0.0.1 version notes: initial release
-- 0.0.2 version notes: fixing my dumb mistakes, a lot of values now use local instead of module so that you can't accidentally use methods not intended for you
-- 0.1.0 version notes: added rem (removes a variable), added prt (prints the evaluation of all following inputs, can be used to print variables), fixed some bugs and mistakes
-- 0.1.1 version notes: added adjustable delay between executed lines; this required a rewrite of the entire system (and introduced some really stupid code), however it does fix bugs i hadn't considered before

local VERSION = "0.1.1" -- Yes, this is intended to be a string
local ModuleLink = "https://www.roblox.com/library/12984141083/Basic-Code-Interpreter" -- this is printed first instead of blindly trusting the gist value

-- auto version check code; requires HTTP service
-- change to 'true' to enable auto-version checking
-- change to 'false' to disable autochecking completely
local autocheckVersion = true

if autocheckVersion then
	local http = game:GetService("HttpService")
	-- this gist stores the data on version and link to update
	local gistLink = "https://gist.githubusercontent.com/GAMBLING-MAN/9b532b330fc438edd91b196c7d3f82d4/raw"
	
	local suc, err = pcall(function()
		return http:GetAsync(gistLink) 
	end)
	if suc then
		local data = http:JSONDecode(err)
		local v = data.ModuleVersion
		local s1, v1 = string.split(VERSION,"."), string.split(v,".")
		
		--print(data)
		
		local uptodate = false
		if tonumber(s1[1]) == tonumber(v1[1]) and tonumber(s1[2]) == tonumber(v1[2]) and tonumber(s1[3]) == tonumber(v1[3]) then
			uptodate = true -- this says you're out of date if your version number is above the current version as well. this is intended behaviour
		end

		if uptodate then
			print("Version check successful, you're up to date!")
		else
			print("Version check successful, your module is out of date!")
			print("You can find the updated version here:", ModuleLink)
			--print("If that link doesn't lead to the updated module for some reason, this link comes from the gist:", data.ModuleLink) uncomment this if the link doesnt work
		end
	else
		print("HTTP requests are disabled, the auto-check for updates wasn't completed.")
		print("You can disable auto-checks in the module (where this line is printed from), or you can enable HTTP requests to automatically check for updates.")
	end
end

------

local storage = {}

local commandWords = {
	"set",
	"rem",
	"prt"
}

local operations = {
	["+"] = "add",
	["-"] = "sub",
	["/"] = "div",
	["*"] = "mul",
	["^"] = "exp",
	["%"] = "mod",
	["rt"] = "rt"
}

local stringDefiners = {
	"|"
}

local operationSigns = {}
for k, _ in pairs(operations) do
	table.insert(operationSigns, k)
end


local forbidden = {}

-- forbid all special words and characters
for _, v in ipairs(commandWords) do
	table.insert(forbidden, v)
end

for _, v in ipairs(stringDefiners) do
	table.insert(forbidden, v)
end

for _, v in ipairs(operationSigns) do
	table.insert(forbidden, v)
end

------
local operation = {}
local commands = {}
local internal = {}

------

function internal.dictLength(dictionary)
	local i = 0
	
	for _, _ in pairs(dictionary) do
		i+=1
	end
	
	return i
end

function internal.runLine(line: string, params)
	local sects = string.split(line," ")

	while true do -- prevent any double spaces or beginning line spaces from messing with code
		local n = table.find(sects, "")
		if n ~= nil then
			table.remove(sects,n)
			if params.log then
				print("removed a double space")
			end
		else
			break
		end
	end

	for i, v in ipairs(sects) do
		if table.find(commandWords, v) ~= nil then
			return coroutine.wrap(commands[v])(sects, i, params)
		end
	end
end

--runs a given snippet of code
function internal.runSnippet(snip: string, params)
	if type(params["log"]) ~= "boolean" then
		params.log = defaultLogging
		if params.log then
			print("defaulting to default logging boolean")
		end
	end

	if type(params["maxVariables"]) ~= "number" then
		params.maxVariables = defaultMaxVars
		if params.log then
			print("defaulting to default variable maximum")
		end
	end
	params.maxVariables = math.round(params.maxVariables) -- just to be safe
	
	if type(params["lineDelay"]) ~= "number" then
		params.lineDelay = defaultLineDelay
		if params.log then
			print("defaulting to default line delay")
		end
	end

	if snip == nil then
		local mes = "No code snippet provided!"
		if params.log then
			warn(mes)
		end
		return false, mes
	end
	
	local store = storage[params.storageKey]
	
	store.Variables = {}
	local variables = storage[params.storageKey].Variables

	for i, v in ipairs(string.split(snip,"\n")) do
		local suc, err = internal.runLine(v, params)

		if not suc then
			local mes = "Error on line "..tostring(i)
			if params.log then
				warn(mes, err)			
			end
			store.Succeeded = false
			store.Return = {mes, err}
			store.Completed = true
			return
		end
		
		if params.lineDelay >= 0 then
			task.wait(params.lineDelay)
		end
	end
	
	store.Succeeded = true
	store.Completed = true
end

----

function operation.evaluate(sects, params)	
	local store = storage[params.storageKey]
	
	for i, v in ipairs(sects) do
		local n = store.Variables[v]
		if n ~= nil then
			sects[i] = n
		end
	end
	
	for i, v in ipairs(sects) do
		local n = tonumber(v)
		if n ~= nil then
			sects[i] = n
		end
	end
	
	for i, v in ipairs(sects) do
		for _, l in ipairs(stringDefiners) do
			local s = string.split(v,l)
			if s[1] == "" and s[3] == "" then
				sects[i] = s[2]
			end
		end
	end
	
	local allstring = true
	for _, v in ipairs(sects) do
		if type(v) ~= "string" then
			allstring = false
		end
	end
	
	if allstring then
		local str = ""
		for i, v in ipairs(sects) do
			str = str..v
			if i ~= #sects then
				str = str.." "
			end
		end
		return true, {str}
	end
	
	while true do
		for i, v in ipairs(sects) do
			if #sects > 1 and i ~= 1 then
				if type(sects[i-1]) == "number" and type(sects[i+1]) == "number" then
					if #sects > i then
						if v == "^" then
							sects[i] = sects[i-1]^sects[i+1]
						elseif v == "%" then
							sects[i] = sects[i-1]%sects[i+1]
						elseif v == "*" then
							sects[i] = sects[i-1]*sects[i+1]
						elseif v == "/" then
							sects[i] = sects[i-1]/sects[i+1]
						elseif v == "+" then
							sects[i] = sects[i-1]+sects[i+1]
						elseif v == "-" then
							sects[i] = sects[i-1]-sects[i+1]
						elseif v == "rt" then
							sects[i] = sects[i-1]^(1/sects[i+1])
						else
							continue
						end
						table.remove(sects,i+1)
						table.remove(sects,i-1)
						break
					else
						return false, "No argument following equation sign"
					end
				else
					return false, "Non-number entered into equation"
				end
			end
		end
		
		local solved = true -- inefficiency rocks
		for _, v in ipairs(sects) do
			if table.find(operationSigns, v) then
				solved = false
			end
		end
		
		if solved then
			break
		end
	end
	
	return true, sects
end

--------

function commands.set(sects, n, params)
	if n ~= 1 then
		return false, "Set can only be used at the start of a line, or did you add a space?"
	elseif #sects < 3 then -- 1 for set, 1 for name, at least 1 for value
		return false, "Set requires at least 2 input variables/values"
	elseif tonumber(sects[2]) ~= nil then
		return false, "Cannot set to a numerical variable: "..sects[2]
	elseif table.find(forbidden,sects[2]) ~= nil then
		return false, "Cannot set to a forbidden word or symbol: "..sects[2]
	else -- if we're good to go
		local store = storage[params.storageKey]
		
		local send = table.clone(sects)
		table.remove(send, 2)
		table.remove(send, 1)
		local suc, err = operation.evaluate(send, params)
		if suc then
			if internal.dictLength(store.Variables) < params.maxVariables or store.Variables[sects[2]] ~= nil then -- if there is space for a new variable OR we're overwriting an old one
				store.Variables[sects[2]] = err[1]
				return true --, variables[sects[2]]
			else -- if neither of the above, error
				return false, "Attempt to write to a variable exceeded the max number of variables."
			end
		else
			return false, err
		end
	end
end

function commands.rem(sects, n, params)
	if n ~= 1 then
		return false, "Rem can only be used at the start of a line"
	elseif #sects ~= 2 then -- 1 for rem, 1 for variable name
		return false, "Rem can only remove 1 variable at a time"
	else
		local store = storage[params.storageKey]
		
		store.Variables[sects[2]] = nil
		return true
	end
end

function commands.prt(sects, n, params)
	if n ~= 1 then
		return false, "Prt can only be used at the start of a line"
	else
		local send = table.clone(sects)
		table.remove(send, 1)
		local suc, err = operation.evaluate(send, params)
		if suc then
			print(err[1])
			return true
		else
			return false, err
		end	
	end
end

--------

function module.runSnippet(snip: string, params: Dictionary)
	if params == nil then
		params = module.createParams()
	end
	
	local key -- this is so stupid
	while true do
		key = math.random(0,10000)
		if storage[tostring(key)] == nil then
			break
		end
	end
	key = tostring(key)
	
	params.storageKey = key
	storage[key] = {}
	
	storage[key].Completed = false
	storage[key].Succeeded = false
	coroutine.wrap(internal.runSnippet)(snip, params)
	
	repeat task.wait() until storage[key].Completed == true -- this is, quite possibly, the worst code i have ever written
	local tab = storage[key]
	storage[key] = nil
	
	if tab["Return"] ~= nil then
		return tab.Succeeded, tab["Variables"], tab.Return
	end
	return tab.Succeeded, tab["Variables"] 
end

function module.createParams(maxVariables: number, lineDelay: number, enableLogging: boolean)
	local params = {}
	
	if type(maxVariables) == "number" then
		params.maxVariables = math.round(maxVariables) -- just to be safe
	else
		params.maxVariables = defaultMaxVars
	end
	
	if type(lineDelay) == "number" then
		params.lineDelay = lineDelay
	else
		params.lineDelay = defaultLineDelay
	end
	
	if type(enableLogging) == "boolean" then
		params.log = enableLogging
	else
		params.log = defaultLogging
	end
	
	return params
end

return module