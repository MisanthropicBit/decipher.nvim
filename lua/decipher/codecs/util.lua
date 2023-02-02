local util = {}

--- Create a codec spec from an encoding table and a padding character
---@param encoding_table decipher.EncodingTable
---@param pad_char string
---@return decipher.CodecSpec
local function make_codec_spec(encoding_table, pad_char)
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

--- Create a new codec from an encoding table and padding character for a module
---@param encoding_table decipher.EncodingTable
---@param pad_char string
---@param module any
function util.make_codec(encoding_table, pad_char, module)
    local spec = make_codec_spec(encoding_table, pad_char)

    return {
        encode = function(value)
            return module.encode_with(value, spec)
        end,
        decode = function(value)
            return module.decode_with(value, spec)
        end,
    }
end

return util
