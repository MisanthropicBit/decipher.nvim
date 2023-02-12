local marks = {}

---@class decipher.Position
---@field row number
---@field col number

---@class decipher.Region
---@field start decipher.Position
---@field end decipher.Position

---@param mark_type "visual" | "motion"
---@return decipher.Region
function marks.get_mark_positions(mark_type)
    local _marks = nil

    if mark_type == "visual" then
        _marks = vim.fn.mode() == "v" and { "v", "." } or { "'<", "'>" }
    elseif mark_type == "motion" then
        _marks = { "'[", "']" }
    else
        error(string.format("Unknown mark type: '%s'", mark_type), 0)
    end

    local start_row, start_col = unpack(vim.fn.getpos(_marks[1]), 2, 3)
    local end_row, end_col = unpack(vim.fn.getpos(_marks[2]), 2, 3)

    return {
        start = { row = start_row, col = start_col },
        ["end"] = { row = end_row, col = end_col },
    }
end

return marks
