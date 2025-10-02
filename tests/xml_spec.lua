local xml = require("decipher.codecs.xml")
local test_utils = require("decipher.util.test")

describe("codecs.xml", function()
    local test_case1 = [[<tag>\"&value'</tag>]]

    local test_cases = {
        [test_case1] = "&lt;tag&gt;\\&quot;&amp;value&apos;&lt;/tag&gt;",
    }

    it("xml-encodes strings", function()
        test_utils.test_encode(test_cases, xml.encode)
    end)

    it("decodes xml-encoded strings", function()
        test_utils.test_decode(test_cases, xml.decode)

        assert.are.same(xml.decode("&#000038;&#x000026;"), "&&")
    end)

    it("decodes all html entities", function()
        for name, value in pairs(xml.html_entities()) do
            local decoded_entity = vim.fn.nr2char(value)

            assert.are.same(xml.decode(("&%s;"):format(name)), decoded_entity)
            assert.are.same(xml.decode(("&#%d;"):format(value)), decoded_entity)
        end
    end)

    it("decoding html entities is case sensitive", function()
        for name, _ in pairs(xml.html_entities()) do
            if not vim.tbl_contains({ "apos", "quot", "gt", "lt" }, name) then
                local entity = name:sub(1, 1):lower() .. name:sub(2):upper()
                assert.are.same(xml.decode(("&%s;"):format(entity)), "?")
            end
        end
    end)

    it('decodes an html entity preceeded by "&amp;"', function()
        assert.are.same(xml.decode("&amp;euro;"), "&euro;")
    end)

    it("handles nil values", function()
        assert.has_error(function()
            ---@diagnostic disable-next-line:param-type-mismatch
            xml.encode(nil)
        end, "Cannot encode nil value")

        assert.has_error(function()
            ---@diagnostic disable-next-line:param-type-mismatch
            xml.decode(nil)
        end, "Cannot decode nil value")
    end)
end)
