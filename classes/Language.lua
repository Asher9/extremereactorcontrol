-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local Language = {
    text = {},
    getText = function(self, entry)
        return self.text[entry]
    end,
    dumpText = function(self)        
        for k, v in pairs(text) do
            print(k..") "..v)
        end
    end,
    loadLanguageByFile = function(self, languageFile)
        local file = fs.open(languageFile,"r")
        local list = file.readAll()
        file.close()
        unsortedList = textutils.unserialise(list)
        text = spairs(unsortedList)()
    end,

    loadLanguageById = function(self, languageId)
        local fileName = "/extreme-reactors-control/lang/"..languageId..".txt"
        self:loadLanguageByFile(fileName)
    end
}

function _G.newLanguageById(languageId)
    local language = {}
    setmetatable(language,{__index=Language})  
    language:loadLanguageById(languageId)  
    print(language:getText("loadedLanguage"))
    return language
end

-- copied from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end




