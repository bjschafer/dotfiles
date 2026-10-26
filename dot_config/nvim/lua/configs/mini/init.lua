local surround_ok, surround = pcall(require, "mini.surround")
if surround_ok then
    surround.setup()
end

local operators_ok, operators = pcall(require, "mini.operators")
if operators_ok then
    operators.setup()
end

local pairs_ok, pairs = pcall(require, "mini.pairs")
if pairs_ok then
    pairs.setup()
end
