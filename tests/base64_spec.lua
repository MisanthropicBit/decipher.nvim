local base64 = require("decipher.codecs.base64")
local base64_url_safe = base64.url_safe()
local test_utils = require("decipher.util.test")

describe("codecs.base64", function()
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
    }

    it("encodes strings into base64", function()
        test_utils.test_encode(test_cases, base64.encode)
    end)

    it("decodes base64-encoded strings", function()
        test_utils.test_decode(test_cases, base64.decode)
    end)

    it("fails to decode a string with invalid characters", function()
        assert.has_error(function()
            base64.decode("bGln*HQgd28=")
        end, "Invalid character '*' at byte position 5 in base64 string")
    end)

    it("encodes strings into url-safe base64", function()
        test_utils.test_encode(test_cases, base64_url_safe.encode)
    end)

    it("decodes base64 url-safe encoded strings", function()
        test_utils.test_decode(test_cases, base64_url_safe.decode)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            ---@diagnostic disable-next-line:param-type-mismatch
            base64.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            ---@diagnostic disable-next-line:param-type-mismatch
            base64.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
