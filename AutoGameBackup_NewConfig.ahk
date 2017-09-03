/*
	Name: AutoGameBackups_NewConfig
	Description: Creates auto game backup config
	Version: 1.0
	
	Author: Blucifer
	Date: July 2017
*/

/*
	Config file data format:
	
	name: gameName
	srcDirs.list: [dir1, dir2, ...]
	dstDir: dstDir
	gameExe: pathToGameExe
*/

/*
	#
*/
#Warn All
#SingleInstance Force

#Include SerDes.ahk
#Include UniqueList.ahk

/*
	Settings
*/
SendMode "Input"
SetWorkingDir A_ScriptDir

/*
	Global Vars
*/
runScript := A_ScriptDir "\AutoGameBackup_Run.ahk"
settingsDir := A_ScriptDir "\Settings"
selfExt := "agbconfig"

/*
	Auto Execute
*/
if (!DirExist(settingsDir)) {
	DirCreate(settingsDir)
}
if (!FileExist(runScript) || InStr(FileExist(runScript), "D")) {
	MsgBox("Could not find script`n" runScript, "Run script missing")
	return
}

addNewGame()

return

/*
	Functions
*/

createShortcut() {
	global runScript, configData, currentNewGamePath
	
	FileCreateShortcut(runScript, "Backup " configData.name ".lnk",, currentNewGamePath)
}

addNewGame() { ; create obj, ask name, show src gui
	global settingsDir, currentNewGamePath, selfExt
	, configData := { name: "", srcDirs: new uniqueList(), dstDir: "", gameExe: ""}
	
	configData.name := Trim(InputBox("Name of game:", "Add new game"))
	if (ErrorLevel || configData.name = "") {
		return
	}
	currentNewGamePath := settingsDir "\" configData.name "." selfExt
	if (DirExist(currentNewGamePath)) {
		reply := MsgBox("Settings for " configData.name " already exist. Create shortcut?", "Existing config", 4)
		if (reply = "Yes") {
			createShortcut()
		}
		return
	}
	
	srcEvents := new newGameGuiEvents("source", configData.srcDirs, Func("addNewGame_p2"))
	addDirsGui(srcEvents)
}
addNewGame_p2() {
	global configData, currentNewGamePath
	
	dstDir := DirSelect("*" A_WorkingDir, 3, "Select destination directory")
	while(ErrorLevel) {
		reply := MsgBox("Cancel and discard changes?", "Discard changes", 4)
		if (reply = "Yes") {
			return
		}
		dstDir := DirSelect("*" A_WorkingDir, 3, "Select destination directory")
	}
	
	configData.dstDir := dstDir
	
	reply := MsgBox("Run game after backup?", "AutoBackup settings", 4)
	if (reply = "Yes") {
		exe := FileSelect(1,, "Select game executable", "Executable (*.exe)")
		if (!ErrorLevel) {
			configData.gameExe := exe
		}
	}
	
	SerDes(configData, currentNewGamePath, 1)
	createShortcut()
}

/*
	Directory GUI
*/
addDirsGui(events) { ; Gui to add directory to a list
	Gui := GuiCreate(, "Add " events.typeStr " directories", events)
	Gui.Add("ListView", "-Multi vdirsList", "Directories")
	Gui.Add("Button", "Section", "Add Directory").OnEvent("Click", "addDir")
	Gui.Add("Button", "ys", "Remove Directory").OnEvent("Click", "removeDir")
 	Gui.Add("Button", "Default ys", "Proceed").OnEvent("Click", "proceed")
	Gui.OnEvent("Close", "close")
	Gui.Show()
	return Gui
}

class newGameGuiEvents { ; Event sink for above gui
	__New(typeStr, dirsList, callback) {
		this.typeStr := typeStr
		this.dirsList := dirsList
		this.callback := callback
	}
	
	addDir(GuiCtrl) {
		listCtrl := GuiCtrl.Gui.Control["dirsList"]
		
		dir := selectDir("Select " this.typeStr " directory")
		if (dir != "" && this.dirsList.add(dir)) {
			listCtrl.Add(,dir)
		}
	}
	
	removeDir(GuiCtrl) {
		listCtrl := GuiCtrl.Gui.Control["dirsList"]
		
		rowNum := listCtrl.GetNext(0)
		if (rowNum != 0) {
			this.dirsList.remove(listCtrl.GetText(rowNum, 1))
			listCtrl.Delete(rowNum)
		}
	}
	
	proceed(GuiCtrl) {
		if (this.dirsList.list.Length() < 1) {
			MsgBox("Add at least one directory to proceed", "Add directories")
			return
		}
		
		GuiCtrl.Gui.Submit()
		this.callback()
	}
	
	close(Gui) {
		if (this.dirsList.list.Length() < 1) {
			return
		}
		
		reply := MsgBox("Save current selection and proceed?", "Save selection", 4)
		if (reply = "Yes") {
			this.callback()
		}
	}
}
selectDir(msg) { ; Custom directory select
	static prevDir := "*" A_WorkingDir
	
	dir := DirSelect(prevDir, 3, msg)
	prevDir := "*" dir
	return dir
}
