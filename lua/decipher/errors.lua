local errors = {}

---@param message string | string[][]
---@param level "error" | "warn"
---@param history boolean
local function _message(message, level, history)
    local chunks = {}

    if type(message) == "string" then
        table.insert(chunks, { " " .. message })
    elseif type(message) == "table" then
        table.insert(chunks, { " " })

        for _, v in pairs(message) do
            table.insert(chunks, v)
        end
    else
        error(("Unsupported error message type '%s'"):format(type(message)))
    end

    local level_color = level == "error" and "ErrorMsg" or "WarningMsg"
    table.insert(chunks, 1, { "[decipher]:", level_color })

    vim.api.nvim_echo(chunks, history or false, {})
end

---@param chunks string | string[][]
---@param history boolean
function errors.error_message(chunks, history)
    _message(chunks, "error", history)
end

function errors.warn_message(chunks, history)
    _message(chunks, "warn", history)
end

---@param codec_name string
function errors.error_message_codec(codec_name)
    errors.error_message({
        { "Codec not found:" },
        { " " .. ("%s"):format(codec_name), "WarningMsg" },
    }, true)
end

return errors
