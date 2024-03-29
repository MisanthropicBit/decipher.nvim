local codecs = {}

local base32 = require("decipher.codecs.base32")
local base64 = require("decipher.codecs.base64")
local base64_url = require("decipher.codecs.base64_url")
local url = require("decipher.codecs.url")

---@enum decipher.Codecs
codecs.codec = {
    base32 = "base32",
    zbase32 = "zbase32",
    crockford = "crockford",
    base64 = "base64",
    base64_url = "base64-url",
    base64_url_safe = "base64-url-safe",
    url = "url",
}

---@alias decipher.EncodingTable table<number, string>
---@alias decipher.DecodingTable table<string, number>

--- Simple spec for defining codecs based on tables like base64
---@class decipher.CodecSpec
---@field name string
---@field encoding_table decipher.EncodingTable
---@field decoding_table decipher.DecodingTable
---@field pad_char string

---@class decipher.Codec
---@field name string
---@field encode fun(string): string
---@field decode fun(string): string

---@type table<string, decipher.Codec>
local codecs_map = {
    ["base32"] = base32,
    ["zbase32"] = base32.zbase32(),
    ["crockford"] = base32.crockford(),
    ["base64-url-safe"] = base64.url_safe(),
    ["base64"] = base64,
    ["base64-url"] = base64_url,
    ["url"] = url,
}

---@param name decipher.CodecArg
---@return decipher.Codec
function codecs.get(name)
    return codecs_map[name]
end

--- Get a list of supported codecs
---@return decipher.Codecs[]
function codecs.supported()
    local _codecs = vim.tbl_keys(codecs_map)
    table.sort(_codecs)

    return _codecs
end

return codecs
