local config = require("decipher.config")

describe("config", function()
    it("throws an error on invalid configs", function()
        local wrong_configs = {
            { float = { padding = "nope" } },
            { float = { max_height = "nah" } },
            { float = { max_width = true } },
            { float = { max_width = true } },
            { float = { border = true } },
            { float = { border = "triple" } },
            { float = { dismiss = 1 } },
            { float = { apply = {} } },
            { float = { title = {} } },
            { float = { title_separator = 1 } },
            { float = { autoclose = 1 } },
            { float = { options = "whoops" } },
        }

        for _, wrong_config in ipairs(wrong_configs) do
            assert.has_error(function()
                ---@diagnostic disable-next-line:assign-type-mismatch
                config.setup(wrong_config)
            end)
        end

        assert.has_error(
            function()
                ---@diagnostic disable-next-line:assign-type-mismatch
                config.setup({ active_codecs = "oops" })
            end,
            'active_codecs: expected valid codecs, got oops. Info: config.active_codecs should be "all" or a list of codecs'
        )

        -- We cannot use an expected error string here since the table's memory
        -- address is printed as part of the string and is different every time
        assert.has_error(function()
            ---@diagnostic disable-next-line:assign-type-mismatch
            config.setup({ active_codecs = { "base64", "base33" } })
        end)
    end)

    it("throws no errors for a valid config", function()
        config.setup({
            active_codecs = { "base64", "base32" },
            float = {
                max_height = 100,
                max_width = "auto",
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
                dismiss = "e",
                apply = "p",
                title = false,
                title_separator = "",
                autoclose = false,
                enter = true,
                options = {
                    wrap = false,
                    number = true,
                },
            },
        })
    end)
end)
