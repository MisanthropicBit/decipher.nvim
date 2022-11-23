local visual = {}

function visual.get_selection()
    local args = vim.fn.mode() == "v" and { "v", "." } or { "'<", "'>" }
    local start_lnum, start_col = unpack(vim.fn.getpos(args[1]), 2, 3)
    local end_lnum, end_col = unpack(vim.fn.getpos(args[2]), 2, 3)

    return {
        ["start"] = { ["lnum"] = start_lnum, ["col"] = start_col },
        ["end"] = { ["lnum"] = end_lnum, ["col"] = end_col },
    }
end

function visual.get_motion()
    local start_lnum, start_col = unpack(vim.fn.getpos("'["), 2, 3)
    local end_lnum, end_col = unpack(vim.fn.getpos("']"), 2, 3)

    return {
        ["start"] = { ["lnum"] = start_lnum, ["col"] = start_col },
        ["end"] = { ["lnum"] = end_lnum, ["col"] = end_col },
    }
end

return visual
