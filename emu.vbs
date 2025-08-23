Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "C:\Users\cleme\AppData\Local\Android\Sdk\emulator"
WshShell.Run "emulator.exe -avd Pixel_7_API_35", 0, False
