local base64_url_safe = {}

local base64 = require("decipher.codecs.base64")
local util = require("decipher.codecs.util")

--- Base64 encoding table from RFC 4648 §5 for url- and filename-safe encoding
---@type decipher.EncodingTable
local rfc4648_base64_url_safe_encoding_table = {
    [0] = "A",
    [1] = "B",
    [2] = "C",
    [3] = "D",
    [4] = "E",
    [5] = "F",
    [6] = "G",
    [7] = "H",
    [8] = "I",
    [9] = "J",
    [10] = "K",
    [11] = "L",
    [12] = "M",
    [13] = "N",
    [14] = "O",
    [15] = "P",
    [16] = "Q",
    [17] = "R",
    [18] = "S",
    [19] = "T",
    [20] = "U",
    [21] = "V",
    [22] = "W",
    [23] = "X",
    [24] = "Y",
    [25] = "Z",
    [26] = "a",
    [27] = "b",
    [28] = "c",
    [29] = "d",
    [30] = "e",
    [31] = "f",
    [32] = "g",
    [33] = "h",
    [34] = "i",
    [35] = "j",
    [36] = "k",
    [37] = "l",
    [38] = "m",
    [39] = "n",
    [40] = "o",
    [41] = "p",
    [42] = "q",
    [43] = "r",
    [44] = "s",
    [45] = "t",
    [46] = "u",
    [47] = "v",
    [48] = "w",
    [49] = "x",
    [50] = "y",
    [51] = "z",
    [52] = "0",
    [53] = "1",
    [54] = "2",
    [55] = "3",
    [56] = "4",
    [57] = "5",
    [58] = "6",
    [59] = "7",
    [60] = "8",
    [61] = "9",
    [62] = "-",
    [63] = "_",
}

local base64_url_safe_codec = util.make_codec("base64-url-safe", rfc4648_base64_url_safe_encoding_table, "=", base64)

--- Encode a string as url-safe base64
---@param value string
---@return string
function base64_url_safe.encode(value)
    return base64_url_safe_codec.encode(value)
end

--- Decode a string encoded as url-safe base64
---@param value string
---@return string
function base64_url_safe.decode(value)
    return base64_url_safe_codec.decode(value)
end

return base64_url_safe
