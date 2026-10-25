//=============================================================================
//  R6RainbowAI.uc : (Rainbow 6 Base Class) This is the AI Controller class for 
//                   all non player members of the Rainbow team.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/01 * Created by Rima Brek
//=============================================================================
class R6RainbowAI extends R6AIController
    native;

var			R6Rainbow					m_pawn;
var         R6RainbowTeam               m_TeamManager;
var         R6Rainbow                   m_TeamLeader;       // it might be sufficient to hold this info in the teamManager
var         R6Rainbow                   m_PaceMember;       // this is the member that is directly ahead of this controller's pawn.

var			name						m_PostFindPathToState;
var			name						m_PostLockPickState;

var			vector						m_vLocationOnTarget;	// location on target to aim at
var			INT							m_iStateProgress;
var			actor						m_NextMoveTarget;
var			R6IORotatingDoor			m_RotatingDoor;

var enum eFormation
{
    FORM_SingleFile,
    FORM_SingleFileWallBothSides,
    FORM_SingleFileWallRight,
    FORM_SingleFileWallLeft,
    FORM_SingleFileNoWalls,
    FORM_OrientedSingleFile,
    FORM_Diamond
} m_eFormation;

var enum ePawnOrientation
{
	PO_Front,
    PO_FrontRight,
    PO_Right,
    PO_Left,
    PO_FrontLeft,
    PO_Back,
    PO_PeekLeft,
    PO_PeekRight,    
} m_ePawnOrientation;

// -- MOVEMENT attributes -- //
var         INT                         m_iTurn;				// used to allow a member walking backwards to turn around periodically
var         INT                         m_iWaitCounter;

// -- INTERACTION attributes -- //
var         Actor                       m_ActionTarget;
var         INT							m_iActionUseGadgetGroup;
var         bool                        m_bTeamMateHasBeenKilled;
var			bool						m_bIsCatchingUp;
var			bool						m_bIsMovingBackwards;
var			bool						m_bSlowedPace;
var			bool						m_bAlreadyWaiting;
var			bool						m_bReactToNoise;
var			bool						m_bUseStaggeredFormation;
var			bool						m_bWeaponsDry;
var			bool						m_bAimingWeaponAtEnemy;

var			bool						m_bEnteredRoom;
var			bool						m_bIndividualAttacks;
var			bool						m_bStateFlag;				// for miscellaneous usage
var			bool						m_bReorganizationPending;
var			FLOAT						m_fLastReactionToGas;

var			vector						m_vGrenadeLocation;
var			FLOAT						m_fGrenadeDangerRadius;

var			actor						m_DesiredTarget;
var			vector						m_vDesiredLocation;
var			vector						m_vNoiseFocalPoint;

var			vector						m_vPreEntryPositions[2];
var			FLOAT						m_fAttackTimerRate;		// Timer event, 0=no timer.
var			FLOAT						m_fAttackTimerCounter;	// Counts up until it reaches m_fAttackTimerRate.
var			FLOAT						m_fFiringAttackTimer;

var         R6CommonRainbowVoices       m_CommonMemberVoicesMgr;
var			R6Door.eRoomLayout			m_eCurrentRoomLayout;

var	enum eCoverDirection
{
	COVER_Left,
	COVER_Center,
	COVER_Right,
	COVER_None
} m_eCoverDirection;

native(2202) final function vector GetTargetPosition();  
native(2203) final function vector GetLadderPosition();
native(2204) final function vector GetGuardPosition();
native(2205) final function vector GetEntryPosition(bool bInsideRoom);
native(2206) final function vector CheckEnvironment();
native(2207) final function SetOrientation(optional ePawnOrientation eOverrideOrientation);
native(2219) final function LookAroundRoom(bool bIsLeadingRoomEntry);
native(2221) final function actor FindSafeSpot();
native(2222) final function bool AClearShotIsAvailable(Pawn pTarget, vector vStart);
native(2223) final function bool ClearToSnipe(vector vStart, rotator rSnipingDir);

//------------------------------------------------------------------
// Possess()
//   BEWARE : could this cause a problem when changing pawns?
//------------------------------------------------------------------
function Possess(Pawn aPawn)
{
    Super.Possess(aPawn);
	m_pawn = R6Rainbow(aPawn);
	m_pawn.bRotateToDesired = true;		// rbrek 19 dec 2001 : bugfix (caused problems)
    PlayerReplicationInfo = none;
    aPawn.PlayerReplicationInfo = none;
	#ifdefDEBUG	if(bShowLog) log(self$"   m_Pawn = "$m_pawn);	#endif
}

event PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role==ROLE_Authority)
    {		
        m_CommonMemberVoicesMgr = R6CommonRainbowVoices( R6AbstractGameInfo(level.game).GetCommonRainbowMemberVoicesMgr() );
    }
}
 
//------------------------------------------------------------------
// UpdatePosture()                                         
//------------------------------------------------------------------
function UpdatePosture()
{
	if(!m_PaceMember.m_bPostureTransition && 
		((m_PaceMember.m_bIsProne != pawn.m_bIsProne) || (m_PaceMember.bIsCrouched != pawn.bIsCrouched)))
	{
		if(m_PaceMember.m_bIsProne && !m_PaceMember.m_bIsSniping)
			pawn.m_bWantsToProne = true;
		else if(m_PaceMember.bIsCrouched)
		{
			pawn.bWantsToCrouch = true;
			pawn.m_bWantsToProne = false;
		}
		else
		{
			pawn.bWantsToCrouch = false;
			pawn.m_bWantsToProne = false;
		}		
	}
}

//------------------------------------------------------------------
// PostureHasChanged()                                         
//------------------------------------------------------------------
function bool PostureHasChanged()
{
	if(pawn.m_bIsProne != pawn.m_bWantsToProne)
		return true;

	if(pawn.m_bIsProne)
		return false;

	if(pawn.bIsCrouched != pawn.bWantsToCrouch)
		return true;

	return false;
}

function FreeBackupPromote();

//------------------------------------------------------------------
// R6SetMovement()
//------------------------------------------------------------------
function R6SetMovement(R6Pawn.eMovementPace ePace)
{
	local bool bIndependantPace;

	// check posture
	if(ePace == 0)
	{
		bIndependantPace = false;
		if(m_PaceMember == none || m_TeamLeader == none)
			return;
		UpdatePosture();
		m_Pawn.m_eMovementPace = m_PaceMember.m_eMovementPace;
	}
	else
	{
		bIndependantPace = true;
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
				pawn.bWantsToCrouch = false;
		}
		else
		{
			if((ePace == PACE_CrouchWalk) || (ePace == PACE_CrouchRun))
				pawn.bWantsToCrouch = true;
		} 
		m_Pawn.m_eMovementPace = ePace;
	}

	// if this is a team leader or a member with a pace independant of leader
	if(m_TeamLeader == none || bIndependantPace)
	{
		// this pawn is the team leader
		if((m_Pawn.m_eMovementPace == PACE_Walk) || (m_Pawn.m_eMovementPace == PACE_CrouchWalk))
			pawn.SetWalking(true);  
		else if((m_Pawn.m_eMovementPace == PACE_Run) || (m_Pawn.m_eMovementPace == PACE_CrouchRun))
			pawn.SetWalking(false); 	
		return;		
	}

    // make needed adjustments if leader is walking backwards or strafing...
	if(!m_PaceMember.IsMovingForward() && !pawn.m_bIsProne)
	{		
		if(m_PaceMember.bIsWalking)
			m_bSlowedPace=true;
		else
		{
			// pacemember is not walking, but this pawn should be
			if(m_PaceMember.bIsCrouched)
			{
				m_bSlowedPace=true;	
				m_Pawn.m_eMovementPace = PACE_CrouchWalk;  
			}
			else
			{
				m_bSlowedPace=false;
				m_Pawn.m_eMovementPace = PACE_Walk;
			}				
		}	
	}	
	else
		m_bSlowedPace=false;

	if((m_Pawn.m_eHealth == HEALTH_Wounded) && !m_bIsMovingBackwards)
	{	
		// if this pawn is wounded, they can only walk except for the last member while moving backwards they can (cheat) run.
		pawn.SetWalking(true);
		
	}
    else if((m_Pawn.m_eMovementPace == PACE_Walk) || (m_Pawn.m_eMovementPace == PACE_CrouchWalk))
	{
		// if too far away from pacemember run to catch up!
		if(!m_bSlowedPace && (DistanceTo(m_PaceMember) > 2*GetFormationDistance()) && !m_TeamManager.m_bTeamIsSeparatedFromLeader)
			pawn.SetWalking(false);
		else
			pawn.SetWalking(true);  
	}
    else if((m_Pawn.m_eMovementPace == PACE_Run) || (m_Pawn.m_eMovementPace == PACE_CrouchRun))
		pawn.SetWalking(false);  
}

//------------------------------------------------------------------
// R6PreMoveTo()                                           
//   ePace is optional so for NPC members who's pace should be set  
//   according to team leader...                                    
//------------------------------------------------------------------
function R6PreMoveTo(vector vTargetPosition, vector vFocus, optional R6Pawn.eMovementPace ePace)
{
	if(pawn.m_bTryToUnProne)
		ePace = PACE_Prone;
	else if(pawn.bTryToUncrouch)
		ePace = PACE_CrouchWalk; 	

	R6SetMovement(ePace);

    // these are set for GetFacingDirection()...
    focus = none;
    focalPoint = vFocus;          
    destination = vTargetPosition;
}

//------------------------------------------------------------------
// R6PreMoveToward()                                       
//   ePace is optional so for NPC members who's pace should be set  
//   according to team leader...                                    
//------------------------------------------------------------------
function R6PreMoveToward(actor target, actor pfocus, optional R6Pawn.eMovementPace ePace)
{
	if(pawn.m_bTryToUnProne)
		ePace = PACE_Prone;
	else if(pawn.bTryToUncrouch)
		ePace = PACE_CrouchWalk;  

	R6SetMovement(ePace);

    // these are set for GetFacingDirection()...
    focus = none;
    focalPoint = pFocus.location;          
    destination = target.location;
}

//------------------------------------------------------------------
// ResetStateProgress()                                       
//------------------------------------------------------------------
function ResetStateProgress()
{
	m_iStateProgress = 0;
}

//------------------------------------------------------------------
// CanClimbLadders()                                       
//------------------------------------------------------------------
function bool CanClimbLadders( R6Ladder ladder )
{
	if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
		return true;
	else
		return R6Pawn(pawn).m_bAutoClimbLadders;
}

//------------------------------------------------------------------
// CanClimbObject: look if the pawn can climb r6climbableObject
//	
//------------------------------------------------------------------
/* // R6CLIMBABLEOBJECT
function bool CanClimbObject()
{
	if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
		return true;

    return Super.CanClimbObject();
} */

//------------------------------------------------------------------
// CanSeeGrenade()                                       
//------------------------------------------------------------------
function bool CanSeeGrenade(vector vGrenadeLocation)
{
	local vector vDir;
	
	vDir = vGrenadeLocation - pawn.location; 
	vDir.z = 0;
	if(VSize(vDir) < 100)
	{
		#ifdefDEBUG 	if(bShowLog) log(" the grenade is within 1m... don't bother checking..... assume this rainbow can see it...");	#endif
		return true;
	}

	vDir = vGrenadeLocation - pawn.location; 
	if(((normal(vDir) dot vector(pawn.rotation)) - pawn.peripheralVision) > 0)
	{
		if(FastTrace(pawn.location, vGrenadeLocation))
			return true;
	}
	
	return false;
}

//------------------------------------------------------------------
// FragGrenadeInProximity()                                       
//------------------------------------------------------------------
function FragGrenadeInProximity(vector vGrenadeLocation, FLOAT fTimeLeft, FLOAT fGrenadeDangerRadius)
{
	// check is grenade is visible to this rainbow
	if(m_pawn.m_bIsClimbingLadder || IsInState('RunAwayFromGrenade'))
		return;

	#ifdefDEBUG	if(bShowLog) log("FragGrenadeInProximity() ::  vGrenadeLocation="$vGrenadeLocation$" fTimeLeft="$fTimeLeft);	#endif
	// first member to see/hear the grenade should inform the team manager so that all the members run 
	if(m_pawn.IsAlive() && CanSeeGrenade(vGrenadeLocation))
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" can see a grenade!!! run away!!! from location="$vGrenadeLocation);		#endif
		m_TeamManager.GrenadeInProximity(m_pawn, vGrenadeLocation, fTimeLeft, fGrenadeDangerRadius);
	}
}

//------------------------------------------------------------------
// ReactToFragGrenade()                                       
//------------------------------------------------------------------
function ReactToFragGrenade(vector vGrenadeLocation, FLOAT fTimeLeft, FLOAT fGrenadeDangerRadius)
{
	#ifdefDEBUG	if(bShowLog) log(pawn$" ReactToFragGrenade() was called ");		#endif

	if(m_pawn.m_bIsClimbingLadder || pawn.physics == PHYS_Ladder || VSize(vGrenadeLocation - pawn.location) > fGrenadeDangerRadius)
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" no real threat, my current location is safe...");	#endif
		return;		// current location is safe
	}

	m_vGrenadeLocation = vGrenadeLocation;
	m_fGrenadeDangerRadius = fGrenadeDangerRadius;

	GotoState('RunAwayFromGrenade');
	SetTimer(fTimeLeft, false);
}

//------------------------------------------------------------------
// PlaySoundAffectedByGrenade()                                       
//------------------------------------------------------------------
function PlaySoundAffectedByGrenade(R6Pawn.EGrenadeType eType)
{
    switch(eType)
    {
        case GTYPE_Smoke:
            if (m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus)
                m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_EntersSmoke);
            else
                m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, ROTV_EntersSmoke);
            break;
        case GTYPE_TearGas:
            if (m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus)
                m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_EntersGas);
            else
            {
                m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, ROTV_EntersGas);

                if (m_TeamManager.m_bPlayerHasFocus || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
                {
                    if (m_TeamManager.m_bFirstTimeInGas)
                    {
                        m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_GasThreat);
                        m_TeamManager.m_bFirstTimeInGas = false;
                        m_TeamManager.SetTimer(60, false);
                    }
                }
            }
            break;
    }
}

//------------------------------------------------------------------
// AIAffectedByGrenade()                                       
//------------------------------------------------------------------
function AIAffectedByGrenade(Actor aGrenade, R6Pawn.EGrenadeType eType)
{
//	#ifdefDEBUG	if(bShowLog) log(pawn$" AIAffectedByGrenade() from "$aGrenade$" pawn.m_bHaveGasMask="$m_pawn.m_bHaveGasMask);	#endif

	if(eType == GTYPE_TearGas)
    {
		// make sure RainbowAI is not already playing Coughing animation
		if(m_pawn.m_bPawnSpecificAnimInProgress)
			m_fLastReactionToGas = Level.TimeSeconds;
		else
		{
			#ifdefDEBUG	if(bShowLog) log(" AIAffectedByGrenade() : eType == GTYPE_TearGas ... play coughing m_fLastReactionToGas="$m_fLastReactionToGas);	#endif
			m_TeamManager.GasGrenadeInProximity(m_pawn);

			if(m_fLastReactionToGas < Level.TimeSeconds - 2.0)
			{
				m_fLastReactionToGas = Level.TimeSeconds;
				m_pawn.SetNextPendingAction(PENDING_Coughing);			
			}
		}
    }
	else if(eType == GTYPE_FlashBang)
	{
		// todo : check who threw the grenade, need not react to our own flashbang
		#ifdefDEBUG	if(bShowLog) log(" AIAffectedByGrenade() : eType == GTYPE_FlashBang : aGrenade.Instigator = "$aGrenade.Instigator);		#endif
		// check if grenade came from this rainbow's team
		if(IsFacing(aGrenade) && m_pawn.IsStationary()) 
			m_pawn.SetNextPendingAction(PENDING_Blinded);
	}
}

//------------------------------------------------------------------
// PlaySoundInflictedDamage()                                       
//------------------------------------------------------------------
function PlaySoundInflictedDamage(Pawn DeadPawn)
{
    switch(R6Pawn(DeadPawn).m_ePawnType)
    {
        case PAWN_Terrorist:
            if (m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus)
                m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_TerroristDown);            
            else if ((m_TeamManager.m_OtherTeamVoicesMgr != none) && (m_pawn.m_bIsSniping))
				m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, ROTV_SniperTangoDown);			
			break;
    }
}

//------------------------------------------------------------------
// PlaySoundActionCompleted()                                       
//------------------------------------------------------------------
function PlaySoundActionCompleted(R6Pawn.eDeviceAnimToPlay eAnimToPlay)
{
    if (Level.NetMode == NM_Standalone)
    {
        if (!m_TeamManager.m_bLeaderIsAPlayer && !m_TeamManager.m_bPlayerHasFocus)
        {
            switch(eAnimToPlay)
            {
                case BA_Keypad:
                    m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_SecurityDeactivated);
                    break;
                case BA_PlantDevice:
                    m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_BugActivated);
                    break;
                case BA_Keyboard:
                    m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_ComputerHacked);
                    break;
            }
        }

    }


    if ((Level.NetMode != NM_Standalone) || m_TeamManager.m_bPlayerHasFocus)
    {
        switch(eAnimToPlay)
        {
            case BA_Keypad:
                m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_SecurityDeactivated);
                break;
            case BA_PlantDevice:
                m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_BugActivated);
                break;
            case BA_Keyboard:
                m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_ComputerHacked);
                break;
        }
    }
}

//------------------------------------------------------------------
// PlaySoundCurrentAction()                                       
//------------------------------------------------------------------
function PlaySoundCurrentAction(Pawn.ERainbowTeamVoices eVoices)
{
    if (m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus)
    {
        if (m_TeamManager.m_bPlayerHasFocus || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
        {
            m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, eVoices);
        }
        else if (eVoices == RTV_HostageSecured)
            m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, RMV_HostageSecured);
    }
    else
        m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, eVoices);

}

//------------------------------------------------------------------
// PlaySoundDamage()                                       
//------------------------------------------------------------------
function PlaySoundDamage(Pawn instigatedBy)
{
    m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_TakeWound);

    if (m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus)
    {
        switch(m_pawn.m_eHealth)
        {
            case HEALTH_Incapacitated:
            case HEALTH_Dead:
                if (m_TeamManager.m_iMemberCount > 1)
                {
                    m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, CRV_GoesDown);
                    if (m_TeamManager.m_bLeaderIsAPlayer)
                        m_TeamManager.m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamManager.m_Team[0], RPV_MemberDown);
                    else
                        m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_TeamManager.m_Team[0], RMV_MemberDown);

                }
                break;
            case HEALTH_Wounded: 
                if (instigatedBy != none)
                {
                    switch(R6Pawn(instigatedBy).m_ePawnType) 
                    {
                        case PAWN_Rainbow:
                            m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, RMV_RainbowHitRainbow);
                            break;
                        case PAWN_Terrorist:
                            m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, RMV_TakingFire);
                            break;
                    }
                }
                break;
        }
    }
    else
    {
        switch(m_pawn.m_eHealth)
        {
            case HEALTH_Incapacitated:
            case HEALTH_Dead:
                if ((m_TeamManager.m_OtherTeamVoicesMgr != none) && (m_TeamManager.m_iMemberCount > 0))
                    m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamManager.m_Team[0], ROTV_MemberDown);
                break;
            case HEALTH_Wounded: 
                if ((instigatedBy != none) && (R6Pawn(instigatedBy).m_ePawnType == PAWN_Rainbow))
                    m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, ROTV_RainbowHitRainbow);
                break;
        }
    }
}

//==========================================================
//            -- state RUNAWAYFROMGRENADE --                
//==========================================================
state RunAwayFromGrenade
{
	function BeginState()	
	{	
		#ifdefDEBUG	if(bShowLog) log(pawn$" has entered state RunAwayFromGrenade...");		#endif
		m_bIgnoreBackupBump = true;
	}

	function EndState()		
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" has exited state RunAwayFromGrenade...");	#endif
		m_TeamManager.m_bGrenadeInProximity = false;
		SetTimer(0, false);
		StopMoving();
		m_bIgnoreBackupBump = false;
	}

	event Timer()
	{
		#ifdefDEBUG	if(bShowLog) log("  Timer() was called.... grenade has exploded, threat is over...");	#endif
		m_TeamManager.GrenadeThreatIsOver();
	}

	function vector SafeLocation()
	{
		local vector vDir;
		local vector vLocation;

		vDir = normal(pawn.location - m_vGrenadeLocation);
		vLocation = m_vGrenadeLocation + (m_fGrenadeDangerRadius+600)*vDir; 
		vLocation.z = pawn.location.z;
		if(PointReachable(vLocation))
			return vLocation;
		
		vLocation = m_vGrenadeLocation - (m_fGrenadeDangerRadius+600)*vDir;
		vLocation.z = pawn.location.z;
		if(PointReachable(vLocation))
			return vLocation;

		// find a path away from grenade
		return vect(0,0,0);
	}

Begin:
	m_TeamManager.SetTeamState(TS_Moving);

	// try to run directly away from the grenade
	m_vTargetPosition = SafeLocation();
	EnsureRainbowIsArmed();

	if(m_vTargetPosition != vect(0,0,0))
		goto('RunToDirectly');

FindPathAway:
	// it is not possible to find a direct path away...	
	moveTarget = FindSafeSpot();   
	#ifdefDEBUG	if(bShowLog) log(pawn$" cannot find a direct safe location to move to... moveTarget="$moveTarget);	#endif
	if(moveTarget != none)
	{
		// handle doors ... ( no room entry )
		if(NeedToOpenDoor(moveTarget))
		{
			m_pawn.PlayDoorAnim(m_pawn.m_Door.m_RotatingDoor);
			Sleep(0.5);
			m_pawn.ServerPerformDoorAction(m_pawn.m_Door.m_RotatingDoor, m_pawn.m_Door.m_RotatingDoor.eDoorCircumstantialAction.CA_Open);			
		}
		R6PreMoveToward(moveTarget, moveTarget, PACE_Run);
		MoveToward(moveTarget);	
		if(m_eMoveToResult == eMoveTo_failed)
			Sleep(0.5);
		
		if(VSize(m_vGrenadeLocation - pawn.location) > (m_fGrenadeDangerRadius+300))
			Goto('Wait');
		
		Goto('FindPathAway');
	}
	Goto('Wait');

RunToDirectly:
	#ifdefDEBUG	if(bShowLog) log(pawn$" will run away to location "$m_vTargetPosition);		#endif
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Run);
	MoveTo(m_vTargetPosition);
	
Wait:
	StopMoving();
	m_TeamManager.SetTeamState(TS_Holding);
	#ifdefDEBUG	if(bShowLog) log(pawn$" ran away from grenade.... pawn.location="$pawn.location$" m_vGrenadeLocation="$m_vGrenadeLocation);		#endif
	Sleep(2);
	Goto('Wait');
}

//==========================================================
//              -- state BUMPBACKUP --		                
//==========================================================
state BumpBackUp
{	
	event bool NotifyBump(Actor other)
	{  
		local R6Pawn thisPawn;

		thisPawn = R6Pawn(other);
		if(thisPawn == none)
			return false;
			
		if(thisPawn.m_iId <= R6Pawn(m_BumpedBy).m_iId)
		{			
			m_BumpedBy = thisPawn;
			GotoState('BumpBackUp');
			return true;
		}
		return false;
	}
	
	function vector GetTargetLocation(bool bRight, optional INT iTry)
	{
		local rotator	rOffset;
		local R6Pawn	bumpedBy;

		bumpedBy = R6Pawn(m_BumpedBy);
		if(bumpedBy.m_bIsClimbingLadder && ((bumpedBy.location.z - pawn.location.z) > 100))
			return(pawn.location - c_iDistanceBumpBackUp*bumpedBy.onLadder.LookDir);			

		switch(iTry)
		{
			case 0:		rOffset = rot(0,16384,0);	break;
			case 1:		rOffset = rot(0,8192,0);	break;
			case 2:		rOffset = rot(0,4096,0);	break;
			case 3:		rOffset = rot(0,0,0);		break;
			case 4:		rOffset = rot(0,-4096,0);	break;
			case 5:		rOffset = rot(0,-8192,0);	break;
			case 6:		rOffset = rot(0,-16384,0);	break;
		}
		
		if(bRight)
			return pawn.location + (c_iDistanceBumpBackUp)*vector(rotator(m_vBumpedByVelocity) + rOffset);
		else
			return pawn.location + (c_iDistanceBumpBackUp)*vector(rotator(m_vBumpedByVelocity) - rOffset);
	}

    function bool GetReacheablePoint( OUT vector vTarget, bool bNoFail )
    {
		local actor hitActor;
		local vector vHitLocation, vHitNormal;
		local vector vExtent;
		local bool	bMoveRight;
		local INT i;

		bMoveRight = MoveRight();
		vTarget = GetTargetLocation(bMoveRight);
	
		vExtent.x = pawn.collisionRadius;
		vExtent.y = vExtent.x;
		vExtent.z = pawn.collisionHeight;
		hitActor = R6Trace(vHitLocation, vHitNormal, vTarget, pawn.location, TF_TraceActors, vExtent);
		
		if(hitActor != none)
			vTarget = vHitLocation + (c_iDistanceBumpBackUp)*vector(rotator(m_vBumpedByVelocity));

		// check to make sure the location is not floating off a ledge
		while(R6Trace(vHitLocation, vHitNormal, vTarget - vect(0,0,200), vTarget, TF_TraceActors) == none && i < 6)
		{
			i++;
			// don't back up off ledge, pick another direction...
			vTarget = GetTargetLocation(bMoveRight, i);
		}

		return true;
	}
}

//==========================================================
//              -- state WAITFORPACEMEMBER --               
//==========================================================
state WaitForPaceMember
{
#ifdefDEBUG
	function BeginState()	{	if(bShowLog) log(pawn$" has entered state WaitForPaceMember...");	}
	function EndState()		{	if(bShowLog) log(pawn$" has exited state WaitForPaceMember...");	}
#endif

Begin:
	Sleep(1);
	if(abs(m_PaceMember.location.z - pawn.location.z) < 30)
		GotoState('FollowLeader');
	else
		Goto('Begin');
}

//------------------------------------------------------------------
// CanBeSeen()                                         
//------------------------------------------------------------------
function bool CanBeSeen(Pawn seen)
{
	local vector vSightDir;

	vSightDir = normal(pawn.location - seen.location);
	if((vector(seen.GetViewRotation()) dot vSightDir) < pawn.peripheralVision)
		return false;
	
	return true;
}

//------------------------------------------------------------------
// SetEnemy()                                         
//------------------------------------------------------------------
function SetEnemy( Pawn newEnemy )
{
	if(!m_pawn.m_bIsSniping)
		m_TeamManager.RainbowIsEngagingEnemy();
    Enemy = newEnemy;
    LastSeenTime = Level.TimeSeconds;
    if(Enemy!=none)
		LastSeenPos = Enemy.Location;
}

//------------------------------------------------------------------
// PlayVoiceTerroristSpotted()                                         
//------------------------------------------------------------------
function PlayVoiceTerroristSpotted(R6Terrorist aTerro)
{
	if(!aTerro.m_bEnteringView && (m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus))
	{
		if(m_bIsMovingBackwards)
			m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, RMV_ContactRear);
		else
			m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, RMV_Contact);
		aTerro.m_bEnteringView = true;
	}
}

//------------------------------------------------------------------
// SeePlayer()                                             
//------------------------------------------------------------------
event SeePlayer(Pawn seen)
{
	local R6Pawn aPawn;

    aPawn = R6Pawn(seen);	
	if(m_pawn.IsEnemy( seen ) && (aPawn.engineWeapon != none))
	{		
		if(m_TeamManager == none)
			return;

		// do not fire at a surrendered/incapacitated/dead terrorist
		if(aPawn.m_bIsKneeling || !aPawn.IsAlive())
		{
			if(!R6Terrorist(aPawn).m_bIsUnderArrest)
				m_TeamManager.TeamSpottedSurrenderedTerrorist(aPawn);
			return;
		}

        if(aPawn.m_bDontKill)
            return;
				
		if(m_TeamManager.m_eMovementMode == MOVE_Recon)
		{
			// Rules of Engagement : RECON 
			if(!CanBeSeen(seen))	
			{
				PlayVoiceTerroristSpotted(R6Terrorist(aPawn));
				return;
			}

			// terrorist can see us, change Rules of Engagement to ASSAULT
			#ifdefDEBUG	if(bShowLog) log("  *****  "$pawn$" can seen by terrorist:"$seen$" change ROE from RECON to ASSAULT!");		#endif
			m_TeamManager.m_eMovementMode = MOVE_Assault;			
		}
		else if(m_TeamManager.m_eMovementMode == MOVE_Infiltrate)
		{
			// Rules of Engagement : INFILTRATE, fire at will with silenced weapons
			// check if terrorist has spotted us
			if(CanBeSeen(seen))
			{
				// terrorist can see us, change Rules of Engagement to ASSAULT
				#ifdefDEBUG	if(bShowLog) log("  *****  "$pawn$" can seen by terrorist:"$seen$" change ROE from INFILTRATE to ASSAULT!");	#endif
				m_TeamManager.m_eMovementMode = MOVE_Assault;	
			}
			else if(!Pawn.EngineWeapon.m_bIsSilenced)
			{
				PlayVoiceTerroristSpotted(R6Terrorist(aPawn));			
				return;
			}
		}
		
		// do not engage if already engaging another terrorist
		if(enemy != none)
			return;

		if(m_bWeaponsDry)
			return;

		if(AClearShotIsAvailable(seen, m_pawn.GetFiringStartPoint()) && (Pawn.EngineWeapon.m_eWeaponType != WT_Grenade))
		{
			#ifdefDEBUG	if(bShowLog) log(pawn$" : SeePlayer() enemy="$enemy$" new enemy="$seen$" has been spotted...m_bIndividualAttacks="$m_bIndividualAttacks);	#endif
			if(!m_bIndividualAttacks || m_TeamManager.EngageEnemyIfNotAlreadyEngaged(m_pawn, aPawn))
			{
				m_pawn.m_bEngaged = true; 
				SetEnemy(seen);
				target = enemy;	
				Enable('EnemyNotVisible');
			}
		}
	}
	else
	{
		if((aPawn.m_ePawnType == PAWN_Hostage) && aPawn.IsAlive() && !R6Hostage(aPawn).m_bExtracted && (R6Hostage(aPawn).m_escortedByRainbow == none))
			m_TeamManager.m_HostageToRescue = aPawn;
	}
}

//------------------------------------------------------------------
// IsANeutralPawnNoise()                                         
//------------------------------------------------------------------
function bool IsANeutralPawnNoise(Actor aNoiseMaker)
{
	local Pawn aPawn;

    aPawn = Pawn( aNoiseMaker );

    if ( aPawn == none )
        aPawn = aNoiseMaker.Instigator;

    if ( aPawn == none )
    {
        return false;
    }

    return m_pawn.IsNeutral( aPawn );
}

//------------------------------------------------------------------
// HearNoise()                                             
//------------------------------------------------------------------
event HearNoise( float Loudness, Actor aNoiseMaker, ENoiseType eType, optional ESoundType ESoundType )
{
	if(m_TeamManager==none)
		return;
	
//rb	if(bShowLog) log(pawn$" heard sound from "$aNoiseMaker.name$" of type "$eType$" and loudness "$Loudness$" aNoiseMaker.Instigator="$aNoiseMaker.Instigator);

	// ignore sounds from neutral pawn
	if( IsANeutralPawnNoise(aNoiseMaker))
		return;

	// rainbow react to noises that originate from terrorists
	m_TeamManager.TeamHearNoise(aNoiseMaker);

	if(m_TeamManager.m_eMovementMode == MOVE_Assault)
		return; 

	// NOISE_Investigate
    // if sound is from a bullet, change rules of engagement
    if((eType==NOISE_Threat) || (eType==NOISE_Grenade))
	{
		if(R6Pawn(aNoiseMaker.owner).m_ePawnType != PAWN_Rainbow)
		{
			#ifdefDEBUG	if(bShowLog) log(pawn$" heard bullet/grenade, change ROE to ASSAULT!! aNoiseMaker="$aNoiseMaker$" aNoiseMaker.owner="$aNoiseMaker.owner);	#endif
			m_TeamManager.m_eMovementMode = MOVE_Assault;
		}
	}
}

//------------------------------------------------------------------
// EnemyNotVisible()                                       
//------------------------------------------------------------------
event EnemyNotVisible()
{
	#ifdefDEBUG if(bShowLog) log(pawn$" EnemyNotVisible() !!!! enemy="$enemy$" enemy.IsAlive()="$enemy.IsAlive());	#endif
	if(Level.TimeSeconds - LastSeenTime < 0.5)
		return;

	StopFiring();
	EndAttack();
    Disable('EnemyNotVisible');
}

//------------------------------------------------------------------
// IsBeingAttacked()                                       
//------------------------------------------------------------------
function IsBeingAttacked(Pawn attacker)
{
	if( m_pawn.IsEnemy(attacker) )
	{			
		// turn towards this enemy if not already engaging another enemy
		if(enemy == none)
		{
			#ifdefDEBUG	if(bShowlog) log(pawn$" IN DANGER!!!!!   has been wounded by enemy: "$attacker$"  will try to turn to face them...");	#endif
			m_pawn.ResetBoneRotation();
			pawn.desiredRotation = rotator(attacker.location - pawn.location);
			focus = attacker;
			enemy = attacker;
		}
	}
}

//------------------------------------------------------------------
// EnemyIsStillAThreat()                                   
//------------------------------------------------------------------
function bool EnemyIsAThreat()
{
    if(enemy == none)
        return false;

    if(R6Pawn(enemy).m_bIsKneeling || !R6Pawn(enemy).IsAlive())
        return false;
  
	return true;
}

//------------------------------------------------------------------
// SetGunDirection - 
//------------------------------------------------------------------
function SetGunDirection(Actor aTarget)
{
    local rotator rDirection;
    local vector  vDirection;
    local Coords  cTarget;
    local vector  vTarget;

    if(aTarget != none)
    {
		// target can be set to self/controller for throwing grenades
		if(aTarget == self) 	
			vTarget = aTarget.location;
        else if(aTarget == enemy)
        {
			vTarget = LastSeenPos;
			m_bAimingWeaponAtEnemy = true;
		}
        else
        {
            cTarget = aTarget.GetBoneCoords('R6 Spine');
            vTarget = cTarget.Origin;
        }

		if(aTarget == self)
			rDirection = aTarget.rotation;
        else
		{
			// Find the pitch between the gun and the target
			vDirection = vTarget - m_pawn.GetFiringStartPoint();
			rDirection = rotator(vDirection);
		}

        m_pawn.m_u8DesiredPitch = (rDirection.Pitch&0xFFFF)/256;
		// only set the desiredYaw if this is not 
		if(aTarget == enemy)
			m_pawn.m_u8DesiredYaw = ((rDirection.Yaw - pawn.rotation.yaw)&0xFFFF)/256;
		else
			m_pawn.m_u8DesiredYaw = 0;
        m_pawn.m_rFiringRotation = rDirection;
    }
    else
    {		
		m_bAimingWeaponAtEnemy = false;
        m_pawn.m_u8DesiredPitch = 0;
		m_pawn.m_u8DesiredYaw = 0;
        m_pawn.m_rFiringRotation = m_pawn.Rotation;
    }
}

//------------------------------------------------------------------
// EndAttack()                                             
//------------------------------------------------------------------
function EndAttack()
{
	#ifdefDEBUG	if(bShowLog) logX(" EndAttack() was called....enemy="$enemy);	#endif
    m_pawn.m_bEngaged = false; // for the heartbeat
    m_TeamManager.DisEngageEnemy(pawn, enemy);
    enemy = none;
	target = none;
	if(IsMoving(pawn))
	{
		if(moveTarget != none)
			focus = moveTarget;
	}
}

//------------------------------------------------------------------
// StartFiring()                                           
//------------------------------------------------------------------
function StartFiring()
{
    if(pawn.EngineWeapon != none)
    {            
 	    if(Enemy != none)
			Target = Enemy;
        SetRotation(pawn.rotation);
        bFire = 1;
        pawn.EngineWeapon.GotoState('NormalFire');
    }
}

//------------------------------------------------------------------
// StopFiring()                                            
//------------------------------------------------------------------
function StopFiring()
{
    bFire = 0;  
}

//------------------------------------------------------------------
// PreEntryRoomIsAcceptablyLarge()                                         
//------------------------------------------------------------------
function bool PreEntryRoomIsAcceptablyLarge()
{
	if(m_TeamManager.m_eMovementMode == MOVE_Recon)
		return false;

	if(m_TeamManager.m_Door == none)
	{
		#ifdefDEBUG	if(bShowLog) log("  PROBLEM : PreEntryRoomIsAcceptablyLarge() LAST RESORT!! m_pawn.m_Door="$m_pawn.m_Door);		#endif
		m_TeamManager.m_Door = m_pawn.m_Door;
	}
	
	if((m_TeamManager.m_Door == none) || (m_TeamManager.m_Door.m_CorrespondingDoor == none))
	{
		#ifdefDEBUG	if(bShowLog) log(" PROBLEM : PreEntryRoomIsAcceptablyLarge() m_TeamManager.m_Door="$m_TeamManager.m_Door);		#endif
		return false;
	}

	if(m_TeamManager.m_Door.m_CorrespondingDoor.m_eRoomLayout == ROOM_None)
		return false;

	return true;
}

//------------------------------------------------------------------
// PostEntryRoomIsAcceptablyLarge()                                         
//------------------------------------------------------------------
function bool PostEntryRoomIsAcceptablyLarge()
{
	if(m_TeamManager.m_eMovementMode == MOVE_Recon)
		return false;

	if(m_TeamManager.m_Door == none)
	{
		#ifdefDEBUG	if(bShowLog) log("  PROBLEM : PostEntryRoomIsAcceptablyLarge() LAST RESORT!! m_pawn.m_Door="$m_pawn.m_Door);	#endif
		m_TeamManager.m_Door = m_pawn.m_Door;
	}

	if(m_TeamManager.m_Door == none)
	{
		#ifdefDEBUG	if(bShowLog) log(" PROBLEM : PostEntryRoomIsAcceptablyLarge() m_TeamManager.m_Door==none");		#endif
		return false;
	}

	if(m_TeamManager.m_Door.m_eRoomLayout == ROOM_None)
		return false;

	return true;
}

//------------------------------------------------------------------
// GetLeadershipReactionTime()                                         
//------------------------------------------------------------------
function FLOAT GetLeadershipReactionTime()
{
	local FLOAT fDelay;
	
	fDelay = 2.f - m_pawn.GetSkill(SKILL_Leadership)*2.f;
	fDelay = FClamp(fDelay, 0f, 2.0f);
	#ifdefDEBUG	if(bShowLog) log(pawn$" : GetLeadershipReactionTime() leadershipskill="$m_pawn.GetSkill(SKILL_Leadership)$" reaction time="$fDelay);	#endif
	return fDelay;
}

//------------------------------------------------------------------
// OnRightSideOfDoor()                                         
//------------------------------------------------------------------
function bool OnRightSideOfDoor(actor aTarget)
{
	local vector vDir, vResult;

	if(aTarget == none)
		return false;

	vDir = normal(pawn.location - aTarget.location);
	vResult = vDir cross vector(aTarget.rotation);
	if(vResult.z < 0)
		return true;
	else
		return false;
}

//------------------------------------------------------------------
//  ResetGadgetGroup()
//------------------------------------------------------------------
function ResetGadgetGroup()
{
	m_iActionUseGadgetGroup = 0;
}

//------------------------------------------------------------------
// AimingAt()                                         
//------------------------------------------------------------------
function bool AimingAt(Pawn enemy)
{
	local vector  vDir;
/*
	local FLOAT   fAccuracy;	
	fAccuracy = R6AbstractWeapon(Pawn.EngineWeapon).GetWorstAccuracy();
	logX(" AimingAT() : worst accuracy="$fAccuracy);
	if(fAccuracy > 5.f)
	{
		log("  Exit AimingAI() : Accuracy is too low....");
		return false;
	}
*/	
	vDir = normal(enemy.location - pawn.location);
	if(vDir dot vector(pawn.rotation + m_pawn.m_rRotationOffset) > 0.5)
		return true;
	else
		return false;
}

//------------------------------------------------------------------
// AttackTimer()                                         
//------------------------------------------------------------------
event AttackTimer()
{	
	// check is rainbow is armed with primary or secondary
	if(m_pawn.m_iCurrentWeapon > 2)
		return;

	m_pawn.m_bReloadToFullAmmo = false;
	if(m_bWeaponsDry)
	{
		if(enemy != none)
		{
			StopFiring();
			EndAttack();
		}
		return;
	}

	// check for necessary reload
	if(!m_pawn.m_bChangingWeapon && (Pawn.EngineWeapon.NumberOfBulletsLeftInClip() == 0))
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" (attackTimer) has no ammo left, must reload...clips="$Pawn.EngineWeapon.GetNbOfClips());	#endif
		RainbowReloadWeapon();
		if(bFire == 1)
		{
			StopFiring();
			EndAttack();
		}
	}

	// cannot attack until finished reloading weapon
	if(m_pawn.m_bReloadingWeapon || m_pawn.m_bChangingWeapon)
		return;

	// check if enemy is dead or surrendered
	if((enemy != none) && (R6Pawn(enemy).m_bIsKneeling || !R6Pawn(enemy).IsAlive()))
		EndAttack();

	if(bFire == 0) 
	{
		if(enemy != none)
		{
			focus = enemy;
			target = enemy;
			
			if(AimingAt(enemy))
			{
				//logX(" I Am AIMINGAT : So start firing!!! ");
				// if this rainbow AI is stationary, they should wait until their accuracy improves before firing
				if(m_pawn.IsStationary() && !IsReadyToFire(enemy))
					return;

				Pawn.EngineWeapon.SetRateOfFire(ROF_FullAuto); 
				StartFiring();
			}
		}
	}
	else
	{
		//log("  ENDATTACK() : 1 bFire="$bFire);
		StopFiring();
		if(!EnemyIsAThreat())
			EndAttack();
	}
}

//------------------------------------------------------------------
// StopAttack()                                         
//------------------------------------------------------------------
event StopAttack()
{
	//logX(" **** StopAttack() : enemy=="$enemy);
	StopFiring();
	if(!EnemyIsAThreat())
		EndAttack();
}

//------------------------------------------------------------------
// SetFocusToDoorKnob()                                         
//------------------------------------------------------------------
function SetFocusToDoorKnob(R6IORotatingDoor aDoor)
{
	if(aDoor == none)
		return;

	if(aDoor.m_bTreatDoorAsWindow)
		SetLocation(aDoor.Location - 30*vector(aDoor.Rotation));
	else
		SetLocation(aDoor.Location - 128*vector(aDoor.Rotation));
	focus = self;
}

//==========================================================
//                  -- state LOCKPICKDOOR --                
//==========================================================
state LockPickDoor
{
ignores SeePlayer;

	function BeginState()
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" has entered state LockPickDoor...");	#endif
		m_pawn.m_bAvoidFacingWalls = false;
		m_bIgnoreBackupBump = true;		
	}
    
	function EndState()
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" has exited state LockPickDoor...");		#endif
		m_pawn.m_bAvoidFacingWalls = true;
		m_bIgnoreBackupBump = false;
		
		if(m_pawn.m_bIsLockPicking)
		{
			#ifdefDEBUG	if(bShowLog) log(" Exit lockPick state prematurely... ");	#endif
			m_pawn.m_bIsLockPicking = false;
			m_pawn.m_bPostureTransition = false;	
			m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5); //R6ResetAnimBlendParams
			m_pawn.m_ePlayerIsUsingHands = HANDS_None;			
		}

		// make sure rainbow gets weapon back before leaving this state
		if(m_pawn.m_bWeaponIsSecured && !m_pawn.m_bWeaponTransition)
		{
			m_pawn.m_eEquipWeapon = EQUIP_EquipWeapon;
			m_pawn.PlayWeaponAnimation();
		}

		if (m_RotatingDoor.m_bIsDoorLocked)
    		m_pawn.ServerPerformDoorAction(m_RotatingDoor, m_RotatingDoor.eDoorCircumstantialAction.CA_LockPickStop);
	}

Begin:
	// get very close to door & look at door knob
	m_vTargetPosition = m_pawn.m_Door.location + 20*vector(m_pawn.m_Door.rotation);
	SetLocation(m_RotatingDoor.location - 128*vector(m_RotatingDoor.rotation));
	MoveToPosition(m_vTargetPosition, rotator(location - pawn.location));
	focus = self;
	FinishRotation();

	// secure weapon
	m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
    FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 

	// play lockpicking animation 
	m_pawn.SetNextPendingAction(PENDING_LockPickDoor);
	m_pawn.m_bIsLockPicking = true;
	Sleep(0.1);

	// play lockpicking sound
	m_RotatingDoor.PlayLockPickSound();

	// wait until necessary time has elapsed
	if(m_pawn.m_bHasLockPickKit)
		Sleep((m_RotatingDoor.m_fUnlockBaseTime - 2.0) * (2.0 - m_pawn.ArmorSkillEffect()) );
	else
		Sleep(m_RotatingDoor.m_fUnlockBaseTime * (2.0 - m_pawn.ArmorSkillEffect()));		

	// set the door's state to unlocked
	m_pawn.ServerPerformDoorAction(m_RotatingDoor, m_RotatingDoor.eDoorCircumstantialAction.CA_UnLock);
	
	// reset cycling lockpicking animation
	m_pawn.m_bIsLockPicking = false;
	m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5);
	m_pawn.m_ePlayerIsUsingHands = HANDS_None;
	Sleep(1.0);

	// get weapon
	m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
    FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 

End:
	// return to previous state
	GotoState(m_PostLockPickState);
}

//------------------------------------------------------------------
// GotoLockPickState()                                         
//------------------------------------------------------------------
function GotoLockPickState(R6IORotatingDoor door)
{
	m_RotatingDoor = door;
	if(m_RotatingDoor == none)
		return;
	
	m_PostLockPickState = GetStateName();
	m_TeamManager.SetTeamState(TS_LockPicking);
	GotoState('LockPickDoor');
}

//------------------------------------------------------------------
// RainbowCannotCompleteOrders()                                         
//------------------------------------------------------------------
function RainbowCannotCompleteOrders()
{
	#ifdefDEBUG	if(bShowLog) log(pawn$" : RainbowCannotCompleteOrders(), Play Sound, reset state... ");		#endif
	m_TeamManager.ActionCompleted(false);
	m_iStateProgress = 0;
	nextState = '';
	GotoState('HoldPosition');
}

//------------------------------------------------------------------
// CanThrowGrenadeIntoRoom()                                         
//------------------------------------------------------------------
function bool CanThrowGrenadeIntoRoom(R6Door aDoor, optional vector vTestTarget)
{
	local vector vTarget, vHitLocation, vHitNormal;
	local actor  hitActor;

	// if grenade is not a frag, then return true immediately (safe)
	if(!m_pawn.engineWeapon.HasBulletType('R6FragGrenade'))
		return true;

	if(vTestTarget == vect(0,0,0))
		vTarget = aDoor.location - 400*vector(aDoor.rotation);
	else
		vTarget = vTestTarget;
	HitActor = Trace(vHitLocation, vHitNormal, vTarget, aDoor.location - 96*vector(aDoor.rotation), false, vect(20,20,40));
	if(HitActor == none)
		return true;

	return false;
}	

//==========================================================//
//                  -- state PERFORMACTION --               //
// This state is used by the second member in a player's    //
// team when instructed by Team Manager to carry out an		//
// action.  This action normally comes the Rose des Vents,  //
// and mainly involves door related actions.				//
// TODO : consider using anim NOTIFY functions instead of   //
//        sleep()											//
//==========================================================//
state PerformAction
{
    function BeginState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" has entered state PerformAction...m_ActionTarget="$m_ActionTarget$" m_iStateProgress="$m_iStateProgress);		#endif
		m_pawn.m_bAvoidFacingWalls = false;
		m_bIndividualAttacks = false;
		m_iTurn = 0;
		m_bEnteredRoom = false;

		if(m_ActionTarget != none && m_ActionTarget.IsA('R6Door'))
		{
			m_TeamManager.m_Door = R6Door(m_ActionTarget);
			m_RotatingDoor = m_TeamManager.m_Door.m_RotatingDoor;
		}
		else
			m_RotatingDoor = none;
    }

    function EndState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" has exited state PerformAction... m_iStateProgress="$m_iStateProgress);		#endif
		if(m_iStateProgress == 14)			
			m_iStateProgress = 0;	
		SetTimer(0,false);
		m_pawn.m_u8DesiredYaw = 0;	
		m_pawn.m_bThrowGrenadeWithLeftHand = false;
		m_pawn.m_bAvoidFacingWalls = true;
		m_bIgnoreBackupBump=false;
		m_bIndividualAttacks = true;
    }

	function Timer()
	{
		m_iTurn++;
		LookAroundRoom(true);
	}

	function vector FindFloorBelowActor(actor target)
	{
		local vector vHitLocation, vHitNormal;

		Trace(vHitLocation, vHitNormal, target.location - vect(0,0,200), target.location, false);
		vHitLocation.z += pawn.collisionHeight; 
		return (vHitLocation);
	}
	
Begin:
	StopMoving();
    m_pawn.ResetBoneRotation();

	// apply a delay based on leadership skill before team starts performing order
	Sleep(GetLeadershipReactionTime());

    // if no target actor is provided, goto('End') and inform TeamAI
    if(m_ActionTarget == none)
        goto('ReinitAction');

	// check if this state was interrupted by a bump or attack
	switch(m_iStateProgress)
	{
		case 0:		goto('PrepareForAction');		break;
		case 1:		goto('FindActionTarget');		break;
		case 2:		goto('MoveToActionTarget');		break;
		case 3:     goto('PreEntry');				break;
        case 4:     goto('WaitForZuluGoCode');      break;
    	case 5:		
		case 6:		goto('PerformDoorAction');		break;
		case 7:		
		case 8:		goto('PerformGrenadeAction');	break;
		case 9:		
		case 10:	goto('PerformClearAction');		break;
		case 11:	goto('UpdateStatus');			break;
		case 12:	goto('ReinitAction');			break;
		default:	goto('WaitForTeamAI');			
	}
	
PrepareForAction:
	m_TeamManager.SetTeamState(TS_Moving);
	if(CanWalkTo(m_ActionTarget.location) || ActorReachable(m_ActionTarget)) 
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" XXX : can see the actionTarget directly, so move directly towards it...");	#endif
		goto('MoveToActionTarget');
	}
	m_iStateProgress = 1;

FindActionTarget:
	#ifdefDEBUG	if(bShowLog) log(" XXX : cannot see the actionTarget directly so, find a path towards it...m_ActionTarget="$m_ActionTarget);	#endif	
	if(!CanWalkTo(m_ActionTarget.location) && !ActorReachable(m_ActionTarget)) 
	{
		if(m_RotatingDoor != none && m_RotatingDoor.m_bTreatDoorAsWindow)	
			FindPathToTargetLocation(FindFloorBelowActor(m_ActionTarget));
		else
			FindPathToTargetLocation(m_ActionTarget.location, m_ActionTarget);
	}
	m_iStateProgress = 2;
	
MoveToActionTarget:
    // if orders include grenade, and door is not locked, switch to grenade in advance...
	if(!m_RotatingDoor.m_bIsDoorLocked && (m_TeamManager.m_iTeamAction & TEAM_Grenade) > 0)
        SwitchWeapon(m_iActionUseGadgetGroup);

	#ifdefDEBUG	if(bShowLog) log(pawn$" XXX : move to action target = "$m_ActionTarget$" m_RotatingDoor="$m_RotatingDoor );	#endif
	m_bIgnoreBackupBump=true;
	if(m_RotatingDoor != none 
		&& m_TeamManager.m_iTeamAction == TEAM_CloseDoor 
		&& m_RotatingDoor.DoorOpenTowardsActor(m_ActionTarget) 
		&& !PreEntryRoomIsAcceptablyLarge())
	{		
		if(m_RotatingDoor.m_bIsOpeningClockWise)
			m_vTargetPosition = m_ActionTarget.location - 85*vector(m_ActionTarget.rotation) + 85*vector(m_ActionTarget.rotation + rot(0,16384,0));
		else
			m_vTargetPosition = m_ActionTarget.location - 85*vector(m_ActionTarget.rotation) - 85*vector(m_ActionTarget.rotation + rot(0,16384,0));

		R6PreMoveTo(m_vTargetPosition, m_RotatingDoor.location, PACE_Walk); 
		MoveTo(m_vTargetPosition, m_RotatingDoor);   
		MoveToPosition(m_vTargetPosition, rotator(m_RotatingDoor.location - pawn.location));
	}
	else
	{
		R6PreMoveToward(m_ActionTarget, m_ActionTarget, PACE_Walk);
		MoveToward(m_ActionTarget);   
		MoveToPosition(m_ActionTarget.location, m_ActionTarget.rotation);
	}
	StopMoving();
    Sleep(0.5);

UnLockDoor:
	// check if door is locked...
	if(m_RotatingDoor.m_bIsDoorLocked)
		GotoLockPickState(m_RotatingDoor);

	m_TeamManager.SetTeamState(TS_Moving);

	// make sure we are equiped with grenade, if not already
	if((m_TeamManager.m_iTeamAction & TEAM_Grenade) > 0)
        SwitchWeapon(m_iActionUseGadgetGroup);
	else // if there is no grenade action, make sure we are equipped with primary/secondary
		EnsureRainbowIsArmed();

	// wait for team to arrive
	while(!m_TeamManager.LastMemberIsStationary())
		Sleep(0.5);

	m_bIgnoreBackupBump=false;
	m_iStateProgress = 3;

PreEntry:
	if((m_pawn.m_Door == m_ActionTarget) && m_RotatingDoor.m_bTreatDoorAsWindow)
	{
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door); 
		m_iStateProgress = 4;
		goto('WaitForZuluGoCode');
	}
	
	if(m_RotatingDoor != none)
	{
		ForceCurrentDoor(R6Door(m_ActionTarget));
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
	}
	
	// get into position before waiting for Zulu
	if(PreEntryRoomIsAcceptablyLarge())
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" PreEntryRoomIsAcceptablyLarge() is true...m_TeamManager.m_Door="$m_TeamManager.m_Door);		#endif
		// move into the proper position for a room entry (not directly in front of door)				
		m_vTargetPosition = getEntryPosition(false);    
		#ifdefDEBUG	if(bShowLog) log(pawn$" move into the proper position for a room entry...m_vTargetPosition="$m_vTargetPosition);	#endif
		if(m_vTargetPosition != vect(0,0,0))
		{
			R6PreMoveTo(m_vTargetPosition, m_RotatingDoor.location, PACE_Walk); 
			MoveTo(m_vTargetPosition);   
			MoveToPosition(m_vTargetPosition, rotator(m_TeamManager.m_Door.m_CorrespondingDoor.location - m_vTargetPosition));
			StopMoving();
		}
	}
	m_iStateProgress = 4;

WaitForZuluGoCode:	
    if( m_TeamManager.m_bCAWaitingForZuluGoCode )
    {
		m_TeamManager.SetTeamState(TS_Waiting);
        Sleep(0.5);
        goto('WaitForZuluGoCode');
    }
    m_iStateProgress = 5;
	
PerformDoorAction:
	#ifdefDEBUG	if(bShowLog) log(pawn$" XXX : label PerformDoorAction :: m_ActionTarget="$m_ActionTarget$" m_iTeamAction="$m_TeamManager.m_iTeamAction);	#endif
    if(((m_TeamManager.m_iTeamAction & TEAM_OpenDoor) > 0) || ((m_TeamManager.m_iTeamAction & TEAM_CloseDoor) > 0))
    {        
		if(m_RotatingDoor != none)
        {
			#ifdefDEBUG	if(bShowLog) log(pawn$" XXX : m_ActionTarget="$m_ActionTarget);	#endif
			if(m_RotatingDoor.m_bIsDoorClosed)
            {				
				focus = m_RotatingDoor;
				if(m_TeamManager.m_Door == none)
				{
					#ifdefDEBUG	if(bShowLog) log(" m_TeamManager.m_Door == none, so get it from ActionTarget...");	#endif
					m_TeamManager.m_Door = R6Door(m_ActionTarget);
				}
								
				// focus should be the door knob, not the pivot/hinges
				SetFocusToDoorKnob(m_RotatingDoor);
				Sleep(1.5);
            }

			// make sure everyone is ready before continuing
			while(!m_TeamManager.LastMemberIsStationary())
				Sleep(0.5);

			// check to see if door is already in the desired state		
			if(((m_TeamManager.m_iTeamAction & TEAM_OpenDoor) > 0) && m_RotatingDoor.m_bIsDoorClosed)
			{
				m_iStateProgress = 6;
				if(m_RotatingDoor.m_bTreatDoorAsWindow)
					m_TeamManager.SetTeamState(TS_Opening);
				else
					m_TeamManager.SetTeamState(TS_OpeningDoor);
				m_pawn.PlayDoorAnim(m_RotatingDoor);
				Sleep(0.5);
				m_pawn.ServerPerformDoorAction(m_RotatingDoor, m_RotatingDoor.eDoorCircumstantialAction.CA_Open);		
				
				// wait for door to open
				while(m_RotatingDoor.m_bIsDoorClosed)
				{
					if(!m_RotatingDoor.m_bInProcessOfOpening)
					{
						Sleep(1.0);
						goto('PerformDoorAction');
					}
					else
						Sleep(0.2);
				}
			}
			else if(((m_TeamManager.m_iTeamAction & TEAM_CloseDoor) > 0) && !m_RotatingDoor.m_bIsDoorClosed)
			{
				m_iStateProgress = 6;
				if(m_RotatingDoor.m_bTreatDoorAsWindow)
					m_TeamManager.SetTeamState(TS_Closing);
				else
					m_TeamManager.SetTeamState(TS_ClosingDoor);

				m_pawn.PlayDoorAnim(m_RotatingDoor);
				Sleep(0.5);
				m_pawn.ServerPerformDoorAction(m_RotatingDoor, m_RotatingDoor.eDoorCircumstantialAction.CA_Close);

				// wait for door to close
				while(m_RotatingDoor.m_iCurrentOpening != 0)
					Sleep(0.5);
			}
			else if(m_iStateProgress < 6)  // then this is the first attempt to open the door
			{
				// door was not found in the appropriate state, so cancel the order...
				RainbowCannotCompleteOrders();
			}
        }
        else
        {
            m_TeamManager.ActionCompleted(false);  
            goto('ReinitAction');
        }
    }
	m_iStateProgress = 7;
	
PerformGrenadeAction:
	// check if grenade has already been thrown
	if(m_iStateProgress == 8)
	{
		Sleep(1.0);
		m_iStateProgress = 9;
		goto('PerformClearAction');
	}
 
    // throw grenade into room 
    if((m_TeamManager.m_iTeamAction & TEAM_Grenade) > 0) 
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" throw grenade into room...");	#endif
		m_TeamManager.SetTeamState(TS_Grenading);
		disable('notifyBump');

		// set the grenade target...
		m_vLocationOnTarget = m_ActionTarget.location + 450*vector(m_ActionTarget.rotation);
		SetLocation(m_vLocationOnTarget);
		
		// check if it is possible to throw a grenade into this room
		if(!CanThrowGrenadeIntoRoom(R6Door(m_ActionTarget).m_CorrespondingDoor))
		{
			#ifdefDEBUG	if(bShowLog) log(" there isn't enough clear space inside room, so skip grenade action...");		#endif
			m_TeamManager.ResetGrenadeAction();
			m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, RMV_TeamOrderFromLeadNil);

			// return to primary weapon  
			SwitchWeapon(1);
			Sleep(1.0);
			m_iStateProgress = 9;
			goto('PerformClearAction');
		}

		focus = self;
        target = self;	
		FinishRotation(); 

		// todo : add check to made sure that we are armed with grenade
        SetRotation(m_ActionTarget.rotation);   
		SetGunDirection(target);		
		SetGrenadeParameters(PreEntryRoomIsAcceptablyLarge());
        m_pawn.PlayWeaponAnimation(); 
        FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 
		m_pawn.m_eRepGrenadeThrow = GRENADE_None;

		SetGunDirection(none);
		enable('notifybump');
		m_iStateProgress = 8;
		
		// return to primary weapon  
        SwitchWeapon(1);	

		// wait for grenade to explode
        Sleep(m_pawn.EngineWeapon.GetExplosionDelay());	
    } 
    m_iStateProgress = 9;

PerformClearAction:
    // enter and clear room (team will follow)
    if((m_TeamManager.m_iTeamAction & TEAM_ClearRoom) > 0) 
    {
		#ifdefDEBUG	if(bShowlog) log(pawn$" : enter and clear room...");	#endif
		m_TeamManager.SetTeamState(TS_ClearingRoom);

		// safety precaution
		if(m_TeamManager.m_Door == none)
		{
			#ifdefDEBUG	if(bShowLog) log(pawn$"  IRREGULAR!! m_TeamManager.m_Door==none!!");	#endif
			m_TeamManager.m_Door = R6Door(m_ActionTarget);			
		}
		m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;

		if(m_iStateProgress == 9)
		{
			// initial move in order to get through the doorway (use R6Door actors)...
			m_vTargetPosition = m_TeamManager.m_Door.location;
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Run);    
			MoveToPosition(m_vTargetPosition, m_TeamManager.m_Door.rotation);   

			m_TeamManager.EnteredRoom(m_pawn);
			m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.location;
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Run);    
			MoveToPosition(m_vTargetPosition, m_TeamManager.m_Door.rotation);   
			StopMoving();

			m_iStateProgress = 10;
		}

		if(m_pawn.m_iId == (m_TeamManager.m_iMemberCount - 1))
		{
			m_iStateProgress = 11;
			SetTimer(1.0,true);
			LookAroundRoom(true);
			Sleep(1.5);			
			goto('UpdateStatus');
		}

		// get target position inside room, if there is enough room...
		// area on other side of door may be too constricted, move to corresponding door actor, and rest of team should just follow...
		if(PostEntryRoomIsAcceptablyLarge())
		{
			m_vTargetPosition = getEntryPosition(true);     			
			SetLocation(focalPoint);  
		}
		else
		{
			#ifdefDEBUG	if(bShowLog) log(pawn$" Enter Room : there is not enough room inside...so go in as far as possible");	#endif
			FindNearbyWaitSpot(m_TeamManager.m_Door.m_CorrespondingDoor, m_vTargetPosition); 
			SetLocation(m_vTargetPosition + 60*(m_vTargetPosition - pawn.location));
		}

		R6PreMoveTo(m_vTargetPosition, location, PACE_Run);    
		MoveToPosition(m_vTargetPosition, rotator(location - m_vTargetPosition));   
		StopMoving();

		SetTimer(1.0,true);
		LookAroundRoom(true);

		m_iStateProgress = 11;
        Sleep(3);
    }
	else
		m_iStateProgress = 11;

UpdateStatus:
    // inform TeamAI that the action has been completed - include a success status
	// TODO : check that the entire team has entered the room....
	// make sure that we are no longer engaging any terrorists
	if(m_TeamManager.RainbowIsEngaging())
	{
		Sleep(0.5);
		goto('UpdateStatus');
	}

	#ifdefDEBUG	if(bShowLog) log(pawn$" inform TeamAI that action is completed...");	#endif
	if((m_TeamManager.m_iTeamAction & TEAM_ClearRoom) > 0) 
    {
		m_TeamManager.ActionCompleted(true);
		m_iStateProgress = 12;

		if( (m_TeamManager.m_Door != none) && (m_pawn.m_iId == (m_TeamManager.m_iMemberCount - 1)) )
		{
			// take a few steps forward to get out of the way...
			m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.location - 96*vector(m_TeamManager.m_Door.m_CorrespondingDoor.rotation);
			SetLocation(m_TeamManager.m_Door.location + 200*vector(m_TeamManager.m_Door.rotation));
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk);
			MoveTo(m_vTargetPosition, self);
		}
	}
	else
	{
		m_TeamManager.ActionCompleted(true);
		m_iStateProgress = 12;
	}

ReinitAction:
    m_ActionTarget = none;
	m_iStateProgress = 13;

WaitForTeamAI:
    // wait for furthur instructions
    Sleep(1); 	
    if(nextState != '')
    {
		m_iStateProgress = 14;
		GotoState(nextState);
	}
    GotoState('HoldPosition');
}

//==========================================================//
//              -- state FINDPATHTOTARGET --                //
//==========================================================//
state FindPathToTarget
{
	#ifdefDEBUG function BeginState() {	if(bShowLog) log(pawn$" entered state FindPathToTarget...m_DesiredTarget="$m_DesiredTarget$" m_vDesiredLocation="$m_vDesiredLocation);	}	#endif
	function EndState()		
	{	
		#ifdefDEBUG if(bShowLog) log(pawn$" exited state FindPathToTarget...");	#endif
		SetTimer(0, false);
	}

	function Timer()
    {
		if(CanThrowGrenade(pawn.location, true, false))
		{
			SetTimer(0, false);
			StopMoving();
			GotoState('TeamMoveTo', 'Action');
		}
	}

Begin:
	if(m_TeamManager.m_iTeamAction == TEAM_MoveAndGrenade)
		SetTimer(0.3, true);

	// find path to target
	if(m_DesiredTarget != none)
		moveTarget = FindPathToward(m_DesiredTarget, true);
	else
		moveTarget = FindPathTo(m_vDesiredLocation, true);     
	
	if(moveTarget != none)
	{
		// if this member is in front of a door and their moveTarget is the R6Door actor on the other side of the door, do a room entry
		if(NeedToOpenDoor(moveTarget))
		{
			m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door); 
			MoveToPosition(m_pawn.m_Door.location, m_pawn.m_Door.rotation); 
			pawn.acceleration = vect(0,0,0);

			// prepare for a room entry...
			SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
			Sleep(1);
			GotoStateLeadRoomEntry();
		}

		m_TargetLadder = R6Ladder(moveTarget);
		if((m_pawn.m_Ladder != none) && (m_TargetLadder != none) && (m_pawn.m_Ladder != m_TargetLadder))
			m_TeamManager.InstructTeamToClimbLadder(R6LadderVolume(m_pawn.m_Ladder.myLadder), true, m_pawn.m_iId);

		#ifdefDEBUG	if(bShowLog) log(self$" FindPathToTarget : move to the movetarget=["$moveTarget$"] on the way to the m_vDesiredLocation...");	#endif
		R6PreMoveToward(moveTarget, moveTarget, PACE_Walk);
		MoveToward(moveTarget);

		if(m_DesiredTarget != none)
		{		
			if(ActorReachable(m_DesiredTarget))
				Goto('End');
		}
		else if(PointReachable(m_vDesiredLocation)) 
			Goto('End');

		goto('Begin');
	}
	else
	{
		#ifdefDEBUG logX(" state FindPathToTarget : cannot find a path to m_vDesiredLocation="$m_vDesiredLocation);	#endif
		if(m_TeamManager.m_iTeamAction != 0)
		{
			if(!m_TeamManager.m_bGrenadeInProximity)
				RainbowCannotCompleteOrders();		
		}
	}

End:
	// move directly to target location
	R6PreMoveTo(m_vDesiredLocation, m_vDesiredLocation, PACE_Walk);
	MoveTo(m_vDesiredLocation);	
	GotoState(m_PostFindPathToState);
}

function FindPathToTargetLocation(vector vTarget, optional actor aTarget)
{
	#ifdefDEBUG	if(bShowLog) log(" FindPathToTargetLocation was called for location vTarget="$vTarget$" aTarget="$aTarget);		#endif
	m_TeamManager.SetTeamState(TS_Moving);
	m_DesiredTarget = aTarget;
	m_vDesiredLocation = vTarget;
	m_PostFindPathToState = GetStateName();
	GotoState('FindPathToTarget');
}

function ReInitEntryPositions()
{
	m_vPreEntryPositions[0] = vect(0,0,0);
	m_vPreEntryPositions[1] = vect(0,0,0);
}

//==========================================================//
//              -- state ROOMENTRY --                       //
// This state is used by team members during a room entry.  //
// (includes all members except the one that is leading	the //
// room entry).												//
//==========================================================//
state RoomEntry
{
    function BeginState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" entered state RoomEntry...m_iStateProgress="$m_iStateProgress);		#endif
        m_pawn.ResetBoneRotation();        
		m_pawn.m_bAvoidFacingWalls = false;
		m_bReactToNoise = true;
		m_bEnteredRoom = false;
		m_bIndividualAttacks = false;
		m_iTurn = 0;
		ReInitEntryPositions();
    }

    function EndState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" exited state RoomEntry... m_iStateProgress="$m_iStateProgress);		#endif
		m_pawn.m_bAvoidFacingWalls = true;
		m_bReactToNoise = false;
		if(m_iStateProgress == 5)
			m_iStateProgress = 0;		// normal exit, so reinit this variable...
		m_bIndividualAttacks = true;
		SetTimer(0,false);
		m_pawn.m_u8DesiredYaw = 0;
    }

	function Timer()
	{
		m_iTurn++;
		LookAroundRoom(false);
	}

	function bool HasEnteredRoom(R6Pawn member)
	{
		if(VSize(member.location - m_TeamManager.m_Door.location) < VSize(member.location - m_TeamManager.m_Door.m_CorrespondingDoor.location))
			return false;
		else
			return true;
	}

	function SetMemberFocus()
	{
		if(PreEntryRoomIsAcceptablyLarge())
		{
			if(m_pawn.m_iId == 3)
			{
				if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
					SetLocation(pawn.location - 300*vector(m_TeamManager.m_Door.rotation));
				else
					SetLocation(m_TeamManager.m_Door.location - 300*vector(m_TeamManager.m_Door.rotation));	 // last member should be looking back to cover team
				focus = self;
			}
			else if((m_pawn.m_iId == 2) && (!m_TeamLeader.m_bIsPlayer || (m_TeamLeader.m_bIsPlayer && !m_TeamManager.m_bTeamIsSeparatedFromLeader)) )
			{
				SetLocation(pawn.location - 300*normal(m_TeamManager.m_Door.location - pawn.location) - 200*vector(m_TeamManager.m_Door.rotation));
				focus = self;
			}
			else
				SetFocusToDoorKnob(m_TeamManager.m_Door.m_RotatingDoor);
		}
		else
		{
			if(m_pawn.m_iId == (m_TeamManager.m_iMemberCount - 1))
			{
				SetLocation(pawn.location - 200*normal(m_TeamManager.m_Door.location - pawn.location));
				focus = self;
			}
			else
				SetFocusToDoorKnob(m_TeamManager.m_Door.m_RotatingDoor);
		}
	}

	function vector GetSingleFilePosition()
	{
		local	vector   vDir;

		vDir = m_PaceMember.location - pawn.location;
		return(m_PaceMember.location - GetFormationDistance()*normal(vDir));
	}

	function CoverRear()
	{
		if(m_TeamManager.m_iTeamAction == TEAM_None)
		{
			SetLocation(pawn.location + (pawn.location - focalPoint)); 
			focus = self;
		}		
	}

	function FLOAT DistanceToLocation(vector vTarget)
	{
		return VSize(pawn.location - vTarget);	
	}

	function R6Pawn.eMovementPace GetRoomEntryPace(bool bRun)
	{
		local R6Pawn.eMovementPace      ePace;
		local bool						bCrouchedEntry;
		
		if(m_TeamLeader.m_bIsPlayer)
		{
			if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
				bCrouchedEntry = m_PaceMember.bIsCrouched;
			else
				bCrouchedEntry = m_TeamLeader.bIsCrouched;
		}
		else
			bCrouchedEntry = (m_TeamManager.m_eMovementSpeed == SPEED_Cautious);

		if(bCrouchedEntry)
		{
			if(bRun)
				ePace = PACE_CrouchRun;
			else
				ePace = PACE_CrouchWalk;
		}
		else
		{
			if(bRun)
				ePace = PACE_Run;
			else
				ePace = PACE_Walk;
		}

		return ePace;
	}

Begin:
	// check if this state was interrupted by a bump or attack
	switch(m_iStateProgress)
	{
		case 0:		goto('GetIntoPosition');		break;
		case 1:		goto('WaitForGo');				break;
		case 2:		goto('PassDoor');				break;
		case 3:		goto('EnterRoom');				break;
		default:	goto('WaitOnLeader');
	}

GetIntoPosition:
    // get target position in front of closed door...
	#ifdefDEBUG	if(bShowLog) log(pawn$" [GetIntoPosition] get target position in front of closed door... m_TeamManager.m_Door="$m_TeamManager.m_Door);	#endif
	// do some checks to make sure door actors are valid
	if(m_TeamManager.m_Door.m_RotatingDoor == none)
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" PROBLEM!!  m_TeamManager.m_Door.m_RotatingDoor==none");		#endif
		GotoState('FollowLeader');
	}
	if(m_TeamManager.m_Door.m_CorrespondingDoor == none)
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" PROBLEM!!  m_TeamManager.m_Door.m_CorrespondingDoor==none");	#endif
		GotoState('FollowLeader');
	}

	// check if there is enough room to form around door, if not stay in single file...
	if(PreEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = getEntryPosition(false);    
		if(m_vTargetPosition != pawn.location)
		{
			if(!CanWalkTo(m_vTargetPosition) && !PointReachable(m_vTargetPosition)) 
			{
				FindPathToTargetLocation(m_vTargetPosition);
			}
			else 
			{	
				// intermediate moves...
				if((m_vPreEntryPositions[0] != vect(0,0,0)) && (DistanceToLocation(m_vPreEntryPositions[0]) < DistanceToLocation(m_vTargetPosition)) )			
				{
					if((m_vPreEntryPositions[1] == vect(0,0,0)) || (DistanceToLocation(m_vPreEntryPositions[0]) < DistanceToLocation(m_vPreEntryPositions[1])) )
					R6PreMoveTo(m_vPreEntryPositions[0], m_vPreEntryPositions[0], GetRoomEntryPace(false));
					MoveTo(m_vPreEntryPositions[0]);   

					if(m_vPreEntryPositions[1] != vect(0,0,0))
					{
						R6PreMoveTo(m_vPreEntryPositions[1], m_vPreEntryPositions[1], GetRoomEntryPace(false));
						MoveTo(m_vPreEntryPositions[1]); 
					}
				}
				else if((m_vPreEntryPositions[1] != vect(0,0,0)) && (DistanceToLocation(m_vPreEntryPositions[1]) < DistanceToLocation(m_vTargetPosition)) )		
				{
					R6PreMoveTo(m_vPreEntryPositions[1], m_vPreEntryPositions[1], GetRoomEntryPace(false));
					MoveTo(m_vPreEntryPositions[1]); 
				}
				R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_Door.m_RotatingDoor.location, GetRoomEntryPace(false));
				MoveTo(m_vTargetPosition);   
				MoveToPosition(m_vTargetPosition, rotator(m_TeamManager.m_Door.m_CorrespondingDoor.location - m_vTargetPosition));
			}
		}
	}
	pawn.acceleration = vect(0,0,0);
	m_iStateProgress = 1;
	#ifdefDEBUG	if(bShowLog) log(pawn$" [WaitForGo] wait for Go to enter room... m_TeamLeader="$m_TeamLeader$" m_TeamLeader.m_bIsPlayer="$m_TeamLeader.m_bIsPlayer);	#endif

WaitForGo: 
	SetMemberFocus();
	StopMoving();	
	if( (m_TeamLeader.m_bIsPlayer && !HasEnteredRoom(m_PaceMember)) 
		 || (!m_TeamLeader.m_bIsPlayer && !R6RainbowAI(m_PaceMember.controller).m_bEnteredRoom) )
    {
		if(!PreEntryRoomIsAcceptablyLarge() && (DistanceTo(m_PaceMember) > GetFormationDistance()))
		{
			// keep up with leader (follow)
			// #ifdefDEBUG	if(bShowLog) log(pawn$" Pre Entry Room is not large enough...");	#endif
			m_vTargetPosition = GetSingleFilePosition();
			if(!PointReachable(m_vTargetPosition)) 
				FindPathToTargetLocation(m_PaceMember.location, m_PaceMember);
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(false));
			MoveTo(m_vTargetPosition);
		}
		else
		{
			if((m_pawn.m_iId == 2) && HasEnteredRoom(m_TeamLeader))
				focus = m_TeamManager.m_Door;
			Sleep(0.5);
		}
        Goto('WaitForGo');
    }
	m_iStateProgress = 2;

PassDoor:
	Sleep(0.2);

	// if there is not enough room to do a real room entry, go back to following leader
	if(!PostEntryRoomIsAcceptablyLarge())
	{
		#ifdefDEBUG	if(bShowlog) log(pawn$" PostEntryRoom is not large enough goto state FollowLeader ");	#endif
		m_TeamManager.EndRoomEntry();
		GotoState('FollowLeader');
	}

	m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;

    // initial move in order to get through the doorway (use R6Door actors)...
	#ifdefDEBUG	if(bShowLog) log(pawn$" [PassDoor] initial move in order to get through the doorway ... ");		#endif
	m_vTargetPosition = m_TeamManager.m_Door.location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));    
	MoveToPosition(m_vTargetPosition, rotator(m_vTargetPosition - pawn.location)); 

    // inform TeamAI - early in order to overlap movement of members...
    m_TeamManager.EnteredRoom(m_pawn); 
	m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));    
	MoveToPosition(m_vTargetPosition, rotator(m_vTargetPosition - pawn.location));  
	m_iStateProgress = 3;

	if(m_PaceMember.m_bIsPlayer)
		m_TeamManager.GetPlayerDirection();

EnterRoom:
	// get target position inside room...
	#ifdefDEBUG	if(bShowLog) log(pawn$" [EnterRoom] get target position inside room ... ");		#endif
    m_vTargetPosition = getEntryPosition(true);     
	SetLocation(focalPoint);	    // focal point was set by getEntryPosition()    

    // move inside room...  TODO: make sure there is enough room to enter.... 
	R6PreMoveTo(m_vTargetPosition, location, GetRoomEntryPace(true));    
	MoveToPosition(m_vTargetPosition, rotator(location - m_vTargetPosition));   
	
	SetTimer(1.0, true);
	LookAroundRoom(false);

	m_iStateProgress = 4;   
    Sleep(0.5);
       	
	#ifdefDEBUG	if(bShowLog) log(pawn$" [WaitOnLeader] wait for pacemember to start moving ... ");	#endif

WaitOnLeader:	
	StopMoving();
    Sleep(0.5);

	// when room is clear or player starts moving, look back
	if(m_eCoverDirection == COVER_None)
		CoverRear();

	// wait for pacemember to start moving and to be far enough away (so that not all members try to move at the same time)
	if((IsMoving(m_PaceMember) && (DistanceTo(m_PaceMember) > 200)) || (DistanceTo(m_PaceMember) > 300))
	{
		if(m_eCoverDirection == COVER_None)
			CoverRear();

		m_iStateProgress = 5;
		GotoState('FollowLeader');
	}
	else		
		Goto('WaitOnLeader');
}

//==========================================================//
//              -- state HOLDPOSITION --                    //
//==========================================================//
state HoldPosition
{
    function BeginState()   
	{       
		#ifdefDEBUG	if(bShowLog) log(pawn$" entered state holdposition...");	#endif
		m_bReactToNoise = true;
	}
    
	function EndState()		
	{		
		#ifdefDEBUG	if(bShowLog) log(pawn$" exited state holdPosition...");		#endif
		m_bReactToNoise = false;
		SetTimer(0, false);   
	}

    function Timer()
    {        
		// when timer goes off, team should continue waiting in crouched position / cover formation  
        m_iWaitCounter++;           
    }

Begin:    
	m_TeamManager.SetTeamState(TS_Holding);
    focus = none; 
    m_iWaitCounter = 0;
    pawn.acceleration = vect(0,0,0);
    SetTimer(1.0, true);   
	Sleep(1.0);
	
Hold:
	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
    if(!pawn.bIsCrouched && !pawn.m_bIsProne && (m_iWaitCounter > 8.0)) 
    {    
        pawn.bWantsToCrouch = true;
        Sleep(0.5); // to give enough time for the startCrouch to take event (performPhysics)       
    }

	// check if we need to reload
	if(NeedToReload())
		RainbowReloadWeapon();

    Sleep(1.0);

    if(nextState != '')
        GotoState(nextState);
    goto('Hold');
}

function SwitchWeapon(INT F)
{
    local R6AbstractWeapon newWeapon;

	// check if Rainbow is already equipped with the desired weapon
	if(F == m_pawn.m_iCurrentWeapon)
		return;

    Pawn.R6MakeNoise( SNDTYPE_Equipping );

    newWeapon = R6AbstractWeapon(m_pawn.GetWeaponInGroup(F));

    if (newWeapon != none)
    {		
        if(Level.NetMode == NM_Standalone)
            m_pawn.EngineWeapon.GotoState('');
		m_pawn.m_iCurrentWeapon = F;
        m_pawn.GetWeapon(newWeapon);
        m_pawn.m_bChangingWeapon = true;
        if (m_pawn.m_SoundRepInfo != none)
            m_pawn.m_SoundRepInfo.m_CurrentWeapon = F - 1; // -1 because the index start to zero not to one
		m_pawn.PlayWeaponAnimation();
	}
}       

//==========================================================//
//           -- state TeamSecureTerrorist --                //
//==========================================================//
state TeamSecureTerrorist
{
	function BeginState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" entered state TeamSecureTerrorist...m_ActionTarget="$m_ActionTarget);	#endif
		m_pawn.ResetBoneRotation();
		m_pawn.m_bAvoidFacingWalls = false;
		m_bIgnoreBackupBump=true;
		m_bStateFlag = false;
    }

    function EndState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" exited state TeamSecureTerrorist...");	#endif
		m_bIgnoreBackupBump=false;

		// reset arrest action if it was not completed
		if(!m_bStateFlag)
		{			
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5);
			m_pawn.m_ePlayerIsUsingHands = HANDS_None;
			m_pawn.PlayWeaponAnimation();			
			R6Terrorist(m_ActionTarget).ResetArrest();
		}

		// get weapon back
		if(m_pawn.m_bWeaponIsSecured && !m_pawn.m_bWeaponTransition)
			m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
    }
    
Begin:
	if(!R6Pawn(m_ActionTarget).IsAlive())
		Goto('End');

	// if this NPC is carrying out a player order, add a delay based on the leadership skill
	if(m_pawn.m_iId == 1)
		Sleep(GetLeadershipReactionTime());

	m_TeamManager.SetTeamState(TS_Moving);
	if(!CanWalkTo(m_ActionTarget.location) && !ActorReachable(m_ActionTarget)) 
		FindPathToTargetLocation(m_ActionTarget.location, m_ActionTarget);
	
DirectMove:
	#ifdefDEBUG	if(bShowLog) log(pawn$" TeamSecureTerrorist : move directly to the terrorist, m_ActionTarget="$m_ActionTarget);		#endif
	
	R6PreMoveToward(m_ActionTarget, m_ActionTarget, PACE_Walk);
	MoveToward(m_ActionTarget);	

	// check to make sure we have reached the terrorist
	if(DistanceTo(m_ActionTarget) > 100)
		goto('Begin');
	focus = m_ActionTarget;
	StopMoving();
	Sleep(0.5);
	
	while(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(TS_Waiting);
		Sleep(0.5);
	}

Secure:
	// assure no interruption
	Disable('SeePlayer');

	// check if terrorist is already secured
	if(R6Terrorist(m_ActionTarget).m_bIsUnderArrest)
	{
		// cancel orders, terrorist is already secured...
		RainbowCannotCompleteOrders();
	}
	m_TeamManager.SetTeamState(TS_SecuringTerrorist);

	// secure weapon
	m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
    FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 

	// todo : check if terrorist is already secured - MoveTeamToCompleted(false)
	R6Terrorist(m_ActionTarget).m_controller.DispatchOrder(R6Terrorist(m_ActionTarget).eTerroristCircumstantialAction.CAT_Secure, m_pawn);
    while( !R6Terrorist(m_ActionTarget).PawnHaveFinishedRotation() )
        Sleep(0.1);

	m_pawn.SetNextPendingAction(PENDING_SecureTerrorist);
	FinishAnim( m_pawn.C_iBaseBlendAnimChannel );
	m_bStateFlag = true;

	// Equip weapon
	m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
    FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 

End:
	if(m_pawn.m_iId == 0)
	{
		// AI team leader
		m_TeamManager.m_SurrenderedTerrorist = none;
		GotoState('Patrol');
	}
	else
	{
		m_TeamManager.MoveTeamToCompleted(true);
	}
}

//------------------------------------------------------------------
// TooCloseToThrowGrenade: check if we are too close to throw the grenade
//	the distance decrease when it's taking too much time
//------------------------------------------------------------------
function bool TooCloseToThrowGrenade( vector vPawnLocation  )
{
    local R6EngineWeapon weapon;
    local FLOAT fKillRadius;
    local FLOAT fExplosionRadius;

    weapon = m_pawn.GetWeaponInGroup(m_iActionUseGadgetGroup);
    if ( weapon == none )
        return false;

    if ( VSize( vPawnLocation - m_vLocationOnTarget ) < weapon.GetSaveDistanceToThrow() )
        return true;   
    
    return false;
}

//------------------------------------------------------------------
// CanThrowGrenade: if all conditions are okay, returns true if the 
//  rainbow can throw a grenade from vPawnLocation.
// bTest: used to evaluate if the rainbow is gonna be damaged 
//                 by the grenade
//------------------------------------------------------------------
function bool CanThrowGrenade( vector vPawnLocation, bool bTraceActors, bool bCheckTooClose )
{
    local vector vDir;
    local vector vTargetLoc;
    local FLOAT fDist;
	local actor  hitActor;
	local vector vHitLocation;
	local vector vHitNormal;
    local INT iTraceFlags;

    vDir = m_vLocationOnTarget - vPawnLocation;
    
    // If farther than 1500 units
    fDist = VSize(vDir);
    if( fDist > 1500 )
        return false;	// logX( "CanThrowGrenade: FALSE > 1500 units" );
    
    // if i'm going to hurt my self
    if ( bCheckTooClose && TooCloseToThrowGrenade( vPawnLocation ) )        
        return false;	// logX( "CanThrowGrenade: FALSE too close" );

    // approx check: are we gonna hit something if we throw the grenade
    vTargetLoc = m_vLocationOnTarget;
    vTargetLoc.Z += 15; // above the ground
    if(bTraceActors)
        iTraceFlags = TF_TraceActors;
    iTraceFlags = iTraceFlags|TF_LineOfFire;
    hitActor = R6Trace(	vHitLocation, vHitNormal, vTargetLoc, vPawnLocation, iTraceFlags, vect(20,20,10) );

    // m_pawn.dbgVectorAdd( vTargetLoc,    vect(10,10,10), 0, "target" );
    // m_pawn.dbgVectorAdd( vHitLocation,  vect(10,10,10), 1, "hit" );
    
    // if hit something and it's too far from target
    if ( hitActor != none && VSize( vHitLocation  - vTargetLoc ) > 30 ) // 30: flexible value. gives good result if not exactly on target.
        return false;	// logX( "CanThrowGrenade: FALSE  hit > 30 units. hitActor=" $hitActor.name$ " vSize:" $VSize( vHitLocation  - vTargetLoc ) );

	// logX( "CanThrowGrenade: TRUE " );
	return true;	
}

//------------------------------------------------------------------
// ClearThrowIsAvailable()
//------------------------------------------------------------------
function bool ClearThrowIsAvailable(vector vTarget)
{
	local	actor	hitActor;
	local   vector	vHitLocation, vHitNormal;		

	hitActor = pawn.R6Trace( vHitLocation, vHitNormal, vTarget + vect(0,0,40), pawn.location, TF_TraceActors|TF_LineOfFire, vect(30,30,15) );
	#ifdefDEBUG  if(bShowLog)	log(" ClearThrowIsAvailable() : pawn.location="$pawn.location$"  vTarget="$vTarget$" hitActor="$hitActor);	#endif

	if(hitActor == none)
		return true;

	if(hitActor.IsA('R6Pawn'))
		return false;

	return true;
}

//------------------------------------------------------------------
// ResetTeamMoveTo()
//------------------------------------------------------------------
function ResetTeamMoveTo()
{
	local INT iWeapon;

	m_iStateProgress = 0;
	SetTimer( 0, false );
	if(m_pawn.m_bInteractingWithDevice)
	{
		#ifdefDEBUG	if(bShowLog) log(" Quit Interacting With Device prematurely... ");	#endif
		m_pawn.m_bInteractingWithDevice = false;
		m_pawn.m_bPostureTransition = false;	
		m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5);
		m_pawn.m_ePlayerIsUsingHands = HANDS_None;	
		
        if(R6IOObject(m_ActionTarget) != none)
			R6IOObject(m_ActionTarget).PerformSoundAction(SIO_Interrupt);
	}

	// make sure rainbow gets weapon back
	if(m_pawn.m_bWeaponIsSecured && !m_pawn.m_bWeaponTransition)
	{
		m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
		m_pawn.PlayWeaponAnimation();
	}
	
	// make sure m_iCurrentWeapon is valid
	m_pawn.m_iCurrentWeapon = FClamp(m_pawn.m_iCurrentWeapon, 1, 4);
	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
}

//==========================================================//
//              -- state TeamMoveTo --                      //
//==========================================================//
state TeamMoveTo
{
    function BeginState()
    {
		#ifdefDEBUG	if(bShowLog) logX( " begin state");		#endif
		m_pawn.ResetBoneRotation();
	    m_pawn.m_bAvoidFacingWalls = false;	
		m_iStateProgress = 0;
    }

	// this code was moved into a function because the BeginState() is not called again when a GotoState() is done on the current state.
	function SetUpTeamMoveTo()
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" :: SetUpTeamMoveTo() was called...m_iStateProgress="$m_iStateProgress);	#endif
        #ifdefDEBUG	if(bShowLog) log(pawn$" :: m_vLocationOnTarget="$m_vLocationOnTarget$" m_vActionLocation="$m_TeamManager.m_vActionLocation);	#endif
		SetTimer( 0, false );
		
		m_vTargetPosition = m_TeamManager.m_vActionLocation;

		// if it's a move and grenade action and it's the first time, check
        // if we can throw the grenade from here, if fails, check if we
        // are too close, if so, get a nav point to go, otherwise walk in 
        // the direction of the point.
        if (( (m_TeamManager.m_iTeamAction & TEAM_Grenade) > 0 ) && ( m_iStateProgress == 0 ))
        {
            m_iStateProgress = 1; // first try
            // check if can throw grenade from here and if i'm not to close
            if ( !CanThrowGrenade( pawn.Location, false, true ) )
            {
                // try to be further from the location
                if ( TooCloseToThrowGrenade( pawn.Location ) &&
                     FindRandomNavPointToThrowGrenade() ) 
                {
                    // m_vTargetPosition is set in FindRandomNavPointToThrowGrenade
                    // logX( "beginstate: FindRandomNavPointToThrowGrenade ok" );
                    m_iStateProgress = 2; // try to reach a nav point
                }
                else
                {
                    // walk toward 
                    m_vTargetPosition = m_vLocationOnTarget;
                    m_vTargetPosition.Z += pawn.collisionHeight;

                    // as we walk toward, try to find the moment we can stop
                    SetTimer( 0.3, true );
                }
            }
            else
            {
                // don't move, we are okay here
                m_vTargetPosition = pawn.Location;
            }
        }
	}

    function EndState()
    {
		#ifdefDEBUG	if(bShowLog) logX( " end state");	#endif
		SetTimer( 0, false );
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;

		ResetTeamMoveTo();
    }	
    
    //------------------------------------------------------------------
    // FindRandomNavPointToThrowGrenade:
    //	try to find a spot to throw a grenade. Not too far from where he's
    //  standing.
    //------------------------------------------------------------------
    function bool FindRandomNavPointToThrowGrenade()
    {
        local Actor actor;
        local INT i;
        local INT iSize;
        local vector vLocationList[10]; // 10 tries
        local INT iLocationListIndex;
        local INT iDistance;
        
        while ( i < ArrayCount( vLocationList ) ) 
        {
            actor = FindRandomDest( true );
            //m_pawn.dbgVectorAdd( actor.location,  vect(10,10,10), i+10, "nav" );
            if ( !actor.isA( 'r6Ladder') &&                        // not a ladder (i don't want to climb)
                abs( actor.location.Z - Pawn.Location.Z ) < 400 )  // don't want to climb a ladder to reach this point
            {
                if (CanThrowGrenade( actor.location, false, true )) // would it be possible to throw the grenade
                {
                    m_vTargetPosition = actor.location;
                    return true;
                }
                else
                {
                    if ( TooCloseToThrowGrenade( actor.location ) )
                    {
                        vLocationList[iLocationListIndex] = actor.location;
                        iLocationListIndex++;
                    }
                }
            }
            i++;
        }

        // even if it all fails, get the furthes distance from all location that were too close from the target
        if ( iLocationListIndex > 0 )
        {
            i = 0;
            for ( i = 0; i < iLocationListIndex; ++i )
            {
                // logX( "FindRandomNavPointToThrowGrenade second check: " $i$ " distance: " $VSize(vLocationList[i] - Pawn.Location) );
                if ( VSize(vLocationList[i] - Pawn.Location) > iDistance  )
                {
                    // check if can throw without the location
                    if  ( CanThrowGrenade( vLocationList[i], false, false ) )       
                    {
                        // logX( "FindRandomNavPointToThrowGrenade second check: Okay " );
                        iDistance = VSize(vLocationList[i] - Pawn.Location);
                        m_vTargetPosition = vLocationList[i];
                    }
                }
            }
            return true;
        }
        return false;
    }

    function Timer()
    {
        // check if we can throw the grenade from here
        if ( (m_TeamManager.m_iTeamAction & TEAM_Grenade) > 0 )
        {
            if ( CanThrowGrenade(pawn.location, true, false ) )
            {
                SetTimer( 0, false );
                StopMoving();
                GotoState( 'TeamMoveTo', 'Action' );
            }
        }
    }

Begin:
	if( ((m_TeamManager.m_iTeamAction & TEAM_Grenade) > 0)  && m_vLocationOnTarget == vect(0,0,0))
		goto('End');

	StopMoving();
	while(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(TS_Waiting);
		Sleep(0.5);
	}

	SetUpTeamMoveTo();
	
	// apply a delay based on leadership skill before team starts performing order
	Sleep(GetLeadershipReactionTime());

MoveTowardTarget:
	m_TeamManager.SetTeamState(TS_Moving);

	if((m_TeamManager.m_iTeamAction & TEAM_EscortHostage) > 0) 
	{
		if(!ActorReachable(m_ActionTarget)) 
			FindPathToTargetLocation(m_ActionTarget.location, m_ActionTarget);
	}
	else
	{
		if(!PointReachable(m_vTargetPosition)) 
			FindPathToTargetLocation(m_vTargetPosition);
	}

FinalMove:
	#ifdefDEBUG	if(bShowlog) logX(" move directly from current location="$pawn.location$" to m_ActionTarget="$m_ActionTarget$" m_vTargetPosition="$m_vTargetPosition);	#endif	
	if ( (m_TeamManager.m_iTeamAction & TEAM_EscortHostage) > 0 )
	{
		while (DistanceTo(m_ActionTarget) > 100)
		{
			R6PreMoveToward(m_ActionTarget, m_ActionTarget, PACE_Walk);  
			MoveToward(m_ActionTarget);    
		}
	}
	else
	{
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk);  
		MoveTo(m_vTargetPosition);    
	
		if(m_TeamManager.m_iTeamAction != TEAM_None && m_eMoveToResult == eMoveTo_failed)
		{		
			m_TeamManager.MoveTeamToCompleted(false);
			RainbowCannotCompleteOrders();
		}
	}
	
Action:
	#ifdefDEBUG	if(bShowLog) logX(" State TeamMoveTo : Ready to perform action... ");  #endif
    if( (m_TeamManager.m_iTeamAction & TEAM_Grenade) > 0 )
    {
		m_TeamManager.SetTeamState(TS_Grenading);
        if ( CanThrowGrenade(pawn.Location, false, false) )
        {
			#ifdefDEBUG	if(bShowLog) logX( "CanThrowGrenade: fire in the house! m_vTargetPosition="$m_vTargetPosition );	#endif   
			
			// check if someone is in the way before throwing the grenade
			if( !ClearThrowIsAvailable(m_vLocationOnTarget) )
			{
				m_vTargetPosition = pawn.location + 300*normal(m_vLocationOnTarget - pawn.location);

				// move towards target - team should back out of way
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk);  
				MoveTo(m_vTargetPosition); 
			}

            SetTimer( 0, false );       // stop timer, we don't need it anymore
            disable( 'notifyBump' );    // avoid bumping when throwing
            StopMoving();               // make sure we are stopeed
            Sleep( 0.2 );
            
            // set the grenade target...
            SetLocation( m_vLocationOnTarget );
            focus = self;
            target = self;

            // change weapon to grenade... 
            SwitchWeapon(m_iActionUseGadgetGroup);	
            FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 
			SetRotation(pawn.rotation);            
            
			// throw grenade 
			SetGunDirection(target);
			m_pawn.m_bThrowGrenadeWithLeftHand = false;
            m_pawn.m_eGrenadeThrow = GRENADE_Throw;
            m_pawn.m_eRepGrenadeThrow = GRENADE_Throw;
            m_pawn.PlayWeaponAnimation(); 
			FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 
			m_pawn.m_eRepGrenadeThrow = GRENADE_None;
		
            // reset values
            m_vLocationOnTarget = vect(0,0,0); 
            m_iStateProgress=0;
            
            enable( 'notifyBump' );

            // return to original weapon
            SwitchWeapon(1);
            FinishAnim(m_pawn.C_iWeaponRightAnimChannel);
        }
        else
        {
			#ifdefDEBUG	if(bShowLog) logX( "CanThrowGrenade: find a spot to throw the grenade" );	#endif
            SetTimer( 0.3, true );
            m_vTargetPosition = m_vLocationOnTarget;
            m_vTargetPosition.Z += pawn.collisionHeight;

            Sleep( 0.2 );
            goto('begin');
        }
		Sleep(1);
    }
    else if ( ((m_TeamManager.m_iTeamAction & TEAM_DisarmBomb) > 0) || ((m_TeamManager.m_iTeamAction & TEAM_InteractDevice) > 0) )
    {
        if ( m_eMoveToResult == eMoveTo_success  )
        {
			if((m_TeamManager.m_iTeamAction & TEAM_DisarmBomb) > 0)
			{
				if(!R6IOObject(m_ActionTarget).m_bIsActivated)
					RainbowCannotCompleteOrders();	// bomb has already been disarmed, cancel the orders
				m_TeamManager.SetTeamState(TS_DisarmingBomb);
			}
			else
				m_TeamManager.SetTeamState(TS_InteractWithDevice);

			// move as close as possible to the object
			m_vTargetPosition = m_ActionTarget.location - (pawn.collisionRadius + m_ActionTarget.collisionRadius + 10)*vector(m_ActionTarget.rotation);
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk);
			MoveToPosition(m_vTargetPosition, rotator(m_ActionTarget.location - m_vTargetPosition));
			
            Focus = m_ActionTarget;
            FinishRotation();
			#ifdefDEBUG	if(bShowLog) log("PlayInteractWithDeviceAnimation for "$m_pawn @ R6IOObject(m_ActionTarget).GetTimeRequired(m_pawn));	#endif
			// secure weapon
			m_pawn.SetNextPendingAction(PENDING_SecureWeapon);
		    FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 

            m_pawn.m_eDeviceAnim = R6IOObject(m_ActionTarget).m_eAnimToPlay;
            m_pawn.SetNextPendingAction(PENDING_InteractWithDevice);
            
            R6IOObject(m_ActionTarget).PerformSoundAction(SIO_Start);
            m_pawn.m_bInteractingWithDevice = true;
            Sleep(R6IOObject(m_ActionTarget).GetTimeRequired(m_pawn));
            R6IOObject(m_ActionTarget).ToggleDevice(m_pawn);
            R6IOObject(m_ActionTarget).PerformSoundAction(SIO_Complete);
            PlaySoundActionCompleted(R6IOObject(m_ActionTarget).m_eAnimToPlay);
			#ifdefDEBUG	if(bShowLog) log("PlayInteractWithDeviceAnimation() is finished for "$m_pawn);	#endif
			m_pawn.AnimBlendToAlpha(m_pawn.C_iBaseBlendAnimChannel, 0.0, 0.5);
            m_pawn.m_bInteractingWithDevice = false;
            m_pawn.m_ePlayerIsUsingHands = HANDS_None;
            m_pawn.PlayWeaponAnimation();
			Sleep(1.0);
			            
			// equip weapon
			m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
			FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 
        }
        else
        {
			// could not reach the ActionTarget (bomb or device)
			RainbowCannotCompleteOrders();

			// todo FAILED : Play sound not able to reach the bomb	
			#ifdefDEBUG	if(bShowLog) log(pawn$" could not reach interactive device : "$m_ActionTarget);		#endif
		}
    }
    else
	{ 
		if ( (m_TeamManager.m_iTeamAction & TEAM_EscortHostage) > 0 )
		{
			// instruct hostage to follow or stay here		
			if(R6Hostage(m_ActionTarget).m_escortedByRainbow != none)
        		R6Hostage(m_ActionTarget).m_controller.DispatchOrder( R6Hostage(m_ActionTarget).eHostageOrder.HOrder_StayHere );
			else
				R6Hostage(m_ActionTarget).m_controller.DispatchOrder( R6Hostage(m_ActionTarget).eHostageOrder.HOrder_ComeWithMe, m_pawn );
		}
		Sleep(1);
	}
	
	if(m_pawn.m_iId == 0)
		m_TeamManager.ActionCompleted(true);
	m_TeamManager.RestoreTeamOrder();

End:
	if(m_pawn.m_iId == 0)
		GotoState('Patrol');
	else
	{
		m_TeamManager.MoveTeamToCompleted(true);
		nextState = '';
		GotoState('HoldPosition');
	}
}

//==========================================================//
//                  -- state WAITFORTEAM --                 //
// this state is for an AI team leader that is waiting for  //
// his team to regroup (after climbing a ladder)            //
//==========================================================//
state WaitForTeam
{
	function BeginState()	
	{	
		#ifdefDEBUG	if(bShowLog) log(pawn$" has entered state WaitForTeam...");		#endif
		m_bReactToNoise = true;
	}
	
	function EndState()		
	{	
		#ifdefDEBUG	if(bShowLog) log(pawn$" has exited state WaitForTeam...");		#endif
		m_bReactToNoise = false;
	}

Begin:
	if(m_TeamManager.m_iMemberCount == 1)
	{
		#ifdefDEBUG	if(bShowLog) log("  If this is the only member in the team, no need to find a wait spot, continue following planning...");	#endif
		goto('Wait');
	}
	
    //make room for team to arrive at end of ladder
	#ifdefDEBUG	if(bShowLog) log(" WaitForTeam : m_pawn.m_Ladder="$m_pawn.m_Ladder$" m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);	#endif
	if(m_TeamManager.m_PlanActionPoint != none)
	{
		m_vTargetPosition = m_pawn.m_Ladder.Location;
		if(m_TeamManager.m_PlanActionPoint == m_pawn.m_Ladder)
			m_TeamManager.ActionPointReached();

		while(VSize(m_vTargetPosition - pawn.location) < 300)
		{
			if(m_TeamManager.m_PlanActionPoint == none)
				break;
			
			#ifdefDEBUG	if(bShowLog) log(pawn$" now go to :m_pawn.m_door="$m_pawn.m_door$" m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);		#endif
			if(m_pawn.m_door != none && m_pawn.m_door.m_RotatingDoor.m_bIsDoorClosed && NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint))
				break;

			// if planning leads this AI back through the ladder they just took, then find a better wait spot until team finishes climbing...
			if(m_TeamManager.m_PlanActionPoint == m_pawn.m_Ladder || !ActorReachable(m_TeamManager.m_PlanActionPoint) || m_TeamManager.m_eNextAPAction != PACT_None)
			{
				#ifdefDEBUG if(bShowLog) log(self$" State WaitForTeam : "$m_TeamManager.m_PlanActionPoint$" is not reachable so goto FindNearbySpot..."); #endif
				goto('FindNearbySpot');
			}

			R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetTeamPace());
			MoveToward(m_TeamManager.m_PlanActionPoint);			
			m_TeamManager.ActionPointReached();
		}
	}
	else
	{
FindNearbySpot:
		FindNearbyWaitSpot(m_pawn.m_Ladder, m_vTargetPosition);
		if(m_vTargetPosition != vect(0,0,0))
		{
			#ifdefDEBUG	if(bShowLog) log(pawn$" obtained a Wait Spot from FindNearbyWaitSpot() : m_vTargetPosition="$m_vTargetPosition);	#endif
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetTeamPace());
			MoveTo(m_vTargetPosition);
		}
	}

	#ifdefDEBUG if(bShowLog) log(" wait for team to catch up here....");	#endif

Wait:
    Sleep(1.0);
	if(m_TeamManager.TeamHasFinishedClimbingLadder())
	{
		m_pawn.m_Ladder = none;

		// check if team is supposed to be holding position
		if(m_TeamManager.m_bAllTeamsHold)
			m_TeamManager.AITeamHoldPosition();
		else
			GotoState('Patrol');   
	}
	else
		Goto('Wait');
}

//////////////////////////////////////////////////////////////////////////////////////////
//                          RAINBOW AI TEAM LEADER                                      //
//////////////////////////////////////////////////////////////////////////////////////////
function R6Pawn.eMovementPace GetTeamPace()
{
    local R6Pawn.eMovementPace      ePace;

    // find out what pace this team should be moving at...
	// if any rainbow members/escorted hostages are wounded, walk instead of run
	switch(m_TeamManager.m_eMovementSpeed)
	{
		case SPEED_Blitz :	
			if(m_TeamManager.AtLeastOneMemberIsWounded())
				ePace = PACE_Walk;
			else
				ePace = PACE_Run;
			break;

		case SPEED_Normal :
			ePace = PACE_Walk;
			break;

		case SPEED_Cautious :
			ePace = PACE_CrouchWalk;
			break;

		default:
			ePace = PACE_Walk;
	}

    m_pawn.m_eMovementPace =  ePace;           
    return(ePace);
}

function bool NextActionPointIsThroughDoor(actor nextActionPoint)
{
	local vector	vDir;
	local FLOAT		fResult;
	
	if(nextActionPoint == none)
		return false;

	if(m_pawn.m_Door == none)
		return false;

	if(m_pawn.m_Door.m_RotatingDoor.m_bTreatDoorAsWindow)
		return false;

	if(VSize(nextActionPoint.location - m_pawn.m_Door.location) > VSize(nextActionPoint.location - m_pawn.m_Door.m_CorrespondingDoor.location) )
		return true;

	return false;
}

function SetGrenadeParameters(bool bPeeking, optional bool bThrowOverhand)
{
	if(bPeeking)
	{
		// check which side of the door we are on
		if(OnRightSideOfDoor(m_ActionTarget))
		{
			m_pawn.m_bThrowGrenadeWithLeftHand = true;
			m_pawn.m_eGrenadeThrow = GRENADE_PeekLeft;
			m_pawn.m_eRepGrenadeThrow = GRENADE_PeekLeft;
		}
		else
		{
			m_pawn.m_bThrowGrenadeWithLeftHand = false;
			m_pawn.m_eGrenadeThrow = GRENADE_PeekRight; 
			m_pawn.m_eRepGrenadeThrow = GRENADE_PeekRight;
		}
	}
	else if(bThrowOverhand)
	{
		m_pawn.m_bThrowGrenadeWithLeftHand = false;
		m_pawn.m_eGrenadeThrow = GRENADE_Throw; 
		m_pawn.m_eRepGrenadeThrow = GRENADE_Throw;
	}
	else
	{
		m_pawn.m_bThrowGrenadeWithLeftHand = false;
		m_pawn.m_eGrenadeThrow = GRENADE_Roll; 
		m_pawn.m_eRepGrenadeThrow = GRENADE_Roll;
	}
}

function ConfirmLadderActionPointWasReached(R6Ladder ladder)
{
	if(m_pawn.m_ePawnType == PAWN_Rainbow && m_pawn.m_iId == 0)
	{
		if(ladder == m_TeamManager.m_PlanActionPoint)
		{
			#ifdefDEBUG	if(bShowLog) log("  Rainbow Team Leader reached the end of the ladder : m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);		#endif
			m_TeamManager.ActionPointReached();	
		}
	}
}

function bool TargetIsLadderToClimb(R6Ladder target)
{
	if(target == none || m_pawn.m_Ladder == none)
		return false;

	if(m_pawn.m_Ladder == target)
		return false;
	
	if(target.myLadder != m_pawn.m_Ladder.myLadder)
		return false;

	return true;
}

//==========================================================//
//                  -- state PATROL --                      //
// This is the main state for an AI team leader.            //
// TODO:    need to add bone rotation for AI team leader    //
//          on stairs, to look up/down...                   //
// todo : AI team lead should automatically secure a		//
//			surrendered terrorist							//
//	      AI team lead should automatically interact with   //
//          objects that are mission objectives				//
//		  AI led team should reorganize for Open Frag &     //
//			clear if the lead is not the one with the frag	//	  
//==========================================================//
state Patrol
{
    function BeginState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$"... entered state Patrol...");	#endif
		m_pawn.m_bAvoidFacingWalls = false; 
		m_iWaitCounter = 0;
		m_pawn.m_bCanProne = false;
		m_bReactToNoise = true;
		m_bStateFlag = false;
    }

    function EndState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$"... exited state Patrol...");	#endif
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;	
		SetTimer(0, false);
		m_pawn.m_bThrowGrenadeWithLeftHand = false;
		m_bIgnoreBackupBump = false;
		m_pawn.m_bCanProne = m_pawn.default.m_bCanProne;
		m_bReactToNoise = false;

		if(m_bStateFlag)
			m_TeamManager.ActionNodeCompleted();
    }

	function bool CornerMovement()
	{
		local vector PathA, PathB;

		PathA = normal(moveTarget.location - pawn.location);
		PathB = normal(m_NextMoveTarget.location - moveTarget.location);

		// strafe around corners when angle is >= 45 degrees
		if(PathA dot PathB < 0.707)  
			return true;

		return false;
	}

	function DispatchInteractions()
	{
		local actor actionTarget;

		// check surroundings for possible actors to interact with...
		actionTarget = CheckForPossibleInteractions();

		// dispatch action
		if(actionTarget != none)
		{
			#ifdefDEBUG	if(bShowLog) logX(" a nearby object was found that corresponds to a mission objective - DO SOMETHING! actionTarget="$actionTarget);	#endif
			// check if next waypoint is closer to actionTarget, and that the actionTarget is reachable from the next moveTarget
			if( (moveTarget != none) 
				&& (VSize(moveTarget.location - actionTarget.location) < VSize(pawn.location - actionTarget.location))
				&& ActorReachableFromLocation(actionTarget, moveTarget.location) )
				return;
			
			if(actionTarget.IsA('R6IOBomb'))
			{			
				#ifdefDEBUG	if(bShowLog) logX(" Reorganize team and go disarm bomb ");	#endif
				m_TeamManager.ReorganizeTeamToInteractWithDevice(TEAM_DisarmBomb, actionTarget);
			}	
			else if(actionTarget.IsA('R6IODevice'))
			{
				#ifdefDEBUG	if(bShowLog) logX(" Reorganize team and go interact with device ");		#endif
				m_TeamManager.ReorganizeTeamToInteractWithDevice(TEAM_InteractDevice, actionTarget);
			}
			else if(actionTarget.IsA('R6Terrorist'))
			{      
				#ifdefDEBUG	if(bShowLog) logX(" Arrest surrendered terrorist ");	#endif
				m_ActionTarget = actionTarget;
				GotoState('TeamSecureTerrorist');	
			}					
			else if(actionTarget.IsA('R6Hostage'))
			{
                //if (R6Hostage(actionTarget).IsAlive()) 
                // MPF1
                if (R6Hostage(actionTarget).IsAlive() && (!R6Hostage(actionTarget).m_bCivilian))//MissionPack1
                {
			        #ifdefDEBUG	if(bShowLog) logX(" Rescue Hostage ");	#endif
			        if (!m_TeamManager.m_bLeaderIsAPlayer)
                    {
                        m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, RTV_EscortingHostage);
                    }
                    R6Hostage(actionTarget).m_controller.DispatchOrder( R6Hostage(actionTarget).eHostageOrder.HOrder_ComeWithMe, m_pawn );
                }
				m_TeamManager.m_HostageToRescue = none;
			}
		}
	}

    function Timer()
    {		
		m_iWaitCounter++;
		// check for next waypoint...
		if((moveTarget != none) && (m_NextMoveTarget != none) && !ActionIsGrenade(m_TeamManager.m_ePlanAction))
		{
			if(enemy == none && DistanceTo(moveTarget) < 200)
			{
				if(CornerMovement() && m_NextMoveTarget != none)
				{	
					focus = m_NextMoveTarget;
					focalPoint = m_NextMoveTarget.location;
				}
			}
		}

        if(m_bTeamMateHasBeenKilled)  // <-- this boolean is set by teamAI, as a means of informing leader 
        {
			#ifdefDEBUG	if(bShowLog) log(" m_bTeamMateHasBeenKilled==true, member of the team has been killed...");	#endif
            m_bTeamMateHasBeenKilled = false;
            pawn.acceleration = vect(0,0,0);    
            nextState = 'Patrol';
            GotoState('HoldPosition');
			return;
        }

		// interact with nearby objects, check every 1 second
		if((m_iWaitCounter % 10) == 0)
			DispatchInteractions();
    }
  
    function bool ConfirmActionPointReached()
    {
        if(VSize(moveTarget.location - pawn.location) < 100)
            return true;

        return false;
    } 
 
	function bool IsCloseEnoughToInteractWith(actor actionTarget)
	{
		if(actionTarget == none)
			return false;

		if((DistanceTo(actionTarget) < 500) && (abs(pawn.location.z - actionTarget.location.z) < 100))
			return true;

		return false;
	}

	function actor CheckForPossibleInteractions()
	{
		local INT i;
		local R6InteractiveObject aIntActor;
		local R6Terrorist   terro;

		// check for nearby interactive objects
		for(i=0; i<m_TeamManager.m_InteractiveObjectList.length; i++)
		{
			aIntActor = m_TeamManager.m_InteractiveObjectList[i];
			if(aIntActor != none)
			{
				// check if this actor is close (within 5m)
				if(R6IOObject(aIntActor).m_bIsActivated && IsCloseEnoughToInteractWith(aIntActor))  // && ActorReachable(aIntActor) )
					return aIntActor;						
			}
		}

		if(m_TeamManager.m_HostageToRescue != none)
		{
			if(IsCloseEnoughToInteractWith(m_TeamManager.m_HostageToRescue))
				return m_TeamManager.m_HostageToRescue;
		}

		// check for possible terrorist that needs to be secured...		 
		if(m_TeamManager.m_SurrenderedTerrorist != none)
		{
			terro = R6Terrorist(m_TeamManager.m_SurrenderedTerrorist);
			if(IsCloseEnoughToInteractWith(terro) && !terro.m_bIsUnderArrest)	//ActorReachable(terro)
				return terro;
		}
		return none;
	}

	function bool ActionIsGrenade(EPlanAction eAPAction)
	{
		if(eAPAction == PACT_Frag || eAPAction == PACT_Flash || eAPAction == PACT_Gas || eAPAction == PACT_Smoke)
			return true;
		return false;
	}

	function actor GetFocus()
	{
		if(enemy == none)
			return moveTarget;
		
		return enemy;
	}

Begin:
	// set timer to check on teammates & status
    SetTimer(0.1, true);     

	moveTarget = m_TeamManager.m_PlanActionPoint; 
    if(moveTarget != none && ConfirmActionPointReached())
		m_TeamManager.ActionPointReached();
	
	if(m_TeamManager.m_bPendingSnipeUntilGoCode)
	{
		m_TeamManager.ReOrganizeTeamForSniping();
		m_TeamManager.SnipeUntilGoCode();
	}

	if(m_bReorganizationPending)
		ReorganizeTeamAsNeeded();

	if(pawn.m_bIsProne)
	{
		pawn.m_bWantsToProne = false;
		Sleep(1.0);
	}
	
	if(!m_pawn.IsStationary() && SniperChangeToSecondaryWeapon())
		Sleep(0.5);		

PickActionPoint: 
	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
	
	if(m_TeamManager.m_iMemberCount > 1)
	{
		// leader should wait for team to catch up if they fall behind...
		while(DistanceTo(m_TeamManager.m_Team[m_TeamManager.m_iMemberCount-1]) > 800)
			Sleep(0.5);
	}
	
	#ifdefDEBUG	if(bShowLog) log("  PickActionPoint : m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);	#endif
    moveTarget = m_TeamManager.m_PlanActionPoint; 
	if((moveTarget != none) || (m_TeamManager.m_ePlanAction != PACT_None))
	{
		DispatchInteractions();
		m_iWaitCounter = 0;
		if(m_TeamManager.m_ePlanAction != PACT_SnipeGoCode)
		{
			if(SniperChangeToSecondaryWeapon())
				Sleep(0.5);	
		}
	}
	else
	{
		if(m_iWaitCounter > 30)
		{
			SniperChangeToPrimaryWeapon();
			if(!pawn.bIsCrouched && m_TeamManager.m_eGoCode == GOCODE_None)
			{
				pawn.bWantsToCrouch = true;
				sleep(0.5);
			}
		}
	}

	// check ammo if not in the process of changing weapons
    if(NeedToReload())
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" (patrol) has no ammo left, must reload...clips="$Pawn.EngineWeapon.GetNbOfClips());		#endif
		if(!pawn.bIsCrouched)
			pawn.bWantsToCrouch = true;		
		RainbowReloadWeapon();
		// todo : check one of the two weapons may be completely out of ammo
		StopMoving();
		while(m_pawn.m_bReloadingWeapon)
			Sleep(0.2);
	}
	
	if(moveTarget == none)
	{		
		// this is needed in case this rainbow got interrupted while sniping until gocode and got sent back to patrol state...
		if(m_TeamManager.m_ePlanAction == PACT_SnipeGoCode)
			m_TeamManager.SnipeUntilGoCode();
		//if(bShowLog) log(self$" moveTarget was none so skip ahead to PerformPlanningAction...");		
		Sleep(0.1);
		Goto('FormationAroundDoor');
	}

	
	if(m_TeamManager.m_eNextAPAction == PACT_None)
		m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();
	else 
	{
		m_NextMoveTarget = none;		

		// check if next action point has a breach door order, may need to reorganize team...
		if(m_TeamManager.m_eNextAPAction == PACT_Breach)
			m_TeamManager.ReOrganizeTeamForBreachDoor(); // reorganize the team to put the member with a breaching charge in front
		else if(m_TeamManager.m_eNextAPAction == PACT_SnipeGoCode)
			m_TeamManager.ReOrganizeTeamForSniping();
		else if(ActionIsGrenade(m_TeamManager.m_eNextAPAction))
			m_TeamManager.ReOrganizeTeamForGrenade(m_TeamManager.m_eNextAPAction);
		// log if no one is equipped with the desired type of grenade // cannot comply skip to next order
	}		
	#ifdefDEBUG	if(bShowLog) logX(" PATROL : PickAction  moveTarget="$moveTarget$" m_NextMoveTarget="$m_NextMoveTarget);		#endif

MoveToActionPoint: 
	#ifdefDEBUG	if(bShowLog) log(pawn$" PATROL : MoveToActionPoint="$m_TeamManager.m_PlanActionPoint);	#endif
    moveTarget = m_TeamManager.m_PlanActionPoint; 	
	if(moveTarget == m_pawn.m_door)
	{
		m_TeamManager.ActionPointReached();
		goto('DoorsAndLadders');
	}

    m_TeamManager.SetTeamState(TS_Moving);

	// check if we are in front of a closed door, if so, skip ahead...
	if(m_pawn.m_Door != none && m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed && NextActionPointIsThroughDoor(moveTarget))
		goto('DoorsAndLadders');

	// check if we are at a ladder we need to climb, if so, skip ahead...
	if(TargetIsLadderToClimb(R6Ladder(moveTarget)))
		goto('DoorsAndLadders');

	// if cannot reach the moveTarget directly, use pathfinding
	if(!CanWalkTo(moveTarget.location) && !ActorReachable(moveTarget)) 
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" (location="$pawn.location$") did not reach "$moveTarget$", find a path to it instead... ");		#endif
		goto('BlockedFindPath');
	}

    // move to action point...
	R6PreMoveToward(moveTarget, GetFocus(), GetTeamPace());		
	MoveToward(moveTarget, GetFocus());  

    // inform TeamAI that Action Point has been reached...
    if(ConfirmActionPointReached())
    {
		if(moveTarget.IsA('R6Door'))
			ForceCurrentDoor(R6Door(moveTarget));
		#ifdefDEBUG	if(bShowLog) log(pawn$" action point "$moveTarget$" has been reached...");	#endif        
		m_TeamManager.ActionPointReached();
		goto('DoorsAndLadders');
    }
	else 
	{		
		#ifdefDEBUG	if(bShowLog) log(pawn$" did not reach moveTarget="$moveTarget$" actionpoint="$m_TeamManager.m_PlanActionPoint$", try again.... ");	#endif
		goto('MoveToActionPoint');
	}

BlockedFindPath:
	#ifdefDEBUG	if(bShowLog) log(self$" BlockedFindPath : findPathToward m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);	#endif
	moveTarget = FindPathToward(m_TeamManager.m_PlanActionPoint, true);     
	if(moveTarget != none)
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" in Patrol state (BlockedFindPath) : move to the movetarget=["$moveTarget$"] ...m_pawn.m_Door="$m_pawn.m_Door);	#endif
		
		R6PreMoveToward(moveTarget, GetFocus(), GetTeamPace());
		MoveToward(moveTarget, GetFocus());

		if(ConfirmActionPointReached() && moveTarget.IsA('R6Door'))
			ForceCurrentDoor(R6Door(moveTarget));
		Goto('DoorsAndLadders');  
	}
	else
	{
		#ifdefDEBUG	if(bShowLog) log(" this is bad... cannot find a path to the next actionpoint... try to move directly...");	#endif
		R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetTeamPace());
		MoveToward(m_TeamManager.m_PlanActionPoint);
		Sleep(1.0);
	}

DoorsAndLadders:
	m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();
	//logX(" *********************************** moveTarget="$moveTarget$" m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);
	#ifdefDEBUG	if(bShowLog) logX(" *********** DOORSANDLADDERS : m_eGoCode="$m_TeamManager.m_eGoCode$" m_NextMoveTarget="$m_NextMoveTarget);	#endif
	#ifdefDEBUG	if(bShowLog) logX("  LABEL : DoorsAndLadders : m_ePlanAction="$m_TeamManager.m_ePlanAction$" m_eNextAPAction="$m_TeamManager.m_eNextAPAction$" m_pawn.m_Door="$m_pawn.m_Door);	#endif
	// todo : if(NeedToOpenDoor(moveTarget)) + move contents of this if into the function... (to be called from anywhere...)
    if((m_TeamManager.m_ePlanAction == PACT_None) && (m_pawn.m_Door != none) 
		&& (NextActionPointIsThroughDoor(m_NextMoveTarget) || NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint))
		&& m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed)
    {
		// prepare for a room entry...
		if(m_TeamManager.m_PlanActionPoint == m_pawn.m_Door || m_NextMoveTarget == m_pawn.m_Door)
		{
			R6PreMoveToward(m_pawn.m_Door, m_pawn.m_Door, GetTeamPace());		
			MoveToward(m_pawn.m_Door);  
			m_TeamManager.ActionPointReached();
		}
		#ifdefDEBUG	if(bShowLog) log(pawn$" we are in front of a door now... ");	#endif
        if(!m_TeamManager.m_bEntryInProgress || (m_TeamManager.m_Door != m_pawn.m_Door))
			m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door); 
		SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
		GotoStateLeadRoomEntry();
    }

	m_TargetLadder = R6Ladder(moveTarget);
	if(TargetIsLadderToClimb(m_TargetLadder))
    {
		moveTarget = m_pawn.m_Ladder;  
        nextState = 'WaitForTeam';
        //inform TEAM AI that player has started climbing a ladder...
        m_TeamManager.TeamLeaderIsClimbingLadder();
        GotoState('ApproachLadder');
	}
      
FormationAroundDoor:
	if(m_TeamManager.m_ePlanAction == PACT_None && m_TeamManager.m_eGoCode == GOCODE_None)
	{
		#ifdefDEBUG	if(bShowLog) log(self$" there is no Plan Action and No Gocode... so continue ahead...");	#endif
		goto('PerformPlanningAction');
	}

	// if we are in front of a door, open the door before throwing the grenade
	if(!m_TeamManager.m_bEntryInProgress && (m_pawn.m_Door != none) && m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed)
	{			
		if(m_pawn.m_Door.m_RotatingDoor.m_bIsDoorLocked)
			GotoLockPickState(m_pawn.m_Door.m_RotatingDoor);

		Sleep(1.0);

		// team should only form around door if the lead is intending to do a room entry...
		m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();
		#ifdefDEBUG if(bShowLog) log(self$" inform teammanager that we want to enter the room...m_NextMoveTarget="$m_NextMoveTarget);	#endif
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);

		#ifdefDEBUG	if(bShowLog) log(self$" (FORMATION) there is some kind of action at this door...m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);	#endif		
		if(PreEntryRoomIsAcceptablyLarge())
		{
			#ifdefDEBUG if(bShowLog) log(" ***** Pre Entry Room Is Large enough, so move to the side of door...RoomLayout="$m_TeamManager.m_Door.m_CorrespondingDoor.m_eRoomLayout);	#endif
			// pick appropriate position before opening door			
			m_vTargetPosition = getEntryPosition(false);    
			if(m_vTargetPosition != vect(0,0,0))
			{
				R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.location, GetTeamPace()); 
				MoveTo(m_vTargetPosition);   
				MoveToPosition(m_vTargetPosition, rotator(m_pawn.m_Door.m_CorrespondingDoor.location - m_vTargetPosition));
			}
		}

		// focus should be the door knob, not the pivot/hinges
		StopMoving();
		SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
		FinishRotation();
	}

PerformPlanningAction:
	if(ActionIsGrenade(m_TeamManager.m_ePlanAction))
    {
        // set the grenade target...        
#ifdefDEBUG
        if(bShowLog) log("==============================GOCODE="$m_TeamManager.m_eGoCode$" ===============================================");
        if(bShowLog) log(" pawn.rotation="$pawn.rotation$",  focus ="$focus$" m_iActionUseGadgetGroup="$m_iActionUseGadgetGroup);     
        if(bShowLog) log(" grenade direction (rotator) : "$rotator(m_TeamManager.m_vPlanActionLocation));
#endif
		if(m_TeamManager.m_bSkipAction)
		{
			#ifdefDEBUG	if(bShowLog) log(" CANNOT COMPLY; not equipped with desired grenade ");		#endif
			m_TeamManager.ActionNodeCompleted();

			if((m_pawn.m_Door != none) && (m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed) 
				&& NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint))
			{
				#ifdefDEBUG	if(bShowLog) log(" could not throw grenade but MUST GET IN ROOM!!");	#endif
				m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door); 
				SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
				GotoStateLeadRoomEntry();
			}	
			
			goto('PickActionPoint');
		}	  
		
		// if this is the first action point then the team did not have an opportunity to prepare for this action in advance,
		// prepare now.
		if(m_iActionUseGadgetGroup == 0) 
			m_TeamManager.ReOrganizeTeamForGrenade(m_TeamManager.m_ePlanAction);

        // change weapon to grenade... 
		if(m_pawn.m_iCurrentWeapon != m_iActionUseGadgetGroup)
		{			
			SwitchWeapon(m_iActionUseGadgetGroup);
			FinishAnim(m_pawn.C_iWeaponRightAnimChannel);
		}

		m_bIgnoreBackupBump=true;

		// if we are in front of a door, open the door before throwing the grenade
		#ifdefDEBUG if(bShowLog) log("  state PATROL : Before opening door... m_pawn.m_Door="$m_pawn.m_Door$" m_ActionTarget="$m_ActionTarget);	#endif	
		m_ActionTarget = m_pawn.m_Door;
		if((m_pawn.m_Door != none) && (m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))
		{
			m_RotatingDoor = m_pawn.m_Door.m_RotatingDoor;
			
			// focus should be the door knob, not the pivot/hinges
			SetFocusToDoorKnob(m_RotatingDoor);
			FinishRotation();

			// open door			
			m_pawn.PlayDoorAnim(m_RotatingDoor);
			Sleep(0.5);
			m_pawn.ServerPerformDoorAction(m_RotatingDoor, m_RotatingDoor.eDoorCircumstantialAction.CA_Open);
    
			// wait for Door to open completely
			while(m_RotatingDoor.m_bIsDoorClosed)
			{
				if(!m_RotatingDoor.m_bInProcessOfOpening)
				{
					Sleep(1.0);
					goto('PerformPlanningAction');
				}
				else
					Sleep(0.1);
			}
		}
			
		if(m_ActionTarget != none)
		{			
			// Rainbow may have been bumped back by door, so reposition
			if(!PreEntryRoomIsAcceptablyLarge())
			{
				R6PreMoveToward(m_ActionTarget, m_pawn.m_Door.m_CorrespondingDoor, GetTeamPace());
				MoveToward(m_ActionTarget, m_pawn.m_Door.m_CorrespondingDoor);
				StopMoving();
			}

			if(!CanThrowGrenadeIntoRoom(m_pawn.m_Door.m_CorrespondingDoor, m_TeamManager.m_vPlanActionLocation))
			{
				#ifdefDEBUG	if(bShowLog) log("*** there isn't enough clear space inside room, so skip grenade action...");	#endif
				m_TeamManager.ActionNodeCompleted();
				goto('PostThrowGrenade');
			}
		}
		else
		{
			// check if someone is in the way before throwing the grenade
			if( !ClearThrowIsAvailable(m_TeamManager.m_vPlanActionLocation) )
			{
				m_vTargetPosition = pawn.location + 300*normal(m_TeamManager.m_vPlanActionLocation - pawn.location);
				
				// move towards target - team should back out of way
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk);  
				MoveTo(m_vTargetPosition); 
				StopMoving();
				Sleep(1.0);
			}
		}

		// set the target for the grenade
		#ifdefDEBUG if(bShowLog) log(" set target for the grenade ="$m_TeamManager.m_vPlanActionLocation);	#endif
        if(m_TeamManager.m_vPlanActionLocation != vect(0,0,0))
        {
			m_vLocationOnTarget = m_TeamManager.m_vPlanActionLocation;
			SetLocation(m_vLocationOnTarget);
		}
        else
			SetLocation(pawn.location + 100*vector(pawn.rotation));
        
		//m_pawn.dbgVectorAdd( location,  vect(10,10,10), 0, "grenade" );
		target = self;
        focus = self;  	
		FinishRotation();

		SetRotation(pawn.rotation);
		SetGunDirection(target);
		
		// check which side of the door we are on and throw grenade
		#ifdefDEBUG	if(bShowLog) log(" **** check which side of the door we are on.... m_pawn.m_Door="$m_pawn.m_Door$" m_ActionTarget="$m_ActionTarget);	#endif
		SetGrenadeParameters(m_ActionTarget!=none && PreEntryRoomIsAcceptablyLarge(), true);
        
		m_bStateFlag = true;
		m_pawn.PlayWeaponAnimation(); 
        FinishAnim( m_pawn.C_iWeaponRightAnimChannel );         
		m_pawn.m_eRepGrenadeThrow = GRENADE_None;
        ResetGadgetGroup();
		m_TeamManager.ActionNodeCompleted();	// inform Team AI that action was completed...
		m_bStateFlag = false;

		SetGunDirection(none);

PostThrowGrenade:
		m_bIgnoreBackupBump=false;
		
        // return to original weapon
        SwitchWeapon(1);
        FinishAnim(m_pawn.C_iWeaponRightAnimChannel); 

		#ifdefDEBUG	if(bShowLog) log(" m_TeamManager.m_ePlanAction="$m_TeamManager.m_ePlanAction$" m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);	 #endif
        // wait for grenade to explode...        
        Sleep(m_pawn.EngineWeapon.GetExplosionDelay());        

		#ifdefDEBUG if(bShowLog) log(self$" m_pawn.m_Door="$m_pawn.m_Door$" check m_NextMoveTarget="$m_NextMoveTarget$" m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);	#endif
		if( m_pawn.m_Door != none
			&& ( NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint)
				|| (m_TeamManager.m_PlanActionPoint == m_pawn.m_Door && NextActionPointIsThroughDoor(m_TeamManager.PreviewNextActionPoint())) ) )
		{
			#ifdefDEBUG	if(bShowLog) log(" after throwing grenade, need to do room entry ");	#endif
			m_iStateProgress = 3;			
			GotoState('LeadRoomEntry', 'EnterRoomBegin');
		}
    }
    else 
    {
		if(moveTarget == none)
		{
			//if(bShowLog) log(" movetarget == none, hold position until furthur instructions...m_TeamManager.m_eGoCode="$m_TeamManager.m_eGoCode);
			if(m_TeamManager.m_eGoCode == GOCODE_None)
				m_TeamManager.SetTeamState(TS_Holding);
			else
				m_TeamManager.SetTeamState(TS_Waiting);
			StopMoving();
			Sleep(1.0);        
		}
    }	

	if(m_TeamManager.m_bEntryInProgress && m_TeamManager.m_eGoCode == GOCODE_None && m_TeamManager.m_PlanActionPoint != none)
		m_TeamManager.RainbowHasLeftDoor(m_pawn);

	if(m_TeamManager.m_eNextAPAction == PACT_None)
		m_TeamManager.RestoreTeamOrder();

    goto('PickActionPoint');
}

function DetonateBreach()
{
	m_iStateProgress = 3;
	GotoState('DetonateBreachingCharge');
}

//==========================================================//
//             -- state PLACEBREACHINGCHARGE --             //
//==========================================================//
state PlaceBreachingCharge
{
    function BeginState()    
	{	
		#ifdefDEBUG	if(bShowLog) log(pawn$" entered state PlaceBreachingCharge...m_TeamManager.m_BreachingDoor="$m_TeamManager.m_BreachingDoor);  	#endif
		m_pawn.m_bAvoidFacingWalls = false;	
		focus = m_TeamManager.m_BreachingDoor;
    }
    
    function EndState()
    {
		#ifdefDEBUG if(bShowLog) log(pawn$" exited state PlaceBreachingCharge...m_iStateProgress="$m_iStateProgress);		#endif
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
		m_bIgnoreBackupBump = false;
		
		// make sure the action was actually completed and not just interrupted, like by a bumpback
		if(m_iStateProgress == 3)
		{
			m_TeamManager.ActionNodeCompleted();
			m_iStateProgress = 0;
		}
    }

	function R6Door GetDoorPathNode()
	{
		local FLOAT fDistA, fDistB;

		fDistA = VSize(m_TeamManager.m_BreachingDoor.m_DoorActorA.location - pawn.location);
		fDistB = VSize(m_TeamManager.m_BreachingDoor.m_DoorActorB.location - pawn.location);

		if(fDistA < fDistB)
			return m_TeamManager.m_BreachingDoor.m_DoorActorA;
		else
			return m_TeamManager.m_BreachingDoor.m_DoorActorB;
	}

	function DetonateBreach()
	{
		if(m_iStateProgress < 1)
			return;

		global.DetonateBreach();
	}

Begin:
	if(m_TeamManager.m_BreachingDoor == none)
		goto('WaitToDetonate');
	m_ActionTarget = GetDoorPathNode();
	
	switch(m_iStateProgress)
	{
		case 0:		goto('GetIntoPosition');	break;
		case 1:		goto('MoveAwayFromDoor');	break;
		default:	goto('WaitToDetonate');
	}

GetIntoPosition:
	// move to door
	m_TeamManager.SetTeamState(TS_Moving);
	#ifdefDEBUG	if(bShowLog) log(pawn$" get into position in front of door...m_ActionTarget="$m_ActionTarget$" m_TeamManager.m_BreachingDoor="$m_TeamManager.m_BreachingDoor);	#endif
    R6PreMoveToward(m_ActionTarget, m_TeamManager.m_BreachingDoor, GetTeamPace());		
    MoveToward(m_ActionTarget, m_TeamManager.m_BreachingDoor);  
	ForceCurrentDoor(R6Door(m_ActionTarget));

	StopMoving();
	focus = m_pawn.m_Door.m_CorrespondingDoor; 
	Sleep(0.5);	
	
	//make sure we are close enough
	if(DistanceTo(m_ActionTarget) > 30)
	{
		m_vTargetPosition = pawn.location - 60*vector(pawn.rotation);
		R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_BreachingDoor.location, PACE_Walk);
		MoveTo(m_vTargetPosition, m_TeamManager.m_BreachingDoor);
		Sleep(0.5);
		Goto('GetIntoPosition');
	}

	m_bIgnoreBackupBump = true;
	m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
	
	// switch to breaching charge gadget	
	m_TeamManager.SetTeamState(TS_SettingBreach);
    SwitchWeapon(m_iActionUseGadgetGroup);
	Sleep(0.2);
    FinishAnim(m_pawn.C_iWeaponRightAnimChannel); 
    
	// place breaching charge
    m_pawn.PlayBreachDoorAnimation(); 
	FinishAnim(m_pawn.C_iBaseBlendAnimChannel);
	Pawn.EngineWeapon.NPCPlaceCharge(m_TeamManager.m_BreachingDoor);
	m_iStateProgress = 1;

	#ifdefDEBUG	if(bShowLog) log(pawn$" finished placing breaching charge... ");  #endif
    PlaySoundCurrentAction(RTV_ExplosivesReady);

    Sleep(2.5);

	#ifdefDEBUG	if(bShowLog) log(" charge has been placed, detonate when ready... m_TeamManager.m_eGoCode="$m_TeamManager.m_eGoCode);	#endif
	m_bIgnoreBackupBump = false;

MoveAwayFromDoor:
	// pick appropriate position before opening door			
	m_vTargetPosition = getEntryPosition(false);   
	if(m_vTargetPosition != m_pawn.m_Door.location)
	{
		if(m_pawn.bIsCrouched)
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.location, PACE_CrouchWalk);
		else
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.location, PACE_Walk); 
		MoveTo(m_vTargetPosition);   
		MoveToPosition(m_vTargetPosition, rotator(m_pawn.m_Door.m_CorrespondingDoor.location - m_vTargetPosition));
	}
	else
	{
		m_vTargetPosition = m_pawn.m_Door.location - 100*vector(m_pawn.m_Door.rotation);
		if(m_pawn.bIsCrouched)
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.location, PACE_CrouchWalk); 
		else
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.location, PACE_Walk); 
		MoveTo(m_vTargetPosition); 
	}	
	StopMoving();

	// focus should be the door knob, not the pivot/hinges
	SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
	FinishRotation();

	// if there is no gocode associated to this action, detonate immediately
	if(m_TeamManager.m_eGoCode == GOCODE_None)
	{
		Sleep(1.0);	
		DetonateBreach();
	}

	m_TeamManager.PlayWaitingGoCode(m_TeamManager.m_eGoCode);

	m_iStateProgress = 2;

WaitToDetonate:		
	m_TeamManager.SetTeamState(TS_Waiting);
	Sleep(0.2);	
	goto('WaitToDetonate');
}

//==========================================================//
//          -- state DETONATEBREACHINGCHARGE --             //
//==========================================================//
state DetonateBreachingCharge
{
#ifdefDEBUG
    function BeginState()    {	if(bShowLog) log(pawn$" entered state DetonateBreachingCharge...");	}
    function EndState()      {	if(bShowLog) log(pawn$" exited state DetonateBreachingCharge...");	}
#endif

Begin:	
	#ifdefDEBUG if(bShowLog) logX(" DetonateBreachingCharge : m_TeamManager.m_BreachingDoor="$m_TeamManager.m_BreachingDoor$" broken="$m_TeamManager.m_BreachingDoor.m_bBroken);	#endif
	ResetStateProgress();
	if(m_TeamManager.m_BreachingDoor == none || !m_TeamManager.m_BreachingDoor.ShouldBeBreached())
		goto('End');

	while(m_TeamManager.m_bTeamIsHoldingPosition)
		Sleep(0.5);
	
	Pawn.EngineWeapon.NPCDetonateCharge();
	#ifdefDEBUG	if(bShowLog) log(" charge has been detonated...");	#endif

End:
	// switch back to primary weapon
    SwitchWeapon(1);
	Sleep(0.5);
    FinishAnim(m_pawn.C_iWeaponRightAnimChannel); 

	if(m_TeamManager.m_PlanActionPoint == m_ActionTarget)
		m_TeamManager.ActionPointReached();

	m_TeamManager.m_BreachingDoor = none;
	ResetGadgetGroup();

	if(m_TeamManager.m_bTeamIsHoldingPosition)
		GotoState('HoldPosition');

	// check if a room entry is next before returning to the patrol state
	moveTarget = m_TeamManager.m_PlanActionPoint;
	if(NextActionPointIsThroughDoor(moveTarget))
	{
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_door);
		GotoStateLeadRoomEntry();
	}
	else
	{
		m_TeamManager.EndRoomEntry();
		GotoState('Patrol'); 
	}
}

function GotoStateLeadRoomEntry()
{	
	ResetStateProgress();
	GotoState('LeadRoomEntry');
}

function ForceCurrentDoor(R6Door aDoor)
{
	if(aDoor == none)
		return;

	m_pawn.m_Door = aDoor;
	m_pawn.m_PotentialActionActor = aDoor.m_RotatingDoor;
}

//==========================================================//
//              -- state LEADROOMENTRY --                   //
// this state is for an AI team leader (or AI team member   //
// that is temporarily lead) that is leading a room entry	//
//==========================================================//
state LeadRoomEntry
{
    function BeginState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" entered state LeadRoomEntry... m_iStateProgress="$m_iStateProgress);	#endif
		m_pawn.m_bAvoidFacingWalls = false;
		m_bIgnoreBackupBump = true;
		m_bEnteredRoom = false;
		m_bIndividualAttacks = false;
		m_iTurn = 0;
		m_bStateFlag = false;
    }
    
    function EndState()
    {
		#ifdefDEBUG if(bShowLog) log(pawn$" exited state LeadRoomEntry...m_iStateProgress="$m_iStateProgress);	#endif
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
		m_bIgnoreBackupBump = false;
		m_pawn.m_u8DesiredYaw = 0;	
		SetTimer(0, false);
		if(m_iStateProgress == 7)
			m_iStateProgress = 0;
		m_bIndividualAttacks = true;
    }

	function Timer()
	{
		if(m_iStateProgress >= 5)
		{
			m_iTurn++;
			LookAroundRoom(true);
		}
		else if(m_pawn.m_iId == 0)
		{
			// if this is an AI team leader, check for nearby Action Points while entering room to avoid backtracking...
			if(DistanceTo(m_TeamManager.m_PlanActionPoint) < 150)
				m_TeamManager.ActionPointReached();	
		}
	}

	function R6Pawn.eMovementPace GetRoomEntryPace(bool bRun)
	{
		local R6Pawn.eMovementPace      ePace;
		local bool						bCrouchedEntry;
		
		if(m_TeamLeader != none && m_TeamLeader.m_bIsPlayer)
			bCrouchedEntry = false;
		else
			bCrouchedEntry = (m_TeamManager.m_eMovementSpeed == SPEED_Cautious);

		if(bCrouchedEntry)
		{
			if(bRun)
				ePace = PACE_CrouchRun;
			else
				ePace = PACE_CrouchWalk;
		}
		else
		{
			if(bRun)
				ePace = PACE_Run;
			else
				ePace = PACE_Walk;
		}

		return ePace;
	}

Begin:
    // Pause in front of door (preparation) : check to see that team has caught up (+ if alone, don't wait)
	StopMoving();  
    
	if(m_TeamManager.m_Door == none)
	{
	    m_TeamManager.RainbowHasLeftDoor(m_pawn);
		goto('Completed');
	}

	if(!m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorClosed)
		goto('EnterRoomBegin');

	switch(m_iStateProgress)
	{
		case 0:		goto('PrepareForRoomEntry');	break;
		case 1:		goto('OpenDoor');				break;
		case 2:		goto('PreEnterRoom');			break;
		case 3:		goto('EnterRoomBegin');			break;
		case 4:		goto('InsideRoom');				break;
		case 5:		goto('EntryFinished');			break;
		default:	goto('Completed');
	}

PrepareForRoomEntry:
	#ifdefDEBUG	if(bShowLog) log(self$" LeadRoomEntry::PrepareForRoomEntry - m_TeamManager.m_Door="$m_TeamManager.m_Door);	#endif
    if(m_TeamManager.m_Door == none)
		goto('EntryFinished');

	if(!PreEntryRoomIsAcceptablyLarge())
	{
		R6PreMoveToward(m_TeamManager.m_Door, m_TeamManager.m_Door, GetRoomEntryPace(false));				
		MoveToward(m_TeamManager.m_Door);
	}

	// check if door is locked...
	if(m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorLocked)
		GotoLockPickState(m_TeamManager.m_Door.m_RotatingDoor);

	// wait for team to arrive
	#ifdefDEBUG if(bShowLog) log(self$" LeadRoomEntry:: wait for team to catch up...");		#endif
	StopMoving();
	while(!m_TeamManager.LastMemberIsStationary())
		Sleep(0.5);

	if(PreEntryRoomIsAcceptablyLarge())
	{
		// move into the proper position for a room entry (not directly in front of door)
		m_vTargetPosition = getEntryPosition(false);    
		if((VSize(m_vTargetPosition - pawn.location) > 30) && (m_vTargetPosition != vect(0,0,0)))
		{
			R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_Door.m_RotatingDoor.location, GetRoomEntryPace(false)); 
			MoveTo(m_vTargetPosition);   
			MoveToPosition(m_vTargetPosition, rotator(m_TeamManager.m_Door.m_CorrespondingDoor.location - m_vTargetPosition));
			StopMoving();
		}
	}
	m_iStateProgress = 1;

OpenDoor:
	#ifdefDEBUG if(bShowLog) log(self$" LeadRoomEntry::OpenDoor - m_TeamManager.m_Door="$m_TeamManager.m_Door);		#endif
	if(!m_TeamManager.m_bLeaderIsAPlayer)
	{
		while(m_TeamManager.m_eGoCode != GOCODE_None)
		{
			m_TeamManager.SetTeamState(TS_Waiting);
			if(NeedToReload())
			{
				RainbowReloadWeapon();
				while(m_pawn.m_bReloadingWeapon)
					Sleep(0.2);
			}
			else
				Sleep(0.5);
		}
	}
	m_TeamManager.SetTeamState(TS_OpeningDoor);
	
	// focus should be the door knob, not the pivot/hinges
	SetFocusToDoorKnob(m_TeamManager.m_Door.m_RotatingDoor);
	Sleep(0.5);	

    // Open Door
    m_pawn.PlayDoorAnim(m_TeamManager.m_Door.m_RotatingDoor);
	Sleep(0.5);
	m_pawn.ServerPerformDoorAction(m_TeamManager.m_Door.m_RotatingDoor, m_TeamManager.m_Door.m_RotatingDoor.eDoorCircumstantialAction.CA_Open);
    
	m_iStateProgress = 2;

PreEnterRoom:
	#ifdefDEBUG	if(bShowLog) log(self$" LeadRoomEntry : wait for door to open....m_TeamManager.m_Door="$m_TeamManager.m_Door);	#endif
	while(m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorClosed)
	{
		if(!m_TeamManager.m_Door.m_RotatingDoor.m_bInProcessOfOpening)
		{
			Sleep(1.0);
			Goto('OpenDoor');
		}
		else
			Sleep(0.1);
	}

	// safety precaution
	if(m_TeamManager.m_Door == none)
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$"  IRREGULAR!! m_TeamManager.m_Door==none!!");	#endif
		m_TeamManager.m_Door = R6Door(m_ActionTarget);			
	}
	m_iStateProgress = 3;

EnterRoomBegin:
	#ifdefDEBUG if(bShowLog) log(pawn$" Enter Room : initial move to get through doorway...m_TeamManager.m_Door="$m_TeamManager.m_Door);	#endif
	SetTimer(0.2, true);
	m_TeamManager.SetTeamState(TS_ClearingRoom);
	m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;

	// initial move in order to get through the doorway (use R6Door actors)...
	m_vTargetPosition = m_TeamManager.m_Door.location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));    
	MoveToPosition(m_vTargetPosition, m_TeamManager.m_Door.rotation);   

	m_TeamManager.EnteredRoom(m_pawn); 
	m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));    
	MoveToPosition(m_vTargetPosition, m_TeamManager.m_Door.rotation);   

	m_iStateProgress = 4;

InsideRoom:
	// if this member is performing the room entry alone, they should not enter the room too far...
	if(m_pawn.m_iId == (m_TeamManager.m_iMemberCount - 1))
	{
		m_iStateProgress = 5;
		goto('EntryFinished');
	}

	// get target position inside room, if there is enough room...	
	// area on other side of door may be too constricted, move to corresponding door actor, and rest of team should just follow...
	if(PostEntryRoomIsAcceptablyLarge())
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" Enter Room : get target position inside room...");	#endif
		m_vTargetPosition = getEntryPosition(true);  
		SetLocation(focalPoint);

		R6PreMoveTo(m_vTargetPosition, location, GetRoomEntryPace(true));
		MoveToPosition(m_vTargetPosition, rotator(location - m_vTargetPosition));
	}
	else
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" Enter Room : there is not enough room inside...so go in as far as possible, m_bInProcessOfOpening="$m_TeamManager.m_Door.m_RotatingDoor.m_bInProcessOfOpening);	#endif
		m_bStateFlag = true;
		if(m_pawn.m_iId == 0 && m_TeamManager.m_PlanActionPoint != none)
		{
			SetTimer(0, false);	

			if(!m_TeamManager.m_Door.m_RotatingDoor.m_bBroken)
			{
				while(m_TeamManager.m_Door.m_RotatingDoor.m_bInProcessOfOpening)
					Sleep(0.1);
			}

			// move to the next Action Point to make room for the rest of the team
			while( (m_TeamManager.m_PlanActionPoint != none) 
				  && (DistanceTo(m_TeamManager.m_Door) < 400) 
				  && (m_pawn.m_Door == none || !m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed)
				  && (m_TeamManager.m_ePlanAction == PACT_None) )
			{	
				#ifdefDEBUG	if(bShowLog) log(" INSTEAD OF finding a nearby waiting spot, move to m_TeamManager.m_PlanActionPoint="$m_TeamManager.m_PlanActionPoint);	#endif
				if(!ActorReachable(m_TeamManager.m_PlanActionPoint))
				{
					#ifdefDEBUG if(bShowLog) log(" XXX : Next Planning Action Point is not reachable.... ");	#endif
					break;
				}
				R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetRoomEntryPace(false));				
				MoveToward(m_TeamManager.m_PlanActionPoint);
				if(DistanceTo(m_TeamManager.m_PlanActionPoint) > 100)
					break;	// MoveToward failed
				
				m_TeamManager.ActionPointReached();
				focus = m_TeamManager.m_PlanActionPoint;
			}
		}
		else
		{
			#ifdefDEBUG	if(bShowLog) log(self$" find an appropriate waiting spot nearby that leaves enough room for other rainbow ... ");	#endif
			FindNearbyWaitSpot(m_TeamManager.m_Door.m_CorrespondingDoor, m_vTargetPosition); 
			SetLocation(m_vTargetPosition + 60*(m_vTargetPosition - pawn.location));

			R6PreMoveTo(m_vTargetPosition, location, GetRoomEntryPace(true));
			MoveToPosition(m_vTargetPosition, rotator(location - m_vTargetPosition));
		}
	}

	m_iStateProgress = 5;

EntryFinished:	
	SetTimer(1.0, true);
	LookAroundRoom(true);

    m_TeamManager.RainbowHasLeftDoor(m_pawn);   
	#ifdefDEBUG	if(bShowLog) log(pawn$" now allow time for others to come in and ensure room is clear ");	#endif
    
	m_iStateProgress = 6;
	
	if(m_pawn.m_iId == (m_TeamManager.m_iMemberCount - 1))
		Sleep(1.5);
	else
		Sleep(3.0);	

Completed:
	m_iStateProgress = 7;
	if(m_pawn.m_iId == 0)
	{
		if(!m_bStateFlag)
			m_TeamManager.RestoreTeamOrder();
		GotoState('Patrol');
	}
	else
	{
		if(m_TeamManager.m_iTeamAction != TEAM_None)
			GotoState(GetNextTeamActionState());
		else
			GotoState('FollowLeader');		
	}		
}

function DispatchOrder( INT iOrder, optional R6RainbowTeam teamManager );

//------------------------------------------------------------------
// GetNextTeamActionState()
//------------------------------------------------------------------
function name GetNextTeamActionState()
{
	if(m_pawn.m_iId > 1)
		return('FollowLeader');

	if((m_TeamManager.m_iTeamAction & TEAM_ClimbLadder) > 0)
		return('TeamClimbStartNoLeader');

	if((m_TeamManager.m_iTeamAction & TEAM_SecureTerrorist) > 0)
		return('TeamSecureTerrorist');

	if( ((m_TeamManager.m_iTeamAction & TEAM_DisarmBomb) > 0)
	    || ((m_TeamManager.m_iTeamAction & TEAM_InteractDevice) > 0)
		|| ((m_TeamManager.m_iTeamAction & TEAM_Move) > 0) )
		return('TeamMoveTo');

	if( ((m_TeamManager.m_iTeamAction & TEAM_OpenDoor) > 0)
		|| ((m_TeamManager.m_iTeamAction & TEAM_CloseDoor) > 0)
		|| ((m_TeamManager.m_iTeamAction & TEAM_ClearRoom) > 0)
		|| ((m_TeamManager.m_iTeamAction & TEAM_Grenade) > 0) )
		return('PerformAction');

	return('FollowLeader');
}

//------------------------------------------------------------------
// VerifyWeaponInventory()
//------------------------------------------------------------------
function VerifyWeaponInventory()
{
	local INT iWeapon;

	if(m_pawn.engineWeapon == pawn.m_WeaponsCarried[m_pawn.m_iCurrentWeapon-1])
		return;

	for(iWeapon=0; iWeapon<4; iWeapon++)
	{
		if(m_pawn.engineWeapon == pawn.m_WeaponsCarried[iWeapon])
		{
			m_pawn.m_iCurrentWeapon = iWeapon+1;
			return;
		}
	}
}

//------------------------------------------------------------------
// EnsureRainbowIsArmed()                                       
//------------------------------------------------------------------
function bool EnsureRainbowIsArmed()
{
	// check if weapon is secured....
	if(m_pawn.m_bWeaponIsSecured && !m_pawn.m_bWeaponTransition)
	{
		m_pawn.SetNextPendingAction(PENDING_EquipWeapon);
		m_pawn.PlayWeaponAnimation();
		return true;
	}

	if(m_pawn.m_iCurrentWeapon > 2)
	{
		#ifdefDEBUG	if(bShowLog) log(" Rainbow is not properly ARMED!!! switch to primary!!!");		#endif
		if(Pawn.m_WeaponsCarried[0] != none && Pawn.m_WeaponsCarried[0].HasAmmo())
			SwitchWeapon(1);
		else
			SwitchWeapon(2);
		return true;
	}
	else if(m_pawn.m_iCurrentWeapon == 2)
	{
		if(Pawn.m_WeaponsCarried[0] != none && (Pawn.m_WeaponsCarried[0].m_eWeaponType != WT_Sniper) && Pawn.m_WeaponsCarried[0].HasAmmo())
		{
			SwitchWeapon(1);
			return true;
		}
	}

	return false;
}

//------------------------------------------------------------------
// SniperChangeToPrimaryWeapon()                                       
//------------------------------------------------------------------
function bool SniperChangeToPrimaryWeapon()
{
	if(Pawn.m_WeaponsCarried[0] == none)
		return false;

	if((pawn.engineWeapon != none) 
		&& !m_pawn.m_bChangingWeapon 
		&& (pawn.engineWeapon == m_pawn.m_WeaponsCarried[1]) 
		&& Pawn.m_WeaponsCarried[0].HasAmmo()
		&& (Pawn.m_WeaponsCarried[0].m_eWeaponType == WT_Sniper))
	{
		SwitchWeapon(1);	
		return true;
	}
	return false;
}

//------------------------------------------------------------------
// SniperChangeToSecondaryWeapon()                                       
//------------------------------------------------------------------
function bool SniperChangeToSecondaryWeapon()
{
	if((pawn.engineWeapon != none) 
		&& !m_pawn.m_bChangingWeapon 
		&& (pawn.engineWeapon == m_pawn.m_WeaponsCarried[0]) 
		&& Pawn.m_WeaponsCarried[1].HasAmmo()
		&& (Pawn.EngineWeapon.m_eWeaponType == WT_Sniper))
	{
		SwitchWeapon(2);
		return true;
	}
	return false;	
}

//////////////////////////////////////////////////////////////////////////////////////////
//                          RAINBOW AI TEAM LEADER                                      //
//////////////////////////////////////////////////////////////////////////////////////////
//==========================================================//
//              -- state SNIPEUNTILGOCODE --                //
//==========================================================//
state SnipeUntilGoCode
{
	function BeginState()	
	{	
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state SnipeUntilGoCode...m_TeamManager="$m_TeamManager);	#endif
		m_pawn.m_bIsSniping = true; 
		m_pawn.m_bAvoidFacingWalls = false;
		m_bStateFlag = false;		
	}

	function EndState()		
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" has exited state SnipeUntilGoCode...");		#endif
		//pawn.m_bWantsToProne = false;
		m_bIgnoreBackupBump = false;
		m_pawn.m_bIsSniping = false;
		m_pawn.m_bAvoidFacingWalls = true;
		// this call will only change to secondary weapon if carrying a true sniper rifle (Except when reacting to a noise)
		m_TeamManager.CheckTeamEngagingStatus();
	}

	event SeePlayer(Pawn seen)
	{
		local R6Pawn aPawn;

		if(!m_bStateFlag)
		{
			global.SeePlayer(seen);
			return;
		}

		if( m_pawn.IsEnemy( seen ) )
		{
            aPawn = R6Pawn(seen);    

			// do not fire at a surrendered/incapacitated/dead terrorist
			if(aPawn.m_bIsKneeling || !aPawn.IsAlive() || (m_TeamManager==none) || (enemy!=none))
				return;

			if(AClearShotIsAvailable(seen, m_pawn.GetFiringStartPoint()))
			{
				#ifdefDEBUG	if(bShowLog) logX(pawn$" : state SnipeUntilGoCode - SeePlayer() enemy="$enemy$" has been spotted..m_TeamManager.m_bSniperHold="$m_TeamManager.m_bSniperHold$" m_TeamManager.m_OtherTeamVoicesMgr="$m_TeamManager.m_OtherTeamVoicesMgr);	#endif
				if(m_TeamManager.m_bSniperHold && m_TeamManager.m_OtherTeamVoicesMgr != none)
					m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, ROTV_SniperHasTarget);
				m_pawn.m_bEngaged = true;
				SetEnemy(seen);
				target = enemy;	
				Enable('EnemyNotVisible');
			}
		}
	}

	event EnemyNotVisible()
	{
		if(Level.TimeSeconds - LastSeenTime < 0.5)
			return;

		#ifdefDEBUG	if(bShowLog) logX(pawn$" (SNIPER) EnemyNotVisible() !!!! enemy="$enemy$" enemy.IsAlive()="$enemy.IsAlive());		#endif
		if(m_TeamManager.m_bSniperHold && m_TeamManager.m_OtherTeamVoicesMgr != none)
			m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, ROTV_SniperLooseTarget);

		StopFiring();
		EndAttack();
		Disable('EnemyNotVisible');
	}

	event AttackTimer();

	function bool NoiseSourceIsVisible()
	{
		if(VSize(m_vNoiseFocalPoint - pawn.location) < 200)
			return false;

		if(normal(m_vNoiseFocalPoint - pawn.location) dot vector(pawn.rotation) > 0.3)
			return true;

		return false;
	}

	event Timer()
	{
		if(enemy != none)
			return;

		if(m_vNoiseFocalPoint != vect(0,0,0))
		{
			if((m_TeamManager.m_iMemberCount == 1) && !NoiseSourceIsVisible() && FastTrace(pawn.location, m_vNoiseFocalPoint))
			{
				#ifdefDEBUG	if(bShowLog) log(" sniper heard a noise, and is alone in his team , so get up! m_vNoiseFocalPoint="$m_vNoiseFocalPoint);	#endif
				GotoState('PauseSniping');
			}
			else
				m_vNoiseFocalPoint = vect(0,0,0);	
		}
	}

Begin:	
	SetTimer(0.5, true);
	enemy = none;
	target = enemy;
	m_TeamManager.CheckTeamEngagingStatus();

	#ifdefDEBUG	if(bShowLog) log(" SnipeUntilGoCode m_ActionTarget="$m_ActionTarget);	#endif
	// change to secondary if carrying a sniper rifle (if target is far)
	if(DistanceTo(m_ActionTarget) > 300)
	{
		if(SniperChangeToSecondaryWeapon())
			FinishAnim( m_pawn.C_iWeaponRightAnimChannel ); 
	}

GetIntoPosition:
	while(DistanceTo(m_ActionTarget) > 40)
	{
		// move to the sniping location
		#ifdefDEBUG	if(bShowLog) log(" move to the sniping location : m_ActionTarget="$m_ActionTarget$" location="$m_ActionTarget.location$" pawn.location="$pawn.location$" rotation="$m_ActionTarget.rotation);	#endif
		R6PreMoveToward(m_ActionTarget, m_ActionTarget, PACE_Walk);
		MoveToward(m_ActionTarget);
		StopMoving();
	}
	
	// assume the correct orientation
	ChangeOrientationTo(m_TeamManager.m_rSnipingDir);
	FinishRotation();

TakePosition:
	// switch to primary if currently carrying secondary
	if(SniperChangeToPrimaryWeapon())
		FinishAnim( m_pawn.C_iWeaponRightAnimChannel );
		
	if(pawn.m_bIsProne)
	{
		m_bIgnoreBackupBump = true;
		goto('LocateEnemy');
	}
	
	// check if we can go prone
	m_vTargetPosition = pawn.location - vect(0,0,60);
	if(ClearToSnipe(m_vTargetPosition, m_TeamManager.m_rSnipingDir))
	{
		pawn.bWantsToCrouch = true;
		Sleep(0.5);
		pawn.m_bWantsToProne = true;
		Sleep(1.5);
	}
	else if(ClearToSnipe(pawn.location, m_TeamManager.m_rSnipingDir))
	{
		pawn.bWantsToCrouch = true;
		Sleep(1.0);
	}			
	else
	{
		pawn.bWantsToCrouch = false;	
		pawn.m_bWantsToProne = false;
		Sleep(0.5);
	}

	m_pawn.ResetBoneRotation();
	ChangeOrientationTo(m_TeamManager.m_rSnipingDir);
	m_bIgnoreBackupBump = true;
	m_bStateFlag = true;
	enemy = none;
    m_TeamManager.PlayWaitingGoCode(m_TeamManager.m_eGoCode, true);

LocateEnemy:
	#ifdefDEBUG	if(bShowLog) logX(" (LocateEnemy) this pawn is now sniping... ");	#endif
	if(!m_TeamManager.m_bCAWaitingForZuluGoCode)
		m_TeamManager.SetTeamState(TS_Sniping);

	if(enemy == none)
	{		
		ChangeOrientationTo(m_TeamManager.m_rSnipingDir);
		Sleep(0.1);
		Goto('LocateEnemy');
	}

EngageEnemy:
	m_TeamManager.CheckTeamEngagingStatus();
	#ifdefDEBUG	if(bShowLog) log(" (EngageEnemy) an enemy has been spotted : terrorist="$enemy$" ammo : "$Pawn.EngineWeapon.NumberOfBulletsLeftInClip());	#endif
	if(!m_TeamManager.m_bSniperHold && enemy != none)
	{
		Pawn.EngineWeapon.SetRateOfFire(ROF_Single); 
		
		focus = enemy;
		target = enemy;
		FinishRotation(); 	

		// wait for accuracy....
		while(!IsReadyToFire(enemy))
			Sleep(0.2);

		// fire at enemy
		m_TeamManager.RainbowIsEngagingEnemy();
		StartFiring();
		Sleep(0.2);
		StopFiring();
	}
	
	// check if we need to reload
	if(NeedToReload())
		RainbowReloadWeapon();

	// if is no longer visible, go back to locating a new target
	if(enemy == none ) 
		Goto('LocateEnemy');

	// if enemy is dead, go back to locating a new target
	if(!R6Pawn(enemy).IsAlive())
	{
		#ifdefDEBUG	if(bShowLog) log(" enemy is dead ="$ enemy);	#endif
		if(m_TeamManager.m_bSniperHold && m_TeamManager.m_OtherTeamVoicesMgr != none)
			m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, ROTV_SniperLooseTarget);
		
		m_TeamManager.DisEngageEnemy(pawn, enemy);
		enemy = none;
		m_pawn.ResetBoneRotation();
		Goto('LocateEnemy');
	}

	Sleep(1.0);
	Goto('EngageEnemy');

EndSniping:	
	m_pawn.ResetBoneRotation();
	m_bIgnoreBackupBump = false;	
	if(pawn.m_bWantsToProne)
	{
		pawn.m_bWantsToProne = false;
		Sleep(1.0);
	}
	pawn.bWantsToCrouch = false;	

WaitForGoCode:
	Sleep(1.0);
	Goto('WaitForGoCode');

Finish:
	// if this pawn is not the team lead, then go to FollowLeader state, otherwise go to Patrol
	if(m_pawn.m_iId == 0)
		GotoState('Patrol');
	else
		GotoState('FollowLeader');	
}

//==========================================================//
//              -- state PAUSESNIPING --                    //
//==========================================================//
state PauseSniping
{
#ifdefDEBUG
    function BeginState()   {		if(bShowLog) log("... entered state PauseSniping...");	}
	function EndState()		{		if(bShowLog) log("... exited state PauseSniping...");	}
#endif

Begin:	
	StopMoving();
	m_vTargetPosition = m_vNoiseFocalPoint;
	m_vNoiseFocalPoint = vect(0,0,0);

	// should he stay crouched?
	if(pawn.m_bWantsToProne)
	{
		pawn.m_bWantsToProne = false;
		Sleep(1.0);
	}
	pawn.bWantsToCrouch = false;	

LookAround:
	SetLocation(m_vTargetPosition);
	focus = self;
	FinishRotation();

Wait:
	// if an enemy is spotted, rainbow will enter the attacking state
	Sleep(2.5);

	if(enemy != none)
		goto('Wait');

	// if 2.5 seconds have passed with no action/interruption, then go back to sniping
	GotoState('SnipeUntilGoCode');
}

function CheckNeedToClimbLadder()
{
	// check if this is a rainbow carrying out a teamorder
	if((m_pawn.m_iId == 1) && m_TeamManager.m_bTeamIsSeparatedFromLeader)
		return;  

	// AI team leader
	if(m_pawn.m_iId == 0)
		return;

	if(m_TargetLadder == none)
		return;

	// check if pace member is on the same end of the ladder as this pawn
	if(PawnIsOnTheSameEndOfLadderAsMember(m_PaceMember, R6LadderVolume(m_TargetLadder.myLadder)))
	{
		// members are already on the same side....no need to climb
		m_TeamManager.MemberFinishedClimbingLadder(m_pawn);
	}	
}

function bool PawnIsOnTheSameEndOfLadderAsMember(R6Rainbow aRainbow, R6LadderVolume ladderVolume)
{
	local  bool		bPaceMemberIsAtTopOfLadder;

	if(ladderVolume == none)
		return true;

	bPaceMemberIsAtTopOfLadder = aRainbow.location.z > ladderVolume.location.z;
	if(bPaceMemberIsAtTopOfLadder == (m_pawn.location.z > ladderVolume.location.z))
		return true;
	else
		return false;
}

//==========================================================//
//             -- state TEAMCLIMBSTARTNOLEADER --           //
// 2nd member leads team to climbs ladder without the       //
// team leader...                                           //
//==========================================================//
state TeamClimbStartNoLeader
{
    function BeginState()
    {
		#ifdefDEBUG if(bShowLog) log(pawn$" has entered state TeamClimbStartNoLeader...");   #endif
		m_pawn.m_bAvoidFacingWalls = false;
		m_pawn.m_bCanProne = false;
    }

    function EndState()
    {
		#ifdefDEBUG if(bShowLog) log(pawn$" has exited state TeamClimbStartNoLeader...");	#endif
		m_pawn.m_bCanProne = m_pawn.default.m_bCanProne;
    }

Begin:	
    // assume moveTarget has been set by TeamAI    
	m_TeamManager.SetTeamState(TS_Moving);
	moveTarget = m_TeamManager.m_TeamLadder;
    if((moveTarget==none) || !moveTarget.IsA('R6Ladder'))  
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" TeamClimbStartNoLeader : moveTarget="$moveTarget$" m_TeamManager.m_TeamLadder="$m_TeamManager.m_TeamLadder);	#endif
		GotoState('HoldPosition');
	}

	m_TargetLadder = R6Ladder(moveTarget);

	// if ladder is not reachable, find a path to it
	if(!CanWalkTo(m_TargetLadder.location) && !ActorReachable(m_TargetLadder)) 
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" this pawn can't reach the ladder directly so use pathfinding to get to it...");		#endif
		FindPathToTargetLocation(m_TargetLadder.location, m_TargetLadder);
	}

	// move directly towards ladder
	if(m_TargetLadder.m_bIsTopOfLadder)
	{
		m_vTargetPosition = m_TargetLadder.location + 70*vector(m_TargetLadder.rotation);
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk); 
		MoveTo(m_vTargetPosition);
	}
	else
	{		
		moveTarget = m_TargetLadder;
		R6PreMoveToward(moveTarget, moveTarget, PACE_Walk); 
		MoveToward(moveTarget);
	}

	// wait for Zulu gocode if there is one
    while( m_TeamManager.m_bCAWaitingForZuluGoCode )
    {
		m_TeamManager.SetTeamState(TS_Waiting);
        Sleep(0.5);     
    }
	
	moveTarget = m_TargetLadder;

WaitAtEndForLeader:
	m_TeamManager.SetTeamState(TS_ClimbingLadder);
	nextState = 'TeamClimbEndNoLeader';
    GotoState('ApproachLadder');
}

//==========================================================//
//             -- state TEAMCLIMBENDNOLEADER --             //
// 2nd in command waits for team to finish climbing ladder  //
//==========================================================//
state TeamClimbEndNoLeader
{
#ifdefDEBUG 
	function BeginState()	{	if(bShowLog) log(pawn$" has entered state TeamClimbEndNoLeader...");	}	
    function EndState()		{	if(bShowLog) log(pawn$" has exited state TeamClimbEndNoLeader...");		}
#endif

Begin:
	// if this NPC is carrying out a player order, add a delay based on the leadership skill
	if(m_pawn.m_iId == 1)
		Sleep(GetLeadershipReactionTime());

PickDest:
    //make room for team to arrive at end of ladder
    FindNearbyWaitSpot(m_pawn.m_Ladder, m_vTargetPosition); 
	#ifdefDEBUG	if(bShowLog) log(" destination to wait for team is: m_vTargetPosition="$m_vTargetPosition);		#endif
	if(m_vTargetPosition == vect(0,0,0))
	{
		#ifdefDEBUG	if(bShowLog) log(" PROBLEM : "$pawn$" could not obtain an appropriate Wait Spot from FindNearbyWaitSpot()");	#endif
		Goto('WaitAtEndForTeam');
	}
	else
	{
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk);
		MoveTo(m_vTargetPosition);  
	}
	StopMoving();

WaitAtEndForTeam:
	m_pawn.m_Ladder = none;
    Sleep(1.0);
    nextState = '';
	if(!m_TeamManager.m_bTeamIsClimbingLadder)
	{
		if(m_TeamManager.m_iTeamAction != TEAM_None)
		{
			// the team climbed the ladder for pathfinding and will proceed to perform previous action
			GotoState(GetNextTeamActionState());
		}
		else
		{
			if(m_TeamManager.m_bTeamIsRegrouping)
				GotoState('FollowLeader');
			else
				GotoState('HoldPosition');
		}
	}
	else
		goto('WaitAtEndForTeam');
}

//==========================================================//
//             -- state TEAMCLIMBLADDER --                  //
// team climbs ladder following another member... this      //
// member may be the team leader or in the case where the   //
// team is separated from leader may be the second member.  //
//==========================================================//
state TeamClimbLadder
{
    function BeginState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" ... entered state TeamClimbLadder...m_pawn.m_Ladder="$m_pawn.m_Ladder$" , m_iStateProgress="$m_iStateProgress);		#endif
		m_pawn.m_bAvoidFacingWalls = false;
		m_pawn.ResetBoneRotation();
		m_pawn.m_bCanProne = false;
    }

    function EndState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" ... exited state TeamClimbLadder... m_iStateProgress="$m_iStateProgress);	#endif
		if(m_iStateProgress == 5)
			m_iStateProgress = 0;
		m_pawn.ResetBoneRotation();
		m_pawn.m_bCanProne = m_pawn.default.m_bCanProne;
    }

	function SetPawnFocus()
	{
		local INT iMember;
		local rotator rOffset;

		if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
			iMember = m_pawn.m_iId - 1;
		else
			iMember = m_pawn.m_iId;

		switch(iMember)
		{
			case 1:		// in this case the team is not separated from leader				
				if(m_pawn.m_Ladder.m_bIsTopOfLadder)
					m_pawn.AimDown();     
				else
					m_pawn.AimUp();       
				focus = m_pawn.m_Ladder; 
				break;
			case 2:
				SetLocation(m_vTargetPosition + 100*(m_vTargetPosition - m_pawn.m_Ladder.location));
				focus = self;
				break;
			case 3:
				rOffset = rotator(m_vTargetPosition - m_pawn.m_Ladder.location);
				rOffset += rot(0,8192,0);
				SetLocation(m_vTargetPosition + 100*vector(rOffset));
				focus = self;
				break;
			default:
				SetLocation(m_pawn.m_Ladder.location);
		}
	}

	function bool LeadHasStartedClimbing()
	{
		if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
			return m_TeamManager.m_Team[1].m_bIsClimbingLadder;
		else
			return m_TeamLeader.m_bIsClimbingLadder;
	}
	
	function bool NeedToFollowTeam()
	{
		local R6Rainbow aRainbow;

		if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
			aRainbow = m_TeamManager.m_Team[1];
		else
			aRainbow = m_TeamLeader;
			
		if(m_TeamManager.m_TeamLadder != none && !PawnIsOnTheSameEndOfLadderAsMember(aRainbow, R6LadderVolume(m_TeamManager.m_TeamLadder.myLadder)))
			return false;

		return (IsMoving(aRainbow) && !aRainbow.m_bIsClimbingLadder);
	}

	function R6Ladder GetLadderMoveTarget()
	{
		if(pawn.location.z > m_TeamManager.m_TeamLadder.myLadder.location.z)
			return R6LadderVolume(m_TeamManager.m_TeamLadder.myLadder).m_TopLadder;
		else
			return R6LadderVolume(m_TeamManager.m_TeamLadder.myLadder).m_BottomLadder;
	}

Begin:
	switch(m_iStateProgress)
	{
		case 0:		goto('FollowTeam');					break;
		case 1:		goto('WaitForLeadToStartClimbing');	break;
		case 2:		goto('FormationAroundLadder');		break;
		case 3:		goto('WaitForTurnToClimb');			break;
		default:	goto('ClimbLadder');
	}

FollowTeam:  
	#ifdefDEBUG	if(bShowLog) log(pawn$" is following team towards ladder ");	#endif
	if(DistanceTo(m_PaceMember) > (GetFormationDistance() + 35))
	{ 
		m_vTargetPosition = m_PaceMember.location + (GetFormationDistance() * normal(pawn.location - m_PaceMember.location));
		if(!ActorReachable(m_PaceMember)) 
			FindPathToTargetLocation(m_PaceMember.location, m_PaceMember);
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk);
		MoveTo(m_vTargetPosition);
	}
	else
		Sleep(0.5);
	StopMoving();

	if(NeedToFollowTeam())  	
	    Goto('FollowTeam');
   
	m_iStateProgress = 1;

WaitForLeadToStartClimbing:	
	#ifdefDEBUG	if(bShowLog) log(self$" WaitForLeadToStartClimbing... ");	#endif
	// check if pacemember is already on the other side of the ladder
	if((abs(m_PaceMember.location.z - pawn.location.z) < 80))
	{
		m_iStateProgress = 2;
		goto('FormationAroundLadder');
	}

	// wait for team lead to get on ladder before taking formation... 
	if(!LeadHasStartedClimbing())
	{
		Sleep(1.0);
		goto('WaitForLeadToStartClimbing');
	}

	m_iStateProgress = 2;

FormationAroundLadder:
	// check if there is insufficient room to form around ladder
	if(m_pawn.m_Ladder.m_bSingleFileFormationOnly)
	{
		#ifdefDEBUG	if(bShowLog) log(self$" There is not enough room for a formation around ladder, move ahead to WaitForTurnToClimb");	#endif
		StopMoving();
		goto('WaitForTurnToClimb');
	}

	if(!m_TeamManager.m_bTeamIsSeparatedFromLeader)
	{
	    if(m_pawn.m_Ladder == none)
	       m_pawn.m_Ladder = m_TeamLeader.m_Ladder;	// pawn's m_Ladder is none, try to get it from teamleader
	}

	// take a formation around ladder
    if(m_pawn.m_Ladder != none)
    {
        m_vTargetPosition = getLadderPosition();  
		
		// check to make sure there is ground under the location
		if(PointReachable(m_vTargetPosition))
		{
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_Walk); 
			MoveTo(m_vTargetPosition);  
			StopMoving();
		}
    }
	
	SetPawnFocus();  	
   	m_iStateProgress = 3;
	#ifdefDEBUG	if(bShowLog) log(self$" : wait for member ahead of me to finish climbing...");	#endif

WaitForTurnToClimb:            
	#ifdefDEBUG	if(bShowLog) log(self$" wait for turn to climb...m_PaceMember="$m_PaceMember);	#endif
    // if pacemember is close by and is not climbing ladder, wait... 
    if( (abs(m_PaceMember.location.z - pawn.location.z) < 80) || m_PaceMember.m_bIsClimbingLadder )
    {              
        Sleep(1.0);
        Goto('WaitForTurnToClimb');
    }
	m_iStateProgress = 4;

ClimbLadder:
	#ifdefDEBUG	if(bShowLog) log(self$" member ahead of me has finished climbing ladder...");	#endif
    Sleep(0.5);
	m_pawn.ResetBoneRotation();

	// consider that m_TeamManager.m_TeamLadder may have changed	
    moveTarget = GetLadderMoveTarget(); 
	if(!CanWalkTo(moveTarget.location) && !ActorReachable(moveTarget)) 
		FindPathToTargetLocation(moveTarget.location, moveTarget);

    R6PreMoveToward(moveTarget, moveTarget, PACE_Walk);
    MoveToward(moveTarget);  
    m_iStateProgress = 5;
	if(moveTarget.IsA('R6Ladder'))
    {     
        nextState = 'FollowLeader';
        nextLabel = 'Begin';
        GotoState('ApproachLadder');
    }
}

//------------------------------------------------------------------
// GetFormationDistance()
//------------------------------------------------------------------
function float GetFormationDistance()
{
	if(m_PaceMember != none)
	{
		if(m_PaceMember.m_bIsProne || ((m_PaceMember.controller != none) && (m_PaceMember.controller.IsInState('SnipeUntilGoCode'))) )
			return m_TeamManager.m_iFormationDistance * 2;
	}

	return m_TeamManager.m_iFormationDistance;
}

//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
// - inherited
// c_iDistanceBumpBackUp depends on m_TeamManager.m_iFormationDistance
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish()
{
	local  R6Pawn aBumpPawn;

    // Check first if we are in this state from too long
    if(m_fLastBump + 4.0f < Level.TimeSeconds)
        return true;

	aBumpPawn = R6Pawn(m_BumpedBy);

	focus = none;	// to prevent npc from constantly turning to maintain focus on pawn he was bumped by
    if(m_TeamLeader == none)
		return ((DistanceTo(m_BumpedBy) > (c_iDistanceBumpBackUp + 60)) || !IsMoving(aBumpPawn));
	else
		return( (DistanceTo(m_BumpedBy) > c_iDistanceBumpBackUp + 60)) || 
				((DistanceTo(m_PaceMember) > c_iDistanceBumpBackUp + 60) && (IsMoving(m_PaceMember) && !m_PaceMember.IsInState('BumpBackUp')) );
}

//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a 
//	return state (in m_bumpBackUpState_nextState)
// - inherited
//------------------------------------------------------------------
function BumpBackUpStateFinished()
{
    gotoState( 'HoldPosition' );
}

//------------------------------------------------------------------
// IsMoving()
//------------------------------------------------------------------
function bool IsMoving(Pawn p)
{
	if(p == none || p.velocity == vect(0,0,0))
        return false;
    else
        return true;
}

//------------------------------------------------------------------
// SetNoiseFocus()
//------------------------------------------------------------------
function SetNoiseFocus(vector vSource)
{
//rb	if(bShowLog) log(pawn$" SetNoiseFocus() was called... m_vNoiseFocalPoint="$m_vNoiseFocalPoint$" m_bReactToNoise="$m_bReactToNoise);
	// check if rainbow is in a state that permits this...
	m_vNoiseFocalPoint = vSource;
	if(m_bReactToNoise)
	{		
		SetLocation(m_vNoiseFocalPoint);
		focus = self;
	}
}

//------------------------------------------------------------------
// ResetNoiseFocus()
//------------------------------------------------------------------
function ResetNoiseFocus()
{
	m_vNoiseFocalPoint = vect(0,0,0);
}

//------------------------------------------------------------------
// NeedToReload()
//------------------------------------------------------------------
function bool NeedToReload()
{
	local FLOAT  fCutOff;

	if(m_pawn.m_iCurrentWeapon > 2)
		return false;
	
	if(m_TeamManager.m_eGoCode == GOCODE_None)
		fCutOff = 0.5;
	else
		fCutOff = 0.75;

	if(pawn.EngineWeapon == none || m_bWeaponsDry || m_pawn.m_bChangingWeapon || m_pawn.m_bReloadingWeapon)
		return false;

	if(pawn.EngineWeapon.NumberOfBulletsLeftInClip() == 0)
	{
		if(enemy == none && pawn.EngineWeapon.IsPumpShotGun())
			m_pawn.m_bReloadToFullAmmo = true;
		return true;
	}

	if(enemy != none)
		return false;

	if(pawn.EngineWeapon.NumberOfBulletsLeftInClip() <= fCutOff*pawn.EngineWeapon.GetClipCapacity())
	{				
		// check if next clip is more than 50% full (except for pump shotguns)
		if(pawn.EngineWeapon.IsPumpShotGun() && (pawn.engineWeapon.GetNbOfClips() > 0))
		{			
			m_pawn.m_bReloadToFullAmmo = true;
			return true;
		}

		// for all other weapons, check if we have at least one full clip before reloading
		if(pawn.EngineWeapon.HasAtLeastOneFullClip())		
			return true;
	}

	return false;
}

//------------------------------------------------------------------
// RainbowReloadWeapon()
//------------------------------------------------------------------
function RainbowReloadWeapon()
{
	if(m_bWeaponsDry)
		return;

	if(m_pawn.m_bReloadingWeapon)
		return;

	if(Pawn.EngineWeapon.GetNbOfClips() > 0) 
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" needs to reload weapon");	#endif
		if(enemy != none)
		{
			StopFiring();
			EndAttack();
		}
		m_pawn.m_u8DesiredYaw = 0;
		m_pawn.m_u8DesiredPitch = 0;
		m_pawn.m_ePlayerIsUsingHands = HANDS_None;
		m_pawn.ServerSwitchReloadingWeapon(TRUE);
		m_pawn.ReloadWeapon();	
	}
	else if(m_pawn.m_iCurrentWeapon == 1 && Pawn.m_WeaponsCarried[1].HasAmmo())
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" needs to switch to secondary weapon");	#endif
		SwitchWeapon(2);
	}
	else if(m_pawn.m_iCurrentWeapon == 2 && Pawn.m_WeaponsCarried[0].HasAmmo())
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" needs to switch to primary weapon");	#endif
		SwitchWeapon(1);
	}
	else if(!m_bWeaponsDry)
	{
		#ifdefDEBUG	if(bShowLog) log("  BOTH WEAPONS ARE DRY?????!!!!! ");	#endif
		// NO AMMO LEFT AT ALL!! do nothing...
		m_bWeaponsDry = true;
		//rbsound 
		if (m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus)
            m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, RMV_AmmoOut);
	}
}

//------------------------------------------------------------------
// GetTeamLeaderPace()
//------------------------------------------------------------------
function R6Pawn.eMovementPace GetPace(bool bRun)
{
	if(m_PaceMember.m_bIsProne && !m_PaceMember.m_bIsSniping)
		return PACE_Prone;    
	else if(m_PaceMember.bIsCrouched)
	{
		if(bRun)
			return PACE_CrouchRun;    
		else
			return PACE_CrouchWalk;
	}
	else
	{
		if(bRun)
			return PACE_Run;   
		else
			return PACE_Walk;
	}
}

function SetRainbowOrientation()
{
	if(m_ePawnOrientation != PO_Back)
		SetOrientation();
	else
	{
		if(m_bIsMovingBackwards)
			SetOrientation();
		else
			SetOrientation(PO_Front);
	}
}

function ReorganizeTeamAsNeeded()
{
	if(m_pawn.m_eHealth != HEALTH_Wounded)
	{
		m_bReorganizationPending = false;
		return;
	}

	#ifdefDEBUG if(bShowLog) log(pawn$" "$self$" ReorganizeTeamAsNeeded() was called...... ");		#endif
	m_TeamManager.ReOrganizeWoundedMembers();
}

//==========================================================//
//                  -- state FOLLOWLEADER --                //
// this is the state for NPC Rainbow team members that      //
// follow their team leader (player or NPC)                 //
//==========================================================//
state FollowLeader
{
    function BeginState()
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" entered state followleader, pawn.physics="$pawn.physics );	#endif
        m_iWaitCounter = 0;
		m_bIsMovingBackwards = false;
		m_ePawnOrientation = PO_Front;
		m_bAlreadyWaiting = false;
		m_vPreviousPosition = vect(0,0,0);
		m_bIgnoreBackupBump = false;
		
		m_iStateProgress = 0;
		m_bReactToNoise = true;
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
    }

    function EndState()
    {
		#ifdefDEBUG if(bShowLog) log(pawn$" exited state followleader" );	#endif
		m_bIgnoreBackupBump = false;
		m_bReactToNoise = false;
		
		// if there is a grenade nearby, do not reset the Timer
		if(!m_TeamManager.m_bGrenadeInProximity)
			SetTimer(0, false);

		m_pawn.StopPeeking();
		m_pawn.m_u8DesiredYaw = 0;

		if(!m_TeamManager.m_bLeaderIsAPlayer && m_TeamManager.m_bTeamIsRegrouping && (m_PaceMember == m_TeamLeader))
			m_TeamManager.TeamIsRegroupingOnLead(false);
    }

    function Timer()
	{
        m_iWaitCounter++; 
        m_iTurn++;
        if(m_iTurn == 6)
            m_iTurn = 0;
        
		// middle members only should check environment for formation (not last member)
		// do not check environment unless moving -> avoid facing walls with adversly affect results otherwise
        if(((m_pawn.m_iId == 1) || (m_pawn.m_iId == 2)) && IsMoving(pawn) && (m_ePawnOrientation != PO_Back))
			CheckEnvironment();             
        
		if(m_bIsCatchingUp)
			m_pawn.ResetBoneRotation();
		else
			SetRainbowOrientation();
    }
    
	function bool RainbowShouldWait()
	{ 
		local FLOAT fDistance;

		// only use this check when standing, caused studdering in movement of NPCs when crouched
		if(!m_bSlowedPace && IsMoving(m_PaceMember) && !pawn.m_bIsProne && !pawn.bIsCrouched)
			return false;

		if(m_vTargetPosition == m_vPreviousPosition)
			return true;

		// if m_bSlowedPace is true, then waiting distance should be twice the formation distance, allow a bigger gap to form 
		// so that movement doesn't studder...
		fDistance = GetFormationDistance();
		if(m_bSlowedPace)
			fDistance*=2; 
	
		if(m_pawn.m_bIsProne)
			fDistance += 60;
		else if(!m_pawn.m_bIsClimbingStairs)
			fDistance += 35;
		
		if(DistanceTo(m_PaceMember, true) < fDistance)
			return true;

		return false;
	}
 
	function vector GetNextTargetPosition()
	{
		local vector vDir;
		local rotator rDir;
		local rotator rOffset;

		if(m_PaceMember == none)
			return pawn.location;

		if(m_bUseStaggeredFormation && (m_TeamManager.m_eFormation == m_eFormation) && (m_ePawnOrientation != PO_Back) && !pawn.m_bIsProne && !m_bSlowedPace)
		{
			rDir = rotator(m_PaceMember.location - pawn.location);
			rOffset = rot(0,2000,0);
			if((m_eFormation == FORM_SingleFileNoWalls) || (m_eFormation == FORM_SingleFileWallRight))
			{				
				if(m_pawn.m_iId == 1)
					rDir += rOffset;
				else 
					rDir -= rOffset;
				return(m_PaceMember.location - GetFormationDistance()*vector(rDir));
			}

			if(m_eFormation == FORM_SingleFileWallLeft)
			{				
				if(m_pawn.m_iId == 1)
					rDir -= rOffset;
				else 
					rDir += rOffset;
				return(m_PaceMember.location - GetFormationDistance()*vector(rDir));
			}
		}		
		return(m_PaceMember.location + (GetFormationDistance() * normal(pawn.location - m_PaceMember.location)));
	}

	function EngageLadderIfNeeded(R6LadderVolume aVolume)
	{
		if(m_TargetLadder == none)
			return;

		// engage ladder only if pace member is on the other side of the ladder
		if(!PawnIsOnTheSameEndOfLadderAsMember(m_PaceMember, aVolume))
			m_TeamManager.InstructTeamToClimbLadder(aVolume, true, m_pawn.m_iId);		
	}

Begin:   
	if(m_PaceMember == none)
	{
		#ifdefDEBUG	if(bShowLog) log("		PROBLEM : m_PaceMember == none, m_TeamLeader="$m_TeamLeader$" m_TeamManager="$m_TeamManager);	#endif
		if((m_TeamLeader != none) && (m_TeamManager != none))
			m_PaceMember = m_TeamManager.m_Team[m_pawn.m_iId-1];
	}

    m_TeamManager.SetFormation(self); 
    SetTimer(1.0, true);  // add check to determine whether this member will actually be facing backward    

	// make sure rainbow is not moving around with a gadget in his hands...
	VerifyWeaponInventory();
	EnsureRainbowIsArmed();

	// change to secondary if carrying a sniper rifle
	if(!m_pawn.IsStationary() && SniperChangeToSecondaryWeapon())
			Sleep(0.5);	

Moving:  
	// check if we need to reload
	if(NeedToReload())
		RainbowReloadWeapon();
	
    if (m_bIsCatchingUp)
        m_bIsCatchingUp = false;  

	if((m_PaceMember == m_TeamLeader) && m_TeamLeader.m_bIsPlayer)
		m_TeamManager.SetTeamState(TS_Following);

	// check if we need to reorganize (i.e. if this pawn is wounded...)
	if(m_bReorganizationPending)
		ReorganizeTeamAsNeeded();

	m_vTargetPosition = GetNextTargetPosition();
	//  the new last condition was added to handle the crouch <--> uncrouch problem...  
	//  use an adjustment of 35 units because MoveToward() may be imprecise, usually up to the size of the collision radius of the pawn.
    if(RainbowShouldWait())
	{
		pawn.acceleration = vect(0,0,0);		
        if(!m_bAlreadyWaiting) 
        {
			// reset the wait counter...        
            m_iWaitCounter=0;   
			m_pawn.ResetBoneRotation();
			m_pawn.StopPeeking();	
			EnsureRainbowIsArmed();

            // last member should be looking backwards when in wait... (except if team is prone)
			if((m_ePawnOrientation == PO_Back) && !m_bIsMovingBackwards && !pawn.m_bIsProne)
            {
				// if last member needs to turn around, play turning animation...	
				sleep(0.2);
				m_bIsMovingBackwards = true;
				SetLocation(pawn.location - 2*(m_PaceMember.location - pawn.location));
                focus = self;
            }

			m_bAlreadyWaiting = true;
        }

        if(VSize(m_TeamLeader.velocity) == 0) 
        {			
            if((m_iWaitCounter > 6) && !m_TeamManager.m_bTeamIsClimbingLadder) 
            {
				if(SniperChangeToPrimaryWeapon())
					FinishAnim(m_pawn.C_iWeaponRightAnimChannel);

				if(!pawn.bIsCrouched && !pawn.m_bIsProne)
				{
					// wait crouching... 
					m_pawn.StopPeeking();
					pawn.bWantsToCrouch = true;
					Sleep(0.2); // to give enough time for the startCrouch to take place (performPhysics)
				}
            }            
        }	            
        Sleep(0.2);       
        goto('Moving');
    } 

	// TODO : if this member was previously waiting (and the separation is large enough), speed up to catch up...
    m_vPreviousPosition = m_vTargetPosition; 

	// - wait animation is now always playing in channel 0
    if(m_bAlreadyWaiting) 
	{
		m_pawn.StopPeeking();
		sleep(0.2);

		// change to secondary if carrying a sniper rifle
		if(SniperChangeToSecondaryWeapon())
			Sleep(0.5);			//FinishAnim(m_pawn.C_iWeaponRightAnimChannel ); 
	}
	m_bAlreadyWaiting = false;

    // to prevent an npc from running into a wall....
    // if targetPosition is not viewable (cannot be attained) NPC may be lagging too far behind...     
	if(!CanWalkTo(m_vTargetPosition) && !PointReachable(m_vTargetPosition))	     
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" Cannot reach PaceMember, so goto Blocked: m_PaceMember="$m_PaceMember);		#endif
		goto('Blocked');
	}
	if(m_PaceMember == m_TeamLeader)
    {
        m_TeamManager.TeamIsSeparatedFromLead(false);		
		m_TeamManager.TeamIsRegroupingOnLead(false);
    }
    
    if((m_ePawnOrientation != PO_Back) || pawn.m_bIsProne || m_PaceMember.m_bIsProne) 
    {         
		m_bIsMovingBackwards = false;
        R6PreMoveTo(m_vTargetPosition, m_vTargetPosition);
		SetLocation(m_vTargetPosition);
    }
    else
    {
        if(m_PaceMember.IsWalking() && (m_iTurn > 2) && (DistanceTo(m_PaceMember) < (GetFormationDistance()+120)))   
        {			
			m_bIsMovingBackwards = true;
            SetLocation(pawn.location - 2*(m_PaceMember.location - pawn.location));					

			// last member should run when moving backwards... (in order to keep up)			
			R6PreMoveTo(m_vTargetPosition, location, GetPace(true));
        }
        else 
        {   
			m_bIsMovingBackwards = false;
			SetLocation(m_vTargetPosition);
			if(m_PaceMember.bIsCrouched && (DistanceTo(m_PaceMember) > (GetFormationDistance()+40))) 
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, PACE_CrouchRun);	
			else
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition);			
        }
    }    

	// check for a posture change before moving...  (TOFIX : UpdatePosture is being called twice....)
	if(PostureHasChanged())
	{
		sleep(0.5);
		while(m_pawn.m_bPostureTransition)
			sleep(0.5);
	}

	MoveTo(m_vTargetPosition, self);
	if(m_eMoveToResult == eMoveTo_failed)
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" eMoveTo_Failed so goto Blocked ");	#endif
		goto('Blocked');
	}
	else
		goto('Moving');

Blocked:
	m_bIsCatchingUp = true;
	if(m_PaceMember == m_TeamLeader)
	{ 
		m_TeamManager.TeamIsRegroupingOnLead(true);
		// wait for others to catch up before continuing
		while(DistanceTo(m_TeamManager.m_Team[m_TeamManager.m_iMemberCount-1]) > 600)
			Sleep(0.5);
	}
	m_pawn.StopPeeking();
	#ifdefDEBUG	if(bShowLog) log(" pawn "$pawn$" is BLOCKED!!!!! ");	#endif	
    m_ePawnOrientation = PO_Front; 
    
	// check if we need to reload
	if(NeedToReload())
		RainbowReloadWeapon();   
	
    // if leader is very close by, do not do a findBestPathToward(), the problem may just be limited space...    
	moveTarget = FindPathToward(m_PaceMember, true); 
    if(moveTarget == none)
    {
		m_pawn.logWarning( "is at location "$pawn.location$" and there appear to be insufficient pathnodes..." );

		// try to step off...
		MoveTo(pawn.location + normal(m_PaceMember.location - pawn.location)*100);
		sleep(1.0);
		goto('Blocked'); 
    }

	if(moveTarget == m_PaceMember)
	{
		// wait for m_PaceMember to get off ladder
		while(m_PaceMember.m_bIsClimbingLadder)
			Sleep(1.0);
		EngageLadderIfNeeded(R6LadderVolume(m_TargetLadder.myLadder)); 
	}

	// check if we need to climb ladder
	m_TargetLadder = R6Ladder(moveTarget);
	if(TargetIsLadderToClimb(m_TargetLadder))
	{
		m_pawn.m_potentialActionActor = m_TargetLadder.myLadder;
		m_TeamManager.InstructTeamToClimbLadder(R6LadderVolume(m_TargetLadder.myLadder), true, m_pawn.m_iId);
	}
	else
	{
		// if this member is in front of a door and their moveTarget is the R6Door actor on the other side of the door, do a room entry
		if(NeedToOpenDoor(moveTarget))
		{  
			#ifdefDEBUG	if(bShowLog) log(self$" In front of a closed door m_pawn.m_Door="$m_pawn.m_Door$", call RainbowIsInFrontOfAClosedDoor and enter state LeadRoomEntry");	#endif
			m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door); 
			MoveToPosition(m_pawn.m_Door.location, m_pawn.m_Door.rotation);
			pawn.acceleration = vect(0,0,0);

			// prepare for a room entry...
			SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
			Sleep(1);
			GotoStateLeadRoomEntry();
		}
	}

	// if this member is using pathfinding, then they are probably trying to catch up...
	if(m_PaceMember.bIsCrouched)
		R6PreMoveToward(moveTarget, moveTarget, PACE_CrouchRun);    
	else if(m_pawn.m_eHealth==HEALTH_Wounded)
		R6PreMoveToward(moveTarget, moveTarget, PACE_Walk);    
	else
		R6PreMoveToward(moveTarget, moveTarget, PACE_Run);    

	if(moveTarget.IsA('R6Ladder'))
		pawn.bIsWalking = true;

	//moveTarget is set by FindBestPathToward()
	#ifdefDEBUG	if(bShowLog) log(pawn$" is blocked... move to m_pawn.m_Door="$m_pawn.m_Door$" m_pawn.m_Ladder="$m_pawn.m_Ladder$" MoveTarget="$moveTarget$" m_potentialActionActor="$R6Pawn(pawn).m_potentialActionActor);		#endif
    MoveToward(moveTarget);             	

    // if pawn still cannot see leader's position, stay in this block...    
    if(!CanWalkTo(m_PaceMember.location) && !ActorReachable(m_PaceMember)) 
        goto('Blocked');
    else
        goto('Moving');
}

// Right now this is being used when the player decides to relinquish control of the squad 
// to his number 2...also used when the current leader of the squad has been killed...
function Promote()
{
    m_TeamLeader = m_TeamManager.m_TeamLeader;    
    m_pawn.m_iID--;
    if(m_TeamLeader == pawn)
    {
		#ifdefDEBUG	if(bShowLog) log(pawn$" is now leading the team... PROMOTE()");		#endif
        m_pawn.ResetBoneRotation();
		m_TeamLeader = none;		
		if(m_pawn.m_bIsClimbingLadder)
			return;

		if(m_TeamManager.m_bTeamIsHoldingPosition)
			GotoState('HoldPosition');
		else
			GotoState('Patrol');
    }        
    else
    {
		#ifdefDEBUG if(bShowLog) log(pawn$" is now following in position ="$m_pawn.m_iId);	#endif
        if(!m_pawn.m_bIsClimbingLadder && !IsInState('RoomEntry'))
		{
			if(m_TeamManager.m_bTeamIsHoldingPosition)
				GotoState('HoldPosition');
			else
				GotoState('FollowLeader');
		}
    }        
}

function Tick(FLOAT fDeltaTime)
{
	local  vector	vDirection;
	local  rotator	rDirection;
	
    Super.Tick(fDeltaTime);

    if(pawn == none)
        return;

	if(enemy != none)
		SetGunDirection(enemy);	
	else if(m_bAimingWeaponAtEnemy && m_pawn.m_fFiringTimer == 0)	// use m_fFiringTimer (1.5sec) to reduce weapon snapping
		SetGunDirection(none);

	if((m_TeamLeader != none) && (m_TeamManager != none) && m_pawn.m_iId != 0)
		m_PaceMember = m_TeamManager.m_Team[m_pawn.m_iId-1];
}

//==================================================================================================//
//                                 DEBUG STATES & FUNCTIONS                                         //
//==================================================================================================//

//==========================================================//
//				   -- state WAITFORGAMETOSTART --		    //
//==========================================================//
auto state WaitForGameToStart
{ 
ignores SeePlayer, HearNoise, NotifyBump;

#ifdefDEBUG
    function BeginState()   {	if(bShowLog) log(self$" entered state WaitForGameToStart...");   }
    function EndState()		{	if(bShowLog) log(self$" exited state WaitForGameToStart...");	}
#endif

Begin:
    Sleep(0.5);
	if(Level.Game.m_bGameStarted && nextState != '')
	{
		if(m_pawn.m_iId == 0)
			Sleep(1.0);
		GotoState(nextState);
	}
    else
		Goto('Begin');
} 

//==============================//
// -- state TESTBONEROTATION -- //
//==============================//
state TestBoneRotation
{ 
Begin:
    Sleep(3); 
    Goto('Begin');
}

state WatchPlayer
{
	function BeginState()
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" has entered state WatchPlayer....");	#endif
		focus = none;
	}

	function EndState()
	{
		#ifdefDEBUG	if(bShowLog) log(pawn$" has exited state WatchPlayer....");		#endif
		m_pawn.R6ResetLookDirection();
		Enable('SeePlayer');
	}
 
Begin:
	m_pawn.r6LoopAnim( 'StandSubGunHigh_nt' );
Wait:
	Sleep(1);
	Goto('Wait');
}

defaultproperties
{
     m_bUseStaggeredFormation=True
     m_bIndividualAttacks=True
     m_fAttackTimerRate=0.500000
     m_fFiringAttackTimer=0.200000
     bIsPlayer=True
}
