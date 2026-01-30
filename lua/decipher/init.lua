local decipher = {}

local decipher_version = "2.1.0"

local codecs = require("decipher.codecs")
local config = require("decipher.config")
local notifications = require("decipher.notifications")
local motion = require("decipher.motion")
local selection = require("decipher.selection")
local str_utils = require("decipher.util.string")
local ui = require("decipher.ui")

decipher.codec = codecs.codec

---@class decipher.Options
---@field public preview boolean if a preview should be shown or not

---@class decipher.ProcessCodecOptions
---@field selection_type decipher.SelectionType
---@field codec_type "encode" | "decode"

---@alias decipher.CodecArg string | decipher.Codecs

---@return string
function decipher.version()
    return decipher_version
end

---@return decipher.Codecs[] a list of the names of supported codecs
function decipher.supported_codecs()
    return codecs.supported()
end

---@param codec_name decipher.CodecArg
---@param value string
---@param func_key "encode" | "decode"
---@return string | nil
local function handle_codec(codec_name, value, func_key)
    local codec = codecs.get(codec_name)

    if codec == nil then
        error(("Codec '%s' not found"):format(codec_name), 0)
    end

    local func = codec[func_key]

    if not func then
        error(("Codec '%s' does not support '%s'"):format(codec_name, func_key), 2)
    end

    return func(value)
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

---@param codec_name string
---@param status boolean
---@param value string
---@param selection_type decipher.SelectionType
---@param codec_type "encode" | "decode"
local function open_float_handler(codec_name, status, value, selection_type, codec_type)
    if status and value == nil then
        value = "Codec not found"
    end

    if not status then
        notifications.error(("%s: %s"):format(codec_name, value))
        return
    end

    -- We need the selection in order to apply the codec operation from the
    -- preview window later on
    local _selection = selection.get_selection(selection_type)

    ui.float.open({
        title = codec_name,
        contents = vim.fn.split(value, [[\r\?\n]]),
        config = config.float,
        selection_type = selection_type,
        codec_name = codec_name,
        codec_type = codec_type,
        selection = _selection,
    })
end

--- Handler for setting a text region to a value
---@param codec_name string
---@param status boolean
---@param value string
---@param selection_type decipher.SelectionType
---@diagnostic disable-next-line:unused-local
local function set_text_region_handler(codec_name, status, value, selection_type)
    if not status then
        notifications.error(("%s: %s"):format(codec_name, value))
        return
    end

    if value == nil then
        notifications.codec_not_found("Codec not found: " .. codec_name)
        return
    end

    -- Escape the string since you cannot set lines in a buffer if it contains newlines
    selection.set_text(0, selection_type, str_utils.escape_newlines({ value }))
end

--- Process a codec action
---@param codec_name decipher.CodecArg
---@param codec_func fun(string): string
---@param selection_type decipher.SelectionType
---@param codec_type "encode" | "decode"
---@param options decipher.Options
local function process_codec(codec_name, codec_func, selection_type, codec_type, options)
    local lines = selection.get_text(0, selection_type)
    local joined = table.concat(lines, "\n")
    local status, value = pcall(codec_func, codec_name, joined)
    local do_preview = (options and options.preview == true) or false

    -- Handle enums, nil etc. passed at runtime
    local _codec_name = ("%s"):format(codec_name)

    if do_preview then
        open_float_handler(_codec_name, status, value, selection_type, codec_type)
    else
        set_text_region_handler(_codec_name, status, value, selection_type)
    end
end

---@param codec_func fun(string): string
---@param selection_type decipher.SelectionType
---@param codec_type "encode" | "decode"
---@param options decipher.Options
local function process_codec_prompt(codec_func, selection_type, codec_type, options)
    vim.ui.select(codecs.supported(), { prompt = "Codec?: " }, function(codec_name)
        if codec_name == nil then
            return
        end

        process_codec(codec_name, codec_func, selection_type, codec_type, options)
    end)
end

---@param codec_name decipher.CodecArg
---@param options decipher.Options
function decipher.encode_selection(codec_name, options)
    process_codec(codec_name, decipher.encode, "visual", "encode", options)
end

---@param codec_name decipher.CodecArg
---@param options decipher.Options
function decipher.decode_selection(codec_name, options)
    process_codec(codec_name, decipher.decode, "visual", "decode", options)
end

---@param codec_name decipher.CodecArg
---@param options decipher.Options
function decipher.encode_motion(codec_name, options)
    motion.start_motion(function()
        process_codec(codec_name, decipher.encode, "motion", "encode", options)
    end)
end

---@param codec_name decipher.CodecArg
---@param options decipher.Options
function decipher.decode_motion(codec_name, options)
    motion.start_motion(function()
        process_codec(codec_name, decipher.decode, "motion", "decode", options)
    end)
end

---@param options decipher.Options
function decipher.encode_selection_prompt(options)
    process_codec_prompt(decipher.encode, "visual", "encode", options)
end

---@param options decipher.Options
function decipher.decode_selection_prompt(options)
    process_codec_prompt(decipher.decode, "visual", "decode", options)
end

---@param options decipher.Options
function decipher.encode_motion_prompt(options)
    motion.start_motion(function()
        process_codec_prompt(decipher.encode, "motion", "encode", options)
    end)
end

---@param options decipher.Options
function decipher.decode_motion_prompt(options)
    motion.start_motion(function()
        process_codec_prompt(decipher.decode, "motion", "decode", options)
    end)
end

function decipher.has_bit_library()
    local has_bit, _ = pcall(require, "bit")

    return has_bit
end

---@param user_config? decipher.Config
function decipher.setup(user_config)
    if not vim.fn.has("nvim-0.8.0") then
        notifications.error("This plugin only works with Neovim >= v0.8.0")
        return
    end

    if not decipher.has_bit_library() then
        notifications.error(
            "A bit library is required. Ensure that either neovim has been built with luajit or use neovim v0.9.0+ which includes a bit library"
        )

        return
    end

    config.setup(user_config)
    ui.float.setup()
end

return decipher
