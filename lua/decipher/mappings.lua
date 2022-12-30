local util = require("decipher.util")

local M = {}

--- If the type describes a motion or not
---@param type string
---@return boolean
local function is_motion_type(type)
    return type == "block" or type == "char" or type == "line"
end

--- Operator function for encode/decoding motions
---@param codec_name either the name of the codec to use or the type of motion
---                  performed by the user
---@param decipher A reference to the decipher main module
function _decipher_motion(motion, codec_name, motion_func)
    -- If we did not receive a motion type, it is a codec name and we set up
    -- the operatorfunc for the g@ motion operator. Otherwise, the user
    -- completed the motion operator and we call decipher.encode_motion
    if not is_motion_type(motion) then
        local old_operatorfunc = vim.go.operatorfunc

        -- Use a global function for the operatorfunc until the global option
        -- supports accepting a lua function: https://github.com/neovim/neovim/issues/14157
        _G._decipher_operatorfunc = function(motion)
            -- Restore the old operatorfunc and remove the global function
            vim.go.operatorfunc = old_operatorfunc
            _G._decipher_operatorfunc = nil

            _decipher_motion(motion, codec_name, motion_func)
        end

        vim.go.operatorfunc = "v:lua._decipher_operatorfunc"
        vim.api.nvim_feedkeys("g@", "n", false)
    else
        motion_func(codec_name)
    end
end

local function make_plug_mapping(mode, name, func, options)
    local options = vim.tbl_extend("force", { silent = true, noremap = true }, options or {})

    vim.keymap.set(mode, "<Plug>(" .. name .. ")", func, options)
end

function M.setup(decipher)
    -- Visual selection prompt mappings
    make_plug_mapping("v", "DecipherEncodePrompt", decipher.encode_selection_prompt)
    make_plug_mapping("v", "DecipherDecodePrompt", decipher.decode_selection_prompt)

    for _, codec in ipairs(decipher.codecs()) do
        local plug_encode_name = "DecipherEncode" .. codec_name
        local plug_decode_name = "DecipherDecode" .. codec_name
        local codec_name = util.title_case(codec)

        -- Visual selections
        make_plug_mapping("v", plug_encode_name, function()
            decipher.encode_selection(codec)
        end)

        make_plug_mapping("v", plug_decode_name, function()
            decipher.decode_selection(codec)
        end)

        -- Motions
        make_plug_mapping("n", plug_encode_name .. "Motion", function()
            _decipher_motion(nil, codec, decipher.encode_motion)
        end, { expr = true })

        make_plug_mapping("n", plug_decode_name .. "Motion", function()
            _decipher_motion(nil, codec, decipher.decode_motion)
        end, { expr = true })

        -- Previews
        make_plug_mapping("v", plug_decode_name .. "Preview", function()
            decipher.decode_preview_selection(codec)
        end)
    end
end

return M
