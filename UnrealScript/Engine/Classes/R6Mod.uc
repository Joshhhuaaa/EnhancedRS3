//=============================================================================
//  R6Mod.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// MPF a mod
class R6Mod extends Object
    config native;

const C_iR6ModVersion = 1;

struct ReticuleListElement
{
    var string m_szReticuleId;
    var string m_szReticuleClassName;
};

var config string	m_szKeyWord;		        // system name  (not localized)
var config int      version;
var config int      MinorVersion;
var config int      BuildVersion;
var        string	m_szName;			// name from dictionnary
var        string   m_szModInfo;
var config float    m_fPriority;
var config string   m_szCampaignIniFile;
var config string   m_szServerIni;
var config string   m_szUserIni;

var config string   m_ConfigClass;

var config bool     m_bUseMyKarma; //If the mod has his own karmadata.
var config bool     m_bUseCustomOperatives;

var config Array<ReticuleListElement> m_aReticuleList;

var config Array<string> m_ALocFile;

var config Array<string> m_aExtraPaths;

var config Array<string> m_aDescriptionPackage;

var config string m_PlayerCtrlToSpawn;
var config string m_GlobalHUDToSpawn;
var config string m_DefaultLightPawn;
var config string m_DefaultMediumPawn;
var config string m_DefaultHeavyPawn;
var config string m_DefaultPilotPawn;
var config string m_DefaultRainbowAI;
var config string m_HostageMgrToSpawn;

var config Array<string> m_aExtraModInfo;
var        Array<R6Mod>  m_aExtraMods;    // pointer to the extra mods list

var config Array<string>  m_szGameTypes;

var config string	m_szBackgroundRootDir;
var config string	m_szVideosRootDir;

var config string	m_szCreditsFile;
var config string   m_szMenuDefinesFile;

function Init( string szFile )
{
	local R6ModMgr	pModManager;
    local R6Mod     ProperMod;

    LoadConfig( "..\\Mods\\" $szFile );

    // more recent version or no version OR no mapName
    if ( version != C_iR6ModVersion  || version == 0 ||
         m_szKeyWord == "" )
    {
        log("WARNING: problem initializing mod " $szFile );
        return;
    }

    if ( m_fPriority == 0 )
        m_fPriority = 2.0;

	// for localisation, search in mod directory before
	pModManager = class'Actor'.static.GetModMgr();
    ProperMod = pModManager.m_pCurrentMod;
	pModManager.m_pCurrentMod = self;
	pModManager.SetSystemMod();

    m_szName      = Localize( m_szKeyWord, "ModName", "R6Mod", true );
	m_szModInfo   = Localize( m_szKeyWord, "ModInfo", "R6Mod", true );

    if ( Len( m_szKeyWord ) > 20 ) // protection
        assert( false );

    if (ProperMod!=none)
    {
        pModManager.m_pCurrentMod = ProperMod;
	    pModManager.SetSystemMod();
    }

    // LogInfo();
}

function LogArray( string s, Array<string> anArray )
{
    local int i;

    log( s$ ":" );
    for ( i = 0; i < anArray.Length; ++i )
        log( "   -" $anArray[i] );
}

function R6Mod GetExtraMods(INT index)
{
	if(index < m_aExtraMods.Length)
		return m_aExtraMods[index];
	else
		return none;
}

function AddGameTypesFromCurrentMod(LevelInfo pLevelInfo)
{
	local class<R6ModConfig> pConfigClass;
	local R6ModConfig pModConfig;

	if(m_ConfigClass != "")
	{
		pConfigClass = class<R6ModConfig> (DynamicLoadObject( m_ConfigClass, class'Class' ));
		pModConfig = new(self)pConfigClass;
		pModConfig.AddModSpecificGameModes(pLevelInfo);
	}
}

function LogInfo()
{
	log( "");
	log( " R6Mod Information");
	log( " =================");
    log( "	m_szKeyWord = " $m_szKeyWord );
    log( "  version= " $version );
    log( "  m_fPriority=" $m_fPriority );
    log( "  m_szName= " $m_szName );
    log( "  m_szModInfo=" $m_szModInfo );
    log( "  m_szCampaignIniFile=" $m_szCampaignIniFile );
	log( "  m_szBackgroundRootDir=" $m_szBackgroundRootDir);
    log( "  m_szVideosRootDir=" $m_szVideosRootDir);
	log( "  m_szCreditsFile= " $m_szCreditsFile);


	log( "");
	log("Localization Files:");
	log("===================");


	log( "");
	log( " Description Packages");
	log( " ====================");
	LogArray( "	 m_aDescriptionPackage", m_aDescriptionPackage);
}

defaultproperties
{
}
