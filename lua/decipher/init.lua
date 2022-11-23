local decipher = {}

local decipher_version = "1.0.0"

local config = require("decipher.config")
local codecs = require("decipher.codecs")
local float = require("decipher.float")
local text = require("decipher.text")
local util = require("decipher.util")
local visual = require("decipher.visual")

---@enum decipher.Codec
decipher.Codec = {}
decipher.Codec.BASE64 = 1
decipher.Codec.BASE85 = 2
decipher.Codec.URL_BASE64 = 3
decipher.Codec.URL_BASE85 = 3
decipher.Codec.ROT13 = 4
decipher.Codec.ALL = 5

---@return string
function decipher.version()
    return decipher_version
end

---@return string[] A list of the names of supported codecs
function decipher.codecs()
    return codecs.supported()
end

---@param chunks string[][]
---@param history boolean
local function error_message(chunks, history)
    vim.api.nvim_echo(chunks, history, {})
end

---@param codec_name string
local function error_message_codec(codec_name)
    error_message({
        -- TODO: Move header into local function
        { "[decipher]:", "WarningMsg" },
        { " " .. "Codec not found:" },
        { " " .. string.format("%s", codec_name), "WarningMsg" },
    }, true)
end

---@param codec_name string
---@param value string
---@param func_key string
---@return string
local function handle_codec(codec_name, value, func_key)
    local codec = codecs.get(codec_name)

    if codec == nil then
        error_message_codec(codec_name)
        return nil
    end

    return codec[func_key](value)
end

---@param codec_name string
---@param value string
---@return string
function decipher.encode(codec_name, value)
    return handle_codec(codec_name, value, "encode")
end

---@param codec_name string
---@param value string
---@return string
function decipher.decode(codec_name, value)
    return handle_codec(codec_name, value, "decode")
end

local function handle_selection(codec_name, codec_func, selection_func)
    local selection = selection_func()
    local text_value = text.get_region(selection)
    local value = codec_func(codec_name, text_value)

    if value == nil then
        return
    end

    -- Escape the string since you cannot set lines in a buffer if it contains newlines
    text.set_region(selection, util.escape_newlines(value))
end

function decipher.encode_selection(codec_name)
    handle_selection(codec_name, decipher.encode, visual.get_selection)
end

function decipher.decode_selection(codec_name)
    handle_selection(codec_name, decipher.decode, visual.get_selection)
end

function decipher.encode_motion(codec_name)
    handle_selection(codec_name, decipher.encode, visual.get_motion)
end

function decipher.decode_motion(codec_name)
    handle_selection(codec_name, decipher.decode, visual.get_motion)
end

local function codec_prompt(codec_func)
    local codec_name

    vim.ui.select(decipher.codecs(), { prompt = "Codec?: " }, function(item)
        codec_name = item
    end)

    if codec_name == nil then
        return
    end

    handle_selection(codec_name, codec_func, visual.get_selection)
end

function decipher.encode_selection_prompt()
    codec_prompt(decipher.encode)
end

function decipher.decode_selection_prompt()
    codec_prompt(decipher.decode)
end

function decipher.decode_preview_selection(codec_name)
    local selection = visual.get_selection()
    local text_value = text.get_region(selection)
    local value = decipher.decode(codec_name, text_value)

    if value == nil then
        error_message(string.format("Failed to decode selection as '%s'", codec_name))
        return
    end

    float.open("base64", { value }, config.float)
end

---@param user_config decipher.Config
function decipher.setup(user_config)
    config.setup(user_config)
end

return decipher
