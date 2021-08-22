-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local Language = {
    text = {},
    getText = function(self, entry)
        local value = text[entry]
        if value == nil or value == '' then
            return entry
        end
        return value
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
        text = textutils.unserialise(list)
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
    print(language:getText("language"))
    return language
end




