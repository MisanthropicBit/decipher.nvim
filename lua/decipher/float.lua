local float = {}

local config = require("decipher.config")
local errors = require("decipher.errors")
local util = require("decipher.util")
local selection = require("decipher.selection")

---@type boolean
local has_floating_window = vim.fn.has("nvim") and vim.fn.exists("*nvim_win_set_config")

local decipher_float_var_name = "decipher_float"

-- As percentages of the window's dimensions
local default_max_width = 0.8
local default_max_height = 0.7

---@type table<string, any>
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

---@type table<string, any>
local buffer_options = {
    buftype = "nofile",
    bufhidden = "wipe",
    buflisted = false,
    modifiable = false,
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
        lnum = vim.fn.winline() + win_row - 1,
        col = vim.fn.wincol() + win_col - 1,
    }
end

---Pad the given lines
---@param lines string[]
---@param padding number
---@param padchar string
---@return string[], number, number
local function pad_lines(lines, padding, padchar)
    local padded = {}
    local width = 0

    for _ = 1, padding do
        table.insert(padded, "")
    end

    local padstr = padding > 0 and padchar:rep(padding) or ""

    for _, line in ipairs(lines) do
        local padded_line = padstr .. line .. padstr

        table.insert(padded, padded_line)
        width = math.max(width, #padded_line)
    end

    for _ = 1, padding do
        table.insert(padded, "")
    end

    return padded, width, #padded
end

---@class decipher.Page
---@field title string
---@field contents string[]
---@field rendered string[]
---@field width number
---@field height number

---@class decipher.Float
---@field width number Width of the float
---@field height number Height of the float
---@field pages table<string, decipher.Page> Table of pages by name
---@field selection_type decipher.SelectionType -- Type of selection that triggered this float to open
---@field parent_selection decipher.Region -- Region selected in the parent buffer
---@field win_id? number Window id
---@field parent_bufnr? number Parent buffer number
---@field buffer? number Buffer id
---@field position decipher.Position position of the float
---@field window_config? decipher.WindowConfig
---@field help_visible boolean If the help page is visible or not
local Float = {
    width = 0,
    height = 0,
    border = nil,
    pages = {},
    selection = {
        ["start"] = { lnum = -1, col = -1 },
        ["end"] = { lnum = -1, col = -1 },
    },
    win_id = nil,
    parent_bufnr = nil,
    buffer = nil,
    position = {
        lnum = 0,
        col = 0,
    },
    window_config = nil,
    help_visible = false,
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
    local max_width = default_max_width
    local max_height = default_max_height

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

---@alias decipher.Anchor "NW" | "SW" | "NE" | "SE"

---@private
---@param position decipher.Position initial position of the float
---@param width number width of the float
---@param height number height of the float
---@param padding number padding of the float
---@return { anchor: decipher.Anchor, position: decipher.Position }
function Float:get_anchored_position(position, width, height, padding)
    local vertical_anchor, horizontal_anchor = "N", "W"

    if position.lnum + height + padding > vim.o.lines - 1 then
        vertical_anchor = "S"
    end

    if position.col + width + padding >= vim.o.columns then
        horizontal_anchor = "E"
    end

    return {
        anchor = vertical_anchor .. horizontal_anchor,
        position = position,
    }
end

---@param position decipher.Position
function Float:open(position)
    local minimum_window_options = {
        style = "minimal",
        relative = "editor",
        width = 1,
        height = 1,
        row = 1,
        col = 1,
        border = self.window_config.border,
        noautocmd = true,
        focusable = true,
    }

    self.position = position
    self.parent_bufnr = vim.api.nvim_get_current_buf()
    self.buffer = vim.api.nvim_create_buf(false, true)
    self.win_id = vim.api.nvim_open_win(self.buffer, self.window_config.enter or false, minimum_window_options)

    vim.api.nvim_win_set_var(self.win_id, decipher_float_var_name, true)
    self:render_page("main")
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
                desc = "Closes the decipher floating window when insert mode is entered or the cursor is moved",
            })
        end, 0)
    end
end

-- Render a page of the float
---@private
---@param name string
function Float:render_page(name)
    local page = self.pages[name]

    local contents, width, height = pad_lines(page.contents, self.window_config.padding, " ")
    local max_width, max_height = self:compute_max_dimensions()

    if max_width ~= "auto" then
        width = math.min(width, max_width)
    end

    if max_height ~= "auto" then
        height = math.min(height, max_height)
    end

    -- Temporarily make the buffer modifiable so we can render the page
    vim.api.nvim_buf_set_option(self.buffer, "modifiable", true)
    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, true, contents)
    vim.api.nvim_buf_set_option(self.buffer, "modifiable", false)

    local anchored = self:get_anchored_position(self.position, width, height, self.window_config.padding)

    local title = self.window_config.title and page.title or nil

    if title then
        title = " " .. title .. " "
    end

    vim.api.nvim_win_set_config(self.win_id, {
        title = title,
        title_pos = self.window_config.title_pos or "left",
        relative = "editor",
        row = anchored.position.lnum,
        col = anchored.position.col,
        anchor = anchored.anchor,
        width = width,
        height = height,
    })
end

---@private
-- Set mappings for the float
function Float:set_mappings()
    if self.window_config.mappings then
        local map_options = { buffer = self.buffer, silent = true, noremap = true }

        local function set_keymap(key, func)
            local lhs = self.window_config.mappings[key]

            vim.keymap.set("n", lhs, func, map_options)
        end

        set_keymap("close", function()
            self:close()
        end)
        set_keymap("apply", function()
            self:apply_codec()
        end)
        set_keymap("help", function()
            self:toggle_help()
        end)
        set_keymap("jsonpp", function()
            self:toggle_json_pretty_print()
        end)
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

    -- Set user options last so they take priority
    for option, value in pairs(self.window_config.options) do
        vim.api.nvim_win_set_option(self.win_id, option, value)
    end
end

---@param name string
---@param options { title?: string, contents?: string[] }
function Float:set_page(name, options)
    if self.pages[name] == nil then
        self.pages[name] = {}
    end

    if options.title ~= nil and #options.title > 0 then
        self.pages[name].title = options.title
    end

    if options.contents ~= nil and #options.contents > 0 then
        self.pages[name].contents = options.contents
    end
end

-- Set the selected region for a visual selection or motion
---@param parent_selection decipher.Region selection orginially made in the
--                          float's parent buffer
function Float:set_selection(selection_type, parent_selection)
    self.selection_type = selection_type
    self.parent_selection = parent_selection
end

-- Apply the encoding or decoding in a preview to the selection that triggered
-- the preview
function Float:apply_codec()
    selection.set_text_from_selection(
        self.parent_bufnr,
        self.selection_type,
        self.parent_selection,
        self.pages["main"].contents
    )
    self:close()
end

---Toggle help
function Float:toggle_help()
    self.help_visible = not self.help_visible

    if self.help_visible then
        if self.pages["help"] == nil then
            local format = "%s - %s"

            self:set_page("help", {
                title = "Help",
                contents = {
                    format:format(self.window_config.mappings.close, "Close the floating window"),
                    format:format(self.window_config.mappings.apply, "Apply the encoding/decoding"),
                    format:format(self.window_config.mappings.jsonpp, "Prettily format contents as json"),
                    format:format(self.window_config.mappings.help, "Toggle this help"),
                },
            })
        end

        self:render_page("help")
    else
        self:render_page("main")
    end
end

---Toggle json pretty printing
function Float:toggle_json_pretty_print()
    self.jsonpp_visible = not self.jsonpp_visible

    if self.jsonpp_visible then
        if self.pages["jsonpp"] == nil then
            local page = self.pages["main"]
            local success, result = pcall(vim.json.decode, table.concat(page.contents))

            if not success then
                errors.error_message("Cannot decode as json: " .. result, true)
                self.jsonpp_visible = false
                return
            end

            local pretty = util.json.pretty_print(result, { sort_keys = true })

            self:set_page("jsonpp", {
                title = page.title .. " (json pretty-print)",
                contents = vim.fn.split(pretty, "\n"),
            })
        end

        vim.bo.filetype = "json"
        self:render_page("jsonpp")
    else
        vim.bo.filetype = ""
        self:render_page("main")
    end
end

-- Attempt to focus the float. May fail silently if window has already been closed
---@return boolean
function Float:focus()
    local status, _ = pcall(vim.api.nvim_set_current_win, self.win_id)

    return status
end

---Attempt to close the float. May fail silently if window has already been closed
function Float:close()
    pcall(vim.api.nvim_win_close, self.win_id, true)
end

---Tracks open floating windows
---@type table<number, decipher.Float>
local floats = {}

---Close a floating window
---@param win_id? number
function float.close(win_id)
    local parent_win_handle = win_id or vim.api.nvim_get_current_win()
    local _float = floats[parent_win_handle]

    if _float ~= nil then
        local status, result = pcall(vim.api.nvim_win_get_var, _float.win_id, decipher_float_var_name)
        floats[parent_win_handle] = nil

        if status and result == true then
            _float:close()
        end
    end
end

---@param title? string
---@param contents string[]
---@param window_config? decipher.WindowConfig
---@param selection_type decipher.SelectionType
---@param _selection decipher.Region
function float.open(title, contents, window_config, selection_type, _selection)
    if has_floating_window ~= 1 then
        errors.error_message("No support for floating windows", true)
        return nil
    end

    local cur_win_id = vim.api.nvim_get_current_win()
    local existing_float = floats[cur_win_id]

    -- Check for existing float in current buffer and focus that instead of
    -- opening a new float
    if existing_float ~= nil then
        if existing_float:focus() then
            return existing_float
        else
            float.close(existing_float.win_id)
        end
    end

    local _config = window_config or config.float
    local win = Float:new(_config)

    -- Escape the string since you cannot set lines in a buffer if it
    -- contains newlines
    win:set_page("main", {
        title = title,
        contents = util.str.escape_newlines(contents),
    })
    win:set_selection(selection_type, _selection)
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
