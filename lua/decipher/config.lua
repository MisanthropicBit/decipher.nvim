---@class WindowConfig
---@field max_width number
---@field max_height number
---@field padding number
---@field border (string | string[])[]
---@field dismiss? string
---@field title boolean
---@field title_separator string
---@field autoclose boolean
---@field enter boolean
---@field options table<string, any>

local config = {}

---@class Config
---@field float decipher.WindowConfig
local default_config = {
    float = {
        max_height = 20,
        max_width = 30,
        padding = 0,
        border = {
            { "╭", "Keyword" },
            { "─", "Keyword" },
            { "╮", "Keyword" },
            { "│", "Keyword" },
            { "╯", "Keyword" },
            { "─", "Keyword" },
            { "╰", "Keyword" },
            { "│", "Keyword" },
        },
        dismiss = "q",
        title = true,
        title_separator = "─",
        autoclose = true,
        enter = false,
        options = {
            wrap = false,
        },
    },
}

---@type Config
local _user_config = default_config

---@param user_config Config
function config.setup(user_config)
    _user_config = vim.tbl_deep_extend("keep", user_config, default_config)
end

setmetatable(config, {
    __index = function(_, key)
        return _user_config[key]
    end,
})

return config
