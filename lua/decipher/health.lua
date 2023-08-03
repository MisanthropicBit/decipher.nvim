local health = {}

function health.check()
    vim.health.report_start("decipher.nvim")

    local has_bit, _ = pcall(require, "bit")

    if not has_bit then
        vim.health.report_error("A bit library is required", {
            "Build neovim with luajit",
            "Use neovim v0.9.0+ which includes a bit library",
        })
    else
        vim.health.report_ok("A bit library is available")
    end
end

return health
