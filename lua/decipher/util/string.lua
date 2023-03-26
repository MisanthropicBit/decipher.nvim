local string_util = {}

---@param lines string[]
---@return string[]
function string_util.escape_newlines(lines)
    return vim.tbl_map(function(line)
        local sub, _ = line:gsub("\n", [[\n]])

        return sub
    end, lines)
end

return string_util
