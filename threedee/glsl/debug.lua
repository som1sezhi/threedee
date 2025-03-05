-- https://gist.github.com/jaredallard/ddb152179831dd23b230
local function split(self, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end

local function printLines(source)
    local lines = split(source, '\n')
    for i, line in ipairs(lines) do
        print(string.format('%3d %s', i, line))
    end
end

return {
    printLines = printLines
}
