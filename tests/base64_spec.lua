local base64 = require("decipher.codecs.base64")
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

    local base64_url_safe = base64.make_base64_codec({
        [0] = "A",
        [1] = "B",
        [2] = "C",
        [3] = "D",
        [4] = "E",
        [5] = "F",
        [6] = "G",
        [7] = "H",
        [8] = "I",
        [9] = "J",
        [10] = "K",
        [11] = "L",
        [12] = "M",
        [13] = "N",
        [14] = "O",
        [15] = "P",
        [16] = "Q",
        [17] = "R",
        [18] = "S",
        [19] = "T",
        [20] = "U",
        [21] = "V",
        [22] = "W",
        [23] = "X",
        [24] = "Y",
        [25] = "Z",
        [26] = "a",
        [27] = "b",
        [28] = "c",
        [29] = "d",
        [30] = "e",
        [31] = "f",
        [32] = "g",
        [33] = "h",
        [34] = "i",
        [35] = "j",
        [36] = "k",
        [37] = "l",
        [38] = "m",
        [39] = "n",
        [40] = "o",
        [41] = "p",
        [42] = "q",
        [43] = "r",
        [44] = "s",
        [45] = "t",
        [46] = "u",
        [47] = "v",
        [48] = "w",
        [49] = "x",
        [50] = "y",
        [51] = "z",
        [52] = "0",
        [53] = "1",
        [54] = "2",
        [55] = "3",
        [56] = "4",
        [57] = "5",
        [58] = "6",
        [59] = "7",
        [60] = "8",
        [61] = "9",
        [62] = "-",
        [63] = "_",
    }, "=")

    it("encodes strings into base64 with custom codec", function()
        test_utils.test_encode(test_cases, function(value)
            return base64.encode_with(value, base64_url_safe)
        end)
    end)

    it("decodes strings into base64 with custom codec", function()
        test_utils.test_decode(test_cases, function(value)
            return base64.decode_with(value, base64_url_safe)
        end)
    end)

    it("handles nil values", function()
        assert.has_error(function()
            base64.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            base64.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
