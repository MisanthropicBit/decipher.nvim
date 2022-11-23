local M = {}

local base64 = require("decipher.codecs.base64")
local base64_url = require("decipher.codecs.base64_url")
local url = require("decipher.codecs.url")

local codecs_map = {
    ["base64"] = base64,
    ["base64-url"] = base64_url,
    ["url"] = url,
}

function M.get(name)
    return codecs_map[name]
end

function M.supported()
    return vim.tbl_keys(codecs_map)
end

return M
