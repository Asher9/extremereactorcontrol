-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 2.6 --
-- Installer (English) --


--===== Local Variables =====

local arg = {... }
local update
local branch = ""
local repoUrl = "https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/raw/"
local selectedLang = {}
local installLang = "en"

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

function getLanguage()
  if not update then    
    languages = downloadAndRead("supportedLanguages.txt")
    downloadAndExecuteClass("Language.lua")
    for k, v in pairs(languages) do
      print(k..") "..v)
    end
    term.write("Language? ")

	  installLang = read()if languages[installLang] == nil then
      error("Language not found!")
    else
      writeFile("lang/"..installLang..".txt")
      selectedLang = _G.newLanguageById(installLang)
    end
  else
    downloadAndExecuteClass("Language.lua")
    writeFile("lang/"..installLang..".txt")
    selectedLang = _G.newLanguageById(_G.lang)
  end

	print(selectedLang.text.language)
end

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
    term.clear()
		error("File not found! Please check!\nFailed at "..relUrl..path)
	else
		return gotUrl.readAll()
	end
end

function downloadAndRead(fileName)
	writeFile(fileName)
	local fileData = fs.open("/extreme-reactors-control/"..fileName,"r")
	local list = fileData.readAll()
	fileData.close()

	return textutils.unserialise(list)
end

function downloadAndExecuteClass(fileName)	
	writeFile("classes/"..fileName)
  shell.run("/extreme-reactors-control/classes/"..fileName)
end

function getAllFiles()
	local fileEntries = downloadAndRead("files.txt")

	for k, v in pairs(fileEntries) do
	  print(v.name.." files...")

	  for fileCount = 1, #v.files do
      local fileName = v.files[fileCount]
      writeFile(fileName)
	  end

	  print("    Done.")
	end
end

--===== Run installation =====

--load language data
getLanguage()

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

print("Getting new files...")
getAllFiles()

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


