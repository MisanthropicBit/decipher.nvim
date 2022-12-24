local util = {}

function util.escape_newlines(text)
    local sub, _ = text:gsub("\n", [[\n]])

    return sub
end

local function _title_case(text)
    return text:sub(1, 1):upper() .. text:sub(2, #text):lower()
end

function util.title_case(text)
    local result = {}

    for part in text:gmatch("[^-]+") do
        table.insert(result, _title_case(part))
    end

    return table.concat(result, "")
end

return util
