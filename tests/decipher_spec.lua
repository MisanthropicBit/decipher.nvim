local decipher = require("decipher")
local stub = require("luassert.stub")

describe("decipher", function()
    it("gets the current version", function()
        assert.are.same(decipher.version(), "1.0.0")
    end)

    it("gets a sorted list of supported codecs", function()
        assert.are.same(decipher.supported_codecs(), {
            "base32",
            "base64",
            "base64-url",
            "base64-url-safe",
            "crockford",
            "url",
            "zbase32",
        })
    end)

    it("gets a sorted list of active codecs", function()
        decipher.setup({ active_codecs = { "crockford", "base64" } })

        assert.are.same(decipher.active_codecs(), {
            "base64",
            "crockford",
        })
    end)

    it("prints an error if the neovim version is not supported", function()
        stub(vim.fn, "has", false)
        stub(vim.api, "nvim_echo")

        decipher.setup({})

        assert.stub(vim.fn.has).was_called_with("nvim-0.5.0")
        assert.stub(vim.api.nvim_echo).was_called_with({
            { "[decipher]:", "ErrorMsg" },
            { " This plugin only works with Neovim >= v0.5.0" },
        }, false, {})
    end)

    it("encodes a string using a codec", function()
        assert.are.same(decipher.encode("base64", "light work"), "bGlnaHQgd29yaw==")
        assert.are.same(decipher.encode(decipher.codec.base64, "light work"), "bGlnaHQgd29yaw==")
    end)

    it("decodes a string using a codec", function()
        assert.are.same(decipher.decode("base64", "bGlnaHQgd29yaw=="), "light work")
        assert.are.same(decipher.decode(decipher.codec.base64, "bGlnaHQgd29yaw=="), "light work")
    end)

    it("issues an error for an unknown/unsupported codec", function()
        assert.has_error(function()
            decipher.encode("nope", "test")
        end, "Codec 'nope' not found")
    end)
end)
