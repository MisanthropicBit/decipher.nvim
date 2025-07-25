local zbase32 = {}

local base32 = require("decipher.codecs.base32")
local util = require("decipher.codecs.util")

local zbase32_encoding_table = {
    [0] = "y",
    [1] = "b",
    [2] = "n",
    [3] = "d",
    [4] = "r",
    [5] = "f",
    [6] = "g",
    [7] = "8",
    [8] = "e",
    [9] = "j",
    [10] = "k",
    [11] = "m",
    [12] = "c",
    [13] = "p",
    [14] = "q",
    [15] = "x",
    [16] = "o",
    [17] = "t",
    [18] = "1",
    [19] = "u",
    [20] = "w",
    [21] = "i",
    [22] = "s",
    [23] = "z",
    [24] = "a",
    [25] = "3",
    [26] = "4",
    [27] = "5",
    [28] = "h",
    [29] = "7",
    [30] = "6",
    [31] = "9",
}

local zbase32_codec = util.make_codec("zbase32", zbase32_encoding_table, "=", base32)

--- Encode a zbase32-encoded string
---@param value string
---@return string
function zbase32.encode(value)
    return zbase32_codec.encode(value)
end

--- Decode a string as zbase32
---@param value string
---@return string
function zbase32.decode(value)
    return zbase32_codec.decode(value)
end

return zbase32
