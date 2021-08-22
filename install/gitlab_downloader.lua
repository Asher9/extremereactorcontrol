-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Init Program Downloader (GitLab) --

--===== Local variables =====

--Release or beta version?
local selectInstaller = ""

--Branch & Relative paths to the url and path
local installLang = "en"
local branch = ""
local relUrl = ""
local relPath = "/extreme-reactors-control/"
local repoUrl = "https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/raw/"
local selectedLang = {}

function getLanguage()
	languages = downloadAndRead("supportedLanguages.txt")
	downloadAndExecuteClass("Language.lua")
	for k, v in pairs(languages) do
		print(k..") "..v)
	end
	term.write("Language? ")

	installLang = read()
    
    print("Selected Language: "..installLang)
	
	if languages[installLang] == nil then
		error("Language not found!")
	else
		print("Downloading '"..installLang.."' language file")
		writeFile("lang/"..installLang..".txt")
		selectedLang = _G.newLanguageById(installLang)
	end

	print(selectedLang.text.language)
end

--Select the github branch to download
function selectBranch()
	clearTerm()

	print("Which version should be downloaded?")
	print("Available:")
	print("1) main (Stable Release)")
	print("2) develop (Unstable Release)")
	term.write("Input (1-2): ")

	local input = read()
	if input == "1" then
		branch = "main"
		relUrl = repoUrl..branch.."/"
		releaseVersion()
	elseif input == "2" then
		branch = "develop"
		relUrl = repoUrl..branch.."/"
		betaVersion()
	else
		print("Invalid input!")
		sleep(2)
		selectBranch()
	end
end

--Removes old installations
function removeAll()
	print("Removing old files...")
	if fs.exists(relPath) then
		shell.run("rm "..relPath)
	end
	if fs.exists("startup") then
		shell.run("rm startup")
	end
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
		clearTerm()
		error("File not found! Please check!\nFailed at "..relUrl..path)
	else
		return gotUrl.readAll()
	end
end

function downloadAndExecuteClass(fileName)	
	writeFile("classes/"..fileName)
	shell.run("/extreme-reactors-control/classes/"..fileName)
end

function downloadAndRead(fileName)
	writeFile(fileName)
	local fileData = fs.open("/extreme-reactors-control/"..fileName,"r")
	local list = fileData.readAll()
	fileData.close()

	return textutils.unserialise(list)
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

--Gets all the files from github
function getFiles()
	clearTerm()
	print("Getting new files...")
	getAllFiles()

	--Startup
	print("Startup file...")
	local file = fs.open("startup","w")
  	file.writeLine("shell.run(\"/extreme-reactors-control/start/start.lua\")")
	file.close()
end

--Clears the terminal
function clearTerm()
	shell.run("clear")
	term.setCursorPos(1,1)
end

function releaseVersion()
	removeAll()

	--Downloads the installer
	writeFile("install/installer.lua")

	--execute installer
	shell.run("/extreme-reactors-control/install/installer.lua")
end

function betaVersion()
	removeAll()
	getFiles()
	print("Done!")
	sleep(2)
end

selectBranch()
os.reboot()