local url = {}

local bits = require("decipher.bits")

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

---Url-encode a string
---@param value string
---@return string
function url.encode(value)
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

---Url-decode a string
---@param value string
---@return string
function url.decode(value)
    if value == nil then
        error("Cannot decode nil value", 0)
    end

    local result = {}
    local i = 1

    while i <= #value do
        local char = value:sub(i, i)

        if char == "+" then
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

return url
