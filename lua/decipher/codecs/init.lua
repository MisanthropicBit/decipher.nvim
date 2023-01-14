local M = {}

local base64 = require("decipher.codecs.base64")
local base64_url = require("decipher.codecs.base64_url")
local url = require("decipher.codecs.url")

---@enum codec
M.codec = {
    base64 = "base64",
    base85 = "base85",
    base64_url = "base64-url",
    base85_url = "base85-url",
    rot13 = "rot13",
    all = "all",
}

---@alias decipher.codec codec

local codecs_map = {
    ["base64"] = base64,
    ["base64-url"] = base64_url,
    ["url"] = url,
}

function M.get(name)
    return codecs_map[name]
end

function M.supported()
    local codecs = vim.tbl_keys(codecs_map)
    table.sort(codecs)

    return codecs
end

return M
