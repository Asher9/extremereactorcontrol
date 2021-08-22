-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local Language = {
    text = {},
    getText = function(self,entry)
        return self.text[entry]
    end,

    loadLanguageByFile = function(self, languageFile)
        print("Loading '"..languageFile.."' file")
        local file = fs.open(languageFile,"r")
        local list = file.readAll()
        file.close()

        text = textutils.unserialise(list)
    end,
    loadLanguageById = function(self, languageId)    
        print("Language Requested: "..languageId)
        local fileName = "/extreme-reactors-control/lang/"..languageId..".txt"
        print("Using File: "..fileName)
        self.loadLanguageByFile(fileName)
    end
}

function _G.newLanguageById(languageId)
    local language = {}
    setmetatable(language,{__index=Language})  
    language:loadLanguageById(languageId)  
    print(language:getText("loadedLanguage"))
    return language
end





