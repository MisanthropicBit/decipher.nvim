local url_plus = {}

local url = require("decipher.codecs.url")

function url_plus.encode(value)
    return url.encode_with(value)
end

function url_plus.decode(value)
    return url.decode_with(value, { decode_plus_as_space = false })
end

return url_plus
