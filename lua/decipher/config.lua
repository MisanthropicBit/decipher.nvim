local config = {}

local codecs = require("decipher.codecs")

---@class decipher.WindowMappings
---@field close? string
---@field apply? string
---@field jsonpp? string
---@field help? string

---@class decipher.WindowConfig
---@field padding? number
---@field border? (string | string[])[]
---@field mappings? decipher.WindowMappings
---@field title? boolean
---@field title_pos? 'left' | 'center' | 'right'
---@field autoclose? boolean
---@field enter? boolean
---@field options? table<string, any>

---@class decipher.Config
---@field active_codecs? (string | decipher.Codecs)[] | "all"
---@field user_codecs? decipher.Codec[]
---@field float? decipher.WindowConfig

---@type decipher.Config
local default_config = {
    active_codecs = "all",
    float = {
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
        mappings = {
            close = "q",
            apply = "a",
            jsonpp = "J",
            help = "?",
        },
        title = true,
        title_pos = "left",
        autoclose = true,
        enter = false,
        options = {},
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
                return false, ("Invalid codec '%s' at index %d in config.active_codecs"):format(value, idx)
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
        ["float.padding"] = { _config.float.padding, "number" },
        ["float.border"] = { _config.float.border, validate_border, "valid border" },
        ["float.mappings"] = { _config.float.mappings, "table" },
        ["float.mappings.close"] = { _config.float.mappings.close, "string" },
        ["float.mappings.apply"] = { _config.float.mappings.apply, "string" },
        ["float.mappings.jsonpp"] = { _config.float.mappings.jsonpp, "string" },
        ["float.mappings.help"] = { _config.float.mappings.help, "string" },
        ["float.title"] = { _config.float.title, "boolean" },
        ["float.title_pos"] = { _config.float.title_pos, "string" },
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
