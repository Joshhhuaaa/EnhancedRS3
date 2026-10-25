//=============================================================================
//  R6AIController.uc : This is the AI Controller class for all Rainbow6 characters.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    2001/05/07  Joel Tremblay : Add the Stun and Kill Tables 
//                                with R6DamageAttitudeTo
//    2001/06/20 - Eric : Add the PatrolNode navigation
//    2001/11/19 - Jean-Francois Dube : Added interactive actions
//=============================================================================
class R6AIController extends AIController
    native 
    abstract;

var         R6Pawn              m_r6pawn;               // remove r6pawn() cast
var         vector              m_vTargetPosition;
var         vector              m_vPreviousPosition;
var         R6Ladder            m_TargetLadder;

CONST       C_fMaxBumpTime = 1.f;                       // Max time to be in bumpbackup state 
var         Actor               m_BumpedBy;
var         name                m_bumpBackUpNextState;  // return state when BumpBackUp state is over
var         name                m_openDoorNextState;    // return state when OpenDoor state is over
var const   int                 c_iDistanceBumpBackUp;  // distance to backup
var         FLOAT               m_fLastBump;            // the time where the pawn was bumped
var         vector              m_vBumpedByLocation;    // used in state code 
var         vector              m_vBumpedByVelocity;    // used in state code 

var         bool                m_bStateBackupAvoidFacingWalls; // backup of the bool when entering a state
var         bool                m_bIgnoreBackupBump;    // this flag should be set to true during states that should not be interrupted by a notifyBump to backup...
var         bool                m_bGetOffLadder;

// climb object

var         R6ClimbableObject   m_climbingObject;
var         name                m_climbingObjectNextState;  // return state when BumpBackUp state is over

var         INT                 m_iCurrentRouteCache;

// For debug purpose
var(Debug)  BOOL                bShowLog;
var(Debug)  BOOL                bShowInteractionLog;

//InteractiveObjects
var         R6InteractiveObject m_InteractionObject;
var         Actor               m_ActorTarget;
var         name                m_AnimName;
var         FLOAT               m_fLoopAnimTime;
var         name                m_StateAfterInteraction;
var         BOOL                m_bChangingState;
var         BOOL                m_bCantInterruptIO;
var			BOOL				m_bMoveTargetAlreadySet;

var         R6IORotatingDoor    m_closeDoor; // the door too close after opening one

//Matinee SubActions: clauzon 03/04/2001
/*MATINEE_AI_MODE see R6Engine/classes/backup/R6ActionExecuteAI.uc
var         R6SubActionGoto             m_SubActionGoto;
var         vector                      m_AttachPos;
var         rotator                     m_AttachRot;
*/

// Find the best path to run away from an enemy (you must set Enemy before calling this)
native(1810) final function BOOL MakePathToRun();
// Find the closest available spot
native(1811) final function R6ActionSpot FindPlaceToTakeCover( vector vThreatLocation, FLOAT fMaxDistance );
native(1817) final function R6ActionSpot FindPlaceToFire( actor pTarget, vector vDestination, FLOAT fMaxDistance );
native(1818) final function R6ActionSpot FindInvestigationPoint( INT iSearchIndex, FLOAT fMaxDistance, optional BOOL bFromThreat, optional vector vThreatLocation );

native(1813) final function BOOL PickActorAdjust(Actor pActor);

// RBrek 13 Aug 2001 - Latent move function that will gradually move pawn to a certain location and orientation/rotation in
//                      a certain amount of time...
native(2201) final function MoveToPosition(vector vPosition, rotator rOrientation); 

// Latent function to follow a path already calculated with function like FindPathTo and FindPathToward
native(1812) final function FollowPath( optional R6Pawn.eMovementPace ePace, optional name returnLabel, optional BOOL bContinuePath );
native(1814) final function FollowPathTo( vector vDestination, optional R6Pawn.eMovementPace ePace, optional actor aTarget );

// Check if the pawn can go to the destination with a MoveTo
native(1815) final function bool CanWalkTo( vector vDestination, OPTIONAL BOOL bDebug );
native(1816) final function rotator FindGrenadeDirectionToHitActor( Actor aTarget, vector vTargetLoc, FLOAT fGrenadeSpeed );
native(1509) final function bool NeedToOpenDoor(Actor target);
native(1510) final function GotoOpenDoorState( R6Door navPointToOpenFrom );
native(2209) final function FindNearbyWaitSpot(Actor node, out vector vWaitLocation);
native(2220) final function bool ActorReachableFromLocation(Actor target, vector vLocation);

function Possess(Pawn aPawn)
{
    super.Possess( aPawn );

    m_r6pawn = R6Pawn( aPawn );
    m_r6pawn.SetFriendlyFire();
}

function Tick(FLOAT fDeltaTime)
{
    Super.Tick(fDeltaTime);

    if (pawn != None)
    {
        pawn.m_bIsFiringWeapon = bFire; //(bFire > 0);
#ifdefDEBUG
        m_r6pawn.UpdateBones();
#endif
        if(m_r6pawn.m_TrackActor != none)
        {
            // IMPORTANT!! EnemyNotVisible() should be used to disable the TrackActor feature when the target actor is no longer visible
            if(IsActorInView(m_r6pawn.m_TrackActor))
            {
                m_r6pawn.UpdatePawnTrackActor();
            }
            else
            {
                m_r6pawn.TurnToFaceActor(m_r6pawn.m_TrackActor);
            }
        }
    }
}

function bool IsActorInView(Actor actor)
{
    if((actor.location - pawn.location) dot vector(pawn.rotation) < 0)
        return false;
    else
        return true;
}

function bool IsActorRightOfView(Actor actor)
{
    if((actor.location - pawn.location) dot vector(pawn.rotation) < 0)
        return false;
    else
        return true;
}

event R6SetMovement(R6Pawn.eMovementPace ePace)
{
    //if(bShowLog) log( name $ " playing animation for pace: " $ ePace $ " bIsCrouched: " $ pawn.bIsCrouched $ " bWantsToCrouch: " $ pawn.bWantsToCrouch $ " bIsWalking: " $ pawn.bIsWalking );  
    if ( !pawn.m_bIsProne && (ePace == PACE_Prone) )
    {
        pawn.m_bWantsToProne = true;
    }
    else if ( pawn.m_bIsProne && (ePace != PACE_Prone) )
    {
        pawn.m_bWantsToProne = false;
        pawn.bWantsToCrouch = true;
    }
    else if(pawn.bIsCrouched)
    {
        if((ePace == PACE_Walk) || (ePace == PACE_Run))
        {
            pawn.bWantsToCrouch = false;
        }
    }
    else
    {
        if((ePace == PACE_CrouchWalk) || (ePace == PACE_CrouchRun))
        {
            pawn.bWantsToCrouch = true;
        }
    } 

    if((ePace == PACE_Walk) || (ePace == PACE_CrouchWalk) || (ePace == PACE_Prone))
    {
        if(!pawn.bIsWalking)
        {
            pawn.SetWalking(true);  
        }
    }
    else if((ePace == PACE_Run) || (ePace == PACE_CrouchRun))
    {
        if(pawn.bIsWalking)
        {
            pawn.SetWalking(false);  
        }
    }

    m_r6pawn.m_eMovementPace = ePace;
}

//------------------------------------------------------------------
// CheckPaceForInjury()                                           
//   17 jan 2002 rbrek                  
//   Rainbow cannot run if injured, walk only...        
//------------------------------------------------------------------
function CheckPaceForInjury(out R6Pawn.eMovementPace ePace)
{
    if( m_r6pawn.m_eHealth == HEALTH_Wounded)
    {
        if(ePace == PACE_CrouchRun)
            ePace = PACE_CrouchWalk;
        else if(ePace == PACE_Run)
            ePace = PACE_Walk;
    }   
    /*
    if (bShowlog){
        switch( m_eMovementPace)
        {
            case PACE_None:         logX( "None" );      break;
            case PACE_Prone:        logX( "Prone" );     break;
            case PACE_CrouchWalk:   logX( "CrouchWalk"); break;
            case PACE_CrouchRun:    logX( "CrouchRun");  break;
            case PACE_Walk:         logX( "Walk");       break;
            case PACE_Run:          logX( "Run");        break;
            default:                logX( "Unknown");    break;
    }}*/
}

// the following movement functions will handle moving the pawn in the right direction
// with a desired orientation, and at the right speed/velocity.
// if a focus is not specified, 
function R6PreMoveTo(vector vTargetPosition, vector vFocus, R6Pawn.eMovementPace ePace)
{
    CheckPaceForInjury(ePace);
    R6SetMovement(ePace);

    // these are set for GetFacingDirection()...
    focus = none;
    focalPoint = vFocus;
    destination = vTargetPosition;
}

function R6PreMoveToward(actor target, actor pFocus, R6Pawn.eMovementPace ePace)
{
    CheckPaceForInjury(ePace);
    R6SetMovement(ePace);

    // these are set for GetFacingDirection()...
    focus = none;
    focalPoint = pFocus.location;
    destination = target.location;
}

/* GetFacingDirection()
returns direction faced relative to movement dir

0 = forward
16384 = right
32768 = back
49152 = left
*/
// override the version in AIController.uc so that only depend on focalpoint and destination...
function int GetFacingDirection()
{
    local float fStrafeMag;
    local vector vFocus2D, vLoc2D, vDest2D, vDir, vLookDir, vY;

    if(focalPoint == destination)
        return 0;

    // check for strafe or backup
    vFocus2D = focalPoint;
    vFocus2D.Z = 0;
    vLoc2D = pawn.location;
    vLoc2D.Z = 0;
    vDest2D = destination;
    vDest2D.Z = 0;
    vLookDir = Normal(vFocus2D - vLoc2D);
    vDir = Normal(vDest2D - vLoc2D);
    fStrafeMag = vLookDir dot vDir;
    if ( fStrafeMag < 0.75 )
    {
        if ( fStrafeMag < -0.75 )
            return 32768;
        else
        {
            vY = (vLookDir cross vect(0,0,1));
            if ((vY Dot (vDest2D - vLoc2D)) > 0)
                return 49152;
            else
                return 16384;
        }
    }

    return 0;
}


//------------------------------------------------------------------
// CanClimbLadders
//  
//------------------------------------------------------------------
function bool CanClimbLadders( R6Ladder ladder )
{
    return m_r6pawn.m_bAutoClimbLadders;
}

//------------------------------------------------------------------
// CanClimbObject: true if the pawn can climb r6ClimableObject. 
//  - needed for inheritance
//------------------------------------------------------------------
function bool CanClimbObject()
{
    return m_r6pawn.m_bCanClimbObject;
}

function CheckNeedToClimbLadder();

//----------------------------//
// -- state WAITFORLADDER  -- //
//----------------------------//
state WaitToClimbLadder
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$"...entered WaitToClimbLadder state..."); #endif
        //m_TargetLadder must be valid...
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$"...exited WaitToClimbLadder state..."); #endif
    }

	function vector GetWaitPosition()
	{
		if(m_TargetLadder.m_bIsTopOfLadder)
			return(m_TargetLadder.location + 200*vector(m_TargetLadder.rotation + rot(0,8192,0)));
		else
			return(m_TargetLadder.location - 200*vector(m_TargetLadder.rotation + rot(0,8192,0)));
	}

Begin:
    // move to an appropriate position to wait...
	destination = GetWaitPosition();
    R6PreMoveTo(destination, m_TargetLadder.location, PACE_Walk); 
    MoveTo(destination, m_TargetLadder);    
    StopMoving();
    #ifdefDEBUG if(bShowLog) log(pawn$" has reached a position to wait to climb ladder..."); #endif

Wait:
    Sleep(1.0);
    // wait for ladder to become free...
    if(LadderIsAvailable())
    {
        #ifdefDEBUG if(bShowLog) log(m_TargetLadder.myLadder$" is now available!! for "$pawn$" to climb..."); #endif
		
		moveTarget = m_TargetLadder; 
		Sleep(2.0);  // allow for an additional small delay to ensure that ladder has been cleared...
		GotoState('ApproachLadder');
    }
    else
        Goto('Wait');
}

function ConfirmLadderActionPointWasReached(R6Ladder ladder);

function bool LadderIsAvailable()
{
	local R6LadderVolume ladderVol;

	ladderVol = R6LadderVolume(m_TargetLadder.myLadder);

	if(!ladderVol.IsAvailable(Pawn))
		return false;

	if(m_TargetLadder.m_bIsTopOfLadder && ladderVol.IsAShortLadder() && !ladderVol.SpaceIsAvailableAtBottomOfLadder(true))
		return false;

	return true;
}

//----------------------------//
// -- state APPROACHLADDER -- //
//----------------------------// 
// * this state assumes that controller.moveTarget has been set to the R6Ladder actor at the start 
// of the ladder that the pawn is supposed to climb 
// * when pawn finishes climbing the ladder, will enter state Dispatcher... will only exit state 
// Dispatcher if/when nextState != '' 
state ApproachLadder
{
ignores SeePlayer, HearNoise;

    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$"...entered ApproachLadder state...moveTarget="$moveTarget); #endif
		m_TargetLadder = R6Ladder(moveTarget);
        m_bStateBackupAvoidFacingWalls = m_r6pawn.m_bAvoidFacingWalls;
        m_r6pawn.m_bAvoidFacingWalls = false;
		pawn.m_bCanProne = false;
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$"...exited ApproachLadder state..."); #endif
		pawn.m_bCanProne = true;
		if(pawn.physics != PHYS_Ladder)
			R6LadderVolume(m_TargetLadder.myLadder).RemoveClimber(m_r6pawn);
    }

	function bool ReadyToClimbLadder()
	{
		local R6RainbowAI  rainbowAI;

		rainbowAI = R6RainbowAI(m_r6pawn.controller);
		rainbowAI.m_TeamManager.SetTeamIsClimbingLadder(true);

		if( ((rainbowAI.m_TeamManager.m_iTeamAction & TEAM_ClimbLadder) > 0) && rainbowAI.m_TeamManager.m_bCAWaitingForZuluGoCode)
			return false;

		return true;
	}

Begin:    
    pawn.SetBoneRotation('R6 Spine1', rot(0,0,0),, 1.0);

    //TODO:  check if pawn is already at the R6Ladder actor (check distance between pawn and moveTarget ***...    
    // assume that moveTarget was set to the R6Ladder actor at the beginning of the ladder we wish to climb
    if(m_TargetLadder == none) 
        GotoState('Dispatcher');

    // check to make sure that no pawn is already on the ladder...
    if(!LadderIsAvailable())
        GotoState('WaitToClimbLadder'); 

    R6LadderVolume(m_TargetLadder.myLadder).AddClimber(m_r6pawn);

MoveToStartOfLadder:
    #ifdefDEBUG if(bShowLog) log(pawn$" approaches beginning of ladder...m_TargetLadder="$m_TargetLadder);  #endif
	// WAIT : check if it is still necessary to climb the ladder.... where is pacemember?)
	CheckNeedToClimbLadder();

    // move to ladder
    R6PreMoveToward(m_TargetLadder, m_TargetLadder, PACE_Walk);
    MoveToward(m_TargetLadder); 
	if(DistanceTo(m_TargetLadder) >= 40)
    {
        StopMoving();
        Sleep(1.0);
        Goto('MoveToStartOfLadder');
    }
    
	ConfirmLadderActionPointWasReached(m_TargetLadder);

WaitForZuluGoCode:
    if( m_r6pawn.m_ePawnType == PAWN_Rainbow )
    {
		if(!ReadyToClimbLadder())
        {
            Sleep(0.5);
            goto('WaitForZuluGoCode');
        }
    }
        
Wait:
    Sleep(0.5); 

    //TODO : FIXTHIS!!! only do this if we are a potential climber...state PotentialClimb
    //  *** we should not even be here if the laddervolume has not detected this pawn....*****
    if(!m_TargetLadder.m_bIsTopOfLadder)  // if we are at the top, play the animation that includes turning...
    {
        destination = m_TargetLadder.location;
        destination.z = pawn.location.z;  
        MoveToPosition(destination, m_TargetLadder.rotation);
    }       
    else
    { 
        destination = m_TargetLadder.location + 50*vector(m_TargetLadder.rotation);
        destination.z = pawn.location.z;  
        MoveToPosition(destination, m_TargetLadder.rotation + rot(0,32768,0));
    }

    // pawn should get into (almost exactly) the right position, and keep trying until pawn does.
    if((VSize(pawn.location - destination) >= 10))
    {
        #ifdefDEBUG if(bShowLog) log(pawn$" did not get into exactly the right position, so try again.... "); #endif
        Sleep(1.0);
        Goto('Wait');
    }

    #ifdefDEBUG if(bShowLog) log(pawn$" in state ApproachLadder : m_TargetLadder ="$m_TargetLadder$" m_r6pawn.m_potentialActionActor="$m_r6pawn.m_potentialActionActor); #endif
    // note: MoveToPosition() and MoveTo() both reset moveTarget to none...
    if((m_r6pawn.m_potentialActionActor == none) || (!m_r6pawn.m_potentialActionActor.IsA('R6LadderVolume')))
    {
        moveTarget = m_TargetLadder;  // moveTarget has been reset to none by MoveToPosition()
        goto('Wait');
    }

    // we need to make sure that pawn has succeeded in reaching beginning of ladder... otherwise they should keep trying... 
    // make sure pawn is not already climbing a ladder
    if(!m_r6pawn.m_bIsClimbingLadder)
    {       
        // check to make sure that no pawn is already on the ladder...
        if(!R6LadderVolume(m_TargetLadder.myLadder).IsAvailable(Pawn))
        {
            GotoState('WaitToClimbLadder'); 
        }

		m_r6pawn.ClimbLadder(LadderVolume(m_r6pawn.m_potentialActionActor));  
    }
}

function bool AreClimbingInSameDirection(R6Pawn npcPawn, R6Pawn playerPawn)
{
    if(playerPawn.velocity.z != 0.0)
    {
        if(npcPawn.IsMovingUpLadder() == playerPawn.IsMovingUpLadder())
            return true;
    }

    return false;
}

//---------------------------------//
// -- state BEGINCLIMBINGLADDER -- //
//---------------------------------//
state BeginClimbingLadder
{
ignores SeePlayer, HearNoise;
 
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$"...entered BeginClimbingLadder state..."); #endif
		pawn.m_bCanProne = false;
        disable('NotifyBump');
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$"...exited BeginClimbingLadder state..."); #endif
		pawn.m_bCanProne = true;
		m_bMoveTargetAlreadySet = false;
		pawn.LadderSpeed = pawn.default.LadderSpeed;
    }

    event bool NotifyBump(Actor other)
    {
        local R6Pawn bumpingPawn;

        if(!other.IsA('R6Pawn'))
            return false;           // 13 jan 2002 rbrek - ignore notifyBump events for non pawns

        m_BumpedBy = other;
        bumpingPawn = R6Pawn(other);

        if(bumpingPawn.m_bIsClimbingLadder && !AreClimbingInSameDirection(m_r6pawn, bumpingPawn)) 
        {           
            if(!bumpingPawn.m_bIsPlayer)
            {
                #ifdefDEBUG if(bShowLog) log(pawn$" has bumped into another NPC on the ladder!!! "$bumpingPawn$" whose velocity is "$bumpingPawn.velocity$" and state="$bumpingPawn.controller.GetStateName()); #endif
                if(R6AIController(bumpingPawn.controller).DistanceTo(bumpingPawn.m_Ladder) < DistanceTo(m_r6pawn.m_Ladder))
                    return false;
            }

            #ifdefDEBUG if(bShowLog) log(pawn$" has been bumped by player!! so change direction and get off!! ");            #endif
            pawn.ladderSpeed = 200;			
			if(pawn.velocity.z > 0)
				moveTarget = R6LadderVolume(pawn.OnLadder).m_BottomLadder;
            else
                moveTarget = R6LadderVolume(pawn.OnLadder).m_TopLadder;
                       
			pawn.bIsWalking = false;
            m_bGetOffLadder = true;
            return true;
        }   
		
		if(!bumpingPawn.m_bIsClimbingLadder)
		{
			Gotostate('BeginClimbingLadder', 'BlockedAtTop');
			return true;
		}
    }

Begin:
    if(pawn.bIsCrouched)
        pawn.bWantsToCrouch = false;
	Sleep(0.5);

	if(pawn.m_ePawnType == PAWN_Rainbow)
	{
		m_r6pawn.SetNextPendingAction(PENDING_SecureWeapon); 
		FinishAnim(m_r6pawn.C_iWeaponRightAnimChannel); 

		if(!LadderIsAvailable())
		{
			m_r6pawn.m_bIsClimbingLadder = false;
			R6LadderVolume(m_TargetLadder.myLadder).RemoveClimber(m_r6pawn);
			pawn.SetPhysics(PHYS_Walking);
			m_r6pawn.SetNextPendingAction(PENDING_EquipWeapon); 			    
			GotoState('WaitToClimbLadder'); 	
		}
	}

    m_r6pawn.m_bIsClimbingLadder = true;    
    pawn.LockRootMotion(1, true);
    m_r6pawn.SetNextPendingAction(PENDING_StartClimbingLadder);

WaitForStartClimbingAnimToEnd:	
    FinishAnim();

StartLadder:
    m_r6pawn.SetNextPendingAction(PENDING_PostStartClimbingLadder); 
    FinishAnim(m_r6pawn.C_iBaseBlendAnimChannel);
    pawn.SetRotation(pawn.OnLadder.LadderList.Rotation);
    SetRotation(pawn.OnLadder.LadderList.Rotation);
    focus = none;

	if(m_bMoveTargetAlreadySet && moveTarget != none)
		Goto('MoveTowardEndOfLadder');

    if(m_r6pawn.m_Ladder.m_bIsTopOfLadder)
    {
        pawn.SetLocation(pawn.location + 15*vector(pawn.rotation));  
        m_TargetLadder = R6LadderVolume(pawn.OnLadder).m_BottomLadder;   
    }
    else
    { 
        // need this otherwise pawn will end up in wall/geometry  (root bone is not centered)
        if ( m_r6pawn.m_ePawnType != PAWN_Hostage )
            pawn.SetLocation(pawn.location - 20*vector(pawn.rotation));
        m_TargetLadder = R6LadderVolume(pawn.OnLadder).m_TopLadder; 
    }
    moveTarget = m_TargetLadder;

MoveTowardEndOfLadder:
    Enable('NotifyBump');
    Pawn.Anchor = NavigationPoint(moveTarget);      // For follow path to know where the pawn is now
    
    // rainbow members always climb ladder fast...
    if(m_r6pawn.m_ePawnType == PAWN_Rainbow && m_r6pawn.m_eHealth == HEALTH_Healthy)
        pawn.bIsWalking = false;
    
    MoveToward(moveTarget);  
    
    if(m_r6pawn.m_ePawnType == PAWN_Rainbow)
        pawn.bIsWalking = true;

    Sleep(2);
    Goto('MoveTowardEndOfLadder');

BlockedAtTop:
	StopMoving();
	Sleep(1.5);
	moveTarget = m_TargetLadder;
	goto('MoveTowardEndOfLadder');
}

//-------------------------------//
// -- state ENDCLIMBINGLADDER -- //
//-------------------------------//
state EndClimbingLadder
{
ignores SeePlayer, HearNoise;

    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$"...entered EndClimbingLadder state...pawn.location="$pawn.location); #endif
        pawn.acceleration = vect(0,0,0);
		Disable('NotifyBump');
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) log(pawn$"...exited EndClimbingLadder state...pawn.location="$pawn.location); #endif
        pawn.onLadder = None; 
		m_r6pawn.m_bIsClimbingLadder = false; 		
		// fixes bug : player dies, and switches to an AI that is getting off ladder, AI is switched to state DEAD, 
		// and bCollideWorld is never set back to true, player falls through map.
		pawn.bCollideWorld = true;	
        m_r6pawn.m_bAvoidFacingWalls = m_bStateBackupAvoidFacingWalls;
    }

    function bool NotifyHitWall(vector HitNormal, actor Wall)
    {
        return true; //pawn won't get notified...
    }

    function ClimbLadderIsOver()
    {
        local INT i;
        
        m_r6pawn.m_Ladder = none;
        pawn.OnLadder = none;

        // Check if we want to go to the other end of that ladder
        while(i<16)
        {
            RouteCache[i] = none;
            ++i;
        }        
    }

Begin:
	if(!m_r6pawn.m_bIsClimbingLadder)
		goto('End');

    if(m_r6pawn.m_Ladder.m_bIsTopOfLadder || pawn.bIsWalking || (m_r6pawn.m_ePawnType != PAWN_Rainbow))
        pawn.LockRootMotion(1, true);

    m_r6pawn.SetNextPendingAction(PENDING_EndClimbingLadder); 	
	
WaitForEndClimbingAnimToEnd:
    FinishAnim(0);   
	m_r6pawn.m_bSlideEnd = false;

	ConfirmLadderActionPointWasReached(m_r6pawn.m_Ladder);

EndClimb:
    m_r6pawn.m_ePlayerIsUsingHands=HANDS_Both;
    pawn.SetPhysics(PHYS_Walking);
    m_TargetLadder = m_r6pawn.m_Ladder;
    if(m_r6pawn.m_Ladder.m_bIsTopOfLadder)
    {
        m_r6pawn.SetNextPendingAction(PENDING_PostEndClimbingLadder); 
        //  pawn.SetLocation(pawn.location + 10*vector(pawn.rotation));    // todo rbrek
        FinishAnim(m_r6pawn.C_iBaseBlendAnimChannel);
    }
    else if(pawn.bIsWalking || (m_r6pawn.m_ePawnType != PAWN_Rainbow))
    {
        m_r6pawn.SetNextPendingAction(PENDING_PostEndClimbingLadder); // todo : need to have a more exact animation so that zero tweening will look good.
        //  pawn.SetLocation(pawn.location + 25*vector(pawn.rotation));     // todo rbrek : adjustments to make later...
        FinishAnim(m_r6pawn.C_iBaseBlendAnimChannel);
    }
    focus = pawn.onLadder;
    focalPoint = pawn.onLadder.location;
    moveTarget = none;
	m_r6pawn.m_bIsClimbingLadder = false; 

	if(pawn.m_ePawnType == PAWN_Rainbow)
		m_r6pawn.SetNextPendingAction(PENDING_EquipWeapon); 		
	Enable('NotifyBump');

End:
    if(m_r6pawn.m_Ladder.m_bIsTopOfLadder)   
    {
        Destination = pawn.location + 120*pawn.onLadder.lookDir;         
        #ifdefDEBUG if(bShowLog) log("we are at the top of the ladder (pawn.location="$pawn.location$") so move forward to Destination="$Destination); #endif
        R6PreMoveTo(Destination, Destination, PACE_Walk);  
        MoveTo(Destination);        
    }
    else
    {
        Destination = pawn.location - 120*pawn.onLadder.lookDir;         
        #ifdefDEBUG if(bShowLog) log("we are at the bottom of the ladder (pawn.location="$pawn.location$") so move back and play walking"); #endif
        R6PreMoveTo(Destination, pawn.onLadder.location, PACE_Walk);  
        MoveTo(Destination, pawn.onLadder);     
    }
	StopMoving();

    //==TEAM AI==================================================//
    if( m_r6pawn.m_ePawnType == PAWN_Rainbow )
    {        
        if(!m_bGetOffLadder)
            R6RainbowAI(pawn.controller).m_TeamManager.MemberFinishedClimbingLadder(m_r6pawn);  
    }
    else if ( m_r6pawn.m_ePawnType == PAWN_Hostage )
    {
        ClimbLadderIsOver();
    }
    //===========================================================//
    
    if(m_bGetOffLadder)
    {
        m_bGetOffLadder = false;
        GotoState('WaitToClimbLadder');
    }
    else if(nextState != '')
        GotoState( nextState, nextLabel );   // should we reset nextState to ''?? TODO??
    else
        GotoState('Dispatcher');  
}

//------------------------//
// -- state DISPATCHER -- //
//------------------------//
state Dispatcher
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) log(" ... entered state Dispatcher..."); #endif
    }

Begin:
    Sleep(3); 
    if(nextState != '')
        GotoState(nextState);

    Goto('Begin');
}

state Dead
{
ignores SeePlayer, NotifyBump, R6DamageAttitudeTo, HearNoise, EnemyNotVisible;
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX( Pawn.Name $" has died...."); #endif
                
        StopMoving();
        SetLocation(Pawn.Location);
    }
}

// Called when killed
function PawnDied()
{
    GotoState('Dead');
}

//------------------------------------------------------------------
// StopMoving
//  
//------------------------------------------------------------------
function StopMoving()
{
    if ( pawn == none ) // if dead, return
        return;
        
    pawn.acceleration = vect(0,0,0);
    pawn.velocity = vect(0,0,0);
    moveTarget = none;
    Pawn.SetWalking(true);
}

//------------------------------------------------------------------//
// function NotifyBump()                                            //
//------------------------------------------------------------------//
event bool NotifyBump(Actor other)
{
    if(!other.IsA('R6Pawn'))    // 13 jan 2002 rbrek - ignore notifyBump events for non pawns
        return false;

    // if i'm stationary OR the other pawn has priority to pass, bump
    if( m_r6pawn.IsStationary() || !m_r6pawn.HasBumpPriority( r6pawn(other) ) ) 
    {              
        if( !m_bIgnoreBackupBump && !IsInState( 'ApproachLadder' ))      
        {           
            // this pawn is stationary...  so backup...
			StopMoving();
            m_BumpedBy = other;            
            if ( GetStateName() != 'BumpBackUp' )
                GotoBumpBackUpState( GetStateName() );
            else
                GotoBumpBackUpState( m_bumpBackUpNextState );
            return true;
        }  
        else
            return false;
    }        
    else        
		return PickActorAdjust(other);   
}

//==========================================================//
//                  -- state ClimbObject --                  //
//==========================================================//

/* // R6CLIMBABLEOBJECT
//------------------------------------------------------------------
// GotoClimbObjectState: initialize and sets the current state to 
//  ClimbObject.
//------------------------------------------------------------------
function GotoClimbObjectState( R6ClimbableObject climbingObject, name returnState )
{
    m_climbingObject = climbingObject;
    m_climbingObjectNextState = returnState;
    GotoState( 'ClimbObject' );
}

//------------------------------------------------------------------
// state: ClimbObject
//  
//------------------------------------------------------------------
state ClimbObject
{
    ignores SeePlayer, HearNoise, NotifyBump; 
    
    function BeginState()
    {
        #ifdefDEBUG if ( bShowLog ) logX( "begin state" );       #endif

        StopMoving();
        m_bStateBackupAvoidFacingWalls = m_r6pawn.m_bAvoidFacingWalls;
        m_r6pawn.SetAvoidFacingWalls( false );
    }

    function EndState()
    {
        m_r6pawn.SetAvoidFacingWalls( m_bStateBackupAvoidFacingWalls );
    }   

    function FixLocationAfterClimbing( INT iNewZ )
    {
        local vector vLoc;

        vLoc = pawn.location;
        vLoc.Z = iNewZ;

        pawn.SetLocation( vLoc );
    }

Begin:
    StopMoving();
    // set pace and orientation
    if ( R6Rainbow( pawn ) != none )
        R6RainbowAI( pawn.controller ).R6PreMoveToward( m_climbingObject, m_climbingObject );
    else
        R6PreMoveToward( m_climbingObject, m_climbingObject, m_r6pawn.m_eMovementPace );
        
    Sleep(0.5);

    m_fLastBump = Level.TimeSeconds;
    while ( !m_climbingObject.IsClimbableBy( m_r6pawn, true, true ) )
    {
         // log ( "wait can't climb object now" );
        Sleep( 0.3 );

        if ( Level.TimeSeconds > m_fLastBump + 3 )
        {
            goto( 'EndClimbing' );
            break;
        }
    }
    
    if (pawn.bIsCrouched && R6Rainbow(pawn) != none )
    {
        R6Rainbow(pawn).EndKneeDown();
        FinishAnim(m_r6pawn.C_iBaseBlendAnimChannel);
    }

    m_r6pawn.m_climbObject = m_climbingObject;
 
    // begin climbing anim
    pawn.LockRootMotion(1, false);
    m_r6pawn.StopAnimating();
    m_r6pawn.SetNextPendingAction(PENDING_StartClimbingObject);
    
    // end climbing anim
    FinishAnim();
    m_r6pawn.SetNextPendingAction(PENDING_PostStartClimbingObject);

    if ( pawn.bIsCrouched )
        pawn.SetLocation(pawn.location + vect(0,0,20));                 
    
    FinishAnim( m_r6pawn.C_iBaseBlendAnimChannel );
    m_r6pawn.m_bPostureTransition = false;
    m_r6pawn.PlayWaiting();

    //log("current z: " $pawn.location.Z );

    if ( pawn.bIsCrouched && R6Rainbow(pawn) != none )
        R6Rainbow(pawn).BlendKneeOnGround();

EndClimbing:
    Focus = none;
    m_climbingObject = none;

    if ( m_climbingObjectNextState != '' )   
    {
        GotoState( m_climbingObjectNextState );
    }       
    else
    {
        ClimbObjectStateFinished();
    }
}


//------------------------------------------------------------------
// ClimbObjectStateFinished: function fired if there is not a 
//  return state (in m_climbingObjectNextState)
//------------------------------------------------------------------
function ClimbObjectStateFinished()
{
    log( "ScriptWarning: ClimbObjectStateFinished was not inherited" );
}*/


//==========================================================//
//                  -- state BUMPBACKUP --                  //
//==========================================================//

function bool IsInCrouchedPosture()
{
    return pawn.bIsCrouched;
}

//------------------------------------------------------------------
// GotoBumpBackUpState: initialize and sets the current state to 
//  BumpBackUp.
//------------------------------------------------------------------
function GotoBumpBackUpState( name returnState )
{
    if(returnState == 'BumpBackUp')
    {
        return;
    }
    m_bumpBackUpNextState = returnState;
    GotoState( 'BumpBackUp' );
}

//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish()
{
    // Check first if we are in this state from too long
    if(m_fLastBump + C_fMaxBumpTime < Level.TimeSeconds)
        return true;

    return (DistanceTo(m_BumpedBy) >= c_iDistanceBumpBackUp);
}

//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a 
//  return state (in m_bumpBackUpState_nextState)
//------------------------------------------------------------------
function BumpBackUpStateFinished()
{
    log( "ScriptWarning: BumpBackUpStateFinished was not inherited" );
}

//------------------------------------------------------------------
// DistanceTo: distance to a pawn without considering the Z axis
//  
//------------------------------------------------------------------
function FLOAT DistanceTo(Actor member, optional bool bIncludeZ)
{
    local   vector  vDistance;
	
	if(member == none)
		return 0.f;

    vDistance = pawn.location - member.location;
    if(!bIncludeZ)
		vDistance.z = 0.f;
    return (VSize(vDistance));
}

//------------------------------------------------------------------
// state: BumpBackUp
//  
//------------------------------------------------------------------
state BumpBackUp
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin state   m_BumpedBy="$m_BumpedBy );      #endif
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) logX( "end state" );         #endif
		StopMoving();
    }   

    function bool MoveRight()
    {
        local vector vProduct;

        m_vBumpedByLocation = m_BumpedBy.location;
        m_vBumpedByLocation.z = pawn.location.z;

        vProduct = normal(m_BumpedBy.velocity) cross normal(pawn.location - m_vBumpedByLocation);
        if(vProduct.z > 0)
            return true;
        return false;
    }

    event bool NotifyBump(Actor other)
    {  
        if( other == m_BumpedBy || 
           (R6Pawn(other) != none) && R6Pawn(other).m_bIsPlayer)
        {
            m_BumpedBy = other;
            GotoState('BumpBackUp');
            return true;
        }           
        return false;
    }

    //------------------------------------------------------------------
    // GetReacheablePoint: get a reacheable pont behind the pawn.
    //	return false if fails to find a point
    //  Test to move away at 90' degree from the bumped actor. Try 4 times from 90 to 180,
    //   0        if fails, try to move away from 90 to 0.
    //   |
    //  pawn-->90
    //   |
    //   180
    //------------------------------------------------------------------
    function bool GetReacheablePoint( OUT vector vTarget, bool bNoFail )
    {
        local rotator   rRotation;
        local int       iYawIncrement;
        local int       iStartingYaw;
        local int       iTry;
        local int       iTryMax;
        local int       iTryOnAQuadrantMax;
        local vector    vDest;

        // the hostage gives more try
        if ( m_r6pawn.m_ePawnType == PAWN_Hostage ) 
            iTryMax = 7;
        else
            iTryMax = 1;
        
        iStartingYaw  = 16384;   // 90 degree
        iYawIncrement = 16384/3;
        iTryOnAQuadrantMax = 16384/iYawIncrement + 1; // maximum try on a quadrant.

        if ( !MoveRight() )
        {
            iStartingYaw  *= -1;
            iYawIncrement *= -1;
        }
        
        while ( iTry < iTryMax )
        {
            if ( iTry < iTryOnAQuadrantMax )  // try moving away: 90 to 180.
                rRotation.yaw = iStartingYaw + iYawIncrement*iTry;
            else                             // try moving 90 to 0
                rRotation.yaw = iStartingYaw + iYawIncrement*(iTry+1-iTryOnAQuadrantMax)*-1;            

            vDest = pawn.location + (c_iDistanceBumpBackUp)*vector(rotator(m_vBumpedByVelocity) + rRotation);

            if ( CanWalkTo( vDest ) || bNoFail )
            {
                vTarget = vDest;
                return true;
            }

            ++iTry;
        }
        
        // failed
        return false;
    }

Begin:
    if(m_BumpedBy.IsA('R6IORotatingDoor'))
    {
        Disable('NotifyBump');
        Goto('BackupFromDoor');
    }
    else if(!m_BumpedBy.IsA('R6Pawn'))
    {
        Disable('NotifyBump');
        Goto('BackupFromActor');
    }

    // force to stay on the same plane!
    m_vBumpedByLocation = m_BumpedBy.location;
    m_vBumpedByLocation.z = pawn.location.z;
    m_vBumpedByVelocity = m_BumpedBy.velocity;
    m_vBumpedByVelocity.z = pawn.velocity.z;

    //if(bShowLog) logX( " backing up... m_BumpedBy="$m_BumpedBy);
    
    // get a reacheable point
    if ( !GetReacheablePoint( m_vTargetPosition, false ) )
    {
        // failed, but try to move anyway
        GetReacheablePoint( m_vTargetPosition, true );
    }

    if ( pawn.m_bIsProne )
    {
        R6PreMoveTo(m_vTargetPosition, m_BumpedBy.location, PACE_Prone);
    }
    // special case for hostage, 
    else if( m_r6pawn.m_ePawnType == PAWN_Hostage  )
    {
        if ( IsInCrouchedPosture() ) // we don't have crouch run back / left / right anim, so crouch walk!
            R6PreMoveTo(m_vTargetPosition, m_BumpedBy.location, PACE_CrouchWalk); 
        else
            R6PreMoveTo(m_vTargetPosition, m_BumpedBy.location, PACE_Walk);
    }
    else if( m_r6pawn.m_ePawnType != PAWN_Rainbow && IsInCrouchedPosture() )
    {
        R6PreMoveTo(m_vTargetPosition, m_BumpedBy.location, PACE_CrouchRun ); 
    }
    else
    {
		if(m_r6pawn.m_ePawnType == PAWN_Rainbow)
			R6PreMoveTo(m_vTargetPosition, m_BumpedBy.location, PACE_Run); 
		else
			R6PreMoveTo(m_vTargetPosition, m_BumpedBy.location, PACE_Walk);
    }
    MoveTo(m_vTargetPosition, m_BumpedBy); 

    pawn.acceleration = vect(0,0,0);

    m_fLastBump = Level.TimeSeconds;
Wait:
    sleep(0.2);
    if( IsBumpBackUpStateFinish() )
        Goto('Finish');
    else
        Goto('Wait');

Finish:
    if( m_bumpBackUpNextState != '')   // to prevent a pawn from getting stuck in this state...
    {
        if(m_bumpBackUpNextState == 'ApproachLadder')
            moveTarget = m_TargetLadder;     
        GotoState( m_bumpBackUpNextState );
    }       
    else
        BumpBackUpStateFinished();

BackupFromDoor:
    #ifdefDEBUG if(bShowLog) log(pawn$" backup from door.... "); #endif
    m_r6pawn.m_bAvoidFacingWalls = false;
    SetLocation(Pawn.Location);
    m_vTargetPosition = R6IORotatingDoor(m_BumpedBy).GetTarget( Pawn, 225, true ); // 225 unit behind the door
    R6PreMoveTo(m_vTargetPosition, location, m_r6pawn.m_eMovementPace);
    MoveTo(m_vTargetPosition, self); 
    pawn.acceleration = vect(0,0,0);
    if ( m_bumpBackUpNextState == 'OpenDoor' )
        sleep(0.2); // little sleep if was trying to open the door
    else
        sleep(1.0);
    Goto('Finish');

BackupFromActor:
    #ifdefDEBUG if(bShowLog) log(pawn$" backup from actor.... "); #endif
    m_r6pawn.m_bAvoidFacingWalls = false;
    SetLocation(pawn.location);
    m_vTargetPosition = pawn.location - 120*normal(m_BumpedBy.location - pawn.location);
    m_vTargetPosition.z = pawn.location.z;
    R6PreMoveTo(m_vTargetPosition, location, m_r6pawn.m_eMovementPace);
    MoveTo(m_vTargetPosition, self); 
    pawn.acceleration = vect(0,0,0);
    sleep(1.0);
    Goto('Finish');
}

//------------------------------------------------------------------
// CanOpenDoor: check if the pawn has the ability to open the door
//  ie: in case it's locked.
//------------------------------------------------------------------
event bool CanOpenDoor( R6IORotatingDoor door )
{
    return true;
}

//------------------------------------------------------------------
// OpenDoorFailed: triggered when the pawn try to go in the state 
//  OpenDoor. Usually should go in another state
//------------------------------------------------------------------
event OpenDoorFailed()
{
    m_r6pawn.logWarning( "should be overwritted. ie: gotostate('doSomethingIfDoorIsLocked')" );
    
}

//------------------------------------------------------------------
// State to open a door: call GotoOpenDoorState to go in this state
//------------------------------------------------------------------ 
state OpenDoor
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif

        // the check canOpenDoor and the event OpenDoorFailed 
        // are done in the nativecode (see GotoOpenDoorState)
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) logX( "end" ); #endif
    }

    //------------------------------------------------------------------
    // NeedToMove: return true if the pawn need to move at the best spot 
    //  to open the rotatingDoor. the destination is passed in vDest.
    //------------------------------------------------------------------
    function bool NeedToMove( OUT vector vDest )
    {
        local   vector  vDoorLoc;
        local   vector  vSpotToGo;

        if ( m_r6pawn.m_Door == none )
            return false;

        vDoorLoc  = m_r6pawn.m_Door.m_RotatingDoor.GetTarget( pawn, 0, true ); 
        // approx distance to be to open a door
        vSpotToGo = m_r6pawn.m_Door.m_RotatingDoor.GetTarget( pawn, 75, true ); 
        vDest = vSpotToGo;

        return true;
    }

    // so the pawn won't collide with door
    function INT GetFurthestOffsetFromDoor( Actor actor )
    {
        // door width = 128 + 10 for a little offset
        return 128 + actor.CollisionRadius+10; 
    }

begin:
    if ( m_r6pawn.m_Door == none )     
        goto('end'); // no more door to open

    if ( m_r6pawn.m_door.m_RotatingDoor.m_bIsDoorClosed == false || 
         m_r6pawn.m_door.m_RotatingDoor.m_bInProcessOfOpening)
        goto('end'); // the door was opened
    
    if ( NeedToMove( m_vTargetPosition ) )
    {
        //logX( "need to move close" );
        SetLocation(Pawn.Location);
        R6PreMoveTo(m_vTargetPosition, location, m_r6pawn.m_eMovementPace);
        MoveToPosition( m_vTargetPosition, m_r6pawn.m_Door.Rotation ); 
    }

    ChangeOrientationTo( m_r6pawn.m_Door.Rotation );
    FinishRotation();

    if ( m_r6pawn.m_door.m_RotatingDoor.m_bIsDoorClosed == false || 
         m_r6pawn.m_door.m_RotatingDoor.m_bInProcessOfOpening )
        goto('end'); // the door was opened

    //logX( "open door" );
    // Unlock the door if locked
    if( m_r6pawn.m_door.m_RotatingDoor.m_bIsDoorLocked )
    {
        m_r6pawn.SetNextPendingAction(PENDING_OpenDoor, 1 );
        FinishAnim(m_r6pawn.C_iPawnSpecificChannel);
    }

    m_r6pawn.SetNextPendingAction(PENDING_OpenDoor, 0 );
    // sleep while the hand reach the door
    Sleep( 0.5 ); 
    
    if ( m_r6pawn.m_Door == none )
        goto('CloseDoor');
        
    // if the door will open on us
    if ( !m_r6pawn.m_door.m_RotatingDoor.ActorIsOnSideA( pawn ) )
    {
        // logX("move back" );
        m_vTargetPosition = m_r6pawn.m_Door.m_RotatingDoor.GetTarget( pawn, GetFurthestOffsetFromDoor(pawn), true ); 
        SetLocation(Pawn.Location);
        R6PreMoveTo(m_vTargetPosition, location, m_r6pawn.m_eMovementPace);
        m_r6pawn.m_Door.m_RotatingDoor.openDoor(m_r6pawn, 10000 );
        MoveToPosition( m_vTargetPosition, m_r6pawn.m_Door.Rotation ); 
    }
    else
    {
        m_r6pawn.m_Door.m_RotatingDoor.openDoor(m_r6pawn);
    }

    // check how long it should sleep depending where the door opens
    if ( m_r6pawn.m_door.m_RotatingDoor.ActorIsOnSideA( pawn ) )
    {
        if ( m_r6pawn.m_ePawnType == PAWN_Hostage && m_r6pawn.m_eMovementPace == PACE_Run )
            Sleep( 0.5 );
        else            
            Sleep( 0.3 ); // sleep while the anim play and the door opens
    }
    else
    {
        if ( m_r6pawn.m_ePawnType == PAWN_Hostage && m_r6pawn.m_eMovementPace == PACE_Run )
            Sleep( 1.5 );
        else
            Sleep( 1.0 ); // sleep while the anim play and the door opens
    }

    // give a try to close the door. if the actor is bumped, it will try to open/close again
    // the same door because he already succeeded to open the door
    if ( m_r6pawn.m_Door != none )
    {
        // set the door to close. needed if the pawn is bumped, he will knows that he has 
        // too close this door (and not to open it)
        m_closeDoor = m_r6pawn.m_Door.m_RotatingDoor;
        m_r6pawn.RemovePotentialOpenDoor( m_r6pawn.m_Door );
    }

CloseDoor:
    // close the door if not alrealdy close
    if ( m_closeDoor != none && 
         m_r6pawn.m_ePawnType == PAWN_Terrorist && 
         R6Terrorist(m_r6Pawn).m_eDefCon != DEFCON_1 &&
         (!m_closeDoor.m_bIsDoorClosed || m_closeDoor.m_bInProcessOfOpening ) )
    {
        // from here if bumped, forget about closing the door
        if ( !m_closeDoor.ActorIsOnSideA( pawn ) )
        {
            m_vTargetPosition = m_closeDoor.GetTarget( pawn, 0 );
        }
        else
        {
            m_vTargetPosition = m_closeDoor.GetTarget( pawn, GetFurthestOffsetFromDoor(pawn) );
        }

        SetLocation(Pawn.Location);
        R6PreMoveTo(m_vTargetPosition, location, m_r6pawn.m_eMovementPace);
        MoveToPosition( m_vTargetPosition, m_r6pawn.Rotation ); 
        m_closeDoor.closeDoor( m_r6pawn );
    }
    m_closeDoor = none;

end:
    GotoState( m_openDoorNextState );
}


//------------------------------------------------------------------
// TestMakePath
//------------------------------------------------------------------
function SetStateTestMakePath( Pawn anEnemy, R6Pawn.eMovementPace ePace )
{
    Enemy = anEnemy;
    m_r6pawn.m_eMovementPace = ePace;
    LastSeenTime = Level.TimeSeconds;
    GotoState( 'TestMakePath' );
}

state TestMakePathEnd
{
    function BeginState()
    {
        logX( "begin: TestMakePathEnd" );
        StopMoving();
        Enemy = none;
    }
}

//------------------------------------------------------------------
// TestMakePath: initialized by SetStateTestMakePath
//------------------------------------------------------------------
state TestMakePath
{
    ignores SeePlayer, HearNoise;

    function BeginState()
    {
        logX( "begin. Eneny =" @Enemy.name );
    }

    function EnemyNotVisible()
    {
        // if (bShowLog) logX ( ": entered function EnemyNotVisible.  Time:" $ Level.TimeSeconds $ " Last seen: " $ LastSeenTime );

        // Not seen for at least X seconds, reset
       if ( Level.TimeSeconds - LastSeenTime > 20 )
       {
            logX( "Not seen for at least 20 seconds. GotoState('')" );
            GotoState( 'TestMakePathEnd' );
        }
    }

Begin:
ChooseDestination:
    // Find a destination
    if( !MakePathToRun() )
    {
        logX( "Nowhere to run..., gotostate '' " );
        gotoState( 'TestMakePathEnd' );
    }

RunToDestination:
    //  Move to it
    logX( "label RunToDestination.  Goal = " $RouteGoal );
    FollowPath( m_r6pawn.m_eMovementPace, 'ReturnToPath', false );
    Goto('ChooseDestination');

ReturnToPath:
    FollowPath( m_r6pawn.m_eMovementPace, 'ReturnToPath', true );
    Goto('ChooseDestination');
}

//============================================================================
// FLOAT GetCurrentChanceToHit - 
//============================================================================
function FLOAT GetCurrentChanceToHit( actor aTarget )
{
    local FLOAT fAngle;
    local FLOAT fDistance;
    local FLOAT fError;

    if(pawn.engineWeapon == none)
        return 0.f;

    // Get angle in radian (for use with Tan)
    fAngle = Pawn.EngineWeapon.GetCurrentMaxAngle() * 0.0174532925; // 2*PI / 360
    fAngle = Tan( fAngle );
    fDistance = VSize(Pawn.Location - aTarget.Location);
    fError = fAngle * fDistance;

    //logX( " current CTH: " $ ((Target.CollisionRadius)/fError)
    //          $ " MaxAngle:" $ Pawn.EngineWeapon.GetCurrentMaxAngle()
    //          $ " Tan Angle:" $ fAngle
    //          $ " Distance:" $ fDistance
    //          $ " Error:" $ fError
    //          );

    return (aTarget.CollisionRadius)/fError;
}

//============================================================================
// BOOL IsReadyToFire - 
//============================================================================
function BOOL IsReadyToFire( actor aTarget )
{
    local FLOAT fNeededChanceToHit;
    local FLOAT fSelfControl;
    
    // If weapon is already at the best it can be, we're ready
    if(Pawn.EngineWeapon.IsAtBestAccuracy())
    {
        return true;
    }

    // Needed chance to hit, Exponentialy calculated from Self Control skill
    // 100 = 100
    //  90 =  81
    //    ...
    //  50 =  25
    //    ...
    //  20 =   4
    //  10 =   1
    fSelfControl = m_r6pawn.GetSkill(SKILL_SelfControl);
    fNeededChanceToHit = fSelfControl * fSelfControl;
    if(fNeededChanceToHit>1.f)
        fNeededChanceToHit = 1.f;

    return GetCurrentChanceToHit(aTarget)>fNeededChanceToHit;
}

//============================================================================
// BOOL IsFocusLeft - 
//============================================================================
function BOOL IsFocusLeft()
{
    local INT iLeft;
    local INT iRight;
    local Rotator rFocus;

    if(focus==None)
    {
        #ifdefDEBUG if(bShowLog) logX( "Called IsFocusLeft with no focus" ); #endif
        return true;
    }
    
    rFocus = Rotator(focus.Location - Pawn.Location);

    iLeft  = Clamp( rFocus.Yaw - Pawn.Rotation.Yaw, 0, 65535 );
    iRight = Clamp( rFocus.Yaw + Pawn.Rotation.Yaw, 0, 65535 );

    return (iLeft<iRight);
}

//============================================================================
// ChangeOrientationTo - 
//============================================================================
function ChangeOrientationTo( Rotator newRotation )
{
    Focus = None;
    FocalPoint = Pawn.Location + vector(newRotation) * 50;
    Pawn.DesiredRotation = newRotation;
}

//------------------------------------------------------------------
// ChooseRandomDirection
//  
//------------------------------------------------------------------
function Rotator ChooseRandomDirection( int iLookBackChance )
{
    local BOOL bLookBack;
    local BOOL bTurnLeft;
    local INT iTemp;
    local Rotator rRot;

    // Check if we look back and if we turn left (or right)
    bLookBack = Rand(100)+1 < iLookBackChance; // 1 to 100
    bTurnLeft = Rand(2) == 1;        // 0 to 1

    if(bLookBack)
    {
        iTemp = Rand(16383) + 16383; // Between 90d and 180d
    }
    else
    {
        iTemp = Rand(8192) + 8192;   // Between 45d and 90d
    }
    rRot = Pawn.Rotation;
    if(bTurnLeft)
    {
        rRot.Yaw -= iTemp;
    }
    else
    {
        rRot.Yaw += iTemp;
    }

    //if (bShowLog) logX ( " change direction. Was: " $ Pawn.Rotation $ " WillBe: " $ rRot );
    //if (bShowLog) logX ( " location: " $ Pawn.Location $ " focalPt: " $ FocalPoint );

    return rRot;
}

// The following function was taken from Bot.uc
// FindBestPathToward() assumes the desired destination is not directly reachable. 
// It tries to set Destination to the location of the best waypoint, and returns true if successful
function bool FindBestPathToward(Actor desired, bool bClearPaths)
{
    local Actor path;
    local bool bSuccess;
    
    path = FindPathToward(desired, bClearPaths); 
        
    bSuccess = (path != None);  
    if (bSuccess)
    {
        moveTarget = path; 
        destination = path.location;
    }   
    return bSuccess;
}


//============================================================================
// IsFacing - 
//============================================================================
function bool IsFacing(Actor aGrenade)
{
    local vector vDir;

    vDir = aGrenade.location - pawn.location; 
    if(normal(vDir) dot vector(pawn.rotation) > 0)
        return true;

    return false;
}

//============================================================================
// AIAffectedByGrenade - 
//============================================================================
function AIAffectedByGrenade( Actor aGrenade, R6Pawn.EGrenadeType eType )
{
}


//============================================================================
// GetGrenadeDirection - 
//============================================================================
function Rotator GetGrenadeDirection( Actor aTarget, OPTIONAL vector vTargetLoc )
{
    local Rotator rFiringRotation;
    
    rFiringRotation = FindGrenadeDirectionToHitActor( aTarget, vTargetLoc, Pawn.EngineWeapon.GetMuzzleVelocity() );
    
    #ifdefDEBUG if(bShowLog) logX( "Grenade firing direction: " $rFiringRotation ); #endif

    return rFiringRotation;
}


//===================================================================================================
//   ####              #                                       #      ##                            
//    ##              ##                                      ##                                    
//    ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//    ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//    ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//    ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//   ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===================================================================================================
function BOOL CanInteractWithObjects(R6InteractiveObject O)
{
    return false;
}

function PerformAction_StartInteraction()
{
    #ifdefDEBUG if (bShowInteractionLog) logX(m_r6pawn$"::PerformAction_StartInteraction"); #endif
    m_StateAfterInteraction = GetStateName();
    m_InteractionObject.m_SeePlayerPawn = none;
    m_InteractionObject.m_HearNoiseNoiseMaker = none;

    m_InteractionObject.m_bPawnDied = false;
    m_bChangingState = true;
    GotoState('PA_StartInteraction');
}

function PerformAction_LookAt(Actor Target)
{
    #ifdefDEBUG if (bShowInteractionLog) logX(m_r6pawn$"::PerformAction_LookAt"); #endif
    m_ActorTarget = Target;
    m_bChangingState = true;
    GotoState('PA_LookAt');
}

function PerformAction_Goto(Actor Target)
{
    #ifdefDEBUG if (bShowInteractionLog) logX(m_r6pawn$"::PerformAction_Goto"); #endif
    m_ActorTarget = Target;
    m_bChangingState = true;
    GotoState('PA_Goto');
}

function PerformAction_PlayAnim(name AnimName)
{
    #ifdefDEBUG if (bShowInteractionLog) logX(m_r6pawn$"::PerformAction_PlayAnim"); #endif
    m_AnimName = AnimName;
    m_bChangingState = true;
    GotoState('PA_PlayAnim');
}

function PerformAction_LoopAnim(name AnimName, FLOAT fLoopAnimTime)
{
    #ifdefDEBUG if (bShowInteractionLog) logX(m_r6pawn$"::PerformAction_LoopAnim"); #endif
    m_AnimName = AnimName;
    m_fLoopAnimTime = fLoopAnimTime;
    m_bChangingState = true;
    GotoState('PA_LoopAnim');
}

function PerformAction_StopInteraction()
{
    #ifdefDEBUG if (bShowInteractionLog) logX(m_r6pawn$"::PerformAction_StopInteraction"); #endif
    m_bChangingState = true;
    GotoState(m_StateAfterInteraction);

    if(m_InteractionObject.m_bPawnDied == true)
    {
        PawnDied();
    }
    else if(m_InteractionObject.m_SeePlayerPawn != none)
    {
        SeePlayer(m_InteractionObject.m_SeePlayerPawn);
    }

    if(m_InteractionObject.m_HearNoiseNoiseMaker != none)
    {
        HearNoise(m_InteractionObject.m_HearNoiseLoudness, m_InteractionObject.m_HearNoiseNoiseMaker, m_InteractionObject.m_HearNoiseType);
    }
}

state PA_Interaction
{
    event SeePlayer(Pawn seen)
    {
        if(m_r6pawn.m_bDontSeePlayer && R6Pawn(seen).m_bIsPlayer)
            return;

        if(m_InteractionObject.m_SeePlayerPawn == none)
        {
            #ifdefDEBUG if(bShowInteractionLog) logX("PA_Interaction::SeePlayer("$seen$")"); #endif

            m_InteractionObject.m_SeePlayerPawn = seen;

            if(!m_bCantInterruptIO)
            {
                // Stop interacting with object with ending actions.
                m_InteractionObject.StopInteractionWithEndingActions();
            }
        }
    }

    event HearNoise(float Loudness, Actor NoiseMaker, ENoiseType eType, optional ESoundType ESoundType)
    {
        if(m_r6pawn.m_bDontHearPlayer && R6Pawn(NoiseMaker).m_bIsPlayer)
            return;

        if(m_InteractionObject.m_HearNoiseNoiseMaker == none)
        {
            #ifdefDEBUG if(bShowInteractionLog) logX("PA_Interaction::HearNoise("$NoiseMaker$","$eType$")"); #endif

            m_InteractionObject.m_HearNoiseLoudness = Loudness;
            m_InteractionObject.m_HearNoiseNoiseMaker = NoiseMaker;
            m_InteractionObject.m_HearNoiseType = eType;

            if(!m_bCantInterruptIO)
            {
                // Stop interacting with object with ending actions.
                m_InteractionObject.StopInteractionWithEndingActions();
            }
        }
    }

    function PawnDied()
    {
        #ifdefDEBUG if(bShowInteractionLog) logX("PA_Interaction::PawnDied"); #endif

        if(m_InteractionObject.m_bPawnDied == false)
        {
            m_InteractionObject.m_bPawnDied = true;

            // Force shot in the head, to prevent death animation before karma physic.
            m_r6pawn.m_iTracedBone = 0;
            // Stop interacting with object without ending actions.
            m_InteractionObject.StopInteraction();
        }
    }

    event AnimEnd(int Channel)
    {
    }

    event bool NotifyBump(Actor other)
    {
        //m_InteractionObject.StopInteraction();
        return true;
    }

    event EndState()
    {
        if(m_bChangingState == true)
        {// We're changing states normally.
            m_bChangingState = false;
        }
        else
        {// State was changed by AI, so stop interaction.
            #ifdefDEBUG if(bShowInteractionLog) log(m_r6pawn$"::Interaction was stopped by AI!"); #endif
            // Stop interacting with object with ending actions.
            m_InteractionObject.StopInteractionWithEndingActions();
        }
    }
}

state PA_StartInteraction extends PA_Interaction
{
Begin:
    m_InteractionObject.FinishAction();
}

state PA_LookAt extends PA_Interaction
{
Begin:
    m_r6pawn.PawnLookAt(m_ActorTarget.Location);
    m_InteractionObject.FinishAction();
}

state PA_Goto extends PA_Interaction
{
    event EndState()
    {
        StopMoving();
        Super.EndState();
    }
Begin:
    MoveTo(m_ActorTarget.Location);
    MoveToPosition(m_ActorTarget.Location, m_ActorTarget.Rotation);
    m_InteractionObject.FinishAction();
}

state PA_PlayAnim extends PA_Interaction
{
Begin:
    m_r6pawn.R6PlayAnim(m_AnimName, 1.0);
    FinishAnim();
    m_InteractionObject.FinishAction();
}

state PA_LoopAnim extends PA_Interaction
{
Begin:
    m_r6pawn.R6LoopAnim(m_AnimName, 1.0);
    if(m_fLoopAnimTime == 0.0f)
    {
        Stop;
    }
    else
    {
        Sleep(m_fLoopAnimTime);
    }

    m_InteractionObject.FinishAction();
}


//===================================================================================================

defaultproperties
{
     c_iDistanceBumpBackUp=80
     MinHitWall=-0.400000
     bRotateToDesired=True
}
