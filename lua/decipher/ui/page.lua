---@class decipher.Page
---@field parent decipher.Float
---@field title? string
---@field contents string[]
---@field _setup? fun(float: decipher.Float, page: decipher.Page): string[]?
---@field _posthook? fun(float: decipher.Float, page: decipher.Page)
local Page = {}

function Page:new(parent, options)
    local page = {
        parent = parent,
        title = options.title or nil,
        contents = options.contents or {},
        _setup = options.setup or nil,
        _posthook = options.posthook or nil,
    }

    self.__index = self

    return setmetatable(page, self)
end

function Page:setup()
    if type(self._setup) == "function" then
        local contents = self._setup(self.parent, self)

        self.contents = contents or {}

        return contents ~= nil
    end

    return true
end

function Page:posthook()
    if type(self._posthook) == "function" then
        self._posthook(self.parent, self)
    end
end

return Page
