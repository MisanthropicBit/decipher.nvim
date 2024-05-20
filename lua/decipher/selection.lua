local selection = {}

---@class decipher.Position
---@field lnum number
---@field col number

---@class decipher.Region
---@field start decipher.Position
---@field end decipher.Position

---@alias decipher.SelectionType "visual" | "motion"

local block_visual_mode = "\22"

---@param mode string
---@return boolean
local function is_visual_mode(mode)
    return vim.tbl_contains({ "v", "V", block_visual_mode }, mode)
end

---@return string
function selection.get_last_visual_mode()
    local mode = vim.fn.mode()

    if not is_visual_mode(mode) then
        -- If there was no current visual mode, get the previous mode instead
        mode = vim.fn.visualmode()
    end

    return mode
end

---@param type decipher.SelectionType
---@return decipher.Region
function selection.get_selection(type)
    local _marks = nil

    if type == "visual" then
        -- Account for currently being in visual mode
        _marks = is_visual_mode(vim.fn.mode()) and { "v", "." } or { "'<", "'>" }
    elseif type == "motion" then
        _marks = { "'[", "']" }
    else
        error(("Unknown mark type: '%s'"):format(type), 0)
    end

    local start_lnum, start_col = unpack(vim.fn.getpos(_marks[1]), 2, 3)
    local end_lnum, end_col = unpack(vim.fn.getpos(_marks[2]), 2, 3)

    return {
        start = { lnum = start_lnum, col = start_col },
        ["end"] = { lnum = end_lnum, col = end_col },
    }
end

---@return decipher.Region
function selection.get_visual_selection()
    return selection.get_selection("visual")
end

---@return decipher.Region
function selection.get_motion_selection()
    return selection.get_selection("motion")
end

--- Adjust a past-end-of-line visual selection by the value of 'selection' setting
---@param bufnr integer
---@param end_col integer
---@return integer
local function get_selection_offset(bufnr, end_col)
    local selection_offset = 0
    local curline_end_col

    vim.api.nvim_buf_call(bufnr, function()
        curline_end_col = vim.fn.col("$")
    end)

    if end_col == curline_end_col then
        selection_offset = vim.opt.selection:get() == "inclusive" and 1 or 0
    end

    return selection_offset
end

---@param bufnr number
---@return string[]
local function get_visual_text(bufnr)
    local mode = selection.get_last_visual_mode()
    local region = selection.get_selection("visual")

    if mode == "V" then
        -- Line-wise selection
        return vim.api.nvim_buf_get_lines(bufnr, region.start.lnum - 1, region["end"].lnum, false)
    elseif mode == "v" then
        -- Character-wise selection
        return vim.api.nvim_buf_get_text(
            bufnr,
            region.start.lnum - 1,
            region.start.col - 1,
            region["end"].lnum - 1,
            region["end"].col,
            {}
        )
    elseif mode == block_visual_mode then
        -- Block-wise selection
        local lines = vim.api.nvim_buf_get_lines(bufnr, region.start.lnum - 1, region["end"].lnum, false)

        local start_col = region.start.col
        local end_col = region["end"].col

        -- Swap columns so we truncate correctly
        if start_col > end_col then
            start_col, end_col = end_col, start_col
        end

        -- Truncate each line by the start and end column
        return vim.tbl_map(function(line)
            return line:sub(start_col, end_col)
        end, lines)
    end

    return {}
end

---@param bufnr number
---@return string[]
local function get_motion_text(bufnr)
    local region = selection.get_selection("motion")

    return vim.api.nvim_buf_get_text(
        bufnr,
        region.start.lnum - 1,
        region.start.col - 1,
        region["end"].lnum - 1,
        region["end"].col,
        {}
    )
end

--- Get the text for the previous selection
---@param bufnr number
---@param type decipher.SelectionType
---@return string[]
function selection.get_text(bufnr, type)
    if type == "visual" then
        return get_visual_text(bufnr)
    else
        return get_motion_text(bufnr)
    end
end

---@param bufnr number
---@param region decipher.Region
---@param value string[]
local function set_visual_text(bufnr, region, value)
    local vmode = vim.fn.visualmode()

    if not is_visual_mode(vmode) then
        -- We might be setting text from a floating window so get the visual mode in
        -- the original buffer
        vim.api.nvim_buf_call(bufnr, function()
            vmode = vim.fn.visualmode()
        end)
    end

    if vmode == "V" then
        -- Line-wise selection
        return vim.api.nvim_buf_set_lines(bufnr, region.start.lnum - 1, region["end"].lnum, false, value)
    elseif vmode == "v" then
        -- Character-wise selection
        local selection_offset = get_selection_offset(bufnr, region["end"].col)

        return vim.api.nvim_buf_set_text(
            bufnr,
            region.start.lnum - 1,
            region.start.col - 1,
            region["end"].lnum - 1,
            region["end"].col - selection_offset,
            value
        )
    elseif vmode == block_visual_mode then
        -- Block-wise selection
        local selection_offset = get_selection_offset(bufnr, region["end"].col)
        local start_col = region.start.col
        local end_col = region["end"].col - selection_offset
        local end_lnum = math.max(region["end"].lnum, region.start.lnum + #value - 1)
        local i = 1

        for lnum = region.start.lnum, end_lnum do
            local new_end_col = end_col
            local replacement = {}

            if i <= #value then
                -- There are still lines to insert
                replacement = { value[i] }

                if lnum > region["end"].lnum then
                    -- We have passed the end of the region, insert the line
                    -- at the start of the visual block without replacing the
                    -- lines
                    new_end_col = start_col - 1
                end
            end

            vim.api.nvim_buf_set_text(bufnr, lnum - 1, start_col - 1, lnum - 1, new_end_col, replacement)

            i = i + 1
        end
    end
end

---@param bufnr number
---@param region decipher.Region
---@param value string[]
local function set_motion_text(bufnr, region, value)
    return vim.api.nvim_buf_set_text(
        bufnr,
        region.start.lnum - 1,
        region.start.col - 1,
        region["end"].lnum - 1,
        region["end"].col,
        value
    )
end

--- Set the last selection type to some text
---@param bufnr number
---@param type decipher.SelectionType
---@param value string[]
function selection.set_text(bufnr, type, value)
    if type == "visual" then
        set_visual_text(bufnr, selection.get_selection("visual"), value)
    else
        set_motion_text(bufnr, selection.get_selection("motion"), value)
    end
end

--- Set a given selection to some text
---@param bufnr number
---@param type decipher.SelectionType
---@param _selection decipher.Region
---@param value string[]
function selection.set_text_from_selection(bufnr, type, _selection, value)
    if type == "visual" then
        set_visual_text(bufnr, _selection, value)
    else
        set_motion_text(bufnr, _selection, value)
    end
end

return selection
