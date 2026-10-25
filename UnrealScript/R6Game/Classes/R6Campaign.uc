//=============================================================================
//  R6Campaign.uc : This class represents a single player campaign and the list of missions (maps)
//					included in it
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================

class R6Campaign extends Object
		config;

var        string               m_szCampaignFile;

var config Array<string>	            missions;           // file to load
var        Array<R6MissionDescription>  m_missions;         // R6MissionDescription

var config Array<string>    m_OperativeClassName;
var config Array<string>    m_OperativeBackupClassName; // Array of Rookies to spawn when needed.
var config string           LocalizationFile;


//------------------------------------------------------------------
// Ini: init the campaign, load all the mission description
//	   aLevel: needed for getting r6gametype
//    console: needed to access the array of mission descriptions
// szFileName: campaign file name
//------------------------------------------------------------------
function InitCampaign( LevelInfo aLevel, string szFileName, R6Console console )
{
    local int       i, j, iMission;
    local string    szIniFile;
    local bool      bFound;

    m_szCampaignFile = szFileName;

	LoadConfig( class'Actor'.static.GetModMgr().GetCampaignMapDir(szFileName) $ m_szCampaignFile );
	console.GetAllMissionDescriptions( class'Actor'.static.GetModMgr().GetCampaignMapDir(szFileName));

	// for each ini file name of the mission
    i = 0;
    iMission = 0;
    while ( i < missions.Length )
    {
        missions[i] = caps( missions[i] );
        szIniFile = missions[i]$ ".INI";
        bFound = false;
        // find the mission description object from the array
        j = 0;
        while ( j < console.m_aMissionDescriptions.Length )
        {
            if ( console.m_aMissionDescriptions[j].m_missionIniFile == szIniFile )
            {
				m_missions[iMission] = console.m_aMissionDescriptions[j];
                m_missions[iMission].m_bCampaignMission = true;

                if ( iMission == 0 ) // first mission is always unlocked
                    m_missions[iMission].m_bIsLocked = false; 
                else
                    m_missions[iMission].m_bIsLocked = true; 

                iMission++;
                bFound = true;
                break;
            }
            j++;
        }

        if ( !bFound )
        {
            log( "Warning: missing mission description " $szIniFile$ " in campaign " $szFileName ); 
        }

        i++;
    }

    console.UnlockMissions();
}

//------------------------------------------------------------------
// LogInfo
//	
//------------------------------------------------------------------
function LogInfo()
{
    local int i;

    log( "CAMPAIGN name=" $m_szCampaignFile$ " localizationFile=" $LocalizationFile ); 
    log( "===========================================================" ); 
    log( " List mission (.ini files)" );
    while ( i < missions.Length )
    {
        log( "  Mission " $i$ " " $missions[i] );
        i++;
    }

    log( " List operative" );
    i = 0;

    log( "  List backup operative" );
    i = 0;
    while ( i < m_OperativeBackupClassName.Length )
    {
        log( "  bk " $i$ " " $m_OperativeBackupClassName[i] );
        i++;
    }
}

defaultproperties
{
}
