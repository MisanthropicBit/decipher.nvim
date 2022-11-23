--local decoder = {}

-----@alias decipher.Status 1 | 2 | 3
--decoder.Status = {}
--decoder.Status.READY = 1
--decoder.Status.RUNNING = 2
--decoder.Status.COMPLETED = 3

--decoder_default_options = {
--  cache = true
--  async = false
--}

--decoder.new = function(name, decode_func, options)
--  if self.decode_func == nil
--    -- what do?
--  end

--  local self = setmetatable({}, { __index = decoder })

--  local options = options or decoder_default_options

--  self.id = misc.id('cmp.source.new')
--  self.name = name
--  self.async = options.async
--  self.cache = options.cache and cache.new() or nil

--  self:reset()

--  return self
--end

-----Reset decoder
--decoder.reset = function(self)
--  self.cache:clear()
--  self.status = decoder.Status.READY
--end

-----Decode source text
--decoder:decode(source)
--  return self.decode_func(source)
--end

-----Get decoder status
--decoder:status()
--  return self.status
--end
