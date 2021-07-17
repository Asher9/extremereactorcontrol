-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local BiggerReactor = {
    name = "",
    id = {},
    side = "",
    type = "",

    active = function(self)
        return self.id.active()
    end,
    controlRodLevel = function(self)
        return self.id.getControlRod(0).level()
    end,
    controlRodCount = function(self)
        return self.id.controlRodCount()
    end,
    energy = function(self)
        return self.id.battery().stored()
    end,
    fuelTemp = function(self)
        return self.id.fuelTemperature()
    end,
    casingTemp = function(self)
        return self.id.casingTemperature()
    end,
    fuel = function(self)
        return self.id.fuelTank().fuel()
    end,
    maxFuel = function(self)
        return self.id.fuelTank().capacity()
    end,
    fuelPer = function(self)
        return math.floor(self:fuel()/self:maxFuel()*100)
    end,
    waste = function(self)
        return self.id.fuelTank().waste()
    end,
    energyProduction = function(self)
        return self.id.getEnergyProducedLastTick()
    end,
    steamOutput = function(self)
        return self.id.coolantTank().hotFluidAmount()
    end,
    fuelConsumption = function(self)
        return self.id.fuelTank().burnedLastTick()
    end,
    activeCooling = function(self)
        return self.id.transitionedLastTick() > 1
    end,

    setOn = function(self,status)
        self.id.setActive(status)
    end,
    setRodLevel = function(self,level)
        self.id.setAllControlRodLevels(level)
    end
}


function _G.newBiggerReactor(name,id, side, type)
    local reactor = {}
    setmetatable(reactor,{__index=BiggerReactor})

    reactor.name = name
    reactor.id = id
    reactor.side = side
    reactor.type = type

    return reactor
end






