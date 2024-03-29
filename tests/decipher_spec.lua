local decipher = require("decipher")
local codecs = require("decipher.codecs")
local stub = require("luassert.stub")

describe("decipher", function()
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
        }, true, {})

        vim.fn.has:revert()
        vim.api.nvim_echo:revert()
    end)

    it("prints an error if a bit library is not available", function()
        stub(decipher, "has_bit_library", false)
        stub(vim.api, "nvim_echo")

        decipher.setup({})

        assert.stub(vim.api.nvim_echo).was_called_with({
            { "[decipher]:", "ErrorMsg" },
            { " " },
            { "A bit library is required. Ensure that either " },
            { "neovim has been built with luajit " },
            { "or use neovim v0.9.0+ which includes a bit library" },
        }, true, {})

        decipher.has_bit_library:revert()
        vim.api.nvim_echo:revert()
    end)

    it("encodes a string using a codec", function()
        assert.are.same(decipher.encode("base64", "light work"), "bGlnaHQgd29yaw==")
        assert.are.same(decipher.encode(decipher.codec.base64, "light work"), "bGlnaHQgd29yaw==")
    end)

    it("decodes a string using a codec", function()
        assert.are.same(decipher.decode("base64", "bGlnaHQgd29yaw=="), "light work")
        assert.are.same(decipher.decode(decipher.codec.base64, "bGlnaHQgd29yaw=="), "light work")
    end)

    it("issues an error for an unknown codec", function()
        assert.has_error(function()
            decipher.encode("nope", "test")
        end, "Codec 'nope' not found")
    end)

    it("issues an error for unsupported encoding/decoding", function()
        stub(codecs, "get", { decode = function() end })

        assert.has_error(function()
            decipher.encode("base64-url", "test")
        end, "Codec 'base64-url' does not support 'encode'")

        stub(codecs, "get", { encode = function() end })

        assert.has_error(function()
            decipher.decode("base64-url", "test")
        end, "Codec 'base64-url' does not support 'decode'")

        codecs.get:revert()
    end)
end)
