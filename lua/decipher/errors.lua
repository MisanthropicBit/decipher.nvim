local errors = {}

---@param message string | string[][]
---@param history boolean
local function _error_message(message, history)
    local chunks = {}

    if type(message) == "string" then
        table.insert(chunks, { " " .. message })
    elseif type(message) == "table" then
        for _, v in pairs(message) do
            table.insert(chunks, v)
        end
    else
        error(("Unsupported error message type '%s'"):format(type(message)))
    end

    table.insert(chunks, 1, { "[decipher]:", "WarningMsg" })

    vim.api.nvim_echo(chunks, history or false, {})
end

---@param chunks string | string[][]
---@param history boolean
function errors.error_message(chunks, history)
    _error_message(chunks, history)
end

---@param codec_name string
function errors.error_message_codec(codec_name)
    errors.error_message({
        { " " .. "Codec not found:" },
        { " " .. ("%s"):format(codec_name), "WarningMsg" },
    }, true)
end

return errors
