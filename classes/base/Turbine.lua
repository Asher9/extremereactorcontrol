-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local Turbine = {
    name = "",
    id = {},
    side = "",
    type = "",

    active = function(self)
        return self.id.getActive()
    end,
    coilsEngaged = function(self)
        return self.id.getInductorEngaged()
    end,
    rotorSpeed = function(self)
        return self.id.getRotorSpeed()
    end,
    energy = function(self)
        return self.id.getEnergyStored()
    end,
    energyProduction = function(self)
        return self.id.getEnergyProducedLastTick()
    end,
    steamIn = function(self)
        return self.id.getFluidFlowRate()
    end,

    setOn = function(self, status)
        self.id.setActive(status)
    end,
    setCoils = function(self, status)
        self.id.setInductorEngaged(status)
    end,
    setSteamIn = function(self, amount)
        self.id.setFluidFlowRateMax(amount)
    end

}

function _G.newTurbine(name,id, side, type)
    local turbine = {}
    setmetatable(turbine,{__index = Turbine})

    turbine.name = name
    turbine.id = id
    turbine.side = side
    turbine.type = type

    return turbine
end







