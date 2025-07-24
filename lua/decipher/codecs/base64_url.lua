local base64url = {}

-- A direct implementation of the example C# code in RFC 7515, appendix C

local base64 = require("decipher.codecs.base64")

function base64url.encode(value)
    if value == nil then
        error("Cannot encode nil value", 0)
    end

    return vim.fn.trim(base64.encode(value), "=", 2):gsub("+", "-"):gsub("/", "_")
end

function base64url.decode(value)
    if value == nil then
        error("Cannot decode nil value", 0)
    end

    local translated = value:gsub("-", "+"):gsub("_", "/")
    local len_remainder = #translated % 4

    if len_remainder == 0 then
        -- No padding needed
    elseif len_remainder == 2 or len_remainder == 3 then
        translated = translated .. ("="):rep(4 - len_remainder)
    else
        error(("Invalid length of base64url string (%d) when applying padding"):format(#translated), 0)
    end

    return base64.decode(translated)
end

return base64url
