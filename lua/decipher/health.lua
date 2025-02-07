local health = {}
local decipher = require("decipher")

local report_start, report_ok, report_error

if vim.fn.has("nvim-0.10") then
    report_start = vim.health.start
    report_ok = vim.health.ok
    report_error = vim.health.error
else
    ---@diagnostic disable-next-line: deprecated
    report_start = vim.health.report_start
    ---@diagnostic disable-next-line: deprecated
    report_ok = vim.health.report_ok
    ---@diagnostic disable-next-line: deprecated
    report_error = vim.health.report_error
end

function health.check()
    report_start("decipher.nvim")

    if not decipher.has_bit_library() then
        report_error("A bit library is required", {
            "Build neovim with luajit",
            "Use neovim v0.9.0+ which includes a bit library",
        })
    else
        report_ok("A bit library is available")
    end
end

return health
