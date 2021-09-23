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
    local message = {}
    setmetatable(message,{__index = Wrapper})
    message.data = data
    message.type = type

    return textutils.unserialise(message)
end

function _G.readMessage(input)
    return textutils.unserialise(input)
end