local config = {}

---@class decipher.WindowMappings
---@field close? string
---@field apply? string
---@field update? string
---@field jsonpp? string
---@field help? string

---@class decipher.WindowConfig
---@field padding? number
---@field border? string | string[] | string[][]
---@field mappings? decipher.WindowMappings
---@field title? boolean
---@field title_pos? 'left' | 'center' | 'right'
---@field autoclose? boolean
---@field enter? boolean
---@field options? table<string, any>
---@field json_auto_open boolean

---@class decipher.Config
---@field float? decipher.WindowConfig

---@type decipher.Config
local default_config = {
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
            apply = "<leader>a",
            update = "<leader>u",
            jsonpp = "<leader>j",
            help = "g?",
        },
        title = true,
        title_pos = "left",
        autoclose = true,
        enter = false,
        options = {},
        json_auto_open = true,
    },
}

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
        ["float.padding"] = { _config.float.padding, "number" },
        ["float.border"] = { _config.float.border, validate_border, "valid border" },
        ["float.mappings"] = { _config.float.mappings, "table" },
        ["float.mappings.close"] = { _config.float.mappings.close, "string" },
        ["float.mappings.apply"] = { _config.float.mappings.apply, "string" },
        ["float.mappings.update"] = { _config.float.mappings.update, "string" },
        ["float.mappings.jsonpp"] = { _config.float.mappings.jsonpp, "string" },
        ["float.mappings.help"] = { _config.float.mappings.help, "string" },
        ["float.title"] = { _config.float.title, "boolean" },
        ["float.title_pos"] = { _config.float.title_pos, "string" },
        ["float.autoclose"] = { _config.float.autoclose, "boolean" },
        ["float.enter"] = { _config.float.enter, "boolean" },
        ["float.options"] = { _config.float.options, "table" },
        ["float.json_auto_open"] = { _config.float.json_auto_open, "boolean" },
    })
end

---@type decipher.Config
local _user_config = default_config

---Use in testing
---@private
function config._default_config()
    return default_config
end

---@param user_config? decipher.Config
function config.setup(user_config)
    _user_config = vim.tbl_deep_extend("keep", user_config or {}, default_config)

    validate_config(_user_config)
end

setmetatable(config, {
    __index = function(_, key)
        return _user_config[key]
    end,
})

return config
