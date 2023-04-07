-- This script serves as an example on how to use the module above. I want to write documentation at some point, but for now I hope this will suffice.
local Interpreter = require(script.Parent) -- this should lead to the module script

local snippet1 = "set twelve+thirteen 12 + 13\nset three-two 3 - 2\nset three*two 3 * 2\nset six/two 6 / 2\nset seven%two 7 % 2\nset seven^two 7 ^ 2\nset nineroottwo 9 rt 2\nset hi Hello there"
local snippet2 = "set twelve+thirteen 12 + 13 \n prt twelve+thirteen \n prt |twelve+thirteen| \n rem twelve+thirteen \n prt twelve+thirteen"

-- A snippet is a body of code separated by '\n' (new line characters)
-- Currently, mathematical operations are supported, and the keyword 'set' can be used to assign to variables
-- When a snippet is run, it will return a boolean (did it successfully complete), and if it successfully completed, a dictionary of all the variables set to.
-- Above is an example snippet to showcase the currently available options
-- The order of operations is NOT implemented, when doing multiple operations at once, operations are applied from left to right.

local params1 = Interpreter.createParams(3, 0, true, false)
local params2 = Interpreter.createParams(100, 0, true, false)
local params3 = Interpreter.createParams()

-- prints the results
print(Interpreter.runSnippet(snippet1, params1)) -- this will error, it exceeds maximum variables
print(Interpreter.runSnippet(snippet1, params2)) -- this will work, there are enough variables

print(Interpreter.runSnippet(snippet2))
