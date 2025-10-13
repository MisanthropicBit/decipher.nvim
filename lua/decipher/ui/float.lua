local float = {}

-- TODO: Preview does not expand with manually inserted newlines and long lines

local compat = require("decipher.compat")
local config = require("decipher.config")
local notifications = require("decipher.notifications")
local Page = require("decipher.ui.page")
local util = require("decipher.util")
local selection = require("decipher.selection")

---@alias decipher.Anchor "NW" | "SW" | "NE" | "SE"

---@class decipher.FloatOpenOptions
---@field title          string?
---@field contents       string[]
---@field window_config  decipher.WindowConfig?
---@field selection_type decipher.SelectionType
---@field codec_name     string
---@field codec_type     "encode" | "decode"
---@field selection      decipher.Region

local augroup = vim.api.nvim_create_augroup("decipher.augroup", {})

---Tracks open floating windows
---@type table<number, decipher.Float>
local floats = {}

---@type boolean
local has_floating_window = vim.fn.exists("*nvim_win_set_config") == 1

---@type boolean
local has_title = vim.fn.has("nvim-0.9") == 1

local decipher_float_var_name = "decipher_float"

-- As percentages of the window's dimensions
local default_max_width = 0.8
local default_max_height = 0.7

---@type table<string, string | number | boolean>
local default_floating_window_options = {
    style = "minimal",
    relative = "editor",
    width = 1,
    height = 1,
    row = 1,
    col = 1,
    noautocmd = true,
    focusable = true,
}

---@type table<string, boolean | string>
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
    filetype = "decipher_float",
    modifiable = true,
    swapfile = false,
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

---@param position decipher.Position initial position of the float
---@param width    number            width of the float
---@param height   number            height of the float
---@return { anchor: decipher.Anchor, position: decipher.Position }
local function get_anchored_position(position, width, height)
    local vertical_anchor, horizontal_anchor = "N", "W"

    if position.lnum + height > vim.o.lines - 1 then
        vertical_anchor = "S"
    end

    if position.col + width >= vim.o.columns then
        horizontal_anchor = "E"
    end

    return {
        anchor = vertical_anchor .. horizontal_anchor,
        position = position,
    }
end

---@param max_width  number | "auto"
---@param max_height number | "auto"
---@return number, number
local function compute_max_dimensions(max_width, max_height)
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

    ---@cast max_width integer
    ---@cast max_height integer

    return max_width, max_height
end

---@class decipher.Float
---@field width            number                       Width of the float
---@field height           number                       Height of the float
---@field curpage          string                       Name of the current page
---@field pages            table<string, decipher.Page> Table of pages by name
---@field selection_type   decipher.SelectionType       Type of selection that triggered this float to open
---@field parent_selection decipher.Region              Region selected in the parent buffer
---@field win_id?          number                       Window id
---@field parent_bufnr?    number                       Parent buffer number
---@field buffer?          number                       Buffer id
---@field position         decipher.Position            Position of the float
---@field window_config?   decipher.WindowConfig
---@field codec_name       string                       The codec used when opening the float
---@field codec_type       "encode" | "decode"          The method used when opening the float
local Float = {
    width = 0,
    height = 0,
    border = nil,
    curpage = "",
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

---@param position? decipher.Position
function Float:open(position, options)
    self.position = position or get_global_coordinates()
    self.parent_bufnr = vim.api.nvim_get_current_buf()
    self.buffer = vim.api.nvim_create_buf(false, true)

    local floating_window_options = vim.tbl_extend("force", default_floating_window_options, {
        border = self.window_config.border,
        zindex = config.float.zindex or 50,
    })

    self.win_id = vim.api.nvim_open_win(self.buffer, self.window_config.enter or false, floating_window_options)
    vim.api.nvim_win_set_var(self.win_id, decipher_float_var_name, true)

    self:set_mappings()
    self:set_options()

    if self.window_config.autoclose then
        -- We defer execution of the autocmd because a motion moves the cursor if
        -- the position is not at the start of what the motion ends up encompasses and so
        -- triggers the CursorMoved event immediately, closing the float
        vim.defer_fn(function()
            if not vim.api.nvim_buf_is_valid(self.parent_bufnr) then
                return
            end

            vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMoved" }, {
                callback = function()
                    self:close()
                end,
                group = augroup,
                once = true,
                buffer = self.parent_bufnr,
                desc = "Closes the decipher floating window when insert mode is entered or the cursor is moved",
            })
        end, 0)
    end
end

--- Render a page of the float
---@private
---@param name string
---@return boolean
function Float:render_page(name)
    local page = self:get_page(name)
    local ok, result = pcall(page.setup, page)

    if not ok then
        ---@cast result string
        notifications.error(result)
        return false
    end

    local contents = page.contents
    ---@cast contents string[]

    local lines_width, lines_height = util.str.dimensions(contents)
    local max_width, max_height = compute_max_dimensions(default_max_width, default_max_height)

    -- Adjust width so there is space for the title
    local title_width = page.title and (#page.title + 2) or 0
    lines_width = math.max(title_width, math.min(lines_width, max_width))
    lines_height = math.min(lines_height, max_height)

    page:render(contents)

    local anchored = get_anchored_position(self.position, lines_width, lines_height)

    local win_config = {
        relative = "editor",
        row = anchored.position.lnum,
        col = anchored.position.col,
        anchor = anchored.anchor,
        width = lines_width,
        height = lines_height,
    }

    if has_title then
        if self.window_config.title and page.title then
            win_config.title = {
                { " " .. page.title .. " ", "DecipherFloatTitle" },
            }
            win_config.title_pos = self.window_config.title_pos
        end
    else
        if self.window_config.title then
            notifications.warn("'title' option requires nvim 0.9+")
        end
    end

    vim.api.nvim_win_set_config(self.win_id, win_config)
    self.curpage = name

    return true
end

--- Set mappings for the float
---@private
function Float:set_mappings()
    if self.window_config.mappings then
        local map_options = { buffer = self.buffer, silent = true, noremap = true }

        ---@param key  string
        ---@param func function
        local function set_keymap(key, func)
            local lhs = self.window_config.mappings[key]

            vim.keymap.set("n", lhs, func, map_options)
        end

        set_keymap("close", function()
            self:close()
        end)

        set_keymap("apply", function()
            self:update_parent_buffer(vim.api.nvim_buf_get_lines(self.buffer, 0, -1, true))
        end)

        set_keymap("update", function()
            -- Get contents and concatenate with newlines
            local contents = table.concat(vim.api.nvim_buf_get_lines(self.buffer, 0, -1, true), "\n")

            -- If we opened a float after decoding then we should encode it
            -- when updating and vice versa
            local method = self.codec_type == "encode" and "decode" or "encode"
            local new_encoded = require("decipher")[method](self.codec_name, contents)

            self:update_parent_buffer({ new_encoded })
        end)

        set_keymap("help", function()
            self:switch_to_page("help")
        end)

        set_keymap("json", function()
            self:switch_to_page("json")
        end)
    end
end

---@private
-- Set window and buffer options for the float
function Float:set_options()
    -- Set default window options
    for option, value in pairs(window_options) do
        compat.set_option(option, value, { win = self.win_id })
    end

    -- Set default buffer options
    for option, value in pairs(buffer_options) do
        compat.set_option(option, value, { buf = self.buffer })
    end

    -- Set user options last so they take priority
    for option, value in pairs(self.window_config.win_options) do
        compat.set_option(option, value, { win = self.win_id })
    end
end

---@param page_name string
---@return decipher.Page
function Float:get_page(page_name)
    return self.pages[page_name]
end

---@param name    string
---@param options decipher.Page?
function Float:add_page(name, options)
    self.pages[name] = Page:new(self, options)
end

--- Set the selected region for a visual selection or motion
---@param selection_type   decipher.SelectionType
---@param parent_selection decipher.Region selection orginially made in the float's parent buffer
function Float:set_selection(selection_type, parent_selection)
    self.selection_type = selection_type
    self.parent_selection = parent_selection
end

--- Update the parent buffer (the original selection/motion) with a value then
--- close the float
---@private
---@param value string[]
function Float:update_parent_buffer(value)
    if self.selection_type and self.parent_selection then
        selection.set_text_from_selection(self.parent_bufnr, self.selection_type, self.parent_selection, value)

        self:close()
    end
end

--- Switch between a given page and the main page
---@param page_name string page name to toggle between
function Float:switch_to_page(page_name)
    local old_page = self:get_page(self.curpage)

    if old_page then
        old_page:save()
    end

    local target_page = self.curpage == page_name and "main" or page_name
    local success = self:render_page(target_page)

    if success and old_page then
        old_page:cleanup()
    end
end

--- Attempt to focus the float. May fail silently if window has already been closed
---@return boolean
function Float:focus()
    local status, _ = pcall(vim.api.nvim_set_current_win, self.win_id)

    return status
end

--- Attempt to close the float. May fail silently if window has already been closed
function Float:close()
    pcall(vim.api.nvim_win_close, self.win_id, true)
end

---@param options decipher.FloatOpenOptions
---@return decipher.Float?
function float.open(options)
    if not has_floating_window then
        notifications.error("No support for floating windows")
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

    local _config = options.window_config or config.float
    local _float = Float:new(_config)

    _float:add_page("main", {
        parent = _float,
        title = options.title,
        -- Escape the string since you cannot set lines in a buffer if it
        -- contains newlines
        contents = util.str.escape_newlines(options.contents),
    })

    _float:add_page("help", {
        parent = _float,
        title = "Help",
        ---@param parent decipher.Float
        setup = function(parent, page)
            local mappings = parent.window_config.mappings
            ---@cast mappings -nil

            local mapping_lens = vim.tbl_map(function(mapping)
                return #mapping
            end, vim.tbl_values(mappings))
            ---@cast mapping_lens number[]

            local max_keymap_width = math.max(unpack(mapping_lens))

            ---@param mapping string
            ---@param desc string
            ---@return string
            local function format_help_entry(mapping, desc)
                local help_format = "%s%s  %s"
                local spacing = (" "):rep(max_keymap_width - #mapping)

                return help_format:format(mapping, spacing, desc)
            end

            page.contents = {
                format_help_entry(mappings.close, "Close the preview"),
                format_help_entry(mappings.apply, "Apply the preview to the selection including any changes"),
                format_help_entry(mappings.update, "Update selection with preview"),
                format_help_entry(mappings.json, "View preview as immutable json"),
                format_help_entry(mappings.help, "Toggle this help"),
            }
        end,
    })

    _float:add_page("json", {
        parent = _float,
        setup = function(parent, page)
            local main_page = parent.pages["main"]
            local ok, result = pcall(vim.json.decode, table.concat(main_page.contents))

            if not ok then
                error("Cannot decode as json: " .. result)
            end

            local pretty = util.json.pretty_print(result, { sort_keys = true })

            page.title = main_page.title .. " (json pretty-print)"
            page.contents = vim.fn.split(pretty, "\n")

            vim.bo[parent.buffer].filetype = "json"
            vim.bo[parent.buffer].modifiable = false
        end,
        cleanup = function(parent)
            vim.bo[parent.buffer].filetype = nil
            vim.bo[parent.buffer].modifiable = true
        end,
    })

    _float.codec_name = options.codec_name
    _float.codec_type = options.codec_type
    _float:set_selection(options.selection_type, options.selection)
    _float:open()
    _float:switch_to_page("main")

    floats[cur_win_id] = _float

    return _float
end

--- Close a floating window
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

function float.setup()
    vim.api.nvim_create_autocmd("WinClosed", {
        ---@param event { buf: number, event: string, file: string, id: number, match: string }
        callback = function(event)
            float.close(tonumber(event.match))
        end,
        group = augroup,
        desc = "Close any decipher floats related to the window that was closed",
    })

    vim.cmd([[hi default link DecipherFloatTitle Title]])
end

return float
