/*
	Name: AutoGameBackup_Run
	Description: Runs an auto game backup
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

/*
	Settings
*/
SendMode "Input"
SetWorkingDir A_ScriptDir

/*
	Global Vars
*/
; newConfigScript := A_ScriptDir "\AutoGameBackup_NewConfig.ahk"
dateFormat := "yyyy_MM(MMM)_dd_HH_mm"

/*
	Auto Execute
*/
if (A_Args.Length() > 0) {
	performBackup(A_Args[1])
}

return

/*
	Functions
*/
performBackup(configFile) {
	global dateFormat
	
	if (!FileExist(configFile) || InStr(FileExist(configFile), "D")) {
		MsgBox("Config file " configFile " doesn't exist", "Config file doesn't exist")
		return
	}
	
	configData := SerDes(configFile)
	if (!validateConfigData(configData)) {
		MsgBox("Config file " configFile " is invalid", "Config file invalid")
		return
	}
	
	; Valid configFile
	
	if (!DirExist(configData.dstDir)) {
		DirCreate(configData.dstDir)
	}
	
	dstCore := configData.dstDir "\" FormatTime(, dateFormat)
	if (DirExist(dstCore)) {
		MsgBox("Backup was created less than a minute ago!", "Backup exists")
		return
	}
	
	; Valid dst
	
	for k, v in configData.srcDirs.list {
		if (!DirExist(v)) {
			MsgBox("Skipping source " v " because it was not found", "Source not found")
			continue
		}
	
		SplitPath(v, dstInner)
		dst := dstCore "\" dstInner
		
		; In case you decide to put two folders of the same name in your srcs
		if (DirExist(dst)) {
			offset := 2
			newDst := dst offset
			while(DirExist(newDst)) {
				offset++
				newDst := dst offset
			}
			dst := newDst
		}
		
		DirCopy(v, dst)
	}
	
	if (FileExist(configData.gameExe)) {
		reply := MsgBox("Run " configData.gameExe "?", "Run game", 4)
		if (reply = "Yes") {
			Run configData.gameExe
		}
	}
}

validateConfigData(configData) {
	return (configData.name != "" && configData.srcDirs.list != "" && configData.dstDir != "")
}
