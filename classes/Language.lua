-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local Language = {
    languageEntries = {},

    getText = function(self,entry)
        return self.languageEntries[entry]
    end,

    loadLanguageFile = function(self, language)    
        local file = fs.open("/extreme-reactors-control/lang/"..language..".txt","r")
        local list = file.readAll()
        file.close()

        languageEntries = textutils.unserialise(list)

    end
}


function _G.newLanguage(langName)
    local language = {}
    setmetatable(language,{__index=Language})    
    print(language:getText("loadedLanguage"))
    return language
end






