local motion = {}

local marks = require("decipher.marks")

--- If the type describes a motion or not
---@param type string | nil
---@return boolean
local function is_motion_type(type)
    return type == "block" or type == "char" or type == "line"
end

--- Operator function for encode/decoding motions
---@param maybe_motion string | nil either the type of motion or nil for the initial call
---@param handler function the motion function to call when the motion is completed
local function _decipher_motion(maybe_motion, handler)
    -- If we did not receive a motion type, it is a codec name and we set up
    -- the operatorfunc for the g@ motion operator. Otherwise, the user
    -- completed the motion operator and we call decipher.encode_motion
    if not is_motion_type(maybe_motion) then
        local old_operatorfunc = vim.go.operatorfunc

        -- Use a global function for the operatorfunc until the global option
        -- supports accepting a lua function: https://github.com/neovim/neovim/issues/14157
        _G._decipher_operatorfunc = function(_motion)
            -- Restore the old operatorfunc and remove the global function
            vim.go.operatorfunc = old_operatorfunc
            _G._decipher_operatorfunc = nil

            _decipher_motion(_motion, handler)
        end

        vim.go.operatorfunc = "v:lua._decipher_operatorfunc"
        vim.api.nvim_feedkeys("g@", "n", false)
    else
        handler()
    end
end

---@return Region
function motion.get_motion()
    return marks.get_mark_positions("motion")
end

---@param handler fun(): nil
function motion.start_motion(handler)
    _decipher_motion(nil, handler)
end

return motion
