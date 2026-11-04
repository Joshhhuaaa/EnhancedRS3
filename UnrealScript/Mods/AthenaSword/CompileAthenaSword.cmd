@echo off

:: Create Inc folders if they don't exist
if not exist .\ASCharacters\Inc\ mkdir .\ASCharacters\Inc
if not exist .\ASWeapons\Inc\ mkdir .\ASWeapons\Inc
if not exist .\ASDescription\Inc\ mkdir .\ASDescription\Inc
if not exist .\ASGame\Inc\ mkdir .\ASGame\Inc
if not exist .\ASMenu\Inc\ mkdir .\ASMenu\Inc

del ".\System\ASCharacters.u"
del ".\System\ASWeapons.u"
del ".\System\ASDescription.u"
del ".\System\ASGame.u"
del ".\System\ASMenu.u"

echo Compiling scripts for Athena Sword

cd ..\..\System\
UCC.exe make -nobind -silent INI=RavenShield.ini MOD=AthenaSword
cd ..\Mods\AthenaSword\

echo Finished compiling Athena Sword

PAUSE
