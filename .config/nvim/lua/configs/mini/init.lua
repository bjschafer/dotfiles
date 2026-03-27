local surround_ok, surround = pcall(require, "mini.surround")
if surround_ok then
    surround.setup()
end

local operators_ok, operators = pcall(require, "mini.operators")
if operators_ok then
    operators.setup()
end
