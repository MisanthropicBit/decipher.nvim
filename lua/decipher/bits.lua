local bits = {}

local bit = require("bit")

bits.band = bit.band
bits.bor = bit.bor
bits.lshift = bit.lshift
bits.rshift = bit.rshift

--- Extract a byte by shifting right and applying a bitmask
---@param value number value to get bits from
---@param rshift number how much to right-shift
---@param mask number mask for masking off bits
function bits.get_bits(value, rshift, mask)
    return bits.band(bits.rshift(value, rshift), mask)
end

--- Pack bits into a bit buffer from the left
---@param buffer number target bit buffer
---@param lshift number how much to left-shift
---@param value number value to pack into the bit buffer
function bits.left_pack(buffer, lshift, value)
    local mask = bits.lshift(1, lshift) - 1
    return bits.bor(bits.lshift(buffer, lshift), bit.band(value, mask))
end

return bits
