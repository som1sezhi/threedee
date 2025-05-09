---Resolve #include directives in a GLSL source string. If two source strings 
---are passed in, dependencies are checked treating the 1st string as the
---vertex shader source and the 2nd string as the fragment shader source.
---@param source1 string
---@param source2 string
---@return string, string
---@overload fun(source1: string): string
local function preprocess(source1, source2)
    local prevIncludes = {}
    local prevIncludedTraits = {}
    local checkPrevStageDeps = false

    local function getSnippet(snippetName)
        local snippetInfo
        local function f()
            snippetInfo = require('threedee.glsl.snippets.' .. snippetName)
        end
        if pcall(f) then
            local function checkDep(depName)
                if not prevIncludes[depName] then
                    error(string.format(
                        '<%s> depends on <%s> which was not included previously',
                        snippetName, depName
                    ))
                end
            end
            local function checkTraitDep(traitName)
                if not prevIncludedTraits[traitName] then
                    error(string.format(
                        '<%s> depends on an include with trait "%s" which was not included previously',
                        snippetName, traitName
                    ))
                end
            end

            if snippetInfo.deps then
                for _, depName in ipairs(snippetInfo.deps) do
                    checkDep(depName)
                end
            end
            if snippetInfo.traitDeps then
                for _, traitName in ipairs(snippetInfo.traitDeps) do
                    checkTraitDep(traitName)
                end
            end
            if checkPrevStageDeps and snippetInfo.prevStageDeps then
                for _, depName in ipairs(snippetInfo.prevStageDeps) do
                    checkDep(depName)
                end
            end

            prevIncludes[snippetName] = true
            if snippetInfo.traits then
                for _, traitName in ipairs(snippetInfo.traits) do
                    prevIncludedTraits[traitName] = true
                end
            end

            -- prepend \n to ensure snippet always starts with a newline
            -- (apparently on some systems the initial newline of multiline
            -- strings can be dropped somehow?? idk)
            return '\n' .. snippetInfo.snippet
        else
            error('could not resolve #include <' .. snippetName .. '>')
        end
    end

    local ret1 = (string.gsub(source1, '\n[ \t]*#include%s+<([%w_]+)>', getSnippet))
    if source2 == nil then
        return ret1
    else
        checkPrevStageDeps = true
        local ret2 = (string.gsub(source2, '\n[ \t]*#include%s+<([%w_]+)>', getSnippet))
        return ret1, ret2
    end
end

return preprocess