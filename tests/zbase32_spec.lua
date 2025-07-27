local zbase32 = require("decipher.codecs.zbase32")
local test_utils = require("decipher.util.test")

describe("codecs.zbase32", function()
    local std_test_cases = {
        ["Many hands make light work."] = "jiosh6jypbosh3durbssn45frbsg135eqoo8q551pczy====",
        ["light work."] = "ptwsq4dwrb5s6humfa======",
        ["light work"] = "ptwsq4dwrb5s6hum",
        ["light wor"] = "ptwsq4dwrb5s6ho=",
        ["light wo"] = "ptwsq4dwrb5s6===",
        ["light w"] = "ptwsq4dwrb5o====",
        [""] = "",
        ["line1\nline2"] = "ptwsh3jtbjsg15ufge======",
        ["works with unicode like ✔"] = "q7zzr45urb5s17derb4sh4mdp71gkedcpfiske8nu1ky====",
    }

    it("encodes strings into zbase32", function()
        test_utils.test_encode(std_test_cases, zbase32.encode)
    end)

    it("decodes zbase32-encoded strings", function()
        test_utils.test_decode(std_test_cases, zbase32.decode)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            zbase32.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            zbase32.decode(nil)
        end, "Cannot decode nil value")
    end)

    it("throws an error if the length of the zbase32-encoded string is not a multiple of 8", function()
        assert.has_error(function()
            zbase32.decode("NRUWO2DUEB3W64")
        end, "zbase32-encoded string is not a multiple of 8")
    end)
end)
