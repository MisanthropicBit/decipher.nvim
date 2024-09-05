local selection = require("decipher.selection")
local vader = require("decipher.util.vader")

local given, normal, expect = vader.given, vader.normal, vader.expect

-- TODO:
--  * Test selection with currently selected visual mode
--  * Test selection vim options (test 'old')
--  * Test selection when still in visual mode

describe("selection", function()
    after_each(function()
        -- The 'selection' option is set globally
        vim.opt_local.selection = "inclusive"
    end)

    describe("motion", function()
        local contents = { "a sentence on the first line", 'this "is" a test' }

        describe("get_selection", function()
            it("gets region after motion (inner double-quoted string)", function()
                given(contents, function()
                    normal('jwyi"')

                    local region = selection.get_selection("motion")

                    assert.are.same(region, {
                        start = { lnum = 2, col = 7 },
                        ["end"] = { lnum = 2, col = 9 },
                    })
                end)
            end)

            it("gets region after motion (a word)", function()
                given(contents, function()
                    normal("$2hyaw")

                    local region = selection.get_selection("motion")

                    assert.are.same(region, {
                        start = { lnum = 1, col = 24 },
                        ["end"] = { lnum = 1, col = 28 },
                    })
                end)
            end)
        end)

        describe("get_text", function()
            it("gets text after motion (inner double-quoted string)", function()
                pending("Skipped")

                -- given(contents, function()
                --     normal('jwyi"')

                --     local text = selection.get_text(0, "motion")

                --     assert.are.same(text, { "is" })
                -- end)
            end)

            it("gets text after motion (a word)", function()
                given(contents, function()
                    normal("$2hyaw")

                    local text = selection.get_text(0, "motion")

                    assert.are.same(text, { " line" })
                end)
            end)

            it("gets text after motion that crosses line boundaries", function()
                given(contents, function()
                    normal("2wy5w")

                    local text = selection.get_text(0, "motion")

                    assert.are.same(text, { "on the first line", 'this "' })
                end)
            end)
        end)

        describe("set_text", function()
            it("sets text after motion", function()
                pending("Skipped")

                -- given(contents, function()
                --     normal('jwyi"')

                --     local text = { "is not" }
                --     selection.set_text(0, "motion", text)

                --     expect({
                --         "a sentence on the first line",
                --         'this "is not" a test'
                --     })
                -- end)
            end)

            it("sets text after motion (a word)", function()
                given(contents, function()
                    normal("$2hyaw")

                    local text = { "replacement" }
                    selection.set_text(0, "motion", text)

                    expect({
                        "a sentence on the firstreplacement",
                        'this "is" a test',
                    })
                end)
            end)

            it("sets text after motion that crosses line boundaries", function()
                given(contents, function()
                    normal("2wy5w")

                    local text = { "replacement" }
                    selection.set_text(0, "motion", text)

                    expect({
                        'a sentence replacementis" a test',
                    })
                end)
            end)

            it("sets multi-line text after motion that crosses line boundaries", function()
                given(contents, function()
                    normal("2wy5w")

                    local text = { "first", "second", "third" }
                    selection.set_text(0, "motion", text)

                    expect({
                        "a sentence first",
                        "second",
                        'thirdis" a test',
                    })
                end)
            end)
        end)
    end)
end)
