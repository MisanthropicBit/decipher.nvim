local codecs = {}

local base32 = require("decipher.codecs.base32")
local base64 = require("decipher.codecs.base64")
local base64_url = require("decipher.codecs.base64_url")
local url = require("decipher.codecs.url")

---@enum decipher.Codec
codecs.codec = {
    base32 = "base32",
    zbase32 = "zbase32",
    crockford = "crockford",
    base64 = "base64",
    base64_url = "base64-url",
    base64_url_safe = "base64-url-safe",
    url = "url",
    -- base85 = "base85",
    -- base64_url = "base64-url",
    -- base85_url = "base85-url",
    -- rot13 = "rot13",
    -- all = "all",
}

---@alias decipher.EncodingTable table<number, string>
---@alias decipher.DecodingTable table<string, number>

--- Simple spec for defining codecs based on tables like base64
---@class decipher.CodecSpec
---@field name string
---@field encoding_table decipher.EncodingTable
---@field decoding_table decipher.DecodingTable
---@field pad_char string


local codecs_map = {
    ["base32"] = base32,
    ["zbase32"] = base32.zbase32(),
    ["crockford"] = base32.crockford(),
    ["base64-url-safe"] = base64.url_safe(),
    ["base64"] = base64,
    ["base64-url"] = base64_url,
    ["url"] = url,
}

function codecs.get(name)
    return codecs_map[name]
end

--- Get a list of supported codecs
---@return decipher.Codec[]
function codecs.supported()
    local _codecs = vim.tbl_keys(codecs_map)
    table.sort(_codecs)

    return _codecs
end

return codecs
