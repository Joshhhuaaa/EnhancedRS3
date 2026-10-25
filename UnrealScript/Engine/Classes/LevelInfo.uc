//=============================================================================
// LevelInfo contains information about the current level. There should 
// be one per level and it should be actor 0. UnrealEd creates each level's 
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
	native
	nativereplication
    hidecategories(R6Weather);

import class R6MissionObjectiveBase;

// Textures.
#exec Texture Import File=Textures\WireframeTexture.tga
#exec Texture Import File=Textures\WhiteSquareTexture.pcx
#exec Texture Import File=Textures\S_Vertex.tga Name=LargeVertex

//-----------------------------------------------------------------------------
// Level time.

// Time passage.
var() float TimeDilation;          // Normally 1 - scales real time passage.

// Current time.
var           float	TimeSeconds;   // Time in seconds since level began play.
var transient int   Year;          // Year.
var transient int   Month;         // Month.
var transient int   Day;           // Day of month.
var transient int   DayOfWeek;     // Day of week.
var transient int   Hour;          // Hour.
var transient int   Minute;        // Minute.
var transient int   Second;        // Second.
var transient int   Millisecond;   // Millisecond.
var			  float	PauseDelay;		// time at which to start pause

var enum EPhysicsDetailLevel
{
	PDL_Low,
	PDL_Medium,
	PDL_High
} PhysicsDetailLevel;

var                     bool    m_bShowFloppy;
var                     float   m_fCompteurFrameDetection;
var(MP2VirusUpload)     float   m_fTempsDetection;
var(MP2VirusUpload)     float   m_fClignoteTime;
var(R6GazAlertMode)     int     m_iCoughTimes;
var(R6GazAlertMode)     float   m_fOxygeneTopLevel;
var(R6GazAlertMode)     float   m_iCoughSeuil;
var(R6GazAlertMode)     float   m_fOxygeneStepDecrease;
var(FreeBackupMode)     int     m_iNbOfFreeBackupToSpawn;
var(FreeBackupMode)     int     m_iNbOfFBToSpawnBasedOnNbPlayers;
var(ClassicMission)     bool    m_bIsClassicMission;

// Karma - jag
var float KarmaTimeScale;		// Karma physics timestep scaling.
var float RagdollTimeScale;		// Ragdoll physics timestep scaling. This is applied on top of KarmaTimeScale.
var int   MaxRagdolls;			// Maximum number of simultaneous rag-dolls.
var float KarmaGravScale;		// Allows you to make ragdolls use lower friction than normal.
var bool  bKStaticFriction;		// Better rag-doll/ground friction model, but more CPU.

var()	   bool bKNoInit;				// Start _NO_ Karma for this level. Only really for the Entry level.
// jag

//-----------------------------------------------------------------------------
// Text info about level.

var() localized string Title;
var()           string Author;		    // Who built it.
var() localized string LevelEnterText;  // Message to tell players when they enter.
var()           string LocalizedPkg;    // Package to look in for localizations.
var             PlayerReplicationInfo Pauser;          // If paused, name of person pausing the game.
var		LevelSummary Summary;
var           string VisibleGroups;		    // List of the group names which were checked when the level was last saved
var transient string SelectedGroups;		// A list of selected groups in the group browser (only used in editor)
//-----------------------------------------------------------------------------
// Flags affecting the level.

var() bool           bLonePlayer;     // No multiplayer coordination, i.e. for entranceways.
var bool             bBegunPlay;      // Whether gameplay has begun.
var bool             bPlayersOnly;    // Only update players.
var bool             bHighDetailMode; // Client high-detail mode.
var bool			 bDropDetail;	  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool			 bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool             bStartup;        // Starting gameplay.
var	bool			 bPathsRebuilt;	  // True if path network is valid
var transient const bool		 bPhysicsVolumesInitialized;	// true if physicsvolume list initialized

//R6InGamePLanning
var bool   m_bInGamePlanningActive;
var bool   m_bInGamePlanningZoomingIn;
var bool   m_bInGamePlanningZoomingOut;
var float  m_fInGamePlanningZoomDistance;

//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() vector  CameraLocationDynamic;
var() vector  CameraLocationTop;
var() vector  CameraLocationFront;
var() vector  CameraLocationSide;
var() rotator CameraRotationDynamic;

//-----------------------------------------------------------------------------
// Audio properties.

var(Audio) string	Song;			// Filename of the streaming song.
var(Audio) float	PlayerDoppler;	// Player doppler shift, 0=none, 1=full.

//-----------------------------------------------------------------------------
// Miscellaneous information.

var() float Brightness;
var() texture Screenshot;
var texture DefaultTexture;
var texture WireframeTexture;
var texture WhiteSquareTexture;
var texture LargeVertex;
var int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching
} LevelAction;

//R6 change level in planning
var(R6Planning) INT R6PlanningMaxLevel;
var(R6Planning) INT R6PlanningMinLevel;
var(R6Planning) vector R6PlanningMaxVector;
var(R6Planning) vector R6PlanningMinVector;

var string		m_szGameTypeShown;
var BOOL        m_bGameTypesInitialized;
var FLOAT       m_fRainbowSkillMultiplier;
var FLOAT       m_fTerroSkillMultiplier;

//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.
var bool  m_bLogBandWidth;  // this bool says whether we want to log bwidth usage

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var GameInfo Game;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var const Controller ControllerList;
var PhysicsVolume PhysicsVolumeList;
//#ifdef R6ACTIONSPOT
var const R6ActionSpot m_ActionSpotList;
//#endif // #ifdef R6ACTIONSPOT

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//R6 Multiplayer SKINS
var(R6MultiPlayerSkins) string  GreenTeamPawnClass;
var(R6MultiPlayerSkins) string  RedTeamPawnClass;

//Skin names received by the client. If package does not exist, it will be downloaded.
var						material  GreenTeamSkin;
var						material  GreenHeadSkin;
var						material  GreenGogglesSkin;
var						material  GreenHandSkin;
var						material  GreenMenuSkin;
var						mesh	  GreenMesh;
var						class<StaticMeshActor> GreenHelmet;
var						staticmesh GreenHelmetMesh;
var						material  GreenHelmetSkin;
var						Object.Region    GreenMenuRegion;

var						material  RedTeamSkin;
var						material  RedHeadSkin;
var						material  RedGogglesSkin;
var						material  RedHandSkin;
var						material  RedMenuSkin;
var						mesh	  RedMesh;
var						class<StaticMeshActor> RedHelmet;
var						staticmesh RedHelmetMesh;
var						material  RedHelmetSkin;
var						Object.Region    RedMenuRegion;

//R6MissionObjectives 
var(R6MissionObjectives)	bool		m_bUseDefaultMoralityRules;
var(R6MissionObjectives)	float		m_fTimeLimit;
var(R6MissionObjectives) string         m_szMissionObjLocalization;
var(R6MissionObjectives) editinline Array<R6MissionObjectiveBase> m_aMissionObjectives;
var(R6MissionObjectives) Sound          m_sndMissionComplete;

//R6Weather
var					    Emitter	                m_WeatherEmitter;
var(R6LevelWeather)     class<R6WeatherEmitter> m_WeatherEmitterClass;
var                     class<R6WeatherEmitter> m_RepWeatherEmitterClass;
var                     Actor                   m_WeatherViewTarget;

//R6Breathing
var(R6Breathing)        class<Emitter>  m_BreathingEmitterClass;

//R6Sound
struct SoundZoneAudibleZones
{
    var() bool bZone00;
    var() bool bZone01;
    var() bool bZone02;
    var() bool bZone03;
    var() bool bZone04;
    var() bool bZone05;
    var() bool bZone06;
    var() bool bZone07;
    var() bool bZone08;
    var() bool bZone09;
    var() bool bZone10;
    var() bool bZone11;
    var() bool bZone12;
    var() bool bZone13;
    var() bool bZone14;
    var() bool bZone15;
    var() bool bZone16;
    var() bool bZone17;
    var() bool bZone18;
    var() bool bZone19;
    var() bool bZone20;
    var() bool bZone21;
    var() bool bZone22;
    var() bool bZone23;
    var() bool bZone24;
    var() bool bZone25;
    var() bool bZone26;
    var() bool bZone27;
    var() bool bZone28;
    var() bool bZone29;
    var() bool bZone30;
    var() bool bZone31;
    var() bool bZone32;
    var() bool bZone33;
    var() bool bZone34;
    var() bool bZone35;
    var() bool bZone36;
    var() bool bZone37;
    var() bool bZone38;
    var() bool bZone39;
    var() bool bZone40;
    var() bool bZone41;
    var() bool bZone42;
    var() bool bZone43;
    var() bool bZone44;
    var() bool bZone45;
    var() bool bZone46;
    var() bool bZone47;
    var() bool bZone48;
    var() bool bZone49;
    var() bool bZone50;
    var() bool bZone51;
    var() bool bZone52;
    var() bool bZone53;
    var() bool bZone54;
    var() bool bZone55;
    var() bool bZone56;
    var() bool bZone57;
    var() bool bZone58;
    var() bool bZone59;
    var() bool bZone60;
    var() bool bZone61;
    var() bool bZone62;
    var() bool bZone63;
};

var                     Sound          m_sndPlayMissionIntro;
var                     Sound          m_sndPlayMissionExtro;

var(R6Sound)            sound          m_SurfaceSwitchSnd;              // Sound event containing all the surface sounds - EB April 6th, 2002
var(R6Sound)            sound          m_SurfaceSwitchForOtherPawnSnd;  // Sound event containing all the surface sounds for the other pawn- SD July 30th, 2002
var(R6Sound)            sound          m_BodyFallSwitchSnd;             // Sound contain only the body fall sounds for player - SD
var(R6Sound)            sound          m_BodyFallSwitchForOtherPawnSnd; // Sound contain only the body fall sounds for the other pawn- SD
var(R6Sound)            sound          m_StartingMusic;    // When the Music is set in the level the music is play at the beginning of the game.
var(R6Sound)            String         m_csVoicesOneLinersBankName;
var(R6Sound)            FLOAT          m_fEndGamePauseTime;

var(R6Sound)            SoundZoneAudibleZones   m_SoundZoneAudibleZones[64];

var(R6Sound)            ETerroristNationality  m_eTerroristVoices; // Terrorist voice for the map.
var(R6Sound)            EHostageNationality    m_eHostageVoices; // Terrorist voice for the map.

var R6DecalManager m_DecalManager;

//#ifdef R6DBGVECTORINFO
var BOOL m_bShowDebugLine;
//#endif // #ifdef R6DBGVECTORINFO

//R6NEWRENDERERFEATURES
var     BOOL    m_bShowDebugLights;
var     BOOL    m_bShowDebugLODs;
var     BOOL    m_bShowOnlyTransparentSM;
var     BOOL    m_bNightVisionActive;
var     BOOL    m_bHeatVisionActive;
var     BOOL    m_bScopeVisionActive;
var     BOOL    m_bAllow3DRendering;
var     Texture m_pScopeMaskTexture;
var     Texture m_pScopeAddTexture;
var     INT     m_iMotionBlurIntensity;
var     BOOL    m_bSkipMotionBlur;  // used to avoid blur in menus

var     R6AbstractHostageMgr    m_hostageMgr;   // there's only one instance of hostageMgr
var     R6AbstractTerroristMgr  m_terroristMgr;
var     FLOAT   m_fDbgNavPointDistance;         // debug: max distance to player for displaying nav point.

var(R6SFX) Material m_pProneTrailMaterial;

//#ifdef R6WRITABLEMAP
struct WritableMapVertex
{
	var vector	position;
	var Color	color;
};

struct WritableMapStroke
{
	var float	timeStamp;
	var INT		numPoints;
};

struct WritableMapIcon
{
    var float   timeStamp;
    var INT     iIconIndex;
    var Color   color;
    var INT     iPosX;
    var INT     iPosY;
};

var		array<WritableMapVertex>	m_aCurrentStrip;
var		vector						m_vPredVector;
var		vector						m_vPredPredVector;

var		array<WritableMapVertex>	m_aWritableMapStrip;
var		array<WritableMapStroke>	m_aWritableMapTimeStamp;
var     array<WritableMapIcon>      m_aWritableMapIcons;

// R6SOUND
var BOOL		  m_bPlaySound;
var BOOL		  m_bCanStartStartingSound;
var BOOL          m_bSoundFadeFinish;
// END R6SOUND

var BOOL          m_bIsResettingLevel;
var R6ServerInfo  m_ServerSettings;

var R6LimitedSFX  m_aLimitedSFX[6];
var int m_iLimitedSFXCount;

//#ifdef R6PUNKBUSTER
//__WITH_PB__
var int iPBEnabled; //1 means PB server is running, 0 means not activated or deactivate cmd given but still running
var BOOL m_bPBSvRunning; // true means running, false means not running
//#endif R6PUNKBUSTER


// R6CODE: Game Mode
struct GameTypeInfo
{
    // **** if modified, update this struct in AZoneInfo.h ****
    var string		        m_szGameType;
	var string				m_szDisplayAsGameType;
    var EGameModeInfo       m_eGameModeInfo;
    var bool                m_bTeamAdversarial;
    var bool                m_bUsePreRecMessages;
    var bool                m_bCanSetNbOfTerroristToSpawn;
    var bool                m_bPlayWithNonRainbowNPCs;
    var bool                m_bUseRainbowComm;
    var bool                m_bDisplayBombTimer;
    var string              m_szNameLocalization;
    var string              m_szClassName;
    var string              m_szGreenTeamObjective;
    var string              m_szRedTeamObjective;
    var string              m_szGreenShortDescription;
    var string              m_szRedShortDescription;
    var string              m_szToString;
    var string              m_szSaveDirectoryName;
    var string              m_szEnglishDirName;
    var string              m_szLocalizationFile;
    // **** if modified, update this struct in AZoneInfo.h ****
};

var array<GameTypeInfo>		m_aGameTypeInfo;

const RDC_CamFirstPerson=0x01;      // 1st person death camera
const RDC_CamThirdPerson=0x02;      // 3rd person death camera
const RDC_CamFreeThirdP=0x04;       // Free 3rd person death camera
const RDC_CamGhost=0x08;            // camera ghost
const RDC_CamFadeToBk=0x10;         // fade to black
const RDC_CamTeamOnly=0x20;         // team only

// R6CODE END

enum ER6SoundState
{
    BANK_UnloadGun,
    BANK_UnloadAll
};

//R6HEARTBEAT
var BOOL                    m_bHeartBeatOn;
var FLOAT                   m_fDistanceHeartBeatVisible;

// #ifdef R6WRITABLEMAP
var(R6DrawingTool)	Texture						m_tWritableMapTexture;				
native(2801) final function AddWritableMapPoint(vector point, Color c);
native(2802) final function AddEncodedWritableMapStrip(string s);
native(1608) final function AddWritableMapIcon(string Msg);
// #endif//R6WRITABLEMAP

native(2711) final function SetBankSound(ER6SoundState eGameState); // This function is called when every actor is loaded.  Use to do specific stuff in native code
native(1604) final function FinalizeLoading(); // This function is called when every actor is loaded.  Use to do specific stuff in native code
native(1515) final function ResetLevelInNative();
native(1516) final function CallLogThisActor( Actor anActor );
native(1518) final function string GetMapNameLocalisation( string _szMapName );
// R6CODE+

//------------------------------------------------------------------
// GameTypeUseNbOfTerroristToSpawn
//	
//------------------------------------------------------------------
simulated event bool GameTypeUseNbOfTerroristToSpawn( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_bCanSetNbOfTerroristToSpawn;
        }
    }

    return false;
}

//------------------------------------------------------------------
// IsGameTypeMultiplayer
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeMultiplayer( string szGameType, optional BOOL _bNotIncludeGMI_None )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
			if (_bNotIncludeGMI_None)
				if (m_aGameTypeInfo[i].m_eGameModeInfo == GMI_None)
					return false;

            return ( m_aGameTypeInfo[i].m_eGameModeInfo!=GMI_SinglePlayer);
        }
    }

    return false;
}



//------------------------------------------------------------------
// IsGameTypeAdversarial
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeAdversarial( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return ( m_aGameTypeInfo[i].m_eGameModeInfo==GMI_Adversarial);
        }
    }

    return false;
}

simulated function bool IsGameTypeTeamAdversarial( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return ( m_aGameTypeInfo[i].m_bTeamAdversarial );
        }
    }

    return false;
}


//------------------------------------------------------------------
// IsGameTypeCooperative
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeCooperative( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return ( m_aGameTypeInfo[i].m_eGameModeInfo==GMI_Cooperative);
        }
    }

    return false;
}


//------------------------------------------------------------------
// IsGameTypeSquad
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeSquad( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return ( m_aGameTypeInfo[i].m_eGameModeInfo==GMI_Squad);
        }
    }

    return false;
}

//------------------------------------------------------------------
// IsGameTypeUsePreRecMessages
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeUsePreRecMessages( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_bUsePreRecMessages;
        }
    }

    return false;
}

//------------------------------------------------------------------
// IsGameTypeUseNotPlayableNPC
//	
//------------------------------------------------------------------
simulated event bool IsGameTypePlayWithNonRainbowNPCs( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_bPlayWithNonRainbowNPCs;
        }
    }

    return false;
}

//------------------------------------------------------------------
// IsGameTypeUseRainbowComm
//	
//------------------------------------------------------------------
simulated function bool IsGameTypeUseRainbowComm( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_bUseRainbowComm;
        }
    }

    return false;
}

//------------------------------------------------------------------
// GetGameNameLocalization
//	
//------------------------------------------------------------------
simulated function string GetGameNameLocalization( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_szNameLocalization;
        }
    }

    return "";
}

//------------------------------------------------------------------
// GetGameNameLocalization
//	
//------------------------------------------------------------------
function string GameTypeToString( string szGameType )
{

    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_szToString;
        }
    }

    return "";

}


//------------------------------------------------------------------
// GameTypeLocalizationFile
//	
//------------------------------------------------------------------
function string GameTypeLocalizationFile( string szGameType )
{

    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_szLocalizationFile;
        }
    }

    return "";

}

//------------------------------------------------------------------
// GetGreenTeamObjective
//	
//------------------------------------------------------------------
simulated function string GetGreenTeamObjective( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_szGreenTeamObjective;
        }
    }

    return "";
}

//------------------------------------------------------------------
// GetRedTeamObjective
//	
//------------------------------------------------------------------
simulated function string GetRedTeamObjective( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_szRedTeamObjective;
        }
    }

    return "";
}

//------------------------------------------------------------------
// GetGreenShortDescription
//	
//------------------------------------------------------------------
simulated function string GetGreenShortDescription( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_szGreenShortDescription;
        }
    }

    return "";
}

//------------------------------------------------------------------
// GetRedShortDescription
//	
//------------------------------------------------------------------
simulated function string GetRedShortDescription( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_szRedShortDescription;
        }
    }

    return "";
}

//------------------------------------------------------------------
// GetGameTypeFromClassName
//	
//------------------------------------------------------------------
simulated function string GetGameTypeFromClassName( string szGameClassName )
{
    local int i;

	for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szClassName == szGameClassName )
        {
            return m_aGameTypeInfo[i].m_szGameType;
        }
    }
    return "";
}

//------------------------------------------------------------------
// GetGameTypeClassName
//	
//------------------------------------------------------------------
simulated function string GetGameTypeClassName( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_szClassName;
        }
    }

    return "";
}


simulated function GetGameTypeSaveDirectories(out string SaveDirectory, out string EnglishSaveDir)
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == Game.m_szGameTypeFlag )
        {
            SaveDirectory = m_aGameTypeInfo[i].m_szSaveDirectoryName;
            EnglishSaveDir = m_aGameTypeInfo[i].m_szEnglishDirName;
        }
    }
}

simulated function BOOL FindSaveDirectoryNameFromEnglish(out string SaveDirectory, string EnglishSaveDir)
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( EnglishSaveDir == m_aGameTypeInfo[i].m_szEnglishDirName )
        {
            SaveDirectory = m_aGameTypeInfo[i].m_szSaveDirectoryName;
            return true;
        }
    }
    return false;
}

//------------------------------------------------------------------
// GetGameTypeFromLocName ; The optional parameter is for similar localization name for single and multi.
//	
//------------------------------------------------------------------
simulated function string GetGameTypeFromLocName( string szGameTypeLoc , optional BOOL _bOnlyMulti)
{
    local int i;
	local BOOL bFind;

	bFind = true;

    for ( i = 0; i < m_aGameTypeInfo.Length; i++ )
    {
        if ( m_aGameTypeInfo[i].m_szNameLocalization ~= szGameTypeLoc )
        {
			if (_bOnlyMulti)
			{
				bFind = (m_aGameTypeInfo[i].m_eGameModeInfo!=GMI_SinglePlayer);
			}

			if (bFind)
            {
                return m_aGameTypeInfo[i].m_szGameType;
            }
        }
    }

    return "RGM_NoRulesMode";
}

//------------------------------------------------------------------
// GetHostageMgr: singleton pattern
//	
//------------------------------------------------------------------
simulated function Actor GetHostageMgr()
{
	local class<R6AbstractHostageMgr> DesiredHostageMgrClass;
    local R6ModMgr pModManager;

    if ( m_hostageMgr == none )
    {
        pModManager = class'Actor'.static.GetModMgr();
        if ( pModManager.m_pCurrentMod.m_HostageMgrToSpawn != "" )
            DesiredHostageMgrClass = class<R6AbstractHostageMgr>(DynamicLoadObject(pModManager.m_pCurrentMod.m_HostageMgrToSpawn, class'Class'));
        else
            DesiredHostageMgrClass = class<R6AbstractHostageMgr>(DynamicLoadObject("R6Engine.R6HostageMgr", class'Class'));
        m_hostageMgr = spawn( DesiredHostageMgrClass );
    }
    
    return m_hostageMgr;
}

//============================================================================
// Object GetTerroristMgr - 
//============================================================================
function Object GetTerroristMgr()
{
	local class<R6AbstractTerroristMgr> mgrClass;

    if ( m_terroristMgr == none )
    {
        mgrClass = class<R6AbstractTerroristMgr>(DynamicLoadObject("R6Engine.R6TerroristMgr", class'Class')); 
        m_terroristMgr = new mgrClass;
        m_terroristMgr.Initialization( Self );
    }
    
    return m_terroristMgr;
} 

//------------------------------------------------------------------
// GameTypeInfoAdd
//  add the data needed to fill a GameTypeInfo struct
//------------------------------------------------------------------
simulated function GameTypeInfoAdd(   string       szGameType,			// the game mode
								      string       szDisplayAsGameType, // if game mode availability is similar to an already existing one
									  EGameModeInfo  eGameModeInfoType, // which GM can be played in
	  								  bool         bTeamAdversarial,	// if the GM can be played in Team Adversarial
									  bool         bUsePreRecMessage,   // if the GM can use the preRecorded message
									  bool         bSetNbTerro,			// if CanSetNbOfTerroristToSpawn in the menu
									  bool         bPlayWithNonRainbowNPCs,	// if NPC (Terrorist, Hostage Civilian)
									  bool         bUseRainbowComm,		// if the GM use the rainbow communication (Open Door, etc.)
									  string       szLocalizationFile,	// localization 
									  string       szClassName,			// The name of the class
									  string       szNameLocalization,  // localisation name
                                      string       szGreenTeamObjective,//Multi:Green team mission objective localized, you can leave this empty in single player
                                      string       szRedTeamObjective,  //Multi:Red team mission objective localized, you can leave this empty in single player
                                      string       szGreenShortDescription, 
                                      string       szRedShortDescription, 
                                      string       szToString)          //This can be used for look up in R6GameMode.int (same has the enum entry)
{
	local int index;
	local GameTypeInfo GameTypeToAdd;

	for(index = 0; index < m_aGameTypeInfo.Length; index++)
	{
		if(m_aGameTypeInfo[index].m_szGameType == szGameType)
			return; //Game type with the same name already exists.
	}

	GameTypeToAdd.m_eGameModeInfo           = eGameModeInfoType;
	GameTypeToAdd.m_bTeamAdversarial        = bTeamAdversarial;
	GameTypeToAdd.m_bUsePreRecMessages      = bUsePreRecMessage;
	GameTypeToAdd.m_bCanSetNbOfTerroristToSpawn = bSetNbTerro;
	GameTypeToAdd.m_bPlayWithNonRainbowNPCs = bPlayWithNonRainbowNPCs;
	GameTypeToAdd.m_bUseRainbowComm         = bUseRainbowComm;
	GameTypeToAdd.m_szGameType              = szGameType;
	GameTypeToAdd.m_szDisplayAsGameType     = szDisplayAsGameType;
	GameTypeToAdd.m_szLocalizationFile      = szLocalizationFile;
	GameTypeToAdd.m_szClassName             = szClassName;
	GameTypeToAdd.m_szNameLocalization      = szNameLocalization;
	GameTypeToAdd.m_szGreenTeamObjective    = szGreenTeamObjective;
	GameTypeToAdd.m_szRedTeamObjective      = szRedTeamObjective;
	GameTypeToAdd.m_szGreenShortDescription = szGreenShortDescription;
	GameTypeToAdd.m_szRedShortDescription   = szRedShortDescription;
	GameTypeToAdd.m_szToString              = szToString;
	m_aGameTypeInfo[index] = GameTypeToAdd;
}

simulated function GameTypeSaveGameInfo( INT          iIndex,
                                         string       szSaveDirectoryName, //Directory name where to put the save plannin
                                         string       szEnglishDirName)   //Directory Name to match the game type in savegames

{
    assert( iIndex < m_aGameTypeInfo.Length );

    m_aGameTypeInfo[iIndex].m_szSaveDirectoryName     = szSaveDirectoryName;
    m_aGameTypeInfo[iIndex].m_szEnglishDirName        = szEnglishDirName;
    
}

//------------------------------------------------------------------
// SetGameTypeStrings 
//  
//------------------------------------------------------------------
simulated function SetGameTypeStrings()
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; ++i )
    {
        //log( "* " $ m_aGameTypeInfo[i].m_szToString );
        
        if ( m_aGameTypeInfo[i].m_szGreenTeamObjective != "" )
        {
            m_aGameTypeInfo[i].m_szGreenTeamObjective = 
                Localize( m_aGameTypeInfo[i].m_szToString, "GreenTeamObj", m_aGameTypeInfo[i].m_szGreenTeamObjective );
            //log( "- greenT:" $m_aGameTypeInfo[i].m_szGreenTeamObjective );
        }

        if ( m_aGameTypeInfo[i].m_szRedTeamObjective != "" )
        {
            m_aGameTypeInfo[i].m_szRedTeamObjective = 
                Localize( m_aGameTypeInfo[i].m_szToString, "RedTeamObj", m_aGameTypeInfo[i].m_szRedTeamObjective );
            //log( "-   redT:" $m_aGameTypeInfo[i].m_szRedTeamObjective );
        }
        
        if ( m_aGameTypeInfo[i].m_szGreenShortDescription != "" )
        {
            m_aGameTypeInfo[i].m_szGreenShortDescription = 
                Localize( m_aGameTypeInfo[i].m_szToString, "GreenShortDesc", m_aGameTypeInfo[i].m_szGreenShortDescription );
            //log( "- greenD:" $m_aGameTypeInfo[i].m_szGreenShortDescription );
        }
        
        if ( m_aGameTypeInfo[i].m_szRedShortDescription != "" )
        {
            m_aGameTypeInfo[i].m_szRedShortDescription = 
                Localize( m_aGameTypeInfo[i].m_szToString, "RedShortDesc", m_aGameTypeInfo[i].m_szRedShortDescription );
            //log( "-   redD:" $m_aGameTypeInfo[i].m_szRedShortDescription );
        }
    }
}

simulated function SetGameTypeDisplayBombTimer( string szGameType )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; ++i )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            m_aGameTypeInfo[i].m_bDisplayBombTimer = true;
            break;
        }
    }
}

simulated function bool IsGameTypeDisplayBombTimer(  string szGameType  )
{
    local int i;

    for ( i = 0; i < m_aGameTypeInfo.Length; ++i )
    {
        if ( m_aGameTypeInfo[i].m_szGameType == szGameType )
        {
            return m_aGameTypeInfo[i].m_bDisplayBombTimer;
        }
    }

    return false;
}
// R6CODE-

//-----------------------------------------------------------------------------
// Functions.

// R6CODE+
simulated event PreBeginPlay()
{
	//MissionPack1 2
	local R6ModMgr pModMgr;
	local R6Mod pCurrentMod;
	// end of MissionPack1 2

	if ( m_bGameTypesInitialized )  // Make sure game types are only initialized once
		return;

	m_bGameTypesInitialized = TRUE;

	pModMgr = class'Actor'.static.GetModMgr();
	pModMgr.AddGameTypes(self);
}



//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    local R6DecalManager aMgr;

    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    aMgr = m_DecalManager;
    m_DecalManager = none;
    if(aMgr!=none)
        aMgr.destroy();

    m_bCanStartStartingSound=false;
    
    if(!Level.bKNoInit)
    {
        #ifdefDEBUG log("DecalManager spawned for "$self); #endif
        m_DecalManager = Spawn(class'Engine.R6DecalManager');
    }
    
    if(m_terroristMgr!=none)
        m_terroristMgr.ResetOriginalData();

    m_bInGamePlanningActive = false;
}

// R6CODE-
//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL();

//#ifdef R6PUNKBUSTER
//__WITH_PB__
native (1319) final simulated function PBNotifyServerTravel();
//#endif R6PUNKBUSTER

//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL();

//
// Jump the server to a new level.
//
event ServerTravel( string URL, bool bItems )
{
	if( NextURL=="" )
	{
		bNextItems          = bItems;
		NextURL             = URL;
		if( Game!=None )
			Game.ProcessServerTravel( URL, bItems );
		else
			NextSwitchCountdown = 0;
	}
}

//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted()
{
	local DefaultPhysicsVolume P;
	P = None;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	// perform garbage collection of objects (not done during gameplay)
	GarbageCollect();
	Super.Reset();
}

simulated function AddPhysicsVolume(PhysicsVolume NewPhysicsVolume)
{
	local PhysicsVolume V;

	for ( V=PhysicsVolumeList; V!=None; V=V.NextPhysicsVolume )
		if ( V == NewPhysicsVolume )
			return;

	NewPhysicsVolume.NextPhysicsVolume = PhysicsVolumeList;
	PhysicsVolumeList = NewPhysicsVolume;
}

simulated function RemovePhysicsVolume(PhysicsVolume DeletedPhysicsVolume)
{
	local PhysicsVolume V,Prev;

	for ( V=PhysicsVolumeList; V!=None; V=V.NextPhysicsVolume )
	{
		if ( V == DeletedPhysicsVolume )
		{
			if ( Prev == None )
				PhysicsVolumeList = V.NextPhysicsVolume;
			else
				Prev.NextPhysicsVolume = V.NextPhysicsVolume;	
			return;
		}
		Prev = V;
	}
}

//R6ARMPATCHES
native(2612) final function NotifyMatchStart();

// R6CODE+

//------------------------------------------------------------------
// GetCamSpot
//	
//------------------------------------------------------------------
function actor GetCamSpot( string szGameType )
{
    local Actor StartSpot;

    foreach AllActors( class'Actor', StartSpot )
    {
        if ( StartSpot.isA( 'R6CameraSpot' ) &&
             StartSpot.IsAvailableInGameType( szGameType ) )
        {
            return StartSpot;
        }
    }


    return none;
}


//------------------------------------------------------------------
// ResetLevel
//	
//------------------------------------------------------------------
simulated function ResetLevel( int iNbOfRestart )
{
    local Actor aActor;
    local Pawn  aPawn;
    local Controller C, pNextController;
    local PlayerController PC;

    log( "Resetting Level (total=" $iNbOfRestart$ ")" );

    m_bIsResettingLevel = true;

    foreach AllActors( class'Actor', aActor )
        aActor.FirstPassReset();

    if ( NetMode != NM_Client )  // server job
    {
        // loop on controller. Destroy Pawns and destroy AI Controller
        C = Level.ControllerList;
        while ( C != none )
        {
            PC = PlayerController(C); 
            // inform player to reset
            if ( PC != none )
            {
                PC.ResettingLevel(iNbOfRestart);
            }

            if ( C.pawn != none ) // if a pawn
            {
                aPawn = C.pawn; // temp handle on this pawn
                if (PC!=none)
                {
                    PC.UnPossess();      // unpossess this pawn
                }
                aPawn.destroy(); // destroy this pawn

                C.Pawn = none;
            }

            pNextController = C.NextController;
            if ( PC != none )
            {
				C.GotoState('BaseSpectating'); //                C.GotoState('PlayerWaiting');
            }
            else if ( AIController(C) != none )
            {
                C.destroy();
            }
            C = pNextController;
        }
    }

    if ( m_bResetSystemLog ) log( "RESET: ResetOriginalData of all actors..." );
    foreach AllActors( class'Actor', aActor )
    {
        // delete those actor
        if ( aActor.bTearOff || aActor.m_bDeleteOnReset )
        {
            if ( !aActor.destroy() )
            {
#ifdefDEBUG
                log( "WarningReset: destroy failed for " $aActor.name );
#endif
            }
        }
        else
        {
            aActor.ResetOriginalData();
        }
    }

    ResetLevelInNative();

    // perform garbage collection of objects (not done during gameplay)
    GarbageCollect();

    foreach AllActors( class'Actor', aActor )
    {
        if ( (PlayerController(aActor)==none) &&    // the state for playercontroller already set
             (GameInfo(aActor)==none) )             // and state for Game info will be set
        {
            aActor.setInitialState();
        }

#ifdefDEBUG
        // list all actor that are supposed to be deleted
        if ( aActor.bTearOff && !aActor.bDeleteMe )
        {
            log( "WarningReset: " $aActor.name$ " was teared off (delete me)" );
        }
        
        if ( NetMode != NM_DedicatedServer )
        {
            if ( aActor.m_bSpawnedInGame && !aActor.bDeleteMe )
            {
                log( "WarningReset: " $aActor.name$ " was spawned in game (delete me)" );
            }
        }

        // actor who are suppossed to be deleted
        if ( !aActor.bDeleteMe )
        {
            if ( aActor.bTearOff || aActor.m_bDeleteOnReset )
            {
                log( "WarningReset: " $aActor.name$ " should be deleted" );
            }        
        }
#endif
    }


    // Stop and reinitialize all sound.
    StopAllSounds();
    if (Level.NetMode != NM_Standalone)
        StopAllMusic();

    ResetVolume_AllTypeSound();

    m_bIsResettingLevel = false;
}


//-----------------------------------------------------------------------------
// GetMissionObjLocFile
//   return the string for the MObj or the default one
//-----------------------------------------------------------------------------
function string GetMissionObjLocFile( R6MissionObjectiveBase obj )
{
    if ( obj != none && obj.m_szMissionObjLocalization != "" )
        return obj.m_szMissionObjLocalization;

    return m_szMissionObjLocalization;
}

// R6CODE-

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority )
		Pauser, TimeDilation;

    
    reliable if( Role==ROLE_Authority )
        m_RepWeatherEmitterClass;

    reliable if( Role==ROLE_Authority )
        m_bShowFloppy, m_fCompteurFrameDetection;
}

// R6Weather
simulated event PostBeginPlay()
{
    if(NetMode != NM_Client)
        m_RepWeatherEmitterClass = m_WeatherEmitterClass;

    if((NetMode == NM_Standalone || NetMode == NM_ListenServer) && m_WeatherEmitterClass != none)
        m_WeatherEmitter = Spawn(m_WeatherEmitterClass);

    GetTerroristMgr();
}

simulated function SetWeatherActive(BOOL bWeatherActive)
{
    if(bWeatherActive && m_WeatherEmitter.Emitters[0].m_iPaused == 1)
    {
        m_WeatherEmitter.Emitters[0].m_iPaused = 0;
        m_WeatherEmitter.Emitters[0].AllParticlesDead = false;
    }
    else if(!bWeatherActive && m_WeatherEmitter.Emitters[0].m_iPaused == 0)
    {
        m_WeatherEmitter.Emitters[0].m_iPaused = 1;
        m_WeatherEmitter.Emitters[0].AllParticlesDead = false;
    }
}
//END R6Weather

defaultproperties
{
     PhysicsDetailLevel=PDL_Medium
     m_iNbOfFBToSpawnBasedOnNbPlayers=3
     MaxRagdolls=32
     R6PlanningMinLevel=65535
     bKStaticFriction=True
     bHighDetailMode=True
     m_bUseDefaultMoralityRules=True
     m_bAllow3DRendering=True
     m_bPlaySound=True
     TimeDilation=1.000000
     KarmaTimeScale=0.900000
     RagdollTimeScale=1.000000
     KarmaGravScale=1.000000
     m_fInGamePlanningZoomDistance=5000.000000
     Brightness=1.000000
     m_fRainbowSkillMultiplier=1.000000
     m_fTerroSkillMultiplier=1.000000
     m_fEndGamePauseTime=8.000000
     m_fDbgNavPointDistance=2000.000000
     DefaultTexture=Texture'Engine.DefaultTexture'
     WireframeTexture=Texture'Engine.WireframeTexture'
     WhiteSquareTexture=Texture'Engine.WhiteSquareTexture'
     LargeVertex=Texture'Engine.LargeVertex'
     Title="Untitled"
     VisibleGroups="None"
     GreenTeamPawnClass="R6Characters.R6RainbowMediumBlue"
     RedTeamPawnClass="R6Characters.R6RainbowMediumEuro"
     m_szMissionObjLocalization="R6MissionObjectives"
     bWorldGeometry=True
     bAlwaysRelevant=True
     bHiddenEd=True
}
