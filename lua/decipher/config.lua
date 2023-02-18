local config = {}

local codecs = require("decipher.codecs")

---@class decipher.WindowConfig
---@field max_width number | "auto"
---@field max_height number | "auto"
---@field padding number
---@field border (string | string[])[]
---@field dismiss? string
---@field apply? string
---@field title boolean
---@field title_separator string
---@field autoclose boolean
---@field enter boolean
---@field options table<string, any>

---@class decipher.Config
---@field active_codecs (string | decipher.Codecs)[] | "all"
---@field float decipher.WindowConfig

---@type decipher.Config
local default_config = {
    active_codecs = "all",
    float = {
        max_height = "auto",
        max_width = "auto",
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
        apply = "a",
        title = true,
        title_separator = "─",
        autoclose = true,
        enter = false,
        options = {
            wrap = false,
        },
    },
}

---@type decipher.Config
local _user_config = default_config

---@param user_config? decipher.Config
function config.setup(user_config)
    _user_config = vim.tbl_deep_extend("keep", user_config or {}, default_config)

    if _user_config.active_codecs == "all" then
        _user_config.active_codecs = codecs.supported()
    end
end

setmetatable(config, {
    __index = function(_, key)
        return _user_config[key]
    end,
})

return config
