-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --
-- Turbine control --

--Loads the touchpoint API
shell.run("cp /extreme-reactors-control/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")

--Loads the input API
shell.run("cp /extreme-reactors-control/config/input.lua /input")
os.loadAPI("input")
shell.run("rm input")

--Some variables
--Touchpoint init
local page = touchpoint.new(touchpointLocation)
--Buttons
local rOn
local rOff
local tOn
local tOff
local aTOn
local aTOff
local aTN = { "  -  ", label = "aTurbinesOn" }
local cOn
local cOff
--Last/Current turbine (for switching)
local lastStat = 0
local currStat = 0
--Last/Current TurbineSpeed (for checking)
local lastSpeed = {}
local currSpeed = {}
local speedFailCounter = {}

--Button renaming

rOn = { " On  ", label = "reactorOn" }
rOff = { " Off ", label = "reactorOn" }
tOn = { " On  ", label = "turbineOn" }
tOff = { " Off ", label = "turbineOn" }
aTOn = { " On ", label = "aTurbinesOn" }
aTOff = { " Off ", label = "aTurbinesOn" }
cOn = { " On  ", label = "coilsOn" }
cOff = { " Off ", label = "coilsOn" }


--Init auto mode
function startAutoMode()
    --Everything setup correctly?
    checkPeripherals()

    --Loads/Calculates the reactor's rod level
    findOptimalFuelRodLevel()

    --Clear display
    term.clear()
    term.setCursorPos(1, 1)

    --Display prints
    print("Getting all Turbines to " .. turbineTargetSpeed .. " RPM...")
    controlMonitor.setBackgroundColor(backgroundColor)
    controlMonitor.setTextColor(textColor)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1, 1)

    controlMonitor.write("Getting Turbines to " .. (input.formatNumberComma(turbineTargetSpeed)) .. " RPM. Please wait...")

    --Gets turbine to target speed
    --Init SpeedTables
    initSpeedTable()
    while not allAtTargetSpeed() do
        getToTargetSpeed()
        sleep(1)
        term.setCursorPos(1, 2)
        for i = 0, amountTurbines, 1 do
            local tSpeed = t[i].getRotorSpeed()

            print("Speed: " .. tSpeed .. "     ")

            --formatting and printing status
            controlMonitor.setTextColor(textColor)
            controlMonitor.setCursorPos(1, (i + 3))
            if i >= 16 then controlMonitor.setCursorPos(28, (i - 16 + 3)) end
            
            if (i + 1) < 10 then
                controlMonitor.write("Turbine 0" .. (i + 1) .. ": " .. (input.formatNumberComma(math.floor(tSpeed))) .. " RPM")
            else
                controlMonitor.write("Turbine " .. (i + 1) .. ": " .. (input.formatNumberComma(math.floor(tSpeed))) .. " RPM")
            end

            if tSpeed > turbineTargetSpeed then
                controlMonitor.setTextColor(colors.green)
                controlMonitor.write(" OK  ")
            else
                controlMonitor.setTextColor(colors.red)
                controlMonitor.write(" ...  ")
            end
        end
    end

    --Enable reactor and turbines
    reactor.setActive(true)
    allTurbinesOn()

    --Reset terminal
    term.clear()
    term.setCursorPos(1, 1)

    --Reset Monitor
    controlMonitor.setBackgroundColor(backgroundColor)
    controlMonitor.clear()
    controlMonitor.setTextColor(textColor)
    controlMonitor.setCursorPos(1, 1)

    --Creates all buttons
    createAllButtons()

    --Displays first turbine (default)
    printStatsAuto(0)

    --run
    clickEvent()
end

--Init manual mode
function startManualMode()
    --Everything setup correctly?
    checkPeripherals()
    --Creates all buttons
    createAllButtons()
    --Creates additional manual buttons
    createManualButtons()

    --Sets all turbine flow rates to maximum (if set different in auto mode)
    for i = 0, #t do
        t[i].setFluidFlowRateMax(targetSteam)
    end

    --Displays the first turbine (default)
    printStatsMan(0)

    --run
    clickEvent()
end

--Checks if all required peripherals are attached
function checkPeripherals()
    controlMonitor.setBackgroundColor(colors.black)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1, 1)
    controlMonitor.setTextColor(colors.red)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    --No turbine found
    if turbines[0] == nil then
        controlMonitor.write("Turbines not found! Please check and reboot the computer (Press and hold Ctrl+R)")
        error("Turbines not found! Please check and reboot the computer (Press and hold Ctrl+R)")
    end
    --No reactor found
    if reactor == "" then
        controlMonitor.write("Reactor not found! Please check and reboot the computer (Press and hold Ctrl+R)")
        error("Reactor not found! Please check and reboot the computer (Press and hold Ctrl+R)")
    end
    --No energy storage found
    if capacitors[0] == nill then
        controlMonitor.write("Energy Storage not found! Please check and reboot the computer (Press and hold Ctrl+R)")
        error("Energy Storage not found! Please check and reboot the computer (Press and hold Ctrl+R)")
    end
end

function getEnergy()
    local energyStore = 0

    for i =1, #capacitors do
        energyStore = energyStore + capacitors[i].getEnergyStored()
    end

    return energyStore
end

function getEnergyMax()
    local energyStore = 0

    for i =1, #capacitors do
        energyStore = energyStore + capacitors[i].getMaxEnergyStored()
    end

    return energyStore
end

function getEnergyPer()
    local en = getEnergy()
    local enMax = getEnergyMax()
    local enPer = math.floor(en / enMax * 100)
    return enPer
end

--Returns the current energy fill status of a turbine
function getTurbineEnergy(turbine)
    return turbines[turbine].getEnergyStored()
end

--Toggles the reactor status and the button
function toggleReactor()
    reactor.setActive(not reactor.getActive())
    page:toggleButton("reactorOn")
    if reactor.getActive() then
        page:rename("reactorOn", rOn, true)
    else
        page:rename("reactorOn", rOff, true)
    end
end

--Toggles one turbine status and button
function toggleTurbine(i)
    turbines[i].setActive(not turbines[i].getActive())
    page:toggleButton("turbineOn")
    if turbines[i].getActive() then
        page:rename("turbineOn", tOn, true)
    else
        page:rename("turbineOn", tOff, true)
    end
end

--Toggles one turbine coils and button
function toggleCoils(i)
    turbines[i].setInductorEngaged(not turbines[i].getInductorEngaged())
    page:toggleButton("coilsOn")
    if turbines[i].getInductorEngaged() then
        page:rename("coilsOn", cOn, true)
    else
        page:rename("coilsOn", cOff, true)
    end
end

--Enable all turbines (Coils engaged, FluidRate 2000mb/t)
function allTurbinesOn()
    for i = 0, amountTurbines, 1 do
        turbines[i].setActive(true)
        turbines[i].setInductorEngaged(true)
        turbines[i].setFluidFlowRateMax(targetSteam)
    end
end

--Disable all turbiens (Coils disengaged, FluidRate 0mb/t)
function allTurbinesOff()
    for i = 0, amountTurbines, 1 do
        turbines[i].setInductorEngaged(false)
        turbines[i].setFluidFlowRateMax(0)
    end
end

--Enable one turbine
function turbineOn(i)
    turbines[i].setInductorEngaged(true)
    turbines[i].setFluidFlowRateMax(targetSteam)
end

--Disable one turbine
function turbineOff(i)
    turbines[i].setInductorEngaged(false)
    turbines[i].setFluidFlowRateMax(0)
end

--Toggles all turbines (and buttons)
function toggleAllTurbines()
    page:rename("aTurbinesOn", aTOff, true)
    local onOff
    if turbines[0].getActive() then onOff = "off" else onOff = "on" end
    for i = 0, amountTurbines do
        if onOff == "off" then
            turbines[i].setActive(false)
            if page.buttonList["aTurbinesOn"].active then
                page:toggleButton("aTurbinesOn")
                page:rename("aTurbinesOn", aTOff, true)
            end
        else
            turbines[i].setActive(true)
            if not page.buttonList["aTurbinesOn"].active then
                page:toggleButton("aTurbinesOn")
                page:rename("aTurbinesOn", aTOn, true)
            end --if
        end --else
    end --for
end

--function

--Toggles all turbine coils (and buttons)
function toggleAllCoils()
    local coilsOnOff
    if turbines[0].getInductorEngaged() then coilsOnOff = "off" else coilsOnOff = "on" end
    for i = 0, amountTurbines do
        if coilsOnOff == "off" then
            turbines[i].setInductorEngaged(false)
            if page.buttonList["Coils"].active then
                page:toggleButton("Coils")
            end
        else
            turbines[i].setInductorEngaged(true)
            if not page.buttonList["Coils"].active then
                page:toggleButton("Coils")
            end
        end
    end
end

--Calculates/Reads the optiomal reactor rod level
function findOptimalFuelRodLevel()

    --Load config?
    if not (math.floor(rodLevel) == 0) then
        reactor.setAllControlRodLevels(rodLevel)
    else
        --Get reactor below 99c
        getTo99c()

        --Enable reactor + turbines
        reactor.setActive(true)
        allTurbinesOn()

        --Calculation variables
        local controlRodLevel = 99
        local diff = 0
        local targetSteamOutput = targetSteam * (amountTurbines + 1)
        local targetLevel = 99

        --Display
        controlMonitor.setBackgroundColor(backgroundColor)
        controlMonitor.setTextColor(textColor)
        controlMonitor.clear()

        print("TargetSteam: " .. targetSteamOutput)

        controlMonitor.setCursorPos(1, 1)
        controlMonitor.write("Finding optimal FuelRod Level...")
        controlMonitor.setCursorPos(1, 3)
        controlMonitor.write("Calculating Level...")
        controlMonitor.setCursorPos(1, 5)
        controlMonitor.write("Target Steam-Output: " .. (input.formatNumberComma(math.floor(targetSteamOutput))) .. "mb/t")

        --Calculate Level based on 2 values
        local failCounter = 0
        while true do
            reactor.setAllControlRodLevels(controlRodLevel)
            sleep(2)
            local steamOutput1 = reactor.getHotFluidProducedLastTick()
            print("SO1: " .. steamOutput1)
            reactor.setAllControlRodLevels(controlRodLevel - 1)
            sleep(5)
            local steamOutput2 = reactor.getHotFluidProducedLastTick()
            print("SO2: " .. steamOutput2)
            diff = steamOutput2 - steamOutput1
            print("Diff: " .. diff)

            targetLevel = 100 - math.floor(targetSteamOutput / diff)
            print("Target: " .. targetLevel)

            --Check target level
            if targetLevel < 0 or targetLevel == "-inf" then

                --Calculation failed 3 times?
                if failCounter > 2 then
                    controlMonitor.setBackgroundColor(colors.black)
                    controlMonitor.clear()
                    controlMonitor.setTextColor(colors.red)
                    controlMonitor.setCursorPos(1, 1)
                    
                    controlMonitor.write("RodLevel calculation failed!")
                    controlMonitor.setCursorPos(1, 2)
                    controlMonitor.write("Calculation would be < 0!")
                    controlMonitor.setCursorPos(1, 3)
                    controlMonitor.write("Please check Steam/Water input!")

                    --Disable reactor and turbines
                    reactor.setActive(false)
                    allTurbinesOff()
                    for i = 1, amountTurbines do
                        turbines[i].setActive(false)
                    end


                    term.clear()
                    term.setCursorPos(1, 1)
                    print("Target RodLevel: " .. targetLevel)
                    error("Failed to calculate RodLevel!")

                else
                    failCounter = failCounter + 1
                    sleep(2)
                end

                print("FailCounter: " .. failCounter)

            else
                break
            end
        end

        --RodLevel calculation successful
        print("RodLevel calculation successful!")
        reactor.setAllControlRodLevels(targetLevel)
        controlRodLevel = targetLevel

        --Find precise level
        while true do
            sleep(5)
            local steamOutput = reactor.getHotFluidProducedLastTick()

            controlMonitor.setCursorPos(1, 3)
            controlMonitor.write("FuelRod Level: " .. controlRodLevel .. "  ")

            controlMonitor.setCursorPos(1, 6)
            controlMonitor.write("Current Steam-Output: " .. (input.formatNumberComma(steamOutput)) .. "mb/t    ")

            --Level too big
            if steamOutput < targetSteamOutput then
                controlRodLevel = controlRodLevel - 1
                reactor.setAllControlRodLevels(controlRodLevel)
            else
                reactor.setAllControlRodLevels(controlRodLevel)
                rodLevel = controlRodLevel
                saveOptionFile()
                print("Target RodLevel: " .. controlRodLevel)
                sleep(2)
                break
            end --else
        end --while
    end --else
end

--function

--Gets the reactor below 99c
function getTo99c()
    controlMonitor.setBackgroundColor(backgroundColor)
    controlMonitor.setTextColor(textColor)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1, 1)

    controlMonitor.write("Getting Reactor below 99c ...")

    --Disables reactor and turbines
    reactor.setActive(false)
    allTurbinesOn()

    --Temperature variables
    local fTemp = reactor.getFuelTemperature()
    local cTemp = reactor.getCasingTemperature()
    local isNotBelow = true

    --Wait until both values are below 99
    while isNotBelow do
        term.setCursorPos(1, 2)
        print("CoreTemp: " .. fTemp .. "      ")
        print("CasingTemp: " .. cTemp .. "      ")

        fTemp = reactor.getFuelTemperature()
        cTemp = reactor.getCasingTemperature()

        if fTemp < 99 then
            if cTemp < 99 then
                isNotBelow = false
            end
        end

        sleep(1)
    end --while
end

--function

--Checks the current energy level and controlls turbines/reactor
--based on user settings (reactorOn, reactorOff)
function checkEnergyLevel()
    printStatsAuto(currStat)
    --Level > user setting (default: 90%)
    if getEnergyPer() >= reactorOffAt then
        print("Energy >= reactorOffAt")
        if turbineOnOff == "on" then
            allTurbinesOn()
        elseif turbineOnOff == "off" then
            allTurbinesOff()
        end
        reactor.setActive(false)
        --Level < user setting (default: 50%)
    elseif getEnergyPer() <= reactorOnAt then
        reactor.setActive(true)
        for i = 0, amountTurbines do
            turbines[i].setFluidFlowRateMax(targetSteam)
            if turbines[i].getRotorSpeed() < turbineTargetSpeed * 0.98 then
                turbines[i].setInductorEngaged(false)
            end
            if turbines[i].getRotorSpeed() > turbineTargetSpeed * 1.02 then
                turbines[i].setInductorEngaged(true)
            end
        end

    else
        if reactor.getActive() then
            for i = 0, amountTurbines do
                if turbines[i].getRotorSpeed() < turbineTargetSpeed * 0.98 then
                    turbines[i].setInductorEngaged(false)
                end
                if turbines[i].getRotorSpeed() > turbineTargetSpeed * 1.02 then
                    turbines[i].setInductorEngaged(true)
                end
            end --for
        end --if
    end --else
end

--Sets the tables for checking the current turbineSpeeds
function initSpeedTable()
    for i = 0, amountTurbines do
        lastSpeed[i] = 0
        currSpeed[i] = 0
        speedFailCounter[i] = 0
    end
end

--Gets turbines to targetSpeed
function getToTargetSpeed()
    for i = 0, amountTurbines, 1 do

        --Get the current speed of the turbine
        local tspeed = turbines[i].getRotorSpeed()

        --Control turbines
        if tspeed <= turbineTargetSpeed then
            reactor.setActive(true)
            turbines[i].setActive(true)
            turbines[i].setInductorEngaged(false)
            turbines[i].setFluidFlowRateMax(targetSteam)
        end
        if turbines[i].getRotorSpeed() > turbineTargetSpeed then
            turbineOff(i)
        end


        --Not working yet - Needs reworking
        --        --Write speed to the currSpeed table
        --        currSpeed[i] = tspeed
        --
        --        --Check turbine speed progression
        --        if currSpeed[i] < lastSpeed[i]-50 then
        --
        --            print(speedFailCounter)
        --
        --            --Return error message
        --            if speedFailCounter[i] >= 3 then
        --                controlMonitor.setBackgroundColor(colors.black)
        --                controlMonitor.clear()
        --                controlMonitor.setTextColor(colors.red)
        --                controlMonitor.setCursorPos(1, 1)
        --                    controlMonitor.write("Turbines can't get to speed!")
        --                    controlMonitor.setCursorPos(1,2)
        --                    controlMonitor.write("Please check your Steam-Input!")
        --                    error("Turbines can't get to speed!")
        --            --increase speedFailCounter
        --            else
        --                speedFailCounter[i] = speedFailCounter[i] + 1
        --            end
        --        end
        --
        --        --Write speed to the lastSpeed table
        --        lastSpeed[i] = tspeed
    end
end

--Returns true if all turbines are at targetSpeed
function allAtTargetSpeed()
    for i = 0, amountTurbines do
        if turbines[i].getRotorSpeed() < turbineTargetSpeed then
            return false
        end
    end
    return true
end

--Runs another program
function run(program)
    shell.run(program)
    shell.completeProgram("/extreme-reactors-control/program/turbineControl.lua")
    error("terminated.")
end

--Creates all required buttons
function createAllButtons()
    local x1 = 40
    local x2 = 47
    local x3 = 54
    local x4 = 61
    local y = 4

    --Turbine buttons
    for i = 0, amountTurbines, 1 do
        if overallMode == "auto" then
            if i <= 7 then
                page:add("#" .. (i + 1), function() printStatsAuto(i) end, x1, y, x1 + 5, y)
            elseif (i > 7 and i <= 15) then
                page:add("#" .. (i + 1), function() printStatsAuto(i) end, x2, y, x2 + 5, y)
            elseif (i > 15 and i <= 23) then
                page:add("#" .. (i + 1), function() printStatsAuto(i) end, x3, y, x3 + 5, y)
            elseif i > 23 then
                page:add("#" .. (i + 1), function() printStatsAuto(i) end, x4, y, x4 + 5, y)
            end
            if (i == 7 or i == 15 or i == 23) then y = 4
            else y = y + 2
            end

        elseif overallMode == "manual" then
            if i <= 7 then
                page:add("#" .. (i + 1), function() printStatsMan(i) end, x1, y, x1 + 5, y)
            elseif (i > 7 and i <= 15) then
                page:add("#" .. (i + 1), function() printStatsMan(i) end, x2, y, x2 + 5, y)
            elseif (i > 15 and i <= 23) then
                page:add("#" .. (i + 1), function() printStatsMan(i) end, x3, y, x3 + 5, y)
            elseif i > 23 then
                page:add("#" .. (i + 1), function() printStatsMan(i) end, x4, y, x4 + 5, y)
            end
            if (i == 7 or i == 15 or i == 23) then y = 4
            else y = y + 2
            end
        end --mode
    end --for

    --Other buttons
    page:add("Main Menu", function() run("/extreme-reactors-control/start/menu.lua") end, 2, 23, 17, 23)
        
    page:draw()
end

--Creates (additional) manual buttons
function createManualButtons()
    page:add("reactorOn", toggleReactor, 11, 11, 15, 11)
    page:add("Coils", toggleAllCoils, 25, 17, 31, 17)
    page:add("aTurbinesOn", toggleAllTurbines, 18, 17, 23, 17)
    page:rename("aTurbinesOn", aTN, true)

    --Switch reactor button?
    if reactor.getActive() then
        page:rename("reactorOn", rOn, true)
        page:toggleButton("reactorOn")
    else
        page:rename("reactorOn", rOff, true)
    end

    --Turbine buttons on/off
    page:add("turbineOn", function() toggleTurbine(currStat) end, 20, 13, 24, 13)
    if turbines[currStat].getActive() then
        page:rename("turbineOn", tOn, true)
        page:toggleButton("turbineOn")
    else
        page:rename("turbineOn", tOff, true)
    end

    -- Turbinen buttons (Coils)
    page:add("coilsOn", function() toggleCoils(currStat) end, 9, 15, 13, 15)
    if turbines[currStat].getInductorEngaged() then
        page:rename("coilsOn", cOn, true)
    else
        page:rename("coilsOn", cOff, true)
    end
    page:draw()
end

--Checks for events (timer/clicks)
function clickEvent()

    while true do

        --refresh screen
        if overallMode == "auto" then
            checkEnergyLevel()
        elseif overallMode == "manual" then
            printStatsMan(currStat)
        end

        --timer
        local timer1 = os.startTimer(1)

        while true do
            --gets the event
            local event, p1 = page:handleEvents(os.pullEvent())
            print(event .. ", " .. p1)

            --execute a buttons function if clicked
            if event == "button_click" then
                page:flash(p1)
                page.buttonList[p1].func()
                break
            elseif event == "timer" and p1 == timer1 then
                break
            end
        end
    end
end

--displays all info on the screen (auto mode)
function printStatsAuto(turbine)
    --refresh current turbine
    currStat = turbine

    --toggles turbine buttons if pressed (old button off, new button on)
    if not page.buttonList["#" .. currStat + 1].active then
        page:toggleButton("#" .. currStat + 1)
    end
    if currStat ~= lastStat then
        if page.buttonList["#" .. lastStat + 1].active then
            page:toggleButton("#" .. lastStat + 1)
        end
    end

    --gets overall energy production
    local rfGen = 0
    for i = 0, amountTurbines, 1 do
        rfGen = rfGen + turbines[i].getEnergyProducedLastTick()
    end

    --prints the energy level (in %)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))
    controlMonitor.setTextColor(tonumber(textColor))

    controlMonitor.setCursorPos(2, 2)
    
        controlMonitor.write("Energy: " .. getEnergyPer() .. "%  ")


    --prints the energy bar
    local part1 = getEnergyPer() / 5
    controlMonitor.setCursorPos(2, 3)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(2, 3)
    for i = 1, part1 do
        controlMonitor.write(" ")
    end
    controlMonitor.setTextColor(textColor)

    --prints the overall energy production
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    controlMonitor.setCursorPos(2, 5)
    
        controlMonitor.write("RF-Production: " .. (input.formatNumberComma(math.floor(rfGen))) .. " RF/t      ")

    --Reactor status (on/off)
    controlMonitor.setCursorPos(2, 7)
    
    controlMonitor.write("Reactor: ")
    if reactor.getActive() then
        controlMonitor.setTextColor(colors.green)
        controlMonitor.write("on ")
    end
    if not reactor.getActive() then
        controlMonitor.setTextColor(colors.red)
        controlMonitor.write("off")
    end
        
    --Prints all other informations (fuel consumption,steam,turbine amount,mode)
    controlMonitor.setTextColor(tonumber(textColor))
    controlMonitor.setCursorPos(2, 9)
    local fuelCons = tostring(r.getFuelConsumedLastTick())
    local fuelCons2 = string.sub(fuelCons, 0, 4)
    local eff = math.floor(rfGen / reactor.getFuelConsumedLastTick())
    if not reactor.getActive() then eff = 0 end
    
    controlMonitor.write("Fuel Consumption: " .. fuelCons2 .. "mb/t     ")
    controlMonitor.setCursorPos(2, 10)
    controlMonitor.write("Steam: " .. (input.formatNumberComma(math.floor(reactor.getHotFluidProducedLastTick()))) .. "mb/t    ")
    controlMonitor.setCursorPos(2, 11)
    controlMonitor.write("Efficiency: " .. (input.formatNumberComma(eff)) .. " RF/mb       ")
    controlMonitor.setCursorPos(40, 2)
    controlMonitor.write("Turbines: " .. (amountTurbines + 1) .. "  ")
    controlMonitor.setCursorPos(2, 13)
    controlMonitor.write("-- Turbine " .. (turbine + 1) .. " --")

    --Currently selected turbine details

    --coils
    controlMonitor.setCursorPos(2, 14)
    controlMonitor.write("Coils: ")

    if turbines[turbine].getInductorEngaged() then
        controlMonitor.setTextColor(colors.green)
        controlMonitor.write("engaged     ")
    end
    if turbines[turbine].getInductorEngaged() == false then
        controlMonitor.setTextColor(colors.red)
        controlMonitor.write("disengaged")
    end
    controlMonitor.setTextColor(tonumber(textColor))

    --rotor speed/RF-production
    controlMonitor.setCursorPos(2, 15)

    controlMonitor.write("Rotor Speed: ")
    controlMonitor.write((input.formatNumberComma(math.floor(turbines[turbine].getRotorSpeed()))) .. " RPM    ")
    controlMonitor.setCursorPos(2, 15)
    controlMonitor.write("RF-Production: " .. (input.formatNumberComma(math.floor(turbines[turbine].getEnergyProducedLastTick()))) .. " RF/t           ")

    --Internal buffer of the turbine
    controlMonitor.setCursorPos(2, 16)
    
    controlMonitor.write("Internal Energy: ")
    controlMonitor.write(input.formatNumberComma(math.floor(getTurbineEnergy(turbine))) .. " RF          ")

    --prints the current program version
    controlMonitor.setCursorPos(2, 25)
    controlMonitor.write("Version " .. version)

    --refreshes the last turbine id
    lastStat = turbine
end

--printStats (manual)
function printStatsMan(turbine)
    --refresh current turbine
    currStat = turbine

    --toggles turbine buttons if pressed (old button off, new button on)
    if not page.buttonList["#" .. currStat + 1].active then
        page:toggleButton("#" .. currStat + 1)
    end
    if currStat ~= lastStat then
        if page.buttonList["#" .. lastStat + 1].active then
            page:toggleButton("#" .. lastStat + 1)
        end
    end

    --On/Off buttons
    if turbines[currStat].getActive() and not page.buttonList["turbineOn"].active then
        page:rename("turbineOn", tOn, true)
        page:toggleButton("turbineOn")
    end
    if not turbines[currStat].getActive() and page.buttonList["turbineOn"].active then
        page:rename("turbineOn", tOff, true)
        page:toggleButton("turbineOn")
    end
    if turbines[currStat].getInductorEngaged() and not page.buttonList["coilsOn"].active then
        page:rename("coilsOn", cOn, true)
        page:toggleButton("coilsOn")
    end
    if not turbines[currStat].getInductorEngaged() and page.buttonList["coilsOn"].active then
        page:rename("coilsOn", cOff, true)
        page:toggleButton("coilsOn")
    end

    --prints the energy level (in %)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))
    controlMonitor.setTextColor(tonumber(textColor))

    controlMonitor.setCursorPos(2, 2)
    
    controlMonitor.write("Energy: " .. getEnergyPer() .. "%  ")

    --prints the energy bar
    local part1 = getEnergyPer() / 5
    controlMonitor.setCursorPos(2, 3)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(2, 3)
    for i = 1, part1 do
        controlMonitor.write(" ")
    end
    controlMonitor.setTextColor(textColor)

    --prints the overall energy production
    local rfGen = 0
    for i = 0, amountTurbines, 1 do
        rfGen = rfGen + turbines[i].getEnergyProducedLastTick()
    end

    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    --Other status informations
    controlMonitor.setCursorPos(2, 5)
    controlMonitor.write("RF-Production: " .. (input.formatNumberComma(math.floor(rfGen))) .. " RF/t      ")
    controlMonitor.setCursorPos(2, 7)
    local fuelCons = tostring(reactor.getFuelConsumedLastTick())
    local fuelCons2 = string.sub(fuelCons, 0, 4)
    controlMonitor.write("Fuel Consumption: " .. fuelCons2 .. "mb/t     ")
    controlMonitor.setCursorPos(2, 9)
    controlMonitor.write("Rotor Speed: ")
    controlMonitor.write((input.formatNumberComma(math.floor(turbines[turbine].getRotorSpeed()))) .. " RPM     ")
    controlMonitor.setCursorPos(2, 11)
    controlMonitor.write("Reactor: ")
    controlMonitor.setCursorPos(2, 13)
    controlMonitor.write("Current Turbine: ")
    controlMonitor.setCursorPos(2, 17)
    controlMonitor.write("All Turbines: ")
        
    controlMonitor.setCursorPos(2, 15)
    controlMonitor.write("Coils: ")

    controlMonitor.setCursorPos(40, 2)
    controlMonitor.write("Turbines: " .. (amountTurbines + 1) .. "  ")

    --prints the current program version
    controlMonitor.setCursorPos(2, 25)
    controlMonitor.write("Version " .. version)

    --refreshes the last turbine id
    lastStat = turbine
end

--program start
if overallMode == "auto" then
    startAutoMode()
elseif overallMode == "manual" then
    startManualMode()
end
