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

--- Pad an array of given lines
---@param lines string[]
---@param padding number
---@return string[], number, number
function string_util.pad_lines(lines, padding)
    local padded = {}
    local width = 0

    for _ = 1, padding do
        table.insert(padded, "")
    end

    local padstr = (" "):rep(padding)

    for _, line in ipairs(lines) do
        local padded_line = padstr .. line .. padstr

        table.insert(padded, padded_line)
        width = math.max(width, #padded_line)
    end

    for _ = 1, padding do
        table.insert(padded, "")
    end

    return padded, width, #padded
end

--- Unpad an array of given lines
---@param lines string[]
---@param padding number
---@return string[]
function string_util.unpad_lines(lines, padding)
    local unpadded = {}

    for _ = 1, padding do
        table.remove(lines, 1)
    end

    for _, line in ipairs(lines) do
        local unpadded_line = line:sub(#line - #padding, #line):sub(1, padding)

        table.insert(unpadded, unpadded_line)
    end

    for _ = 1, padding do
        table.remove(lines, #lines)
    end

    return unpadded
end

return string_util
