-- get full path to this configs directory
local configs_dir = vim.fn.stdpath("config") .. "/lua/configs"
-- get full paths of all config dirs within this configs directory
local configs = vim.split(vim.fn.glob(configs_dir .. "/*"), "\n", { trimempty = true })

for _, cfg in pairs(configs) do
    if vim.fn.isdirectory(cfg) ~= 0 then
        cfg = cfg:gsub(configs_dir, "configs")
        local ok, err = pcall(require, cfg)
        if not ok then
            vim.notify("Failed to load config: " .. cfg .. "\n" .. err, vim.log.levels.ERROR)
        end
    end
end
