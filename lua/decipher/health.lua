local health = {}
local compat = require("decipher.compat")
local decipher = require("decipher")

local report_start, report_ok, report_error = compat.get_report_funcs()

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
