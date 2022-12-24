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
function _decipher_encode_motion(codec_name, decipher)
    -- If we did not receive a motion type, it is a codec name and we set up
    -- the operatorfunc for the g@ motion operator. Otherwise, the user
    -- completed the motion operator and we call decipher.encode_motion
    if not is_motion_type(codec_name) then
        vim.b._decipher_motion_codec_name = codec_name

        -- vim.go.operatorfunc = v:lua.require("decipher.mappings")._decipher_encode_motion
        vim.api.nvim_feedkeys("g@", "n", false)
    else
        decipher.encode_motion(vim.b._decipher_motion_codec_name, decipher)
        vim.b._decipher_motion_codec_name = nil
    end
end

function M.setup(decipher)
    local keymap = vim.keymap
    local map_options = { silent = true, noremap = true }
    local motion_map_options = { silent = true, expr = true, noremap = true }

    -- Prompt mappings
    keymap.set("v", "<Plug>(DecipherEncodePrompt)", decipher.encode_selection_prompt, map_options)
    keymap.set("v", "<Plug>(DecipherDecodePrompt)", decipher.decode_selection_prompt, map_options)

    for _, codec in ipairs(decipher.codecs()) do
        local codec_name = util.title_case(codec)

        -- Visual selections
        keymap.set(
            "v",
            string.format("<Plug>(DecipherEncode%s)", codec_name),
            function() decipher.encode_selection(codec) end,
            map_options
        )
        keymap.set(
            "v",
            string.format("<Plug>(DecipherDecode%s)", codec_name),
            function() decipher.decode_selection(codec) end,
            map_options
        )

        -- Motions
        keymap.set(
            "n",
            string.format("<Plug>(DecipherEncode%sMotion)", codec_name),
            function() _decipher_encode_motion(codec, decipher) end,
            motion_map_options
        )
        keymap.set(
            "n",
            string.format("<Plug>(DecipherDecode%sMotion)", codec_name),
            function() _decipher_decode_motion(codec) end,
            motion_map_options
        )

        -- Previews
        keymap.set(
            "v",
            string.format("<Plug>(DecipherPreview%s)", codec_name),
            function() decipher.decode_preview_selection(codec) end,
            map_options
        )
    end
end

return M
