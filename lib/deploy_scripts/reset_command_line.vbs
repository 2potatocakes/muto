
Set oShell = WScript.CreateObject("WScript.Shell")
filename = oShell.ExpandEnvironmentStrings("%TEMP%\reset_command_line.bat")
Set objFileSystem = CreateObject("Scripting.fileSystemObject")
Set oFile = objFileSystem.CreateTextFile(filename, TRUE)

'Grab System Environment variables'
    set oEnv=oShell.Environment("System")
    for each sitem in oEnv
        oFile.WriteLine("SET " & sitem)
    next
    path = oEnv("PATH")

'Grab User Environment variables'
    set oEnv=oShell.Environment("User")
    for each sitem in oEnv
        oFile.WriteLine("SET " & sitem)
    next

'Output to Global PATH variable'
    path = path & ";" & oEnv("PATH")
    oFile.WriteLine("SET PATH=" & path)
    oFile.Close