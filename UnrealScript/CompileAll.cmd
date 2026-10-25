@echo off

:: Create Inc folders if they don't exist
if not exist .\Core\Inc\ mkdir .\Core\Inc
if not exist .\Engine\Inc\ mkdir .\Engine\Inc
if not exist .\Fire\Inc\ mkdir .\Fire\Inc
if not exist .\Editor\Inc\ mkdir .\Editor\Inc
if not exist .\UWindow\Inc\ mkdir .\UWindow\Inc
if not exist .\IpDrv\Inc\ mkdir .\IpDrv\Inc
if not exist .\Gameplay\Inc\ mkdir .\Gameplay\Inc
if not exist .\R6SFX\Inc\ mkdir .\R6SFX\Inc
if not exist .\R6Abstract\Inc\ mkdir .\R6Abstract\Inc
if not exist .\R6Engine\Inc\ mkdir .\R6Engine\Inc
if not exist .\R6Characters\Inc\ mkdir .\R6Characters\Inc
if not exist .\R61stWeapons\Inc\ mkdir .\R61stWeapons\Inc
if not exist .\R6Weapons\Inc\ mkdir .\R6Weapons\Inc
if not exist .\R6WeaponGadgets\Inc\ mkdir .\R6WeaponGadgets\Inc
if not exist .\R63rdWeapons\Inc\ mkdir .\R63rdWeapons\Inc
if not exist .\R6Description\Inc\ mkdir .\R6Description\Inc
if not exist .\R6GameService\Inc\ mkdir .\R6GameService\Inc
if not exist .\R6Game\Inc\ mkdir .\R6Game\Inc
if not exist .\R6Window\Inc\ mkdir .\R6Window\Inc
if not exist .\R6Menu\Inc\ mkdir .\R6Menu\Inc
if not exist .\UnrealEd\Inc\ mkdir .\UnrealEd\Inc

echo Compiling scripts for Raven Shield

cd .\System\
UCC.exe make -all -nobind -silent INI=RavenShield.ini
cd ..

echo Finished compiling Raven Shield

PAUSE
