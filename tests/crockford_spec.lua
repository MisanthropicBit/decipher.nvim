local crockford = require("decipher.codecs.crockford")
local test_utils = require("decipher.util.test")

vim.print(require("decipher").encode("crockford", "🔑_🏧⛳🈹"))
describe("codecs.crockford", function()
    local std_test_cases = {
        ["Many hands make light work."] = "9NGPWY90D1GPWS3K41PP2TV541P6JSV8EGG7EVVJDCQ0====",
        ["light work."] = "DHMPET3M41VPYWKB5R======",
        ["light work"] = "DHMPET3M41VPYWKB",
        ["light wor"] = "DHMPET3M41VPYWG=",
        ["light wo"] = "DHMPET3M41VPY===",
        ["light w"] = "DHMPET3M41VG====",
        [""] = "",
        ["line1\nline2"] = "DHMPWS9H19P6JVK568======",
        ["works with unicode like ✔"] = "EXQQ4TVK41VPJX3841TPWTB3DXJ6A83CD5NPA872KJA0====",
        ["🔑_🏧⛳🈹"] = "Y2FS94AZY2FRZ9Z2KESZ17W8Q4======",
    }

    it("encodes strings into crockford", function()
        test_utils.test_encode(std_test_cases, crockford.encode)
    end)

    it("decodes crockford-encoded strings", function()
        test_utils.test_decode(std_test_cases, crockford.decode)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            crockford.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            crockford.decode(nil)
        end, "Cannot decode nil value")
    end)

    it("throws an error if the length of the crockford-encoded string is not a multiple of 8", function()
        assert.has_error(function()
            crockford.decode("NRUWO2DUEB3W64")
        end, "crockford-encoded string is not a multiple of 8")
    end)
end)
