local M = {}

local unpack = unpack or table.unpack

local function user_command(name, func, options)
    vim.api.nvim_create_user_command(name, func, options)
end

function M.setup(decipher)
    vim.api.nvim_create_user_command("DecipherVersion", function()
        print(decipher.version())
    end, { nargs = 0 })

    local shared_options1 = { range = true, nargs = "+" }
    local shared_options2 = { range = true, nargs = 1, complete = decipher.codecs }
    local shared_options3 = { range = true, nargs = 0 }

    user_command("DecipherEncode", function(args)
        decipher.encode(unpack(args.fargs))
    end, shared_options1)
    user_command("DecipherDecode", function(args)
        decipher.decode(unpack(args.fargs))
    end, shared_options1)

    user_command("DecipherEncodeSelection", function(args)
        decipher.encode_selection(unpack(args.fargs))
    end, shared_options2)
    user_command("DecipherDecodeSelection", function(args)
        decipher.decode_selection(unpack(args.fargs))
    end, shared_options2)

    user_command("DecipherPreviewSelection", function(args)
        decipher.decode_preview_selection(args.fargs)
    end, shared_options2)

    user_command("DecipherEncodePrompt", decipher.encode_selection_prompt, shared_options3)
    user_command("DecipherDecodePrompt", decipher.decode_selection_prompt, shared_options3)
end

return M
