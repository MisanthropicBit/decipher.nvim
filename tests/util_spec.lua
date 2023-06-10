local util = require("decipher.util")

describe("util", function()
    describe("escape_newlines", function()
        it("escapes newlines", function()
            assert.are.same(util.str.escape_newlines({ "" }), { "" })
            assert.are.same(util.str.escape_newlines({ "no newlines" }), { "no newlines" })
            assert.are.same(util.str.escape_newlines({ "two\nnewlines\n" }), { "two\\nnewlines\\n" })

            local lines = { "two\nnewlines\n", "no newlines" }

            assert.are.same(util.str.escape_newlines(lines), { "two\\nnewlines\\n", "no newlines" })
        end)
    end)

    describe("json", function()
        it("formats nil values", function()
            assert.are.same(util.json.pretty_print(nil), "null")
        end)

        it("formats booleans", function()
            assert.are.same(util.json.pretty_print(true), "true")
            assert.are.same(util.json.pretty_print(false), "false")
        end)

        it("formats strings", function()
            assert.are.same(util.json.pretty_print("hello"), '"hello"')
            assert.are.same(util.json.pretty_print('\b\fw\ao\t\nr"\rl\vd\\'), [["\b\fw\ao\t\nr\"\rl\vd\\"]])
        end)

        it("formats numbers", function()
            assert.are.same(util.json.pretty_print(174.483), "174.483")
            assert.are.same(util.json.pretty_print(-3289), "-3289")
        end)

        it("formats arrays", function()
            assert.are.same(util.json.pretty_print({}), "{}")
            assert.are.same(
                util.json.pretty_print({ 1, 2, 3 }),
                [=[[
  1,
  2,
  3
]]=]
            )

            -- With different indent
            assert.are.same(
                util.json.pretty_print({ 1, 2, 3 }, { indent = 4 }),
                [=[[
    1,
    2,
    3
]]=]
            )
        end)

        it("formats tables", function()
            local test = {
                msg = "hello",
                level = 1,
                values = { 1, 2, 3 },
                hide = true,
            }

            local result = util.json.pretty_print(test, { sort_keys = true })

            assert.are.same(
                result,
                [[{
  "hide": true,
  "level": 1,
  "msg": "hello",
  "values": [
    1,
    2,
    3
  ]
}]]
            )
        end)

        it("formats tables with more than one level", function()
            local test = {
                msg = "hello",
                levels = {
                    b = 2,
                    c = 3,
                    a = 1,
                },
                values = { 1, 2, 3 },
                hide = true,
            }

            local result = util.json.pretty_print(test, { sort_keys = true })

            assert.are.same(
                result,
                [[{
  "hide": true,
  "levels": {
    "a": 1,
    "b": 2,
    "c": 3
  },
  "msg": "hello",
  "values": [
    1,
    2,
    3
  ]
}]]
            )
        end)

        it("handles unsupported types", function()
            assert.has_error(function()
                util.json.pretty_print(function() end)
            end, "Cannot format value of type 'function'")

            assert.has_error(function()
                util.json.pretty_print(coroutine.create(function() end))
            end, "Cannot format value of type 'thread'")
        end)
    end)
end)
