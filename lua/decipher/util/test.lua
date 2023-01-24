local test = {}

--- Test that encoding the input of a test case with an encoding function
--- yields the same result as the output of the test case
---@param test_cases table<string, string>
---@param encode_func fun(string): string?
function test.test_encode(test_cases, encode_func)
    for input, output in pairs(test_cases) do
        assert.are.equal(encode_func(input), output)
    end
end

--- Test that decoding the output of a test case with a decoding function
--- yields the same result as the input of the test case
---@param test_cases table<string, string>
---@param decode_func fun(string): string?
function test.test_decode(test_cases, decode_func)
    for input, output in pairs(test_cases) do
        assert.are.equal(decode_func(output), input)
    end
end

return test
