local decipher = require("decipher")
local config = require("decipher.config")
local vader = require("decipher.util.vader")
local ui = require("decipher.ui")

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
        return ui.float.open({
            title = title,
            contents = contents,
            selection_type = "visual",
            selection = region,
            codec_name = "base64",
            codec_type = "decode",
        })
    end

    it("opens a float", function()
        given(buffer_contents, function(context)
            local _float = create_float("title", { "contents" })

            assert(_float ~= nil, "Float was nil")

            local window_config = vim.api.nvim_win_get_config(_float.win_id)

            assert.are._not.same(_float.buffer, vim.api.nvim_win_get_buf(0))
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

    it("immediately enters a float if configured", function()
        given(buffer_contents, function(context)
            config.setup({ float = { enter = true } })

            local _float = create_float("title", { "contents" })

            assert(_float ~= nil, "Float was nil")
            assert.are.same(_float.buffer, vim.api.nvim_win_get_buf(0))

            ui.float.close(context.win_id)
        end)
    end)

    it("enters a float if already opened", function()
        given(buffer_contents, function(context)
            local float1 = create_float("title", { "contents" })

            assert(float1 ~= nil, "Float was nil")
            assert.are.same(vim.api.nvim_win_get_buf(0), context.bufnr)

            local float2 = create_float("title", { "contents" })
            assert(float2 ~= nil, "Float was nil")
            assert.are.same(float1, float2)

            ui.float.close(context.win_id)
        end)
    end)

    it("provides configurable, overriable key mappings", function()
        given(buffer_contents, function(context)
            config.setup({
                float = {
                    enter = true,
                    mappings = {
                        apply = "A",
                        help = "g?",
                    },
                },
            })

            local _float = create_float("title", { "contents" })

            assert.is_not_nil(_float)
            assert.are.same(_float.buffer, vim.api.nvim_win_get_buf(0))
            assert.are._not.same(vim.fn.maparg("q", "n"), "")
            assert.are._not.same(vim.fn.maparg("A", "n"), "")
            assert.are.same(vim.fn.maparg("<leader>a", "n"), "")
            assert.are._not.same(vim.fn.maparg("<leader>j", "n"), "")
            assert.are._not.same(vim.fn.maparg("g?", "n"), "")
            assert.are.same(vim.fn.maparg("?g", "n"), "")

            ui.float.close(context.win_id)
        end)
    end)

    it("closes window using mapping", function()
        given(buffer_contents, function(context)
            config.setup({ float = { enter = true } })

            local _float = create_float("title", { "contents" })

            assert.is_not_nil(_float)
            assert.are.same(_float.buffer, vim.api.nvim_win_get_buf(0))

            normal("q")
            assert.are._not.same(_float.buffer, vim.api.nvim_win_get_buf(0))

            ui.float.close(context.win_id)
        end)
    end)

    it("switches to help page and back", function()
        given(buffer_contents, function(context)
            config.setup({ float = { enter = true } })

            local _float = create_float("title", { "contents" })

            assert.is_not_nil(_float)

            assert.are.same(_float.buffer, vim.api.nvim_win_get_buf(0))
            normal("g?")

            expect({
                "q - Close the floating window",
                "<leader>a - Apply the encoding/decoding of the original selection ignoring any changes made in the floating window",
                "<leader>u - Update the value in the orignal buffer with any changes made in the floating window",
                "<leader>j - Prettily format contents as an immutable json view",
                "g? - Toggle this help",
            }, _float.buffer)

            normal("g?")
            expect({ "contents" }, _float.buffer)

            ui.float.close(context.win_id)
        end)
    end)

    it("applies codec", function()
        given(buffer_contents, function(context)
            config.setup({ float = { enter = true } })

            normal("viW<esc>")
            decipher.decode_selection("base64", { preview = true })
            expect({ "light work" })

            normal("<leader>a")
            expect({ "light work" })

            ui.float.close(context.win_id)
        end)
    end)
end)
