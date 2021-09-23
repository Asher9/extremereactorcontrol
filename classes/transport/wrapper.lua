local Wrapper = {
    type = "",
    location = "",
    response = "",
    data = {}
}


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