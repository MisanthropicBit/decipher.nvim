local decipher = require("decipher")
local config = require("decipher.config")
local codecs = require("decipher.codecs")

describe("config", function()
    it("throws an error on invalid configs", function()
        local wrong_configs = {
            { float = { padding = "nope" } },
            { float = { border = true } },
            { float = { border = "triple" } },
            { float = { mappings = { close = 1 } } },
            { float = { mappings = { apply = {} } } },
            { float = { mappings = { jsonpp = coroutine.create(function() end) } } },
            { float = { mappings = { help = function() end } } },
            { float = { title = {} } },
            { float = { title_pos = 1 } },
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

    it('uses all codecs when "all" is used', function()
        config.setup({ active_codecs = "all" })

        assert.are.same(config.active_codecs, codecs.supported())
        assert.are.same(decipher.active_codecs(), codecs.supported())
    end)

    it("throws no errors for a valid config", function()
        config.setup({
            active_codecs = { "base64", "base32" },
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
                    jsonpp = "H",
                    help = "x",
                },
                title = false,
                title_pos = "right",
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
