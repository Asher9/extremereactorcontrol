local StartUpMessage = {
    message = ""
}

function _G.newStartUpMessage(messageData)
    debugOutput("Creating new StartUpMesssage Class")

    local message = {}
    setmetatable(message,{__index = StartUpMessage})
    
    message.message = messageData

    return message
end