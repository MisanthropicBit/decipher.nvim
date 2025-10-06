local string_util = {}

---@param lines string[]
---@return string[]
function string_util.escape_newlines(lines)
    return vim.tbl_map(function(line)
        local sub, _ = line:gsub("\n", [[\n]])

        return sub
    end, lines)
end

---@param lines string[]
---@return integer, integer
function string_util.dimensions(lines)
    local width, height = 0, #lines

    for _, line in ipairs(lines) do
        width = math.max(width, #line)
    end

    return width, height
end

return string_util
