local base64_url_encoded = require("decipher.codecs.base64_url_encoded")
local test_utils = require("decipher.util.test")

describe("codecs.base64_url", function()
    local test_cases = {
        ["Many hands make light work."] = "TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu",
        ["light work."] = "bGlnaHQgd29yay4%3d",
        ["light work"] = "bGlnaHQgd29yaw%3d%3d",
        ["light wor"] = "bGlnaHQgd29y",
        ["light wo"] = "bGlnaHQgd28%3d",
        ["light w"] = "bGlnaHQgdw%3d%3d",
        [""] = "",
        ["works with unicode like ✔"] = "d29ya3Mgd2l0aCB1bmljb2RlIGxpa2Ug4pyU",
        ["line1\nline2"] = "bGluZTEKbGluZTI%3d",
        ["🔑_🏧⛳🈹"] = "8J%2bUkV%2fwn4%2bn4puz8J%2bIuQ%3d%3d",
    }

    it("base64 url-encodes strings", function()
        test_utils.test_encode(test_cases, base64_url_encoded.encode)
    end)

    it("base64 url-decodes strings", function()
        test_utils.test_decode(test_cases, base64_url_encoded.decode)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            base64_url_encoded.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            base64_url_encoded.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
