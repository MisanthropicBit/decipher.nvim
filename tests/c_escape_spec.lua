local c_escape = require("decipher.codecs.c_escape")
local test_utils = require("decipher.util.test")

describe("codecs.c_escape", function()
    local test_cases = {
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t",
        ["\b"] = "\\b",
        ["\f"] = "\\\f",
        ['"'] = '\\"',
        ["\\"] = "\\\\",
    }

    it("escapes strings as a c string", function()
        local test = "line 1\nline2"
        test_utils.test_encode(test_cases, c_escape.encode)
    end)

    it("unescapes c-escaped strings", function()
        test_utils.test_decode(test_cases, c_escape.decode)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            ---@diagnostic disable-next-line:param-type-mismatch
            c_escape.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            ---@diagnostic disable-next-line:param-type-mismatch
            c_escape.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
