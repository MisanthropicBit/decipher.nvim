local base64_url = require("decipher.codecs.base64_url")
local test_utils = require("decipher.util.test")

describe("codecs.base64_url", function()
    local test_cases = {
        ["this is=a test@!"] = "dGhpcyBpcz1hIHRlc3RAIQ%3d%3d",
        ["line1\nline2"] = "bGluZTEKbGluZTI%3d",
        [""] = "",
    }

    it("base64 url-decodes strings", function()
        test_utils.test_decode(test_cases, base64_url.decode)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            base64_url.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
