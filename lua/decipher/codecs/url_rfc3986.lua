local url_rfc3986 = {}

local url = require("decipher.codecs.url")

function url_rfc3986.encode(value)
    return url.encode_with(value)
end

function url_rfc3986.decode(value)
    return url.decode_with(value, { decode_plus_as_space = false })
end

return url_rfc3986
