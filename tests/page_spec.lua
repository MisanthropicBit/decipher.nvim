local Page = require("decipher.ui.page")

describe("Page", function()
    it("validates setup function on creation", function()
        ---@diagnostic disable-next-line: missing-fields, param-type-mismatch
        Page:new(nil, { setup = nil })

        ---@diagnostic disable-next-line: missing-fields, param-type-mismatch
        Page:new(nil, { setup = function() end })

        assert.has_error(function()
            ---@diagnostic disable-next-line: missing-fields, param-type-mismatch
            Page:new(nil, { setup = true })
        end)
    end)
end)
