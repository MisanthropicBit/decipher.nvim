local M = {}

local base64 = require("decipher.codecs.base64")
local url = require("decipher.codecs.url")

-- TODO
-- function M.encode(value)
-- end

function M.decode(value)
    return url.decode(base64.decode(value))
end

return M
