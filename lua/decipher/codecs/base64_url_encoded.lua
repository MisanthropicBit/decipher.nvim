local base64_url_encoded = {}

local base64 = require("decipher.codecs.base64")
local url = require("decipher.codecs.url")

--- Encode a value as a base64 url-encoded string
---@param value string
---@return string
function base64_url_encoded.encode(value)
    return url.encode(base64.encode(value))
end

--- Decode a base64 url-encoded string
---@param value string
---@return string
function base64_url_encoded.decode(value)
    return base64.decode(url.decode(value))
end

return base64_url_encoded
