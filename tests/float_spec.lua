local decipher = require("decipher")
local config = require("decipher.config")
local vader = require("decipher.util.vader")
local ui = require("decipher.ui")
local match = require("luassert.match")
local stub = require("luassert.stub")

local given, normal, expect = vader.given, vader.normal, vader.expect

describe("ui.float", function()
    local buffer_contents = { "bGlnaHQgd29yaw==" }

    local region = {
        start = { lnum = 0, col = 0 },
        ["end"] = { lnum = 0, col = 0 },
    }

    before_each(function()
        -- Set the default config for testing so the tests are not using my own setup
        config.setup(config._default_config())
    end)

    local function create_float(title, contents)
        local _float = ui.float.open({
            title = title,
            contents = contents,
            selection_type = "visual",
            selection = region,
            codec_name = "base64",
            codec_type = "decode",
        })

        assert(_float ~= nil, "Float was nil")
        assert.are.same(vim.api.nvim_win_get_var(_float.win_id, "decipher_float"), true)

        return _float
    end

    it("creates a float", function()
        local _float = ui.float.open({
            title = "title",
            contents = { "contents" },
            selection_type = "visual",
            selection = region,
            codec_name = "base64",
            codec_type = "decode",
        })

        assert(_float ~= nil, "Float was nil")
        assert.are_not.same(_float.buffer, vim.api.nvim_win_get_buf(0))
        assert.are.same(vim.api.nvim_win_get_var(_float.win_id, "decipher_float"), true)

        local window_config = vim.api.nvim_win_get_config(_float.win_id)

        assert.are_not.same(_float.buffer, vim.api.nvim_win_get_buf(0))
        assert.are.same(vim.api.nvim_win_get_var(_float.win_id, "decipher_float"), true)

        if vim.fn.has("nvim-0.9") == 1 then
            assert.are.same(window_config.title[1][1], " title ")
            assert.are.same(window_config.title_pos, "left")
        end

        assert.are.same(window_config.width, 8)
        assert.are.same(window_config.height, 1)
        assert.are.same(window_config.focusable, true)
        assert.are.same(window_config.relative, "editor")
    end)

    it("opens a float", function()
        given("", function(context)
            local _float = create_float("title", { "contents" })

            local window_config = vim.api.nvim_win_get_config(_float.win_id)

            assert.are.same(vim.api.nvim_win_get_var(_float.win_id, "decipher_float"), true)
            if vim.fn.has("nvim-0.9") == 1 then
                assert.are.same(window_config.title[1][1], " title ")
                assert.are.same(window_config.title_pos, "left")
            end

            assert.are.same(window_config.width, 8)
            assert.are.same(window_config.height, 1)
            assert.are.same(window_config.focusable, true)
            assert.are.same(window_config.relative, "editor")

            expect({ "contents" }, _float.buffer)

            ui.float.close(context.win_id)
        end)
    end)

    -- NOTE: Cannot trigger a CursorMoved event
    -- it("autocloses floating window when cursor is moved", function()
    --     given(buffer_contents, function(context)
    --         config.setup({ float = { enter = false } })
    --         local _float = create_float("title", { "contents" })

    --         assert(_float ~= nil, "Float was nil")

    --         -- assert(vim.fn.bufexists(_float.buffer))
    --         -- assert(vim.api.nvim_win_is_valid(_float.win_id))
    --         vim.cmd([[doautocmd CursorMoved]])
    --         -- assert(not vim.fn.bufexists(_float.buffer))
    --         vim.print(_float.win_id)
    --         assert(not vim.api.nvim_win_is_valid(_float.win_id))
    --         assert.are.same(vim.api.nvim_win_get_buf(0), context.bufnr)

    --         float.close(context.win_id)
    --     end)
    -- end)

    -- it("autocloses floating window when insert mode is entered", function()
    --     given(buffer_contents, function(context)
    --         local _float = create_float("title", { "contents" })

    --         assert(_float ~= nil, "Float was nil")
    --         vim.cmd([[doautocmd InsertEnter]])
    --         vim.print(vim.api.nvim_win_get_buf(0), context.bufnr, _float.buffer)
    --         assert.are.same(vim.api.nvim_win_get_buf(0), context.bufnr)

    --         float.close(context.win_id)
    --     end)
    -- end)

    it("enters a float if already opened", function()
        given("", function(context)
            local float1 = create_float("title", { "contents" })

            assert.are.same(vim.api.nvim_win_get_buf(0), context.bufnr)

            local float2 = create_float("title", { "contents" })
            assert.are.same(float1, float2)

            ui.float.close(context.win_id)
        end)
    end)

    it("provides configurable, overriable key mappings", function()
        given("", function(context)
            config.setup({
                ---@diagnostic disable-next-line: missing-fields
                float = {
                    enter = true,
                    mappings = {
                        apply = "A",
                        help = "?g",
                    },
                },
            })

            local _float = create_float("title", { "contents" })

            assert.is_not_nil(_float)
            assert.are.same(_float.buffer, vim.api.nvim_win_get_buf(0))
            assert.are_not.same(vim.fn.maparg("q", "n"), "")
            assert.are_not.same(vim.fn.maparg("A", "n"), "")
            assert.are.same(vim.fn.maparg("<leader>a", "n"), "")
            assert.are_not.same(vim.fn.maparg("<leader>j", "n"), "")
            assert.are.same(vim.fn.maparg("g?", "n"), "")
            assert.are_not.same(vim.fn.maparg("?g", "n"), "")

            ui.float.close(context.win_id)
        end)
    end)

    it("closes window using mapping", function()
        given("", function(context)
            ---@diagnostic disable-next-line: missing-fields
            config.setup({ float = { enter = true } })

            local _float = create_float("title", { "contents" })

            assert.is_not_nil(_float)
            assert.are.same(_float.buffer, vim.api.nvim_win_get_buf(0))

            normal("q")
            assert.are_not.same(_float.buffer, vim.api.nvim_win_get_buf(0))

            ui.float.close(context.win_id)
        end)
    end)

    it("switches to help page and back", function()
        given("", function(context)
            ---@diagnostic disable-next-line: missing-fields
            config.setup({ float = { enter = true } })

            local _float = create_float("title", { "contents" })

            assert.is_not_nil(_float)

            assert.are.same(_float.buffer, vim.api.nvim_win_get_buf(0))
            normal("g?")

            expect({
                "q          Close the preview",
                "<leader>a  Apply the preview to the selection including any changes",
                "<leader>u  Update selection with preview",
                "<leader>j  View preview as immutable json",
                "g?         Toggle this help",
            }, _float.buffer)

            normal("g?")
            expect({ "contents" }, _float.buffer)

            ui.float.close(context.win_id)
        end)
    end)

    it("applies codec", function()
        given(buffer_contents, function(context)
            ---@diagnostic disable-next-line: missing-fields
            config.setup({ float = { enter = true } })

            normal("viW<esc>")
            decipher.decode_selection("base64", { preview = true })
            expect({ "light work" })

            normal("1 a")
            expect({ "light work" })

            ui.float.close(context.win_id)
        end)
    end)

    it("applies preview with changes", function()
        given({ "ewogICJhIjogMQp9" }, function(context)
            ---@diagnostic disable-next-line: missing-fields
            config.setup({ float = { enter = true } })

            normal("V")
            decipher.decode_selection("base64", { preview = true })

            expect({ "{", '  "a": 1', "}" }, vim.api.nvim_get_current_buf())

            -- Add a ("b", 2) key-value pair
            normal('2ggA,<cr>"b": 2')

            -- Apply decoded preview
            normal("1 a")

            -- Original buffer
            expect({ "{", '  "a": 1,', '  "b": 2', "}" }, vim.api.nvim_get_current_buf())

            ui.float.close(context.win_id)
        end)
    end)

    it("updates original buffer with preview", function()
        given({ "ewogICJhIjogMQp9" }, function(context)
            ---@diagnostic disable-next-line: missing-fields
            config.setup({ float = { enter = true, mappings = { update = "u" } } })

            normal("V")
            decipher.decode_selection("base64", { preview = true })

            expect({ "{", '  "a": 1', "}" }, vim.api.nvim_get_current_buf())

            -- Add a ("b", 2) key-value pair
            normal('2ggA,<cr>"b": 2')

            -- Update original buffer with change
            -- NOTE: This does not work with the default leader keymap although
            -- it works when applying. An 'undo' is done instead
            normal("u")

            -- Original buffer
            expect({ "ewogICJhIjogMSwKICAiYiI6IDIKfQ==" }, vim.api.nvim_get_current_buf())
        end)
    end)

    it("fails to switch to json view if json is malformed", function()
        given({ "eyJhIjogMX0=" }, function(context)
            ---@diagnostic disable-next-line: missing-fields
            config.setup({ float = { enter = true, mappings = { json = "j" } } })

            stub(vim, "notify")

            normal("V")
            decipher.decode_selection("base64", { preview = true })

            expect({ '{"a": 1}' }, vim.api.nvim_get_current_buf())

            -- Delete the first double-quote
            normal('f"x')

            -- Try to view as json
            -- NOTE: This does not work with the default leader keymap although
            -- it works when applying
            normal("j")

            assert
                ---@diagnostic disable-next-line: param-type-mismatch
                .stub(vim.notify)
                ---@diagnostic disable-next-line: undefined-field
                .was_called_with(match.has_match("Cannot decode as json: "), vim.log.levels.ERROR, { title = "decipher.nvim" })

            ---@diagnostic disable-next-line: undefined-field
            vim.notify:revert()
        end)
    end)
end)
