//=============================================================================
// Pawn, the base class of all actors that can be controlled by players or AI.
//
// Pawns are the physical representations of players and creatures in a level.  
// Pawns have a mesh, collision, and physics.  Pawns can take damage, make sounds, 
// and hold weapons and other inventory.  In short, they are responsible for all 
// physical interaction between the player or AI and the world.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Pawn extends Actor 
	abstract
	native
	placeable
	nativereplication;

#exec Texture Import File=Textures\Pawn.pcx Name=S_Pawn Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Pawn variables.

var Controller Controller;

// Physics related flags.
var bool		bJustLanded;		// used by eyeheight adjustment
var bool		bUpAndOut;			// used by swimming 
var bool		bIsWalking;			// currently walking (can't jump, affects animations)
var bool		bWarping;			// Set when travelling through warpzone (so shouldn't telefrag)
var bool		bWantsToCrouch;		// if true crouched (physics will automatically reduce collision height to CrouchHeight)
var const bool  bIsCrouched;		// set by physics to specify that pawn is currently crouched
var const bool  bTryToUncrouch;		// when auto-crouch during movement, continually try to uncrouch
var() bool		bCanCrouch;			// if true, this pawn is capable of crouching

// #ifdef R6CODE  - 24 jan 2002 rbrek - moved here for pathfinding
var	bool		m_bWantsToProne;
var const bool  m_bIsProne;     
var const bool  m_bTryToUnProne;
var() bool		m_bCanProne;
// #endif
      
var bool		bCrawler;			// crawling - pitch and roll based on surface pawn is on
var const bool	bReducedSpeed;		// used by movement natives
var	bool		bCanJump;			// movement capabilities - used by AI
var	bool 		bCanWalk;
var	bool		bCanSwim;
var	bool		bCanFly;
var	bool		bCanClimbLadders;
var	bool		bCanStrafe;
var	bool		bAvoidLedges;		// don't get too close to ledges
var	bool		bStopAtLedges;		// if bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
var	bool		bNoJumpAdjust;		// set to tell controller not to modify velocity of a jump/fall	
var	bool		bCountJumps;		// if true, inventory wants message whenever this pawn jumps
var const bool	bSimulateGravity;	// simulate gravity for this pawn on network clients when predicting position (true if pawn is walking or falling)
//R6CODE var	bool		bUpdateEyeheight;	// if true, UpdateEyeheight will get called every tick
var	bool		bIgnoreForces;		// if true, not affected by external forces
var const bool	bNoVelocityUpdate;	// used by C++ physics
var	bool		bCanWalkOffLedges;	// Can still fall off ledges, even when walking (for Player Controlled pawns)
var bool		bSteadyFiring;		// used for third person weapon anims/effects
var bool		bCanBeBaseForPawns;	// all your 'base', are belong to us

// used by dead pawns (for bodies landing and changing collision box)
var		bool	bThumped;		
var		bool	bInvulnerableBody;

// AI related flags
var		bool	bIsFemale;
var		bool	bAutoActivate;			// if true, automatically activate Powerups which have their bAutoActivate==true
/*R6CHANGEWEAPONSYSTEM
var		bool	bCanPickupInventory;	// if true, will pickup inventory when touching pickup actors
*/
var		bool	bUpdatingDisplay;		// to avoid infinite recursion through inventory setdisplay
var		bool	bAmbientCreature;		// AIs will ignore me
var(AI) bool	bLOSHearing;			// can hear sounds from line-of-sight sources (which are close enough to hear)
										// bLOSHearing=true is like UT/Unreal hearing
var(AI) bool	bSameZoneHearing;		// can hear any sound in same zone (if close enough to hear)
var(AI) bool	bAdjacentZoneHearing;	// can hear any sound in adjacent zone (if close enough to hear)
var(AI) bool	bMuffledHearing;		// can hear sounds through walls (but muffled - sound distance increased to double plus 4x the distance through walls
var(AI) bool	bAroundCornerHearing;	// Hear sounds around one corner (slightly more expensive, and bLOSHearing must also be true)
var(AI) bool	bDontPossess;			// if true, Pawn won't be possessed at game start
var		bool	bAutoFire;				// used for third person weapon anims/effects
var		bool	bRollToDesired;			// Update roll when turning to desired rotation (normally false)
var		bool	bIgnorePlayFiring;		// if true, ignore the next PlayFiring() call (used by AnimNotify_FireWeapon)
//R6ARMPATCHES
var     bool    m_bArmPatchSet;         // if false, ArmPatch is the default one

//UT2K3
// cache net relevancy test
var		bool	bCachedRelevant;		// network relevancy caching flag
var     float   m_fFallingHeight;
var     float   NetRelevancyTime;
var     PlayerController LastRealViewer;
var     actor   LastViewer;
var		bool	bUseCompressedPosition;	// use compressed position in networking - true unless want to replicate roll, or very high velocities

var		byte	FlashCount;				// used for third person weapon anims/effects
// AI basics.
var 	byte	Visibility;			//How visible is the pawn? 0=invisible, 128=normal, 255=highly visible 
var		float	DesiredSpeed;
var		float	MaxDesiredSpeed;
var(AI) name	AIScriptTag;		// tag of AIScript which should be associated with this pawn
//#ifndef R6NOISE
//var(AI) float	HearingThreshold;	// max distance at which a makenoise(1.0) loudness sound can be heard
//#endif // #ifndef R6NOISE
var(AI)	float	Alertness;			// -1 to 1 ->Used within specific states for varying reaction to stimuli 
var(AI)	float	SightRadius;		// Maximum seeing distance.
var(AI)	float	PeripheralVision;	// Cosine of limits of peripheral vision.
var()	float	SkillModifier;			// skill modifier (same scale as game difficulty)	
var const float	AvgPhysicsTime;		// Physics updating time monitoring (for AI monitoring reaching destinations)
var		float	MeleeRange;			// Max range for melee attack (not including collision radii)
var NavigationPoint Anchor;			// current nearest path;
var		float	DestinationOffset;	// used to vary destination over NavigationPoints
var		float	NextPathRadius;		// radius of next path in route
var		vector	SerpentineDir;		// serpentine direction
var		float	SerpentineDist;
var		float	SerpentineTime;		// how long to stay straight before strafing again
var const float	UncrouchTime;		// when auto-crouch during movement, continually try to uncrouch once this decrements to zero

// Movement.
var float   GroundSpeed;    // The maximum ground speed.
var float   WaterSpeed;     // The maximum swimming speed.
var float   AirSpeed;		// The maximum flying speed.
var float	LadderSpeed;	// Ladder climbing speed
var float	AccelRate;		// max acceleration rate
var float	JumpZ;      	// vertical acceleration w/ jump
var float   AirControl;		// amount of AirControl available to the pawn
var float	WalkingPct;		// pct. of running speed that walking speed is
var float	CrouchedPct;	// pct. of running speed that crouched walking speed is
var float	MaxFallSpeed;	// max speed pawn can land without taking damage (also limits what paths AI can use)
var vector	ConstantAcceleration;	// acceleration added to pawn when falling

// Player info.
var	string			OwnerName;		// Name of owning player (for save games, coop)
/*R6CHANGEWEAPONSYSTEM
var travel Weapon       Weapon;        // The pawn's current weapon.
//var Weapon				PendingWeapon;	// Will become weapon once current weapon is put down
*/
//#ifdef R6CHANGEWEAPONSYSTEM
var     R6EngineWeapon EngineWeapon;    //Current weapon the character is using
var     R6EngineWeapon PendingWeapon;	// Will become weapon once current weapon is put down
var     R6EngineWeapon m_WeaponsCarried[4]; // Weapons carried by the character, max 4 (primary, handgun, 2 types of grenades)
var     BOOL           m_bDroppedWeapon;

var     BOOL           m_bHaveGasMask;        
var     BOOL           m_bUseHighStance;// Character is using high stance when holding his weapon.
var     BOOL           m_bWantsHighStance;  // Character want to use HighStance
//#endif R6CHANGEWEAPONSYSTEM

/*R6CHANGEWEAPONSYSTEM
var travel Powerups	SelectedItem;	// currently selected inventory item
*/
//R6CODE var float      	BaseEyeHeight; 	// Base eye height above collision center.
//R6CODE var float        	EyeHeight;     	// Current eye height, adjusted for bobbing and stairs.
var	const vector	Floor;			// Normal of floor pawn is standing on (only used by PHYS_Spider and PHYS_Walking)
var float			SplashTime;		// time of last splash
var float			CrouchHeight;	// CollisionHeight when crouching
var float			CrouchRadius;	// CollisionRadius when crouching
//R6CODE var float			OldZ;			// Old Z Location - used for eyeheight smoothing
var PhysicsVolume	HeadVolume;		// physics volume of head
var travel int      Health;         // Health: 100 = normal maximum
var	float			BreathTime;		// used for getting BreathTimer() messages (for no air, etc.)
var float			UnderWaterTime; // how much time pawn can go without air (in seconds)

// #ifdef R6CODE  - 24 jan 2002 rbrek - moved here for pathfinding
var float           m_fProneHeight; // height of collision cylinder when prone
var float           m_fProneRadius; // radius of collision cylinder when prone
var BOOL            m_bTurnRight;   // When the player turn left
var BOOL            m_bTurnLeft;    // When the player turn right
//#ifdef R6CODE
var const vector	m_vLastNetLocation;	// Last location received by the network.  Used to set the correct location of a pawn when he stop (Velocity=0)
//#endif // #ifdef R6CODE

// #endif



// Sound and noise management
// remember location and position of last noises propagated
//#ifndef R6NOISE
//var const 	vector 		noise1spot;
//var const 	float 		noise1time;
//var const	pawn		noise1other;
//var const	float		noise1loudness;
//var const 	vector 		noise2spot;
//var const 	float 		noise2time;
//var const	pawn		noise2other;
//var const	float		noise2loudness;
//#else  // #ifdef R6NOISE
var const   vector      noiseSpot;
var const   float       noiseTime;
var const   float       noiseLoudness;
var const   ENoiseType  noiseType;
var         FLOAT       m_NextBulletImpact;
var         FLOAT       m_NextFireSound;
//#endif // #ifdef R6NOISE
var			float		LastPainSound;

// view bob
//#ifndef R6CODE
//var				globalconfig float Bob;
//#else
var				float Bob;
//#endif // #ifndef R6CODE
var				float				LandBob, AppliedBob;
var				float bobtime;
var				vector			WalkBob;

var float SoundDampening;
var float DamageScaling;

var localized  string MenuName; // Name used for this pawn type in menus (e.g. player selection) 

// shadow decal
//R6SHADOW var Projector Shadow;

// blood effect
var class<Effects> BloodEffect;
var class<Effects> LowDetailBlood;
var class<Effects> LowGoreBlood;

var class<AIController> ControllerClass;	// default class to use when pawn is controlled by AI (can be modified by an AIScript)

var float CarcassCollisionHeight;	// collision height of dead body lying on the ground
var PlayerReplicationInfo PlayerReplicationInfo;

var LadderVolume OnLadder;		// ladder currently being climbed

var name LandMovementState;		// PlayerControllerState to use when moving on land or air
var name WaterMovementState;	// PlayerControllerState to use when moving in water

// Animation status
var name AnimStatus;
var name AnimAction;			// use for replicating anims 

// Animation updating by physics FIXME - this should be handled as an animation object
// Note that animation channels 2 through 11 are used for animation updating
var vector TakeHitLocation;		// location of last hit (for playing hit/death anims)
var vector TearOffMomentum;		// momentum to apply when torn off (bTearOff == true)
var bool bPhysicsAnimUpdate;	
var bool bWasProne;				// r6code - rbrek 9 jan 2002
var bool bWasCrouched;
var bool bWasWalking;
var bool bWasOnGround;
var bool bInitializeAnimation;
var bool bPlayedDeath;
var	bool m_bIsLanding;			// r6code - rbrek 23 jan 2002 
//R6CODE+
var Bool m_bMakesTrailsWhenProning;
//R6CODE-
var EPhysics OldPhysics;
var float OldRotYaw;			// used for determining if pawn is turning
var vector OldAcceleration;
var float BaseMovementRate;		// FIXME - temp - used for scaling movement
var name MovementAnims[4];		// Forward, Back, Left, Right
//#ifdef R6CODE	// rbrek 18 april 2002 - this is to replace the old MovementAnimRate[]; need something to indicate that anim must be played backward
var byte AnimPlayBackward[4];	
//#endif
var name TurnLeftAnim;
var name TurnRightAnim;			// turning anims when standing in place (scaled by turn speed)
var(AnimTweaks) float BlendChangeTime;	// time to blend between movement animations
var float MovementBlendStartTime;	// used for delaying the start of run blending
var float ForwardStrafeBias;	// bias of strafe blending in forward direction
var float BackwardStrafeBias;	// bias of strafe blending in backward direction


// #ifdef R6CODE
var material m_HitMaterial;     // Use when we do a line check for the footstep. Use also for the sound.

var					vector			m_vEyeLocation;
var					rotator			m_rRotationOffset;		// rotation offset (with respect to pawn.rotation)
//var					rotator			m_rRepRotationOffset;

var                 INT             m_iIsInStairVolume;
// peeking
var                 FLOAT           m_fCrouchBlendRate;
var                 BOOL            m_bPeekingLeft;
var enum ePeekingMode
{
    PEEK_none,
    PEEK_full,
    PEEK_fluid
} m_ePeekingMode;


var					BYTE			m_bIsFiringWeapon;
// #endif

//R6HEARTBEAT
//var                 R6BasicHBLocation m_BasicHBLocation;
var                 EPawnType       m_ePawnType;            // Type of pawn.  Possibility are PAWN_Rainbow, PAWN_Terrorist
                                                            //           and PAWN_Hostage (hostage include civilian)
var BOOL		m_bHBJammerOn;			    // Only for the Heart Beat Jammer. Because it a gun and not a object spwan i use that in the basic location
var BOOL		m_bUseSpecialSkin;
//var             R6BasicRadarLocation m_BasicRadarLocation;
var float       m_fHeartBeatTime[2];        // Heart Beat time in ms, one for each cicle
var float       m_fHeartBeatFrequency;      // Number of heart beat by minutes.
var int         m_iNoCircleBeat;            // Current circle to be start display

var texture m_pHeartBeatTexture;    // Texture use for the heart beat sensor
var                 INT m_iTeam;	 // In which team the R6Pawn is
var                 INT m_iDefaultTeam;

// these bitflags is for the isfriendly mechanism, all other teams are neutral
var                 INT m_iFriendlyTeams;   // all teams we are friendly towards
var                 INT m_iEnemyTeams;      // all teams we are hostile towards

//#ifdef R6CODE
var INT m_iExtentX0;    // Extend of last Add to the hash, for debug
var INT m_iExtentY0;
var INT m_iExtentZ0;
var INT m_iExtentX1;
var INT m_iExtentY1;
var INT m_iExtentZ1;
//#endif // #ifdef R6CODE

//R6CODE
var string m_CharacterName;        //Name of the character
var BOOL m_bIsDeadBody;
var BOOL m_bAnimStopedForRG;       // Stop animation on a ragdoll, but after the first frame
var BOOL m_bIsPlayer;              // this will accurately indicate whether this pawn is a player or not

var class<StaticMeshActor>			m_HelmetClass;

var FLOAT m_fBlurValue;
var FLOAT m_fDecrementalBlurValue;
var FLOAT m_fRepDecrementalBlurValue;

//R6CODE
enum EGrenadeType
{
    GTYPE_None,
    GTYPE_Smoke,
    GTYPE_TearGas,
    GTYPE_FlashBang,
	GTYPE_BreachingCharge
};

enum eGrenadeThrow
{
    GRENADE_None,
    GRENADE_Throw,
    GRENADE_Roll,
    GRENADE_RemovePin,
    GRENADE_PeekLeft,
    GRENADE_PeekRight,
	GRENADE_PeekLeftThrow,
	GRENADE_PeekRightThrow
};

enum EAnimStateType
{
    SA_Generic,
    SA_Walk,
    SA_Run,
    SA_Turn,
    SA_CrouchToProne,
    SA_ProneToCrouch,
    SA_ProneWalk,
    SA_ProneSideWalk,
    SA_StairUp,
    SA_StairDown,
    SA_LadderHands,
    SA_LadderFoot,
    SA_LameWalkSlide,
    SA_Land,
    SA_DeadFall,
    SA_LameWalkLegOK
};

enum EGunSoundType
{
    GS_ExteriorStereo,
    GS_InteriorStereo,
    GS_ExteriorMono,
    GS_InteriorMono
};

enum ETerroristVoices
{
    TV_Wounded,
    TV_Taunt,
    TV_Surrender,
    TV_SeesTearGas,
    TV_RunAway,
    TV_Grenade,
    TV_CoughsSmoke,
    TV_CoughsGas,
    TV_Backup,
    TV_SeesSurrenderedHostage,
    TV_SeesRainbow_LowAlert,
    TV_SeesRainbow_HighAlert,
    TV_SeesFreeHostage,
    TV_HearsNoize
};

enum EHostageVoices
{
    HV_Run,
    HV_Frozen,
    HV_Foetal,
    HV_Hears_Shooting,
    HV_RnbFollow,
    HV_RndStayPut,
    HV_RnbHurt,
    HV_EntersSmoke,
    HV_EntersGas,
    HV_ClarkReprimand
};

enum ECommonRainbowVoices
{
    CRV_TerroristDown,
    CRV_TakeWound,
    CRV_GoesDown,
    CRV_EntersSmoke,
    CRV_EntersGas,
    CRV_Cough,
    CRV_Suffocation
};

enum ERainbowPlayerVoices
{
    RPV_TeamRegroup,
    RPV_TeamMove,
    RPV_TeamHold,
    RPV_AllTeamsHold,
    RPV_AllTeamsMove,
    RPV_TeamMoveAndFrag,
    RPV_TeamMoveAndGas,
    RPV_TeamMoveAndSmoke,
    RPV_TeamMoveAndFlash,
    RPV_TeamOpenDoor,
    RPV_TeamCloseDoor,
	RPV_TeamOpenShudder,
	RPV_TeamCloseShudder,
    RPV_TeamOpenAndClear,
    RPV_TeamOpenAndFrag,
    RPV_TeamOpenAndGas,
    RPV_TeamOpenAndSmoke,
    RPV_TeamOpenAndFlash,
    RPV_TeamOpenFragAndClear,
    RPV_TeamOpenGasAndClear,
    RPV_TeamOpenSmokeAndClear,
    RPV_TeamOpenFlashAndClear,
    RPV_TeamFragAndClear,
    RPV_TeamGasAndClear,
    RPV_TeamSmokeAndClear,
    RPV_TeamFlashAndClear,
    RPV_TeamUseLadder,
    RPV_TeamSecureTerrorist,
    RPV_TeamGoGetHostage,
    RPV_TeamHostageStayPut,
    RPV_TeamStatusReport,
    RPV_TeamUseElectronic,
    RPV_TeamUseDemolition,
    RPV_AlphaGoCode,
    RPV_BravoGoCode,
    RPV_CharlieGoCode,
    RPV_ZuluGoCode,
    RPV_OrderTeamWithGoCode,
    RPV_HostageFollow,
    RPV_HostageStay,
    RPV_HostageSafe,
    RPV_HostageSecured,
    RPV_MemberDown,
    RPV_SniperFree,
    RPV_SniperHold
};

enum ERainbowMembersVoices
{
    RMV_Contact,
    RMV_ContactRear,
    RMV_ContactAndEngages,
    RMV_ContactRearAndEngages,
    RMV_TeamRegroupOnLead,
    RMV_TeamReformOnLead,
    RMV_TeamReceiveOrder,
    RMV_TeamOrderFromLeadNil,
    RMV_NoMoreFrag,
    RMV_NoMoreSmoke,
    RMV_NoMoreGas,
    RMV_NoMoreFlash,
    RMV_OnLadder,
    RMV_MemberDown,
    RMV_AmmoOut,
    RMV_FragNear,
    RMV_EntersGasCloud,
    RMV_TakingFire,
    RMV_TeamHoldUp,
    RMV_TeamMoveOut,
    RMV_HostageFollow,
    RMV_HostageStay,
    RMV_HostageSafe,
    RMV_HostageSecured,
    RMV_RainbowHitRainbow,
    RMV_RainbowHitHostage,
    RMV_DoorReform
};

enum ERainbowOtherTeamVoices
{
    ROTV_SniperHasTarget,
    ROTV_SniperLooseTarget,
    ROTV_SniperTangoDown,
    ROTV_MemberDown,
    ROTV_RainbowHitRainbow,
    ROTV_Objective1,
    ROTV_Objective2,
    ROTV_Objective3,
    ROTV_Objective4,
    ROTV_Objective5,
    ROTV_Objective6,
    ROTV_Objective7,
    ROTV_Objective8,
    ROTV_Objective9,
    ROTV_Objective10,
    ROTV_WaitAlpha,
    ROTV_WaitBravo,
    ROTV_WaitCharlie,
    ROTV_WaitZulu,
    ROTV_EntersSmoke,
    ROTV_EntersGas,
    ROTV_StatusEngaging,
    ROTV_StatusMoving,
    ROTV_StatusWaiting,
    ROTV_StatusWaitAlpha,
    ROTV_StatusWaitBravo,
    ROTV_StatusWaitCharlie,
    ROTV_StatusWaitZulu,
    ROTV_StatusSniperWaitAlpha,
    ROTV_StatusSniperWaitBravo,
    ROTV_StatusSniperWaitCharlie,
    ROTV_StatusSniperUntilAlpha,
    ROTV_StatusSniperUntilBravo,
    ROTV_StatusSniperUntilCharlie
};

enum EPreRecordedMsgVoices
{
    PRMV_NeedBackup,
    PRMV_FollowMe,
    PRMV_CoverArea,
    PRMV_MoveOut,
    PRMV_CoverMe,
    PRMV_Retreat,
    PRMV_ReformOnMe,
    PRMV_Charge,
    PRMV_HoldPosition,
    PRMV_SecureArea,
    PRMV_WaitingOrders,
    PRMV_Assauting,
    PRMV_Defending,
    PRMV_EscortingCargo,
    PRMV_ObjectiveComplete,
    PRMV_ObjectiveReached,
    PRMV_Covering,
    PRMV_WeaponDry,
    PRMV_Move,
    PRMV_Roger,
    PRMV_Negative,
    PRMV_TakingFire,
    PRMV_PinnedDown,
    PRMV_TangoSpotted,
    PRMV_TangoDown,
    PRMV_StatusReport,
    PRMV_Clear
};

enum EMultiCommonVoices
{
    MCV_FragThrow,
    MCV_FlashThrow,
    MCV_GasThrow,
    MCV_SmokeThrow,
    MCV_ActivatingBomb,
    MCV_BombActivated,
    MCV_DeactivatingBomb,
    MCV_BombDeactivated
};

enum ERainbowTeamVoices
{
    RTV_PlacingBug,
    RTV_BugActivated,
    RTV_AccessingComputer,
    RTV_ComputerHacked,
    RTV_EscortingHostage,
    RTV_HostageSecured,
    RTV_PlacingExplosives,
    RTV_ExplosivesReady,
    RTV_DesactivatingSecurity,
    RTV_SecurityDeactivated,
    RTV_GasThreat,
    RTV_GrenadeThreat

};

//UT2K3
var transient CompressedPosition PawnPosition;

// Grenade effect
var         EGrenadeType        m_eEffectiveGrenade;
var         FLOAT               m_fRemainingGrenadeTime;
var			vector				m_vGrenadeLocation;
// Flashbang visual effect
var         BOOL                m_bFlashBangVisualEffectRequested;
var         FLOAT               m_fFlashBangVisualEffectTime;
var			FLOAT				m_fXFlashBang;
var			FLOAT				m_fYFlashBang;
var			FLOAT				m_fDistanceFlashBang;

var         Sound               m_sndHBSSound;
var         Sound               m_sndHearToneSound;
var         Sound               m_sndHearToneSoundStop;

var         eGrenadeThrow       m_eGrenadeThrow;        // Throw or roll the grenade (anims)
var         eGrenadeThrow       m_eRepGrenadeThrow;     // SPECIAL replication purposes see Aristo or Serge for info
var         BOOL                m_bRepFinishShotgun;

// END R6CODE

// Prone trail
var         INT                 m_iProneTrailPtr;

var enum eHealth
{
    HEALTH_Healthy,
    HEALTH_Wounded,
    HEALTH_Incapacitated,
    HEALTH_Dead
} m_eHealth;

//R6ARMPATCHES
var                 Guid                    m_ArmPatchGUID;
var                 Texture                 m_ArmPatchTexture;

//R6CODE
var                 INT                     m_iCurrentFloor;
var                 FLOAT                   m_fLastCommunicationTime;   // last time player sent a voice message for in-game map

//#ifdef R6CODE
var					FLOAT					m_fPrePivotPawnInitialOffset;
//#endif

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		m_iTeam,m_iFriendlyTeams,m_iEnemyTeams,OnLadder,
        m_WeaponsCarried,bSimulateGravity, bIsCrouched, m_bIsProne, bIsWalking, 
        PlayerReplicationInfo, Controller, AnimStatus, AnimAction,
        TakeHitLocation, m_bWantsHighStance, m_eHealth, m_eRepGrenadeThrow,
        m_ArmPatchGUID, m_bHaveGasMask, m_bHBJammerOn;

    unreliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
		 GroundSpeed, WaterSpeed, AirSpeed, AccelRate, JumpZ, AirControl, Health;

    unreliable if (bNetDirty && (!bNetOwner && (Role==ROLE_Authority)))
        EngineWeapon,PendingWeapon,bSteadyFiring;

    unreliable if (Role==ROLE_Authority)
        m_bIsPlayer, m_fFallingHeight;

    unreliable if (!bNetOwner && (Role==ROLE_Authority))
        m_bPeekingLeft, m_ePeekingMode, m_fCrouchBlendRate;
    
    unreliable if (!bNetOwner && (Role==ROLE_Authority) && m_bIsPlayer)
        m_bRepFinishShotgun, m_rRotationOffset;
       
    // insure that data is rep from owner of this pawn to the server || server sends the data to the non owners of this pawn
    unreliable if ((bNetOwner && (Role<ROLE_Authority)) || (!bNetOwner && (Role==ROLE_Authority)))
		m_bIsFiringWeapon, m_bTurnRight, m_bTurnLeft;

	reliable if( (bTearOff||m_bUseRagdoll) && bNetDirty && (Role==ROLE_Authority) )
		TearOffMomentum;
    
	// replicated functions sent to server by owning client
	reliable if( Role<ROLE_Authority )
		ServerChangedWeapon,ServerFinishShotgunAnimation;

    // R6CODE
	reliable if( Role == ROLE_Authority )
        m_fRepDecrementalBlurValue;

    // UT2K3
    unreliable if ( !bNetOwner && Role==ROLE_Authority )
		PawnPosition;
}

//R6BLOOD
simulated event R6DeadEndedMoving();
simulated event StopAnimForRG();

native function bool ReachedDestination(Actor Goal);

//R6IsFriend
native function bool IsFriend(  Pawn aPawn );
native function bool IsEnemy(   Pawn aPawn );
native function bool IsNeutral( Pawn aPawn );
native function bool IsAlive();

//#ifdef R6CHANGEWEAPONSYSTEM
simulated event ReceivedWeapons();
simulated event ReceivedEngineWeapon();
//#endif R6CHANGEWEAPONSYSTEM

//#ifdef R6CODE
function FLOAT GetPeekingRate();

simulated event PlayWeaponAnimation();

//For shotguns anims in MP
function ServerFinishShotgunAnimation()
{
    m_bRepFinishShotgun = !m_bRepFinishShotgun;
}


/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	if ( (Controller == None) || Controller.bIsPlayer )
		Destroy();
	else
		Super.Reset();
}

function String GetHumanReadableName()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.PlayerName;
	return MenuName;
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
	MakeNoise(1.0);
}

/* PossessedBy()
 Pawn is possessed by Controller
*/
function PossessedBy(Controller C)
{
	Controller = C;
	NetPriority = 3;

	if ( C.PlayerReplicationInfo != None )
	{
		PlayerReplicationInfo = C.PlayerReplicationInfo;
		OwnerName = PlayerReplicationInfo.PlayerName;
	}
	if ( C.IsA('PlayerController') )
	{
		if ( Level.NetMode != NM_Standalone )
			RemoteRole = ROLE_AutonomousProxy;
		BecomeViewTarget();

        //R6ARMPATCHES
        if(PlayerController(C).Player != none)
        {
            m_ArmPatchGUID = PlayerController(C).Player.m_ArmPatchGUID;
            m_bArmPatchSet = false;
        }
	}
	else
		RemoteRole = Default.RemoteRole;

	SetOwner(Controller);	// for network replication
//R6CODE	Eyeheight = BaseEyeHeight;
	ChangeAnimation();
}

function UnPossessed()
{
    //R6CODE+
    if(Level.NetMode != NM_Standalone && PlayerReplicationInfo != none)
        m_CharacterName = PlayerReplicationInfo.PlayerName;
    
	//PlayerReplicationInfo = None;
    //R6CODE-
	SetOwner(None);
	Controller = None;
}

/* PointOfView()
called by controller when possessing this pawn
false = 1st person, true = 3rd person
*/
simulated function bool PointOfView()
{
	return false;
}

function BecomeViewTarget()
{
// R6CODE	bUpdateEyeHeight = true;
}

function DropToGround()
{
	bCollideWorld = True;
	bInterpolating = false;
	if ( Health > 0 )
	{
		SetCollision(true,true,true);
		SetPhysics(PHYS_Falling);
		AmbientSound = None;
		if ( IsHumanControlled() )
			Controller.GotoState(LandMovementState);
	}
}

function bool CanGrabLadder()
{
	return ( bCanClimbLadders 
			&& (Controller != None)
			&& (Physics != PHYS_Ladder)
			&& ((Physics != Phys_Falling) || (abs(Velocity.Z) <= JumpZ)) );
}

event SetWalking(bool bNewIsWalking)
{
	if ( bNewIsWalking != bIsWalking )
	{
		bIsWalking = bNewIsWalking;
		ChangeAnimation();
	}
}

function bool CanSplash()
{
	if ( (Level.TimeSeconds - SplashTime > 0.25)
		&& ((Physics == PHYS_Falling) || (Physics == PHYS_Flying))
		&& (Abs(Velocity.Z) > 100) )
	{
		SplashTime = Level.TimeSeconds;
		return true;
	}
	return false;
}

//#ifdef R6CODE
event EndClimbLadder(LadderVolume OldLadder)
//#else
//function EndClimbLadder(LadderVolume OldLadder)
//#endif // #ifdef R6CODE
{
	if ( Controller != None )
		Controller.EndClimbLadder();
	if ( Physics == PHYS_Ladder )
		SetPhysics(PHYS_Falling);
}

function ClimbLadder(LadderVolume L)
{
	OnLadder = L;
	SetRotation(OnLadder.WallDir);
	SetPhysics(PHYS_Ladder);
	if ( IsHumanControlled() )
		Controller.GotoState('PlayerClimbing');
}

/* DisplayDebug()
list important actor variable on canvas.  Also show the pawn's controller and weapon info
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);

	Canvas.DrawText("Animation Action "$AnimAction$" Status "$AnimStatus);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Anchor "$Anchor$" Serpentine Dist "$SerpentineDist$" Time "$SerpentineTime);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Floor "$Floor$" DesiredSpeed "$DesiredSpeed$" Crouched "$bIsCrouched$" Try to uncrouch "$UncrouchTime;
	if ( (OnLadder != None) || (Physics == PHYS_Ladder) )
		T=T$" on ladder "$OnLadder;
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);
//R6CODE	Canvas.DrawText("EyeHeight "$Eyeheight$" BaseEyeHeight "$BaseEyeHeight$" Physics Anim "$bPhysicsAnimUpdate);
//R6CODE	YPos += YL;
//R6CODE	Canvas.SetPos(4,YPos);

	if ( Controller == None )
	{
		Canvas.SetDrawColor(255,0,0);
		Canvas.DrawText("NO CONTROLLER");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		Controller.DisplayDebug(Canvas,YL,YPos);

/*R6CHANGEWEAPONSYSTEM
	if ( Weapon == None )
	{
		Canvas.SetDrawColor(0,255,0);
		Canvas.DrawText("NO WEAPON");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		Weapon.DisplayDebug(Canvas,YL,YPos);
R6CHANGEWEAPONSYSTEM*/
}
		 		
//
// Compute offset for drawing an inventory item.
//
/*R6CHANGEWEAPONSYSTEM
//simulated function vector CalcDrawOffset(inventory Inv)
//{
//    local vector DrawOffset;
//
//	if ( Controller == None )
//		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);
//
//	DrawOffset = ((0.9/Controller.FOVAngle * 100 * ModifiedPlayerViewOffset(Inv)) >> GetViewRotation() );
//	if ( !IsLocallyControlled() )
//		DrawOffset.Z += BaseEyeHeight;
//	else
//	{	
//		DrawOffset.Z += EyeHeight;
//		DrawOffset += WeaponBob(Inv.BobDamping);
//	}
//	return DrawOffset;
//}
//
//function vector ModifiedPlayerViewOffset(inventory Inv)
//{
//	return Inv.PlayerViewOffset;
//}
*/
function vector WeaponBob(float BobDamping)
{
	Local Vector WBob;

	WBob = BobDamping * WalkBob;
	WBob.Z = (0.45 + 0.55 * BobDamping) * WalkBob.Z;
	if ( PlayerController(Controller) != None )
		WBob += 0.9 * PlayerController(Controller).ShakeOffset;
	return WBob;
}

function CheckBob(float DeltaTime, vector Y)
{
	local float Speed2D;

	if (Physics == PHYS_Walking )
	{
		Speed2D = VSize(Velocity);
		if ( Speed2D < 10 )
			BobTime += 0.2 * DeltaTime;
		else
			BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
		WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
		AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
		WalkBob.Z = AppliedBob;
		if ( Speed2D > 10 )
			WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
		if ( LandBob > 0.01 )
		{
			AppliedBob += FMin(1, 16 * deltatime) * LandBob;
			LandBob *= (1 - 8*Deltatime);
		}
	}
	else if ( Physics == PHYS_Swimming )
	{
		Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
		WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
		WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
	}
	else
	{
		BobTime = 0;
		WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
	}
}

//***************************************
// Interface to Pawn's Controller

// return true if controlled by a Player (AI or human)
simulated function bool IsPlayerPawn()
{
	return ( (Controller != None) && Controller.bIsPlayer );
}

// return true if controlled by a real live human
simulated function bool IsHumanControlled()
{
	return ( PlayerController(Controller) != None );
}

// return true if controlled by local (not network) player
simulated function bool IsLocallyControlled()
{
	if ( Level.NetMode == NM_Standalone )
		return true;
	if ( Controller == None )
		return false;
	if ( PlayerController(Controller) == None )
		return true;

	return ( Viewport(PlayerController(Controller).Player) != None );
}

// rbrek 26 oct 2001
// #ifdef R6CODE - this function was converted to an event so that it can be called from the native 
//					code for SeePawn(), LineOfSightTo()...
// simulated function rotator GetViewRotation()
simulated event rotator GetViewRotation() 
{
	if ( Controller == None )
		return Rotation;
    else
		return Controller.GetViewRotation();
}

simulated function SetViewRotation(rotator NewRotation )
{
	if ( Controller != None )
		Controller.SetRotation(NewRotation);
}

final function bool InGodMode()
{
	return ( (Controller != None) && Controller.bGodMode );
}

function bool NearMoveTarget()
{
	if ( (Controller == None) || (Controller.MoveTarget == None) )
		return false;

	return ReachedDestination(Controller.MoveTarget);
}

simulated final function bool PressingFire()
{
	return ( (Controller != None) && (Controller.bFire != 0) );
}

simulated final function bool PressingAltFire()
{
	return ( (Controller != None) && (Controller.bAltFire != 0) );
}

function Actor GetMoveTarget()
{	
	if ( Controller == None )
		return None;

	return Controller.MoveTarget;
}

function SetMoveTarget(Actor NewTarget )
{
	if ( Controller != None )
		Controller.MoveTarget = NewTarget;
}

function bool LineOfSightTo(actor Other)
{
	return ( (Controller != None) && Controller.LineOfSightTo(Other) );
} 

/* CHANGENOTE: Changes in this function related to the Weapon code updates
*/
/*R6CHANGEWEAPONSYSTEM
simulated final function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	if ( Controller == None )
		return Rotation;

	return Controller.AdjustAim(FiredAmmunition, projStart, aimerror);
}
*/

/*R6CHANGEWEAPONSYSTEM
function HandlePickup(Pickup pick)
{
	MakeNoise(0.2);
	if ( Controller != None )
		Controller.HandlePickup(pick);
}
*/
function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if ( PlayerController(Controller) != None )
		PlayerController(Controller).ReceiveLocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

event ClientMessage( coerce string S, optional Name Type )
{
	if ( PlayerController(Controller) != None )
		PlayerController(Controller).ClientMessage( S, Type );
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( Controller != None )
		Controller.Trigger(Other, EventInstigator);
}

//***************************************

function bool CanTrigger(Trigger T)
{
	return true;
}

function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
	Style = NewStyle;
	Texture = NewTexture;
	bUnlit = bLighting;
/*R6CHANGEWEAPONSYSTEM
	if ( Weapon != None )
		Weapon.SetDisplayProperties(Style, Texture, bUnlit);

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
*/
	bUpdatingDisplay = false;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
/*R6CHANGEWEAPONSYSTEM
	if ( Weapon != None )
		Weapon.SetDefaultDisplayProperties();

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
*/
    bUpdatingDisplay = false;
}

function FinishedInterpolation()
{
	DropToGround();
}

function JumpOutOfWater(vector jumpDir)
{
	Falling();
	Velocity = jumpDir * WaterSpeed;
	Acceleration = jumpDir * AccelRate;
	velocity.Z = FMax(380,JumpZ); //set here so physics uses this for remainder of tick
	bUpAndOut = true;
}

event FellOutOfWorld()
{
	if ( Role < ROLE_Authority )
		return;
	Health = -1;
	SetPhysics(PHYS_None);
/*R6CHANGEWEAPONSYSTEM
	Weapon = None;
*/
}

/* ShouldCrouch()
Controller is requesting that pawn crouch
*/
function ShouldCrouch(bool Crouch)
{
	bWantsToCrouch = Crouch;
}

// Stub events called when physics actually allows crouch to begin or end
// use these for changing the animation (if script controlled)
event EndCrouch(float HeightAdjust)
{
//R6CODE	EyeHeight -= HeightAdjust;
//R6CODE	OldZ += HeightAdjust;
//R6CODE	BaseEyeHeight = Default.BaseEyeHeight;
}

event StartCrouch(float HeightAdjust)
{
//R6CODE    EyeHeight += HeightAdjust;
//R6CODE    OldZ -= HeightAdjust;
//R6CODE    BaseEyeHeight = 0.8 * CrouchHeight;
}

function RestartPlayer();
function AddVelocity( vector NewVelocity)
{
	if ( bIgnoreForces )
		return;
	if ( (Physics == PHYS_Walking)
		|| (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

function KilledBy( pawn EventInstigator )
{
	local Controller Killer;

	Health = 0;
	if ( EventInstigator != None )
		Killer = EventInstigator.Controller;
}

function TakeFallingDamage()
{
	local float Shake;

	if (Velocity.Z < -0.5 * MaxFallSpeed)
	{
		MakeNoise(FMin(2.0,-0.5 * Velocity.Z/(FMax(JumpZ, 150.0))));
		if ( Controller != None )
		{
			Shake = FMin(1, -1 * Velocity.Z/MaxFallSpeed);
			Controller.ShakeView(0.175 + 0.1 * Shake, 850 * Shake, Shake * vect(0,0,1.5), 120000, vect(0,0,10), 1);
		}
	}
}

function ClientReStart()
{
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
//R6CODE	BaseEyeHeight = Default.BaseEyeHeight;
//R6CODE	EyeHeight = BaseEyeHeight;
	PlayWaiting();
}

function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	if ( Controller != None )
		Controller.ClientSetLocation(NewLocation, NewRotation);
}

function ClientSetRotation( rotator NewRotation )
{
	if ( Controller != None )
		Controller.ClientSetRotation(NewRotation);
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	if ( Physics == PHYS_Ladder )
		SetRotation(OnLadder.Walldir);
	else
	{
		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
			NewRotation.Pitch = 0;
		SetRotation(NewRotation);
	}
}

function ClientDying(vector HitLocation)
{
	if ( Controller != None )
		Controller.ClientDying(HitLocation);
}

//=============================================================================
// Inventory related functions.

// The player/bot wants to select next item
#ifdefDEBUG
exec function NextItem()
{
/*R6CHANGEWEAPONSYSTEM
	if (SelectedItem==None) {
		SelectedItem = Inventory.SelectNext();
		Return;
	}
	if (SelectedItem.Inventory!=None)
		SelectedItem = SelectedItem.Inventory.SelectNext(); 
	else
		SelectedItem = Inventory.SelectNext();

	if ( SelectedItem == None )
		SelectedItem = Inventory.SelectNext();
*/
}
#endif

// FindInventoryType()
// returns the inventory item of the requested class
// if it exists in this pawn's inventory 

/*R6CHANGEWEAPONSYSTEM
function Inventory FindInventoryType( class DesiredClass )
{
	local Inventory Inv;

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )   
		if ( Inv.class == DesiredClass )
			return Inv;
    return None;
} 
*/

// Add Item to this pawn's inventory. 
// Returns true if successfully added, false if not.
/*R6CHANGEWEAPONSYSTEM
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	local actor Last;

	Last = self;
	
	// The item should not have been destroyed if we get here.
	if (NewItem ==None )
		log("tried to add none inventory to "$self);

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if( Inv == NewItem )
			return false;
		Last = Inv;
	}

	// Add to back of inventory chain (so minimizes net replication effect).
	NewItem.SetOwner(Self);
	NewItem.Inventory = None;
	Last.Inventory = NewItem;

	if ( Controller != None )
		Controller.NotifyAddInventory(NewItem);
	return true;
}

// Remove Item from this pawn's inventory, if it exists.
function DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;

	if ( Item == Weapon )
		Weapon = None;
	if ( Item == SelectedItem )
		SelectedItem = None;
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			break;
		}
	}
	Item.SetOwner(None);
}
*/

/*R6CHANGEWEAPONSYSTEM
function name GetWeaponBoneFor(Inventory I)
{
	return 'righthand';
}
*/

function ServerChangedWeapon(R6EngineWeapon OldWeapon, R6EngineWeapon W)
{
/*R6CHANGEWEAPONSYSTEM
	if ( OldWeapon != None )
	{
		OldWeapon.SetDefaultDisplayProperties();
		OldWeapon.DetachFromPawn(self);		
	}
	Weapon = W;
	if ( Weapon == None )
		return;

	if ( Weapon != None )
	{
		//log("ServerChangedWeapon: Attaching Weapon to actor bone.");
		Weapon.AttachToPawn(self);
	}

	Weapon.SetRelativeLocation(Weapon.Default.RelativeLocation);
	Weapon.SetRelativeRotation(Weapon.Default.RelativeRotation);
	if ( OldWeapon == Weapon )
	{
		if ( Weapon.IsInState('DownWeapon') ) 
			Weapon.BringUp();
		Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)
		return;
	}
	else if ( Level.Game != None )
		MakeNoise(0.1 * Level.Game.Difficulty);		
	Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)

	PlayWeaponSwitch(W);
	Weapon.BringUp();
*/
}

//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;
		
	if ( ((Controller == None) || !Controller.bIsPlayer || bWarping) && (Pawn(Other) != None) )
		return true;
		
	return false;
}

event EncroachedBy( actor Other )
{
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	Velocity += (100 + CollisionRadius) * VRand();
	Velocity.Z = 200 + CollisionHeight;
	SetPhysics(PHYS_Falling);
	bNoJumpAdjust = true;
	Controller.SetFall();
}

singular event BaseChange()
{
	local float decorMass;

	if ( bInterpolating )
		return;
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	else if ( Pawn(Base) != None )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns )
		{
			JumpOffPawn();
		}
	}
}

//R6CODE
//event UpdateEyeHeight( float DeltaTime )
//{
//	local float smooth;
//	local float OldEyeHeight;
//
//	if (Controller == None )
//	{
//		EyeHeight = 0;
//		return;
//	}
//
//	// smooth up/down stairs
//	smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
//	If( Controller.WantsSmoothedView() )
//	{
//		OldEyeHeight = EyeHeight;
//		EyeHeight = FClamp((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
//							-0.5 * CollisionHeight,
//							CollisionHeight + FClamp((OldZ - Location.Z), 0.0, MAXSTEPHEIGHT)); 
//	}
//	else
//	{
//		bJustLanded = false;
//		EyeHeight = EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth;
//	}
//	Controller.AdjustView(DeltaTime);
//}
//R6CODE

/* EyePosition()
Called by PlayerController to determine camera position in first person view.  Returns
the offset from the Pawn's location at which to place the camera
*/
// rbrek 26 oct 2001
// #ifdef R6CODE - this function was converted to an event so that it can be called from the native 
//					code for SeePawn(), LineOfSightTo()...
// function vector EyePosition()
event vector EyePosition()
{
//R6CODE	return EyeHeight * vect(0,0,1) + WalkBob;
	return WalkBob;
}

//=============================================================================

simulated event Destroyed()
{
//	local Inventory Inv,Next;

	if ( Shadow != None )
    {
		Shadow.Destroy();
        Shadow = none;
    }
	if ( Controller != None )
		Controller.PawnDied();
	if ( Role < ROLE_Authority )
		return;

/*R6CHANGEWEAPONSYSTEM
	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )   
		Inv.Destroy();
*/
//R6CHANGEWEAPONSYSTEM
    if (EngineWeapon!= none)
    {
        EngineWeapon.destroy();
	}	

    if (PendingWeapon!= none)
    {
        PendingWeapon.destroy();
    }

    EngineWeapon = None;
    PendingWeapon = None;
/*R6CHANGEWEAPONSYSTEM
	Inventory = None;
*/
	Super.Destroyed();
}

//=============================================================================
//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	Super.PreBeginPlay();
	Instigator = self;
	DesiredRotation = Rotation;
	if ( bDeleteMe )
		return;

//R6CODE	if ( BaseEyeHeight == 0 )
//R6CODE		BaseEyeHeight = 0.8 * CollisionHeight;
//R6CODE	EyeHeight = BaseEyeHeight;

	if ( menuname == "" )
		menuname = GetItemName(string(class));
}

event PostBeginPlay()
{
	local AIScript A;


	Super.PostBeginPlay();
	SplashTime = 0;
//R6CODE	EyeHeight = BaseEyeHeight;
	OldRotYaw = Rotation.Yaw;

	// automatically add controller to pawns which were placed in level
	// NOTE: pawns spawned during gameplay are not automatically possessed by a controller
	if ( Level.bStartup && (Health > 0) && !bDontPossess )
	{
		// check if I have an AI Script
		if ( (AIScriptTag != 'None') && (AIScriptTag != '') )
		{
			ForEach AllActors(class'AIScript',A,AIScriptTag)
				break;
			// let the AIScript spawn and init my controller
			if ( A != None )
			{
				A.SpawnControllerFor(self);
				if ( Controller != None )
					return;
			}
		}
		if ( (ControllerClass != None) && (Controller == None) )
			Controller = spawn(ControllerClass);
		if ( Controller != None )
		{
			Controller.Possess(self);
			AIController(Controller).Skill += SkillModifier;
		}
	}
}

// called after PostBeginPlay on net client
simulated event PostNetBeginPlay()
{
	if ( Role == ROLE_Authority )
		return;
	if ( Controller != None )
	{
		Controller.Pawn = self;
// R6CODE		bUpdateEyeHeight = true;
	} 

	if ( (PlayerReplicationInfo != None) 
		&& (PlayerReplicationInfo.Owner == None) )
		PlayerReplicationInfo.SetOwner(Controller);
	PlayWaiting();
}
	
simulated function SetMesh()
{
	LinkMesh( default.mesh );
}

function Gasp();
function SetMovementPhysics();

function Died(Controller Killer, vector HitLocation)
{
	if ( bDeleteMe )
		return; //already destroyed

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	Velocity.Z *= 1.3;
	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();
	PlayDying(HitLocation);
	if ( Level.Game.bGameEnded )
		return;
	if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
		ClientDying(HitLocation);
}

event Falling()
{
	//SetPhysics(PHYS_Falling); //Note - physics changes type to PHYS_Falling by default
	if ( Controller != None )
		Controller.SetFall();
}

event HitWall(vector HitNormal, actor Wall);

event Landed(vector HitNormal)
{
	LandBob = FMin(50, 0.055 * Velocity.Z); 
	TakeFallingDamage();
	if ( Health > 0 )
		PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
	bJustLanded = true;
}

event HeadVolumeChange(PhysicsVolume newHeadVolume)
{
	if ( (Level.NetMode == NM_Client) || (Controller == None) )
		return;
	if ( HeadVolume.bWaterVolume )
	{
		if (!newHeadVolume.bWaterVolume)
		{
			if ( Controller.bIsPlayer && (BreathTime > 0) && (BreathTime < 8) )
				Gasp();
			BreathTime = -1.0;
		}
	}
	else if ( newHeadVolume.bWaterVolume )
		BreathTime = UnderWaterTime;
}

function bool TouchingWaterVolume()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bWaterVolume )
			return true;
			
	return false;
}

//Pain timer just expired.
//Check what zone I'm in (and which parts are)
//based on that cause damage, and reset BreathTime

event BreathTimer()
{
	if ( (Health < 0) || (Level.NetMode == NM_Client) )
		return;
	TakeDrowningDamage();
	if ( Health > 0 )
		BreathTime = 2.0;
}

function TakeDrowningDamage();		

function bool CheckWaterJump(out vector WallNormal)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, checkpoint, start, checkNorm, Extent;

	checkpoint = vector(Rotation);
	checkpoint.Z = 0.0;
	checkNorm = Normal(checkpoint);
	checkPoint = Location + CollisionRadius * checkNorm;
	Extent = CollisionRadius * vect(1,1,0);
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, Extent);
	if ( (HitActor != None) && (Pawn(HitActor) == None) )
	{
		WallNormal = -1 * HitNormal;
		start = Location;
		start.Z += 1.1 * MAXSTEPHEIGHT;
		checkPoint = start + 2 * CollisionRadius * checkNorm;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true);
		if (HitActor == None)
			return true;
	}

	return false;
}

//Player Jumped
function DoJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
		if ( Role == ROLE_Authority )
		{
			if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
				MakeNoise(0.1 * Level.Game.Difficulty);
/*R6CHANGEWEAPONSYSTEM
			if ( bCountJumps && (Inventory != None) )
				Inventory.OwnerEvent('Jumped');
*/
		}
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != None) && !Base.bWorldGeometry )
			Velocity.Z += Base.Velocity.Z; 
		SetPhysics(PHYS_Falling);
	}
}

/* PlayMoverHitSound()
Mover Hit me, play appropriate sound if any
*/
function PlayMoverHitSound();

/*
Pawn was killed - detach any controller, and die
*/

// blow up into little pieces (implemented in subclass)
simulated function ChunkUp()
{
	if ( (Level.NetMode != NM_Client) && (Controller != None) )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied();
		else
			Controller.Destroy();
	}
	destroy();
}

State Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, name FiringMode) {}
	//function PlayWeaponSwitch(Weapon NewWeapon) {}
	simulated function PlayNextAnimation() {}

	function Died(Controller Killer, vector HitLocation)
	{
	}

	function Timer()
	{
		if ( !PlayerCanSeeMe() )
			Destroy();
		else
			SetTimer(2.0, false);	
	}

	function Landed(vector HitNormal)
	{
		local rotator finalRot;

		LandBob = FMin(50, 0.055 * Velocity.Z);

		finalRot = Rotation;
		finalRot.Roll = 0;
		finalRot.Pitch = 0;
		setRotation(finalRot);
		SetPhysics(PHYS_None);
		SetCollision(true, false, false);

		if ( !IsAnimating(0) )
			LieStill();
	}

	// prone body should have low height, wider radius
	function ReduceCylinder()
	{
		local float OldHeight, OldRadius;
		local vector OldLocation;

		SetCollision(True,False,False);
		OldHeight = CollisionHeight;
		OldRadius = CollisionRadius;
		SetCollisionSize(1.5 * Default.CollisionRadius, CarcassCollisionHeight);
		PrePivot = vect(0,0,1) * (OldHeight - CollisionHeight); // FIXME - changing prepivot isn't safe w/ static meshes
		OldLocation = Location;
		if ( !SetLocation(OldLocation - PrePivot) )
		{
			SetCollisionSize(OldRadius, CollisionHeight);
			if ( !SetLocation(OldLocation - PrePivot) )
			{
				SetCollisionSize(CollisionRadius, OldHeight);
				SetCollision(false, false, false);
				PrePivot = vect(0,0,0);
				if ( !SetLocation(OldLocation) )
					ChunkUp();
			}
		}
		PrePivot = PrePivot + vect(0,0,3);
	}

	function LandThump()
	{
		// animation notify - play sound if actually landed, and animation also shows it
		if ( Physics == PHYS_None)
			bThumped = true;
	}

	event AnimEnd(int Channel)
	{
		if ( Channel != 0 )
			return;
		if ( Physics == PHYS_None )
			LieStill();
		else if ( PhysicsVolume.bWaterVolume )
		{
			bThumped = true;
			LieStill();
		}
	}

	function LieStill()
	{
		if ( !bThumped )
			LandThump();
		if ( CollisionHeight != CarcassCollisionHeight )
			ReduceCylinder();
	}

	singular function BaseChange()
	{
		if( base == None )
			SetPhysics(PHYS_Falling);
		else if ( Pawn(base) != None )
			ChunkUp(); // don't let corpse ride around on someone's head
	}

	function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy,
							   vector vHitLocation, vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
	{
		return 0;
	}

	function BeginState()
	{		
		if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(12.0, false);
		SetPhysics(PHYS_Falling);
		bInvulnerableBody = true;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied();
			else
				Controller.Destroy();
		}
	}

Begin:
	Sleep(0.2);
	bInvulnerableBody = false;
}

//=============================================================================
// Animation interface for controllers

simulated event SetAnimAction(name NewAction);

/* SetAnimStatus()
Called by controller to set animation status (e.g. relaxed, alert, combat, etc.
*/
simulated function SetAnimStatus(name NewStatus)
{
	if ( NewStatus != AnimStatus )
	{
		// anim status change
		AnimStatus = NewStatus;
		ChangeAnimation();
	}
}

/* PlayXXX() function called by controller to play transient animation actions 
*/
simulated event PlayDying(vector HitLoc)
{
	GotoState('Dying');
	if ( bPhysicsAnimUpdate )
	{
		bReplicateMovement = false;
		bTearOff = true;
		Velocity += TearOffMomentum;
		SetPhysics(PHYS_Falling);
	}
	bPlayedDeath = true;
}

simulated function PlayFiring(float Rate, name FiringMode);
/*R6CHANGEWEAPONSYSTEM
function PlayWeaponSwitch(Weapon NewWeapon);
*/
simulated event StopPlayFiring()
{
	bSteadyFiring = false;
}

//=============================================================================
// Pawn internal animation functions

simulated event ChangeAnimation()
{
	if ( (Controller != None) && Controller.bControlAnimations )
		return;
	// player animation - set up new idle and moving animations
	PlayWaiting();
	PlayMoving();
}

simulated event AnimEnd(int Channel)
{
	if ( Channel == 0 )
		PlayWaiting();
}

// Animation group checks (usually implemented in subclass)

function bool CannotJumpNow()
{
	return false;
}

simulated event PlayJump();
simulated event PlayFalling();
simulated function PlayMoving();
simulated function PlayWaiting();

function PlayLanded(float impactVel)
{
	if ( !bPhysicsAnimUpdate )
		PlayLandingAnimation(impactvel);
}

simulated event PlayLandingAnimation(float ImpactVel);

defaultproperties
{
     Visibility=128
     Health=100
     bCanJump=True
     bCanWalk=True
     bLOSHearing=True
     bUseCompressedPosition=True
     m_bUseHighStance=True
     DesiredSpeed=1.000000
     MaxDesiredSpeed=1.000000
     SightRadius=5000.000000
     AvgPhysicsTime=0.100000
     GroundSpeed=600.000000
     WaterSpeed=300.000000
     AirSpeed=600.000000
     LadderSpeed=200.000000
     AccelRate=2048.000000
     JumpZ=420.000000
     AirControl=0.050000
     WalkingPct=0.500000
     CrouchedPct=0.500000
     MaxFallSpeed=1200.000000
     CrouchHeight=40.000000
     CrouchRadius=34.000000
     Bob=0.016000
     SoundDampening=1.000000
     DamageScaling=1.000000
     CarcassCollisionHeight=23.000000
     BaseMovementRate=525.000000
     BlendChangeTime=0.250000
     LandMovementState="PlayerWalking"
     WaterMovementState="PlayerSwimming"
     ControllerClass=Class'Engine.AIController'
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     bCanTeleport=True
     bOwnerNoSee=True
     bStasis=True
     bAcceptsProjectors=True
     bDisturbFluidSurface=True
     bUpdateSimulatedPosition=True
     bTravel=True
     bShouldBaseAtStartup=True
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bRotateToDesired=True
     bDirectional=True
     SoundRadius=9.000000
     TransientSoundVolume=2.000000
     CollisionRadius=34.000000
     CollisionHeight=78.000000
     NetPriority=2.000000
     Texture=Texture'Engine.S_Pawn'
     RotationRate=(Pitch=4096,Yaw=20000,Roll=3072)
}
