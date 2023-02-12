-- USE: nvim_win_set_config({window},
-- USE: nvim_win_set_option({window},
-- vim.api.nvim_command(
--   string.format("autocmd CursorMoved <buffer> ++once lua require('goto-preview').dismiss_preview(%d)", preview_window)
-- )

local float = {}

local config = require("decipher.config")
local errors = require("decipher.errors")
local str_utils = require("decipher.util.string")
local text = require("decipher.text")

local has_floating_window = vim.fn.has("nvim") and vim.fn.exists("*nvim_win_set_config")

local window_options = {
    wrap = false,
    number = false,
    relativenumber = false,
    cursorline = false,
    signcolumn = "no",
    foldenable = false,
    spell = false,
    list = false,
}

local buffer_options = {
    buftype = "nofile",
    bufhidden = "wipe",
    buflisted = false,
}

---@param percentage number
---@param value number
---@return number
local function from_percentage(percentage, value)
    return math.floor(value * percentage)
end

---@return decipher.Position
local function get_global_coordinates()
    local win_row, win_col = unpack(vim.fn.win_screenpos(0))

    return {
        row = vim.fn.winline() + win_row - 1,
        col = vim.fn.wincol() + win_col - 1,
    }
end

---@class decipher.Float
---@field width number
---@field height number
---@field title string
---@field contents string[]
---@field selection decipher.Region
---@field win_id? number window id
---@field parent_bufnr? number
---@field buffer? number buffer id
---@field position decipher.Position position of the float
---@field window_config? decipher.WindowConfig
local Float = {
    width = 0,
    height = 0,
    title = "",
    contents = {},
    selection = {
        ["start"] = { row = -1, col = -1 },
        ["end"] = { row = -1, col = -1 },
    },
    win_id = nil,
    parent_bufnr = nil,
    buffer = nil,
    position = {
        row = 0,
        col = 0,
    },
    window_config = nil,
}

---@private
---@param window_config decipher.WindowConfig
---@return decipher.Float
function Float:new(window_config)
    local win = {}

    setmetatable(win, self)
    self.__index = self
    win.window_config = window_config

    return win
end

---@private
---@return number, number
function Float:compute_max_dimensions()
    local max_width = self.window_config.max_width
    local max_height = self.window_config.max_height

    if max_width ~= "auto" then
        if 0 < max_width and max_width < 1 then
            ---@diagnostic disable-next-line:param-type-mismatch
            max_width = from_percentage(max_width, vim.o.columns)
        end
    end

    if max_height ~= "auto" then
        -- Convert percentages to window dimension limits
        if 0 < max_height and max_height < 1 then
            ---@diagnostic disable-next-line:param-type-mismatch
            max_height = from_percentage(max_height, vim.o.lines)
        end
    end

    ---@diagnostic disable-next-line:return-type-mismatch
    return max_width, max_height
end

---@private
---@param content_width number
---@param content_height number
---@return table
function Float:create_window_options(content_width, content_height)
    local max_width, max_height = self:compute_max_dimensions()
    local total_padding = self.window_config.padding * 2

    -- Adjust window dimenions with padding and title
    local width = content_width + total_padding * 2
    local height = content_height + total_padding

    if #self.title ~= nil and #self.title > 0 then
        height = height + 2
    end

    if max_width ~= "auto" then
        width = math.min(width, max_width)
    end

    if max_height ~= "auto" then
        height = math.min(height, max_height)
    end

    local anchored = self:get_anchored_position(self.position, width, height, self.window_config.padding)

    return {
        relative = "editor",
        row = anchored.position.row,
        col = anchored.position.col,
        anchor = anchored.anchor,
        width = width,
        height = height,
        style = "minimal",
        border = self.window_config.border,
        noautocmd = true,
        focusable = true,
    }
end

---@alias decipher.Anchor "NW" | "SW" | "NE" | "SE"

---@private
---@param position decipher.Position initial position of the float
---@param width number width of the float
---@param height number height of the float
---@param padding number padding of the float
---@return { anchor: decipher.Anchor, position: decipher.Position }
function Float:get_anchored_position(position, width, height, padding)
    local vertical_anchor, horizontal_anchor = "N", "W"

    if position.row + height + padding > vim.o.lines - 1 then
        vertical_anchor = "S"
        position.row = position.row - padding
    end

    if position.col + width + padding <= vim.o.columns then
        position.col = position.col - 1
    else
        horizontal_anchor = "E"
        position.col = position.col - padding
    end

    return {
        anchor = vertical_anchor .. horizontal_anchor,
        position = position,
    }
end

---@return number, number
function Float:content_dimensions()
    if self.contents == nil or #self.contents == 0 then
        return 0, 0
    end

    local width, height = 0, #self.contents

    for _, line in ipairs(self.contents) do
        width = math.max(width, #line)
    end

    return width, height
end

---@param position decipher.Position
function Float:open(position)
    self.position = position

    local options = self:create_window_options(self.width, self.height)
    self.parent_bufnr = vim.api.nvim_get_current_buf()
    self.buffer = vim.api.nvim_create_buf(false, true)
    self.win_id = vim.api.nvim_open_win(self.buffer, self.window_config.enter or false, options)

    vim.api.nvim_win_set_var(self.win_id, "decipher_float", true)
    self:show_contents(options.width)
    self:set_mappings()
    self:set_options()

    if self.window_config.autoclose then
        -- We defer execution of the autocmd because a motion moves the cursor if
        -- the position is not at the start of what the motion ends up encompasses and so
        -- triggers the CursorMoved event immediately, closing the float
        vim.defer_fn(function()
            vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMoved" }, {
                callback = function()
                    self:close()
                end,
                once = true,
                buffer = self.parent_bufnr,
                desc = [[Closes the decipher floating window when insert mode is entered,
    the cursor is moved]],
            })
        end, 0)
    end
end

-- Show the contents of the float
---@private
---@param win_width number
function Float:show_contents(win_width)
    local contents = {}

    if self.title ~= nil and #self.title > 0 then
        contents = { " " .. self.title, string.rep(self.window_config.title_separator, win_width) }
    end

    for _ = 1, self.window_config.padding do
        table.insert(contents, "")
    end

    local prepadding = self.window_config.padding > 0 and string.rep(" ", self.window_config.padding * 2) or ""

    for _, line in ipairs(self.contents) do
        table.insert(contents, prepadding .. line)
    end

    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, true, contents)
end

---@private
-- Set mappings for the float
function Float:set_mappings()
    if self.window_config.dismiss then
        local map_options = { buffer = self.buffer, silent = true, noremap = true }

        vim.keymap.set("n", self.window_config.dismiss, function()
            self:close()
        end, map_options)

        vim.keymap.set("n", self.window_config.apply, function()
            self:apply_codec()
        end, map_options)
    end
end

---@private
-- Set window and buffer options for the float
function Float:set_options()
    -- Set default window options
    for option, value in pairs(window_options) do
        vim.api.nvim_win_set_option(self.win_id, option, value)
    end

    -- Set default buffer options
    for option, value in pairs(buffer_options) do
        vim.api.nvim_buf_set_option(self.buffer, option, value)
    end

    -- Set use roptions last so they take priority
    for option, value in pairs(self.window_config.options) do
        vim.api.nvim_win_set_option(self.win_id, option, value)
    end
end

---@param title string
function Float:set_title(title)
    self.title = title
end

---@param contents string[]
function Float:set_contents(contents)
    -- TODO: Pad contents
    if contents ~= nil and #contents > 0 then
        self.contents = contents
        self.width, self.height = self:content_dimensions()
    end
end

-- Set the selected region for a visual selection or motion
---@param selection decipher.Region
function Float:set_selection(selection)
    self.selection = selection
end

-- Apply the encoding or decoding in a preview to the selection that triggered
-- the preview
function Float:apply_codec()
    text.set_region(self.parent_bufnr, self.selection, str_utils.escape_newlines(self.contents[1]))
    self:close()
end

-- Attempt to focus the float. May fail silently if window has already been closed
---@return boolean
function Float:focus()
    local status, _ = pcall(vim.api.nvim_set_current_win, self.win_id)

    return status
end

---@private
-- Attempt to close the float. May fail silently if window has already been closed
function Float:close()
    pcall(vim.api.nvim_win_close, self.win_id, true)
end

-- Tracks open floating windows
---@type table<number, decipher.Float>
local floats = {}

-- Close a floating window
---@param win_id? number
function float.close(win_id)
    local win_handle = win_id or vim.api.nvim_get_current_win()
    local status, result = pcall(vim.api.nvim_win_get_var, win_handle, "decipher_float")

    if status and result == true then
        pcall(vim.api.nvim_win_close, win_handle, true)

        local _float = floats[win_handle]

        if _float ~= nil then
            floats[win_handle] = nil
        end
    end
end

---@param title? string
---@param contents string[]
---@param window_config? decipher.WindowConfig
function float.open(title, contents, window_config, selection)
    -- TODO: Close current popup if inside it

    if has_floating_window ~= 1 then
        errors.error_message("No support for floating windows", true)
        return
    end

    local cur_win_id = vim.api.nvim_get_current_win()
    local existing_float = floats[cur_win_id]

    -- Check for existing float in current buffer and focus that instead of
    -- opening a new float
    if existing_float ~= nil then
        if existing_float:focus() then
            return
        else
            float.close(existing_float.win_id)
        end
    end

    local _config = window_config or config.float
    local win = Float:new(_config)

    if _config.title and title ~= nil then
        win:set_title(title)
    end

    -- Escape the string since you cannot set lines in a buffer if it
    -- contains newlines
    win:set_contents(vim.tbl_map(str_utils.escape_newlines, contents))
    win:set_selection(selection)
    win:open(get_global_coordinates())

    floats[cur_win_id] = win

    return win
end

function float.setup()
    vim.cmd([[
        augroup DecipherCleanupFloats
            autocmd!
            autocmd WinClosed * lua require("decipher.float").close()
        augroup end
    ]])
end

return float
