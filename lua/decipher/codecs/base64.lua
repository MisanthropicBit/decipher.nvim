local M = {}

local bit = require("bit")

-- Create a codec from an encoding table and a padding character
function M.make_base64_codec(encoding_table, pad_char)
    local codec = {
        encoding_table = encoding_table,
        decoding_table = {},
        pad_char = pad_char,
    }

    for key, value in pairs(encoding_table) do
        codec.decoding_table[value] = key
    end

    return codec
end

-- Encoding table from RFC 4648
local rfc4648_encoding_table = {
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

local default_base64_codec = M.make_base64_codec(rfc4648_encoding_table, "=")

local function combined_octets(value, i)
    local value1, value2, value3 = value:byte(i, i + 3)

    return bit.bor(bit.lshift(value1, 16), bit.lshift(value2 or 0, 8), value3 or 0)
end

local function get_bits(value, rshift)
    return bit.band(bit.rshift(value, rshift), 0x3f)
end

function M.encode_with(value, base64_codec)
    if value == nil then
        return value
    end

    local encoding_table = base64_codec.encoding_table
    local result, size, last = "", #value, #value % 3

    for i = 1, size - last, 3 do
        local octets = combined_octets(value, i)

        result = string.format(
            "%s%s%s%s%s",
            result,
            encoding_table[get_bits(octets, 18)],
            encoding_table[get_bits(octets, 12)],
            encoding_table[get_bits(octets, 6)],
            encoding_table[bit.band(octets, 0x3f)]
        )
    end

    if last > 0 then
        local pad_char = base64_codec.pad_char
        local octets = combined_octets(value, size - last + 1)

        result = string.format(
            "%s%s%s%s%s",
            result,
            encoding_table[get_bits(octets, 18)],
            encoding_table[get_bits(octets, 12)],
            last == 1 and pad_char or encoding_table[get_bits(octets, 6)],
            pad_char
        )
    end

    return result
end

function M.encode(value)
    return M.encode_with(value, default_base64_codec)
end

function M.decode_with(value, base64_codec)
    if value == nil then
        return value
    end

    local decoding_table = base64_codec.decoding_table
    local pad_char = base64_codec.pad_char
    local result = ""

    for i = 1, #value, 4 do
        local value3, value4 = value:sub(i + 2, i + 2), value:sub(i + 3, i + 3)
        local last = value3 == pad_char and 3 or value4 == pad_char and 2 or 1

        local joined = bit.bor(
            bit.lshift(decoding_table[value:sub(i, i)] or 0, 18),
            bit.lshift(decoding_table[value:sub(i + 1, i + 1)] or 0, 12),
            bit.lshift(decoding_table[value3] or 0, 6),
            decoding_table[value4] or 0
        )

        for j = 3, last, -1 do
            result = string.format("%s%s", result, string.char(bit.band(bit.rshift(joined, (j - 1) * 8), 0xff)))
        end
    end

    return result
end

function M.decode(value)
    return M.decode_with(value, default_base64_codec)
end

return M
