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
_G.smallMonitor = 1

local function searchPeripherals()
    local peripheralList = peripheral.getNames()
    for i = 1, #peripheralList do
        local periItem = peripheralList[i]
        local periType = peripheral.getType(periItem)
        local peri = peripheral.wrap(periItem)
        
        if periType == "BigReactors-Reactor" then
            print("Reactor - "..periItem)
            _G.reactors[amountReactors] = newReactor("r" .. tostring(amountReactors), peri, periItem, periType)
            _G.amountReactors = amountReactors + 1
        elseif periType == "BigReactors-Turbine" then
            print("Turbine - "..periItem)
            _G.turbines[amountTurbines] = newTurbine("t" .. tostring(amountTurbines), peri, periItem, periType)
            _G.amountTurbines = amountTurbines + 1
        elseif periType == "BiggerReactors_Reactor" then
            print("BiggerReactor Reactor - "..periItem)
            _G.reactors[amountReactors] = newBiggerReactor("r" .. tostring(amountReactors), peri, periItem, periType)
            _G.amountReactors = amountReactors + 1
        elseif periType == "BiggerReactors_Turbine" then
            print("BiggerReactor Turbine - "..periItem)
            _G.turbines[amountTurbines] = newBiggerTurbine("t" .. tostring(amountTurbines), peri, periItem, periType)
            _G.amountTurbines = amountTurbines + 1
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
            local successMekV10Plus, errMekV10Plus = pcall(function() peri.getTotalEnergyFilledPercentage() end)

            if successGetEnergyStored and (successGetEnergy == false) then
			    --Capacitorbank / Energycell / Energy Core
                print("getEnergyStored() device - "..peripheralList[i])
                _G.capacitors[amountCapacitors] = newEnergyStorage("e" .. tostring(amountCapacitors), peri, periItem, periType)
                _G.amountCapacitors = amountCapacitors + 1
            end

            if successGetEnergy then
			    --Mekanism / others
                print("getEnergy() device - "..peripheralList[i])
                _G.capacitors[amountCapacitors] = newMekanismEnergyStorage("e" .. tostring(amountCapacitors), peri, periItem, periType)
                _G.amountCapacitors = amountCapacitors + 1
            end

            if successGetEnergy then
			    --Mekanism V10plus 
                print("getTotalEnergyFilledPercentage() device - "..peripheralList[i])
                _G.capacitors[amountCapacitors] = newMekanismEnergyStorageV10plus("e" .. tostring(amountCapacitors), peri, periItem, periType)
                _G.amountCapacitors = amountCapacitors + 1
            end

            

        end
    end

	_G.amountReactors = amountReactors - 1
	_G.amountTurbines = amountTurbines - 1
	_G.amountCapacitors = amountCapacitors - 1
end

function _G.checkPeripherals()
	--Check for errors
	term.clear()
	term.setCursorPos(1,1)

    if _G.reactors[0] == nil then
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

    if amountTurbines < 33 then
        _G.smallMonitor = 1
        if monX < 71 or monY < 26 then
            local messageOut = string.gsub(string.gsub(_G.language:getText("monitorSize"), "8","7"),"6","4")
            controlMonitor.write(messageOut)
            error(messageOut)
        end
    else
        _G.smallMonitor = 0
        if monX < 82 or monY < 40 then
            local messageOut = _G.language:getText("monitorSize");
            controlMonitor.write(messageOut)
            error(messageOut)
        end
    end
end


function _G.initPeripherals()
    searchPeripherals()
    _G.checkPeripherals()
end


