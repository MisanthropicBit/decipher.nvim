local marks = {}

---@class Position
---@field lnum number
---@field col number

---@class Region
---@field start Position
---@field end Position

---@param mark_type "visual" | "motion"
---@return Region
function marks.get_mark_positions(mark_type)
    local _marks = nil

    if mark_type == "visual" then
        _marks = vim.fn.mode() == "v" and { "v", "." } or { "'<", "'>" }
    elseif mark_type == "motion" then
        _marks = { "'[", "']" }
    else
        error(string.format("Unknown mark type: '%s'", mark_type))
    end

    local start_lnum, start_col = unpack(vim.fn.getpos(_marks[1]), 2, 3)
    local end_lnum, end_col = unpack(vim.fn.getpos(_marks[2]), 2, 3)

    return {
        start = { lnum = start_lnum, col = start_col },
        ["end"] = { lnum = end_lnum, col = end_col },
    }
end

return marks
