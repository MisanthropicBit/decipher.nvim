local decipher = require("decipher")
local stub = require("luassert.stub")

describe("decipher", function()
    it("gets the current version", function()
        assert.are.same(decipher.version(), "1.0.0")
    end)

    it("gets a list of supported codecs", function()
        local codecs = decipher.codecs()
        table.sort(codecs)

        assert.are.same(codecs, { "base64", "base64-url", "url" })
    end)

    it("prints an error if the neovim version is not supported", function()
        stub(vim.fn, "has", false)
        stub(vim.api, "nvim_echo")

        decipher.setup({})

        assert.stub(vim.fn.has).was_called_with("nvim-0.5.0")
        assert.stub(vim.api.nvim_echo).was_called_with({
            { "[decipher]:", "WarningMsg" },
            { " This plugin only works with Neovim >= v0.5.0" },
        }, false, {})
    end)

    it("encodes a string using a codec", function()
        local encoded = decipher.encode("base64", "light work")

        assert.are.same(encoded, "bGlnaHQgd29yaw==")
    end)

    it("issues an error and returns nil for an unknown/unsupported codec", function()
        stub(vim.api, "nvim_echo")

        local encoded = decipher.encode("nope", "test")
        assert.is._nil(encoded)

        assert.stub(vim.api.nvim_echo).was_called_with({
            { "[decipher]:", "WarningMsg" },
            { " Codec not found:" },
            { " nope", "WarningMsg" },
        }, true, {})
    end)
end)
