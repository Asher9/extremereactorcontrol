-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --
-- Installer (English) --


--===== Local Variables =====

local arg = {... }
local update
local branch = ""
local repoUrl = "https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/raw/"

--Program arguments for updates
if #arg == 0 then

  --No update
  update = false
  branch = "main"

elseif #arg == 2 then

 --Select branch
 if arg[2] == "stable" then branch = "main"
 elseif arg[2] == "main" then branch = "main"
 elseif arg[2] == "develop" then branch = "develop"
 elseif arg[2] == "unstable" then branch = "develop"
 else
   error("Invalid 2nd argument!")
 end
  if arg[1] == "update" then
    --Update!
    update = true
  elseif arg[1] == "install" then
    update = false
  else
    error("Invalid 1st argument!")
  end

else
  error("0 or 2 arguments required!")
end

--Url for file downloads
local relUrl = repoUrl..branch.."/"


--===== Functions =====

--Writes the files to the computer
function writeFile(path)
	local file = fs.open("/extreme-reactors-control/"..path,"w")
	local content = getURL(path);
	file.write(content)
	file.close()
end

--Resolve the right url
function getURL(path)
	local gotUrl = http.get(relUrl..path)
	if gotUrl == nil then
		clearTerm()
		error("File not found! Please check!\nFailed at "..relUrl..path)
	else
		return gotUrl.readAll()
	end
end


--===== Run installation =====

--First time installation
if not update then
  --Description
  term.clear()
  term.setCursorPos(1,1)
  print("Extreme Reactors Control by SeekerOfHonjo")
  print("Version 1.0")
  print()
  print("About this program:")
  print("The program controls one ExtremeReactors reactor.")
  print("You can also attach up to 32 turbines.")
  print("You must connect the computer with Wired Modems to the reactor (and the turbines).")
  print("Additionally some kind of Energy Storage and a monitor is required.")
  print("The size of the monitor has to be at least 8 wide and 6 high.")
  print("If set up with turbines, the reactor must be able to produce at least 2000mb/t of steam per turbine.")
  print()
  write("Press Enter...")
  leer = read()

  --Computer label
  local out = true
  while out do
    term.clear()
    term.setCursorPos(1,1)
    print("It is recommended to label the computer.")
    term.write("Do you want to label the computer? (y/n): ")

    local input = read()
    if input == "y" then
      print()
      shell.run("label set \"ReactorControlComputer\"")
      print()
      print("ComputerLabel set to \"ReactorControlComputer\".")
      print()
      sleep(2)
      out = false

    elseif input == "n" then
      print()
      print("ComputerLabel not set.")
      print()
      out = false
    end
  end

  --Startup
  local out2 = true
  while out2 do
    term.clear()
    term.setCursorPos(1,1)
    print("It is recommended to add the program to the computers' startup.")
    print("If you add the program to the startup, the program will automatically run when the computer is started.")
    term.write("Add startup? (y/n): ")

    local input = read()
    if input == "y" then
      local file = fs.open("startup","w")
      file.writeLine("shell.run(\"/extreme-reactors-control/start/start.lua\")")
      file.close()
      print()
      print("Startup installed.")
      print()
      out2 = false
    end
    if input == "n" then
      print()
      print("Startup not installed.")
      print()
      out2 = false
    end
  end

  sleep(1)
end --update

term.clear()
term.setCursorPos(1,1)

print("Checking and deleting existing files...")
--Removes old files
if fs.exists("/extreme-reactors-control/program/") then
  shell.run("rm /extreme-reactors-control/")
end

--Download all program parts
print("Getting new files...")

--Config
term.write("Config files...")
writeFile("config/input.lua")
writeFile("config/options.txt")
writeFile("config/touchpoint.lua")
print("     Done.")

--Classes
term.write("Classes files...")
writeFile("classes/Language.lua")
writeFile("classes/Peripherals.lua")
writeFile("classes/base/EnergyStorage.lua")
writeFile("classes/base/Reactor.lua")
writeFile("classes/base/Turbine.lua")
writeFile("classes/mekanism/EnergyStorage.lua")
writeFile("classes/bigger_reactors/Reactor.lua")
writeFile("classes/bigger_reactors/Turbine.lua")
print("     Done.")

--Install
term.write("Install files...")
writeFile("install/installer.lua")
print("     Done.")

--Program
term.write("Program files...")
writeFile("program/editOptions.lua")
writeFile("program/reactorControl.lua")
writeFile("program/turbineControl.lua")
print("     Done.")

--Start
term.write("Start files...")
writeFile("start/menu.lua")
writeFile("start/start.lua")
print("     Done.")

term.clear()
term.setCursorPos(1,1)

--Refresh startup (if installed)
if fs.exists("startup") then
  shell.run("rm startup")
  local file = fs.open("startup","w")
  file.writeLine("shell.run(\"/extreme-reactors-control/start/start.lua\")")
  file.close()
end

--Install complete
term.clear()
term.setCursorPos(1,1)

if not update then
  print("Installation successful!")
  print("The program is now ready to run!")
  print()
  term.setTextColor(colors.green)
  print()
  print("Thanks for using my program! ;)")
  print("I hope you like it.")
  print()
  print("SeekerOfHonjo")
  print("(c) 2021")

  local x,y = term.getSize()
  term.setTextColor(colors.yellow)
  term.setCursorPos(1,y)
  term.write("Reboot in ")
  for i=5,0,-1 do
    term.setCursorPos(11,y)
    term.write(i)
    sleep(1)
  end
end

shell.completeProgram("/extreme-reactors-control/install/installer.lua")


