local Wrapper = {
    type = "",
    location = "",
    response = "",
    data = {}
}

local binPath = "/extreme-reactors-control/classes/transport/"
shell.run(binPath.."reactoronly.lua")
shell.run(binPath.."reactorturbine.lua")
shell.run(binPath.."startup.lua")

function _G.newMessage(type, data, location)
    debugOutput("Creating new Wrapper Class")

    local message = {}
    setmetatable(message,{__index = Wrapper})
    
    if data == nil then
        debugOutput("MISSING data object. This is going to break!")
    end

    debugOutput("Settings Name -> ".. type)
    message.data = data
    message.type = type

    return  textutils.unserialise(message)
end

function _G.readMessage(input)
    debugOutput("Creating new Wrapper Class")
    return textutils.unserialise(input)
end