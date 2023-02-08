local test = {}

--- Test that encoding the input of a test case with an encoding function
--- yields the same result as the output of the test case
---@param test_cases table<string, string>
---@param encode_func fun(string): string?
function test.test_encode(test_cases, encode_func)
    for input, output in pairs(test_cases) do
        local encoded = encode_func(input)

        assert.are.equal(#encoded, #output)
        assert.are.equal(encoded, output)
    end
end

--- Test that decoding the output of a test case with a decoding function
--- yields the same result as the input of the test case
---@param test_cases table<string, string>
---@param decode_func fun(string): string?
function test.test_decode(test_cases, decode_func)
    for input, output in pairs(test_cases) do
        local decoded = decode_func(output)

        assert.are.equal(#decoded, #input)
        assert.are.equal(decoded, input)
    end
end

return test
