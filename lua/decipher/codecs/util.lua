local codecs_util = {}

---@param value string
---@param idx number
---@param spec decipher.CodecSpec
---@return number
function codecs_util.decoding_table_lookup(value, idx, spec)
    local char = value:sub(idx, idx)

    if char == spec.pad_char then
        return 0
    elseif char == "" then
        -- This occurs when an encoded string is too short and indexing the
        -- value goes out of bounds and returns an empty string
        error(("Attempt to decode out of bounds at position %d, encoded string is too short"):format(idx))
    end

    local decoded = spec.decoding_table[char]

    if decoded == nil then
        error(("Invalid character '%s' at byte position %d in %s string"):format(char, idx, spec.name), 0)
    end

    return decoded
end

--- Create a codec spec from an encoding table and a padding character
---@param name string
---@param encoding_table decipher.EncodingTable
---@param pad_char string
---@return decipher.CodecSpec
local function make_codec_spec(name, encoding_table, pad_char)
    local codec_spec = {
        name = name,
        encoding_table = encoding_table,
        decoding_table = {},
        pad_char = pad_char,
    }

    for key, value in pairs(encoding_table) do
        codec_spec.decoding_table[value] = key
    end

    return codec_spec
end

--- Create a new codec from an encoding table and padding character for a module
---@param name string
---@param encoding_table decipher.EncodingTable
---@param pad_char string
---@param module any
---@return decipher.Codec
function codecs_util.make_codec(name, encoding_table, pad_char, module)
    local spec = make_codec_spec(name, encoding_table, pad_char)

    return {
        name = name,
        encode = function(value)
            return module.encode_with(value, spec)
        end,
        decode = function(value)
            return module.decode_with(value, spec)
        end,
    }
end

return codecs_util
