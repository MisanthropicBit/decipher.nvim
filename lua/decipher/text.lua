local text = {}

---@param selection decipher.Region
---@return string[]
function text.get_region(selection)
    return vim.api.nvim_buf_get_text(
        0,
        selection.start.row - 1,
        selection.start.col - 1,
        selection["end"].row - 1,
        {}
    )[1]
end

---@param bufnr number
---@param selection decipher.Region
---@param value string
function text.set_region(bufnr, selection, value)
    -- TODO: Use lockmarks here if selection is on a single line
    vim.api.nvim_buf_set_text(
        bufnr,
        selection.start.row - 1,
        selection.start.col - 1,
        selection["end"].row - 1,
        { value }
    )
end

return text
