-- Testing tools inspired by the awesome vader.vim and based on
-- the fine ideas from:
-- https://github.com/Julian/lean.nvim/blob/main/lua/tests/helpers.lua

local vader = {}

local has_luassert, luassert = pcall(require, "luassert")

if not has_luassert then
    error("Luassert library not found")
end

local say = require("say")

---@diagnostic disable-next-line:unused-local
local function expect_buffer(description, state, arguments)
    local status, _ = pcall(luassert.are.same, state, arguments)

    return status
end

say:set("assertion.expect_buffer.positive", "Expected %s to %s in buffer \n but got %s")
say:set("assertion.expect_buffer.negative", "Expected %s to %s in buffer \nto didn't get %s")

luassert:register(
    "assertion",
    "expect_buffer",
    expect_buffer,
    "assertion.expect_buffer.positive",
    "assertion.expect_buffer.negative"
)

--- Create a new buffer with the given contents and run the callback
--- in that buffer
---@param ... any
function vader.given(...)
    local description, contents, callback
    local numargs = select("#", ...)

    if numargs < 2 then
        error("vader.given takes at least 2 arguments")
    elseif numargs == 2 then
        contents, callback = ...
    elseif numargs == 3 then
        description, contents, callback = ...
    end

    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_set_current_buf(bufnr)

    vim.opt_local.bufhidden = "hide"
    vim.opt_local.swapfile = false

    if #contents > 0 then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
    end

    -- TODO: Add custom formatter here?
    vim.api.nvim_buf_call(bufnr, function()
        callback({ bufnr = bufnr, win_id = vim.api.nvim_get_current_win() })
    end)

    -- Clean up all open buffers to ensure test isolation
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    end
end

--- Run normal mode commands without mappings
---@param input string
---@param use_mappings? boolean
function vader.normal(input, use_mappings)
    local bang = use_mappings and "!" or ""
    vim.cmd(vim.api.nvim_replace_termcodes("normal" .. bang .. " " .. input, true, false, true))
end

function vader.expect(contents, bufnr)
    local actual_contents = vim.api.nvim_buf_get_lines(bufnr or 0, 0, -1, true)

    luassert.are.same(actual_contents, contents)
end

return vader
