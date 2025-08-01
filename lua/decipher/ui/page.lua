---@class decipher.Page
---@field parent    decipher.Float
---@field title     string?
---@field contents  string[]?
---@field _setup    (fun(float: decipher.Float, page: decipher.Page): string[])?
---@field _cleanup  fun(float: decipher.Float, page: decipher.Page)?
local Page = {}

---@param parent  decipher.Float
---@param options decipher.Page
function Page:new(parent, options)
    local page = {
        parent = parent,
        title = options.title or nil,
        contents = options.contents or {},
        _setup = options.setup or nil,
        _cleanup = options.cleanup or nil,
    }

    self.__index = self

    return setmetatable(page, self)
end

function Page:setup()
    if not self._setup then
        return true
    elseif type(self._setup) == "function" then
        self._setup(self.parent, self)

        return self.contents ~= nil
    end

    return false
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
