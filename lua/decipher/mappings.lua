local util = require("decipher.util")

local M = {}

--- If the type describes a motion or not
---@param type string | nil
---@return boolean
local function is_motion_type(type)
    return type == "block" or type == "char" or type == "line"
end

--- Operator function for encode/decoding motions
---@param motion string | nil either the type of motion or nil for the initial call
---@param codec_name string either the name of the codec to use or the type of motion
---                         performed by the user
---@param motion_func function the motion function to call when the motion is completed
local function _decipher_motion(motion, codec_name, motion_func)
    -- If we did not receive a motion type, it is a codec name and we set up
    -- the operatorfunc for the g@ motion operator. Otherwise, the user
    -- completed the motion operator and we call decipher.encode_motion
    if not is_motion_type(motion) then
        local old_operatorfunc = vim.go.operatorfunc

        -- Use a global function for the operatorfunc until the global option
        -- supports accepting a lua function: https://github.com/neovim/neovim/issues/14157
        _G._decipher_operatorfunc = function(_motion)
            -- Restore the old operatorfunc and remove the global function
            vim.go.operatorfunc = old_operatorfunc
            _G._decipher_operatorfunc = nil

            _decipher_motion(_motion, codec_name, motion_func)
        end

        vim.go.operatorfunc = "v:lua._decipher_operatorfunc"
        vim.api.nvim_feedkeys("g@", "n", false)
    else
        motion_func(codec_name)
    end
end

local function make_plug_mapping(mode, name, func, options)
    local merged_options = vim.tbl_extend("force", { silent = true, noremap = true }, options or {})

    vim.keymap.set(mode, "<Plug>(" .. name .. ")", func, merged_options)
end

function M.setup(decipher)
    -- Visual selection prompt
    make_plug_mapping("v", "DecipherEncodePrompt", decipher.encode_selection_prompt)
    make_plug_mapping("v", "DecipherDecodePrompt", decipher.decode_selection_prompt)

    -- Visual selection prompt with preview
    make_plug_mapping(
        "v",
        "DecipherEncodePrompt",
        function()
            decipher.encode_selection_prompt({ preview = true })
        end
    )

    make_plug_mapping(
        "v",
        "DecipherDecodePrompt",
        function()
            decipher.decode_selection_prompt({ preview = true })
        end
    )

    -- Motions with prompt
    make_plug_mapping("n", "DecipherEncodeMotionPrompt", decipher.encode_motion_prompt)
    make_plug_mapping("n", "DecipherDecodeMotionPrompt", decipher.decode_motion_prompt)

    -- Motions with prompt and preview
    make_plug_mapping(
        "n",
        "DecipherEncodeMotionPromptPreview",
        function()
            decipher.encode_motion_prompt({ preview = true })
        end
    )

    make_plug_mapping(
        "n",
        "DecipherDecodeMotionPromptPreview",
        function()
            decipher.decode_motion_prompt({ preview = true })
        end
    )

    local function with_preview(func)
        return function(codec_name)
            func(codec_name, { preview = true })
        end
    end

    -- Dynamically create all <Plug> mappings
    for _, codec in ipairs(decipher.codecs()) do
        local codec_name = util.title_case(codec)
        local plug_encode_name = "DecipherEncode" .. codec_name
        local plug_decode_name = "DecipherDecode" .. codec_name

        -- Visual selections
        make_plug_mapping("v", plug_encode_name, function()
            decipher.encode_selection(codec)
        end)

        make_plug_mapping("v", plug_decode_name, function()
            decipher.decode_selection(codec)
        end)

        -- Visual selections with preview
        make_plug_mapping(
            "v",
            plug_encode_name .. "Preview",
            with_preview(decipher.encode_selection)
        )

        make_plug_mapping(
            "v",
            plug_decode_name .. "Preview",
            with_preview(decipher.decode_selection)
        )

        -- Motions
        make_plug_mapping("n", plug_encode_name .. "Motion", function()
            _decipher_motion(nil, codec, decipher.encode_motion)
        end, { expr = true })

        make_plug_mapping("n", plug_decode_name .. "Motion", function()
            _decipher_motion(nil, codec, decipher.decode_motion)
        end, { expr = true })

        -- Motions with preview
        make_plug_mapping("n", plug_encode_name .. "MotionPreview", function()
            _decipher_motion(nil, codec, with_preview(decipher.encode_motion))
        end, { expr = true })

        make_plug_mapping("n", plug_decode_name .. "MotionPreview", function()
            _decipher_motion(nil, codec, with_preview(decipher.decode_motion))
        end, { expr = true })
    end
end

return M
