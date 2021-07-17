-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local BiggerTurbine = {
    name = "",
    id = {},
    side = "",
    type = "",

    active = function(self)
        return self.id.active()
    end,
    coilsEngaged = function(self)
        return self.id.coilEngaged()
    end,
    rotorSpeed = function(self)
        return self.id.rotor.RPM()
    end,
    energy = function(self)
        return self.id.battery.stored()
    end,
    energyProduction = function(self)
        return self.id.battery.producedLastTick()
    end,
    steamIn = function(self)
        return self.id.fluidTank.flowLastTick()
    end,

    setOn = function(self, status)
        self.id.setActive(status)
    end,
    setCoils = function(self, status)
        self.id.setCoilEngaged(status)
    end,
    setSteamIn = function(self, amount)
        self.id.fluidTank.setNominalFlowRate(amount)
    end

}

function _G.newBiggerTurbine(name,id, side, type)
    print("Creating new Bigger Reactors Turbine")
    local turbine = {}
    setmetatable(turbine,{__index = BiggerTurbine})

    print("Settings Name -> ".. name)
    turbine.name = name
    print("Settings Id -> ".. id)
    turbine.id = id
    print("Settings Side -> ".. side)
    turbine.side = side
    print("Settings Type -> ".. type)
    turbine.type = type

    return turbine
end







