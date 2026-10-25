//=============================================================================
//  R6MissionDescription.uc : This class contains descriptions
//								of a specific mission, do a LoadConfig("..\maps\"$m_MapName)
//                              after you do a new on an object of this class        
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================
class R6MissionDescription extends Object 
    config
    native;

const C_iR6MissionDescriptionVersion = 3;

// defined in r6MiscStructs.h
struct GameTypeMaxPlayer
{
    var string package;
    var string type;
    var int    maxNb;
};

struct GameTypeSkin
{
    var string package;
    var string type;
    var string greenPackage;
    var string green;
    var string redPackage;
    var string red;
};

var        string              m_missionIniFile;        // this var tring is always in upper case
var config string			   m_MapName;
var config string			   m_ShortName;
var config int                 version;
var config string              mod;
var config Array<GameTypeMaxPlayer>  GameTypes;
var        Array<string>	   m_szGameTypes;
var config string              LocalizationFile;

var config string			   m_AudioBankName;
var config Sound               m_PlayEventControl;
var config Sound               m_PlayEventClark;
var config Sound               m_PlayEventSweeney;

var config string			   m_InGameVoiceClarkBankName;
var config Sound               m_PlayMissionIntro;
var config Sound               m_PlayMissionExtro;

var config Texture             m_TMissionOverview;     //This is for the campaign select menu
var config Region              m_RMissionOverview;

var config Texture             m_TWorldMap;            //World map showing mission Location
var config Region              m_RWorldMap;


var config Array<class>        m_MissionArmorTypes;    //This array should contain the list of the classes
                                                       //of armors available for this mission

var        bool                m_bCampaignMission;     // true if used in a campaign
var        bool                m_bIsLocked;            // true if locked


var config Array<GameTypeSkin> SkinsPerGameTypes;



event Reset()
{
    m_missionIniFile = "";
    m_MapName        = "";
    version          = 0;
    GameTypes.remove( 0, GameTypes.length );
    SkinsPerGameTypes.remove( 0, SkinsPerGameTypes.length );
    m_szGameTypes.remove( 0, m_szGameTypes.length );
    LocalizationFile = "";

    m_AudioBankName     = "";

    m_bCampaignMission = false;
    m_bIsLocked        = default.m_bIsLocked;
}

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
event BOOL Init( LevelInfo aLevel, string szMissionFile )
{
    local int i;
    local string szIniFile;
    local string szClassName;
#ifdefDEBUG
    local GameTypeMaxPlayer tempGT;
#endif

    m_missionIniFile = caps(szMissionFile);

#ifdefSPDEMO
    if ( m_missionIniFile != "OIL_REFINERY.INI" )
        return TRUE;
#endif

	LoadConfig( szMissionFile );

    // no version OR no mapName
    if ( version == 0 || m_MapName == "" )
    {
#ifdefDEBUG
        // If we don't have a .ini or the .ini is invalid, intialize with default value
        tempGT.package = "R6Game";
        tempGT.maxNb = 16;
        tempGT.type = "R6TerroristHuntGame";
        GameTypes[0] = tempGT;
        tempGT.type = "R6TerroristHuntCoopGame";
        GameTypes[1] = tempGT;
        tempGT.type = "R6DeathMatch";
        GameTypes[2] = tempGT;
        tempGT.type = "R6TeamDeathMatchGame";
        GameTypes[3] = tempGT;
        tempGT.type = "R6NoRules";
        GameTypes[4] = tempGT;
        tempGT.type = "R6LoneWolfGame";
        tempGT.maxNb = 1;
        GameTypes[5] = tempGT;
        
        while ( i < GameTypes.Length )
        {
            szClassName = GameTypes[i].package $ "." $ GameTypes[i].type;
            m_szGameTypes[i] = aLevel.GetGameTypeFromClassName( szClassName  );
            ++i;
        }
#endif
        return FALSE;
    }

    szIniFile = m_MapName $".ini";
    szIniFile = caps( szIniFile );
    
	
	if ( InStr(m_missionIniFile, szIniFile) < 0 )
    {
        log("WARNING: R6MissionDescription m_missionIniFile (" $ m_missionIniFile $ ") != m_MapName (" $ szIniFile $ ") - " $ InStr(m_missionIniFile, szIniFile) );
        m_MapName = "";
        return FALSE;
    }
	else
	{
		m_missionIniFile=szIniFile;
    }

    if ( aLevel == none )
        return FALSE;
    
    i=0;
    // get the GameType
    while ( i < GameTypes.Length )
    {
        szClassName = GameTypes[i].package $ "." $ GameTypes[i].type;
        m_szGameTypes[i] = aLevel.GetGameTypeFromClassName( szClassName  );
        ++i;
    }
    
    // old version or no mod specified
    if ( version <= 2 || Mod == "" )
        Mod = "RavenShield";

//    LogInfo();
	return TRUE;
}

//------------------------------------------------------------------
// GetSkins
//	
//------------------------------------------------------------------
event bool GetSkins( out LevelInfo aLevel, string szGameTypeClass )
{
    local int i;
    local string szGameMode, szClassName;
	local class<Pawn> TempGreenClass, TempRedClass;

	// find if there's a skin for this game mode
    i = 0;
    while ( i < SkinsPerGameTypes.Length )
    {
        szClassName = SkinsPerGameTypes[i].package $ "." $ SkinsPerGameTypes[i].type;

        if ( szGameTypeClass ~= szClassName )
        {
            if ( SkinsPerGameTypes[i].greenPackage ~= "none" || SkinsPerGameTypes[i].green ~= "none" )
                aLevel.GreenTeamPawnClass = "none";
            else
                aLevel.GreenTeamPawnClass = SkinsPerGameTypes[i].greenPackage $ "." $SkinsPerGameTypes[i].green;
            if ( SkinsPerGameTypes[i].redPackage ~= "none" && SkinsPerGameTypes[i].red ~= "none" )
                aLevel.RedTeamPawnClass = "none";
            else
                aLevel.RedTeamPawnClass   = SkinsPerGameTypes[i].redPackage   $ "." $SkinsPerGameTypes[i].red;
			if ( aLevel.NetMode != NM_Client )
			{
				if ( aLevel.GreenTeamPawnClass != "none" )
					TempGreenClass = class<Pawn>(DynamicLoadObject(aLevel.GreenTeamPawnClass, class'Class'));
				if(TempGreenClass != none)
				{
					aLevel.GreenTeamSkin = TempGreenClass.default.Skins[0];
					aLevel.GreenHeadSkin = TempGreenClass.default.Skins[1];
					aLevel.GreenGogglesSkin = TempGreenClass.default.Skins[2];
					aLevel.GreenHandSkin = TempGreenClass.default.Skins[5];
					aLevel.GreenMesh = TempGreenClass.default.Mesh;
					aLevel.GreenHelmet = TempGreenClass.default.m_HelmetClass;
					if(aLevel.GreenHelmet != none)
					{
						aLevel.GreenHelmetMesh = aLevel.GreenHelmet.default.StaticMesh;
						aLevel.GreenHelmetSkin = aLevel.GreenHelmet.default.Skins[0];
					}
				}
				if ( aLevel.RedTeamPawnClass != "none" )
					TempRedClass = class<Pawn>(DynamicLoadObject(aLevel.RedTeamPawnClass, class'Class'));
				if(TempRedClass != none)
				{
					aLevel.RedTeamSkin = TempRedClass.default.Skins[0];
					aLevel.RedHeadSkin = TempRedClass.default.Skins[1];
					aLevel.RedGogglesSkin = TempRedClass.default.Skins[2];
					aLevel.RedHandSkin = TempRedClass.default.Skins[5];
					aLevel.RedMesh = TempRedClass.default.Mesh;
					aLevel.RedHelmet = TempRedClass.default.m_HelmetClass;
					if(aLevel.RedHelmet != none)
					{
						aLevel.RedHelmetMesh = aLevel.RedHelmet.default.StaticMesh;
						aLevel.RedHelmetSkin = aLevel.RedHelmet.default.Skins[0];
					}
				}
			}

			return true;
        }
        ++i;
    }

    return false; // use default one
}

function SetSkins( string szGameTypeClass, string GreenSkinClass, string RedSkinClass )
{
    local int i;
    local string szClassName, szSkinPackage, szSkinClass, szMapDir;

    i = 0;
    while ( i < SkinsPerGameTypes.Length )
    {
        szClassName = SkinsPerGameTypes[i].package $ "." $ SkinsPerGameTypes[i].type;

        if ( szGameTypeClass ~= szClassName )
        {
            SkinsPerGameTypes[i].greenPackage = Left(GreenSkinClass, InStr(GreenSkinClass, "."));
            SkinsPerGameTypes[i].green = Mid(GreenSkinClass, InStr(GreenSkinClass, ".") + 1);
            if ( RedSkinClass ~= "" )
            {
                SkinsPerGameTypes[i].redPackage = "None";
                SkinsPerGameTypes[i].red = "None";
            }
            else
            {
                SkinsPerGameTypes[i].redPackage = Left(RedSkinClass, InStr(RedSkinClass, "."));
                SkinsPerGameTypes[i].red = Mid(RedSkinClass, InStr(RedSkinClass, ".") + 1);
            }
            if ( mod ~= "" || mod ~= "RavenShield" )
                szMapDir = "..\\maps\\";
            else
                szMapDir = "..\\mods\\" $ mod $ "\\maps\\";
            SaveConfig( szMapDir $ m_missionIniFile );
        }
        i++;
    }
}

//------------------------------------------------------------------
// LogInfo
//	
//------------------------------------------------------------------
function LogInfo()
{
    local int i;
    local string szClassName, szGreen, szRed;
    local class<Pawn> RedPawnClass, GreenPawnClass;

    log( "MissionDescription " $m_missionIniFile$ " mapName=" $m_MapName$ " localizationFile=" $LocalizationFile$ " version=" $version );
    log( " mod                    =" $mod );
    log( " m_TMissionOverview     =" $m_TMissionOverview );   
    log( " m_RMissionOverview     =" $m_RMissionOverview.x$ "," $m_RMissionOverview.y$"," $m_RMissionOverview.w$","$m_RMissionOverview.h );
    log( " m_TWorldMap            =" $m_TWorldMap );     
    log( " m_RWorldMap            =" $m_RWorldMap.x$ "," $m_RWorldMap.y$"," $m_RWorldMap.w$","$m_RWorldMap.h );
    log( " m_AudioBankName        =" $m_AudioBankName );
    log( " m_PlayEventControl     =" $m_PlayEventControl );
    log( " m_PlayEventClark       =" $m_PlayEventClark );
    log( " m_PlayEventSweeney     =" $m_PlayEventSweeney );

    i=0;
    while ( i < m_MissionArmorTypes.Length )
    {
        log( " m_MissionArmorTypes " $i$ "=" $m_MissionArmorTypes[i] );
        ++i;
    }

    i=0;
    while ( i < GameTypes.Length )
    {
        log( " GameTypes " $i$ "=" $GameTypes[i].package$"."$GameTypes[i].type$ " ID=" $m_szGameTypes[i]$ " max nb players=" $GameTypes[i].maxNb );
        ++i;
    }

    i=0;
    while ( i < SkinsPerGameTypes.Length )
    {
        szClassName = SkinsPerGameTypes[i].package  $ "." $SkinsPerGameTypes[i].type;
        szGreen = SkinsPerGameTypes[i].greenPackage $ "." $SkinsPerGameTypes[i].green;
        szRed   = SkinsPerGameTypes[i].redPackage   $ "." $SkinsPerGameTypes[i].red;
        
        log( " SkinsPerGameTypes " $i$ "- " $szClassName$ " green=" $szGreen$ " red=" $szRed );
        /*
        GreenPawnClass = class<Pawn>(DynamicLoadObject(szGreen, class'Class'));
        if ( GreenPawnClass == none )
            log( "WARNING: unknown green skin for "  $szClassName$ " green= " $szGreen$ " m_missionIniFile= " $m_missionIniFile );

        RedPawnClass   = class<Pawn>(DynamicLoadObject(szRed, class'Class'));
        if ( RedPawnClass == none ) 
            log( "WARNING: unknown red skin for "  $szClassName$ " red= " $szRed$ " m_missionIniFile= " $m_missionIniFile );
        */
        ++i;
    }

}

//------------------------------------------------------------------
// IsAvailableInGameType
//	
//------------------------------------------------------------------
function bool IsAvailableInGameType( string szGameType )
{
    local int i;

    while ( i < m_szGameTypes.Length )
    {
        if ( m_szGameTypes[i] == szGameType )
            return true;
        ++i;
    }

    return false; 
}

//------------------------------------------------------------------
// GetMaxNbPlayers
//	
//------------------------------------------------------------------
function int GetMaxNbPlayers( string szGameType )
{
    local int i;
    
    while ( i < m_szGameTypes.Length )
    {
        if ( m_szGameTypes[i] == szGameType )
        {
            return GameTypes[i].maxNb;
        }
        ++i;
    }

    return 0;
}

defaultproperties
{
     m_MissionArmorTypes(0)=None
}
