local M = {}

local bit = require("bit")

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

local function url_encode_byte(list, byte)
    table.insert(list, "%")
    table.insert(list, string.format("%x", bit.rshift(byte, 4)))
    table.insert(list, string.format("%x", bit.band(byte, 0xf)):upper())
end

function M.encode(value)
    if value == nil then
        return value
    end

    local result = {}

    for i = 1, #value do
        local char = value:sub(i, i)
        local byte1, byte2, byte3, byte4 = char:byte(1, -1)
        -- print(byte1, byte2, byte3, byte4)
        local utf8_len = 1

        if utf8_len <= 1 then
            if reserved[byte1 + 1] == 0 then
                table.insert(result, char)
            elseif char == " " then
                table.insert(result, "+")
            else
                url_encode_byte(result, byte1)
            end
        else
            table.foreach({ byte1, byte2, byte3, byte4 }, function(byte)
                url_encode_byte(result, byte)
            end)
        end
    end

    return table.concat(result)
end

function M.decode(value)
    if value == nil then
        return value
    end

    local result = {}
    local i = 1

    while i <= #value do
        local char = value:sub(i, i)
        local utf8_len = 1

        if utf8_len <= 1 then
            if char == "+" then
                table.insert(result, " ")
                i = i + 1
            elseif char ~= "%" then
                table.insert(result, char)
                i = i + 1
            else
                local v1 = tonumber(value:sub(i + 1, i + 1), 16)
                local v2 = tonumber(value:sub(i + 2, i + 2), 16)

                table.insert(result, string.char(bit.bor(bit.lshift(v1, 4), v2)))
                i = i + 3
            end
        else
            table.insert(result, char)
            i = i + 1
        end
    end

    return table.concat(result)
end

-- local function url_encode = function(str)
--     if type(str) ~= "number" then
--         str = str:gsub("\r?\n", "\r\n")
--         str = str:gsub("([^%w%-%.%_%~ ])", function(c)
--             return string.format("%%%02X", c:byte())
--         end)
--         str = str:gsub(" ", "+")
--         return str
--     else
--         return str
--     end
-- end

return M
