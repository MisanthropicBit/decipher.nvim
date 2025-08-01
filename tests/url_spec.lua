local url = require("decipher.codecs.url")
local test_utils = require("decipher.util.test")

describe("codecs.url", function()
    local test_cases = {
        ["this is=a test@"] = "this+is%3Da+test%40",
        ["this_should_not_be_encoded"] = "this_should_not_be_encoded",
        ["http://www.test.com/?symbol=€"] = "http://www.test.com/?symbol%3d%e2%82%ac",
        ["http://www.test.com/?symbol=🥲"] = "http://www.test.com/?symbol%3d%f0%9f%a5%b2",
        [""] = "",
        ["🔑_🏧⛳🈹"] = "%f0%9f%94%91_%f0%9f%8f%a7%e2%9b%b3%f0%9f%88%b9",
    }

    it("url-decodes strings", function()
        test_utils.test_decode(test_cases, url.decode)
    end)

    it("decodes both lower- and upper-case hex digits", function()
        local input = "http://www.test.com/?symbol=€"
        local decoded_lower = url.decode("http://www.test.com/?symbol%3d%e2%82%ac")
        local decoded_upper = url.decode("http://www.test.com/?symbol%3D%E2%82%AC")

        assert.are.equal(#decoded_lower, #input)
        assert.are.equal(decoded_lower, input)

        assert.are.equal(#decoded_upper, #input)
        assert.are.equal(decoded_upper, input)
    end)

    it("handles nil", function()
        assert.has_error(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            url.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            url.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
