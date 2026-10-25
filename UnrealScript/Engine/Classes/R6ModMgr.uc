//=============================================================================
//  R6ModMgr.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// new MPF
class R6ModMgr extends Object
    native;

var R6UPackageMgr   m_pUPackageMgr;
var Array<R6Mod>    m_aMods;
var R6Mod           m_pCurrentMod;
var R6Mod           m_pRVS;
var bool            bShowLog;
var String          m_szPendingModName; // used when the server is started by Ubi.com

var array<string>	m_aGameTypeCorrTable;	// the game type corresponding table (compatibility with code before/after sdk)

native(2020) final function AddNewModExtraPath(R6Mod pMod, INT iResetPaths);
native(2021) final function SetSystemMod();
native(2022) final function SetGeneralModSettings(R6Mod pMod);
native(2023) final function bool IsOfficialMod(string _szName);
native(2024) final function int GetASBuildVersion();
native(2025) final function int GetIWBuildVersion();
native(3003) final function CallSndEngineInit(Level pLevel);

event int  GetNbMods()        { return m_aMods.Length; }

event bool IsMissionPack()   
{     
    return !IsRavenShield();
}

event bool IsRavenShield()
{
	return m_pCurrentMod == m_pRVS;
}

function bool CheckValidModVersion(R6Mod pModToCheck)
{
    local bool bReturnValue;

    bReturnValue = true;
    if ( pModToCheck.m_szKeyWord ~= "AthenaSword" )
        bReturnValue = GetASBuildVersion() == pModToCheck.BuildVersion;
    else if ( pModToCheck.m_szKeyWord ~= "IronWrath" )
        bReturnValue = GetIWBuildVersion() == pModToCheck.BuildVersion;

    return bReturnValue;
}

///////////////////////////////////////////////////////////
// Init Mod,create the package manager
// fill the aMod array and load the mod's ini
event InitModMgr()
{
    local R6FileManager pFileManager;
    local int i, j, jMove, iFiles;
    local string szIniFilename;
    local R6Mod aMod;
    local bool bNotFound;
    local array<string> ModsList;

    ModsList[ModsList.Length] = "RAVENSHIELD.MOD";
    ModsList[ModsList.Length] = "IRONWRATH.MOD";
    ModsList[ModsList.Length] = "ATHENASWORD.MOD";

    pFileManager = new(none) class'R6FileManager';
    
    m_pUPackageMgr = new(none) class'Engine.R6UPackageMgr';
    m_pUPackageMgr.InitOperativeClassesMgr();
    
    iFiles = pFileManager.GetNbFile("..\\Mods\\", "mod" );
    // loop on all .ini
    for ( i = 0; i < iFiles; i++ )
    {
        pFileManager.GetFileName( i, szIniFilename );
        if ( szIniFilename == "" )
            continue;

        bNotFound = true;
        for ( j = 0; j < ModsList.Length; j++ )
        {
            if ( ModsList[j] == Caps(szIniFilename) )
                bNotFound = false;
        }
        if ( bNotFound )
            continue;

        aMod = new(none) class'Engine.R6Mod';
        aMod.Init( szIniFilename );

        // find where to add the element
        for ( j = 0; j < m_aMods.Length; j++ )
        {
            if ( aMod.m_fPriority < m_aMods[j].m_fPriority )
                break;
        }

        // move elements to the right
        for ( jMove = m_aMods.Length; jMove != j; jMove-- )
        {
            m_aMods[jMove] = m_aMods[jMove-1];
        }

        // add it
        m_aMods[j] = aMod;
    }

	//Recurse again to find the extra mods associated to a current mod
	for ( i = 0; i < m_aMods.Length; i++ )
	{
		FindExtraMods(m_aMods[i]);
	}

    m_pRVS = GetModInstance( "RavenShield" );

	FillCorrepondanceTable();
}

function FindExtraMods(R6Mod pCurrentMod)
{
	local int i, j;
	for(i = 0; i < pCurrentMod.m_aExtraModInfo.Length; i++)
	{
		for ( j = 0; j < m_aMods.length; j++ )
		{
			if(pCurrentMod.m_aExtraModInfo[i] ~= m_aMods[j].m_szKeyWord )
			{
				pCurrentMod.m_aExtraMods[pCurrentMod.m_aExtraMods.Length] = m_aMods[j];
			}
		}
	}
}

function IsMapAvailable(string szKeyWord, Console pConsole)
{
	local int i;
	local string szMapDir;

	for ( i = 0; i < m_aMods.Length; ++i )
	{
		if ( m_aMods[i].m_szKeyWord ~= szKeyWord )
		{
			if(m_aMods[i] == m_pRVS)
				 szMapDir = "..\\Maps\\";
			else		   
				szMapDir = "..\\mods\\"$m_aMods[i].m_szKeyWord$"\\MAPS\\";

			if (pConsole != None)
			{
				pConsole.GetAllMissionDescriptions( szMapDir );
			}
		}
	}
}

function R6UPackageMgr GetPackageMgr() 
{
    return m_pUPackageMgr;
}

function R6Mod GetModInstance(string szKeyWord)
{
    local int i;
    
    for ( i = 0; i < m_aMods.Length; ++i )
    {
        if ( m_aMods[i].m_szKeyWord ~= szKeyWord )
        {
            return m_aMods[i];
        }
    }
	return none;
}

event SetCurrentMod( string szKeyWord, LevelInfo pLevelInfo, optional bool bInitSystem, optional Console pConsole, optional Level pLevel)
{
    local int    i;
    local R6Mod  pPreviousMod;

    pPreviousMod = m_pCurrentMod;
	m_pCurrentMod = m_pRVS; //Reset to RavenShield, if the mod set by The function does not exist

    for ( i = 0; i < m_aMods.Length; ++i )
    {
        if ( m_aMods[i].m_szKeyWord ~= szKeyWord && CheckValidModVersion(m_aMods[i]) )
        {
            if ( bShowLog ) log("CurrentMod: " $szKeyWord);

            m_pCurrentMod = m_aMods[i];
        }
    }

    if (pPreviousMod != m_pCurrentMod)
    {
	    CallSndEngineInit(pLevel);
		AddNewModExtraPath(m_pCurrentMod, 1);
		for(i = 0; i < m_pCurrentMod.m_aExtraMods.length; i++)
		{
			AddNewModExtraPath(m_pCurrentMod.m_aExtraMods[i], 0);
		}
		SetSystemMod(); // update the current mod in GSys for localisation purpose...
		if (pConsole != None)
		{
			pConsole.GetAllMissionDescriptions( GetMapsDir() );
		}
    }
    SetGeneralModSettings(m_pCurrentMod);

	if(pLevelInfo != none)
	{
		AddGameTypes(pLevelInfo);
	}

#ifdefDEBUG
    log("SetCurrentMod() m_pCurrentMod = "@m_pCurrentMod.m_szKeyWord);
#endif
}

function AddGameTypes(LevelInfo pLevelInfo)
{
	local INT i;

	//empty the list
	pLevelInfo.m_aGameTypeInfo.remove(0, pLevelInfo.m_aGameTypeInfo.Length);

	//Add RS if Lvl 2 
	if((m_pCurrentMod != m_pRVS) && (m_pCurrentMod.m_fPriority > 1))
	{
		m_pRVS.AddGameTypesFromCurrentMod(pLevelInfo);
	}

	//Add his
	m_pCurrentMod.AddGameTypesFromCurrentMod(pLevelInfo);

	//add extra mods
	for(i = 0; i < m_pCurrentMod.m_aExtraMods.length; i++)
	{
		m_pCurrentMod.m_aExtraMods[i].AddGameTypesFromCurrentMod(pLevelInfo);
	}
	
	pLevelInfo.SetGameTypeStrings();
}

function bool IsGameTypeAvailable( string szGametype )
{
    local INT i;
    
    for (i = 0; i < m_pCurrentMod.m_szGameTypes.Length; i++)
    {
        if ( szGametype == m_pCurrentMod.m_szGameTypes[i] )
        {
            return true;
        }
    }

    return false;
}

event String GetBackgroundsRoot()
{
    return m_pCurrentMod.m_szBackgroundRootDir;
}

event String GetVideosRoot()
{
    return m_pCurrentMod.m_szVideosRootDir;
}

event string GetDefaultCampaignDir()
{
    return "..\\save\\campaigns\\";
}

event string GetCampaignDir()
{
    if ( m_pCurrentMod == m_pRVS )
        return GetDefaultCampaignDir();
    else
        return GetDefaultCampaignDir() $ m_pCurrentMod.m_szKeyWord $ "\\";
}

event string GetIniFilesDir()
{
    if ( m_pCurrentMod == m_pRVS )
        return "System";
    else
        return "mods\\" $ m_pCurrentMod.m_szKeyWord $ "\\System";
}

function string GetCampaignMapDir(string szIniCampaignName)
{
	local INT i;
	
	for ( i = 0; i < m_aMods.Length; i++ )
	{
		if(m_aMods[i].m_szCampaignIniFile ~= szIniCampaignName)
		{
			if(szIniCampaignName ~= "RavenshieldCampaign")
			{
				return "..\\Maps\\";
			}
			else		   
			{
				return "..\\mods\\"$m_aMods[i].m_szKeyWord$"\\MAPS\\";
			}
		}
	}

	return "";
}

event string GetMapsDir()
{
	if(IsRavenShield())
		return "..\\Maps\\";
	else		   
		return "..\\mods\\"$m_pCurrentMod.m_szKeyWord$"\\MAPS\\";
}

function class<HUD> GetDefaultHUD()
{
    if ( m_pCurrentMod.m_GlobalHUDToSpawn != "" )
        return class<HUD>(DynamicLoadObject(m_pCurrentMod.m_GlobalHUDToSpawn, class'Class'));
    else
        return class<HUD>(DynamicLoadObject("R6Game.R6HUD", class'Class'));
}

function class<Pawn> GetDefaultPilotPawn()
{
    local string CurrentPawnClassName;

    if ( m_pCurrentMod.m_DefaultPilotPawn != "" )
        CurrentPawnClassName = m_pCurrentMod.m_DefaultPilotPawn;
    else
        CurrentPawnClassName = m_pRVS.m_DefaultPilotPawn;

    return class<Pawn>(DynamicLoadObject(CurrentPawnClassName, class'Class'));
}

function class<Pawn> GetDefaultRainbowPawn(INT Index)
{
    local string CurrentPawnClassName;

    if ( Index == 0 || Index == 1 )
    {
        if ( m_pCurrentMod.m_DefaultLightPawn != "" )
            CurrentPawnClassName = m_pCurrentMod.m_DefaultLightPawn;
        else
            CurrentPawnClassName = m_pRVS.m_DefaultLightPawn;
    }
    if ( Index == 2 )
    {
        if ( m_pCurrentMod.m_DefaultMediumPawn != "" )
            CurrentPawnClassName = m_pCurrentMod.m_DefaultMediumPawn;
        else
            CurrentPawnClassName = m_pRVS.m_DefaultMediumPawn;
    }
    if ( Index == 3 )
    {
        if ( m_pCurrentMod.m_DefaultHeavyPawn != "" )
            CurrentPawnClassName = m_pCurrentMod.m_DefaultHeavyPawn;
        else
            CurrentPawnClassName = m_pRVS.m_DefaultHeavyPawn;
    }

    return class<Pawn>(DynamicLoadObject(CurrentPawnClassName, class'Class'));
}

function class<AIController> GetDefaultRainbowAI()
{
    if ( m_pCurrentMod.m_DefaultRainbowAI != "" )
        return class<AIController>(DynamicLoadObject(m_pCurrentMod.m_DefaultRainbowAI, class'Class'));
    else
        return class<AIController>(DynamicLoadObject(m_pRVS.m_DefaultRainbowAI, class'Class'));
}

function string GetCreditsFile()
{
    return "..\\" $ GetIniFilesDir() $ "\\" $ m_pCurrentMod.m_szCreditsFile;
}

function string GetMenuDefFile()
{
    return "..\\" $ GetIniFilesDir() $ "\\" $ m_pCurrentMod.m_szMenuDefinesFile;
}

function class<Actor> GetCurrentReticule(string ReticuleID)
{
    local string ReticuleClassName;
    local int i;

    if ( m_pCurrentMod.m_aReticuleList.Length != 0 )
    {
        for ( i = 0; i < m_pCurrentMod.m_aReticuleList.Length; i++ )
        {
            if ( ReticuleID == m_pCurrentMod.m_aReticuleList[i].m_szReticuleId )
            {
                ReticuleClassName = m_pCurrentMod.m_aReticuleList[i].m_szReticuleClassName;
                break;
            }
        }
    }
    if ( ReticuleClassName == "" )
    {
        for ( i = 0; i < m_pRVS.m_aReticuleList.Length; i++ )
        {
            if ( ReticuleID == m_pRVS.m_aReticuleList[i].m_szReticuleId )
                ReticuleClassName = m_pRVS.m_aReticuleList[i].m_szReticuleClassName;
        }
    }

    return class<Actor>(DynamicLoadObject(ReticuleClassName, class'Class'));
}

event string GetServerIni()
{
    return "..\\" $ GetIniFilesDir() $ "\\" $ m_pCurrentMod.m_szServerIni;
}

event string GetModKeyword()
{
    return m_pCurrentMod.m_szKeyword;
}

event String GetModName()
{
    return m_pCurrentMod.m_szName;
}

//==================== COMPATIBILITY SECTION ===========================================================
// keep compatibilty with previous version until Ubi.com update their GSClient stuff
// THE ORDER IS IMPORTANT AND THE NAME TOO
function FillCorrepondanceTable()
{
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_AllMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_StoryMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_PracticeMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_MissionMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_TerroristHuntMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_TerroristHuntCoopMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_HostageRescueMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_HostageRescueCoopMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_HostageRescueAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_DefendMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_DefendCoopMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_ReconMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_ReconCoopMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_DeathmatchMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_TeamDeathmatchMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_BombAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_EscortAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_LoneWolfMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_SquadDeathmatch";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_SquadTeamDeathmatch";

	// MPF
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_TerroristHuntAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_ScatteredHuntAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_CaptureTheEnemyAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_CountDownMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_KamikazeMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_FreeBackupAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_GazAlertAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_IntruderAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_LimitSeatsAdvMode";
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_VirusUploadAdvMode";

	// The end
	m_aGameTypeCorrTable[m_aGameTypeCorrTable.length] = "RGM_NoRulesMode";
}

event int GetGameTypeIndex( string _szGameType)
{
	local int i;

	for (i = 0; i < m_aGameTypeCorrTable.length; i++)
	{
		if (_szGameType == m_aGameTypeCorrTable[i])
			return i;
	}

	return m_aGameTypeCorrTable.length; // RGM_NoRulesMode
}

event string GetGameTypeName( int _iIndex)
{
	if (_iIndex >= m_aGameTypeCorrTable.length)
	{
		log("GetGameTypeName() return RGM_NoRulesMode because iIndex "@_iIndex@">= nb of gametype "@m_aGameTypeCorrTable.length);
		return m_aGameTypeCorrTable[m_aGameTypeCorrTable.length - 1]; // RGM_NoRulesMode
	}
	else
		return m_aGameTypeCorrTable[_iIndex];
}

//==================== END OF COMPATIBILITY SECTION =======================================================

defaultproperties
{
}
