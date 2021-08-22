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
  if not update or _G.lang == nil then    
    languages = downloadAndRead("supportedLanguages.txt")
    downloadAndExecuteClass("Language.lua")
    for k, v in pairs(languages) do
      print(k..") "..v)
    end

    term.write("Language? (example: en): ")
  
    installLang = read()
  
    if installLang == "" or installLang == nil then
      installLang = "en"
    end
    
    if languages[installLang] == nil then
      error("Language not found!")
    else
      writeFile("lang/"..installLang..".txt")
      selectedLang = _G.newLanguageById(installLang)
    end
  else
    installLang = _G.lang
    downloadAndExecuteClass("Language.lua")
    writeFile("lang/"..installLang..".txt")
    selectedLang = _G.newLanguageById(_G.lang)
  end

	print(selectedLang:getText("language"))
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
  print(selectedLang:getText("installerIntroLine1"))
  print(selectedLang:getText("installerIntroLine2"))
  print()
  print(selectedLang:getText("installerIntroLine3"))
  print(selectedLang:getText("installerIntroLine4"))
  print(selectedLang:getText("installerIntroLine5"))
  print(selectedLang:getText("installerIntroLine6"))
  print(selectedLang:getText("installerIntroLine7"))
  print(selectedLang:getText("installerIntroLine8"))
  print(selectedLang:getText("installerIntroLine9"))
  print()
  write(selectedLang:getText("pressEnter"))
  leer = read()

  --Computer label
  local out = true
  while out do
    term.clear()
    term.setCursorPos(1,1)
    print(selectedLang:getText("installerLabelLine1"))
    term.write(selectedLang:getText("installerLabelLine2"))

    local input = read()
    if input == "y" then
      print()
      shell.run("label set \"ReactorControlComputer\"")
      print()
      print(selectedLang:getText("installerLabelSet"))
      print()
      sleep(2)
      out = false

    elseif input == "n" then
      print()
      print(selectedLang:getText("installerLabelNotSet"))
      print()
      out = false
    end
  end

  --Startup
  local out2 = true
  while out2 do
    term.clear()
    term.setCursorPos(1,1)
    print(selectedLang:getText("installerStartupLine1"))
    print(selectedLang:getText("installerStartupLine2"))
    term.write(selectedLang:getText("installerStartupLine3"))

    local input = read()
    if input == "y" then
      local file = fs.open("startup","w")
      file.writeLine("shell.run(\"/extreme-reactors-control/start/start.lua\")")
      file.close()
      print()
      print(selectedLang:getText("installerStartupInstalled"))
      print()
      out2 = false
    end
    if input == "n" then
      print()
      print(selectedLang:getText("installerStartupUninstalled"))
      print()
      out2 = false
    end
  end

  sleep(1)
end --update

term.clear()
term.setCursorPos(1,1)

print(selectedLang:getText("installerFileCheck"))
--Removes old files
if fs.exists("/extreme-reactors-control/program/") then
  shell.run("rm /extreme-reactors-control/")
end

print(selectedLang:getText("installerGettingNewFiles"))
getAllFiles()

term.clear()
term.setCursorPos(1,1)

print(selectedLang:getText("updatingStartup"))
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
  print(selectedLang:getText("installerOutroLine1"))
  print(selectedLang:getText("installerOutroLine2"))
  print()
  term.setTextColor(colors.green)
  print()
  print(selectedLang:getText("installerOutroLine3").." ;)")
  print(selectedLang:getText("installerOutroLine4"))
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


