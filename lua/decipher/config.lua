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
            { "╭", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╮", "FloatBorder" },
            { "│", "FloatBorder" },
            { "╯", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╰", "FloatBorder" },
            { "│", "FloatBorder" },
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

--- Validate a dimension
local function validate_dimension(arg)
    return arg == "auto" or type(arg) == "number"
end

--- Validate a codec option
local function validate_codecs(arg)
    if arg == "all" then
        return true
    elseif type(arg) == "table" then
        for idx, value in ipairs(arg) do
            if codecs.get(value) == nil then
                return false, string.format("Invalid codec '%s' at index %d in config.active_codecs", value, idx)
            end
        end

        return true
    end

    return false, 'config.active_codecs should be "all" or a list of codecs'
end

--- Validate a floating window border
local function validate_border(arg)
    local presets = {
        "none",
        "single",
        "double",
        "rounded",
        "solid",
        "shadow",
    }

    return presets[arg] ~= nil or type(arg) == "table"
end

--- Validate a config
---@param _config decipher.Config
local function validate_config(_config)
    vim.validate({
        active_codecs = { _config.active_codecs, validate_codecs, "valid codecs" },
        ["float.max_width"] = { _config.float.max_width, validate_dimension, "valid dimension" },
        ["float.max_height"] = { _config.float.max_height, validate_dimension, "valid dimension" },
        ["float.padding"] = { _config.float.padding, "number" },
        ["float.border"] = { _config.float.border, validate_border, "valid border" },
        ["float.dismiss"] = { _config.float.dismiss, "string" },
        ["float.apply"] = { _config.float.apply, "string" },
        ["float.title"] = { _config.float.title, "boolean" },
        ["float.title_separator"] = { _config.float.title_separator, "string" },
        ["float.autoclose"] = { _config.float.autoclose, "boolean" },
        ["float.enter"] = { _config.float.enter, "boolean" },
        ["float.options"] = { _config.float.options, "table" },
    })
end

---@type decipher.Config
local _user_config = default_config

---@param user_config? decipher.Config
function config.setup(user_config)
    _user_config = vim.tbl_deep_extend("keep", user_config or {}, default_config)

    if _user_config.active_codecs == "all" then
        _user_config.active_codecs = codecs.supported()
    end

    validate_config(_user_config)
end

setmetatable(config, {
    __index = function(_, key)
        return _user_config[key]
    end,
})

return config
