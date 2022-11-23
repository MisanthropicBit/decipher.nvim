local base64_url = require("decipher.codecs.base64_url")

describe("codecs.base64_url", function()
    local test_cases = {
        ["this is=a test@"] = "dGhpcytpcyUzRGErdGVzdCU0MA==",
    }

    -- TODO
    -- it('base64 url-encodes strings', function()
    --     for input, output in pairs(test_cases) do
    --         assert.are.same(base64_url.encode(input), output)
    --     end
    -- end)

    it("base64 url-decodes strings", function()
        for input, output in pairs(test_cases) do
            assert.are.same(base64_url.decode(output), input)
        end
    end)

    it("handles nil", function()
        assert.is._nil(base64_url.decode(nil))
    end)
end)
