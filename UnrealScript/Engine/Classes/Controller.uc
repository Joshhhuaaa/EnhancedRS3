//=============================================================================
// Controller, the base class of players or AI.
//
// Controllers are non-physical actors that can be attached to a pawn to control 
// its actions.  PlayerControllers are used by human players to control pawns, while 
// AIControFllers implement the artificial intelligence for the pawns they control.  
// Controllers take control of a pawn using their Possess() method, and relinquish 
// control of the pawn by calling UnPossess().
//
// Controllers receive notifications for many of the events occuring for the Pawn they 
// are controlling.  This gives the controller the opportunity to implement the behavior 
// in response to this event, intercepting the event and superceding the Pawn's default 
// behavior.  
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Controller extends Actor
	native
	nativereplication
	abstract;

var Pawn Pawn;

var		float		SightCounter;		// Used to keep track of when to check player visibility
var		float		FovAngle;			// X field of view angle in degrees, usually 90.
var		float		Handedness;
var		bool        bIsPlayer;			// Pawn is a player or a player-bot.
var		bool		bGodMode;			// cheat - when true, can't be killed or hurt

//AI flags
var const bool		bLOSflag;			// used for alternating LineOfSight traces
var		bool		bAdvancedTactics;	// serpentine movement between pathnodes
var		bool		bCanOpenDoors;
var		bool		bCanDoSpecial;
var		bool		bAdjusting;			// adjusting around obstacle
var		bool		bPreparingMove;		// set true while pawn sets up for a latent move
var		bool		bControlAnimations;	// take control of animations from pawn (don't let pawn play animations based on notifications)
var		bool		bEnemyInfoValid;	// false when change enemy, true when LastSeenPos etc updated

var(AI) enum EAttitude  // order in decreasing importance
{
	ATTITUDE_Fear,		// will try to run away
	ATTITUDE_Hate,		// will attack enemy
	ATTITUDE_Frenzy,	// will attack anything, indiscriminately
	ATTITUDE_Threaten,	// animations, but no attack
	ATTITUDE_Ignore,
	ATTITUDE_Friendly,
	ATTITUDE_Follow 	// accepts player as leader
} AttitudeToPlayer;		// determines how creature will react on seeing player (if in human form)


// #ifdef R6PlayerMovements
var                 BOOL            m_bCrawl;               // equivalent of bDuck
// #endif R6PlayerMovements

// Input buttons.
var input byte
	bRun, /* r6code bDuck,*/ bFire, bAltFire;

// r6code

// Camera movement with the keyboard for the PlaningController
var input BYTE		m_bMoveUp;
var input BYTE		m_bMoveDown;
var input BYTE		m_bMoveLeft;
var input BYTE		m_bMoveRight;
var input BYTE		m_bRotateCW;
var input BYTE		m_bRotateCCW;
var input BYTE		m_bZoomIn;
var input BYTE		m_bZoomOut;
var input BYTE      m_bAngleUp;
var input BYTE      m_bAngleDown;
var input BYTE    	m_bLevelUp;
var input BYTE      m_bLevelDown;
var input BYTE      m_bGoLevelUp; //to change the level once.
var input BYTE      m_bGoLevelDown;

// end

var		byte		bDuck;			// 17 jan 2002 rbrek - modified the declaration of bDuck so that it is no longer mapped directly to an input button
                 					// especially since we use it as a regular variable.  Input variables are all reset when the game loses focus (switch tasks).

var		vector		AdjustLoc;			// location to move to while adjusting around obstacle

var const	Controller		nextController; // chained Controller list

var		float 		Stimulus;			// Strength of stimulus - Set when stimulus happens

// Navigation AI
var 	float		MoveTimer;
var 	Actor		MoveTarget;		// actor being moved toward
var		vector	 	Destination;	// location being moved toward
var	 	vector		FocalPoint;		// location being looked at
var		Actor		Focus;			// actor being looked at
var		Mover		PendingMover;	// mover pawn is waiting for to complete its move
var		Actor		GoalList[4];	// used by navigation AI - list of intermediate goals
var NavigationPoint home;			// set when begin play, used for retreating and attitude checks
var	 	float		MinHitWall;		// Minimum HitNormal dot Velocity.Normal to get a HitWall event from the physics

// Enemy information
var	 	Pawn    	Enemy;
var		Actor		Target;
var		vector		LastSeenPos; 	// enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var		vector		LastSeeingPos;	// position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var		float		LastSeenTime;
 
var string VoiceType; //for speech
var float OldMessageTime; //to limit frequency of voice messages

// Route Cache for Navigation
var Actor RouteCache[16];
var ReachSpec	CurrentPath;
var Actor	RouteGoal; //final destination for current route
var float	RouteDist;	// total distance for current route

// Replication Info
var() class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var PlayerReplicationInfo PlayerReplicationInfo;

var class<Pawn> PawnClass;	// class of pawn to spawn (for players)
var class<Pawn> PreviousPawnClass;	// Holds the player's previous class

var float GroundPitchTime;
var vector ViewX, ViewY, ViewZ;	// Viewrotation encoding for PHYS_Spider

var NavigationPoint StartSpot;  // where player started the match

//#ifdef R6CODE
var         name                NextState; //for queueing states
var         name                NextLabel; //for queueing states
var R6PawnReplicationInfo m_PawnRepInfo;

//Put here to save cast and checks
var         BOOL                m_bLockWeaponActions;      //Local Flag to limit the actions on weapon while doing something else.
var         BOOL                m_bHideReticule;

//#endif // #ifdef R6CODE

// R6MOVETO
enum EMoveToResult {
    eMoveTo_none,
    eMoveTo_success,
    eMoveTo_failed
};
var         EMoveToResult       m_eMoveToResult;

// for monitoring the position of a pawn
var		vector		MonitorStartLoc;	// used by latent function MonitorPawn()
var		Pawn		MonitoredPawn;		// used by latent function MonitorPawn()
var		float		MonitorMaxDistSq;

const LATENT_MOVETOWARD = 503; // LatentAction number for Movetoward() latent function

//R6CODE Begin
enum ECDKEY_VALID_REQ
{
    ECDKEY_NONE,
    ECDKEY_FIRSTPASS,
    ECDKEY_WAITING_FOR_RESPONSE,
    ECDKEY_NOT_VALID,
    ECDKEY_VALID,
    ECDKEY_TIMEOUT
};

enum ECDKEYST_STATUS
{
    ECDKEYST_PLAYER_UNKNOWN,
    ECDKEYST_PLAYER_INVALID,
    ECDKEYST_PLAYER_VALID,
    ECDKEYST_PLAYER_BANNED,
    ECDKEYST_PLAYER_PB_KICKED
};
struct PlayerVerCDKeyStatus
{
    var ECDKEY_VALID_REQ m_eCDKeyRequest;       // State of cdkey request state machine
    var string           m_szAuthorizationID;   // Player authorization ID
    var INT              m_iCDKeyReqID;         // CD key request ID
    var BOOL             m_bCDKeyValSecondTry;  // This is the second attempt at validating this user (only try twice)
    var ECDKEYST_STATUS  m_eCDKeyStatus;        // Player status set by validation server (valid, not valid, unknown)
};

//R6CODE End

replication
{
	reliable if( Role==ROLE_Authority )
		R6DamageAttitudeTo;
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		PlayerReplicationInfo, m_PawnRepInfo, Pawn;
	reliable if( bNetDirty && (Role== ROLE_Authority) && bNetOwner )
		PawnClass;

	// Functions the server calls on the client side.
	reliable if( RemoteRole==ROLE_AutonomousProxy ) 
		ClientGameEnded, ClientDying, ClientSetRotation, ClientSetLocation;

	// Functions the client calls on the server.
	reliable if ( Role < ROLE_Authority )
		ServerRestartPlayer;
}

// Latent Movement.
//Note that MoveTo sets the actor's Destination, and MoveToward sets the
//actor's MoveTarget.  Actor will rotate towards destination unless the optional ViewFocus is specified.

native(500) final latent function MoveTo( vector NewDestination, optional Actor ViewFocus, optional float speed, optional bool bShouldWalk);
native(502) final latent function MoveToward(actor NewTarget, optional Actor ViewFocus, optional float speed, optional float DestinationOffset, optional bool bUseStrafing, optional bool bShouldWalk);
native(508) final latent function FinishRotation();

// native AI functions
/* LineOfSightTo() returns true if any of several points of Other is visible 
  (origin, top, bottom)
*/
native(514) final function bool LineOfSightTo(actor Other); 

/* CanSee() similar to line of sight, but also takes into account Pawn's peripheral vision
*/
native(533) final function bool CanSee(Pawn Other); 

//Navigation functions - return the next path toward the goal
native(518) final function Actor FindPathTo(vector aPoint, optional bool bClearPaths);
native(517) final function Actor FindPathToward(actor anActor, optional bool bClearPaths);
native final function Actor FindPathTowardNearest(class<NavigationPoint> GoalClass);
native(525) final function NavigationPoint FindRandomDest(optional bool bClearPaths);

native(522) final function ClearPaths();
native(523) final function vector EAdjustJump(float BaseZ, float XYSpeed);

//Reachable returns whether direct path from Actor to aPoint is traversable
//using the current locomotion method
native(521) final function bool pointReachable(vector aPoint);
native(520) final function bool actorReachable(actor anActor);

/* PickWallAdjust()
Check if could jump up over obstruction (only if there is a knee height obstruction)
If so, start jump, and return current destination
Else, try to step around - return a destination 90 degrees right or left depending on traces
out and floor checks
*/
native(526) final function bool PickWallAdjust(vector HitNormal);

/* WaitForLanding()
latent function returns when pawn is on ground (no longer falling)
*/
native(527) final latent function WaitForLanding();

native(540) final function actor FindBestInventoryPath(out float MinWeight, bool bPredictRespawns);

native(529) final function AddController();
native(530) final function RemoveController();

// Pick best pawn target
native(531) final function pawn PickTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);
native(534) final function actor PickAnyTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);

native final function bool InLatentExecution(int LatentActionNumber); //returns true if controller currently performing latent action specified by LatentActionNumber
// Force end to sleep
native function StopWaiting();
native function EndClimbLadder();

event MayFall(); //return true if allowed to fall - called by engine when pawn is about to fall

//#ifdef R6CODE
exec function Map(int iGotoMapId, string explanation);
//#endif R6CODE

function PendingStasis()
{
	bStasis = true;
	Pawn = None;
}

// #ifdef R6CODE
//============================================================================
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//============================================================================
function logX( string szText, OPTIONAL int iSource )
{
    local string szSource;
	local string time;

    time = string(Level.TimeSeconds);
	time = Left(Time, InStr(Time, ".") + 3); // 2 digits after the dot
    
    if ( iSource == 1 )   // from pawn
    {
        szSource = "(" $time$ ":P) ";    // pawn
    }
    else
    {
        szSource = "(" $time$ ":C) ";    // controller
    }

    log( szSource $ name $ " [" $ GetStateName() $ "|" $ Pawn.GetStateName() $ "] " $ szText );
}
// #endif // #ifdef R6CODE

/* DisplayDebug()
list important controller attributes on canvas
*/
function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	if ( Pawn == None )
	{
		Super.DisplayDebug(Canvas,YL,YPos);
		return;
	}
	
	Canvas.SetDrawColor(255,0,0);
	Canvas.DrawText("CONTROLLER "$GetItemName(string(self))$" Pawn "$Pawn);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("     STATE: "$GetStateName()$" Timer: "$TimerCounter$" Enemy "$Enemy, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	if ( PlayerReplicationInfo == None )
		Canvas.DrawText("     NO PLAYERREPLICATIONINFO", false);
	else
		PlayerReplicationInfo.DisplayDebug(Canvas,YL,YPos);

	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function rotator GetViewRotation()
{
	return Rotation;
}

/* Reset() 
reset actor to initial state
*/
function Reset()
{
	Super.Reset();
	Enemy = None;
	LastSeenTime = 0;
	StartSpot = None;
}

/* ClientSetLocation()
replicated function to set location and rotation.  Allows server to force new location for
teleports, etc.
*/
function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	SetRotation(NewRotation);
	If ( (Rotation.Pitch > RotationRate.Pitch) 
		&& (Rotation.Pitch < 65536 - RotationRate.Pitch) )
	{
		If (Rotation.Pitch < 32768) 
			NewRotation.Pitch = RotationRate.Pitch;
		else
			NewRotation.Pitch = 65536 - RotationRate.Pitch;
	}
	if ( Pawn != None )
	{
		NewRotation.Roll  = 0;
		Pawn.SetRotation( NewRotation );
		Pawn.SetLocation( NewLocation );
	}
}

/* ClientSetRotation()
replicated function to set rotation.  Allows server to force new rotation.
*/
function ClientSetRotation( rotator NewRotation )
{
	SetRotation(NewRotation);
	if ( Pawn != None )
	{
		NewRotation.Pitch = 0;
		NewRotation.Roll  = 0;
		Pawn.SetRotation( NewRotation );
	}
}

function ClientDying(vector HitLocation)
{
	if ( Pawn != None )
	{
		Pawn.PlayDying(HitLocation);
		Pawn.GotoState('Dying');
	}
}

/* AIHearSound()
Called when AI controlled pawn would hear a sound.  Default AI implementation uses MakeNoise() 
interface for hearing appropriate sounds instead
*/
event AIHearSound ( 
	actor Actor, 
	int Id, 
	sound S, 
	vector SoundLocation, 
	vector Parameters,
	bool Attenuate 
);

function Possess(Pawn aPawn)
{
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
	// preserve Pawn's rotation initially for placed Pawns
	FocalPoint = Pawn.Location + 512*vector(Pawn.Rotation);
	Restart();
}

/* PawnDied()
 unpossess a pawn (because pawn was killed)
 */
function PawnDied()
{
	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.UnPossessed();
	}
	Pawn = None;
	PendingMover = None;
	if ( bIsPlayer )
		GotoState('Dead'); // can respawn
	else
		Destroy();
}

function Restart()
{
	Enemy = None;
}

event LongFall(); // called when latent function WaitForLanding() doesn't return after 4 seconds

// notifications of pawn events (from C++)
// if return true, then pawn won't get notified 
event bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume);
event bool NotifyHeadVolumeChange(PhysicsVolume NewVolume);
event bool NotifyLanded(vector HitNormal);
event bool NotifyHitWall(vector HitNormal, actor Wall);
event bool NotifyBump(Actor Other);
event NotifyHitMover(vector HitNormal, mover Wall);

// notifications called by pawn in script
/*R6CHANGEWEAPONSYSTEM
function NotifyAddInventory(inventory NewItem);
*/
function SetFall();	//about to fall

event PreBeginPlay()
{
	AddController();
    m_PawnRepInfo = Spawn(class'R6PawnReplicationInfo');
    m_PawnRepInfo.m_ControllerOwner = Self;

    Super.PreBeginPlay();
	if ( bDeleteMe )
		return;

	SightCounter = 0.2 * FRand();  //offset randomly 
}

event PostBeginPlay()
{
	Super.PostBeginPlay();

//	if ( bIsPlayer && (Role == ROLE_Authority) )
//	{
//		PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
//		InitPlayerReplicationInfo();
//	}
}

function InitPlayerReplicationInfo()
{
	if (PlayerReplicationInfo.PlayerName == "")
		PlayerReplicationInfo.SetPlayerName(class'GameInfo'.Default.DefaultPlayerName);
}

//#ifndef R6CODE
//function HandlePickup(Pickup pick)
//{
//	if ( MoveTarget == pick )
//		MoveTimer = -1.0;
//}
//#endif // #ifndef R6CODE

simulated event Destroyed()
{
	if ( Role < ROLE_Authority )
		return;

	RemoveController();

	if ( bIsPlayer && (Level.Game != None) )
		Level.Game.logout(self);
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.Destroy();

	if ( m_PawnRepInfo != None )
    {
        m_PawnRepInfo.Destroy();
        m_PawnRepInfo = none;
    }

	Super.Destroyed();
}

/* AdjustView() 
by default, check and see if pawn still needs to update eye height
(only if some playercontroller still has pawn as its viewtarget)
Overridden in playercontroller
*/
function AdjustView( float DeltaTime )
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('PlayerController') && (PlayerController(C).ViewTarget == Pawn) )
			return;

//R6CODE	Pawn.bUpdateEyeHeight =false;
//R6CODE	Pawn.Eyeheight = Pawn.BaseEyeheight; 
}
			
function bool WantsSmoothedView()
{
	return ( ((Pawn.Physics==PHYS_Walking) || (Pawn.Physics==PHYS_Spider)) && !Pawn.bJustLanded );
}

function ClientGameEnded()
{
	GotoState('GameEnded');
}

simulated event RenderOverlays( canvas Canvas )
{
/*R6CHANGEWEAPONSYSTEM
	if ( Pawn.Weapon != None )
		Pawn.Weapon.RenderOverlays(Canvas);
*/
//R6Code+
    if ( Pawn.EngineWeapon != None )
    {
		Pawn.EngineWeapon.RenderOverlays(Canvas);
    }
//R6Code-
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
	return 0;
}

//------------------------------------------------------------------------------
// Speech related

function byte GetMessageIndex(name PhraseName)
{
	return 0;
}

//***************************************************************
// interface used by ScriptedControllers to query pending controllers

function bool WouldReactToNoise( float Loudness, Actor NoiseMaker)
{
	return false;
}

function bool WouldReactToSeeing(Pawn Seen)
{
	return false;
}

//***************************************************************
// AI related

function FearThisSpot(Actor ASpot);
event PrepareForMove(NavigationPoint Goal, ReachSpec Path);
function WaitForMover(Mover M);
function MoverFinished();
function UnderLift(Mover M);


//#ifndef R6CODE
//event float Desireability(Pickup P)
//{
//	return P.BotDesireability(Pawn);
//}
//#endif // #ifndef R6CODE

// #ifdef R6NOISE
event HearNoise( float Loudness, Actor NoiseMaker, ENoiseType eType, optional ESoundType ESoundType);
// #else
// event HearNoise( float Loudness, Actor NoiseMaker );
// #endif // #ifdef R6NOISE

event SeePlayer( Pawn Seen );	// called when a player (bIsPlayer==true) pawn is seen
event SeeMonster( Pawn Seen );	// called when a non-player (bIsPlayer==false) pawn is seen
event EnemyNotVisible();

function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime);

function eAttitude AttitudeTo(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		return AttitudeToPlayer;
	else
		return ATTITUDE_Ignore;
}

/*R6CHANGEWEAPONSYSTEM
function float AdjustDesireFor(Pickup P);
*/
function bool FireWeaponAt(Actor A);
 
function StopFiring()
{
	bFire = 0;
	bAltFire = 0;
}

/*R6CHANGEWEAPONSYSTEM
function float WeaponPreference(Weapon W);
*/

/* AdjustAim()
AIController version does adjustment for non-controlled pawns. 
PlayerController version does the adjustment for player aiming help.
Only adjusts aiming at pawns
allows more error in Z direction (full as defined by AutoAim - only half that difference for XY)
CHANGENOTE: This function change is related to the Weapon code updates
*/
/*R6CHANGEWEAPONSYSTEM
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	return Rotation;
}
*/
/* ReceiveWarning()  *** CHANGENOTE: RENAMED (WAS WARNTARGET())***
 AI controlled creatures may duck
 if not falling, and projectile time is long enough
 often pick opposite to current direction (relative to shooter axis)
*/
function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
}

function bool CheckFutureSight(float DeltaTime)
{
	return true;
}

function ServerReStartPlayer()
{
}

event MonitoredPawnAlert();

function StartMonitoring(Pawn P, float MaxDist)
{
	MonitoredPawn = P;
	MonitorStartLoc = P.Location;
	MonitorMaxDistSq = MaxDist * MaxDist;
}

// **********************************************
// Controller States

State Dead
{
ignores SeePlayer, HearNoise, KilledBy;

	function PawnDied() {}

	function ServerReStartPlayer()
	{
		//log("calling restartplayer in dying with netmode "$Level.NetMode);
		if ( Level.NetMode == NM_Client )
			return;
		Level.Game.RestartPlayer(self);
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, ReceiveWarning;

	function BeginState()
	{
		if ( Pawn != None )
		{
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			Pawn.SimAnim.AnimRate = 0;
			Pawn.SetCollision(false,false,false);
			Pawn.Velocity = vect(0,0,0);
			Pawn.SetPhysics(PHYS_None);
			Pawn.UnPossessed();
		}
		if ( !bIsPlayer )
			Destroy();
	}
}

//R6CODE
simulated function R6DamageAttitudeTo(Pawn other, eKillResult eKillFromTable, eStunResult eStunFromTable, vector vBulletMomentum);
function PlaySoundDamage(Pawn instigatedBy);
function PlaySoundInflictedDamage(Pawn DeadPawn);
function PlaySoundCurrentAction(Pawn.ERainbowTeamVoices eVoices);
function PlaySoundAffectedByGrenade(Pawn.EGrenadeType eType);
function SetWeaponSound(R6PawnReplicationInfo PawnRepInfo, string szCurrentWeaponTxt, BYTE u8CurrentWepon);

//End R6CODE

defaultproperties
{
     AttitudeToPlayer=ATTITUDE_Hate
     m_bHideReticule=True
     FovAngle=90.000000
     MinHitWall=-1.000000
     PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
     bHidden=True
     bHiddenEd=True
}
