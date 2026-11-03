@echo off

:: Create Inc folders if they don't exist
if not exist .\MP2Weapons\Inc\ mkdir .\MP2Weapons\Inc
if not exist .\MP2Description\Inc\ mkdir .\MP2Description\Inc
if not exist .\MP2SFX\Inc\ mkdir .\MP2SFX\Inc
if not exist .\MP21stWeapons\Inc\ mkdir .\MP21stWeapons\Inc
if not exist .\MP23rdWeapons\Inc\ mkdir .\MP23rdWeapons\Inc
if not exist .\MP2Game\Inc\ mkdir .\MP2Game\Inc
if not exist .\MP2Characters\Inc\ mkdir .\MP2Characters\Inc
if not exist .\MP2Menu\Inc\ mkdir .\MP2Menu\Inc

del ".\System\MP2SFX.u"
del ".\System\MP21stWeapons.u"
del ".\System\MP2Weapons.u"
del ".\System\MP23rdWeapons.u"
del ".\System\MP2Description.u"
del ".\System\MP2Game.u"
del ".\System\MP2Menu.u"
del ".\System\MP2Characters.u"

echo Compiling scripts for Iron Wrath

cd ..\..\System\
UCC.exe make -nobind -silent INI=RavenShield.ini MOD=IronWrath
cd ..\Mods\IronWrath\

echo Finished compiling Iron Wrath

PAUSE
