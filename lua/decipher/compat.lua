local compat = {}

function compat.tbl_islist(tbl)
    if vim.fn.has("nvim-0.10.0") == 1 then
        return vim.islist(tbl)
    end

    ---@diagnostic disable-next-line: deprecated
    return vim.tbl_islist(tbl)
end

---@return function, function, function
function compat.get_report_funcs()
    if vim.fn.has("nvim-0.10") == 1 then
        return vim.health.start, vim.health.ok, vim.health.error
    else
        ---@diagnostic disable-next-line: deprecated
        return vim.health.report_start, vim.health.report_ok, vim.health.report_error
    end
end

---@param name string
---@param value unknown
---@param options { scope: "local" | "global", win: integer?, buf: integer? }
function compat.set_option(name, value, options)
    if vim.fn.has("nvim-0.10.0") == 1 then
        vim.api.nvim_set_option_value(name, value, options)
    else
        if options.win then
            ---@diagnostic disable-next-line: deprecated
            vim.api.nvim_win_set_option(options.win, name, value)
        elseif options.buf then
            ---@diagnostic disable-next-line: deprecated
            vim.api.nvim_buf_set_option(options.buf, name, value)
        end
    end
end

return compat
