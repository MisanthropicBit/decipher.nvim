local compat = {}

---@param tbl table
---@return boolean
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
    end

    ---@diagnostic disable-next-line: deprecated
    return vim.health.report_start, vim.health.report_ok, vim.health.report_error
end

return compat
