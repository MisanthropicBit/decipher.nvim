local url = {}

-- An implementation of RFC 1866, mainly for the application/x-www-form-urlencoded mimetype

local bits = require("decipher.bits")

---@class decipher.UrlCodecOptions
---@field decode_plus_as_space boolean

-- stylua: ignore
local reserved = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
}

---Url-encode a single byte and insert it into list
---@param list string[]
---@param byte integer
local function url_encode_byte(list, byte)
    table.insert(list, "%")
    table.insert(list, ("%x"):format(bits.rshift(byte, 4)))
    table.insert(list, ("%x"):format(bits.band(byte, 0xf)))
end

---@param value string
---@param options decipher.UrlCodecOptions?
---@return string
function url.encode_with(value, options)
    if value == nil then
        error("Cannot encode nil value", 0)
    end

    local result = {}

    for i = 1, #value do
        local char = value:sub(i, i)
        local byte = char:byte(1, 1)

        if reserved[byte + 1] == 0 then
            table.insert(result, char)
        elseif char == " " then
            table.insert(result, "+")
        else
            url_encode_byte(result, byte)
        end
    end

    return table.concat(result)
end

--- Url-encode a string
---@param value string
---@return string
function url.encode(value)
    return url.encode_with(value)
end

---@param value string
---@param options decipher.UrlCodecOptions?
---@return string
function url.decode_with(value, options)
    if value == nil then
        error("Cannot decode nil value", 0)
    end

    local plus_as_space = options and options.decode_plus_as_space or false
    local result = {}
    local i = 1

    while i <= #value do
        local char = value:sub(i, i)

        if plus_as_space and char == "+" then
            table.insert(result, " ")
            i = i + 1
        elseif char ~= "%" then
            table.insert(result, char)
            i = i + 1
        else
            local v1 = tonumber(value:sub(i + 1, i + 1), 16)
            local v2 = tonumber(value:sub(i + 2, i + 2), 16)

            table.insert(result, string.char(bits.bor(bits.lshift(v1, 4), v2)))
            i = i + 3
        end
    end

    return table.concat(result)
end
--- Url-decode a string
---@param value string
---@return string
function url.decode(value)
    return url.decode_with(value, { decode_plus_as_space = true })
end

return url
