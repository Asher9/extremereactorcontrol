-- Reactor / Turbine Control
-- (c) 2017 Thor_s_Crafter
-- Version 3.0


--Peripherals
_G.monitors = {} --Monitor
_G.controlMonitor = "" --Monitor
_G.reactors = {} --Reactor
_G.capacitors = {} --Energy Storage
_G.turbines = {} --Turbines

--Total count of all turbines
_G.amountTurbines = 0
_G.amountMonitors = 0
_G.amountCapacitors = 0
_G.amountReactors = 0

local function searchPeripherals()
    local peripheralList = peripheral.getNames()
    for i = 1, #peripheralList do
        local periItem = peripheralList[i]
        local periType = peripheral.getType(periItem)
        local peri = peripheral.wrap(periItem)
        
        if periType == "BigReactors-Reactor" then
            print("Reactor - "..periItem)
            _G.reactors[#_G.reactors + 1] = newReactor("r" .. tostring(#_G.reactors + 1), peri, periItem, periType)
        elseif periType == "BigReactors-Turbine" then
            print("Turbine - "..periItem)
            _G.turbines[#_G.turbines + 1] = newTurbine("t" .. tostring(#_G.turbines + 1), peri, periItem, periType)
        elseif periType == "BiggerReactors_Reactor" then
            print("BiggerReactor Reactor - "..periItem)
            _G.reactors[#_G.reactors + 1] = newBiggerReactor("r" .. tostring(#_G.reactors + 1), peri, periItem, periType)
        elseif periType == "BiggerReactors_Turbine" then
            print("BiggerReactor Turbine - "..periItem)
            _G.turbines[#_G.turbines + 1] = newBiggerTurbine("t" .. tostring(#_G.turbines + 1), peri, periItem, periType)
        elseif periType == "monitor" then
            print("Monitor - "..periItem)
			if(peripheralList[i] == controlMonitor) then
				--add to output monitors
				_G.monitors[amountMonitors] = peripheral.wrap(peripheralList[i])
				_G.amountMonitors = amountMonitors + 1
			else
				_G.controlMonitor = peripheral.wrap(peripheralList[i])
				_G.touchpointLocation = periItem
			end
        else
            local successGetEnergyStored, errGetEnergyStored = pcall(function() peri.getEnergyStored() end)
            local successGetEnergy, errGetEnergy = pcall(function() peri.getEnergy() end)

            if successGetEnergyStored then
			    --Capacitorbank / Energycell / Energy Core
                print("getEnergyStored() device - "..peripheralList[i])
                _G.capacitors[#_G.capacitors + 1] = newEnergyStorage("e" .. tostring(#_G.capacitors + 1), peri, periItem, periType)
            end

            if successGetEnergy then
			    --Mekanism / others
                print("getEnergy() device - "..peripheralList[i])
                _G.capacitors[#_G.capacitors + 1] = newMekanismEnergyStorage("e" .. tostring(#_G.capacitors + 1), peri, periItem, periType)
            end

        end
    end
end

local function checkPeripherals()
	--Check for errors
	term.clear()
	term.setCursorPos(1,1)

    if _G.reactors[1] == nil then
        error("No reactor found!")
    end
	if controlMonitor == "" then
        error("Monitor not found!\nPlease check and reboot the computer (Press and hold Ctrl+R)")
	end

    --Monitor clear
	controlMonitor.setBackgroundColor(colors.black)
	controlMonitor.setTextColor(colors.red)
	controlMonitor.clear()
	controlMonitor.setCursorPos(1,1)
    
	--Monitor too small
	local monX,monY = controlMonitor.getSize()
	if monX < 71 or monY < 26 then
		controlMonitor.write("Monitor too small\n Must be at least 8 in length and 6 in height.\nPlease check and reboot the computer (Press and hold Ctrl+R)")
		error("Monitor too small.\nMust be at least 8 in length and 6 in height.\nPlease check and reboot the computer (Press and hold Ctrl+R)")
	end
    
	_G.amountReactors = amountReactors - 1
	_G.amountTurbines = amountTurbines - 1
	_G.amountCapacitors = amountCapacitors - 1
end


function _G.initPeripherals()
    searchPeripherals()
    checkPeripherals()
end


