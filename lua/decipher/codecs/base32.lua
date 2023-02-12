local base32 = {}

local bits = require("decipher.bits")
local util = require("decipher.codecs.util")

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
    [26] = "2",
    [27] = "3",
    [28] = "4",
    [29] = "5",
    [30] = "6",
    [31] = "7",
}

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

local default_base32_codec = util.make_codec("base32", rfc4648_encoding_table, "=", base32)

--- Encode a string as base32 with a given codec spec
---@param value string
---@param base32_codec decipher.CodecSpec
---@return string
function base32.encode_with(value, base32_codec)
    if value == nil then
        error("Cannot encode nil value", 0)
    end

    local encoding_table = base32_codec.encoding_table
    local result, bit_buffer, bit_count = "", 0, 0

    -- This implementation pushes bytes from the input into a bit buffer where
    -- 5-bit values are extracted and used for the output
    for i = 1, #value do
        bit_buffer = bits.bor(bits.lshift(bit_buffer, 8), value:byte(i, i))
        bit_count = bit_count + 8

        while bit_count >= 5 do
            local index = bits.get_bits(bit_buffer, bit_count - 5, 0x1f)

            result = string.format("%s%s", result, encoding_table[index])
            bit_count = bit_count - 5
        end
    end

    -- Output any remaining bits in the bit buffer
    if bit_count > 0 then
        local index = bits.band(bits.lshift(bit_buffer, 5 - bit_count), 0x1f)

        result = string.format("%s%s", result, encoding_table[index])
    end

    -- Pad until the result is a multiple of 8
    while #result % 8 ~= 0 do
        result = string.format("%s%s", result, "=") -- encoding_table.padding)
    end

    return result
end

--- Encode a string as base32
---@param value string
---@return string
function base32.encode(value)
    return default_base32_codec.encode(value)
end

--- Decode a base32-encoded string with a given codec spec
---@param value string
---@param base32_codec decipher.CodecSpec
---@return string
function base32.decode_with(value, base32_codec)
    if value == nil then
        error("Cannot decode nil value", 0)
    end

    if #value % 8 ~= 0 then
        error("base32-encoded string is not a multiple of 8", 0)
    end

    local pad_char = base32_codec.pad_char
    local result, bit_buffer, bit_count = "", 0, 0

    for i = 1, #value do
        local char = string.char(value:byte(i))

        if char == pad_char then
            break
        end

        local index = util.decoding_table_lookup(value, i, base32_codec)
        bit_buffer = bits.left_pack(bit_buffer, 5, index)
        bit_count = bit_count + 5

        while bit_count >= 8 do
            local char8 = bits.get_bits(bit_buffer, bit_count - 8, 0xff)
            result = string.format("%s%s", result, string.char(char8))
            bit_count = bit_count - 8
        end
    end

    return result
end

--- Decode a base32-encoded string
---@param value string
---@return string
function base32.decode(value)
    return default_base32_codec.decode(value)
end

--- Get a codec for the zbase32 variant of base32
---@return decipher.Codec
function base32.zbase32()
    return util.make_codec("zbase32", zbase32_encoding_table, "=", base32)
end

--- Get a codec for the crockford variant of base32
---@return decipher.Codec
function base32.crockford()
    return util.make_codec("crockford", crockfold_encoding_table, "=", base32)
end

return base32
