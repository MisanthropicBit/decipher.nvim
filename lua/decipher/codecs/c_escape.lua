local escape = {}

-- All credit for these functions go to vim-unimpaired by tpope which have been ported to lua

vim.g._decipher_escape_encoding_map = {
    ["\n"] = "n",
    ["\r"] = "r",
    ["\t"] = "t",
    ["\b"] = "b",
    ["\f"] = "f",
    ['"'] = '"',
    ["\\"] = "\\",
}

vim.g._decipher_escape_decoding_map = {
    n = "\n",
    r = "\r",
    t = "\t",
    b = "\b",
    f = "\f",
    e = [[\e]],
    a = "\001",
    v = "\013",
    ["\n"] = "",
}

function escape.encode(value)
    if value == nil then
        error("Cannot encode nil value", 0)
    end

    -- Matches an octal number range (0-27) which are escape sequences in the
    -- ascii table, backslashes, or a double-quote. Then looks up the match
    -- in an encoding table and otherwise default to printing the octal
    -- encoding of the match
    return vim.fn.substitute(
        value,
        '[\1-\27\\\\"]',
        [[\="\\".get(g:_decipher_escape_encoding_map,submatch(0),printf("%03o",char2nr(submatch(0))))]],
        "g"
    )
end

function escape.decode(value)
    if value == nil then
        error("Cannot decode nil value", 0)
    end

    local decoded = value

    -- Matches a double-quoted string with some text followed by an odd number
    -- of backslashes (which would escape the next character), barring starting
    -- and ending whitespace and a newline at the end (\= matches 0 or 1 of the
    -- preceding atom, as many as possible)
    if not vim.fn.match(decoded, [[^\s*".\{-\}\\\@<!\%(\\\\\)*"\s*\n\=$]]) then
        -- Strip the starting double-quote
        decoded = vim.fn.substitute(decoded, [[^\s*\zs"]], "", "")
        -- Strip the ending double-quote
        decoded = vim.fn.substitute(decoded, [["\ze\s*\n\=$]], "", "")
    end

    -- Matches a 1-3 digit octal number, a 1-2 digit hexadecimal number, a 1-4
    -- digit hexadecimal number prefixed by a 'u', or any character. If the
    -- match matches a squences of number, 'u' and 'x', replaces any prefixed
    -- 'U' or 'u' (unicode codepoints), then transforms it to a character.
    -- Otherwise uses the raw match. Then it looks it up in a decoding table
    return vim.fn.substitute(
        decoded,
        [[\\\(\o\{1,3\}\|x\x\{1,2\}\|u\x\{1,4\}\|.\)]],
        [[\=get(g:_decipher_escape_decoding_map,submatch(1),submatch(1) =~? "^[0-9xu]" ? nr2char("0".substitute(submatch(1),"^[Uu]","x","")) : submatch(1))]],
        "g"
    )
end

return escape
