@echo off
cls

"E:\Program Files (x86)\Embarcadero\RAD Studio\7.0\bin\brcc32.exe" Database.RC

move /Y Database.RES "..\"

pause