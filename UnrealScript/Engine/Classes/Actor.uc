//=============================================================================
// Actor: The base class of all actors.
// Actor is the base class of all gameplay objects.  
// A large number of properties, behaviors and interfaces are implemented in Actor, including:
//
// -	Display 
// -	Animation
// -	Physics and world interaction
// -	Making sounds
// -	Networking properties
// -	Actor creation and destruction
// -	Triggering and timers
// -	Actor iterator functions
// -	Message broadcasting
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Actor extends Object
	abstract
	native
	nativereplication;

// Imported data (during full rebuild).
#exec Texture Import File=Textures\S_Actor.pcx Name=S_Actor Mips=Off MASKED=1
#exec Texture Import File=Textures\S_LockLocation.pcx Name=S_LockLocation Mips=Off

//R6CODE
enum eKillResult
{
    KR_None,
    KR_Wound,
    KR_Incapacitate,
    KR_Killed,
};

enum eStunResult
{
    SR_None,
    SR_Stunned,
    SR_Dazed,
    SR_KnockedOut,
};

enum EStance
{
    STAN_None,
    STAN_Standing,
    STAN_Crouching,
    STAN_Prone
};

// see GetRandomTweenNum
struct RandomTweenNum
{
    var()   float m_fMin;
    var()   float m_fMax;
    var     float m_fResult; // result of the last GetRandomTweenNum
};  // if you modify this struct: update FRandomTweenNum in R6Engine.h


// we are using chars instead of bools since bools inside structs can not be properly serialized yet :(

//END R6CODE

// Flags.
var			  const bool	bStatic;			// Does not move or change over time. Don't let L.D.s change this - screws up net play
var(Advanced)		bool	bHidden;			// Is hidden during gameplay.
var(Advanced) const bool	bNoDelete;			// Cannot be deleted during play.
//#ifdef R6CODE
// Overrides bNoDelete, we need bNoDelete set to true for Interactive objects, but we want to be able to override 
// this if it should not be available based on game mode.
var           const BOOL    m_bR6Deletable;
var(R6Availability) BOOL    m_bUseR6Availability;
var                 BOOL    m_bSkipHitDetection;
//#endif R6CODE
var					bool	bAnimByOwner;		// Animation dictated by owner.
var			  const	bool	bDeleteMe;			// About to be deleted.
var transient const bool	bTicked;			// Actor has been updated.
var(Lighting)		bool	bDynamicLight;		// This light is dynamic.
var                 bool    m_bDynamicLightOnlyAffectPawns; // R6CODE
var					bool	bTimerLoop;			// Timer loops (else is one-shot).
var(Advanced)		bool	bCanTeleport;		// This actor can be teleported.
var 				bool	bOwnerNoSee;		// Everything but the owner can see this actor.
var					bool    bOnlyOwnerSee;		// Only owner can see this actor.
var			  const	bool	bAlwaysTick;		// Update even when players-only.
var(Advanced)		bool    bHighDetail;		// Only show up on high-detail.
var(Advanced)		bool	bStasis;			// In StandAlone games, turn off if not in a recently rendered zone turned off if  bStasis  and physics = PHYS_None or PHYS_Rotating.
var					bool	bTrailerSameRotation; // If PHYS_Trailer and true, have same rotation as owner.
var					bool	bTrailerPrePivot;	// If PHYS_Trailer and true, offset from owner by PrePivot.
var					bool	bClientAnim;		// Don't replicate any animations - animation done client-side
var					bool	bWorldGeometry;		// Collision and Physics treats this actor as world geometry
//R6CODE
//var					bool    bAcceptsProjectors;	// Projectors can project onto this actor
var(Display)		bool    bAcceptsProjectors;	// Projectors can project onto this actor
var					bool    m_bHandleRelativeProjectors;	// Projectors can project onto this actor but are relative to it -jfd
var					bool	bOrientOnSlope;		// when landing, orient base on slope of floor
var					bool    bDisturbFluidSurface; // Cause ripples when in contact with FluidSurface.
var			  const	bool	bOnlyAffectPawns;	// Optimisation - only test ovelap against pawns. Used for influences etc.
var					bool    bShowOctreeNodes;
var					bool    bWasSNFiltered;      // Mainly for debugging - the way this actor was inserted into Octree.

// Networking flags
var			  const	bool	bNetTemporary;				// Tear-off simulation in network play.
var			  const	bool	bNetOptional;				// Actor should only be replicated if bandwidth available.
var			  const	bool	bNetDirty;					// set when any attribute is assigned a value in unrealscript, reset when the actor is replicated
var					bool	bAlwaysRelevant;			// Always relevant for network.
var					bool	bReplicateInstigator;		// Replicate instigator to client (used by bNetTemporary projectiles).
var					bool	bReplicateMovement;			// if true, replicate movement/location related properties
var					bool	bSkipActorPropertyReplication; // if true, don't replicate actor class variables for this actor
var					bool	bUpdateSimulatedPosition;	// if true, update velocity/location after initialization for simulated proxies
var					bool	bTearOff;					// if true, this actor is no longer replicated to new clients, and 
														// is "torn off" (becomes a ROLE_Authority) on clients to which it was being replicated.
//#ifdef R6CODE
var                 BOOL    m_bUseRagdoll;              // Wheter or not the ragdoll have control over the bone (used only for pawn)
var                 BOOL    m_bForceBaseReplication;    // Force to replicate Base and AttachmentBone, mostly for weapon
//#endif // #ifdef R6CODE
var					bool	bOnlyDirtyReplication;		// if true, only replicate actor if bNetDirty is true - useful if no C++ changed attributes (such as physics) 
														// bOnlyDirtyReplication only used with bAlwaysRelevant actors
var					bool	bReplicateAnimations;		// Should replicate SimAnim

//UT2K3
var const           bool    bNetInitialRotation;        // Should replicate initial rotation
var         	    bool    bCompressedPosition;	    // used by networking code to flag compressed position replication

//R6CODE
var           const bool    m_bReticuleInfo;            // if the true, eventGetReticuleInfo will get call
var                 bool    m_bShowInHeatVision;
var                 BOOL    m_bFirstTimeInZone;
var(Lighting)       bool    m_bBypassAmbiant;
var                 BOOL    m_bRenderOutOfWorld;
var                 BOOL    m_bSpawnedInGame;       // when spawned in game, after the game is started, this is set to true
var                 BOOL    m_bResetSystemLog;      // used to debug the reset system
var                 BOOL    m_bDeleteOnReset;       // Actor who must be deleted when resetting the level

#ifdefSPDEMO
var                 int     m_vID;                  // version ID
#endif

// Priority Parameters
// Actor's current physics mode.
var(Movement) const enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Projectile,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_Ladder,
	PHYS_RootMotion,
    PHYS_Karma,
    PHYS_KarmaRagDoll
} Physics;

// Net variables.
enum ENetRole
{
	ROLE_None,              // No role at all.
	ROLE_DumbProxy,			// Dumb proxy of this actor.
	ROLE_SimulatedProxy,	// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,	// Locally autonomous proxy of this actor.
	ROLE_Authority,			// Authoritative control over the actor.
};
var ENetRole Role;
var ENetRole RemoteRole;

// Drawing effect.
var(Display) const enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_Terraform,
	DT_SpriteAnimOnce,
	DT_StaticMesh,
	DT_DrawType,
	DT_Particle,
	DT_AntiPortal,
	DT_FluidSurface
} DrawType;

var const transient int		NetTag;
var			float			LastRenderTime;	// last time this actor was rendered.
var(Events) name			Tag;			// Actor's tag name.

// Execution and timer variables.
var				float       TimerRate;		// Timer event, 0=no timer.
var		const	float       TimerCounter;	// Counts up until it reaches TimerRate.
var(Advanced)	float		LifeSpan;		// How old the object lives before dying, 0=forever.

var transient MeshInstance MeshInstance;	// Mesh instance.

var(Display) float		  LODBias;

// Owner.
var         const Actor   Owner;			// Owner actor.
var(Object) name InitialState;
var(Object) name Group;

//-----------------------------------------------------------------------------
// Structures.

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};

//-----------------------------------------------------------------------------
// Major actor properties.

// Scriptable.
var       const LevelInfo Level;         // Level this actor is on.
var transient const Level XLevel;        // Level object.
var(Events) name          Event;         // The event this actor causes.
var Pawn                  Instigator;    // Pawn responsible for damage caused by this actor.
var(R6Sound) sound        AmbientSound;  // Ambient sound effect.
var(R6Sound) sound        AmbientSoundStop;         // Stop the ambient sound effect.
// ifdef R6Sound
var(R6Sound) FLOAT        m_fAmbientSoundRadius;    // Ambient Sound Radius
var(R6Sound) FLOAT        m_fSoundRadiusSaturation; // The distance where the sound will be at the maximum
var(R6Sound) FLOAT        m_fSoundRadiusActivation; // The distance where the sound is activated
var(R6Sound) FLOAT        m_fSoundRadiusLinearFadeDist; // Distance at which the sound starts to fade linearly
var(R6Sound) FLOAT        m_fSoundRadiusLinearFadeEnd; //Distance from which the sound will be inaudible
var          BOOL         m_bInAmbientRange; 
// Play Conditions
var(R6Sound) BOOL         m_bPlayIfSameZone;        // Play the ambient sound only if the object is in the same zone
var(R6Sound) BOOL         m_bPlayOnlyOnce;          // Play a sound one time only.
var(R6Sound) BOOL         m_bListOfZoneHearable;    // Play the sound only in the zone of the array m_ListOfZoneInfo
var(R6Sound) BOOL         m_bIfDirectLineOfSight;   // Play the ambient sound only if we have a direct line of sight
var(R6SOUND) array<ZoneInfo> m_ListOfZoneInfo;      // Play the ambient sound only if the object is NOT in one of those zone

var          Actor        m_CurrentAmbianceObject;  // Object responsible if the current ambience that should be hear by this actor.  Use when we switch from player to player
var          Actor        m_CurrentVolumeSound;    // Object responsible if the current ambience that should be hear by this actor.  Use when we switch from player to player
var          BOOL         m_bUseExitSounds;         // Some objects, like ZoneInfo, contains Entry and Exit Sound.  This lag is to know which of the m_CurrentAmbianceSounds object to use
var          BOOL         m_bSoundWasPlayed;         // When the we want play the sound only once. A check is made to know if the sound was already played.
// endif

//#ifndef R6CHANGEWEAPONSYSTEM
//var Inventory             Inventory;     // Inventory chain.
//#endif
var const Actor           Base;          // Actor we're standing on.
var       bool            m_bDrawFromBase;//R6CODE This actor is drawn by its parent
var const PointRegion     Region;        // Region this actor is in.
var transient array<int>  Leaves;		 // BSP leaves this actor is in.

// Internal.
var const float           LatentFloat;   // Internal latent function use.
var const array<Actor>    Touching;		 // List of touching actors.
var const transient array<int>  OctreeNodes;// Array of nodes of the octree Actor is currently in. Internal use only.
var const transient Box	  OctreeBox;     // Actor bounding box cached when added to Octree. Internal use only.
var const transient vector OctreeBoxCenter;
var const transient vector OctreeBoxRadii;
var const actor           Deleted;       // Next actor in just-deleted chain.

// Internal tags.
var const native int CollisionTag, LightingTag, ActorTag;
var const transient int JoinedTag;

// The actor's position and rotation.
var const	PhysicsVolume	PhysicsVolume;	// physics volume this actor is currently in
var(Movement) const vector	Location;		// Actor's location; use Move to set.
var(Movement) const rotator Rotation;		// Rotation.
var(Movement) vector		Velocity;		// Velocity.
var			  vector        Acceleration;	// Acceleration.

// Attachment related variables
var(Movement)	name	AttachTag;
var const array<Actor>  Attached;			// array of actors attached to this actor.
var const vector		RelativeLocation;	// location relative to base/bone (valid if base exists)
var const rotator		RelativeRotation;	// rotation relative to base/bone (valid if base exists)
var const name			AttachmentBone;		// name of bone to which actor is attached (if attached to center of base, =='')

//R6CODE from UT2003
var(Movement) const bool bHardAttach;       // Uses 'hard' attachment code. bBlockActor and bBlockPlayer must also be false.
											// This actor cannot then move relative to base (setlocation etc.).
											// Dont set while currently based on something!
											// 
var const     Matrix    HardRelMatrix;		// Transform of actor in base's ref frame. Doesn't change after SetBase.
//#endif 

// Projectors
struct ProjectorRenderInfoPtr { var int Ptr; };	// Hack to to fool C++ header generation...
//R6CODE
//var const transient array<ProjectorRenderInfoPtr> Projectors;// Projected textures on this actor
struct ProjectorRelativeRenderInfo
{
    var     ProjectorRenderInfoPtr  m_RenderInfoPtr;
    var     vector                  m_RelativeLocation;
    var     rotator                 m_RelativeRotation;
};
var const transient array<ProjectorRelativeRenderInfo> Projectors;// Projected textures on this actor

//-----------------------------------------------------------------------------
// Display properties.

var(Display) Material		Texture;			// Sprite texture.if DrawType=DT_Sprite
var(Display) const mesh		Mesh;				// Mesh if DrawType=DT_Mesh.
var(Display) const StaticMesh StaticMesh;		// StaticMesh if DrawType=DT_StaticMesh
var StaticMeshInstance		StaticMeshInstance; // Contains per-instance static mesh data, like static lighting data.
var const export model		Brush;				// Brush if DrawType=DT_Brush.
//var(Display) const float	DrawScale;			// Scaling factor, 1.0=normal size.
//R6
var(Display) float	DrawScale;			// Scaling factor, 1.0=normal size.
var(Display) const vector	DrawScale3D;		// Scaling vector, (1.0,1.0,1.0)=normal size.
var			 vector			PrePivot;			// Offset from box center for drawing.
var(Display) array<Material> Skins;				// Multiple skin support - not replicated.
var(Display) byte			AmbientGlow;		// Ambient brightness, or 255=pulsing.
var(Display) byte           MaxLights;          // Limit to hardware lights active on this primitive.
var(Display) ConvexVolume	AntiPortal;			// Convex volume used for DT_AntiPortal

//R6Code
var(Display) array<Material> NightVisionSkins;
var(Display) FLOAT          m_fLightingScaleFactor;
var(Display) FLOAT          CullDistance;
var(Display) Color          m_fLightingAdditiveAmbiant;
var          BOOL           m_bAllowLOD;

// Style for rendering sprites, meshes.
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Particle,
    STY_Highlight
} Style;

// Display.
var(Display)  bool      bUnlit;					// Lights don't affect actor.
var(Display)  bool      bShadowCast;			// Casts static shadows.
var(Display)  bool		bStaticLighting;		// Uses raytraced lighting.
var(Display)  bool		bUseLightingFromBase;	// Use Unlit/AmbientGlow from Base

// Advanced.
var			  bool		bHurtEntry;				// keep HurtRadius from being reentrant
var(Advanced) bool		bGameRelevant;			// Always relevant for game
var(Advanced) bool		bCollideWhenPlacing;	// This actor collides with the world when placing.
var			  bool		bTravel;				// Actor is capable of travelling among servers.
var(Advanced) bool		bMovable;				// Actor can be moved.
var			  bool		bDestroyInPainVolume;	// destroy this actor if it enters a pain volume
var(Advanced) bool		bShouldBaseAtStartup;	// if true, find base for this actor at level startup, if collides with world and PHYS_None or PHYS_Rotating
var			  bool		bPendingDelete;			// set when actor is about to be deleted (since endstate and other functions called 
												// during deletion process before bDeleteMe is set).

//R6CODE    For collisions
var(Advanced) BOOL      m_bUseDifferentVisibleCollide;  // to use a different point to collide with this actor (in foreach VisibleCollidingActors)
var(Advanced) vector    m_vVisibleCenter;               // use this vector instead of location when m_bUseDifferentVisibleCollide is true
//end R6CODE

//-----------------------------------------------------------------------------
// Sound.

// Ambient sound.
var(Sound) float        SoundRadius;			// Radius of ambient sound.
var        bool         m_b3DSound;             // Does this actor emits sounds in 3D
var(Sound) byte         SoundPitch;				// Sound pitch shift, 64.0=none.


// Sound occlusion
enum ESoundOcclusion
{
	OCCLUSION_Default,
	OCCLUSION_None,
	OCCLUSION_BSP,
	OCCLUSION_StaticMeshes,
};

var(Sound) ESoundOcclusion SoundOcclusion;		// Sound occlusion approach.

// Sound slots for actors.

// R6CODE  *** Change the ESoundSlot for our proper USE ***
enum ESoundSlot
{
	SLOT_None,
	SLOT_Ambient,           
    SLOT_Guns,
    SLOT_SFX,               // All the special effect (Door, Explosion, Vitre, etc.)
	SLOT_GrenadeEffect,     // Use for special effect on the flash bang grenade )
	SLOT_Music,             // In game music
	SLOT_Talk,              // Use for the terrorist
    SLOT_Speak,             // Use in the menu briefing
    SLOT_HeadSet,           // Use for the Rainbow, talk with the Head Phone the player talk 
    SLOT_Menu,              // Use for all other sound in the menu
    SLOT_Instruction,
    SLOT_StartingSound
};

enum ESoundVolume
{
    VOLUME_Music,
    VOLUME_Voices,
    VOLUME_FX,
    VOLUME_Grenade
};

enum ESendSoundStatus
{
    SSTATUS_SendToPlayer,
    SSTATUS_SendToMPTeam,
    SSTATUS_SendToAll
};

enum ELoadBankSound
{
	LBS_Fix,
	LBS_UC,
	LBS_Map,
	LBS_Gun,
};

var(R6Sound) name         m_szSoundBoneName;			// Bone use by the sound.

//END R6CODE

// Music transitions.
enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};

// Regular sounds.
var(Sound) float TransientSoundVolume;	// default sound volume for regular sounds (can be overridden in playsound)
var(Sound) float TransientSoundRadius;	// default sound radius for regular sounds (can be overridden in playsound)

//-----------------------------------------------------------------------------
// Collision.

// Collision size.
var(Collision) const float CollisionRadius;		// Radius of collision cyllinder.
var(Collision) const float CollisionHeight;		// Half-height cyllinder.

// Collision flags.
var(Collision) const bool bCollideActors;		// Collides with other actors.
var(Collision) bool       bCollideWorld;		// Collides with the world.
var(Collision) bool       bBlockActors;			// Blocks other nonplayer actors.
var(Collision) bool       bBlockPlayers;		// Blocks other player actors.
var(Collision) bool       bProjTarget;			// Projectiles should potentially target this actor.
//#ifndef R6CODE
var(Collision) bool       m_bSeeThrough;        // Object that we don't want to see when checking for visibility (mainly for AI)
var(Collision) bool       m_bPawnGoThrough;     // Object from geometry that don't block the player
var(Collision) bool       m_bBulletGoThrough;   // Object from geometry that don't block the bullet
var(Collision) bool       m_bShotThrough;
//#endif // #ifndef R6CODE
// #ifdef R6PERBONECOLLISION
var            bool       m_bDoPerBoneTrace; // Use per-bone collision
var            byte       m_iTracedBone;
// #endif R6PERBONECOLLISION

// R6CIRCUMSTANTIALACTION
var            FLOAT      m_fCircumstantialActionRange;
// R6CIRCUMSTANTIALACTION

//#ifndef R6CODE
//var(Collision) bool		  bBlockZeroExtentTraces; // block zero extent actors/traces
//var(Collision) bool		  bBlockNonZeroExtentTraces;	// block non-zero extent actors/traces
//#endif // #ifndef R6CODE
var(Collision) bool       bAutoAlignToTerrain;  // Auto-align to terrain in the editor
var(Collision) bool		  bUseCylinderCollision;// Force axis aligned cylinder collision (useful for static mesh pickups, etc.)
var(Collision) const bool bBlockKarma;			// Block actors being simulated with Karma.

//R6COLLISIONBOX
var R6ColBox              m_collisionBox;  // Second CollisionBox of the pawn
var R6ColBox              m_collisionBox2; // Second CollisionBox of the pawn
//END R6COLLISIONBOX

//R6CODE
var(Debug) BOOL m_bLogNetTraffic;   // should we log net traffic for this actor?
//End R6CODE

//-----------------------------------------------------------------------------
// Lighting.

// Light modulation.
var(Lighting) enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
	LT_TexturePaletteOnce,
	LT_TexturePaletteLoop
} LightType;

// Spatial light effect to use.
var(Lighting) enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Unused,
	LE_Sunlight
} LightEffect;

// Lighting info.
var(LightColor) float
	LightBrightness;
var(LightColor) byte
	LightHue,
	LightSaturation;

// Light properties.
var(Lighting) float
	LightRadius;
var(Lighting) byte
	LightPeriod,
	LightPhase,
	LightCone;

// Lighting.
var(Lighting) bool	     bSpecialLit;	// Only affects special-lit surfaces.
var(Lighting) bool	     bActorShadows; // Light casts actor shadows.
var(Lighting) bool	     bCorona;       // Light uses Skin as a corona.
var bool				 bLightChanged;	// Recalculate this light's lighting now.
var bool                 m_bLightingVisibility; // R6CODE

//-----------------------------------------------------------------------------
// Physics.

// Options.
var			  bool		  bIgnoreOutOfWorld; // Don't destroy if enters zone zero
var(Movement) bool        bBounce;           // Bounces when hits ground fast.
var(Movement) bool		  bFixedRotationDir; // Fixed direction of rotation.
var(Movement) bool		  bRotateToDesired;  // Rotate to DesiredRotation.
var           bool        bInterpolating;    // Performing interpolating.
var			  const bool  bJustTeleported;   // Used by engine physics - not valid for scripts.

// R6CODE
var           bool        m_bUseOriginalRotationInPlanning;
var           rotator     sm_Rotation;

// Physics properties.
var(Movement) float       Mass;				// Mass of this actor.
var(Movement) float       Buoyancy;			// Water buoyancy.
var(Movement) rotator	  RotationRate;		// Change in rotation per second.
var(Movement) rotator     DesiredRotation;	// Physics will smoothly rotate actor to this rotation if bRotateToDesired.
var			  Actor		  PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes 
var       const vector    ColLocation;		// Actor's old location one move ago. Only for debugging

const MAXSTEPHEIGHT = 33.0; // Maximum step height walkable by pawns
const MINFLOORZ = 0.7; // minimum z value for floor normal (if less, not a walkable floor)
					   // 0.7 ~= 45 degree angle for floor

// R6DBGVECTORINFO
struct DbgVectorInfo
{
    var bool       m_bDisplay;  
    var vector     m_vLocation;
    var vector     m_vCylinder;
    var color      m_color;
    var string     m_szDef;
}; // ******* defined in UnObj.h

var array<DbgVectorInfo>   m_dbgVectorInfo;
// #endif R6DBGVECTORINFO

//#ifdef R6CHARLIGHTVALUE
var           float       fLightValue;      // Light value of the actor in the range 0..1
//#endif R6CHARLIGHTVALUE

// ifdef WITH_KARMA

// Used to avoid compression
struct KRBVec
{
	var float	X, Y, Z;
};

var(Karma) export editinline KarmaParamsCollision KParams; // Parameters for Karma Collision/Dynamics.
var const native int KStepTag;

// endif

//-----------------------------------------------------------------------------
// Animation replication (can be used to replicate channel 0 anims for dumb proxies)
struct AnimRep
{
	var name AnimSequence; 
	var bool bAnimLoop;	
	var byte AnimRate;		// note that with compression, max replicated animrate is 4.0
	var byte AnimFrame;
	var byte TweenRate;		// note that with compression, max replicated tweentime is 4 seconds
};
var transient AnimRep		  SimAnim;		   // only replicated if bReplicateAnimations is true

// #ifdef R6CODE
// rbrek - 12 nov 2001
//  used for bone rotation, represents the transition of a bone rotation
//  if == 1, either no bone rotation has been done or a bone rotation has been applied but the transition is complete.
//  if == 0, a bone rotation was requested and we are at the very start of the transition to the desired rotation.
var				FLOAT			m_fBoneRotationTransition;		

// AnimStruct used for scripted sequences
struct AnimStruct
{
	var() name AnimSequence;
	var() name BoneName;
	var() float AnimRate;
	var() byte alpha;
	var() byte LeadIn;
	var() byte LeadOut;
	var() bool bLoopAnim; 	
};


//-----------------------------------------------------------------------------
// Forces.

enum EForceType
{
	FT_None,
	FT_DragAlong,
};

var (Force) EForceType	ForceType;
var (Force)	float		ForceRadius;
var (Force) float		ForceScale;


//-----------------------------------------------------------------------------
// Networking.

// Network control.
var float NetPriority; // Higher priorities means update it more frequently.
var float NetUpdateFrequency; // How many seconds between net updates.

// Symmetric network flags, valid during replication only.
var const bool bNetInitial;       // Initial network update.
var const bool bNetOwner;         // Player owns this actor.
var const bool bNetRelevant;      // Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bDemoRecording;	  // True we are currently demo recording
var const bool bClientDemoRecording;// True we are currently recording a client-side demo
var const bool bClientDemoNetFunc;// True if we're client-side demo recording and this call originated from the remote.


//Editing flags
var(Advanced) bool        bHiddenEd;     // Is hidden during editing.
var(Advanced) bool        bHiddenEdGroup;// Is hidden by the group brower.
var(Advanced) bool        bDirectional;  // Actor shows direction arrow during editing.
var const bool            bSelected;     // Selected in UnrealEd.
var(Advanced) bool        bEdShouldSnap; // Snap to grid in editor.
var transient bool        bEdSnap;       // Should snap to grid in UnrealEd.
var transient const bool  bTempEditor;   // Internal UnrealEd.
var	bool				  bObsolete;	 // actor is obsolete - warn level designers to remove it
var bool				  bPathColliding;// this actor should collide (if bWorldGeometry && bBlockActors is true) during path building (ignored if bStatic is true, as actor will always collide during path building)
var transient bool		  bPathTemp;	 // Internal/path building

var	bool				  bScriptInitialized; // set to prevent re-initializing of actors spawned during level startup
var(Advanced) bool        bLockLocation; // Prevent the actor from being moved in the editor.

//#ifdef R6EDITORLOCKACTOR
var(Advanced) bool        bEdLocked;     // Locked in editor (no movement or rotation).
/*#elseif //R6EDITORLOCKACTOR
var bool                  bEdLocked;     // Locked in editor (no movement or rotation).
#endif //R6EDITORLOCKARCTOR */

var class<LocalMessage> MessageClass;

//R6NEWRENDERERFEATURES
var(Lighting) float	     bCoronaMUL2XFactor;
var(Lighting) float	     m_fCoronaMinSize;
var(Lighting) float	     m_fCoronaMaxSize;

// #ifdef R6CODE - rbrek 12 june 2002
// Rainbow AI

const	TEAM_None					= 0x00000;
const	TEAM_Orders					= 0x00001;		// actions were received as orders from player and not initiated by AI (therefore requiring acknowledgement)
	
const	TEAM_OpenDoor				= 0x00010;
const	TEAM_CloseDoor				= 0x00020;
const	TEAM_Grenade				= 0x00040;
const	TEAM_ClearRoom				= 0x00080;
const	TEAM_Move					= 0x00100;
const	TEAM_ClimbLadder			= 0x00200;
const	TEAM_SecureTerrorist		= 0x00400;
const	TEAM_EscortHostage			= 0x00800;
const	TEAM_DisarmBomb				= 0x01000;
const	TEAM_InteractDevice			= 0x02000;

const	TEAM_OpenAndClear			= 0x00090;		// TEAM_OpenDoor | TEAM_ClearRoom;
const	TEAM_OpenAndGrenade			= 0x00050;		// TEAM_OpenDoor | TEAM_Grenade;
const	TEAM_OpenGrenadeAndClear	= 0x000d0;		// TEAM_OpenDoor | TEAM_ClearRoom | TEAM_Grenade;
const	TEAM_GrenadeAndClear		= 0x000c0;		// TEAM_Grenade | TEAM_ClearRoom;
const	TEAM_MoveAndGrenade			= 0x00140;		// TEAM_Move | TEAM_Grenade;


// MP Team Id Constants
const c_iTeamNumHostage     = 0;
const c_iTeamNumTerrorist   = 1;
const c_iTeamNumAlpha       = 2;
const c_iTeamNumBravo       = 3;
const c_iTeamNumUnknow      = 4;
const c_iTeamNumPrisonerAlpha = 5;
const c_iTeamNumPrisonerBravo = 6;
const c_iTeamNumFreeBackup  = 7;


const  DEATHMSG_CONNECTIONLOST=1;
const  DEATHMSG_PENALTY=2;
const  DEATHMSG_KAMAKAZE=3;
const  DEATHMSG_SWITCHTEAM=4;
const  DEATHMSG_HOSTAGE_DIED=5;
const  DEATHMSG_HOSTAGE_KILLEDBY=6;
const  DEATHMSG_HOSTAGE_KILLEDBYTERRO=7;
const  DEATHMSG_RAINBOW_KILLEDBYTERRO=8;
const  DEATHMSG_KILLED_BY_BOMB=9;
const  DEATHMSG_PRISONER_KILLEDBY=10;
const  DEATHMSG_RAINBOW_SUFFOCATE=11;
const  DEATHMSG_INTRUDER_KILLEDBY=12;

// #endif R6CODE


//-----------------------------------------------------------------------------
// Enums.

// Travelling from server to server.
enum ETravelType
{
	TRAVEL_Absolute,	// Absolute URL.
	TRAVEL_Partial,		// Partial (carry name, reset server).
	TRAVEL_Relative,	// Relative URL.
};


// double click move direction.
enum EDoubleClickDir
{
	DCLICK_None,
	DCLICK_Left,
	DCLICK_Right,
	DCLICK_Forward,
	DCLICK_Back,
	DCLICK_Active,
	DCLICK_Done
};

// #ifdef R6BUILDPLANNINGPHASE
enum EDisplayFlag
{
    DF_ShowOnlyInPlanning,
    DF_ShowOnlyIn3DView,
    DF_ShowInBoth
};
var(R6Planning)   EDisplayFlag  m_eDisplayFlag;
var(R6Planning)   color         m_PlanningColor;
var(R6Planning)   INT           m_iPlanningFloor_0;
var(R6Planning)   INT           m_iPlanningFloor_1;
var(R6Planning)   BOOL          m_bPlanningAlwaysDisplay;
var(R6Planning)   BOOL	        m_bIsWalkable;
var(R6Planning)   BOOL          m_bSpriteShowFlatInPlanning;
var(R6Planning)   BOOL          m_bSpriteShownIn3DInPlanning;
var(R6Planning)   byte          m_u8SpritePlanningAngle;
var               BOOL          m_bSpriteShowOver;
//END R6PLANNINGRENDERING

// #ifdef R6NOISE
// Used by MakeNoise and HearNoise, for the controller to choose the type of reaction
enum ENoiseType
{
    NOISE_None,             // no sound
    NOISE_Investigate,      // Pawn go investigate
    NOISE_Threat,           // Pawn feel threatened 
    NOISE_Grenade,          // It's a grenade!!  Run!!
	NOISE_Dead				// team mate has been killed
};

// Used by MakeNoise and HearNoise, to tell the type of instigator
enum EPawnType
{
    PAWN_NotDefined,    // Not supposed to be used
    PAWN_Rainbow,
    PAWN_Terrorist,
    PAWN_Hostage,       // Hostage AND civilian
	PAWN_All
};

// Used by R6MakeNoise to tell wich loudness to pick
enum ESoundType
{
    SNDTYPE_None,           // No sound
    SNDTYPE_Gunshot,        // Check the gun for silenced or not
    SNDTYPE_BulletImpact,   // Impact, ricochet
    SNDTYPE_GrenadeImpact,  // Grenade bouncing
    SNDTYPE_GrenadeLike,    // Grenade-like weapon bouncing (FalseHB, HeartBeatJammer,...)
    SNDTYPE_Explosion,      // Various explosion (grenade, breach door)
    SNDTYPE_PawnMovement,   // Check the pawn to know the stance and the speed
    SNDTYPE_Choking,        // Choking from gas
    SNDTYPE_Talking,        // Talking
    SNDTYPE_Screaming,      // Talking louder :)
    SNDTYPE_Reload,         // Reloading weapon
    SNDTYPE_Equipping,      // Change in equipment (Weapon, gadget, ...)
    SNDTYPE_Dead,           // When a pawn died
    SNDTYPE_Door            // Opening and closing door
//    SNDTYPE_Object        // Let the objects do their own noise
};

// #endif // #ifdef R6NOISE

// #ifdef R6LOAD_IFGameType
enum EGameModeInfo 
{
    GMI_None,          // no info or no rules game mode
    GMI_SinglePlayer,  // if the GM can be played in single
    GMI_Cooperative,   // if the GM can be played in Coop
    GMI_Adversarial,   // if the GM can be played in adversarial
    GMI_Squad          // if the GM can be played in Squad
};

enum EModeFlagOption
{
    MFO_Available,
    MFO_NotAvailable
};    
// Training Stuff
enum EHUDDisplayType
{
    HDT_Normal,
    HDT_Hidden,
    HDT_FadeIn,
    HDT_Blink
};

enum EHUDElement
{
    HE_HealthAndName,
    HE_Posture,
    HE_ActionIcon,
    HE_WeaponIconAndName,
    HE_WeaponAttachment,
    HE_Ammo,
    HE_Magazine,
    HE_ROF,
    HE_TeamHealth,
    HE_MovementMode,
    HE_ROE,
    HE_WPAction,
    HE_Reticule,
    HE_WPIcon,
    HE_OtherTeam,
    HE_PressGoCodeKey
};

struct R6HUDState
{
    var float           fTimeStamp;    
    var EHUDDisplayType eDisplay;
    var Color           color;
};

struct stCustomAvailability
{
    var() string          szGameType;
    var() EModeFlagOption eAvailabilityFlag;
};


// the following specify if this actor is (not) available for each mode
// don't put this in an enum
var(R6Availability) const bool            m_bHideInLowGoreLevel;
var(R6Availability) const EModeFlagOption m_eStoryMode;         
var(R6Availability) const EModeFlagOption m_eMissionMode;         
var(R6Availability) const EModeFlagOption m_eTerroristHunt;     
var(R6Availability) const EModeFlagOption m_eTerroristHuntCoop;
var(R6Availability) const EModeFlagOption m_eHostageRescue;     
var(R6Availability) const EModeFlagOption m_eHostageRescueCoop;   
var(R6Availability) const EModeFlagOption m_eHostageRescueAdv;    
var(R6Availability) const EModeFlagOption m_eDefend;            
var(R6Availability) const EModeFlagOption m_eDefendCoop;          
var(R6Availability) const EModeFlagOption m_eRecon;             
var(R6Availability) const EModeFlagOption m_eReconCoop;             
var(R6Availability) const EModeFlagOption m_eDeathmatch;        
var(R6Availability) const EModeFlagOption m_eTeamDeathmatch;        
var(R6Availability) const EModeFlagOption m_eBomb;              
var(R6Availability) const EModeFlagOption m_eEscort;            
var(R6Availability) const EModeFlagOption m_eLoneWolf;          
var(R6Availability) const EModeFlagOption m_eSquadDeathmatch;             
var(R6Availability) const EModeFlagOption m_eSquadTeamDeathmatch;             
// MPF
var(R6Availability) const EModeFlagOption m_eTerroristHuntAdv; // MissionPack1
var(R6Availability) const EModeFlagOption m_eScatteredHuntAdv; // MissionPack1
var(R6Availability) const EModeFlagOption m_eCaptureTheEnemyAdv; // MissionPack1
var(R6Availability) const EModeFlagOption m_eCountDown;//MissionPack1 2
var(R6Availability) const EModeFlagOption m_eKamikaze; //MissionPack1 for MissionPack2
var(R6Availability) const EModeFlagOption m_eFreeBackupAdv;
var(R6Availability) const EModeFlagOption m_eGazAlertAdv;
var(R6Availability) const EModeFlagOption m_eIntruderAdv;
var(R6Availability) const EModeFlagOption m_eLimitSeatsAdv;
var(R6Availability) const EModeFlagOption m_eVirusUploadAdv;
var(R6Availability) array<stCustomAvailability> m_aCustomAvailability;

// #endif R6LOAD_IFGameType 

var Actor m_AttachedTo;
var FLOAT m_fAttachFactor; // Factor used by R6Tags.  if the scale changes (1.1 for rainbow character, 1 for Terrorists) 
                           // The tags must be divided by this value.  Then value is already divided.  1/1.1 = 0.909091 for Rainbow

var(Lighting) bool m_bIsRealtime;
var(Advanced) bool m_bShouldHidePortal;
var bool m_bHidePortal;

//R6SHADOW
var Projector Shadow;

// Planning
struct IndexBufferPtr { var int Ptr; }; // Hack to to fool C++ header generation...

var(Display)        BOOL            m_bOutlinedInPlanning;
var                 BOOL            m_bNeedOutlineUpdate;       // Actor was modified in the editor
var                 array<INT>      m_OutlineIndices;           // 2 16-bits indices each
var                 StaticMesh      m_OutlineStaticMesh;
var transient const IndexBufferPtr  m_OutlineIndexBuffer;

var             INT             m_bInWeatherVolume;

var             BYTE            m_u8RenderDataLastUpdate;

var(Display)    BYTE            m_HeatIntensity;

var             INT             m_iLastRenderCycles;
var             INT             m_iLastRenderTick;
var             INT             m_iTotalRenderCycles;
var             INT             m_iNbRenders;
var             INT             m_iTickCycles;
var             INT             m_iTraceCycles;
var             INT             m_iTraceLastTick;
var             INT             m_iTracedCycles;
var             INT             m_iTracedLastTick;

// R6CODE
struct ResolutionInfo
{
    var INT iWidth;
    var INT iHeigh;
    var INT iRefreshRate;
};

//R6USESMBATCHOPT+
struct StaticMeshBatchRenderInfo
{
    var INT m_iBatchIndex;
    var INT m_iFirstIndex;
    var INT m_iMinVertexIndex;
    var INT m_iMaxVertexIndex;
};

var             array<StaticMeshBatchRenderInfo> m_Batches;
var             bool                             m_bBatchesStaticLightingUpdated;
//R6USESMBATCHOPT-

// R6CODE
var(Lighting) BOOL m_bForceStaticLighting;

// Variable for skipping certain tick for unimportant actor
var     BOOL    m_bSkipTick;
var     BOOL    m_bTickOnlyWhenVisible;
var     BYTE    m_wTickFrequency;
var     BYTE    m_wNbTickSkipped;
var     FLOAT   m_fCummulativeTick;

struct PlayerMenuInfo
{
    var string szPlayerName;
    var string szKilledBy;                 // name of the player who killed me
    var INT    iKills;                     // Number of kills
    var INT    iEfficiency;                // Efficiency (hits/shot)
    var INT    iRoundsFired;               // Rounds fired (Bullets shot by the player)
	var INT    iRoundsHit;				   // Bullets shot by the player and that hit somebody
    var INT    iPingTime;                  // ping (The delay between player and server communication)
    var INT    iHealth;                    // health of this player
    var INT    iTeamSelection;
    var INT    iRoundsPlayed;              // game rounds played
    var INT    iRoundsWon;                 // game rounds won
    var INT    iDeathCount;                // number of rounds we died in this match
    var BOOL   bOwnPlayer;                 // This player is the player on this computer
    var BOOL   bSpectator;                 // treat as spectator?
    var BOOL   bPlayerReady;               // player ready icon
    var BOOL   bJoinedTeamLate;            // joined a team after game started
};

enum ETerroristNationality
{
    TN_Spanish1,
    TN_Spanish2,
    TN_German1,
    TN_German2,
    TN_Portuguese
};
enum EHostageNationality
{
    HN_French,
    HN_British,
    HN_Spanish,
    HN_Portuguese,
    HN_Norwegian
};

enum EVoicesPriority
{
    VP_Low,                                 // Can be interrupt at any time by another voices with superior priority
    VP_Medium,                              // Can stop low priority and play the current voice
    VP_High                                 // Stop and remove all sounds in low and medium alredy send and play new one
};

//-----------------------------------------------------------------------------
// natives.

// Execute a console command in the context of the current level and game engine.
native function string ConsoleCommand( string Command );


//#ifdef R6TAGS
//=========================================================================
// Tags.
native(2008) final function GetTagInformations( string TagName, out vector outVector, out rotator OutRotator, OPTIONAL FLOAT vOwnerScale);
//#endif R6TAGS \

// #ifdef R6DBGVECTORINFO
native(1505) final function DbgVectorReset( INT vectorIndex );
native(1506) final function DbgVectorAdd( vector vPoint, vector vCylinder, INT vectorIndex, OPTIONAL string szDef );
native(1801) final function DbgAddLine( vector vStart, vector vEnd, color cColor );
//#endif // #ifdef R6DBGVECTORINFO

native(1513) final function bool IsAvailableInGameType( string szGameType );

//#ifdef R6CODE
native(1230) final function GetFPlayerMenuInfo(INT Index, out PlayerMenuInfo _iPlayerMenuInfo);
native(1231) final function SetFPlayerMenuInfo(INT Index, PlayerMenuInfo _iPlayerMenuInfo);

//#ifdef R6CODE
native(1232) final function GetPlayerSetupInfo(out string m_CharacterName,
                                               out string m_ArmorName,
                                               out string m_WeaponNameOne,
                                               out string m_WeaponGadgetNameOne,
                                               out string m_BulletTypeOne,
                                               out string m_WeaponNameTwo,
                                               out string m_WeaponGadgetNameTwo,
                                               out string m_BulletTypeTwo,
                                               out string m_GadgetNameOne,
                                               out string m_GadgetNameTwo);

native(1233) final function SetPlayerSetupInfo(string m_CharacterName,
                                               string m_ArmorName,
                                               string m_WeaponNameOne,
                                               string m_WeaponGadgetNameOne,
                                               string m_BulletTypeOne,
                                               string m_WeaponNameTwo,
                                               string m_WeaponGadgetNameTwo,
                                               string m_BulletTypeTwo,
                                               string m_GadgetNameOne,
                                               string m_GadgetNameTwo);

native(1279) final function SortFPlayerMenuInfo(INT LastIndex, string szGameType);

//#ifdef R6CODE
native(1551) static final function R6AbstractGameManager GetGameManager();
native(1524) static final function R6ModMgr GetModMgr();
native(1009) static final function R6GameOptions GetGameOptions();
native(1012) static final function FLOAT GetTime();
native(2614) static final function INT GetNbAvailableResolutions();
native(2615) static final function GetAvailableResolution(INT Index, OUT INT Width, OUT INT Height, OUT INT RefreshRate);
//#ifdef R6CODE
native(1200) static final function BOOL  NativeStartedByGSClient();
native(1316) static final function BOOL  NativeNonUbiMatchMakingHost();
native(1303) static final function BOOL  NativeNonUbiMatchMaking();
native(1304) static final function NativeNonUbiMatchMakingAddress(OUT string RemoteIpAddress);
native(1305) static final function NativeNonUbiMatchMakingPassword(OUT string NonUbiPassword);
native(1273) static final function R6ServerInfo GetServerOptions();
native(1274) static final function R6ServerInfo GetServerOptionsRefreshed();
native(1283) static final function R6ServerInfo SaveServerOptions(OPTIONAL string FileName);
native(1302) static final function R6MissionDescription GetMissionDescription();
native(1311) static final function SetServerBeacon(InternetInfo ServerBeacon);
native(1312) static final function InternetInfo GetServerBeacon();

//#ifdefR6PUNBUSTER
native(1400) static final function BOOL IsPBClientEnabled();
native(1402) static final function BOOL IsPBServerEnabled();
native(1401) static final function SetPBStatus( BOOL _bDisable, BOOL _bServerStatus);
//#endif

//#endif R6CODE
native(2613) static final function LoadLoadingScreen(String MapName, Texture pTex0, Texture pTex1);
native(2616) static final function BOOL ReplaceTexture(String Filename, Texture pTex);
native(1256) final function string ConvertGameTypeIntToString( INT iGameType );
native(2015) final function INT ConvertGameTypeToInt( string szGameType );
native(1419) static final function string GetGameVersion( OPTIONAL BOOL _bShortVersion, OPTIONAL BOOL _bModVersion);
native(2617) static final function BOOL IsVideoHardwareAtLeast64M();
native(2618) static final function Canvas GetCanvas();
native(2619) static final function EnableLoadingScreen(BOOL _enable);
native(2620) static final function AddMessageToConsole(string Msg, Color MsgColor, optional BYTE bMessageUseBigFont);
native(2621) static final function UpdateGraphicOptions();
native(2622) static final function GarbageCollect();
native(1519) static final function string GetMapNameExt();
native(1520) static final function string ConvertIntTimeToString( INT iTimeToConvert, OPTIONAL BOOL bAlignMinOnTwoDigits );
native(1522) static final function string GlobalIDToString(BYTE aBytes[16/*K_GlobalID_size*/]);
native(1523) static final function        GlobalIDToBytes( string szIn, OUT byte aBytes[255] );
native(2607) static final function object LoadRandomBackgroundImage(optional string _szBackGroundSubFolder);
native(4042) static final function KMP2IOKarmaAllNativeFct(INT WhatIdo, Actor _owner, optional FLOAT _var_int, optional FLOAT _var_float, optional vector _var_vect);



//------------------------------------------------------------------
// GetReticuleInfo: info displayed under the reticule. 
//  optimized to work with the flag m_bReticuleInfo.
//	out: szName is the name identifying this Actor
//       return true if it's a friend or a neutral actor, False if enemy
//------------------------------------------------------------------
simulated event BOOL GetReticuleInfo( Pawn ownerReticule, OUT string szName ) { return false; }


//#endif

//#endif R6CODE

// #ifdef R6HEARTBEAT
simulated event BOOL ProcessHeart(FLOAT DeltaSeconds, out FLOAT fMul1, out FLOAT fMul2);
// #endif R6HEARTBEAT




//-----------------------------------------------------------------------------
// Network replication.

replication
{
	// Location
	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && bReplicateMovement
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Location;

	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && bReplicateMovement 
					&& ((DrawType == DT_Mesh) || (DrawType == DT_StaticMesh))
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Rotation;

	unreliable if ( (((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && bReplicateMovement 
					&& RemoteRole<=ROLE_SimulatedProxy) 
//#ifdef R6CODE
                    || (m_bForceBaseReplication && !bNetOwner && Role == ROLE_Authority)
//#endif // #ifdef R6CODE
                    )
		Base;

    unreliable if( (((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && bReplicateMovement 
					&& RemoteRole<=ROLE_SimulatedProxy && (Base != None) && !Base.bWorldGeometry)
//#ifdef R6CODE
                    || (m_bForceBaseReplication && !bNetOwner && Role == ROLE_Authority)
//#endif // #ifdef R6CODE
                    )
		RelativeRotation, RelativeLocation, AttachmentBone;

	// Physics
	unreliable if( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && bReplicateMovement 
					&& (((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition))
						|| ((RemoteRole == ROLE_DumbProxy) && (Physics == PHYS_Falling))) )
		Velocity;

// #ifndef R6CODE // 17 feb 2002 rbrek
//	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
//					&& (((RemoteRole == ROLE_SimulatedProxy) && bNetInitial)
//						|| (RemoteRole == ROLE_DumbProxy)) )
//		Physics;
// #else
	unreliable if( Role == ROLE_Authority && !bNetOwner)
		Physics;
    
	unreliable if( Role == ROLE_Authority && bNetInitial)
        bActorShadows;

	unreliable if( Role == ROLE_Authority)
        m_bUseRagdoll, m_fAttachFactor;

	reliable if( Role < ROLE_Authority)
		ServerSendBankToLoad, ServerForceKillResult, ServerForceStunResult;

    reliable if( Role == ROLE_Authority)
        ClientAddSoundBank;

    reliable if ( Role == ROLE_Authority )
        m_collisionBox,m_collisionBox2;
    
// #endif //R6CODE

	unreliable if( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && bReplicateMovement 
					&& (RemoteRole <= ROLE_SimulatedProxy) && (Physics == PHYS_Rotating) )
		bFixedRotationDir, bRotateToDesired, RotationRate, DesiredRotation;

	// Ambient sound.
	unreliable if( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) )
		AmbientSound;

	unreliable if( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) 
					&& (AmbientSound!=None) )
		SoundRadius, SoundPitch, m_szSoundBoneName;

	// Animation. 
	unreliable if( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) 
				&& (Role==ROLE_Authority) && (DrawType==DT_Mesh) && bReplicateAnimations )
		SimAnim;

	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) )
		bHidden;

	// Properties changed using accessor functions (Owner, rendering, and collision)
	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) && bNetDirty )
		Owner, DrawScale, DrawScale3D, DrawType, bCollideActors,bCollideWorld,bOnlyOwnerSee,Texture,Style,
        m_fLightingScaleFactor,m_fLightingAdditiveAmbiant;

	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) && bNetDirty 
					&& (bCollideActors || bCollideWorld) )
		bProjTarget, bBlockActors, bBlockPlayers, CollisionRadius, CollisionHeight;

	// Properties changed only when spawning or in script (relationships, rendering, lighting)
	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) )
		Role,RemoteRole,bNetOwner,LightType,bTearOff;

//#ifndef R6CHANGEWEAPONSYSTEM	
//    unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
//					&& bNetDirty && bNetOwner )
//		Inventory;
//#endif
    
	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && bReplicateInstigator )
		Instigator;

	// Infrequently changed mesh properties
	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && (DrawType == DT_Mesh) )
		AmbientGlow,bUnlit,PrePivot,Mesh;

	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) 
				&& bNetDirty && (DrawType == DT_StaticMesh) )
		StaticMesh;

	// Infrequently changed lighting properties.
	unreliable if ( ((!m_bUseRagdoll && !bSkipActorPropertyReplication) || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && (LightType != LT_None) )
		LightEffect, LightBrightness, LightHue, LightSaturation,
		LightRadius, LightPeriod, LightPhase, bSpecialLit;

	// replicated functions
	unreliable if( bDemoRecording )
		DemoPlaySound;

}

//=============================================================================
// Actor error handling.

// Handle an error and kill this one actor.
native(233) final function Error( coerce string S );

//=============================================================================
// General functions.

// Latent functions.
native(256) final latent function Sleep( float Seconds );

// Collision.
native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
native(283) final function bool SetCollisionSize( float NewRadius, float NewHeight );
native final function SetDrawScale(float NewScale);
native final function SetDrawScale3D(vector NewScale3D);
native final function SetStaticMesh(StaticMesh NewStaticMesh);
native final function SetDrawType(EDrawType NewDrawType);

// Movement.
native(266) final function bool Move( vector Delta );

//R6CODE native(267) final function bool SetLocation( vector NewLocation );
native(267) final function bool SetLocation( vector NewLocation, optional bool bNoCheck );
native(299) final function bool SetRotation( rotator NewRotation );

// SetRelativeRotation() sets the rotation relative to the actor's base
native final function bool SetRelativeRotation( rotator NewRotation );
native final function bool SetRelativeLocation( vector NewLocation );

native(3969) final function bool MoveSmooth( vector Delta );
native(3971) final function AutonomousPhysics(float DeltaSeconds);

// Relations.
native(298) final function SetBase( actor NewBase, optional vector NewFloor );
native(272) final function SetOwner( actor NewOwner );

//=============================================================================
// Animation.

// Animation functions.
//#ifdef R6CODE -  
// 14 jan 2002 rbrek - for playing animations backwards
// 16 jan 2002 rbrek - added bForceAnimRate to force PlayAnim to use exactly the specified animation rate
native(259) final function PlayAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel, optional bool bBackward, optional bool bForceAnimRate );
native(260) final function LoopAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel, optional bool bBackward, optional bool bForceAnimRate );
//#endif R6CODE

native(294) final function TweenAnim( name Sequence, float Time, optional int Channel );
native(282) final function bool IsAnimating(optional int Channel);
native(261) final latent function FinishAnim(optional int Channel);
native(263) final function bool HasAnim( name Sequence );
native final function StopAnimating( optional bool ClearAllButBase );
native final function FreezeAnimAt( float Time, optional int Channel);
native final function bool IsTweening(int Channel);

//#ifdef R6CODE 
native(1805) final function ClearChannel( int iChannel );
native(1500) final function name GetAnimGroup( name Sequence ); // pgaron 4 jan 2002
//#endif

// Animation notifications.
event AnimEnd( int Channel );
native final function EnableChannelNotify ( int Channel, int Switch );
native final function int GetNotifyChannel();

// Skeletal animation.
simulated native final function LinkSkelAnim( MeshAnimation Anim, optional mesh NewMesh );
simulated native final function LinkMesh( mesh NewMesh, optional bool bKeepAnim );

//#ifdef R6CODE - rbrek 4 april 2002
native(2210) final function UnLinkSkelAnim();
//#endif

native final simulated function AnimBlendParams( int Stage, optional float BlendAlpha, optional float InTime, optional float OutTime, optional name BoneName );
native final function AnimBlendToAlpha( int Stage, float TargetAlpha, float TimeInterval );

//#ifdef R6CODE - rbrek 05 jan 2002
native(2208) final function float GetAnimBlendAlpha( int Stage );
//#endif

//#ifdef R6CODE - pgaron 15 jan 2002
native(1501) final function bool    WasSkeletonUpdated();
//#endif
native final simulated function coords  GetBoneCoords( name BoneName, optional bool bDontCallGetFrame ); // r6code added bDontCallGetFrame  
native final function rotator GetBoneRotation( name BoneName, optional int Space );

native final function vector  GetRootLocation();
native final function rotator GetRootRotation();
native final function vector  GetRootLocationDelta();
native final function rotator GetRootRotationDelta();

native final function bool  AttachToBone( actor Attachment, name BoneName );
native final function bool  DetachFromBone( actor Attachment );

// rbrek - 22 nov 2001
// added an argument to LockRootMotion() to allow using root motion with or without locking rotation of the root bone...
//#ifdef R6CODE
native final function LockRootMotion( int Lock, optional bool bUseRootRotation );
//#elif
//native final function LockRootMotion( int Lock );
//#endif

native final function SetBoneScale( int Slot, optional float BoneScale, optional name BoneName );

native final function SetBoneDirection( name BoneName, rotator BoneTurn, optional vector BoneTrans, optional float Alpha );
native final function SetBoneLocation( name BoneName, optional vector BoneTrans, optional float Alpha );
native final function GetAnimParams( int Channel, out name OutSeqName, out float OutAnimFrame, out float OutAnimRate );
native final function bool AnimIsInGroup( int Channel, name GroupName );  

// #ifdif R6CODE - rbrek - 10 oct 2001  
native final function SetBoneRotation( name BoneName, optional rotator BoneTurn, optional int Space, optional float Alpha, optional float InTime);
// #endif R6CODE
//native final function SetBoneRotation( name BoneName, optional rotator BoneTurn, optional int Space, optional float Alpha );

//=========================================================================
// Rendering.

native final function plane GetRenderBoundingSphere();

//=========================================================================
// Physics.

// Physics control.
native(301) final latent function FinishInterpolation();
native(3970) final function SetPhysics( EPhysics newPhysics );

native final function OnlyAffectPawns(bool B);

// ifdef WITH_KARMA
native final function KSetMass( float mass );
native final function float KGetMass();

// Set inertia tensor assuming a mass of 1. Scaled by mass internally to calculate actual inertia tensor.
native final function KSetInertiaTensor( vector it1, vector it2 );
native final function KGetInertiaTensor( out vector it1, out vector it2 );

native final function KSetDampingProps( float lindamp, float angdamp );
native final function KGetDampingProps( out float lindamp, out float angdamp );

native final function KSetFriction( float friction );
native final function float KGetFriction();

native final function KSetRestitution( float rest );
native final function float KGetRestitution();

native final function KSetCOMOffset( vector offset );
native final function KGetCOMOffset( out vector offset );
native final function KGetCOMPosition( out vector pos ); // get actual position of actors COM in world space

native final function KSetImpactThreshold( float thresh );
native final function float KGetImpactThreshold();

native final function KWake();
native final function bool KIsAwake();
native final function KAddImpulse( vector Impulse, vector Position, optional name BoneName );

native final function KSetStayUpright( bool stayUpright, bool allowRotate );

native final function KSetBlockKarma( bool newBlock );

native final function KSetActorGravScale( float ActorGravScale );
native final function float KGetActorGravScale();

// Disable/Enable Karma contact generation between this actor, and another actor.
// Collision is on by default.
native final function KDisableCollision( actor Other );
native final function KEnableCollision( actor Other );

// Ragdoll-specific functions
native final function KSetSkelVel( vector Velocity, optional vector AngVelocity, optional bool AddToCurrent );
native final function float KGetSkelMass();
native final function KFreezeRagdoll();

// You MUST turn collision off (KSetBlockKarma) before using bone lifters!
native final function KAddBoneLifter( name BoneName, InterpCurve LiftVel, float LateralFriction, InterpCurve Softness ); 
native final function KRemoveLifterFromBone( name BoneName ); 
native final function KRemoveAllBoneLifters(); 

// Used for only allowing a fixed maximum number of ragdolls in action.
native final function KMakeRagdollAvailable();
native final function bool KIsRagdollAvailable();

// event called when Karmic actor hits with impact velocity over KImpactThreshold
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm); 

// event called when karma actor's velocity drops below KVelDropBelowThreshold;
event KVelDropBelow();

// event called when a ragdoll convulses (see KarmaParamsSkel)
event KSkelConvulse();

// event called just before sim to allow user to 
// NOTE: you should ONLY put numbers into Force and Torque during this event!!!!
event KApplyForce(out vector Force, out vector Torque);

// This is called from inside C++ physKarma at the appropriate time to update state of Karma rigid body.
// If you return true, newState will be set into the rigid body. Return false and it will do nothing.
//#ifndef R6KARMA
//event bool KUpdateState(out KRigidBodyState newState);
//#endif // #ifndef R6KARMA

// endif

//=========================================================================
// Music

//R6SOUND
native final function BOOL PlayMusic( Sound Music, optional BOOL bForcePlayMusic);
native final function BOOL StopMusic( Sound StopMusic );
native final function StopAllMusic();
//ELSE
//native final function int PlayMusic( string Song, float FadeInTime );
//native final function StopMusic( int SongHandle, float FadeOutTime );
//native final function StopAllMusic( float FadeOutTime );
//END RSOUND

//=========================================================================
// Engine notification functions.

//
// Major notifications.
//
//event Destroyed();
//R6SHADOW
event Destroyed()
{
   if (Shadow != none)
       Shadow.Destroy();
}
event GainedChild( Actor Other );
event LostChild( Actor Other );
event Tick( float DeltaTime );

//
// Triggers.
//
event Trigger( Actor Other, Pawn EventInstigator );
event UnTrigger( Actor Other, Pawn EventInstigator );
event BeginEvent();
event EndEvent();

//
// Physics & world interaction.
//
event Timer();
event HitWall( vector HitNormal, actor HitWall );
event Falling();
event Landed( vector HitNormal );
event ZoneChange( ZoneInfo NewZone );
event PhysicsVolumeChange( PhysicsVolume NewVolume );
event Touch( Actor Other );
event PostTouch( Actor Other ); // called for PendingTouch actor after physics completes
event UnTouch( Actor Other );
event Bump( Actor Other );
event BaseChange();
event Attach( Actor Other );
event Detach( Actor Other );
event Actor SpecialHandling(Pawn Other);
event bool EncroachingOn( actor Other );
event EncroachedBy( actor Other );
event FinishedInterpolation()
{
	bInterpolating = false;
}

event EndedRotation();			// called when rotation completes
event UsedBy( Pawn user ); // called if this Actor was touching a Pawn who pressed Use

//#ifdef R6CODE
function SetAttachVar(Actor AttachActor, string StaticMeshTag, name PawnTag);
function MatineeAttach();
function MatineeDetach();
//#endif


event FellOutOfWorld()
{
	SetPhysics(PHYS_None);
	Destroy();
}	

//
// Damage and kills.
//
event KilledBy( pawn EventInstigator );

//
// Trace a line and see what it collides with first.
// Takes this actor's collision properties into account.
// Returns first hit actor, Level if hit level, or None if hit nothing.
//
native(277) final function Actor Trace
(
	out vector      HitLocation,
	out vector      HitNormal,
	vector          TraceEnd,
	optional vector TraceStart,
	optional bool   bTraceActors,
	optional vector Extent,
    optional out material Material
);

//ifdef R6CODE
const TF_TraceActors = 0x0001;
const TF_Visibility  = 0x0002;
const TF_LineOfFire  = 0x0004;
const TF_SkipVolume  = 0x0008;
const TF_ShadowCast  = 0x0010;
const TF_SkipPawn    = 0x0020;

native(1806) final function Actor R6Trace
(
	out vector      HitLocation,
	out vector      HitNormal,
	vector          TraceEnd,
	optional vector TraceStart,
    optional INT    iTraceFlags,
	optional vector Extent,
    optional out material Material
);

native(1800) final function bool FindSpot( out vector vLocation, optional vector vExtent );
//endif R6CODE

// returns true if did not hit world geometry
native(548) final function bool FastTrace
(
	vector          TraceEnd,
	optional vector TraceStart
);

//
// Spawn an actor. Returns an actor of the specified class, not
// of class Actor (this is hardcoded in the compiler). Returns None
// if the actor could not be spawned (either the actor wouldn't fit in
// the specified location, or the actor list is full).
// Defaults to spawning at the spawner's location.
//
native(278) final function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation,
//R6CODE+
    optional bool     bNoCollisionFail
//R6CODE-
);

//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
native(279) final function bool Destroy();

// Networking - called on client when actor is torn off (bTearOff==true)
event TornOff();

//=============================================================================
// Timing.

// Causes Timer() events every NewTimerRate seconds.
native(280) final function SetTimer( float NewTimerRate, bool bLoop );

//=============================================================================
// Sound functions.

/* Play a sound effect.
*/

//native(264) final function PlaySound
//(
//	sound				Sound,
//	optional ESoundSlot Slot,
//	optional float		Volume,
//	optional bool		bNoOverride,
//	optional float		Radius,
//	optional float		Pitch,
//	optional bool		Attenuate
//);

// R6CODE
native(264)  final function PlaySound( Sound Sound, optional ESoundSlot Slot);
native(2725) final function StopSound( Sound Sound);
native(2703) final function BOOL IsPlayingSound(Actor aActor, sound Sound);
native(2704) final function BOOL ResetVolume_AllTypeSound();
native(2720) final function BOOL ResetVolume_TypeSound(ESoundSlot eSlot);
native(2705) final function ChangeVolumeType(ESoundSlot eSlot, FLOAT fVolume);
native(2712) final function StopAllSounds();
native(2716) final function AddSoundBank(string szBank, ELoadBankSound eLBS);
native(2717) final function AddAndFindBankInSound(Sound Sound, ELoadBankSound eLBS);
native(2719) final function StopAllSoundsActor(Actor aActor);
native(2721) final function FadeSound(FLOAT fTime, INT iFade, ESoundSlot eSlot);
native(2722) final function SaveCurrentFadeValue();
native(2723) final function ReturnSavedFadeValue(FLOAT fTime);


// R6CODE END

/* play a sound effect, but don't propagate to a remote owner
 (he is playing the sound clientside)
 */
native simulated final function PlayOwnedSound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Attenuate
);

native simulated event DemoPlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Attenuate
);

/* Get a sound duration.
*/
native final function float GetSoundDuration( sound Sound );

//=============================================================================
// AI functions.    

/* Inform other creatures that you've made a noise
 they might hear (they are sent a HearNoise message)
 Senders of MakeNoise should have an instigator if they are not pawns.
*/

// #ifdef R6NOISE
native(512) final function MakeNoise( float Loudness, optional ENoiseType eNoise, optional EPawnType ePawn, optional ESoundType ESoundType );
event R6MakeNoise( Actor.ESoundType eType )
{
    if(eType==SNDTYPE_None)
        return;

    // If we're a client, GameInfo doesn't exist (and we don't need to make the noise
    if(Level.Game!=None)
    {
        Level.Game.R6GameInfoMakeNoise( eType, Self );
    }
    else
    {
        log("Warning: Call to R6MakeNoise when game is not the server" );
        log("         From " $ name $ " in the state " $ GetStateName() );
    }
}

function R6MakeNoise2( FLOAT fLoudness, ENoiseType eNoise, EPawnType ePawn )
{
    MakeNoise( fLoudness, eNoise, ePawn );
}
// #else
// native(512) final function MakeNoise( float Loudness );
// #endif // #ifdef R6NOISE

/* PlayerCanSeeMe returns true if any player (server) or the local player (standalone
or client) has a line of sight to actor's location.
*/
native(532) final function bool PlayerCanSeeMe();

//=============================================================================
// Regular engine functions.

// Teleportation.
event bool PreTeleport( Teleporter InTeleporter );
event PostTeleport( Teleporter OutTeleporter );

// Level state.
event BeginPlay();

//========================================================================
// Disk access.

// Find files.
native(539) final function string GetMapName( string NameEnding, string MapName, int Dir );
native(545) final function GetNextSkin( string Prefix, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc );
native(547) final function string GetURLMap();
native final function string GetNextInt( string ClassName, int Num );
native final function GetNextIntDesc( string ClassName, int Num, out string Entry, out string Description );
native final function bool GetCacheEntry( int Num, out string GUID, out string Filename );
native final function bool MoveCacheEntry( string GUID, optional string NewFilename );  

//=============================================================================
// Iterator functions.

// Iterator functions for dealing with sets of actors.

/* AllActors() - avoid using AllActors() too often as it iterates through the whole actor list and is therefore slow
*/
native(304) final iterator function AllActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* DynamicActors() only iterates through the non-static actors on the list (still relatively slow, bu
 much better than AllActors).  This should be used in most cases and replaces AllActors in most of 
 Epic's game code. 
*/
native(313) final iterator function DynamicActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* ChildActors() returns all actors owned by this actor.  Slow like AllActors()
*/
native(305) final iterator function ChildActors   ( class<actor> BaseClass, out actor Actor );

/* BasedActors() returns all actors based on the current actor (slow, like AllActors)
*/
native(306) final iterator function BasedActors   ( class<actor> BaseClass, out actor Actor );

/* TouchingActors() returns all actors touching the current actor (fast)
*/
native(307) final iterator function TouchingActors( class<actor> BaseClass, out actor Actor );

/* TraceActors() return all actors along a traced line.  Reasonably fast (like any trace)
*/
native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent );

/* RadiusActors() returns all actors within a give radius.  Slow like AllActors().  Use CollidingActors() or VisibleCollidingActors() instead if desired actor types are visible
(not bHidden) and in the collision hash (bCollideActors is true)
*/
native(310) final iterator function RadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

/* VisibleActors() returns all visible actors within a radius.  Slow like AllActors().  Use VisibleCollidingActors() instead if desired actor types are 
in the collision hash (bCollideActors is true)
*/
native(311) final iterator function VisibleActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc );

/* VisibleCollidingActors() returns visible (not bHidden) colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() since it uses the collision hash
*/
native(312) final iterator function VisibleCollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc, optional bool bIgnoreHidden );

/* CollidingActors() returns colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() for reasonably small radii since it uses the collision hash
*/
native(321) final iterator function CollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

//=============================================================================
// Color functions
native(549) static final operator(20) color -     ( color A, color B );
native(550) static final operator(16) color *     ( float A, color B );
native(551) static final operator(20) color +     ( color A, color B );
native(552) static final operator(16) color *     ( color A, float B );

//R6PLANNING
native(2011) final function SetPlanningMode(BOOL bDraw);
native(2014) final function BOOL InPlanningMode();
native(2012) final function SetFloorToDraw(INT iFloor);
native(2610) final function RenderLevelFromMe(INT iXMin, INT iYMin, INT iXSize, INT iYSize);

//R6CODE
native(2608) final function DrawDashedLine(vector vStart, vector vEnd, color Col, float fDashSize);
native(2609) final function DrawText3D(vector vPos, coerce string pString);


//=============================================================================
// Scripted Actor functions.

/* RenderOverlays()
called by player's hud to request drawing of actor specific overlays onto canvas
*/
function RenderOverlays(Canvas Canvas);
	
//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
    if ( Level.Game != none && Level.Game.m_bGameStarted )
    {
        m_bSpawnedInGame = true;
    }
}

//
// Broadcast a localized message to all players.
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage( class<LocalMessage> MessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Level.Game.BroadcastLocalized( self, MessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

// Called immediately after gameplay begins.
//
event PostBeginPlay();

// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
    bScriptInitialized = true;
	if( InitialState!='' )
		GotoState( InitialState );
	else
		GotoState( 'Auto' );
}

//#ifdef R6CODE
simulated function FirstPassReset();
//#endif // #ifdef R6CODE

// called after PostBeginPlay.  On a net client, PostNetBeginPlay() is spawned after replicated variables have been initialized to
// their replicated values
event PostNetBeginPlay();

// R6CODE +
simulated event SaveAndResetData()
{
    SaveOriginalData();     // backup all the needed data
    ResetOriginalData();    // reset the data and initialized the actor (ie: call functions)
}
// R6CODE -

// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept();

// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept();

// Called by PlayerController when this actor becomes its ViewTarget.
//
function BecomeViewTarget();

// Returns the string representation of the name of an object without the package
// prefixes.
//
function String GetItemName( string FullName )
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

// Returns the human readable string representation of an object.
//
function String GetHumanReadableName()
{
	return GetItemName(string(class));
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;
		
	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{	
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));	
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
}

// Get localized message string associated with this actor
static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return "";
}

function MatchStarting(); // called when gameplay actually starts

function String GetDebugName()
{
	return GetItemName(string(self));
}

/* DisplayDebug()
list important actor variable on canvas.  HUD will call DisplayDebug() on the current ViewTarget when
the ShowDebug exec is used
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float XL;
	local int i;
	local Actor A;
	local name anim;
	local float frame,rate;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.StrLen("TEST", XL, YL);
	YPos = YPos + YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,0,0);
	T = GetDebugName();
	if ( bDeleteMe )
		T = T$" DELETED (bDeleteMe == true)";

	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,255,255);

	if ( Level.NetMode != NM_Standalone )
	{
		// networking attributes
		T = "ROLE ";
		Switch(Role)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		T = T$" REMOTE ROLE ";
		Switch(RemoteRole)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		if ( bTearOff )
			T = T$" Tear Off";
		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	T = "Physics ";
	Switch(PHYSICS)
	{
		case PHYS_None: T=T$"None"; break;
		case PHYS_Walking: T=T$"Walking"; break;
		case PHYS_Falling: T=T$"Falling"; break;
		case PHYS_Swimming: T=T$"Swimming"; break;
		case PHYS_Flying: T=T$"Flying"; break;
		case PHYS_Rotating: T=T$"Rotating"; break;
		case PHYS_Projectile: T=T$"Projectile"; break;
		case PHYS_Interpolating: T=T$"Interpolating"; break;
		case PHYS_MovingBrush: T=T$"MovingBrush"; break;
		case PHYS_Spider: T=T$"Spider"; break;
		case PHYS_Trailer: T=T$"Trailer"; break;
		case PHYS_Ladder: T=T$"Ladder"; break;
	}
	T = T$" in physicsvolume "$GetItemName(string(PhysicsVolume))$" on base "$GetItemName(string(Base));
	if ( bBounce )
		T = T$" - will bounce";
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Location: "$Location$" Rotation "$Rotation, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Velocity: "$Velocity$" Speed "$VSize(Velocity), false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Acceleration: "$Acceleration, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	
	Canvas.DrawColor.B = 0;
	Canvas.DrawText("Collision Radius "$CollisionRadius$" Height "$CollisionHeight);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Collides with Actors "$bCollideActors$", world "$bCollideWorld$", proj. target "$bProjTarget);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Blocks Actors "$bBlockActors$", players "$bBlockPlayers);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Touching ";
	ForEach TouchingActors(class'Actor', A)
		T = T$GetItemName(string(A))$" ";
	if ( T == "Touching ")
		T = "Touching nothing";
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.R = 0;
	T = "Rendered: ";
	Switch(Style)
	{
		case STY_None: T=T; break;
		case STY_Normal: T=T$"Normal"; break;
		case STY_Masked: T=T$"Masked"; break;
		case STY_Translucent: T=T$"Translucent"; break;
		case STY_Modulated: T=T$"Modulated"; break;
		case STY_Alpha: T=T$"Alpha"; break;
	}		

	Switch(DrawType)
	{
		case DT_None: T=T$" None"; break;
		case DT_Sprite: T=T$" Sprite "; break;
		case DT_Mesh: T=T$" Mesh "; break;
		case DT_Brush: T=T$" Brush "; break;
		case DT_RopeSprite: T=T$" RopeSprite "; break;
		case DT_VerticalSprite: T=T$" VerticalSprite "; break;
		case DT_Terraform: T=T$" Terraform "; break;
		case DT_SpriteAnimOnce: T=T$" SpriteAnimOnce "; break;
		case DT_StaticMesh: T=T$" StaticMesh "; break;
	}

	if ( DrawType == DT_Mesh )
	{
		T = T$Mesh;
		if ( Skins.length > 0 )
		{
			T = T$" skins: ";
			for ( i=0; i<Skins.length; i++ )
			{
				if ( skins[i] == None )
					break;
				else
					T =T$skins[i]$", ";
			}
		}

		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
		
		// mesh animation
		GetAnimParams(0,Anim,frame,rate);
		T = "AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
		if ( bAnimByOwner )
			T= T$" Anim by Owner";
	}
	else if ( (DrawType == DT_Sprite) || (DrawType == DT_SpriteAnimOnce) )
		T = T$Texture;
	else if ( DrawType == DT_Brush )
		T = T$Brush;
		
	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	
	Canvas.DrawColor.B = 255;	
	Canvas.DrawText("Tag: "$Tag$" Event: "$Event$" STATE: "$GetStateName(), false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Instigator "$GetItemName(string(Instigator))$" Owner "$GetItemName(string(Owner)));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Timer: "$TimerCounter$" LifeSpan "$LifeSpan$" AmbientSound "$AmbientSound);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

// NearSpot() returns true is spot is within collision cylinder
simulated final function bool NearSpot(vector Spot)
{
	local vector Dir;

	Dir = Location - Spot;
	
	if ( abs(Dir.Z) > CollisionHeight )
		return false;

	Dir.Z = 0;
    return ( VSize(Dir) <= CollisionRadius );
}

simulated final function bool TouchingActor(Actor A)
{
	local vector Dir;

	Dir = Location - A.Location;
	
	if ( abs(Dir.Z) > CollisionHeight + A.CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius + A.CollisionRadius );
}

// MERGE NOTE PlusDir() replaced by int operator ClockwiseFrom()

/* StartInterpolation()
when this function is called, the actor will start moving along an interpolation path
beginning at Dest
*/	
simulated function StartInterpolation()
{
	GotoState('');
	SetCollision(True,false,false);
	bCollideWorld = False;
	bInterpolating = true;
	SetPhysics(PHYS_None);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset();

/* 
Trigger an event
*/
event TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( (EventName == '') || (EventName == 'None') )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
		A.Trigger(Other, EventInstigator);
}

/*
Untrigger an event
*/
function UntriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( (EventName == '') || (EventName == 'None') )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
		A.Untrigger(Other, EventInstigator);
}

function bool IsInVolume(Volume aVolume)
{
	local Volume V;
	
	ForEach TouchingActors(class'Volume',V)
		if ( V == aVolume )
			return true;
	return false;
}

function PlayTeleportEffect(bool bOut, bool bSound);

function bool CanSplash()
{
	return false;
}

function vector GetCollisionExtent()
{
	local vector Extent;

	Extent = CollisionRadius * vect(1,1,0);
	Extent.Z = CollisionHeight;
	return Extent;
}


///////////////////////////////////////////////////////////////////////////////
// R6CIRCUMSTANTIALACTION

//===========================================================================//
// R6QueryCircumstantialAction()                                             //
//  Get circumstantial action informations from an actor.                    //
//===========================================================================//
event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    Query.iHasAction = 0;
}

//===========================================================================//
// R6GetCircumstantialActionString()                                         //
//  Translate an action ID to a string.                                      //
//===========================================================================//
simulated function string R6GetCircumstantialActionString( INT iAction )
{ 
    return "";
}

//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//  Notify the actor that the player is starting to interact with it.        //
//===========================================================================//
function R6CircumstantialActionProgressStart( R6AbstractCircumstantialActionQuery Query );

//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//  Once the progress bar is started, use this function to update it.        //
//  Progress should be updated using Level.TimeSeconds and the skill of the  //
//  player acting on it. Should return a number between 0 and 100            //
//===========================================================================//
function INT  R6GetCircumstantialActionProgress( R6AbstractCircumstantialActionQuery Query, Pawn actingPawn )
{
    return 0;
}

//===========================================================================//
// R6CircumstantialActionCancel()                                            //
//  If the action it stop when the player is doing the action				 //
//===========================================================================//
function R6CircumstantialActionCancel();

//===========================================================================//
// R6ActionCanBeExecuted()                                                   //
//  Can the action be executed at this time ?                                //
//  If not, the action will be grayed out in the rose des vents.             //
//===========================================================================//
simulated function BOOL R6ActionCanBeExecuted( INT iAction, PlayerController PlayerController )
{
    return true;
}

//===========================================================================//
// R6FillSubAction()                                                         //
//  Small function used to fill a circumstantial action team submenu using   //
//  an action ID.                                                            //
//===========================================================================//
function R6FillSubAction( Out R6AbstractCircumstantialActionQuery Query, INT iSubMenu, INT iAction )
{
	Query.iTeamSubActionsIDList[iSubMenu*4 + 0] = iAction;
	Query.iTeamSubActionsIDList[iSubMenu*4 + 1] = iAction;
	Query.iTeamSubActionsIDList[iSubMenu*4 + 2] = iAction;
	Query.iTeamSubActionsIDList[iSubMenu*4 + 3] = iAction;
}

// R6CIRCUMSTANTIALACTION
///////////////////////////////////////////////////////////////////////////////

//R6CODE
function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy, 
						   vector vHitLocation, vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
{
    //If the function is not overloaded, call the original function
    //TakeDamage( iKillValue, instigatedBy, vHitLocation, vMomentum, none);
    if(m_bBulletGoThrough == true)
        return iKillValue;
    else
        return 0;
}

function ServerForceKillResult( INT iKillResult );
function ServerForceStunResult( INT iStunResult );

//=============================================================================
// get random number betweem a min and a max
//=============================================================================
static function float GetRandomTweenNum( OUT RandomTweenNum r )
{
	// max should be max >= min
    #ifdefDEBUG    assert( r.m_fMax >= r.m_fMin ); #endif

    r.m_fResult = FRand() * (r.m_fMax - r.m_fMin);
    r.m_fResult += r.m_fMin;

    return r.m_fResult;
}

function Actor R6GetRootActor()
{
    if(m_AttachedTo != none)
    {
        return m_AttachedTo.R6GetRootActor();
    }

    return self;
}

function AddSoundBankName(string szBank)
{
    local BOOL bFind;
    local INT i;

    for (i=0; i<Level.Game.m_BankListToLoad.Length; i++)
    {
        if (Level.Game.m_BankListToLoad[i] == szBank)
        {
            bFind = true;
            break;
        }
    }
        
    if (!bFind)
        Level.Game.m_BankListToLoad[Level.Game.m_BankListToLoad.Length] = szBank;
}

function ServerSendBankToLoad()
{
    local Controller lpController;
    local INT i;

    for (i=0; i<Level.Game.m_BankListToLoad.Length; i++)
    {
		for ( lpController=Level.ControllerList; lpController!=None; lpController=lpController.NextController )
		{
			if (lpController.IsA('PlayerController'))
                lpController.ClientAddSoundBank(Level.Game.m_BankListToLoad[i]);
        }
    }
}

function ClientAddSoundBank(string szBank)
{
    AddSoundBank(szBank, LBS_UC);
    #ifdefDEBUG LogSnd("***** ClientAddSoundBank =" @ szBank @ "*****");    #endif
}

//------------------------------------------------------------------
// Save / Reset Original Data
//	
//------------------------------------------------------------------
simulated function SaveOriginalData();
simulated function ResetOriginalData();

function LogResetSystem( bool bSaving )
{
    if ( bSaving )
        log( "SAVING: "    $name$ " in " $class.name );
    else
        log( "RESETTING: " $name$ " in " $class.name );
}

//------------------------------------------------------------------
// dbgLogActor
//	
//------------------------------------------------------------------
simulated function dbgLogActor( bool bVerbose )
{
    log("Name= " $name );

}
    //END R6CODE

defaultproperties
{
     Role=ROLE_Authority
     RemoteRole=ROLE_DumbProxy
     DrawType=DT_Sprite
     MaxLights=4
     Style=STY_Normal
     SoundPitch=64
     m_eDisplayFlag=DF_ShowInBoth
     m_HeatIntensity=64
     m_wNbTickSkipped=255
     m_iPlanningFloor_0=-1
     m_iPlanningFloor_1=-1
     bReplicateMovement=True
     m_bAllowLOD=True
     bMovable=True
     m_b3DSound=True
     bJustTeleported=True
     m_bIsRealtime=True
     m_bOutlinedInPlanning=True
     LODBias=1.000000
     m_fSoundRadiusSaturation=300.000000
     m_fSoundRadiusActivation=2000.000000
     m_fSoundRadiusLinearFadeDist=1000.000000
     m_fSoundRadiusLinearFadeEnd=2900.000000
     DrawScale=1.000000
     m_fLightingScaleFactor=1.000000
     SoundRadius=64.000000
     TransientSoundVolume=1.000000
     m_fCircumstantialActionRange=175.000000
     Mass=100.000000
     NetPriority=1.000000
     NetUpdateFrequency=100.000000
     bCoronaMUL2XFactor=0.500000
     m_fCoronaMaxSize=100000.000000
     m_fAttachFactor=1.000000
     Texture=Texture'Engine.S_Actor'
     MessageClass=Class'Engine.LocalMessage'
     DrawScale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     m_PlanningColor=(B=255,G=250,R=244,A=255)
}
