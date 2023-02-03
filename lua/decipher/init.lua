local decipher = {}

local decipher_version = "1.0.0"

local config = require("decipher.config")
local codecs = require("decipher.codecs")
local commands = require("decipher.commands")
local error = require("decipher.error")
local float = require("decipher.float")
local text = require("decipher.text")
local str_utils = require("decipher.util.string")
local visual = require("decipher.visual")
local motion = require("decipher.motion")

decipher.codec = codecs.codec

---@class decipher.Options
---@field public preview boolean if a preview should be shown or not

---@alias decipher.CodecArg string | decipher.Codec

---@return string
function decipher.version()
    return decipher_version
end

---@return string[] a list of the names of supported codecs
function decipher.codecs()
    return codecs.supported()
end

---@param codec_name decipher.CodecArg
---@param value string
---@param func_key "encode" | "decode"
---@return string | nil
local function handle_codec(codec_name, value, func_key)
    local codec = codecs.get(codec_name)

    if codec == nil then
        return nil
    end

    return codec[func_key](value)
end

---@param codec_name decipher.CodecArg
---@param value string value to encode
---@return string | nil the encoded value or nil if encoding failed
function decipher.encode(codec_name, value)
    return handle_codec(codec_name, value, "encode")
end

---@param codec_name decipher.CodecArg
---@param value string value to decode
---@return string | nil the decoded value or nil if decoding failed
function decipher.decode(codec_name, value)
    return handle_codec(codec_name, value, "decode")
end

---@param codec_name decipher.CodecArg
---@param status boolean
---@param value string?
---@param selection function
---@diagnostic disable-next-line: unused-local
local function open_float_handler(codec_name, status, value, selection)
    if status and value == nil then
        value = "Codec not found"
    end

    float.open(codec_name, { value }, config.float)
end

--- Handler for setting a text region to a value
---@param codec_name decipher.CodecArg
---@param status boolean
---@param value string?
---@param selection decipher.Region
---@diagnostic disable-next-line: unused-local
local function set_text_region_handler(codec_name, status, value, selection)
    if not status then
        error.error_message(string.format("%s: %s", codec_name, value), true)
        return
    end

    if value == nil then
        error.error_message_codec(codec_name)
        return
    end

    -- Escape the string since you cannot set lines in a buffer if it contains newlines
    text.set_region(selection, str_utils.escape_newlines(value))
end

--- Process a codec action
---@param codec_name decipher.CodecArg
---@param codec_func fun(string): string
---@param selection_func fun(): decipher.Region
---@param options decipher.Options
local function process_codec(codec_name, codec_func, selection_func, options)
    local selection = selection_func()
    local text_value = text.get_region(selection)
    local status, value = pcall(codec_func, codec_name, text_value)
    local do_preview = (options and options.preview == true) or false
    local handler_func = do_preview and open_float_handler or set_text_region_handler

    handler_func(codec_name, status, value, selection)
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

---@param codec_name decipher.CodecArg
---@param options decipher.Options
function decipher.encode_selection(codec_name, options)
    process_codec(codec_name, decipher.encode, visual.get_selection, options)
end

---@param codec_name decipher.CodecArg
---@param options decipher.Options
function decipher.decode_selection(codec_name, options)
    process_codec(codec_name, decipher.decode, visual.get_selection, options)
end

---@param codec_name decipher.CodecArg
---@param options decipher.Options
function decipher.encode_motion(codec_name, options)
    -- TODO: Pass process_codec directly motion.process_motion
    motion.start_motion(function()
        process_codec(codec_name, decipher.encode, motion.get_motion, options)
    end)
end

---@param codec_name decipher.CodecArg
---@param options decipher.Options
function decipher.decode_motion(codec_name, options)
    motion.start_motion(function()
        process_codec(codec_name, decipher.decode, motion.get_motion, options)
    end)
end

---@param options decipher.Options
function decipher.encode_selection_prompt(options)
    process_codec_prompt(decipher.encode, visual.get_selection, options)
end

---@param options decipher.Options
function decipher.decode_selection_prompt(options)
    process_codec_prompt(decipher.decode, visual.get_selection, options)
end

---@param options decipher.Options
function decipher.encode_motion_prompt(options)
    motion.start_motion(function()
        process_codec_prompt(decipher.encode, motion.get_motion, options)
    end)
end

---@param options decipher.Options
function decipher.decode_motion_prompt(options)
    motion.start_motion(function()
        process_codec_prompt(decipher.decode, motion.get_motion, options)
    end)
end

---@param user_config? decipher.Config
function decipher.setup(user_config)
    config.setup(user_config)

    if not vim.fn.has("nvim-0.5.0") then
        error.error_message("This plugin only works with Neovim >= v0.5.0", false)
        return
    end

    commands.setup(decipher)
    float.setup()
end

return decipher
