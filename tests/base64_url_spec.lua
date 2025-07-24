local base64_url = require("decipher.codecs.base64_url")
local test_utils = require("decipher.util.test")

describe("codecs.base64_url", function()
    local test_cases = {
        ["Many hands make light work."] = "TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu",
        ["light work."] = "bGlnaHQgd29yay4",
        ["light work"] = "bGlnaHQgd29yaw",
        ["light wor"] = "bGlnaHQgd29y",
        ["light wo"] = "bGlnaHQgd28",
        ["light w"] = "bGlnaHQgdw",
        ["this is=a test@!"] = "dGhpcyBpcz1hIHRlc3RAIQ",
        ["this is=a test@"] = "dGhpcyBpcz1hIHRlc3RA",
        ["Å³«ÍE#ÿ•3"] = "xQSzq81FI_-VMw",
        ['{"typ":"JWT","alg":"RS256","kid":"1"}'] = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjEifQ",
        ["works with unicode like âœ”"] = "d29ya3Mgd2l0aCB1bmljb2RlIGxpa2Ug4pyU",
        ["line1\nline2"] = "bGluZTEKbGluZTI",
        [""] = "",
    }

    it("base64 url-encodes strings", function()
        test_utils.test_encode(test_cases, base64_url.encode)
    end)

    it("base64 url-decodes strings", function()
        test_utils.test_decode(test_cases, base64_url.decode)
    end)

    it("padding is optional", function()
        assert.are.same(base64_url.decode("dGhpcyBpcz1hIHRlc3RAIQ=="), base64_url.decode("dGhpcyBpcz1hIHRlc3RAIQ"))
    end)

    it("fails if length of encoded value is invalid when applying padding", function()
        assert.has_error(function()
            base64_url.decode("eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjEif")
        end, "Invalid length of base64url string (49) when applying padding")
    end)

    it("handles nil values", function()
        assert.has_error(function()
            base64_url.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            base64_url.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
