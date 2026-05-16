---@alias decipher.CommandPreviewFunc fun(
---options: vim.api.keyset.create_user_command.command_args,
---ns_id: integer,
---preview_buffer: integer): integer

---@type string[]?
local command_arguments

---@param arg_lead   string
---@param cmdline    string
---@param cursor_pos integer
---@return string[]
local function command_complete(arg_lead, cmdline, cursor_pos)
    if not command_arguments then
        command_arguments = vim.list_extend({ "preview=true", "preview=false" }, require("decipher").supported_codecs())
    end

    return command_arguments
end

---@param args string
---@return string[], string[], string[], string[]
local function parse_command_args(args)
    local decipher = require("decipher")
    local codecs, options, unrecognised_args, errors = {}, {}, {}, {}
    local supported_codecs = decipher.supported_codecs()

    for _, arg in ipairs(vim.split(args, " ", { plain = true, trimempty = true })) do
        ---@type string?
        local preview_match = arg:match("preview=(%S+)")

        if preview_match then
            if preview_match ~= "true" and preview_match ~= "false" then
                table.insert(errors, "Invalid value for option 'preview', expected 'true' or 'false'")
            else
                options.preview = preview_match == "true"
            end
        elseif vim.tbl_contains(supported_codecs, arg) then
            table.insert(codecs, arg)
        else
            table.insert(unrecognised_args, arg)
        end
    end

    return codecs, options, unrecognised_args, errors
end

---@param codecs string[]
---@param unrecognised_args string[]
---@param errors string[]
local function process_command_args(codecs, unrecognised_args, errors)
    if #codecs > 1 then
        error("Multiple valid codecs given, specify only one")
    end

    if #errors > 0 then
        error(("Found one or more errors: %s"):format(vim.fn.join(errors, ", ")))
    end

    if #unrecognised_args > 0 then
        error(("One or more unrecognised arguments: %s"):format(vim.fn.join(unrecognised_args, ", ")))
    end
end

---@param codec_func_name "encode" | "decode"
---@return decipher.CommandPreviewFunc
local function create_preview_func(codec_func_name)
    return function(options, ns_id, preview_buffer)
        local codecs, _, unrecognised_args, errors = parse_command_args(options.args)

        if #codecs ~= 1 or #unrecognised_args > 0 or #errors > 0 then
            -- Do not show preview
            return 0
        end

        local buffer = vim.api.nvim_get_current_buf()
        local region = require("decipher.selection").get_selection("visual")
        local start_lnum, end_lnum = region.start.lnum - 1, region["end"].lnum - 1
        local start_col, end_col = region.start.col - 1, region["end"].col - 1
        local text = vim.api.nvim_buf_get_text(buffer, start_lnum, start_col, end_lnum, end_col + 1, {})
        local ok, result = pcall(require("decipher")[codec_func_name], codecs[1], table.concat(text, "\n"))

        if not ok then
            -- Do not show preview
            return 0
        end

        local new_lines = vim.split(result, "\r?\n")
        local new_end_lnum = end_lnum + #new_lines - 1
        local new_end_col = #new_lines[#new_lines]

        if codec_func_name == "decode" and #new_lines == 1 then
            -- If there is only one decoded line offset the new end column by
            -- the original start column
            new_end_col = start_col + new_end_col
        end

        -- Set preview text and highlight in buffer
        vim.api.nvim_buf_set_text(buffer, start_lnum, start_col, end_lnum, end_col + 1, new_lines)
        vim.hl.range(buffer, ns_id, "DecipherCommandPreview", { start_lnum, start_col }, { new_end_lnum, new_end_col })

        -- Set preview text and highlight in preview buffer if enabled
        if preview_buffer then
            local lines = vim.api.nvim_buf_get_lines(buffer, start_lnum, new_end_lnum + 1, true)

            vim.api.nvim_buf_set_lines(preview_buffer, 0, -1, false, lines)
            vim.hl.range(preview_buffer, ns_id, "DecipherCommandPreview", { 0, start_col }, { #new_lines, new_end_col })
        end

        return 2
    end
end

vim.api.nvim_create_user_command("DecipherVersion", function()
    local version = require("decipher").version()
    vim.cmd.echo("'" .. version .. "'")
end, { nargs = 0 })

vim.api.nvim_create_user_command("DecipherEncode", function(args)
    local codecs, options, unrecognised_args, errors = parse_command_args(args.args)

    process_command_args(codecs, unrecognised_args, errors)

    local decipher = require("decipher")

    if #codecs == 0 then
        decipher.encode_selection_prompt(options)
    else
        decipher.encode_selection(codecs[1], options)
    end
end, {
    range = true,
    nargs = "?",
    complete = command_complete,
    desc = "Encode a visual selection",
    preview = create_preview_func("encode"),
})

vim.api.nvim_create_user_command("DecipherDecode", function(args)
    local codecs, options, unrecognised_args, errors = parse_command_args(args.args)

    process_command_args(codecs, unrecognised_args, errors)

    local decipher = require("decipher")

    if #codecs == 0 then
        decipher.decode_selection_prompt(options)
    else
        decipher.decode_selection(codecs[1], options)
    end
end, {
    range = true,
    nargs = "?",
    complete = command_complete,
    desc = "Decode a visual selection",
    preview = create_preview_func("decode"),
})
