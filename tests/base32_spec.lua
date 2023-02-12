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
    }

    it("encodes strings into base32", function()
        test_utils.test_encode(std_test_cases, base32.encode)
    end)

    it("decodes base32-encoded strings", function()
        test_utils.test_decode(std_test_cases, base32.decode)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            base32.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            base32.decode(nil)
        end, "Cannot decode nil value")
    end)

    it("throws an error if the length of the base32-encoded string is not a multiple of 8", function()
        assert.has_error(function()
            base32.decode("NRUWO2DUEB3W64")
        end, "base32-encoded string is not a multiple of 8")
    end)

    describe("codecs.base32.zbase32", function()
        local zbase32 = base32.zbase32()

        local test_cases = {
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
            test_utils.test_encode(test_cases, zbase32.encode)
        end)

        it("decodes zbase32-encoded strings", function()
            test_utils.test_decode(test_cases, zbase32.decode)
        end)
    end)

    describe("codecs.base32.crockford", function()
        local crockford = base32.crockford()

        local test_cases = {
            ["Many hands make light work."] = "9NGPWY90D1GPWS3K41PP2TV541P6JSV8EGG7EVVJDCQ0====",
            ["light work."] = "DHMPET3M41VPYWKB5R======",
            ["light work"] = "DHMPET3M41VPYWKB",
            ["light wor"] = "DHMPET3M41VPYWG=",
            ["light wo"] = "DHMPET3M41VPY===",
            ["light w"] = "DHMPET3M41VG====",
            [""] = "",
            ["line1\nline2"] = "DHMPWS9H19P6JVK568======",
            ["works with unicode like ✔"] = "EXQQ4TVK41VPJX3841TPWTB3DXJ6A83CD5NPA872KJA0====",
        }

        it("encodes strings into crockford", function()
            test_utils.test_encode(test_cases, crockford.encode)
        end)

        it("decodes crockford-encoded strings", function()
            test_utils.test_decode(test_cases, crockford.decode)
        end)
    end)
end)
