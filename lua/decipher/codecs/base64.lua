local base64 = {}

local bits = require("decipher.bits")
local util = require("decipher.codecs.util")

--- Base64 encoding table from RFC 4648
---@type decipher.EncodingTable
local rfc4648_default_encoding_table = {
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
    [62] = "+",
    [63] = "/",
}

local default_base64_codec = util.make_codec("base64", rfc4648_default_encoding_table, "=", base64)

--- Combine three octets/bytes from value at index i into an integer
---@param value string
---@param i number
---@return number
local function combined_octets(value, i)
    local value1, value2, value3 = value:byte(i, i + 3)

    return bits.bor(bits.lshift(value1, 16), bits.lshift(value2 or 0, 8), value3 or 0)
end

--- Encode a string as base64 with a given codec spec
---@param value string
---@param base64_codec decipher.CodecSpec
---@return string
function base64.encode_with(value, base64_codec)
    if value == nil then
        error("Cannot encode nil value", 0)
    end

    local encoding_table = base64_codec.encoding_table
    local result, size, last = "", #value, #value % 3

    for i = 1, size - last, 3 do
        local octets = combined_octets(value, i)

        result = ("%s%s%s%s%s"):format(
            result,
            encoding_table[bits.get_bits(octets, 18, 0x3f)],
            encoding_table[bits.get_bits(octets, 12, 0x3f)],
            encoding_table[bits.get_bits(octets, 6, 0x3f)],
            encoding_table[bits.band(octets, 0x3f)]
        )
    end

    if last > 0 then
        local pad_char = base64_codec.pad_char
        local octets = combined_octets(value, size - last + 1)

        result = ("%s%s%s%s%s"):format(
            result,
            encoding_table[bits.get_bits(octets, 18, 0x3f)],
            encoding_table[bits.get_bits(octets, 12, 0x3f)],
            last == 1 and pad_char or encoding_table[bits.get_bits(octets, 6, 0x3f)],
            pad_char
        )
    end

    return result
end

--- Encode a string as base64
---@param value string
---@return string
function base64.encode(value)
    return default_base64_codec.encode(value)
end

--- Decode a base64-encoded string with a given codec spec
---@param value string
---@param base64_codec decipher.CodecSpec
---@return string
function base64.decode_with(value, base64_codec)
    if value == nil then
        error("Cannot decode nil value", 0)
    end

    local pad_char = base64_codec.pad_char
    local result = ""

    for i = 1, #value, 4 do
        local value3, value4 = value:sub(i + 2, i + 2), value:sub(i + 3, i + 3)
        local last = value3 == pad_char and 3 or value4 == pad_char and 2 or 1

        local decoded1 = util.decoding_table_lookup(value, i, base64_codec)
        local decoded2 = util.decoding_table_lookup(value, i + 1, base64_codec)
        local decoded3 = util.decoding_table_lookup(value, i + 2, base64_codec)
        local decoded4 = util.decoding_table_lookup(value, i + 3, base64_codec)

        local joined =
            bits.bor(bits.lshift(decoded1, 18), bits.lshift(decoded2, 12), bits.lshift(decoded3, 6), decoded4)

        for j = 3, last, -1 do
            result = ("%s%s"):format(result, string.char(bits.band(bits.rshift(joined, (j - 1) * 8), 0xff)))
        end
    end

    return result
end

--- Decode a base64-encoded string
---@param value string
---@return string
function base64.decode(value)
    return default_base64_codec.decode(value)
end

return base64
