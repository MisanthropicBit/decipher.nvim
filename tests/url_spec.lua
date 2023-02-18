local url = require("decipher.codecs.url")
local test_utils = require("decipher.util.test")

describe("codecs.url", function()
    local test_cases = {
        ["this is=a test@"] = "this+is%3Da+test%40",
        ["this_should_not_be_encoded"] = "this_should_not_be_encoded",
    }

    it("url-encodes strings", function()
        test_utils.test_encode(test_cases, url.encode)
    end)

    it("url-decodes strings", function()
        test_utils.test_decode(test_cases, url.decode)
    end)

    it("handles nil", function()
        assert.is._nil(url.encode(nil))
        assert.is._nil(url.decode(nil))
    end)
end)
