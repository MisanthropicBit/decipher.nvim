local util = {}

function util.escape_newlines(text)
    local sub, _ = text:gsub("\n", [[\n]])

    return sub
end

return util
