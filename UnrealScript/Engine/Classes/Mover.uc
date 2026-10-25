//=============================================================================
// The moving brush class.
// This is a built-in Unreal class and it shouldn't be modified.
// Note that movers by default have bNoDelete==true.  This makes movers and their default properties
// remain on the client side.  If a mover subclass has bNoDelete=false, then its default properties must
// be replicated
//=============================================================================
class Mover extends Actor
	native
	nativereplication;

// How the mover should react when it encroaches an actor.
var() enum EMoverEncroachType
{
	ME_StopWhenEncroach,	// Stop when we hit an actor.
	ME_ReturnWhenEncroach,	// Return to previous position when we hit an actor.
   	ME_CrushWhenEncroach,   // Crush the poor helpless actor.
   	ME_IgnoreWhenEncroach,  // Ignore encroached actors.
} MoverEncroachType;

// How the mover moves from one position to another.
var() enum EMoverGlideType
{
	MV_MoveByTime,			// Move linearly.
	MV_GlideByTime,			// Move with smooth acceleration.
} MoverGlideType;

// What classes can bump trigger this mover
var() enum EBumpType
{
	BT_PlayerBump,		// Can only be bumped by player.
	BT_PawnBump,		// Can be bumped by any pawn
	BT_AnyBump,			// Can be bumped by any solid actor
} BumpType;

//-----------------------------------------------------------------------------
// Keyframe numbers.
var() byte       KeyNum;           // Current or destination keyframe.
var byte         PrevKeyNum;       // Previous keyframe.
var() const byte NumKeys;          // Number of keyframes in total (0-3).
var() const byte WorldRaytraceKey; // Raytrace the world with the brush here.
var() const byte BrushRaytraceKey; // Raytrace the brush here.

//-----------------------------------------------------------------------------
// Movement parameters.
var() float      MoveTime;         // Time to spend moving between keyframes.
var() float      StayOpenTime;     // How long to remain open before closing.
var() float      OtherTime;        // TriggerPound stay-open time.
var() int        EncroachDamage;   // How much to damage encroached actors.

//-----------------------------------------------------------------------------
// Mover state.
var() bool       bToggleDirection;
var() bool       bTriggerOnceOnly; // Go dormant after first trigger.
var() bool       bSlave;           // This brush is a slave.
var() bool		 bUseTriggered;		// Triggered by player grab
var() bool		 bDamageTriggered;	// Triggered by taking damage
var() bool       bDynamicLightMover; // Apply dynamic lighting to mover.
var() bool       bUseShortestRotation;
var(ReturnGroup) bool bIsLeader;
var() bool       bOscillatingLoop;
var() name       PlayerBumpEvent;  // Optional event to cause when the player bumps the mover.
var() name       BumpEvent;			// Optional event to cause when any valid bumper bumps the mover.
var   actor      SavedTrigger;      // Who we were triggered by.
var() float		 DamageThreshold;	// minimum damage to trigger
var	  int		 numTriggerEvents;	// number of times triggered ( count down to untrigger )
var	  Mover		 Leader;			// for having multiple movers return together
var	  Mover		 Follower;
var(ReturnGroup) name ReturnGroup;	// if none, same as tag
var() float		 DelayTime;			// delay before starting to open

var(MoverEvents) name OpeningEvent;
var(MoverEvents) name OpenedEvent;
var(MoverEvents) name ClosingEvent;
var(MoverEvents) name ClosedEvent;
var(MoverEvents) name LoopEvent;

var() name AntiPortalTag;
var array<AntiPortalActor> AntiPortals;

//-----------------------------------------------------------------------------
// Audio.
var(MoverSounds) sound      OpeningSound;     // When start opening.
var(MoverSounds) sound      OpenedSound;      // When finished opening.
var(MoverSounds) sound      ClosingSound;     // When start closing.
var(MoverSounds) sound      ClosedSound;      // When finish closing.
var(MoverSounds) sound      MoveAmbientSound; // Optional ambient sound when moving.
var(MoverSounds) sound      LoopSound;

//-----------------------------------------------------------------------------
// Internal.
var vector       KeyPos[24];
var rotator      KeyRot[24];
var vector       BasePos, OldPos, OldPrePivot, SavedPos;
var rotator      BaseRot, OldRot, SavedRot;
var           float       PhysAlpha;       // Interpolating position, 0.0-1.0.
var           float       PhysRate;        // Interpolation rate per second.

// AI related
var       NavigationPoint  myMarker;
var		  bool			bOpening, bDelaying, bClientPause;
var		  bool			bClosed;	// mover is in closed position, and no longer moving
var		  bool			bPlayerOnly;
var(AI)	  bool			bNoAIRelevance; // don't warn about this mover during path review

// for client side replication
var		vector			SimOldPos;
var		int				SimOldRotPitch, SimOldRotYaw, SimOldRotRoll;
var		vector			SimInterpolate;
var		vector			RealPosition;
var     rotator			RealRotation;
var		int				ClientUpdate;
var		int				StepDirection;

replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority )
		SimOldPos, SimOldRotPitch, SimOldRotYaw, SimOldRotRoll, SimInterpolate, RealPosition, RealRotation;
}

/* StartInterpolation()
when this function is called, the actor will start moving along an interpolation path
beginning at Dest
*/	
simulated function StartInterpolation()
{
	GotoState('');
	bInterpolating = true;
	m_bTickOnlyWhenVisible = false;
	SetPhysics(PHYS_None);
}

simulated function Timer()
{
	if ( Velocity != vect(0,0,0) )
	{
		bClientPause = false;
		return;		
	}
	if ( Level.NetMode == NM_Client )
	{
		if ( ClientUpdate == 0 ) // not doing a move
		{
			if ( bClientPause )
			{
				if ( VSize(RealPosition - Location) > 3 )
					SetLocation(RealPosition);
				else
					RealPosition = Location;
				SetRotation(RealRotation);
				bClientPause = false;
			}
			else if ( RealPosition != Location )
				bClientPause = true;
		}
		else
			bClientPause = false;
	}
	else 
	{
		RealPosition = Location;
		RealRotation = Rotation;
	}
}

//-----------------------------------------------------------------------------
// Movement functions.

// Interpolate to keyframe KeyNum in Seconds time.
final simulated function InterpolateTo( byte NewKeyNum, float Seconds )
{
	local Mover M;

	foreach BasedActors(class'Mover', M)
		M.BaseStarted();

	NewKeyNum = Clamp( NewKeyNum, 0, ArrayCount(KeyPos)-1 );
	if( NewKeyNum==PrevKeyNum && KeyNum!=PrevKeyNum )
	{
		// Reverse the movement smoothly.
		PhysAlpha = 1.0 - PhysAlpha;
		OldPos    = BasePos + KeyPos[KeyNum];
		OldRot    = BaseRot + KeyRot[KeyNum];
	}
	else
	{
		// Start a new movement.
		OldPos    = Location;
		OldRot    = Rotation;
		PhysAlpha = 0.0;
	}

	// Setup physics.
	SetPhysics(PHYS_MovingBrush);
	bInterpolating   = true;
	m_bTickOnlyWhenVisible = false;
	PrevKeyNum       = KeyNum;
	KeyNum			 = NewKeyNum;
	PhysRate         = 1.0 / FMax(Seconds, 0.005);

	ClientUpdate++;
	SimOldPos = OldPos;
	SimOldRotYaw = OldRot.Yaw;
	SimOldRotPitch = OldRot.Pitch;
	SimOldRotRoll = OldRot.Roll;
	SimInterpolate.X = 100 * PhysAlpha;
	SimInterpolate.Y = 100 * FMax(0.01, PhysRate);
	SimInterpolate.Z = 256 * PrevKeyNum + KeyNum;
}

// Set the specified keyframe.
final function SetKeyframe( byte NewKeyNum, vector NewLocation, rotator NewRotation )
{
	KeyNum         = Clamp( NewKeyNum, 0, ArrayCount(KeyPos)-1 );
	KeyPos[KeyNum] = NewLocation;
	KeyRot[KeyNum] = NewRotation;
}

// Interpolation ended.
simulated event KeyFrameReached()
{
	local byte OldKeyNum;
	local Mover M;

	OldKeyNum  = PrevKeyNum;
	PrevKeyNum = KeyNum;
	PhysAlpha  = 0;
	ClientUpdate--;

	// If more than two keyframes, chain them.
	if( KeyNum>0 && KeyNum<OldKeyNum )
	{
		// Chain to previous.
		InterpolateTo(KeyNum-1,MoveTime);
	}
	else if( KeyNum<NumKeys-1 && KeyNum>OldKeyNum )
	{
		// Chain to next.
		InterpolateTo(KeyNum+1,MoveTime);
	}
	else
	{
		// Finished interpolating.
		AmbientSound = None;
		if ( (ClientUpdate == 0) && (Level.NetMode != NM_Client) )
		{
			RealPosition = Location;
			RealRotation = Rotation;
			foreach BasedActors(class'Mover', M)
				M.BaseFinished();
		}
	}
}

//-----------------------------------------------------------------------------
// Mover functions.

// Notify AI that mover finished movement
function FinishNotify()
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.nextController )
		if ( (C.Pawn != None) && (C.PendingMover == self) )
			C.MoverFinished();
}

// Handle when the mover finishes closing.
function FinishedClosing()
{
	local Mover M;

	// Update sound effects.
	PlaySound( ClosedSound, SLOT_SFX);//Eric Begin, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	TriggerEvent(ClosedEvent, Self, Instigator);

	// Notify our triggering actor that we have completed.
	if( SavedTrigger != None )
		SavedTrigger.EndEvent();
	SavedTrigger = None;
	Instigator = None;
	If ( MyMarker != None )
		MyMarker.MoverClosed();
	bClosed = true;
	FinishNotify();

	for ( M=Leader; M!=None; M=M.Follower )
		if ( !M.bClosed )
			return;
	UnTriggerEvent(OpeningEvent, Self, Instigator);
}

// Handle when the mover finishes opening.
function FinishedOpening()
{
	// Update sound effects.
	PlaySound( OpenedSound, SLOT_SFX );//Eric Begin, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	
	// Trigger any chained movers.
	TriggerEvent(Event, Self, Instigator);
	TriggerEvent(OpenedEvent, Self, Instigator);

	If ( MyMarker != None )
		MyMarker.MoverOpened();
	FinishNotify();
}

// Open the mover.
function DoOpen()
{
	bOpening = true;
	bDelaying = false;
	InterpolateTo( 1, MoveTime );
	MakeNoise(1.0);
	PlaySound( OpeningSound, SLOT_SFX); //Eric Begin, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(OpeningEvent, Self, Instigator);
	if ( Follower != None )
		Follower.DoOpen();
}

// Close the mover.
function DoClose()
{
	bOpening = false;
	bDelaying = false;
	InterpolateTo( Max(0,KeyNum-1), MoveTime );
	MakeNoise(1.0);
	PlaySound( ClosingSound, SLOT_SFX); //Eric Begin, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	UntriggerEvent(Event, self, Instigator);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(ClosingEvent, Self, Instigator);
	if ( Follower != None )
		Follower.DoClose();
}

//-----------------------------------------------------------------------------
// Engine notifications.

// When mover enters gameplay.
simulated function BeginPlay()
{
	local AntiPortalActor AntiPortal;

	if ( AntiPortalTag != '' )
	{
		foreach AllActors(class'AntiPortalActor', AntiPortal, AntiPortalTag)
		{
			AntiPortals.Length = AntiPortals.Length + 1;
			AntiPortals[AntiPortals.Length - 1] = AntiPortal;
		}
	}

	// timer updates real position every second in network play
	if ( Level.NetMode != NM_Standalone )
	{
		if ( Level.NetMode == NM_Client )
			settimer(4.0, true);
		else
			settimer(1.0, true);
		if ( Role < ROLE_Authority )
			return;
	}

	if ( Level.NetMode != NM_Client )
	{
		RealPosition = Location;
		RealRotation = Rotation;
	}

	// Init key info.
	Super.BeginPlay();
	KeyNum         = Clamp( KeyNum, 0, ArrayCount(KeyPos)-1 );
	PhysAlpha      = 0.0;

	// Set initial location.
	Move( BasePos + KeyPos[KeyNum] - Location );

	// Initial rotation.
	SetRotation( BaseRot + KeyRot[KeyNum] );

	// find movers in same group
	if ( ReturnGroup == '' )
		ReturnGroup = tag;

	Leader = None;
	Follower = None;
}

// Immediately after mover enters gameplay.
function PostBeginPlay()
{
	local mover M;

	// Initialize all slaves.
	if( !bSlave )
	{
		foreach DynamicActors( class 'Mover', M, Tag )
		{
			if( M.bSlave )
			{
				M.GotoState('');
				M.SetBase( Self );
			}
		}
	}
	if ( bIsLeader )
	{
		Leader = self;
		ForEach DynamicActors( class'Mover', M )
			if ( (M != self) && (M.ReturnGroup == ReturnGroup) )
			{
				M.Leader = self;
				M.Follower = Follower;
				Follower = M;
			}
	}
	else if ( Leader == None )
	{
		ForEach DynamicActors( class'Mover', M )
			if ( (M != self) && (M.ReturnGroup == ReturnGroup) )
				return;
		Leader = self;
	}
}

function MakeGroupStop()
{
	// Stop moving immediately.
	bInterpolating = false;
	m_bTickOnlyWhenVisible = default.m_bTickOnlyWhenVisible;
	AmbientSound = None;
	GotoState( , '' );

	if ( Follower != None )
		Follower.MakeGroupStop();
}

function MakeGroupReturn()
{
	// Abort move and reverse course.
	bInterpolating = false;
	m_bTickOnlyWhenVisible = default.m_bTickOnlyWhenVisible;
	AmbientSound = None;
	if ( bIsLeader || (Leader == self) )
	{
		if( KeyNum<PrevKeyNum )
			GotoState( , 'Open' );
		else
			GotoState( , 'Close' );
	}

	if ( Follower != None )
		Follower.MakeGroupReturn();
}
		
// Return true to abort, false to continue.
function bool EncroachingOn( actor Other )
{
	local Pawn P;
	if ( Other == None )
		return false;
	if ( (Pawn(Other) != None) && (Pawn(Other).Controller == None) )
		return false;

	// If we have a bump-player event, and Other is a pawn, do the bump thing.
	P = Pawn(Other);
	if( P!=None && (P.Controller != None) && P.IsPlayerPawn() )
	{
		if ( PlayerBumpEvent!='' )
			Bump( Other );
		if ( (P.Controller != None) && (P.Base != self) && (P.Controller.PendingMover == self) )
			P.Controller.UnderLift(self);	// pawn is under lift - tell him to move
	}

	// Stop, return, or whatever.
	if( MoverEncroachType == ME_StopWhenEncroach )
	{
		Leader.MakeGroupStop();
		return true;
	}
	else if( MoverEncroachType == ME_ReturnWhenEncroach )
	{
		Leader.MakeGroupReturn();
		if ( Other.IsA('Pawn') )
			Pawn(Other).PlayMoverHitSound();
		return true;
	}
	else if( MoverEncroachType == ME_CrushWhenEncroach )
	{
		// Kill it.
		Other.KilledBy( Instigator );
		return false;
	}
	else if( MoverEncroachType == ME_IgnoreWhenEncroach )
	{
		// Ignore it.
		return false;
	}
}

// When bumped by player.
function Bump( actor Other )
{
	local pawn  P;

	P = Pawn(Other);
	if ( bUseTriggered && (P != None) && !P.IsHumanControlled() && P.IsPlayerPawn() )
	{
		Trigger(P,P);
		P.Controller.WaitForMover(self);
	}	
	if ( (BumpType != BT_AnyBump) && (P == None) )
		return;
	if ( (BumpType == BT_PlayerBump) && !P.IsPlayerPawn() )
		return;
	if ( (BumpType == BT_PawnBump) && P.bAmbientCreature )
		return;
	TriggerEvent(BumpEvent, self, P);

	if ( (P != None) && P.IsPlayerPawn() )
		TriggerEvent(PlayerBumpEvent, self, P);
}

// When damaged
function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy,
						   vector vHitLocation, vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
{
	if ( bDamageTriggered && (iKillValue >= DamageThreshold) )
	{
		if ( (AIController(instigatedBy.Controller) != None) && (instigatedBy.Controller.Focus == self) )
			instigatedBy.Controller.StopFiring();
		self.Trigger(self, instigatedBy);
	}
	return 0;
}

function MoverLooped()
{
	TriggerEvent(LoopEvent, Self, Instigator);
	if ( LoopSound != None )
		PlaySound( LoopSound, SLOT_SFX );
}

function BaseStarted();
function BaseFinished();

//========================================================================
// Master State for OpenTimed mover states (for movers that open and close)

state OpenTimedMover
{
	function DisableTrigger();
	function EnableTrigger();
	function bool ShouldReTrigger()
	{
		return false;
	}

Open:
	bClosed = false;
	DisableTrigger();
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep( StayOpenTime );
	if( bTriggerOnceOnly )
		GotoState('');
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	EnableTrigger();
	Sleep(StayOpenTime);
	if ( ShouldReTrigger() )
	{
		SavedTrigger = None;
		GotoState( 'StandOpenTimed', 'Open' );
	}
}

// Open when stood on, wait, then close.
state() StandOpenTimed extends OpenTimedMover
{
	function bool ShouldReTrigger()
	{
		local int i;

		for ( i=0; i<Attached.Length; i++ )
			if ( CanTrigger(Attached[i]) )
				return true;
		return false;
	}

	function bool CanTrigger( actor Other )
	{
		local pawn  P;

		P = Pawn(Other);
		if ( (BumpType != BT_AnyBump) && (P == None) )
			return false;
		if ( (BumpType == BT_PlayerBump) && !P.IsPlayerPawn() )
			return false;
		if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
			return false;
		TriggerEvent(BumpEvent, self, P);
		return true;
	}

	function Attach( actor Other )
	{
		if ( !CanTrigger(Other) )
			return;
		SavedTrigger = None;
		GotoState( 'StandOpenTimed', 'Open' );
	}

	function DisableTrigger()
	{
		Disable( 'Attach' );
	}

	function EnableTrigger()
	{
		Enable('Attach');
	}
}

// Open when bumped, wait, then close.
state() BumpOpenTimed extends OpenTimedMover
{
	function Bump( actor Other )
	{
		if ( (BumpType != BT_AnyBump) && (Pawn(Other) == None) )
			return;
		if ( (BumpType == BT_PlayerBump) && !Pawn(Other).IsPlayerPawn() )
			return;
		if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
			return;
		Global.Bump( Other );
		SavedTrigger = None;
        
        Instigator = Pawn(Other);
		// R6CODE Instigator.Controller.WaitForMover(self);
        // R6CODE+
        if ( Instigator != none )
            Instigator.Controller.WaitForMover(self);
        // R6CODE-
		GotoState( 'BumpOpenTimed', 'Open' );
	}

	function DisableTrigger()
	{
		Disable( 'Bump' );
	}

	function EnableTrigger()
	{
		Enable('Bump');
	}
}

// When triggered, open, wait, then close.
state() TriggerOpenTimed extends OpenTimedMover
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		GotoState( 'TriggerOpenTimed', 'Open' );
	}

	function DisableTrigger()
	{
		Disable( 'Trigger' );
	}

	function EnableTrigger()
	{
		Enable('Trigger');
	}
}

state() LoopMove
{
	event Trigger( actor Other, pawn EventInstigator )
	{
		Disable( 'Trigger' );
		Enable( 'UnTrigger' );
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		bOpening = true;
		PlaySound( OpeningSound, SLOT_SFX );
		AmbientSound = MoveAmbientSound;
		GotoState( 'LoopMove', 'Running' );
	}

	event UnTrigger( actor Other, pawn EventInstigator )
	{
		Disable( 'UnTrigger' );
		Enable( 'Trigger' );
		SavedTrigger = Other;
		Instigator = EventInstigator;
		GotoState( 'LoopMove', 'Stopping' );
	}

	event KeyFrameReached();

	function BeginState()
	{
		bOpening = false;
		bDelaying = false;
	}

Running:
	FinishInterpolation();
	InterpolateTo( byte(KeyNum + 1) % NumKeys, MoveTime );
	GotoState( 'LoopMove', 'Running' );
Stopping:
	FinishInterpolation();
	FinishedOpening();
	UnTriggerEvent(Event, self, Instigator);
	bOpening = false;
	Stop;
}

//=================================================================
// Other Mover States

// Toggle when triggered.
state() TriggerToggle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if( KeyNum==0 || KeyNum<PrevKeyNum )
			GotoState( 'TriggerToggle', 'Open' );
		else
			GotoState( 'TriggerToggle', 'Close' );
	}
Open:
	bClosed = false;
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if ( SavedTrigger != None )
		SavedTrigger.EndEvent();
	Stop;
Close:		
	DoClose();
	FinishInterpolation();
	FinishedClosing();
}

// Open when triggered, close when get untriggered.
state() TriggerControl
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		numTriggerEvents++;
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		GotoState( 'TriggerControl', 'Open' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		numTriggerEvents--;
		if ( numTriggerEvents <=0 )
		{
			numTriggerEvents = 0;
			SavedTrigger = Other;
			Instigator = EventInstigator;
			SavedTrigger.BeginEvent();
			GotoState( 'TriggerControl', 'Close' );
		}
	}

	function BeginState()
	{
		numTriggerEvents = 0;
	}

Open:
	bClosed = false;
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	SavedTrigger.EndEvent();
	if( bTriggerOnceOnly )
		GotoState('');
	Stop;
Close:		
	DoClose();
	FinishInterpolation();
	FinishedClosing();
}

// Start pounding when triggered.
state() TriggerPound
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		numTriggerEvents++;
		SavedTrigger = Other;
		Instigator = EventInstigator;
		GotoState( 'TriggerPound', 'Open' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		numTriggerEvents--;
		if ( numTriggerEvents <= 0 )
		{
			numTriggerEvents = 0;
			SavedTrigger = None;
			Instigator = None;
			GotoState( 'TriggerPound', 'Close' );
		}
	}
	function BeginState()
	{
		numTriggerEvents = 0;
	}

Open:
	bClosed = false;
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	Sleep(OtherTime);
Close:
	DoClose();
	FinishInterpolation();
	Sleep(StayOpenTime);
	if( bTriggerOnceOnly )
		GotoState('');
	if( SavedTrigger != None )
		goto 'Open';
}

//-----------------------------------------------------------------------------
// Bump states.


// Open when bumped, close when reset.
state() BumpButton
{
	function Bump( actor Other )
	{
		if ( (BumpType != BT_AnyBump) && (Pawn(Other) == None) )
			return;
		if ( (BumpType == BT_PlayerBump) && !Pawn(Other).IsPlayerPawn() )
			return;
		if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
			return;
		Global.Bump( Other );
		SavedTrigger = Other;
		Instigator = Pawn( Other );
		Instigator.Controller.WaitForMover(self);
		GotoState( 'BumpButton', 'Open' );
	}
	function BeginEvent()
	{
		bSlave=true;
	}
	function EndEvent()
	{
		bSlave     = false;
		Instigator = None;
		GotoState( 'BumpButton', 'Close' );
	}
Open:
	bClosed = false;
	Disable( 'Bump' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if( bTriggerOnceOnly )
		GotoState('');
	if( bSlave )
		Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Bump' );
}

state() ConstantLoop
{
	event KeyFrameReached()
	{
		if ( bOscillatingLoop )
		{
			if ( (KeyNum == 0) || (KeyNum == NumKeys - 1) )
			{
				StepDirection *= -1;
				MoverLooped();
			}
			KeyNum += StepDirection;
			InterpolateTo( KeyNum, MoveTime );
		}
		else
		{
			InterpolateTo( byte(KeyNum + 1) % NumKeys, MoveTime );
			if ( KeyNum == 0 )
				MoverLooped();
		}
	}

	function BeginState()
	{
		bOpening = false;
		bDelaying = false;
	}

Begin:
	InterpolateTo( 1, MoveTime );
Running:
	FinishInterpolation();
	GotoState( 'ConstantLoop', 'Running' );
}

state() LeadInOutLooper
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( NumKeys < 3 )
		{
			log("LeadInOutLooper detected with <3 movement keys");
			return;
		}
		InterpolateTo( 1, MoveTime );
	}

	event KeyFrameReached()
	{
		if ( KeyNum != 0 )
		{
			InterpolateTo( 2, MoveTime );
			GotoState( 'LeadInOutLooping' );
		}
	}

	function BeginState()
	{
		bOpening = false;
		bDelaying = false;
	}
}

state LeadInOutLooping
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		InterpolateTo( 0, MoveTime );
		GotoState( 'LeadInOutLooper' );
	}

	event KeyFrameReached()
	{
		if ( bOscillatingLoop )
		{
			if ( (KeyNum == 1) || (KeyNum == NumKeys - 1) )
			{
				StepDirection *= -1;
				MoverLooped();
			}
			KeyNum += StepDirection;
			InterpolateTo( KeyNum, MoveTime );
		}
		else
		{
			KeyNum++;
			if ( KeyNum == NumKeys )
			{
				KeyNum = 1;
				MoverLooped();
			}
			InterpolateTo( KeyNum, MoveTime );
		}
	}
}

state() RotatingMover
{
	simulated function BaseStarted()
	{
		local Actor OldBase;

		bFixedRotationDir = true;
		OldBase = Base;
		SetPhysics( PHYS_Rotating );
		SetBase( OldBase );
	}

	simulated function BaseFinished()
	{
		local Actor OldBase;

		OldBase = Base;
		SetPhysics( PHYS_None );
		SetBase( OldBase );
		if ( bToggleDirection )
		{
			RotationRate.Yaw *= -1;
			RotationRate.Pitch *= -1;
			RotationRate.Roll *= -1;
		}
	}

	simulated function BeginState()
	{
		bAlwaysRelevant = true;
		RemoteRole = ROLE_None;
	}
}

defaultproperties
{
     MoverEncroachType=ME_ReturnWhenEncroach
     MoverGlideType=MV_GlideByTime
     NumKeys=2
     StepDirection=1
     bToggleDirection=True
     bClosed=True
     MoveTime=1.000000
     StayOpenTime=4.000000
     Physics=PHYS_MovingBrush
     RemoteRole=ROLE_SimulatedProxy
     bNoDelete=True
     bAcceptsProjectors=True
     m_bHandleRelativeProjectors=True
     bAlwaysRelevant=True
     bOnlyDirtyReplication=True
     bShadowCast=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bEdShouldSnap=True
     bPathColliding=True
     m_bTickOnlyWhenVisible=True
     CollisionRadius=160.000000
     CollisionHeight=160.000000
     NetPriority=2.700000
     InitialState="BumpOpenTimed"
}
