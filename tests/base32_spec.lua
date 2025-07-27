local base32 = require("decipher.codecs.base32")
local test_utils = require("decipher.util.test")

describe("codecs.base32", function()
    local std_test_cases = {
        ["Many hands make light work."] = "JVQW46JANBQW4ZDTEBWWC23FEBWGSZ3IOQQHO33SNMXA====",
        ["light work."] = "NRUWO2DUEB3W64TLFY======",
        ["light work"] = "NRUWO2DUEB3W64TL",
        ["light wor"] = "NRUWO2DUEB3W64Q=",
        ["light wo"] = "NRUWO2DUEB3W6===",
        ["light w"] = "NRUWO2DUEB3Q====",
        [""] = "",
        ["line1\nline2"] = "NRUW4ZJRBJWGS3TFGI======",
        ["works with unicode like ✔"] = "O5XXE23TEB3WS5DIEB2W42LDN5SGKIDMNFVWKIHCTSKA====",
        ["🔑_🏧⛳🈹"] = "6CPZJEK76CPY7J7CTOZ7BH4IXE======",
    }

    it("encodes strings into base32", function()
        test_utils.test_encode(std_test_cases, base32.encode)
    end)

    it("decodes base32-encoded strings", function()
        test_utils.test_decode(std_test_cases, base32.decode)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            base32.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            base32.decode(nil)
        end, "Cannot decode nil value")
    end)

    it("throws an error if the length of the base32-encoded string is not a multiple of 8", function()
        assert.has_error(function()
            base32.decode("NRUWO2DUEB3W64")
        end, "base32-encoded string is not a multiple of 8")
    end)
end)
