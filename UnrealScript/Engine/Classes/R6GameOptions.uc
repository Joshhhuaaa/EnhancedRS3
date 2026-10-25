//=============================================================================
//  R6GameOptions.uc : This class is in charge on keeping the different game options
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/27 * Created by Alexandre Dionne
//    2002/06/13 * Added graphic options
//=============================================================================

class R6GameOptions extends Object
    config(USER)
    native;

//=============================================================================
// NON-CONFIG VARIABLES
//=============================================================================
var BOOL EAXCompatible;	// if the sound card support EAX
var BOOL m_bChangeResolution;
//#ifdefR6PUNKBUSTER
var BOOL m_bPBInstalled;   // if PB is installed
//#endif

// ========================================================
// ========================================================
// NOTE: IF YOU ADD A NEW VARIABLE CONFIG IN THIS CLASS, AND ITS AN OPTIONS
//	     DON`T FORGET TO PUT THE DEFAULT VALUE IN DEFAULT.INI FILE
// ========================================================
// ========================================================
var config color  m_reticuleFriendColour;	// when the reticule is on a friend
var config string MPAutoSelection;			// auto selection in MP (force to GREEN, RED or nothing)
var config BOOL   SplashScreen;				// for german version
var config FLOAT  CountDownDelayTime;       // Time between all player are ready and the beginning of the round

//=============================================================================
// GAME
//=============================================================================
var bool UnlimitedPractice;					// Unlimited Practice
var config bool AlwaysRun;					// Automatically makes the operative run whenever the player gives the move command
var config bool InvertMouse;				// When ON, if the mouse is pushed the targeting reticule will go down, and if the mouse is pulled, the targeting reticule will go up.
var config bool Hide3DView;                 // always have the 3d View active in the planning
var config BOOL PopUpLoadPlan;				// Enable/disable pop-up load planning
var config BOOL PopUpQuickPlay;				// Enable/disable Quick play pop-up
var config FLOAT MouseSensitivity;			// Sets the amount of movement the mouse gives to the targeting reticule.
var config INT AutoTargetSlider;			// 0= off, 1=?, 2=?, 3=? TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//=============================================================================
// SOUND
//=============================================================================
enum EGameOptionsAudioVirtual
{
    eAV_High,
    eAV_Low,
    eAV_None
};

var config INT	AmbientVolume;				// the ambient volume
var config INT	VoicesVolume;				// the voices volume
var config INT	MusicVolume;				// the music volume
var config INT  SndQuality;					// the sound quality
var config BOOL SndHardware;				// 3D Audio Hardware Acceleration
var config BOOL EAX;						// EAX
var config EGameOptionsAudioVirtual AudioVirtual;	// the audio virtualization

//=============================================================================
// MULTI
//=============================================================================
enum EGameOptionsNetSpeed
{
	eNS_T1,
	eNS_T3,
	eNS_Cable,
	eNS_ADSL,
	eNS_Modem
};

var config EGameOptionsNetSpeed NetSpeed;	// The speed connection
var config string CharacterName;			// multiplayer char name
var config INT    Gender;					// gender of the player (a int for Button ID)
var config string ArmPatchTexture;			// Skins, ArmPatches, etc.
var config INT    ChangeNameTime;           // Time between a change name
var config BOOL	  ActivePunkBuster;			// Active PunkBuster in client
var config BOOL	  WantTriggerLag;           // Activate Trigger Lag

//=============================================================================
// GRAPHIC
//=============================================================================
enum EGameOptionsGraphicLevel
{
    eGL_Low,
    eGL_Medium,
    eGL_High
};

enum EGameOptionsEffectLevel
{
    eEL_None,
    eEL_Low,
    eEL_Medium,
    eEL_High
};

//=============================================================================
// HUD FILTERS
//=============================================================================
var config bool   HUDShowCharacterInfo;
var config bool   HUDShowCurrentTeamInfo;
var config bool   HUDShowOtherTeamInfo;
var config bool   HUDShowWeaponInfo;
var config bool   HUDShowFPWeapon;
var config bool   HUDShowReticule;
var config bool   HUDShowWaypointInfo;
var config bool   HUDShowActionIcon;
var config BOOL   HUDShowPlayersName;							// show the teammates names
var config bool   ShowRadar;                // show radar in multiplayer
var config color  HUDMPColor;
var config color  HUDMPDarkColor;

// Textures
var config EGameOptionsGraphicLevel     TextureDetail;
var config EGameOptionsGraphicLevel     LightmapDetail;

// Character's LOD
var config EGameOptionsGraphicLevel     RainbowsDetail;
var config EGameOptionsGraphicLevel     HostagesDetail;
var config EGameOptionsGraphicLevel     TerrosDetail;

// Character's shadow
var config EGameOptionsEffectLevel      RainbowsShadowLevel;
var config EGameOptionsEffectLevel      HostagesShadowLevel;
var config EGameOptionsEffectLevel      TerrosShadowLevel;

// Misc graphics
var config INT							R6ScreenSizeX;
var config INT							R6ScreenSizeY;
var config INT							R6ScreenRefreshRate;
var config BOOL                         AnimatedGeometry;
var config BOOL                         HideDeadBodies;
var config EGameOptionsEffectLevel      GoreLevel;
var config EGameOptionsEffectLevel      DecalsDetail;
var config BOOL                         ShowRefreshRates;
var config BOOL                         LowDetailSmoke;
var config BOOL                         AllowChangeResInGame;

//=============================================================================
// PATCH SERVICE
//=============================================================================

var config bool							AutoPatchDownload;


//=========================================
// ResetGameToDefault: Reset the game options, use default.ini value
//=========================================
function ResetGameToDefault()
{
	ResetConfig("AlwaysRun");				// False
	ResetConfig("InvertMouse");				// False
    ResetConfig("Hide3DView");              // False
	ResetConfig("MouseSensitivity");		// 50
	ResetConfig("AutoTargetSlider");		// 0
	ResetConfig("PopUpLoadPlan");			// True
	ResetConfig("PopUpQuickPlay");			// True
}

//=========================================
// ResetGameToDefault: Reset the game options, use default.ini value
//=========================================
function ResetSoundToDefault( BOOL _bInGame)
{
	ResetConfig("AmbientVolume");			// 50
	ResetConfig("MovementVolume");			// 50
	ResetConfig("VoicesVolume");			// 50
	ResetConfig("MusicVolume");				// 50
	ResetConfig("SndHardware");				// False
	ResetConfig("EAX");						// False
	ResetConfig("AudioVirtual");			// eAV_None

	if (!_bInGame)
	{
		ResetConfig("SndQuality");			// True -- HIGH
	}
}

//=========================================
// ResetGraphicsToDefault: Reset the graphics options, use default.ini value
//=========================================
function ResetGraphicsToDefault( BOOL _bInGame)
{
	ResetConfig("R6ScreenSizeX");			// 800 x
	ResetConfig("R6ScreenSizeY");			// 600
    ResetConfig("R6ScreenRefreshRate");     // 60
	ResetConfig("TextureDetail");			// eGL_High
	ResetConfig("LightmapDetail");			// eGL_Medium
	ResetConfig("RainbowsDetail");			// eGL_High
	ResetConfig("TerrosDetail");			// eGL_High
	ResetConfig("HostagesDetail");			// eGL_High
	ResetConfig("AnimatedGeometry");		// True
	ResetConfig("HideDeadBodies");          // False
    ResetConfig("ShowRefreshRates");        // False
    ResetConfig("LowDetailSmoke");          // False

	if ( !_bInGame)
	{
		ResetConfig("RainbowsShadowLevel");		// eEL_High
		ResetConfig("HostagesShadowLevel");		// eEL_None
		ResetConfig("TerrosShadowLevel");		// eEL_None
		ResetConfig("DecalsDetail");            // eEL_Medium
		ResetConfig("GoreLevel");				// eEL_High
	}
}

//=========================================
// ResetGraphicsToDefault: Reset the graphics options, use default.ini value
//=========================================
function ResetMultiToDefault()
{
	ResetConfig("CharacterName");			// John Doe
	ResetConfig("NetSpeed");				// 
	ResetConfig("Gender");					// 0 = male 
    ResetConfig("ArmPatchTexture");
    ResetConfig("WantTriggerLag");          //False
}

//=========================================
// ResetHudToDefault: Reset the hud options, use default.ini value
//=========================================
function ResetHudToDefault()
{
	ResetConfig("HUDShowCharacterInfo");	// true
    ResetConfig("HUDShowCurrentTeamInfo");	// true
	ResetConfig("HUDShowOtherTeamInfo");	// true
    ResetConfig("HUDShowWeaponInfo");	    // true
	ResetConfig("HUDShowFPWeapon");			// true
    ResetConfig("HUDShowReticule");			// true
	ResetConfig("HUDShowWaypointInfo");		// true
    ResetConfig("HUDShowActionIcon");	    // true
	ResetConfig("HUDShowPlayersName");		// true
	ResetConfig("ShowRadar");               // true
}

//=========================================
// ResetPatchServiceToDefault: Reset the patch service options, use default.ini value
//=========================================
function ResetPatchServiceToDefault()
{
	ResetConfig("AutoPatchDownload");	// false
}

defaultproperties
{
     AudioVirtual=eAV_None
     TextureDetail=eGL_High
     LightmapDetail=eGL_High
     GoreLevel=eEL_High
     DecalsDetail=eEL_Medium
     AmbientVolume=100
     VoicesVolume=100
     MusicVolume=100
     SndQuality=1
     Gender=1
     ChangeNameTime=60
     R6ScreenSizeX=1024
     R6ScreenSizeY=768
     R6ScreenRefreshRate=100
     AlwaysRun=True
     PopUpLoadPlan=True
     PopUpQuickPlay=True
     ActivePunkBuster=True
     HUDShowCharacterInfo=True
     HUDShowCurrentTeamInfo=True
     HUDShowOtherTeamInfo=True
     HUDShowWeaponInfo=True
     HUDShowFPWeapon=True
     HUDShowReticule=True
     HUDShowWaypointInfo=True
     HUDShowActionIcon=True
     HUDShowPlayersName=True
     ShowRadar=True
     ShowRefreshRates=True
     LowDetailSmoke=True
     MouseSensitivity=60.000004
     m_reticuleFriendColour=(G=255)
     HUDMPColor=(B=239,G=209,R=129,A=75)
     characterName="UBu"
}
