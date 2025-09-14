local codecs = {}

local base32 = require("decipher.codecs.base32")
local base64 = require("decipher.codecs.base64")
local base64_url = require("decipher.codecs.base64_url")
local base64_url_encoded = require("decipher.codecs.base64_url_encoded")
local base64_url_safe = require("decipher.codecs.base64_url_safe")
local crockford = require("decipher.codecs.crockford")
local c_escape = require("decipher.codecs.c_escape")
local url = require("decipher.codecs.url")
local url_rfc3986 = require("decipher.codecs.url_rfc3986")
local xml = require("decipher.codecs.xml")
local zbase32 = require("decipher.codecs.zbase32")

---@enum decipher.Codecs
codecs.codec = {
    base32 = "base32",
    base64 = "base64",
    base64_url = "base64-url",
    base64_url_encoded = "base64-url-encoded",
    base64_url_safe = "base64-url-safe",
    crockford = "crockford",
    c_escape = "c-escape",
    url = "url",
    url_rfc3986 = "url-rfc3986",
    xml = "xml",
    zbase32 = "zbase32",
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
    base32 = base32,
    base64 = base64,
    ["base64-url"] = base64_url,
    ["base64-url-encoded"] = base64_url_encoded,
    ["base64-url-safe"] = base64_url_safe,
    crockford = crockford,
    ["c-escape"] = c_escape,
    url = url,
    url_rfc3986 = url_rfc3986,
    zbase32 = zbase32,
    xml = xml,
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
