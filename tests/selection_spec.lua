local selection = require("decipher.selection")
local vader = require("decipher.util.vader")

local given, normal, expect = vader.given, vader.normal, vader.expect

-- TODO:
--  * Test selection with currently selected visual mode
--  * Test selection vim options (test 'old')
--  * Test selection when still in visual mode

describe("selection", function()
    after_each(function()
        -- It seems like the 'selection' option is set globally
        vim.opt_local.selection = "inclusive"
    end)

    describe("visual", function()
        local contents = { "line 1", "line 2" }

        local xs = {
            "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
            "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
            "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
            "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
            "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        }

        describe("get_selection", function()
            it("gets region in line-wise visual mode", function()
                pending("Skipped")

                -- given(contents, function()
                --     normal("Vj")

                --     local region = selection.get_selection("visual")
                --     vim.pretty_print(region)

                --     -- TODO: Convert every assert to use same
                --     assert.are.same(region.start.lnum, 1)
                --     assert.are.same(region.start.col, 1)
                --     assert.are.same(region["end"].lnum, 2)
                --     assert.are.same(region["end"].col, 6)
                -- end)
            end)

            it("gets region in character-wise visual mode", function()
                given(contents, function()
                    normal("veej")

                    local region = selection.get_selection("visual")

                    assert.are.same(region, {
                        start = { lnum = 1, col = 1 },
                        ["end"] = { lnum = 2, col = 6 },
                    })
                end)
            end)

            it("gets region in block-wise visual mode", function()
                pending("Skipped")

                -- given(contents, function()
                --     normal("2|<c-v>je")

                --     local region = selection.get_selection("visual")

                --     assert.are.same(region, {
                --         start = { lnum = 1, col = 1 },
                --         ["end"] = { lnum = 2, col = 4 },
                --     })
                -- end)
            end)

            it("gets region after line-wise visual mode", function()
                given(contents, function()
                    normal("$jVk0<c-c>")

                    local region = selection.get_selection("visual")

                    assert.are.same(region.start.lnum, 1)
                    assert.are.same(region.start.col, 1)
                    assert.are.same(region["end"].lnum, 2)
                end)
            end)

            it("gets region after line-wise visual mode selecting backwards", function()
                given(contents, function()
                    normal("$jVk0<c-c>")

                    local region = selection.get_selection("visual")

                    assert.are.same(region.start.lnum, 1)
                    assert.are.same(region.start.col, 1)
                    assert.are.same(region["end"].lnum, 2)
                end)
            end)

            it("gets region after character-wise visual mode", function()
                given(contents, function()
                    normal("3|vjll<c-c>")

                    local region = selection.get_selection("visual")

                    assert.are.same(region, {
                        start = { lnum = 1, col = 3 },
                        ["end"] = { lnum = 2, col = 5 },
                    })
                end)
            end)

            it("gets region after character-wise visual mode selecting backwards", function()
                given(contents, function()
                    normal("5|jvk2h<c-c>")

                    local region = selection.get_selection("visual")

                    assert.are.same(region, {
                        start = { lnum = 1, col = 3 },
                        ["end"] = { lnum = 2, col = 5 },
                    })
                end)
            end)

            it("gets region after block-wise visual mode", function()
                given(contents, function()
                    normal("2|<c-v>je<c-c>")

                    local region = selection.get_selection("visual")

                    assert.are.same(region, {
                        start = { lnum = 1, col = 2 },
                        ["end"] = { lnum = 2, col = 4 },
                    })
                end)
            end)

            it("gets region after block-wise visual mode selecting backwards", function()
                given(contents, function()
                    normal("4|<c-v>j2h<c-c>")

                    local region = selection.get_selection("visual")

                    assert.are.same(region, {
                        start = { lnum = 1, col = 4 },
                        ["end"] = { lnum = 2, col = 2 },
                    })
                end)
            end)
        end)

        describe("get_text", function()
            it("gets text after line-wise visual mode", function()
                given(contents, function()
                    normal("Vj<c-c>")

                    local text = selection.get_text(0, "visual")

                    assert.are.same(text, { "line 1", "line 2" })
                end)
            end)

            it("gets text after line-wise visual mode selecting backwards", function()
                given(contents, function()
                    normal("$jVk0<c-c>")

                    local text = selection.get_text(0, "visual")

                    assert.are.same(text, { "line 1", "line 2" })
                end)
            end)

            it("gets text after character-wise visual mode with selection option == 'inclusive'", function()
                given(contents, function()
                    vim.opt_local.selection = "inclusive"

                    normal("3|vjll<c-c>")

                    local text = selection.get_text(0, "visual")

                    assert.are.same(text, { "ne 1", "line " })
                end)
            end)

            it("gets text after character-wise visual mode with selection option == 'exclusive'", function()
                given(contents, function()
                    vim.opt_local.selection = "exclusive"

                    normal("3|vjll<c-c>")

                    local text = selection.get_text(0, "visual")

                    assert.are.same(text, { "ne 1", "line" })
                end)
            end)

            it(
                "gets text after character-wise visual mode selecting backwards with selection option == 'inclusive'",
                function()
                    given(contents, function()
                        vim.opt_local.selection = "inclusive"
                        normal("5|jvk2h<c-c>")

                        local text = selection.get_text(0, "visual")

                        assert.are.same(text, { "ne 1", "line " })
                    end)
                end
            )

            it(
                "gets text after character-wise visual mode selecting backwards with selection option == 'exclusive'",
                function()
                    given(contents, function()
                        vim.opt_local.selection = "exclusive"
                        normal("5|jvk2h<c-c>")

                        local text = selection.get_text(0, "visual")

                        assert.are.same(text, { "ne 1", "line" })
                    end)
                end
            )

            it("gets text after block-wise visual mode", function()
                given(contents, function()
                    normal("2|<c-v>je<c-c>")

                    local text = selection.get_text(0, "visual")

                    assert.are.same(text, { "ine", "ine" })
                end)
            end)

            it("gets text after block-wise visual mode selecting backwards", function()
                given(contents, function()
                    normal("4|<c-v>j2h<c-c>")

                    local text = selection.get_text(0, "visual")

                    assert.are.same(text, { "ine", "ine" })
                end)
            end)
        end)

        describe("set_text", function()
            it("sets text after line-wise visual mode", function()
                given(xs, function()
                    normal("2jVj<c-c>")

                    selection.set_text(0, "visual", { "1st line", "2nd line" })

                    expect({
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "1st line",
                        "2nd line",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    })
                end)
            end)

            it("sets text after backwards line-wise visual mode", function()
                given(xs, function()
                    normal("3j$Vk0<c-c>")

                    selection.set_text(0, "visual", { "1st line", "2nd line" })

                    expect({
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "1st line",
                        "2nd line",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    })
                end)
            end)

            it("sets text after character-wise visual mode", function()
                given(xs, function()
                    normal("j15lvj6l<c-c>")

                    selection.set_text(0, "visual", { "replacement" })

                    expect({
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXreplacementXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    })
                end)
            end)

            it("sets text after backwards character-wise visual mode", function()
                given(xs, function()
                    normal("2j21lvk6h<c-c>")

                    selection.set_text(0, "visual", { "replacement" })

                    expect({
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXreplacementXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    })
                end)
            end)

            it("sets text after block-wise visual mode", function()
                given(xs, function()
                    normal("j8l<c-v>6ljj<c-c>")

                    selection.set_text(0, "visual", { "first", "second", "third" })

                    expect({
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXfirstXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXsecondXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXthirdXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    })
                end)
            end)

            it("sets text after block-wise visual mode with underflow lines", function()
                given(xs, function()
                    normal("j8l<c-v>6ljj<c-c>")

                    selection.set_text(0, "visual", { "first", "second" })

                    expect({
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXfirstXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXsecondXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    })
                end)
            end)

            it("sets text after block-wise visual mode with overflow lines", function()
                given(xs, function()
                    normal("j8l<c-v>6ljj<c-c>")

                    selection.set_text(0, "visual", { "first", "second", "third", "fourth" })

                    expect({
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXfirstXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXsecondXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXthirdXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                        "XXXXXXXXfourthXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    })
                end)
            end)
        end)
    end)

    describe("motion", function()
        local contents = { "a sentence on the first line", 'this "is" a test' }

        describe("get_selection", function()
            it("gets region after motion (inner double-quoted string)", function()
                pending("Skipped")

                -- given(contents, function()
                --     normal('jwyi"')

                --     local region = selection.get_selection("motion")

                --     assert.are.same(region, {
                --         start = { lnum = 2, col = 7 },
                --         ["end"] = { lnum = 2, col = 8 },
                --     })
                -- end)
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
