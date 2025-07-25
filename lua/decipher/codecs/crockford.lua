local crockford = {}

local base32 = require("decipher.codecs.base32")
local util = require("decipher.codecs.util")

local crockfold_encoding_table = {
    [0] = "0",
    [1] = "1",
    [2] = "2",
    [3] = "3",
    [4] = "4",
    [5] = "5",
    [6] = "6",
    [7] = "7",
    [8] = "8",
    [9] = "9",
    [10] = "A",
    [11] = "B",
    [12] = "C",
    [13] = "D",
    [14] = "E",
    [15] = "F",
    [16] = "G",
    [17] = "H",
    [18] = "J",
    [19] = "K",
    [20] = "M",
    [21] = "N",
    [22] = "P",
    [23] = "Q",
    [24] = "R",
    [25] = "S",
    [26] = "T",
    [27] = "V",
    [28] = "W",
    [29] = "X",
    [30] = "Y",
    [31] = "Z",
}

local crockford_codec = util.make_codec("crockford", crockfold_encoding_table, "=", base32)

--- Encode a crockford-encoded string
---@param value string
---@return string
function crockford.encode(value)
    return crockford_codec.encode(value)
end

--- Decode a string as crockford
---@param value string
---@return string
function crockford.decode(value)
    return crockford_codec.decode(value)
end

return crockford
