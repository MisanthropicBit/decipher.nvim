local url = require("decipher.codecs.url")

describe("codecs.url", function()
    local test_cases = {
        ["this is=a test@"] = "this+is%3Da+test%40",
        ["this_should_not_be_encoded"] = "this_should_not_be_encoded",
    }

    it("url-encodes strings", function()
        for input, output in pairs(test_cases) do
            assert.are.same(url.encode(input), output)
        end
    end)

    it("url-decodes strings", function()
        for input, output in pairs(test_cases) do
            assert.are.same(url.decode(output), input)
        end
    end)

    it("handles nil", function()
        assert.is._nil(url.decode(nil))
    end)
end)
