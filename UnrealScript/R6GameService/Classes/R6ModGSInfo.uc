class R6ModGSInfo extends object
	native
	config(R6ModGSInfo);

var config BYTE	    m_ucModActivationID[16];    // CDKey validation server activation ID
var config BOOL	    m_bModValidActivationID;    // CDKey validation server activation ID valid flag
var	config string   m_szModGlobalID;            // ubi globalID -- related to ActID

native(1207) final function NativeInitModInfo();

function InitGSMod()
{
    local string szFilename;
    local R6ModMgr pModManager;

    NativeInitModInfo();

    pModManager = class'Actor'.static.GetModMgr();
    szFilename = "..\\" $ pModManager.GetIniFilesDir() $ "\\" $ pModManager.GetModKeyword();
    LoadConfig(szFilename);
}
