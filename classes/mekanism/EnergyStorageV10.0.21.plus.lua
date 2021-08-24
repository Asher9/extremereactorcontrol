-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local MekanismEnergyStorageV10plus = {
    name = "",
    id = {},
    side = "",
    type = "",
    
    energy = function(self)
        return self.id.getTotalEnergy()
    end,
    capacity = function(self)
        return self.id.getTotalMaxEnergy()
    end,
    percentage = function(self)
        return math.floor(self:energy()/self:capacity()*100)
    end,
    percentagePrecise = function(self)
        return self:energy()/self:capacity()*100
    end
}

function _G.newMekanismEnergyStorageV10plus(name,id, side, type)
    print("Creating new Mekanism EnergyCube Storage")
    local storage = {}
    setmetatable(storage,{__index=MekanismEnergyStorageV10plus})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end
    
    storage.name = name
    storage.id = id
    storage.side = side
    storage.type = type

    return storage
end








