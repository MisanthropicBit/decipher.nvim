local decipher = require("decipher")
-- local spy = require('luassert.spy')

describe("decipher", function()
    it("gets the current version", function()
        assert.are.same(decipher.version(), "1.0.0")
    end)

    it("gets a list of supported codecs", function()
        local codecs = decipher.codecs()
        table.sort(codecs)

        assert.are.same(codecs, { "base64", "base64-url", "url" })
    end)

    it("encodes a string using a codec", function()
        local encoded = decipher.encode("base64", "light work")

        assert.are.same(encoded, "bGlnaHQgd29yaw==")
    end)

    it("issues an error and returns nil for an unknown/unsupported codec", function()
        -- local notifier = spy.new(vim.notify)
        local encoded = decipher.encode("nope", "light work")

        assert.is._nil(encoded)
        -- assert.spy(notifier).was.called_with("Codec not found 'nope'", vim.log.levels.INFO)

        -- notifier.revert()
    end)
end)
