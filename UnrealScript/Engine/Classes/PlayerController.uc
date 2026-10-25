//=============================================================================
// PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// This is a built-in Unreal class and it shouldn't be modified.
// for the change in Possess().
//=============================================================================
class PlayerController extends Controller
	config(user)
	native
	nativereplication;

import class R6GameMenuCom;

// Player info.
var const player Player;

// player input control
var globalconfig	bool 	bLookUpStairs;	// look up/down stairs (player)
var globalconfig	bool	bSnapToLevel;	// Snap to level eyeheight when not mouselooking
var globalconfig	bool	bAlwaysMouseLook;
var globalconfig	bool	bKeyboardLook;	// no snapping when true
var bool					bCenterView;

// Player control flags
var bool		bBehindView;    // Outside-the-player view.
var bool		bFrozen;		// set when game ends or player dies to temporarily prevent player from restarting (until cleared by timer)
var bool		bPressedJump;
var bool		bUpdatePosition;
var bool		bIsTyping;
var bool		bFixedCamera;	// used to fix camera in position (to view animations)
var bool		bJumpStatus;	// used in net games
var	bool		bUpdating;

//#ifndef R6CODE
//var globalconfig bool	bNeverSwitchOnPickup;	// if true, don't automatically switch to picked up weapon
//#endif // #ifndef R6CODE

var bool		bZooming;
var	bool		bOnlySpectator;	// This controller is not allowed to possess pawns

//#ifdef R6CODE
var bool		m_bReadyToEnterSpectatorMode;
//#endif

//#ifndef R6CODE
//var globalconfig bool bAlwaysLevel;
//#endif // #ifndef R6CODE
var bool		bSetTurnRot;
var bool		bCheatFlying;	// instantly stop in flying mode
var bool		bFreeCamera;	// free camera when in behindview mode (for checking out player models and animations)
var	bool		bZeroRoll;
var	bool		bCameraPositionLocked;
//#ifndef R6CODE
//var globalconfig bool ngSecretSet;
//#endif // #ifndef R6CODE
var bool		ReceivedSecretChecksum;

var float AimingHelp;
var float WaitDelay;			// Delay time until can restart

var input float
	aBaseX, aBaseY, aBaseZ,	aMouseX, aMouseY,
	aForward, aTurn, aStrafe, aUp, aLookUp;

var input byte
	bStrafe, bSnapLevel, bLook, bFreeLook, bTurn180, bTurnToNearest, bXAxis, bYAxis;

var EDoubleClickDir DoubleClickDir;		// direction of movement key double click (for special moves)

//#ifdef R6CODE
var BOOL   m_bInitFirstTick;

// Camera info.
var int ShowFlags;
var int Misc1,Misc2;
var int RendMap;
var float        OrthoZoom;     // Orthogonal/map view zoom factor.
var const actor ViewTarget;
var float CameraDist;		// multiplier for behindview camera dist
var transient array<CameraEffect> CameraEffects;	// A stack of camera effects.

//#ifdef R6CODE
var float DesiredFOV;
var float DefaultFOV;
//#else
//var globalconfig float DesiredFOV;
//var globalconfig float DefaultFOV;
//#endif R6CODE
var float		ZoomLevel;

// Screen flashes
var vector FlashScale, FlashFog;
var float DesiredFlashScale, ConstantGlowScale, InstantFlash;
var vector DesiredFlashFog, ConstantGlowFog, InstantFog;

// Remote Pawn ViewTargets
var rotator		TargetViewRotation; 
var float		TargetEyeHeight;
var vector		TargetWeaponViewOffset;

var HUD	myHUD;	// heads up display info

var float LastPlaySound;
//#ifndef R6CODE
//var globalconfig int AnnouncerVolume;
//#endif // #ifndef R6CODE

// Music info.
var string				Song;
var EMusicTransition	Transition;

// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
var SavedMove SavedMoves;	// buffered moves pending position updates
var SavedMove FreeMoves;	// freed moves, available for buffering
var SavedMove PendingMove;	
var float CurrentTimeStamp,LastUpdateTime,ServerTimeStamp,TimeMargin, ClientUpdateTime;
var globalconfig float MaxTimeMargin;
/*R6CHANGEWEAPONSYSTEM
var Weapon OldClientWeapon;
*/
var int WeaponUpdate;

// Progess Indicator - used by the engine to provide status messages (HUD is responsible for displaying these).
var string	ProgressMessage[4];
var color	ProgressColor[4];
var float	ProgressTimeOut;

// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;

// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;

// ngWorldStats Logging
var globalconfig private string ngWorldSecret;

var class<LocalMessage> LocalMessageClass;

// view shaking (affects roll, and offsets camera position)
var float	MaxShakeRoll; // max magnitude to roll camera
var vector	MaxShakeOffset; // max magnitude to offset camera position
var float	ShakeRollRate;	// rate to change roll
var vector	ShakeOffsetRate;
var vector	ShakeOffset; //current magnitude to offset camera from shake
var float	ShakeRollTime; // how long to roll.  if value is < 1.0, then MaxShakeOffset gets damped by this, else if > 1 then its the number of times to repeat undamped
var vector	ShakeOffsetTime;

var Pawn		TurnTarget;
var config int	EnemyTurnSpeed;
var int			GroundPitch;
var rotator		TurnRot180;

var vector OldFloor;		// used by PlayerSpider mode - floor for which old rotation was based;

// Components ( inner classes )
//R6CODE
var CheatManager	CheatManager;	// Object within playercontroller that manages "cheat" commands
//var private CheatManager	CheatManager;	// Object within playercontroller that manages "cheat" commands
var class<CheatManager>		CheatClass;		// class of my CheatManager
var private transient PlayerInput	PlayerInput;	// Object within playercontroller that manages player input.
var class<PlayerInput>		InputClass;		// class of my PlayerInput

// Demo recording view rotation
var int DemoViewPitch;
var int DemoViewYaw;
var globalconfig float NetClientMaxTickRate;
var float m_fNextUpdateTime;

//R6CODE
const K_GlobalID_size = 16;
var string  m_szGlobalID;
var PlayerVerCDKeyStatus m_stPlayerVerCDKeyStatus;
var PlayerVerCDKeyStatus m_stPlayerVerModCDKeyStatus;

var int     m_iChangeNameLastTime; // last time change name was requested
var BOOL    m_PreLogOut;        // this controller is about to be destroyed
struct PlayerPrefInfo
{
    var string m_CharacterName;
    var string m_ArmorName;

    var string m_WeaponName1;
    var string m_WeaponName2;

    var string m_WeaponGadgetName1;
    var string m_WeaponGadgetName2;
    
    var string m_BulletType1;
    var string m_BulletType2;

    var string m_GadgetName1;
    var string m_GadgetName2;
};

var PlayerPrefInfo m_PlayerPrefs;
var R6RainbowStartInfo  m_PlayerStartInfo;
var FLOAT   m_fLoginTime;
var string  m_szIpAddr;                     // IP address withou port number used to identfy players in beacon code

//R6CODE
var BOOL m_bRadarActive;
var BOOL m_bHeatVisionActive;

var actor m_SaveOldClientBase;

var R6GameMenuCom.ePlayerTeamSelection	m_TeamSelection;
var BOOL m_bLoadSoundGun;
//end r6code

//R6CODE
// Variable used to keep track of user cd key validation

//#ifdef R6PUNKBUSTER
//__WITH_PB__
var int              iPBEnabled ;
//#endif //R6PUNKBUSTER

var BOOL             m_bInstructionTouch;   // Use in the traning to start the text.

//var travel string    m_szUbiUserID;
//end r6code

// r6code
var enum eCameraMode
{
	CAMERA_FirstPerson,
	CAMERA_3rdPersonFixed,
	CAMERA_3rdPersonFree,
	CAMERA_Ghost
} m_eCameraMode;
// end r6code

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
		ViewTarget, GameReplicationInfo,bOnlySpectator, /* r6code */ m_eCameraMode, m_TeamSelection;  /* end r6code */
	unreliable if ( bNetOwner && Role==ROLE_Authority && (ViewTarget != Pawn) && (Pawn(ViewTarget) != None) )
		TargetViewRotation, TargetEyeHeight, TargetWeaponViewOffset;
	reliable if( bDemoRecording && Role==ROLE_Authority )
		DemoViewPitch, DemoViewYaw;

	reliable if( bNetDirty && (Role==ROLE_Authority) )
		m_bRadarActive;
	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ClientSetHUD,ClientReliablePlaySound, /*R6CODE FOV, */StartZoom, 
		ToggleZoom, StopZoom, EndZoom, ClientSetMusic, ClientRestart,
		ClientReplicateSkins, ClientAdjustGlow, 
		ClientSetBehindView, ClientSetFixedCamera,
		SetProgressTime,
		GivePawn, ClientGotoState,ClientAdjustBase,
        ResettingLevel, ClientErrorMessageLocalized, 
        ClientChangeName, ClientCantRequestChangeNameYet,ClientPBKickedOutMessage; // R6CODE

	reliable if ( (Role == ROLE_Authority) && (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) )
		ClientMessage, TeamMessage, ReceiveLocalizedMessage;
	unreliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientPlaySound, ClientStopSound;
	reliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientTravel;
	unreliable if( Role==ROLE_Authority )
		SetFOVAngle, ClientShake, ClientFlash, ClientInstantFlash, ClientSetFlash, 
		ClientAdjustPosition, ShortClientAdjustPosition, VeryShortClientAdjustPosition, LongClientAdjustPosition;
	unreliable if( (!bDemoRecording || bClientDemoRecording && bClientDemoNetFunc) && Role==ROLE_Authority )
		ClientHearSound;

	// Functions client can call.
	unreliable if( Role<ROLE_Authority )
		ShorterServerMove, ShortServerMove, ServerMove, Say, TeamSay, ServerViewNextPlayer, ServerViewSelf,
        ServerTKPopUpDone;
    reliable if( Role<ROLE_Authority )
		Pause, SetPause, ServerPlayerPref,ServerTeamRequested,
		ServerReStartGame, AskForPawn, ServerToggleRadar, ServerToggleHeatVision,
		ChangeName, Suicide, Typing, ServerSetPlayerReadyStatus, ServerReadyToLoadWeaponSound,
        ServerChangeName; // R6CODE
    //@@@DEBUG BehindView; 
}

//#ifdef R6CODE clauzon those functions are called to properly  initialize the 
//member variables for matinee.
function InitMatineeCamera();
function EndMatineeCamera();
//#endif

// R6CODE
simulated function ResettingLevel(int iNbOfRestart);
function ServerSetPlayerReadyStatus(BOOL _bPlayerReady);
function ServerTKPopUpDone(BOOL _bApplyTeamKillerPenalty);
function ServerTeamRequested(ePlayerTeamSelection eTeamSelected, optional bool bForceSelection);
// END R6CODE


//#ifdef R6PUNKBUSTER
//__WITH_PB__
native (1317) final function string GetPBConnectStatus();
native (1318) static final function int IsPBEnabled();
//#endif //R6PUNKBUSTER

native final function string GetPlayerNetworkAddress();
native (1282) final function SpecialDestroy();
native function string ConsoleCommand( string Command );
native final function LevelInfo GetEntryLevel();
native(544) final function ResetKeyboard();
native final function SetViewTarget(Actor NewViewTarget);
native event ClientTravel( string URL, ETravelType TravelType, bool bItems );
native(546) final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);
native final function string GetDefaultURL(string Option);
// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native function CopyToClipboard( string Text );
native function string PasteFromClipboard();
simulated event BOOL IsPlayerPassiveSpectator();

/* FindStairRotation()
returns an integer to use as a pitch to orient player view along current ground (flat, up, or down)
*/
native(524) final function int FindStairRotation(float DeltaTime);

//#ifdef R6CODE 
function ServerReadyToLoadWeaponSound();
function ServerPlayerPref(PlayerPrefInfo newPlayerPrefs);
event SetMatchResult(string _UserUbiID, INT iField, INT iValue);
event string GetLocalPlayerIp();

native(2706) final function BYTE GetKey(string szActionKey, optional BOOL bPlanningInput);
native(2707) final function string GetActionKey(BYTE Key, optional BOOL bPlanningInput);
native(2708) final function string GetEnumName(BYTE Key, optional BOOL bPlanningInput);
native(2709) final function ChangeInputSet(BYTE iInputSet);
native(2710) final function SetKey(string szKeyAndAction);
native(2713) final function SetSoundOptions();
native(2714) final function ChangeVolumeTypeLinear(ESoundSlot eVolumeLine, FLOAT fVolumeLinear);
//#ifdef R6PUNKBUSTER
native(1320) final function bool PB_CanPlayerSpawn();
//#endif R6PUNKBUSTER

//endif R6CODE

native event ClientHearSound(Actor Actor, Sound S, ESoundSlot Id);

/*
native event ClientHearSound ( 
	actor Actor, 
	int Id, 
	sound S, 
	vector SoundLocation, 
	vector Parameters,
	bool Attenuate
);
*/

// r6code
function bool ShouldDisplayIncomingMessages()
{
    return true;
}

// r6code: give access to the private var PlayerInput
simulated function PlayerInput getPlayerInput()
{
    return PlayerInput;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SpawnDefaultHUD();
	if (Level.LevelEnterText != "" )
		ClientMessage(Level.LevelEnterText);

	DesiredFOV = DefaultFOV;
	SetViewTarget(self);  // MUST have a view target!
	if ( Level.NetMode == NM_Standalone )
		AddCheats();
}

function PendingStasis()
{
	bStasis = true;
	Pawn = None;
	GotoState('Scripting');
}

function AddCheats()
{
    //R6CODE don't spawn cheat managers in entry
    if(Level.bKNoInit)
        return;

	if ( CheatManager == None )
		CheatManager = new CheatClass;
}

/* SpawnDefaultHUD()
Spawn a HUD (make sure that PlayerController always has valid HUD, even if \
ClientSetHUD() hasn't been called\
*/
function SpawnDefaultHUD()
{
	myHUD = spawn(class'HUD',self);
}
	
/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	PawnDied();
	Super.Reset();
	SetViewTarget(self);
	bBehindView = false;
	WaitDelay = Level.TimeSeconds + 2;
	GotoState('BaseSpectating'); //	GotoState('PlayerWaiting');
}

/* InitInputSystem()
Spawn the appropriate class of PlayerInput
Only called for playercontrollers that belong to local players
*/


//R6CODE
event InitMultiPlayerOptions();
//R6CODE END

event InitInputSystem()
{
	PlayerInput = new InputClass;
//#ifdef R6CODE
	UpdateOptions();
}

function UpdateOptions()
{
	PlayerInput.UpdateMouseOptions();
}
//#endif

/* ClientGotoState()
server uses this to force client into NewState
*/
function ClientGotoState(name NewState, name NewLabel)
{
	GotoState(NewState,NewLabel);	
}

function AskForPawn()
{
	if ( Pawn != None )
		GivePawn(Pawn);
	else if ( IsInState('GameEnded') )
		ClientGotoState('GameEnded', 'Begin');
	else if ( IsInState('Dead') )
	{
		bFrozen = false;
		ServerRestartPlayer();
	}		
}	

function GivePawn(Pawn NewPawn)
{
	if ( NewPawn == None )
		return;
	Pawn = NewPawn;
	NewPawn.Controller = self;
	ClientRestart();
}	

/* GetFacingDirection()
returns direction faced relative to movement dir
0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
	local vector X,Y,Z, Dir;

	GetAxes(Pawn.Rotation, X,Y,Z);
	Dir = Normal(Pawn.Acceleration);
	if ( Y Dot Dir > 0 )
		return ( 49152 + 16384 * (X Dot Dir) );
	else
		return ( 16384 - 16384 * (X Dot Dir) );
}

// Possess a pawn
function Possess(Pawn aPawn)
{
	if ( bOnlySpectator )
		return;

	SetRotation(aPawn.Rotation);
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	Pawn.bStasis = false;
	if(PlayerReplicationInfo != none)	//R6CODE
		PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
//#ifndef R6CODE
//	ServerSetHandedness(Handedness);
//#endif // #ifndef R6CODE
	Restart();
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		Pawn.UnPossessed();
		if ( Viewtarget == Pawn )
			SetViewTarget(self);
	}
    Pawn.Controller = none;
	Pawn = none;
	GotoState('Spectating');
}

//#ifdef R6CODE
function bool GetGender();
//#endif

// unpossessed a pawn (because pawn was killed)
function PawnDied()
{
	EndZoom();
	if ( Pawn != None )
		Pawn.RemoteRole = ROLE_SimulatedProxy;
	if ( ViewTarget == Pawn )
		bBehindView = true;

	Super.PawnDied();
}

function ClientSetHUD(class<HUD> newHUDType, class<Scoreboard> newScoringType)
{
	local HUD NewHUD;
//#ifdef R6CODE
    local HUD OldHUD;

    // don't spawn huds in entry
    if(Level.bKNoInit)
        return;
//#endif // #ifdef R6CODE

	if ( (myHUD == None) || ((newHUDType != None) && (newHUDType != myHUD.Class)) )
	{
		NewHUD = spawn(newHUDType, self); 
		if ( NewHUD != None )
		{
//#ifndef R6CODE
//			if ( myHUD != None )
//				myHUD.Destroy();
//			myHUD = NewHUD;
//#else
            OldHUD = myHUD;
			myHUD = NewHUD;
			if ( OldHUD != None )
				OldHUD.Destroy();
//#endif // #ifdef R6CODE
		}
	}
//#ifndef R6CODE
//	if ( (myHUD != None) && (newScoringType != None) )
//		MyHUD.SpawnScoreBoard(newScoringType);
//#endif // #ifdef R6CODE
}

/*R6CHANGEWEAPONSYSTEM
function HandlePickup(Pickup pick)
{
	ReceiveLocalizedMessage( pick.MessageClass, 0, None, None, pick.Class );
}
*/	
function ViewFlash(float DeltaTime)
{
	local vector goalFog;
	local float goalscale, delta;

	delta = FMin(0.1, DeltaTime);
	goalScale = 1 + DesiredFlashScale + ConstantGlowScale;
	goalFog = DesiredFlashFog + ConstantGlowFog;

	if ( Pawn != None )
	{
		goalScale += Pawn.HeadVolume.ViewFlash.X; 
		goalFog += Pawn.HeadVolume.ViewFog;
	}

	DesiredFlashScale -= DesiredFlashScale * 2 * delta;  
	DesiredFlashFog -= DesiredFlashFog * 2 * delta;
	FlashScale.X += (goalScale - FlashScale.X + InstantFlash) * 10 * delta;
	FlashFog += (goalFog - FlashFog + InstantFog) * 10 * delta;
	InstantFlash = 0;
	InstantFog = vect(0,0,0);

	if ( FlashScale.X > 0.981 )
		FlashScale.X = 1;
	FlashScale = FlashScale.X * vect(1,1,1);

	if ( FlashFog.X < 0.019 )
		FlashFog.X = 0;
	if ( FlashFog.Y < 0.019 )
		FlashFog.Y = 0;
	if ( FlashFog.Z < 0.019 )
		FlashFog.Z = 0;
}

event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

//R6CODE+
function ClientErrorMessageLocalized( coerce string szKeyID )
{
    myHUD.AddTextMessage(Localize( "Errors", szKeyID, "R6Engine" ), class'LocalMessage');
}
//R6CODE-

event ClientMessage( coerce string S, optional Name Type )
{
	if (Type == '')
		Type = 'Event';
	TeamMessage(PlayerReplicationInfo, S, Type);
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type  )
{
//#ifndef R6CODE
//    myHUD.Message( PRI, S, Type );  // Message will be sent to the HUD by the InteractionMaster
//#endif // #ifndef R6CODE

	if ( (Type == 'Say') || (Type == 'TeamSay') )
		S = PRI.PlayerName$": "$S;

//	Player.Console.Message( S, 6.0 );
	Player.InteractionMaster.Process_Message( S,6.0, Player.LocalInteractions);
}

simulated function PlayBeepSound();

//Play a sound client side (so only client will hear it

//R6CODE
simulated function ClientPlaySound(sound ASound, ESoundSlot eSlot )
{	
	if (Pawn != None)
		Pawn.PlaySound(ASound, eSlot);
	else
		ViewTarget.PlaySound(ASound, eSlot);  
}

simulated function ClientStopSound(sound ASound)
{	
	if (Pawn != None)
		Pawn.StopSound(ASound);
	else
		ViewTarget.StopSound(ASound);  
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bVolumeControl )
{
	ClientPlaySound(ASound, SLOT_SFX);
}
//R6CODE end

simulated event Destroyed()
{
	local SavedMove Next;

//#ifdef R6CODE	
	if( bOnlySpectator )
		Pawn = none;
//#endif
	if ( Pawn != None )
	{
		Pawn.Health = 0;
		Pawn.Died( self, Pawn.Location );
    }

    //#ifdef R6BUGFIX
    // Remove CheatManager and PlayerInput reference to be sure they are garbage collected
    if(CheatManager!=none)
        CheatManager.ClearOuter();
    CheatManager = none;

    if(PlayerInput!=none)
        PlayerInput.ClearOuter();
    PlayerInput = none;
    //#endif // #ifdef R6BUGFIX

	Super.Destroyed();
	myHud.Destroy();
    myHud = none; // R6CODE

	while ( FreeMoves != None )
	{
		Next = FreeMoves.NextMove;
		FreeMoves.Destroy();
		FreeMoves = Next;
	}
	while ( SavedMoves != None )
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
		SavedMoves = Next;
	}
}

function ClientSetMusic( string NewSong, EMusicTransition NewTransition )
{
// #ifndef R6SOUND
//	StopAllMusic( 0.0 );
//  PlayMusic( NewSong, 3.0 );
// #endif R6SOUND

	Song        = NewSong;
	Transition  = NewTransition;
}
	
// ------------------------------------------------------------------------
// Zooming/FOV change functions

function ToggleZoom()
{
	if ( DefaultFOV != DesiredFOV )
		EndZoom();
	else
		StartZoom();
}
	
function StartZoom()
{
	ZoomLevel = 0.0;
	bZooming = true;
}

function StopZoom()
{
	bZooming = false;
}

function EndZoom()
{
	bZooming = false;
	DesiredFOV = DefaultFOV;
}

function FixFOV()
{
	FOVAngle = Default.DefaultFOV;
	DesiredFOV = Default.DefaultFOV;
	DefaultFOV = Default.DefaultFOV;
}

function SetFOV(float NewFOV)
{
	DesiredFOV = NewFOV;
	FOVAngle = NewFOV;
}

function ResetFOV()
{
	DesiredFOV = DefaultFOV;
	FOVAngle = DefaultFOV;
}

/*R6CODE
exec function FOV(float F)
{
	if( (F >= 80.0) || (Level.Netmode==NM_Standalone) )
	{
		DefaultFOV = FClamp(F, 1, 170);
		DesiredFOV = DefaultFOV;
		SaveConfig();
	}
}
*/

exec function SetSensitivity(float F)
{
	PlayerInput.UpdateSensitivity(F);
}

#ifdefDEBUG
exec function ForceReload()
{
/*R6CHANGEWEAPONSYSTEM
	if ( (Pawn != None) && (Pawn.Weapon != None) )
		Pawn.Weapon.ForceReload();
*/
}
#endif

// ------------------------------------------------------------------------
// Messaging functions

// Send a message to all players.
exec function Say( string Msg )
{
    //R6CODE
    if(Msg == "" || Level.NetMode == NM_Standalone)
        return;
    
	Level.Game.Broadcast(self, Msg, 'Say');
}

exec function TeamSay( string Msg )
{
    //R6CODE
    if(Msg == "" || Level.NetMode == NM_Standalone)
        return;

	Level.Game.BroadcastTeam(self, Msg, 'TeamSay');
}
// ------------------------------------------------------------------------

//#ifndef R6CODE
//function ServerSetHandedness( float hand)
//{
//	Handedness = hand;
//	if ( Pawn.Weapon != None )
//	Pawn.Weapon.SetHand(Handedness);
//}

//function SetHand()
//{
//	ServerSetHandedness(Handedness);
//}

//function ChangeSetHand( string S )
//{
//	if ( S ~= "Left" )
//		Handedness = -1;
//	else if ( S~= "Right" )
//		Handedness = 1;
//	else if ( S ~= "Center" )
//		Handedness = 0;
//	else if ( S ~= "Hidden" )
//		Handedness = 2;
//	SetHand();
//}
//#endif // #ifndef R6CODE

event PreClientTravel()
{
}

function ClientSetFixedCamera(bool B)
{
	bFixedCamera = B;
}

function ClientSetBehindView(bool B)
{
	bBehindView = B;
}

function ClientReplicateSkins(Material Skin1, optional Material Skin2, optional Material Skin3, optional Material Skin4)
{
	// do nothing (just loading other player skins onto client)
	log("Getting "$Skin1$", "$Skin2$", "$Skin3$", "$Skin4);
	return;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	if ( (Sender == None) || (Sender.voicetype == None) || (Player.Console == None) )
		return;
		
	V = Spawn(Sender.voicetype, self);
	if ( V != None )
		V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

/* ForceDeathUpdate()
Make sure ClientAdjustPosition immediately informs client of pawn's death
*/
function ForceDeathUpdate()
{
	LastUpdateTime = Level.TimeSeconds - 10;
}

/* ShorterServerMove()
compressed version of server move for bandwidth saving
*/
function ShorterServerMove
(
	float TimeStamp, 
	vector ClientLoc,
	int View,
// #ifdef R6PlayerMovements
    int iNewRotOffset
// #endif R6PlayerMovements
)
{
	ServerMove(TimeStamp,vect(0,0,0),ClientLoc,false,false,false,View,
// #ifdef R6PlayerMovements
    iNewRotOffset
// #endif R6PlayerMovements
        );
}

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
function ShortServerMove
(
	float TimeStamp, 
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
//#ifdef R6CODE
	bool NewbCrawl, 
//#else
//#endif R6CODE
	int View,
// #ifdef R6PlayerMovements
    int iNewRotOffset
// #endif R6PlayerMovements
)
{
	ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewbRun,NewbDuck,NewbCrawl,View,
// #ifdef R6PlayerMovements
    iNewRotOffset
// #endif R6PlayerMovements
        );
}

/* ServerMove() 
- replicated function sent by client to server - contains client movement and firing info
Passes acceleration in components so it doesn't get rounded.
*/
function ServerMove
(
	float TimeStamp, 
	vector InAccel, 
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
// #ifdef R6PlayerMovements
	bool NewbCrawl, 
// #endif R6PlayerMovements
//	eDoubleClickDir DoubleClickMove, 
//	byte ClientRoll, 
	int View,
// #ifdef R6PlayerMovements
    int iNewRotOffset,
// #endif R6PlayerMovements
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot, ViewRot;
	local vector Accel, LocDiff, ClientVel, ClientFloor;
// #ifdef R6PlayerMovements
    local rotator rNewRotOffset;
// #endif R6PlayerMovements
	local int maxPitch, ViewPitch, ViewYaw;
	local bool OldbCrawl, OldbRun, OldbDuck; //rb NewbPressedJump
	local eDoubleClickDir OldDoubleClickMove;
	local actor ClientBase;
	local ePhysics ClientPhysics;


	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (  OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);

			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);

			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;


			OldbRun = ( (OldAccel & 64) != 0 );
			OldbDuck = ( (OldAccel & 32) != 0 );
			OldbCrawl = ( (OldAccel & 16) != 0 );
		//rb	NewbPressedJump = ( (OldAccel & 16) != 0 );
		//rb	if ( NewbPressedJump )
		//rb		bJumpStatus = NewbJumpStatus;

//			switch (OldAccel & 7)
//			{
//				case 0:
					OldDoubleClickMove = DCLICK_None;
//					break;
//				case 1:
//					OldDoubleClickMove = DCLICK_Left;
//					break;
//				case 2:
//					OldDoubleClickMove = DCLICK_Right;
//					break;
//				case 3:
//					OldDoubleClickMove = DCLICK_Forward;
//					break;
//				case 4:
//					OldDoubleClickMove = DCLICK_Back;
//					break;
//			}
			//log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
			MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, OldbCrawl, OldDoubleClickMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	//rb NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	//rb bJumpStatus = NewbJumpStatus;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	ViewRot.Pitch = ViewPitch;
	ViewRot.Yaw = ViewYaw;
	ViewRot.Roll = 0;
	SetRotation(ViewRot);

	if ( Pawn != None )
	{
        //R6CODE
        rNewRotOffset.Pitch =  2 * (iNewRotOffset/32768);
        rNewRotOffset.Yaw = 2 * (32767 & iNewRotOffset);
        pawn.m_rRotationOffset = rNewRotOffset;
    
		Rot.Roll = 0;//256 * ClientRoll;
		Rot.Yaw = ViewYaw;
		if ( (Pawn.Physics == PHYS_Swimming) || (Pawn.Physics == PHYS_Flying) )
			maxPitch = 2;
		else
			maxPitch = 1;
		If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
		{
			If (ViewPitch < 32768) 
				Rot.Pitch = maxPitch * RotationRate.Pitch;
			else
				Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
		}
		else
			Rot.Pitch = ViewPitch;
		DeltaRot = (Rotation - Rot);
		Pawn.SetRotation(Rot);
	}

	// Perform actual movement.
	if ( (Level.Pauser == None) && (DeltaTime > 0) )
    {
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbCrawl, DCLICK_None, Accel, DeltaRot);
	}
	
	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		if ( Pawn == None )
			LocDiff = Location - ClientLoc;
		else
			LocDiff = Pawn.Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
    if ( ClientErr > 3 )
	{
		if ( Pawn == None )
		{
			ClientPhysics = Physics;
			ClientLoc = Location;
			ClientVel = Velocity;
		}
		else
		{
			ClientPhysics = Pawn.Physics;
			ClientVel = Pawn.Velocity;
			ClientBase = Pawn.Base;
			if ( Mover(Pawn.Base) != None )
				ClientLoc = Pawn.Location - Pawn.Base.Location;
			else
				ClientLoc = Pawn.Location;
			ClientFloor = Pawn.Floor;
		}
		//log("Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
		LastUpdateTime = Level.TimeSeconds;

        if (m_SaveOldClientBase!=ClientBase)
        {
            m_SaveOldClientBase=ClientBase;
            ClientAdjustBase(ClientBase);
        }

		if ( (Pawn == None) || (Pawn.Physics != PHYS_Spider) )
		{
			if ( ClientVel == vect(0,0,0) )
			{
				if ( IsInState('PlayerWalking') && (Pawn != None) && (Pawn.Physics == PHYS_Walking) )
				{					
					VeryShortClientAdjustPosition
					(
						TimeStamp,
						ClientLoc.X,
						ClientLoc.Y,
						ClientLoc.Z,
						ClientBase
					);
				}
				else
					ShortClientAdjustPosition
					(
						TimeStamp,
						GetStateName(),
						ClientPhysics,
						ClientLoc.X,
						ClientLoc.Y,
						ClientLoc.Z,
						ClientBase
					);
			}
			else
				ClientAdjustPosition
				(
					TimeStamp, 
					GetStateName(), 
					ClientPhysics, 
					ClientLoc.X, 
					ClientLoc.Y, 
					ClientLoc.Z, 
					ClientVel.X, 
					ClientVel.Y,
					ClientVel.Z,
					ClientBase
				);
		}
		else
			LongClientAdjustPosition
			(
				TimeStamp, 
				GetStateName(), 
				ClientPhysics, 
				ClientLoc.X, 
				ClientLoc.Y, 
				ClientLoc.Z, 
				ClientVel.X, 
				ClientVel.Y, 
				ClientVel.Z,
				ClientBase,
				ClientFloor.X,
				ClientFloor.Y,
				ClientFloor.Z
			);
	}
	//log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity);
}	

function ProcessMove ( float DeltaTime, vector newAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
{
	if ( Pawn != None )
		Pawn.Acceleration = newAccel;
}

final function MoveAutonomous
(	
	float DeltaTime, 	
	bool NewbRun,
	bool NewbDuck,
	bool NewbCrawl, 
	eDoubleClickDir DoubleClickMove, 
	vector newAccel, 
	rotator DeltaRot
)
{
	if ( NewbRun )
		bRun = 1;
	else
		bRun = 0;

//#ifdefR6CODE
	if( Level.NetMode != NM_Client )
	{
//#endif
		if ( NewbDuck )
			bDuck = 1;
		else
			bDuck = 0;

		if ( NewbCrawl )
			m_bCrawl = true;
		else
			m_bCrawl = false;
//#ifdefR6CODE
	}
//#endif

	HandleWalking();
	ProcessMove(DeltaTime, newAccel, DoubleClickMove, DeltaRot);
	if ( Pawn != None )	
		Pawn.AutonomousPhysics(DeltaTime);
	else
		AutonomousPhysics(DeltaTime);
// #ifdef R6PlayerMovements
    if (pawn!=none)
    {
        pawn.m_vEyeLocation = pawn.GetBoneCoords('R6 PonyTail1').Origin;
    }
// #endif R6PlayerMovements

	//log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

/* VeryShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed, and pawn is walking
*/
function VeryShortClientAdjustPosition
(
	float TimeStamp, 
	float NewLocX, 
	float NewLocY,
	float NewLocZ,
	Actor NewBase
)
{
	local vector Floor;

    if ( Pawn != None )
        Floor = Pawn.Floor;
	
    // #ifdef R6CODE
    // rbrek 17 feb 2002 - added a safe guard, somehow the server invokes this function call on a client whose pawn is not in PHYS_Walking...
    //					   (i.e. when player is trying to get on ladder and is in PHYS_RootMotion -	this should never happen???  TOFIX)
    if ((pawn!=none)&&(pawn.physics != PHYS_Walking)&&(pawn.physics != PHYS_None))
        return;
    // #endif

    LongClientAdjustPosition(TimeStamp,'PlayerWalking',PHYS_Walking,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,
        Floor.X,Floor.Y,Floor.Z);
}

/* ShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed
*/
function ShortClientAdjustPosition
(
	float TimeStamp, 
	name newState, 
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,
        Floor.X,Floor.Y,Floor.Z);
}

/* ClientAdjustPosition
- pass newloc and newvel in components so they don't get rounded
*/
function ClientAdjustPosition
(
	float TimeStamp, 
	name newState, 
	EPhysics newPhysics,
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	float NewVelX, 
	float NewVelY,
	float NewVelZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,NewVelX,NewVelY,NewVelZ,NewBase,
        Floor.X,Floor.Y,Floor.Z);
}

/* LongClientAdjustPosition 
long version, when care about pawn's floor normal
*/
function LongClientAdjustPosition
(
	float TimeStamp, 
	name newState, 
	EPhysics newPhysics,
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ,
	Actor NewBase,
	float NewFloorX,
	float NewFloorY,
	float NewFloorZ
)

{
	local vector NewLocation, NewFloor;
	local Actor MoveActor;

	if ( Pawn != None )
	{
        if (!bNetOwner)
        {
            pawn.m_vEyeLocation = pawn.GetBoneCoords('R6 PonyTail1').Origin;
        }
		if ( Pawn.bTearOff || Pawn.m_bUseRagdoll )
		{
			//Pawn = None;
			GotoState('Dead');
			return;
		}
		MoveActor = Pawn;
	}
	else 
		MoveActor = self;

	if ( CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
	MoveActor.Velocity.X = NewVelX;
	MoveActor.Velocity.Y = NewVelY;
	MoveActor.Velocity.Z = NewVelZ;

	NewFloor.X = NewFloorX;
	NewFloor.Y = NewFloorY;
	NewFloor.Z = NewFloorZ;
	MoveActor.SetBase(NewBase, NewFloor);
	if ( Mover(NewBase) != None )
		NewLocation += NewBase.Location;

    if(NewLocation != MoveActor.Location)   // R6CODE {}
    {
        //log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$MoveActor.Location);
        MoveActor.bCanTeleport = false;
        
        MoveActor.SetLocation(NewLocation);
        MoveActor.bCanTeleport = true;
    }                                       // R6CODE {}
    if(newPhysics != MoveActor.Physics)     // R6CODE {}
    {
        // Never change physics for Karma from network, always do this localy
        if(newPhysics != PHYS_KarmaRagDoll && MoveActor.Physics != PHYS_KarmaRagDoll)
            MoveActor.SetPhysics(newPhysics);
    }                                       // R6CODE {}

	if( GetStateName() != newstate )
		GotoState(newstate);

	bUpdatePosition = true;
}

function ClientAdjustBase(actor newClientBase)
{
	local Actor MoveActor;

	if ( Pawn != None )
		MoveActor = Pawn;
	else 
		MoveActor = self;

    // the floor should be okay
	MoveActor.SetBase(newClientBase);
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool realbCrawl; 
//#ifndef R6CODE 
//	local bool bRealJump;
//#endif
	local float TotalTime;
 
	bUpdatePosition = false;
	realbRun= bRun;
	realbDuck = bDuck;
	realbCrawl = m_bCrawl;
//#ifndef R6CODE 
//	bRealJump = bPressedJump;
//#endif
	CurrentMove = SavedMoves;
	bUpdating = true;
	
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
//			if ( (TotalTime > 0) && (Pawn != None) )
//				AdjustRadius(CurrentMove.Delta * Pawn.GroundSpeed);
			TotalTime += CurrentMove.Delta;
            MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.m_bCrawl, 
                CurrentMove.DoubleClickMove, CurrentMove.Acceleration, rot(0,0,0));
			CurrentMove = CurrentMove.NextMove;
		}
	}
	//log("Client updated position to "$Pawn.Location);
	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	m_bCrawl = realbCrawl;
//#ifndef R6CODE 
//	bPressedJump = bRealJump;
//#endif
}

function AdjustRadius(float MaxMove)
{
	local Pawn P;
	local vector Dir;

	// if other pawn moving away from player, push it away if its close
	// since the client-side position is behind the server side position
	ForEach DynamicActors(class'Pawn', P)
		if ( (P != Pawn) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
		{
			Dir = Normal(P.Location - Pawn.Location);
			if ( (Pawn.Velocity Dot Dir > 0) && (P.Velocity Dot Dir > 0) )
			{
				if ( VSize(P.Location - Pawn.Location) < P.CollisionRadius + Pawn.CollisionRadius + MaxMove )
					P.MoveSmooth(P.Velocity * 0.5 * PlayerReplicationInfo.Ping);
			}
		} 
}

final function SavedMove GetFreeMove()
{
	local SavedMove s, first;
	local int i;

	if ( FreeMoves == None )
	{
		// don't allow more than 30 saved moves
		For ( s=SavedMoves; s!=None; s=s.NextMove )
		{
			i++;
			if ( i > 30 )
			{
				first = SavedMoves;
				SavedMoves = SavedMoves.NextMove;
				first.Clear();
				first.NextMove = None;
				// clear out all the moves
				While ( SavedMoves != None )
				{
					s = SavedMoves;
					SavedMoves = SavedMoves.NextMove;
					s.Clear();
					s.NextMove = FreeMoves;
					FreeMoves = s;
				}
				return first;
			}
		}
		return Spawn(class'SavedMove');
	}
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}	
}

function int CompressAccel(int C)
{
	if ( C >= 0 )
		C = Min(C, 127);
	else
		C = Min(abs(C), 127) + 128;
	return C;
}

/* 
========================================================================
Here's how player movement prediction, replication and correction works in network games:

Every tick, the PlayerTick() function is called.  It calls the PlayerMove() function (which is implemented 
in various states).  PlayerMove() figures out the acceleration and rotation, and then calls ProcessMove() 
(for single player or listen servers), or ReplicateMove() (if its a network client).

ReplicateMove() saves the move (in the PendingMove list), calls ProcessMove(), and then replicates the move 
to the server by calling the replicated function ServerMove() - passing the movement parameters, the client's 
resultant position, and a timestamp.

ServerMove() is executed on the server.  It decodes the movement parameters and causes the appropriate movement 
to occur.  It then looks at the resulting position and if enough time has passed since the last response, or the 
position error is significant enough, the server calls ClientAdjustPosition(), a replicated function.

ClientAdjustPosition() is executed on the client.  The client sets its position to the servers version of position, 
and sets the bUpdatePosition flag to true.  

When PlayerTick() is called on the client again, if bUpdatePosition is true, the client will call 
ClientUpdatePosition() before calling PlayerMove().  ClientUpdatePosition() replays all the moves in the pending 
move list which occured after the timestamp of the move the server was adjusting.
*/

//
// Replicate this client's desired movement to the server.
//
function ReplicateMove
(
	float DeltaTime, 
	vector NewAccel, 
	eDoubleClickDir DoubleClickMove, 
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
//	local byte ClientRoll;
	local float OldTimeDelta, NetMoveDelta;
	local int i, OldAccel;
	local vector BuildAccel, AccelNorm, MoveLoc;
    local rotator rSendRot;

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
    {
        PendingMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);//, MoveEyeLoc);
    }

	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( /* //rb NewMove.bPressedJump ||*/ ((NewMove.DoubleClickMove != DCLICK_NONE) && (NewMove.DoubleClickMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) 
                )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( /* //rb NewMove.bPressedJump || */ ((NewMove.DoubleClickMove != DCLICK_NONE) && (NewMove.DoubleClickMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) 
            )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	if ( NewMove == None )
		return;
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);
	
	// adjust radius of nearby players with uncertain location
//	if ( Pawn != None )
//		AdjustRadius(NewMove.Delta * Pawn.GroundSpeed);

	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);
	if ( Pawn != None )
		Pawn.AutonomousPhysics(NewMove.Delta);
	else
		AutonomousPhysics(DeltaTime);

	//log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

	// Decide whether to hold off on move
	// send if double click move, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
    
    //UT2K3	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);
    NetMoveDelta = FMax(80.0/Player.CurrentNetSpeed, 0.015);
	
	if (/* //rb !PendingMove.bPressedJump && */ (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23) 
					+ (CompressAccel(BuildAccel.Y) << 15) 
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.m_bCrawl )	//rb if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DoubleClickMove;
	}
	//else
	//	log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);
	//log("Replicate move at "$NewMove.TimeStamp$" location "$Pawn.Location);
	// Send to the server
//	ClientRoll = (Rotation.Roll >> 8) & 255;
	
	//rb if ( NewMove.bPressedJump )
	//rb	bJumpStatus = !bJumpStatus;

	if ( Pawn == None )
    {
        MoveLoc = Location;
    }
	else
    {
        rSendRot = pawn.m_rRotationOffset;
        MoveLoc = Pawn.Location;
    }

    if (Level.TimeSeconds > m_fNextUpdateTime)
    {
        m_fNextUpdateTime = Level.TimeSeconds + (1/NetClientMaxTickRate);
    }
    else
    {
        return;
    }

	if ( (NewMove.Acceleration == vect(0,0,0)) && (NewMove.DoubleClickMove == DCLICK_None) )
    {
        if ((NewMove.bDuck==false) && (NewMove.bRun==false) && (NewMove.m_bCrawl==false))
        {
            ShorterServerMove
            (
			    NewMove.TimeStamp, 
			    MoveLoc, 
			    (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
// #ifdef R6PlayerMovements
			    (32767 & (rSendRot.Pitch/2)) * 32768 + (32767 & (rSendRot.Yaw/2))
// #endif R6PlayerMovements
            );
        }
        else
            ShortServerMove
		    (
			    NewMove.TimeStamp, 
			    MoveLoc, 
			    NewMove.bRun,
			    NewMove.bDuck,
			    NewMove.m_bCrawl,  //rb bJumpStatus, 
//   			ClientRoll,
			    (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
// #ifdef R6PlayerMovements
			    (32767 & (rSendRot.Pitch/2)) * 32768 + (32767 & (rSendRot.Yaw/2))
// #endif R6PlayerMovements
		);
    }
	else
		ServerMove
		(
			NewMove.TimeStamp, 
			NewMove.Acceleration * 10, 
			MoveLoc, 
			NewMove.bRun,
			NewMove.bDuck,
			NewMove.m_bCrawl,  //rb bJumpStatus, 
//			NewMove.DoubleClickMove, 
//			ClientRoll,
			(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
// #ifdef R6PlayerMovements
			(32767 & (rSendRot.Pitch/2)) * 32768 + (32767 & (rSendRot.Yaw/2)),
// #endif R6PlayerMovements
			OldTimeDelta,
			OldAccel
		);
}

function HandleWalking()
{
	if ( Pawn != None )
		Pawn.SetWalking(((bRun != 0) || (bDuck != 0)) && !Region.Zone.IsA('WarpZoneInfo')); 
}

function ServerRestartGame()
{
}

function SetFOVAngle(float newFOV)
{
	FOVAngle = newFOV;
}
	 
function ClientFlash( float scale, vector fog )
{
	DesiredFlashScale = scale;
	DesiredFlashFog = 0.001 * fog;
}

function ClientSetFlash(vector Scale, vector Fog)
{
	FlashScale=Scale;
	FlashFog=Fog;
}

function ClientInstantFlash( float scale, vector fog )
{
	InstantFlash = scale;
	InstantFog = 0.001 * fog;
}
   
function ClientAdjustGlow( float scale, vector fog )
{
	ConstantGlowScale += scale;
	ConstantGlowFog += 0.001 * fog;
}

/* ClientShake()
Function called on client to shake view.
Only ShakeView() should call ClientShake()
*/
private function ClientShake(vector ShakeRoll, vector OffsetMag, vector ShakeRate, float OffsetTime)
{
	if ( (MaxShakeRoll < ShakeRoll.X) || (ShakeRollTime < 0.01 * ShakeRoll.Y) )
	{
		MaxShakeRoll = ShakeRoll.X;
		ShakeRollTime = 0.01 * ShakeRoll.Y;	
		ShakeRollRate = 0.01 * ShakeRoll.Z;
	}
	if ( VSize(OffsetMag) > VSize(MaxShakeOffset) )
	{
		ShakeOffsetTime = OffsetTime * vect(1,1,1);
		MaxShakeOffset = OffsetMag;
		ShakeOffsetRate = ShakeRate;
	}
}


/* ShakeView()
Call this function to shake the player's view
shaketime = how long to roll view
RollMag = how far to roll view as it shakes
OffsetMag = max view offset
RollRate = how fast to roll view
OffsetRate = how fast to offset view
OffsetTime = how long to offset view (number of shakes)
*/
function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime)
{
	local vector ShakeRoll;

	ShakeRoll.X = RollMag;
	ShakeRoll.Y = 100 * shaketime;
	ShakeRoll.Z = 100 * rollrate;
	ClientShake(ShakeRoll, OffsetMag, OffsetRate, OffsetTime);
}

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
	if ( bTyping && (Pawn != None) && !Pawn.bTearOff )
		Pawn.ChangeAnimation();

	if (Level.Game.StatLog != None)
		Level.Game.StatLog.LogTypingEvent(bTyping, Self);
}


//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it
// R6CODE
exec function Bind(string szKeyAndCommand)
{

    local string szResult;
    local INT iPos;

    if (InPlanningMode() && !Level.m_bInGamePlanningActive)
        szResult = "INPUTPLANNING" @ szKeyAndCommand;
    else
        szResult = "INPUT" @ szKeyAndCommand;

    SetKey(szResult);

    // Only the console can be change at the same time in the inputplanning and the inputgame.
    iPos = InStr(szKeyAndCommand," ");
	szResult = Right(szKeyAndCommand, Len(szKeyAndCommand) - iPos - 1);
    if (szResult ~= "CONSOLE")
    {
        if (InPlanningMode() && !Level.m_bInGamePlanningActive)
            szResult = "INPUT" @ szKeyAndCommand;
        else
            szResult = "INPUTPLANNING" @ szKeyAndCommand;

        SetKey(szResult);
    }
}

exec function SetOption(string szKeyAndCommand)
{
    local string szResult;

    szResult = "R6GAMEOPTIONS" @ szKeyAndCommand;

    SetKey(szResult);
}
// R6CODE END

exec function Jump( optional float F )
{
/*@@@DEBUG	
	if ( Level.Pauser == PlayerReplicationInfo )
		SetPause(False);
	else
		bPressedJump = true;
@@@DEBUG */
}

/* R6CODE+
exec function LocalTravel( string URL )
{
	if( Level.Netmode==NM_Standalone )
		ClientTravel( URL, TRAVEL_Relative, true );
}
*/

// ------------------------------------------------------------------------
// Loading and saving

/* QuickSave()
Save game to slot 9
*/
/* R6CODE+
exec function QuickSave()
{
	if ( (Pawn.Health > 0) 
		&& (Level.NetMode == NM_Standalone) )
	{
		ClientMessage(QuickSaveString);
		ConsoleCommand("SaveGame 9");
	}
}
R6CODE- */

/* QuickLoad()
Load game from slot 9
*/
/* R6CODE+
exec function QuickLoad()
{
	if ( Level.NetMode == NM_Standalone )
		ClientTravel( "?load=9", TRAVEL_Absolute, false);
}
R6CODE-        */

/* SetPause()
 Try to pause game; returns success indicator.
 Replicated to server in network games.
 */
function bool SetPause( BOOL bPause )
{
	return Level.Game.SetPause(bPause, self);
}

//ifdefR6CODE
/* Pause()
Command to try to pause the game.
*/
exec function Pause()
{
#ifdefDEBUG
	if( !SetPause(Level.Pauser==None) )
        ClientMessage(NoPauseMessage);
#endif
}
//#endif R6CODE

/*R6CHANGEWEAPONSYSTEM
exec function GetWeapon(class<Weapon> NewWeaponClass )
{
	local Inventory Inv;

	if ( (Pawn.Inventory == None) || (NewWeaponClass == None)
		|| ((Pawn.Weapon != None) && (Pawn.Weapon.Class == NewWeaponClass)) )
		return;

	for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.Class == NewWeaponClass )
		{
			Pawn.PendingWeapon = Weapon(Inv);
			if ( !Pawn.PendingWeapon.HasAmmo() )
			{
				ClientMessage( Pawn.PendingWeapon.ItemName$Pawn.PendingWeapon.MessageNoAmmo );
				Pawn.PendingWeapon = None;
				return;
			}
			Pawn.Weapon.PutDown();
			return;
		}
}
*/

// The player wants to fire.
exec function Fire( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
/*R6CHANGEWEAPONSYSTEM
	if( Pawn.Weapon!=None )
		Pawn.Weapon.Fire(F);
*/	
//#ifndef R6CODE
//    if ( Pawn.EngineWeapon!=None )
//#else
	if( (Pawn != none) && (Pawn.EngineWeapon != none) && !GameReplicationInfo.m_bGameOverRep )
//#endif R6CODE
	{
		Pawn.EngineWeapon.Fire(F);
	}
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
/*R6CHANGEWEAPONSYSTEM
	if( Pawn.Weapon!=None )
		Pawn.Weapon.AltFire(F);
*/
	if( Pawn.EngineWeapon!=None )
	{
//        Pawn.PlayFiring();
		Pawn.EngineWeapon.AltFire(F);
	}
}



exec function Suicide()
{
//#ifndef R6CODE
//	Pawn.KilledBy( None );
//#endif // #ifndef R6CODE
}

// R6CODE+
event HandleServerMsg(string _szServerMsg, OPTIONAL int iLifeTime )
{
    myHUD.AddTextServerMessage(_szServerMsg, class'LocalMessage', iLifeTime );
}

function ClientCantRequestChangeNameYet()
{
    HandleServerMsg(Localize("Game", "CantRequestChangeNameYet", "R6GameInfo"));
}

simulated function ServerChangeName( string s )
{
    local int iChangeNameTime;

    iChangeNameTime = class'Actor'.static.GetGameOptions().ChangeNameTime;

    if ( m_iChangeNameLastTime == 0 ||
         Level.TimeSeconds > m_iChangeNameLastTime + iChangeNameTime ||
         Level.NetMode == NM_Standalone )
    {
        m_iChangeNameLastTime = Level.TimeSeconds;
        ClientChangeName( s );
    }
    else
    {
        ClientCantRequestChangeNameYet();
    }
}

simulated function ClientChangeName( string s )
{
    ChangeName(S);
 	if ( Len(S) > 15 )
		S = left(S,15);
    ReplaceText(S, " ", "_");
    ReplaceText(S, "~", "_");
    ReplaceText(S, "?", "_");
    ReplaceText(S, ",", "_");
    ReplaceText(S, "#", "_");
    ReplaceText(S, "/", "_");
    S = RemoveInvalidChars(S);
	UpdateURL("Name", S, true);
	SaveConfig();
	class'Actor'.static.GetGameOptions().CharacterName = S; // update game options name
	class'Actor'.static.GetGameOptions().SaveConfig();
}
// R6CODE-

exec function Name( coerce string S )
{
    // R6CODE
    ServerChangeName( S );

    /*     
	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
	class'Actor'.static.GetGameOptions().CharacterName = S; // update game options name
	class'Actor'.static.GetGameOptions().SaveConfig();
    */
}

exec function SetName( coerce string S)
{
    // R6CODE
    ServerChangeName( S );

    /*
	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
	class'Actor'.static.GetGameOptions().CharacterName = S; // update game options name
	class'Actor'.static.GetGameOptions().SaveConfig();
    */
}

simulated function ChangeName( coerce out string S )
{
 	if ( Len(S) > 15 )
		S = left(S,15);
	
    ReplaceText(S, " ", "_");
    // R6CODE
    ReplaceText(S, "~", "_");
    ReplaceText(S, "?", "_");
    ReplaceText(S, ",", "_");
    ReplaceText(S, "#", "_");
    ReplaceText(S, "/", "_");
    S = RemoveInvalidChars(S);

	if(Level.NetMode != NM_Standalone)
		Level.Game.ChangeName( self, S, false );
}

/*
exec function SwitchTeam()
{
	if ( (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 1) )
		ChangeTeam(0);
	else
		ChangeTeam(1);
}
*/

/* R6CODE
exec function SwitchLevel( string URL )
{
	if( Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
		Level.ServerTravel( URL, false );
}
*/
exec event SetProgressTime( float T )
{
	ProgressTimeOut = T + Level.TimeSeconds;
}

function Restart()
{
	Super.Restart();
	ServerTimeStamp = 0;
	TimeMargin = 0;
	EnterStartState();
	SetViewTarget(Pawn);
	bBehindView = Pawn.PointOfView();
	ClientRestart();
}

function EnterStartState()
{
	local name NewState;

	if ( Pawn.PhysicsVolume.bWaterVolume )
	{
		if ( Pawn.HeadVolume.bWaterVolume )
			Pawn.BreathTime = Pawn.UnderWaterTime;
		NewState = Pawn.WaterMovementState;
	}
	else  
    NewState = Pawn.LandMovementState;

	if ( IsInState(NewState) )
		BeginState();
	else
		GotoState(NewState);
}

function ClientRestart()
{
	if ( Pawn == None )
	{
		GotoState('WaitingForPawn');
		return;
	}
	Pawn.ClientRestart();
	SetViewTarget(Pawn);
	bBehindView = Pawn.PointOfView();
	EnterStartState();	
}

exec function BehindView( Bool B )
{
    // R6CODE
    if ( !CheatManager.CanExec() )
        return;

	bBehindView = B;
	ClientSetBehindView(bBehindView);
}

//=============================================================================
// functions.

event TravelPostAccept()
{
	if ( Pawn.Health <= 0 )
		Pawn.Health = Pawn.Default.Health;
}

event PlayerTick( float DeltaTime )
{
	PlayerInput.PlayerInput(DeltaTime);
	if ( bUpdatePosition )
		ClientUpdatePosition();

	PlayerMove(DeltaTime);
}

function PlayerMove(float DeltaTime);

//
/* AdjustAim()
Calls this version for player aiming help.
Aimerror not used in this version.
Only adjusts aiming at pawns
*/
/*R6CHANGEWEAPONSYSTEM
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local vector FireDir, AimSpot, HitNormal, HitLocation, OldAim, AimOffset;
	local actor BestTarget;
	local float bestAim, bestDist, projspeed;
	local actor HitActor;
	local bool bNoZAdjust, bLeading;
	local rotator AimRot;

	FireDir = vector(Rotation);
	if ( FiredAmmunition.bInstantHit )
		HitActor = Trace(HitLocation, HitNormal, projStart + 10000 * FireDir, projStart, true);
	else 
		HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
	if ( (HitActor != None) && HitActor.bProjTarget )
	{
		FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
		BestTarget = HitActor;
		bNoZAdjust = true;
		OldAim = HitLocation;
		BestDist = VSize(BestTarget.Location - Pawn.Location);
	}
	else
	{
		// adjust aim based on FOV
		bestAim = 0.95;
		if ( AimingHelp == 1 )
		{
			bestAim = 0.93;
			if ( FiredAmmunition.bInstantHit )
				bestAim = 0.97; 
			if ( FOVAngle < DefaultFOV - 8 )
				bestAim = 0.99;
		}
		else
		{
			if ( FiredAmmunition.bInstantHit )
				bestAim = 0.98; 
			if ( FOVAngle != DefaultFOV )
				bestAim = 0.995;
		}
		BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart);
		if ( BestTarget == None )
		{
			if (bBehindView)
				return Pawn.Rotation;
			else
			return Rotation;
		}
		FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
		OldAim = projStart + FireDir * bestDist;
	}
	if ( AimingHelp == 0 )
	{
		if (bBehindView)
			return Pawn.Rotation;
		else
		return Rotation;
	}

	// aim at target - help with leading also
	if ( !FiredAmmunition.bInstantHit )
	{
		projspeed = FiredAmmunition.ProjectileClass.default.speed;
		BestDist = vsize(BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart); 
		bLeading = true;
		FireDir = BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
		// if splash damage weapon, try aiming at feet - trace down to find floor
		if ( FiredAmmunition.bTrySplash 
			&& ((BestTarget.Velocity != vect(0,0,0)) || (BestDist > 1500)) )
		{
			HitActor = Trace(HitLocation, HitNormal, AimSpot - BestTarget.CollisionHeight * vect(0,0,2), AimSpot, false);
			if ( (HitActor != None)
				&& FastTrace(HitLocation + vect(0,0,4),projstart) )
				return rotator(HitLocation + vect(0,0,6) - projStart);
		}
	}
	else
	{
		FireDir = BestTarget.Location - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
	}
	AimOffset = AimSpot - OldAim;

	// adjust Z of shooter if necessary
	if ( bNoZAdjust || (bLeading && (Abs(AimOffset.Z) < BestTarget.CollisionHeight)) )
		AimSpot.Z = OldAim.Z;
	else if ( AimOffset.Z < 0 )
		AimSpot.Z = BestTarget.Location.Z + 0.4 * BestTarget.CollisionHeight;
	else
		AimSpot.Z = BestTarget.Location.Z - 0.7 * BestTarget.CollisionHeight;

	if ( !bLeading )
	{
		// if not leading, add slight random error ( significant at long distances )
		if ( !bNoZAdjust )
		{
			AimRot = rotator(AimSpot - projStart);
			if ( FOVAngle < DefaultFOV - 8 )
				AimRot.Yaw = AimRot.Yaw + 200 - Rand(400);
			else
				AimRot.Yaw = AimRot.Yaw + 375 - Rand(750);
			return AimRot;
		}	
	}
	else if ( !FastTrace(projStart + 0.9 * bestDist * Normal(FireDir), projStart) )
	{
		FireDir = BestTarget.Location - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
	}
		
	return rotator(AimSpot - projStart);
}
*/

function bool NotifyLanded(vector HitNormal)
{
	return bUpdating;
}

function eAttitude AttitudeTo(Pawn Other)
{
	if ( Other.Controller == None )
		return ATTITUDE_Ignore;	
	if ( Other.IsPlayerPawn() )
		return AttitudeToPlayer;
	return Other.Controller.AttitudeToPlayer;
}

//=============================================================================
// Player Control

// Player view.
// Compute the rendering viewpoint for the player.
//

function AdjustView(float DeltaTime )
{
	// teleporters affect your FOV, so adjust it back down
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
		else 
			FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if ( bZooming )
	{	
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	} 
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View; 
}

function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
	// First-person view.
	CameraRotation = Rotation;
	CameraLocation = CameraLocation + Pawn.EyePosition() + ShakeOffset;
}

event AddCameraEffect(CameraEffect NewEffect,optional bool RemoveExisting)
{
	if(RemoveExisting)
		RemoveCameraEffect(NewEffect);

	CameraEffects.Length = CameraEffects.Length + 1;
	CameraEffects[CameraEffects.Length - 1] = NewEffect;
}

event RemoveCameraEffect(CameraEffect ExEffect)
{
	local int	EffectIndex;

	for(EffectIndex = 0;EffectIndex < CameraEffects.Length;EffectIndex++)
		if(CameraEffects[EffectIndex] == ExEffect)
		{
			CameraEffects.Remove(EffectIndex,1);
			return;
		}
}

/* R6CODE
exec function CreateCameraEffect(class<CameraEffect> EffectClass)
{
	AddCameraEffect(new EffectClass);
}*/

function rotator GetViewRotation()
{
	if ( bBehindView && (Pawn != None) )
		return Pawn.Rotation;
	return Rotation;
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

	if ( (ViewTarget == None) || ViewTarget.bDeleteMe )
	{
		log("No VIEWTARGET in PlayerCalcView");
		if ( (Pawn != None) && !Pawn.bDeleteMe )
			SetViewTarget(Pawn);
		else
			SetViewTarget(self);
	}

	ViewActor = ViewTarget;
	CameraLocation = ViewTarget.Location;

	if ( ViewTarget == Pawn )
	{
		if( bBehindView ) //up and behind
			CalcBehindView(CameraLocation, CameraRotation, CameraDist * Pawn.Default.CollisionRadius);
		else
			CalcFirstPersonView( CameraLocation, CameraRotation );
		return;
	}
	if ( ViewTarget == self )
	{
		if ( bCameraPositionLocked )
			CameraRotation = CheatManager.LockedRotation;
		else
			CameraRotation = Rotation;
		return;
	}
//#ifdef R6CODE
	else if ( ViewTarget != none )
	{
		if( bBehindView ) //up and behind
			CalcBehindView( CameraLocation, CameraRotation, CameraDist * Pawn(ViewTarget).Default.CollisionRadius );
		else
			CalcFirstPersonView( CameraLocation, CameraRotation );
		return;
	}
//#endif

	CameraRotation = ViewTarget.Rotation;
	PTarget = Pawn(ViewTarget);
	if ( PTarget != None )
	{
		if ( Level.NetMode == NM_Client )
		{
			if ( PTarget.IsPlayerPawn() )
			{
				PTarget.SetViewRotation(TargetViewRotation);
				CameraRotation = TargetViewRotation;
			}
//R6CODE			PTarget.EyeHeight = TargetEyeHeight;
/*R6CHANGEWEAPONSYSTEM
			if ( PTarget.Weapon != None )
				PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
*/
		}
		else if ( PTarget.IsPlayerPawn() )
			CameraRotation = PTarget.GetViewRotation();
		if ( !bBehindView )
			CameraLocation += PTarget.EyePosition();
	}
	if ( bBehindView )
	{
		CameraLocation = CameraLocation + (ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0,0,1);
		CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
	}
}

function CheckShake(out float MaxOffset, out float Offset, out float Rate, out float Time)
{
	if ( abs(Offset) < abs(MaxOffset) )
		return;

	Offset = MaxOffset;
	if ( Time > 1 )
	{
		if ( Time * abs(MaxOffset/Rate) <= 1 )
			MaxOffset = MaxOffset * (1/Time - 1);
		else
			MaxOffset *= -1;
		Time -= 1;
		Rate *= -1;
	}
	else
	{
		MaxOffset = 0;
		Offset = 0;
		Rate = 0;
	}
}

function ViewShake(float DeltaTime)
{
	local Rotator ViewRotation;
	local float FRoll;

	if ( ShakeOffsetRate != vect(0,0,0) )
	{
		// modify shake offset
		ShakeOffset.X += DeltaTime * ShakeOffsetRate.X;
		CheckShake(MaxShakeOffset.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X);
		
		ShakeOffset.Y += DeltaTime * ShakeOffsetRate.Y;
		CheckShake(MaxShakeOffset.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y);
		
		ShakeOffset.Z += DeltaTime * ShakeOffsetRate.Z;
		CheckShake(MaxShakeOffset.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z);
	}				

	ViewRotation = Rotation;

	if ( ShakeRollRate != 0 )
	{
		ViewRotation.Roll = ((ViewRotation.Roll & 65535) + ShakeRollRate * DeltaTime) & 65535;
		if ( ViewRotation.Roll > 32768 )
			ViewRotation.Roll -= 65536;
		FRoll = ViewRotation.Roll;
		CheckShake(MaxShakeRoll, FRoll, ShakeRollRate, ShakeRollTime);
		ViewRotation.Roll = FRoll;
	}
	else if ( bZeroRoll )
		ViewRotation.Roll = 0;
	SetRotation(ViewRotation);
}

function bool TurnTowardNearestEnemy();

function TurnAround()
{
	if ( !bSetTurnRot )
	{
		TurnRot180 = Rotation;
		TurnRot180.Yaw += 32768;
		bSetTurnRot = true;
	}
	
	DesiredRotation = TurnRot180;
	bRotateToDesired = ( DesiredRotation.Yaw != Rotation.Yaw );
}
					
function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation, ViewRotation;

	if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
	{
		ViewShake(deltaTime);
		return;
	}
	ViewRotation = Rotation;
	DesiredRotation = ViewRotation; //save old rotation
	if ( bTurnToNearest != 0 )
		TurnTowardNearestEnemy();
	else if ( bTurn180 != 0 )
		TurnAround();
	else
	{
		TurnTarget = None;
		bRotateToDesired = false;
		bSetTurnRot = false;
		ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
	}
	ViewRotation.Pitch = ViewRotation.Pitch & 65535;
	If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
	{
		If (aLookUp > 0) 
			ViewRotation.Pitch = 18000;
		else
			ViewRotation.Pitch = 49152;
	}

	SetRotation(ViewRotation);

	ViewShake(deltaTime);
	ViewFlash(deltaTime);
		
	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
		Pawn.FaceRotation(NewRotation, deltatime);
}

function ClearDoubleClick()
{
	if (PlayerInput != None)
		PlayerInput.DoubleClickTimer = 0.0;
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local vector OldAccel;
		local bool OldCrouch;

		if(Pawn == none)
			return;
		
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		if ( bPressedJump )
			Pawn.DoJump(bUpdating);
		if ( Pawn.Physics != PHYS_Falling )
		{
			OldCrouch = Pawn.bWantsToCrouch;
			if (bDuck == 0)
				Pawn.ShouldCrouch(false);
			else if ( Pawn.bCanCrouch )
				Pawn.ShouldCrouch(true);
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		GetAxes(Pawn.Rotation,X,Y,Z);

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y; 
		NewAccel.Z = 0;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime);
		
		GroundPitch = 0;	
		ViewRotation = Rotation;
//#ifndef R6CODE
//		if ( Pawn.Physics == PHYS_Walking )
//		{
//			// tell pawn about any direction changes to give it a chance to play appropriate animation
//			//if walking, look up/down stairs - unless player is rotating view
//			if ( (bLook == 0) 
//				&& (((Pawn.Acceleration != Vect(0,0,0)) && bAlwaysLevel && bSnapToLevel) || !bKeyboardLook) )
//			{
//				if ( bLookUpStairs || bSnapToLevel )
//				{
//					GroundPitch = FindStairRotation(deltaTime);
//					ViewRotation.Pitch = GroundPitch;
//				}
//				else if ( bCenterView )
//				{
//					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
//					if (ViewRotation.Pitch > 32768)
//						ViewRotation.Pitch -= 65536;
//					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
//					if ( Abs(ViewRotation.Pitch) < 1000 )
//						ViewRotation.Pitch = 0;	
//				}
//			}
//		}	
//		else
//#else
	    if ( Pawn.Physics != PHYS_Walking )
//#endif // #ifndef R6CODE
		{
			if ( !bKeyboardLook && (bLook == 0) && bCenterView )
			{
				ViewRotation.Pitch = ViewRotation.Pitch & 65535;
				if (ViewRotation.Pitch > 32768)
					ViewRotation.Pitch -= 65536;
				ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
				if ( Abs(ViewRotation.Pitch) < 1000 )
					ViewRotation.Pitch = 0;	
			}
		}
		Pawn.CheckBob(DeltaTime, Y);

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{

		if ( Pawn.Mesh == None )
			Pawn.SetMesh();
		DoubleClickDir = DCLICK_None;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_Karma) // FIXME HACK!!!
			Pawn.SetPhysics(PHYS_Walking);
		GroundPitch = 0;
	}
	
	function EndState()
	{

		GroundPitch = 0;
		if ( Pawn != None && bDuck==0 )
		{
			Pawn.ShouldCrouch(false);
	}
}
}

// player is climbing ladder
state PlayerClimbing
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		else
		GotoState(Pawn.LandMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;

		if ( bPressedJump )
		{
			Pawn.DoJump(bUpdating);
			if ( Pawn.Physics == PHYS_Falling )
				GotoState('PlayerWalking');
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		GetAxes(Rotation,X,Y,Z);

		// Update acceleration.
		if ( Pawn.OnLadder != None )
			NewAccel = aForward*Pawn.OnLadder.ClimbDir; 
		else
			NewAccel = aForward*X + aStrafe*Y;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);
		
//#ifdef R6CODE - rbrek 12 may 2002
		ViewRotation = Pawn.Rotation;
//		ViewRotation = Rotation;
//#endif

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
	}
	
	function EndState()
	{
		if ( Pawn != None )
			Pawn.ShouldCrouch(false);
	}
}

//#ifndef R6CODE
// Player movement.
// Player Driving a Karma vehicle.
//state PlayerDriving
//{
//ignores SeePlayer, HearNoise, Bump;
//
//    event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
//    {
//        local vector View, CamLookAt, HitLocation, HitNormal;
//        local plane CamView;
//		local KVehicle DrivenVehicle;
//
//	    ViewActor = ViewTarget;
//	    CameraLocation = ViewTarget.Location;
//
//	    if ( ViewTarget == Pawn )
//	    {
//		    if( !bBehindView ) // not drawing car
//            {
//    		    CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
//            }
//		    else // drawing car (use vehicles camera position info)
//            {
//				DrivenVehicle = KVehicle(Pawn);
//                CamView = DrivenVehicle.CamPos[DrivenVehicle.CamPosIndex];
//
//                // Only follow vehicle rotation in 'in car' view.
//                //if(DrivenVehicle.CamPosIndex == 0)
//	                //CameraRotation = Rotation+ViewTarget.Rotation;
//                //else
//	                //CameraRotation = Rotation;
//
//				//if(VSize(DrivenVehicle.Velocity) > 10)
//				//	CameraRotation = Rotator(DrivenVehicle.Velocity);
//				//else
//					CameraRotation = Rotation;
//
//	            View = CamView >> ViewTarget.Rotation;
//	            CameraLocation += View;
//				CamLookAt = CameraLocation;
//
//	            View = (vect(1, 0, 0) * CamView.W) >> CameraRotation;
//	            CameraLocation -= View;
//				
//				if( Trace( HitLocation, HitNormal, CameraLocation, CamLookAt, false ) != None )
//				{
//					CameraLocation = HitLocation;
//				}
//            }
//		    return;
//	    }
//	    if ( ViewTarget == self )
//	    {
//		    CameraRotation = Rotation;
//		    return;
//	    }
//	    CameraRotation = ViewTarget.Rotation;
//	    if ( bBehindView )
//	    {
//		    CameraLocation = CameraLocation + (ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0,0,1);
//		    CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
//	    }
//    }
//
//	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
//	{
//
//	}
//
//    exec function Fire(optional float F)
//    {
//
//    }
//
//    exec function AltFire(optional float F)
//    {
//		local KVehicle DrivenVehicle;
//		DrivenVehicle = KVehicle(Pawn);
//
//		if(DrivenVehicle != None)
//			DrivenVehicle.bLookSteer = !DrivenVehicle.bLookSteer;
//    }
//
//	function PlayerMove( float DeltaTime )
//	{
//		local KVehicle DrivenVehicle;
//		local vector Right, Forward, Up, LookDir, LookDirInPlane;
//		local float UpComp, DesYaw;
//
//
//		DrivenVehicle = KVehicle(Pawn);
//        if(DrivenVehicle == None)
//        {
//            log("PlayerDriving.PlayerMove: No Vehicle");
//            return;
//        }
//
//        // check for 'jump' to throw the driver out.
//        if(bPressedJump)
//        {
//            GotoState('PlayerWalking');
//            return;
//        }
//
//		//log("Drive:"$aForward$" Steer:"$aStrafe);
//
//        if(aForward > 1)
//        {
//            DrivenVehicle.Throttle = 1;
//        }
//        else if(aForward < -1)
//        {
//            DrivenVehicle.Throttle = -1;
//        }
//        else
//        {
//            DrivenVehicle.Throttle = 0;
//        }
//
//		// If we are using 'look steer' - take steering from current look vector.
//		if(DrivenVehicle.bLookSteer)
//		{
//			GetAxes(DrivenVehicle.Rotation,Right,Forward,Up);
//			LookDir = -1 * vector(Rotation);
//
//			UpComp = LookDir Dot Up;
//
//			//If we are looking straight up or down, don't do any steering (go straight) 
//			if(Abs(UpComp) > 0.98f)
//			{
//				DrivenVehicle.Steering = 0;
//			}
//			else
//			{
//				LookDirInPlane = Normal(LookDir - (Up * UpComp));
//
//				DesYaw = -65535/6.2832 * Acos(FClamp(LookDirInPlane Dot Forward, -1.0, 1.0));
//				if((LookDirInPlane Dot Right) > 0)
//					DesYaw *= -1;
//
//				DrivenVehicle.Steering = FClamp(DesYaw * DrivenVehicle.LookSteerSens, -1.0, 1.0);
//			}
//		}
//		// otherwise use the strafe keys for steering.
//		// TODO: Add proper follow-cam - but what does mouse do then?
//		else 
//		{
//			if(aStrafe < -1)
//				DrivenVehicle.Steering = 1;
//			else if(aStrafe > 1)
//				DrivenVehicle.Steering = -1;
//			else
//				DrivenVehicle.Steering = 0;
//		}
//
//        // update 'looking' rotation - no affect on driving
//		UpdateRotation(DeltaTime, 2);
//	}
//
//
//	function BeginState()
//	{
//		SetRotation(rotator( vect(0, -1, 0) >> Pawn.Rotation ));
//        bBehindView = true;
//		bFreeCamera = true;
//	}
//	
//	function EndState()
//	{
//		local KVehicle DrivenVehicle;
//
//		DrivenVehicle = KVehicle(Pawn);
//        DrivenVehicle.KDriverLeave(); // execute 'Leave' event
//		bBehindView = false;
//		bFreeCamera = false;
//	}
//#endif // #ifndef R6CODE

// Player movement.
// Player walking on walls
state PlayerSpidering
{
ignores SeePlayer, HearNoise, Bump;

	event bool NotifyHitWall(vector HitNormal, actor HitActor)
	{
		Pawn.SetPhysics(PHYS_Spider);
		Pawn.SetBase(HitActor, HitNormal);	
		return true;
	}

	// if spider mode, update rotation based on floor					
	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local rotator TempRot, ViewRotation;
		local vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

		if ( bInterpolating || Pawn.bInterpolating )
		{
			ViewShake(deltaTime);
			return;
		}

		TurnTarget = None;
		bRotateToDesired = false;
		bSetTurnRot = false;

		if ( (Pawn.Base == None) || (Pawn.Floor == vect(0,0,0)) )
			MyFloor = vect(0,0,1);
		else
			MyFloor = Pawn.Floor;

		if ( MyFloor != OldFloor )
		{
			// smoothly change floor
			RealFloor = MyFloor;
			MyFloor = Normal(6*DeltaTime * MyFloor + (1 - 6*DeltaTime) * OldFloor);
			if ( (RealFloor Dot MyFloor) > 0.999 )
				MyFloor = RealFloor;

			// translate view direction
			CrossDir = Normal(RealFloor Cross OldFloor);
			FwdDir = CrossDir Cross MyFloor;
			OldFwdDir = CrossDir Cross OldFloor;
			ViewX = MyFloor * (OldFloor Dot ViewX) 
						+ CrossDir * (CrossDir Dot ViewX) 
						+ FwdDir * (OldFwdDir Dot ViewX);
			ViewX = Normal(ViewX);
			
			ViewZ = MyFloor * (OldFloor Dot ViewZ) 
						+ CrossDir * (CrossDir Dot ViewZ) 
						+ FwdDir * (OldFwdDir Dot ViewZ);
			ViewZ = Normal(ViewZ);
			OldFloor = MyFloor;  
			ViewY = Normal(MyFloor Cross ViewX); 
		}

		if ( (aTurn != 0) || (aLookUp != 0) )
		{
			// adjust Yaw based on aTurn
			if ( aTurn != 0 )
				ViewX = Normal(ViewX + 2 * ViewY * Sin(0.0005*DeltaTime*aTurn));

			// adjust Pitch based on aLookUp
			if ( aLookUp != 0 )
			{
				OldX = ViewX;
				ViewX = Normal(ViewX + 2 * ViewZ * Sin(0.0005*DeltaTime*aLookUp));
				ViewZ = Normal(ViewX Cross ViewY);

				// bound max pitch
				if ( (ViewZ Dot MyFloor) < 0.707   )
				{
					OldX = Normal(OldX - MyFloor * (MyFloor Dot OldX));
					if ( (ViewX Dot MyFloor) > 0)
						ViewX = Normal(OldX + MyFloor);
					else
						ViewX = Normal(OldX - MyFloor);

					ViewZ = Normal(ViewX Cross ViewY);
				}
			}
			
			// calculate new Y axis
			ViewY = Normal(MyFloor Cross ViewX);
		}
		ViewRotation =  OrthoRotation(ViewX,ViewY,ViewZ);
		SetRotation(ViewRotation);
		ViewShake(deltaTime);
		ViewFlash(deltaTime);
		Pawn.FaceRotation(ViewRotation, deltaTime );
	}

	function bool NotifyLanded(vector HitNormal)
	{
		Pawn.SetPhysics(PHYS_Spider);
		return bUpdating;
	}

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;

		if ( bPressedJump )
			Pawn.DoJump(bUpdating);
	}

	function PlayerMove( float DeltaTime )
	{
		local vector NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		GroundPitch = 0;	
		ViewRotation = Rotation;

		if ( !bKeyboardLook && (bLook == 0) && bCenterView )
		{
			// FIXME - center view rotation based on current floor
		}
		Pawn.CheckBob(DeltaTime,vect(0,0,0));

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		// Update acceleration.
		NewAccel = aForward*Normal(ViewX - OldFloor * (OldFloor Dot ViewX)) + aStrafe*ViewY; 
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		local Rotator NewRot;

		if ( Pawn.Mesh == None )
			Pawn.SetMesh();
		OldFloor = vect(0,0,1);
		GetAxes(Rotation,ViewX,ViewY,ViewZ);
		DoubleClickDir = DCLICK_None;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if (Pawn.Physics != PHYS_Falling) 
			Pawn.SetPhysics(PHYS_Spider);
		GroundPitch = 0;
		Pawn.bCrawler = true;
		Pawn.SetCollisionSize(Pawn.Default.CollisionHeight,Pawn.Default.CollisionHeight);
	}
	
	function EndState()
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetCollisionSize(Pawn.Default.CollisionRadius,Pawn.Default.CollisionHeight);
			Pawn.ShouldCrouch(false);
			Pawn.bCrawler = Pawn.Default.bCrawler;
		}
	}
}
	
// Player movement.
// Player Swimming
state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

	function bool WantsSmoothedView()
	{
		return ( !Pawn.bJustLanded );
	}

	function bool NotifyLanded(vector HitNormal)
	{
		if ( Pawn.PhysicsVolume.bWaterVolume )
			Pawn.SetPhysics(PHYS_Swimming);
		else
			GotoState(Pawn.LandMovementState);
		return bUpdating;
	}
	
	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint;

		if ( !NewVolume.bWaterVolume )
		{
			Pawn.SetPhysics(PHYS_Falling);
			if (Pawn.bUpAndOut && Pawn.CheckWaterJump(HitNormal)) //check for waterjump
			{
				Pawn.velocity.Z = FMax(Pawn.JumpZ,420) + 2 * Pawn.CollisionRadius; //set here so physics uses this for remainder of tick
				GotoState(Pawn.LandMovementState);
			}				
			else if ( (Pawn.Velocity.Z > 160) || !Pawn.TouchingWaterVolume() )
				GotoState(Pawn.LandMovementState);
			else //check if in deep water
			{
				checkpoint = Pawn.Location;
				checkpoint.Z -= (Pawn.CollisionHeight + 6.0);
				HitActor = Trace(HitLocation, HitNormal, checkpoint, Pawn.Location, false);
				if (HitActor != None)
					GotoState(Pawn.LandMovementState);
				else
				{
					Enable('Timer');
					SetTimer(0.7,false);
				}
			}
		}
		else
		{
			Disable('Timer');
			Pawn.SetPhysics(PHYS_Swimming);
		}
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local vector X,Y,Z, OldAccel;
	
		GetAxes(Rotation,X,Y,Z);
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		Pawn.bUpAndOut = ((X Dot Pawn.Acceleration) > 0) && ((Pawn.Acceleration.Z > 0) || (Rotation.Pitch > 2048));
		if ( !Pawn.PhysicsVolume.bWaterVolume ) //check for waterjump
			NotifyPhysicsVolumeChange(Pawn.PhysicsVolume);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
	
		GetAxes(Rotation,X,Y,Z);

		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1); 
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);
	
		//add bobbing when swimming
		Pawn.CheckBob(DeltaTime, Y);

		// Update rotation.
		oldRotation = Rotation;
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		bPressedJump = false;
	}

	function Timer()
	{
		if ( !Pawn.PhysicsVolume.bWaterVolume && (Role == ROLE_Authority) )
			GotoState(Pawn.LandMovementState);
	
		Disable('Timer');
	}
	
	function BeginState()
	{
		Disable('Timer');
		Pawn.SetPhysics(PHYS_Swimming);
	}
}
	
state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = aForward*X + aStrafe*Y; 
		if ( VSize(Pawn.Acceleration) < 1.0 )
			Pawn.Acceleration = vect(0,0,0);
		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation(DeltaTime, 2);
		
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}
	
	function BeginState()
	{
		Pawn.SetPhysics(PHYS_Flying);
	}
}

state PlayerHelicoptering extends PlayerFlying
{
	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1); 
		if ( VSize(Pawn.Acceleration) < 1.0 )
			Pawn.Acceleration = vect(0,0,0);
		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation(DeltaTime, 2);
		
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}
}

state BaseSpectating
{
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);
	
		Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	}
}

state Scripting
{
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
	exec function Fire( optional float F )
	{
	}

	exec function AltFire( optional float F )
	{
		Fire(F);
	}
	}

function ServerViewNextPlayer()
	{
	local Controller C;
	local Pawn Pick;
	local bool bFound, bRealSpec;

	bRealSpec = bOnlySpectator;
	bOnlySpectator = true;
			
			// view next player
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		log("Check spectate "$C.Pawn$" can "$Level.Game.CanSpectate(self,true,C.Pawn));
		if ( (C.Pawn != None) && Level.Game.CanSpectate(self,true,C.Pawn) )
				{
					if ( Pick == None )
				Pick = C.Pawn;
					if ( bFound )
					{
				Pick = C.Pawn;
						break;
					}	
					else
						bFound = ( ViewTarget == C.Pawn );
				}
	}
	log("best is "$Pick);
	SetViewTarget(Pick);
	log("Viewtarget is "$ViewTarget);		 
			if ( ViewTarget == self )
				bBehindView = false;
			else
				bBehindView = true; //bChaseCam;
	bOnlySpectator = bRealSpec;

		}

event ClientSetNewViewTarget();

function ServerViewSelf()
{
	bBehindView = false;
	SetViewtarget(self);
	ClientMessage(OwnCamera, 'Event');
}

state Spectating extends BaseSpectating
{
	ignores ClientRestart, Suicide,
	 NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

	exec function Fire( optional float F )
	{
		bBehindView = true;
		ServerViewNextPlayer();
	}

	// Return to spectator's own camera.
	exec function AltFire( optional float F )
	{
		bBehindView = false;
		ServerViewSelf();
	}

	function BeginState()
	{
		if ( Pawn != None )
		{
			SetLocation(Pawn.Location);
			UnPossess();
		}
		bCollideWorld = true;
	}

	function EndState()
	{
		if(PlayerReplicationInfo != none)	//R6CODE
			PlayerReplicationInfo.bIsSpectator = false;		
		bCollideWorld = false;
	}
}

auto state PlayerWaiting extends BaseSpectating
{
ignores SeePlayer, HearNoise, NotifyBump, R6TakeDamage, PhysicsVolumeChange;

	exec function Jump( optional float F )
	{
	}

	exec function Suicide()
	{
	}

	function ServerReStartPlayer()
	{
		if ( Level.TimeSeconds < WaitDelay )
			return;
		if ( Level.NetMode == NM_Client )
			return;
		if ( Level.Game.bWaitingToStartMatch )
			PlayerReplicationInfo.bReadyToPlay = true;
		else
			Level.Game.RestartPlayer(self);
	}

	exec function Fire(optional float F)
	{
		ServerReStartPlayer();
	}
	
	exec function AltFire(optional float F)
	{
		ServerReStartPlayer();
	}

	function EndState()
	{
		if ( Pawn != None )
			Pawn.SetMesh();
		if(PlayerReplicationInfo != none)	//R6CODE
			PlayerReplicationInfo.SetWaitingPlayer(false);
		bCollideWorld = false;
	}

	function BeginState()
	{
		if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(true);
		bCollideWorld = true;
		myHUD.bShowScores = false;
	}
}

state WaitingForPawn extends BaseSpectating
{
ignores SeePlayer, HearNoise, KilledBy;

	exec function Fire( optional float F )
	{
	}

	exec function AltFire( optional float F )
	{
	}

	function LongClientAdjustPosition
	(
		float TimeStamp, 
		name newState, 
		EPhysics newPhysics,
		float NewLocX, 
		float NewLocY, 
		float NewLocZ, 
		float NewVelX, 
		float NewVelY, 
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
	}

	function PlayerTick(float DeltaTime)
	{
		Global.PlayerTick(DeltaTime);

		if ( Pawn != None )
		{
			Pawn.Controller = self;
			ClientRestart();
		}
	}

	function Timer()
	{
		AskForPawn();
	}

	function BeginState()
	{
		SetTimer(0.2, true);
	}

	function EndState()
	{
		SetTimer(0.0, false);
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, R6TakeDamage, Suicide;

	function ServerReStartGame()
	{
		Level.Game.RestartGame();
	}

	exec function Fire( optional float F )
	{
		if ( Role < ROLE_Authority)
			return;
		if ( !bFrozen )
			ServerReStartGame();
		else if ( TimerRate <= 0 )
			SetTimer(1.5, false);
	}
	
	exec function AltFire( optional float F )
	{
		Fire(F);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local Rotator ViewRotation;

		GetAxes(Rotation,X,Y,Z);
		// Update view rotation.

		if ( !bFixedCamera )
		{
			ViewRotation = Rotation;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			SetRotation(ViewRotation);
		}
		else if ( ViewTarget != None )
			SetRotation(ViewTarget.Rotation);

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		bPressedJump = false;
	}

	function ServerMove
	(
		float TimeStamp, 
		vector InAccel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbCrawl,  //rb bool NewbJumpStatus, 
//		eDoubleClickDir DoubleClickMove, 
//		byte ClientRoll, 
		int View,
// #ifdef R6PlayerMovements
        int iNewRotOffset,
// #endif R6PlayerMovements
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbCrawl,
							//DoubleClickMove, ClientRoll, 
                            (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
// #ifdef R6PlayerMovements
                            0
// #endif R6PlayerMovements
                            );

	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;
		
		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;
		
		for (tries=0; tries<16; tries++)
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;	
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}
			
		ViewRotation.Yaw = startYaw + besttry * 4096;
		SetRotation(ViewRotation);
	}
	
	function Timer()
	{
		bFrozen = false;
	}
	
	function BeginState()
	{
		local Pawn P;

        Level.m_bInGamePlanningActive = false;
		EndZoom();
		bFire = 0;
		bAltFire = 0;
		if ( Pawn != None )
		{
			Pawn.SimAnim.AnimRate = 0;
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			Pawn.SetCollision(false,false,false);
		}
		myHUD.bShowScores = true;
		bFrozen = true;
		if ( !bFixedCamera )
		{
			//FindGoodView();
			bBehindView = true;
		}
		SetTimer(1.5, false);
		SetPhysics(PHYS_None);
		ForEach DynamicActors(class'Pawn', P)
		{
			P.Velocity = vect(0,0,0);
			P.SetPhysics(PHYS_None);
		}
	}
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy;

	function ServerRestartPlayer()
	{
		Super.ServerRestartPlayer();
	}

	exec function Fire( optional float F )
	{
			ServerReStartPlayer();
	}
	
	exec function AltFire( optional float F )
	{
		if (myHUD.bShowScores)
		Fire(F);
		else
			Timer();
	}

	function ServerMove
	(
		float TimeStamp, 
		vector Accel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbCrawl, //rb bool NewbJumpStatus,
//		eDoubleClickDir DoubleClickMove, 
//		byte ClientRoll, 
		int View,
// #ifdef R6PlayerMovements
        int iNewRotOffset,
// #endif R6PlayerMovements
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(
					TimeStamp,
					Accel, 
					ClientLoc,
					false,
					false,
					false,
//					DoubleClickMove, 
//					ClientRoll, 
					View,
// #ifdef R6PlayerMovements
                    iNewRotOffset,
// #endif R6PlayerMovements
                    );
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator ViewRotation;

		if ( !bFrozen )
		{
			if ( bPressedJump )
			{
				Fire(0);
				bPressedJump = false;
			}
			GetAxes(Rotation,X,Y,Z);
			// Update view rotation.
			ViewRotation = Rotation;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			SetRotation(ViewRotation);
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;
		
		if(ViewTarget == none)
			return;

		////log("Find good death scene view");
		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;
		
		for (tries=0; tries<16; tries++)
		{
			cameraLoc = ViewTarget.Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;	
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}
			
		ViewRotation.Yaw = startYaw + besttry * 4096;
		SetRotation(ViewRotation);
	}
	
	function Timer()
	{

		if (!bFrozen)
			return;
			
		bFrozen = false;
		myHUD.bShowScores = true;
		bPressedJump = false;
	}
	
	function BeginState()
	{
		local SavedMove Next;
//#ifdef R6CODE
		local SavedMove Current;
//#endif // #ifdef R6CODE

		Enemy = None;
		bBehindView = true;
		bFrozen = true;
		bPressedJump = false;
		//FindGoodView();
//#ifndef R6CODE 		
//		SetTimer(6.0, true);
//#endif

		// clean out saved moves
		while ( SavedMoves != None )
		{
			Next = SavedMoves.NextMove;
//#ifdef R6CODE
            Current = SavedMoves;
			SavedMoves = Next;
			Current.Destroy();
//#else
//			SavedMoves.Destroy();
//			SavedMoves = Next;
//#endif // #ifdef R6CODE
		}
		if ( PendingMove != None )
		{
//#ifdef R6CODE
            Current = PendingMove;
			PendingMove = None;
			Current.Destroy();
//#else
//			PendingMove.Destroy();
//			PendingMove = None;
//#endif // #ifdef R6CODE
		}
	}
	
	function EndState()
	{
		local SavedMove Next;

		// clean out saved moves
		while ( SavedMoves != None )
		{
			Next = SavedMoves.NextMove;
			SavedMoves.Destroy();
			SavedMoves = Next;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		bBehindView = false;
		myHUD.bShowScores = false;
		bPressedJump = false;
		//Log(self$" exiting dying with remote role "$RemoteRole$" and role "$Role);
	}
}

//------------------------------------------------------------------------------
// ngStats Accessors
function string GetNGSecret()
{
	return ngWorldSecret;
}

function SetNGSecret(string newSecret)
{
	ngWorldSecret = newSecret;
}

//------------------------------------------------------------------------------
// Control options	
function ChangeStairLook( bool B )
{
	bLookUpStairs = B;
	if ( bLookUpStairs )
		bAlwaysMouseLook = false;
}

function ChangeAlwaysMouseLook(Bool B)
{
	bAlwaysMouseLook = B;
	if ( bAlwaysMouseLook )
		bLookUpStairs = false;
}

//R6Radar begin
event ToggleRadar(BOOL _bRadar)
{
    ServerToggleRadar(_bRadar);
}

function ServerToggleRadar(BOOL _bRadar)
{
    m_bRadarActive = _bRadar;
}

function ServerToggleHeatVision(BOOL bHeatVisionActive)
{
    m_bHeatVisionActive = bHeatVisionActive;
}

//R6Radar end

//#ifdef R6CODE

event ClientPBKickedOutMessage(string PBMessage)
{
    Player.Console.R6ConnectionFailed(PBMessage);
}

// 
function ClientPBKickMsg(string PBMessage)
{
    Player.Console.R6ConnectionFailed(PBMessage);
}

//#endif R6CODE

defaultproperties
{
     EnemyTurnSpeed=45000
     bAlwaysMouseLook=True
     bKeyboardLook=True
     bZeroRoll=True
     OrthoZoom=40000.000000
     CameraDist=9.000000
     DesiredFOV=85.000000
     DefaultFOV=85.000000
     MaxTimeMargin=1.000000
     NetClientMaxTickRate=15.000000
     LocalMessageClass=Class'Engine.LocalMessage'
     CheatClass=Class'Engine.CheatManager'
     InputClass=Class'Engine.PlayerInput'
     FlashScale=(X=1.000000,Y=1.000000,Z=1.000000)
     QuickSaveString="Quick Saving"
     NoPauseMessage="Game is not pauseable"
     ViewingFrom="Now viewing from"
     OwnCamera="Now viewing from own camera"
     bIsPlayer=True
     bCanOpenDoors=True
     bCanDoSpecial=True
     FovAngle=85.000000
     Handedness=1.000000
     bTravel=True
     NetPriority=3.000000
}
