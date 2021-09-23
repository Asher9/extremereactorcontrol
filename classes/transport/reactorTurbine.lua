local ReactorTurbineMessage = {
    energyStored = 0,
    energyMax = 0,
    reactorEnergry =0 ,
    reactorCount = 0,
    fuelConsumed = 0,
    efficiency = 0,
    casing = 0,
    core = 0,
    rodLevel = 0,
    rfProduced = function(self)
        local rfGen = 0
        for i = 0, #turbines, 1 do
            rfGen = rfGen + self.id.turbines[i]:energyProduction()
        end
        return rfGen;
    end,,
    turbines = {}
}

local Turbine = {
    engaged = "",
    turbineSpeed = 0,
    rfProduction = 0,
    turbineEnergy = 0
}

function _G.newReactorTurbineMessage(turbineCount)
    debugOutput("Creating new ReactorOnlyMessage Class")

    local reactorTurbine = {}
    setmetatable(reactorTurbine,{__index = ReactorTurbineMessage})
    
    for i = 1, turbineCount do
        reactorTurbine.turbines[i] = {}
        setmetatable(reactorTurbine.turbines[i],{__index = Turbine})
    end

    return reactorTurbine
end