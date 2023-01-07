local decipher = {}

local decipher_version = "1.0.0"

local config = require("decipher.config")
local codecs = require("decipher.codecs")
local commands = require("decipher.commands")
local error = require("decipher.error")
local float = require("decipher.float")
local mappings = require("decipher.mappings")
local text = require("decipher.text")
local util = require("decipher.util")
local visual = require("decipher.visual")

decipher.codec = codecs.codec

---@class Options
---@field public preview boolean if a preview should be shown or not

---@return string
function decipher.version()
    return decipher_version
end

---@return string[] A list of the names of supported codecs
function decipher.codecs()
    return codecs.supported()
end

---@param codec_name string
---@param value string
---@param func_key "encode" | "decode"
---@return string | nil
local function handle_codec(codec_name, value, func_key)
    local codec = codecs.get(codec_name)

    if codec == nil then
        error.error_message_codec(codec_name)
        return nil
    end

    return codec[func_key](value)
end

---@param codec_name string | codec
---@param value string value to encode
---@return string | nil the encoded value or nil if encoding failed
function decipher.encode(codec_name, value)
    return handle_codec(codec_name, value, "encode")
end

---@param codec_name string
---@param value string value to decode
---@return string | nil the decoded value or nil if decoding failed
function decipher.decode(codec_name, value)
    return handle_codec(codec_name, value, "decode")
end

---@param codec_name string
---@param value string
---@param selection function
---@diagnostic disable-next-line: unused-local
local function open_float_handler(codec_name, value, selection)
    float.open(codec_name, { value }, config.float)
end

--- Handler for setting a text region to a value
---@param codec_name string
---@param value string
---@param selection function
---@diagnostic disable-next-line: unused-local
local function set_text_region_handler(codec_name, value, selection)
    -- Escape the string since you cannot set lines in a buffer if it contains newlines
    text.set_region(selection, util.escape_newlines(value))
end

--- Process a codec action
---@param codec_name string
---@param codec_func function
---@param selection_func function
---@param options Options
local function process_codec(codec_name, codec_func, selection_func, options)
    local selection = selection_func()
    local text_value = text.get_region(selection)
    local value = codec_func(codec_name, text_value)

    if value == nil then
        error.error_message(string.format("Failed to decode selection as '%s'", codec_name), false)
        return
    end

    local do_preview = (options and options.preview == true) or false
    local handler_func = do_preview and open_float_handler or set_text_region_handler

    handler_func(codec_name, value, selection)
end

--- Prompt for a codec to use
local function prompt_codec_name()
    local codec_name

    vim.ui.select(decipher.codecs(), { prompt = "Codec?: " }, function(item)
        codec_name = item
    end)

    return codec_name
end

local function process_codec_prompt(codec_func, selection_func, handler_func)
    local codec_name = prompt_codec_name()

    if codec_name == nil then
        return
    end

    process_codec(codec_name, codec_func, selection_func, handler_func)
end

---@param codec_name string
---@param options Options
function decipher.encode_selection(codec_name, options)
    process_codec(codec_name, decipher.encode, visual.get_selection, options)
end

---@param codec_name string
---@param options Options
function decipher.decode_selection(codec_name, options)
    process_codec(codec_name, decipher.decode, visual.get_selection, options)
end

---@param codec_name string
---@param options Options
function decipher.encode_motion(codec_name, options)
    process_codec(codec_name, decipher.encode, visual.get_motion, options)
end

---@param codec_name string
---@param options Options
function decipher.decode_motion(codec_name, options)
    process_codec(codec_name, decipher.decode, visual.get_motion, options)
end

---@param options Options
function decipher.encode_selection_prompt(options)
    process_codec_prompt(decipher.encode, visual.get_selection, options)
end

---@param options Options
function decipher.decode_selection_prompt(options)
    process_codec_prompt(decipher.decode, visual.get_selection, options)
end

---@param options Options
function decipher.encode_motion_prompt(options)
    process_codec_prompt(decipher.encode, visual.get_motion, options)
end

---@param options Options
function decipher.decode_motion_prompt(options)
    process_codec_prompt(decipher.decode, visual.get_motion, options)
end

---@param user_config decipher.Config | nil
function decipher.setup(user_config)
    if user_config ~= nil then
        config.setup(user_config)
    end

    if not vim.fn.has("nvim-0.5.0") then
        error.error_message("This plugin only works with Neovim >= v0.5.0", false)
        return
    end

    commands.setup(decipher)
    mappings.setup(decipher)
end

return decipher
