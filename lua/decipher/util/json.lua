-- Inspired by https://github.com/smjonas/snippet-converter.nvim/blob/main/lua/snippet_converter/utils/json_utils.lua

local json = {}

---Return an iterator over a table's keys in sorted order
---@param tbl table
---@return function
---@return table
---@return string
local function sorted_pairs(tbl)
    local keys = {}

    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    -- NOTE: Unfortunately this is not a stable sort
    table.sort(keys)

    local idx = 0

    local iter = function(invariant, _)
        idx = idx + 1

        if keys[idx] ~= nil then
            return keys[idx], invariant[keys[idx]]
        end
    end

    return iter, tbl, ""
end

---@class JsonPrettyPrintOptions
---@field indent? integer
---@field sort_keys? boolean

---@class decipher.ResultBuffer
---@field _options JsonPrettyPrintOptions
---@field _result string[]
ResultBuffer = {}

---@param options JsonPrettyPrintOptions
---@return decipher.ResultBuffer
function ResultBuffer:new(options)
    local buffer = {
        _options = options,
        _indent = 0,
        _raw = false,
        _result = {},
    }

    setmetatable(buffer, self)
    self.__index = self

    return buffer
end

function ResultBuffer:indent()
    self._indent = self._indent + self._options.indent
end

function ResultBuffer:dedent()
    self._indent = self._indent - self._options.indent
end

---@param item any
---@param raw? boolean
function ResultBuffer:add(item, raw)
    if not raw and not self._raw then
        table.insert(self._result, (" "):rep(self._indent))
    end

    self._raw = false
    table.insert(self._result, item)
end

function ResultBuffer:set_raw(flag)
    self._raw = flag
end

function ResultBuffer:get()
    return table.concat(self._result)
end

---Escape special characters in strings
---@param value string
---@return string
local function escape_chars(value)
    -- See http://www.lua.org/manual/5.1/manual.html#2.1

    ---@diagnostic disable-next-line: redundant-return-value
    return value:gsub('[\\"\a\b\f\n\r\t\v]', {
        ["\\"] = "\\\\",
        ['"'] = '\\"',
        ["\a"] = "\\a",
        ["\b"] = "\\b",
        ["\f"] = "\\f",
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t",
        ["\v"] = "\\v",
    })
end

local format_value

---@param value table
---@param buffer decipher.ResultBuffer
local function format_array(value, buffer)
    local size = #value
    buffer:add("[\n")
    buffer:indent()

    for idx, item in ipairs(value) do
        format_value(item, buffer)
        buffer:add(idx == size and "\n" or ",\n", true)
    end

    buffer:dedent()
    buffer:add("]")
end

---@param value table
---@param buffer decipher.ResultBuffer
local function format_table_as_object(value, buffer)
    local size = vim.tbl_count(value)

    buffer:add("{\n")
    buffer:indent()

    local i = 1
    local iter = buffer._options.sort_keys and sorted_pairs or pairs

    -- This might be incorrect for more than two levels because the
    -- table to iterate over is always the same
    for key, _value in iter(value) do
        buffer:add(('"%s": '):format(escape_chars(key)))
        buffer:set_raw(true)
        format_value(_value, buffer)

        buffer:add(i == size and "\n" or ",\n", true)
        i = i + 1
    end

    buffer:dedent()
    buffer:add("}")
end

---@param value table
---@param buffer decipher.ResultBuffer
local function format_table(value, buffer)
    if vim.tbl_count(value) == 0 then
        buffer:add("{}")
    else
        if vim.tbl_islist(value) then
            format_array(value, buffer)
        else
            format_table_as_object(value, buffer)
        end
    end
end

---@type table<string, fun(value: any, buffer: decipher.ResultBuffer)>
local formatters = {
    ["string"] = function(value, buffer)
        return buffer:add(([["%s"]]):format(escape_chars(value)))
    end,
    ["number"] = function(num, buffer)
        buffer:add(tostring(num))
    end,
    ["boolean"] = function(bool, buffer)
        buffer:add(bool and "true" or "false")
    end,
    ["table"] = format_table,
}

---@param value any
---@param buffer decipher.ResultBuffer
local function _format_value(value, buffer)
    if value == nil then
        buffer:add("null")
        return
    end

    local _type = type(value)
    local formatter = formatters[_type]

    if not formatter then
        error(("Cannot format value of type '%s'"):format(_type))
    end

    formatter(value, buffer)
end

format_value = _format_value

---Pretty-print a lua value as json
---@param value any
---@param options? JsonPrettyPrintOptions
function json.pretty_print(value, options)
    ---@type JsonPrettyPrintOptions
    local _options = vim.tbl_extend("force", { indent = 2, sort_keys = true }, options or {})
    local buffer = ResultBuffer:new(_options)

    format_value(value, buffer)

    return buffer:get()
end

return json
