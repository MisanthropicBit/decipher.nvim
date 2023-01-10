-- USE: nvim_win_set_config({window},
-- USE: nvim_win_set_option({window},
-- vim.api.nvim_command(
--   string.format("autocmd CursorMoved <buffer> ++once lua require('goto-preview').dismiss_preview(%d)", preview_window)
-- )

local float = {}

local config = require("decipher.config")
local util = require("decipher.util")

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
---@field win_id? number window id
---@field buffer? number buffer id
---@field position decipher.Position position of the float
---@field window_config? decipher.WindowConfig
local Float = {
    width = 0,
    height = 0,
    title = "",
    contents = {},
    win_id = nil,
    buffer = nil,
    position = {
        row = 0,
        col = 0,
    },
    window_config = nil,
}

---@param window_config decipher.WindowConfig
---@return decipher.Float
function Float:new(window_config)
    local win = {}

    setmetatable(win, self)
    self.__index = self
    win.window_config = window_config

    return win
end

---@param content_width number
---@param content_height number
---@return table
function Float:create_window_options(content_width, content_height)
    -- TODO: Merge user config with default config on setup so we don't
    -- need fallbacks here
    local max_width = self.window_config.max_width or vim.o.columns
    local max_height = self.window_config.max_height or vim.o.lines
    local border = self.window_config.border or "rounded"

    -- Convert percentages to window dimension limits
    if 0 < max_height and max_height < 1 then
        max_height = from_percentage(max_height, vim.o.lines)
    end

    if 0 < max_width and max_width < 1 then
        max_width = from_percentage(max_width, vim.o.columns)
    end

    local width = math.min(content_width, max_width - 2)
    local height = math.min(content_height, max_height - 2)
    -- local row = screen_row + math.min(0, vim.o.lines - (height + screen_row + 3))
    -- local col = screen_col + math.min(0, vim.o.columns - (width + screen_col + 3))
    local anchored = self:get_anchored_position(self.position, width, height, self.window_config.padding)

    return {
        relative = "editor",
        row = anchored.position.row,
        col = anchored.position.col,
        anchor = anchored.anchor,
        width = width,
        height = height,
        style = "minimal",
        border = border,
        noautocmd = true,
        focusable = true,
    }
end

---@alias decipher.Anchor "NW" | "SW" | "NE" | "SE"

---@param position decipher.Position initial position of the float
---@param width number width of the float
---@param height number height of the float
---@param padding number padding of the float
---@return { anchor: decipher.Anchor, position: decipher.Position }
function Float:get_anchored_position(position, width, height, padding)
    local vertical_anchor, horizontal_anchor = "N", "W"

    if position.row + height + padding > vim.o.lines - 1 then
        vertical_anchor = "S"
        position.row = position.row - padding - 1
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

---@param contents? string[]
---@return { width: number, height: number }
function Float:dimensions(contents)
    if contents == nil or #contents == 0 then
        return { width = 0, height = 0 }
    end

    local width, height = 0, #contents

    for _, line in ipairs(contents) do
        width = math.max(width, #line)
    end

    local total_padding = self.window_config.padding * 2

    return {
        width = width + total_padding,
        height = height + total_padding,
    }
end

---@param position decipher.Position
function Float:open(position)
    self.position = position

    local dimensions = self:dimensions(self.contents)
    self.width = dimensions.width
    self.height = dimensions.height

    if self.width == 0 or self.height == 0 then
        return
    end

    local options = self:create_window_options(self.width, self.height + 2)

    self.buffer = vim.api.nvim_create_buf(false, true)
    self.win_id = vim.api.nvim_open_win(self.buffer, self.window_config.enter or false, options)

    vim.api.nvim_win_set_var(self.win_id, "decipher_float", true)

    -- local start_lnum = 0

    -- if #self.title > 0 then
    --     start_lnum = 2 + (self.window_config.padding or 0)
    -- end

    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, true, self:assemble_contents())
    self:set_mappings()
    self:set_options()

    -- vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMoved" }, {
    --     callback = function()
    --         self:close()
    --     end,
    --     once = true,
    -- })
end

-- Assemble the final contents of the float
---@return string[]
function Float:assemble_contents()
    local final_contents = {}

    if #self.title > 0 then
        final_contents = {
            self.title,
            string.rep(self.window_config.title_separator, self.width),
        }
    end

    for _, line in ipairs(self.contents) do
        table.insert(final_contents, line)
    end

    return final_contents
end

-- Set mappings for the float
function Float:set_mappings()
    if self.window_config.dismiss then
        local map_options = { buffer = self.buffer, silent = true, noremap = true }

        vim.keymap.set("n", self.window_config.dismiss, function()
            self:close()
        end, map_options)
    end
end

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
    end
end

-- Attempt to focus the float. May fail silently if window has already been closed
---@return boolean
function Float:focus()
    local status, _ = pcall(vim.api.nvim_set_current_win, self.win_id)

    return status
end

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
function float.open(title, contents, window_config)
    -- TODO: Close current popup if inside it

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
    win:set_contents(vim.tbl_map(util.escape_newlines, contents))
    win:open(get_global_coordinates())

    floats[cur_win_id] = win

    return win
end

function float.setup_autocommands()
    vim.cmd([[
        augroup DecipherCleanupFloats
            autocmd!
            autocmd WinClosed * lua require("decipher.float").close()
        augroup end
    ]])
end

return float
