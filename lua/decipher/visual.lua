local visual = {}

---@param mark_type "visual" | "motion"
---@return table
local function get_mark_positions(mark_type)
    local marks = nil

    if mark_type == 'visual' then
        marks = vim.fn.mode() == "v" and { "v", "." } or { "'<", "'>" }
    elseif mark_type == 'motion' then
        marks = { "'[", "']" }
    else
        error(string.format("Unknown mark type: '%s'", mark_type))
    end

    local start_lnum, start_col = unpack(vim.fn.getpos(marks[1]), 2, 3)
    local end_lnum, end_col = unpack(vim.fn.getpos(marks[2]), 2, 3)

    return {
        ["start"] = { ["lnum"] = start_lnum, ["col"] = start_col },
        ["end"] = { ["lnum"] = end_lnum, ["col"] = end_col },
    }
end

---@return table
function visual.get_selection()
    return get_mark_positions('visual')
end

---@return table
function visual.get_motion()
    return get_mark_positions('motion')
end

return visual
