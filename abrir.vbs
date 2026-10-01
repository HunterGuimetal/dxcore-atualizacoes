' DXCORE by GUIMETAL - abre o lancador sem mostrar janela preta
Set sh = CreateObject("WScript.Shell")
d = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & d & "\abrir.ps1""", 0, False
