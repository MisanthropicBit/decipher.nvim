local visual = {}

local marks = require("decipher.marks")

---@return Region
function visual.get_selection()
    return marks.get_mark_positions("visual")
end

return visual
