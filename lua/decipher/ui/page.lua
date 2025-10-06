---@class decipher.Page
---@field parent    decipher.Float
---@field title     string?
---@field contents  string[]?
---@field _setup    (fun(float: decipher.Float, page: decipher.Page): string[])?
---@field _cleanup  fun(float: decipher.Float, page: decipher.Page)?
local Page = {}

---@param parent  decipher.Float
---@param options decipher.Page?
function Page:new(parent, options)
    local _options = options or{}

    vim.validate("setup", _options.setup, "function", true)

    local page = {
        parent = parent,
        title = _options.title,
        contents = _options.contents or {},
        _setup = _options.setup,
        _cleanup = _options.cleanup,
    }

    self.__index = self

    return setmetatable(page, self)
end

function Page:setup()
    if type(self._setup) == "function" then
        self._setup(self.parent, self)
    end
end

function Page:cleanup()
    if type(self._cleanup) == "function" then
        self._cleanup(self.parent, self)
    end
end

---@param contents string[]
function Page:set_contents(contents)
    self.contents = contents
end

function Page:save()
    self.contents = vim.api.nvim_buf_get_lines(self.parent.buffer, 0, -1, true)
end

---@param contents string[]
function Page:render(contents)
    local modifiable = vim.bo[self.parent.buffer].modifiable

    vim.bo[self.parent.buffer].modifiable = true
    vim.api.nvim_buf_set_lines(self.parent.buffer, 0, -1, true, contents)
    vim.bo[self.parent.buffer].modifiable = modifiable
end

return Page
