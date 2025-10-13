local config = require("decipher.config")

describe("config", function()
    it("throws an error on invalid configs", function()
        local wrong_configs = {
            { float = { padding = "nope" } },
            { float = { border = true } },
            { float = { border = "triple" } },
            { float = { mappings = { close = 1 } } },
            { float = { mappings = { apply = {} } } },
            { float = { mappings = { json = coroutine.create(function() end) } } },
            { float = { mappings = { help = function() end } } },
            { float = { title = {} } },
            { float = { title_pos = 1 } },
            { float = { autoclose = 1 } },
            { float = { win_options = "whoops" } },
            { float = { zindex = false } },
        }

        for _, wrong_config in ipairs(wrong_configs) do
            assert.has_error(function()
                ---@diagnostic disable-next-line:assign-type-mismatch
                config.setup(wrong_config)
            end)
        end
    end)

    it("throws no errors for a valid config", function()
        config.setup({
            ---@diagnostic disable-next-line: missing-fields
            float = {
                padding = 1,
                border = {
                    { "╭", "Keyword" },
                    { "─", "Keyword" },
                    { "╮", "Keyword" },
                    { "│", "Keyword" },
                    { "╯", "Keyword" },
                    { "─", "Keyword" },
                    { "╰", "Keyword" },
                    { "│", "Keyword" },
                },
                mappings = {
                    close = "e",
                    apply = "p",
                    json = "H",
                    help = "x",
                },
                title = false,
                title_pos = "right",
                autoclose = false,
                enter = true,
                win_options = {
                    wrap = false,
                    number = true,
                },
                zindex = 52,
            },
        })
    end)
end)
