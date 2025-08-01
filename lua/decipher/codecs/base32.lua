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

            result = ("%s%s"):format(result, encoding_table[index])
            bit_count = bit_count - 5
        end
    end

    -- Output any remaining bits in the bit buffer
    if bit_count > 0 then
        local index = bits.band(bits.lshift(bit_buffer, 5 - bit_count), 0x1f)

        result = ("%s%s"):format(result, encoding_table[index])
    end

    -- Pad until the result is a multiple of 8
    while #result % 8 ~= 0 do
        result = ("%s%s"):format(result, "=") -- encoding_table.padding)
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
        error(("%s-encoded string is not a multiple of 8"):format(base32_codec.name), 0)
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
            result = ("%s%s"):format(result, string.char(char8))
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

return base32
