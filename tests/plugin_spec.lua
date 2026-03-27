local vader = require("decipher.util.vader")

local given, normal, expect = vader.given, vader.normal, vader.expect

describe("commands", function()
    it("runs DecipherVersion", function()
        assert.are.same(vim.fn.exists(":DecipherVersion"), 2)

        local output = vim.fn.execute("DecipherVersion", "")
        local version = vim.split(output, "\n", { plain = true, trimempty = true })[1]

        assert.are.same(version, "3.0.0") -- TODO: Match instead?
    end)

    it("runs DecipherEncode", function()
        assert.are.same(vim.fn.exists(":DecipherEncode"), 2)

        given({ "light work" }, function(context)
            normal("gg0vg_<esc>")
            vim.cmd("DecipherEncode base64")
            expect({ "bGlnaHQgd29yaw==" })
        end)
    end)

    it("handles invalid options for 'preview'", function()
        local ok, err = pcall(vim.fn.execute, "DecipherEncode preview=nope", "")

        assert.is_false(ok)

        ---@diagnostic disable-next-line: undefined-field
        assert.has_match(
            "Found one or more errors: Invalid value for option 'preview', expected 'true' or 'false'",
            err
        )
    end)

    it("handles more than one codec", function()
        local ok, err = pcall(vim.fn.execute, "DecipherEncode base64 base32", "")

        assert.is_false(ok)

        ---@diagnostic disable-next-line: undefined-field
        assert.has_match("Multiple valid codecs given, specify only one", err)
    end)

    it("handles unknown arguments", function()
        local ok, err = pcall(vim.fn.execute, "DecipherEncode nope preview=true", "")

        assert.is_false(ok)

        ---@diagnostic disable-next-line: undefined-field
        assert.has_match("One or more unrecognised arguments: nope", err)
    end)

    it("runs DecipherDecode", function()
        assert.are.same(vim.fn.exists(":DecipherDecode"), 2)

        given({ "bGlnaHQgd29yaw==" }, function(context)
            normal("gg0vg_<esc>")
            vim.cmd("DecipherDecode base64")
            expect({ "light work" })
        end)
    end)
end)
