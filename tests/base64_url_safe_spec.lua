local base64_url_safe = require("decipher.codecs.base64_url_safe")
local test_utils = require("decipher.util.test")

describe("codecs.base64_url_safe", function()
    local test_cases = {
        ["Many hands make light work."] = "TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu",
        ["light work."] = "bGlnaHQgd29yay4=",
        ["light work"] = "bGlnaHQgd29yaw==",
        ["light wor"] = "bGlnaHQgd29y",
        ["light wo"] = "bGlnaHQgd28=",
        ["light w"] = "bGlnaHQgdw==",
        [""] = "",
        ["works with unicode like ✔"] = "d29ya3Mgd2l0aCB1bmljb2RlIGxpa2Ug4pyU",
        ["line1\nline2"] = "bGluZTEKbGluZTI=",
        ["🔑_🏧⛳🈹"] = "8J-UkV_wn4-n4puz8J-IuQ==",
    }

    it("encodes strings into url-safe base64", function()
        test_utils.test_encode(test_cases, base64_url_safe.encode)
    end)

    it("decodes url-safe base64-encoded strings", function()
        test_utils.test_decode(test_cases, base64_url_safe.decode)
    end)

    it("fails to decode a string with invalid characters", function()
        assert.has_error(function()
            base64_url_safe.decode("bGln*HQgd28=")
        end, "Invalid character '*' at byte position 5 in base64-url-safe string")
    end)

    it("handles nil values", function()
        assert.has_error(function()
            ---@diagnostic disable-next-line:param-type-mismatch
            base64_url_safe.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            ---@diagnostic disable-next-line:param-type-mismatch
            base64_url_safe.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
