local config = {}

---@class decipher.WindowMappings
---@field close?  string
---@field apply?  string
---@field update? string
---@field json?   string
---@field help?   string

---@class decipher.WindowConfig
---@field border?      string | string[] | string[][]
---@field mappings?    decipher.WindowMappings
---@field title?       boolean
---@field title_pos?   'left' | 'center' | 'right'
---@field autoclose?   boolean
---@field autojson?    boolean
---@field enter?       boolean
---@field win_options? table<string, any>
---@field zindex       integer?

---@class decipher.Config
---@field float? decipher.WindowConfig

---@type decipher.Config
local default_config = {
    float = {
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
            json = "<leader>j",
            help = "g?",
        },
        title = true,
        title_pos = "left",
        autoclose = true,
        autojson = false,
        enter = false,
        win_options = {},
        zindex = 50,
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
        ["float.border"] = { _config.float.border, validate_border, "valid border" },
        ["float.mappings"] = { _config.float.mappings, "table" },
        ["float.mappings.close"] = { _config.float.mappings.close, "string" },
        ["float.mappings.apply"] = { _config.float.mappings.apply, "string" },
        ["float.mappings.update"] = { _config.float.mappings.update, "string" },
        ["float.mappings.json"] = { _config.float.mappings.json, "string" },
        ["float.mappings.help"] = { _config.float.mappings.help, "string" },
        ["float.title"] = { _config.float.title, "boolean" },
        ["float.title_pos"] = { _config.float.title_pos, "string" },
        ["float.autoclose"] = { _config.float.autoclose, "boolean" },
        ["float.autojson"] = { _config.float.autojson, "boolean" },
        ["float.enter"] = { _config.float.enter, "boolean" },
        ["float.win_options"] = { _config.float.win_options, "table" },
        ["float.zindex"] = { _config.float.zindex, "number" },
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
