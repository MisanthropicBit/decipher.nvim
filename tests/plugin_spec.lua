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

    it("runs DecipherDecode", function()
        assert.are.same(vim.fn.exists(":DecipherDecode"), 2)

        given({ "bGlnaHQgd29yaw==" }, function(context)
            normal("gg0vg_<esc>")
            vim.cmd("DecipherDecode base64")
            expect({ "light work" })
        end)
    end)
end)
