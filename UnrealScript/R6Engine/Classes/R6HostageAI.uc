//=============================================================================
//  R6HostageAI.uc : This is the AI Controller class for all hostages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//=============================================================================

class R6HostageAI extends R6AIController
    native;

import class R6HostageMgr;

struct OrderInfo
{
    // **** if modified, update this struct in r6engine.h ****
    var bool           m_bOrderedByRainbow;
    var R6Pawn         m_pawn1;         // the pawn involved in the order
    var R6Hostage.eHostageOrder  m_eOrder;        // the order
    var float          m_fTime;         // the game level time
    var Actor          m_actor;
    // **** if modified, update this struct in r6engine.h ****
};


var       R6Hostage             m_pawn;                     // to get away from copyinh R6Hostage(pawn)
var       R6HostageMgr          m_mgr;
var       R6HostageVoices       m_VoicesManager;

var       bool                  m_bForceToStayHere;         // true when the rainbow tell him to stay here 
var       bool                  m_bRunningToward;           // true if running toward the group. used in FollowingPawn state
var       bool                  m_bRunToRainbowSuccess;     // true when in succeeded (used in Guarded_runTowardRainbow)
var       INT                   m_iNotGuardedSince;         // time since the hostage is no longer guarded
var       INT                   m_iLastHearNoiseTime;       // last hear noise detected

var       R6Pawn                m_pawnToFollow;             // run toward, follow this pawn
var       bool                  m_bStopDoTransition;        // in follow mode, we may have to stop completly to do a transition

var const INT                   c_iDistanceMax;             // distance max from someone before catching up 
var const INT                   c_iDistanceCatchUp;         // when catching up, the hostage will stop at this min distance
var const INT                   c_iDistanceToStartToRun;    // if far from the group, start to run to catch up
var       bool                  m_bNeedToRunToCatchUp;      // set to true when c_iDistanceToStartToRun is reached
var       bool                  m_bSlowedPace;              // true when following someone walking in reverse
var       bool                  m_bFollowIncreaseDistance;  //
var       bool                  m_bLatentFnStopped;     // used in state code: true when the we manually stop the latent function 

var       RandomTweenNum        m_AITickTime;           // frequence to tick the AI Timer. m_fMin is used for quick AI update in the state code


var       R6Pawn                m_lastSeenPawn;

var       INT                   m_iPlayReaction1;       // play reaction: used to desynchronis hostage reaction to threat
var       INT                   m_iPlayReaction2; 

var       INT                   m_iWaitingTime;         // Used in patrol when waiting at a node or when freed
var       INT                   m_iFacingTime;          // Used in patrol when waiting at a node
var       INT                   m_lastUpdatePaceTime;   // Used in following pawn

var       name                  m_threatGroupName;      // group name used for the processing threat
var R6HostageMgr.ThreatInfo     m_threatInfo;           // info on the current threat of the civilian
var R6Hostage.EStartingPosition m_eTransitionPosition;  // position to go when doing a transition
var vector                      m_vReactionDirection;   // 3d point where the hostage looked/focused when reacted to SeePlayer in Guarded state

var OrderInfo                   m_aOrderInfo[2];        // list of order queued (used by the order system
var INT                         m_iNbOrder;             // number of order in the queue

var const INT                   c_iCowardModifier;      // personnality modifier
var const INT                   c_iNormalModifier;      // personnality modifier
var const INT                   c_iBraveModifier;       // personnality modifier
var const INT                   c_iWoundedModifier;     // personnality modifier
var const INT                   c_iGasModifier;         // personnality modifier

var const INT                   c_iEnemyNotVisibleTime;         // min time before stopping when running away from an enemy
var const INT                   c_iCautiousLastHearNoiseTime;   // if no noise is hear, stay cautious for this length of time
var       RandomTweenNum        m_RunForCoverMinTween;   // time allowed to run for cover before starting to be aware of what's going on
var       RandomTweenNum        m_scareToDeathTween;   

var       bool                  m_bDbgIgnoreThreat;     // debug: ignore threat
var       bool                  m_bDbgIgnoreRainbow;

var       name                  m_runForCoverStateToGoOnFailure;
var       name                  m_runForCoverStateToGoOnSuccess;
var       actor                 m_runAwayOfGrenade; // used when Enemy can't be used (ie: for grenade)
var const INT                   c_iRunForCoverOfGrenadeMinDist;

var       RandomTweenNum        m_stayBlindedTweenTime;
var       name                  m_reactToGrenadeStateToReturn;

var       R6Terrorist           m_terrorist;          // terroriste with who's interacting with
var       R6Pawn                m_escort;             // pawn who escortedvar       

var       vector                m_vMoveToDest;                  // destination

var       Actor                 m_pGotoToExtractionZone;

var       bool                  m_bDbgRoll;
var       INT                   m_iDbgRoll; 
var       INT                   m_iRandomNumber;

// used in state code 
var rotator     m_rotator;
var bool        m_bool;
var vector      m_vectorTemp;
var float       m_float;
var name        m_name;


var bool bThreatShowLog;  
 
//MissionPack1 // MPF1
var class<R6EngineWeapon> DefaultWeaponClass;
var R6EngineWeapon DefaultWeapon;
var PathNode m_pCoverNode;
var array<PathNode> m_pListOfCoverNodes;

struct PlaySndInfo
{
    var INT     m_iLastTime;        // last time the sound was played
    var INT     m_iInBetweenTime;   // time to wait before playing again the sound
};

var PlaySndInfo m_aPlaySndInfo[12];
var BOOL        m_bFirstTimeClarkComment;

const C_iKeepDistanceFromPawn = 105;

event PostBeginPlay()
{
    local INT i; 

    Super.PostBeginPlay();

    m_mgr = R6HostageMgr( level.GetHostageMgr() );

    assert( arrayCount(m_aPlaySndInfo) >= m_mgr.HSTSNDEvent_Max );

    for ( i = 0; i < arraycount(m_aPlaySndInfo); i++ )
    {
        m_aPlaySndInfo[i].m_iInBetweenTime = 1;
    }
    m_aPlaySndInfo[ m_mgr.HSTSNDEvent_SeeRainbowBaitOrGoFrozen ].m_iInBetweenTime = 5;
    m_aPlaySndInfo[ m_mgr.HSTSNDEvent_HearShooting             ].m_iInBetweenTime = 2;

}

/////////////////////////////////////////////////////////////////////////
// Possess: once the pawn is possed, initialized the controller 
// - inherited
function Possess(Pawn aPawn)
{
    local INT i;

    Super.Possess(aPawn);

    m_pawn = R6Hostage(pawn);

    // Set the manager
    m_VoicesManager = R6HostageVoices(R6AbstractGameInfo(level.game).GetHostageVoicesMgr(Level.m_eHostageVoices, m_pawn.bIsFemale));

    if ( GetStateName() != 'Configuration' )
        GotoState( 'Configuration' );
}

//------------------------------------------------------------------
// Tick
//	
//------------------------------------------------------------------
function Tick(FLOAT fDeltaTime)
{
    Super.Tick( fDeltaTime );

    if ( m_iNbOrder > 0 )
    {
        Order_Process();
    }
}


//------------------------------------------------------------------
//	auto state Configuration
//------------------------------------------------------------------
auto state Configuration
{
    ignores SeePlayer, HearNoise;

    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) log( name@ "[" @getStateName()@ "|None] : entered *STATE* Configuration"); #endif
    }

    function EndState()
    {
        m_threatGroupName = GetThreatGroupName();
        m_iNotGuardedSince = 0;
    }

begin:
    while( !(m_pawn.m_bInitFinished) )
    {
        #ifdefDEBUG if(bShowLog) logX( "waiting for initialization..."); #endif
        Sleep(1);
    }

    GetRandomTweenNum( m_pawn.m_waitingGoCrouchTween );

    GetRandomTweenNum( m_AITickTime );
    #ifdefDEBUG if (bShowLog) logX( "ai tick time: " $m_AITickTime.m_fResult ); #endif

	//Begin MissionPack1 // MPF1
	if(m_pawn.m_bPoliceManMp1)
	{
		m_pawn.m_sightRadiusTween.m_fMin=500;
		m_pawn.m_sightRadiusTween.m_fMax=1000;
	}
	//End MissionPack1

    pawn.sightRadius = GetRandomTweenNum( m_pawn.m_sightRadiusTween );
    #ifdefDEBUG if (bShowLog) logX( "sight radius: " $pawn.sightRadius ); #endif
    
    GetRandomTweenNum( m_pawn.m_updatePaceTween );
    GetRandomTweenNum( m_RunForCoverMinTween );

// debug  *********************************************************
//m_pawn.m_ePosition = POS_Stand;
//m_pawn.m_bStartAsCivilian = true;
//m_bDbgIgnoreThreat = true;
//m_bDbgIgnoreRainbow = true;
// debug  end *********************************************************

    focalPoint = m_pawn.location + vector(m_pawn.Rotation);

    if ( m_pawn.m_bStartAsCivilian )
    {
        CivInit();
    }
    else
    {
        m_pawn.SetStandWalkingAnim( eStandWalkingAnim_scared, true );

        if ( IsGuarded( true ) )
        {
            SetPawnPosition( m_pawn.m_ePosition );    // force to have the default position

            while ( !Level.Game.m_bGameStarted )
            {
                Sleep( 0.5 );
            }

            SetStateGuarded( m_pawn.m_ePosition, m_mgr.HSTSNDEvent_None );
        }
        else
        {
            // set state and position, but no SetTransitionTo
            setFreed( true );
            SetPawnPosition( POS_Crouch );

            while ( !Level.Game.m_bGameStarted )
            {
                Sleep( 0.5 );
            }

            GotoState( 'Freed' );
        }
    }
    
}



//------------------------------------------------------------------
// Died: called when the pawn is declared dead 
//------------------------------------------------------------------
function PawnDied()
{
    // if he was following, he will be removed from the escorted list
    StopFollowingPawn( false );

    if ( m_pListOfCoverNodes.Length > 0 )
        m_pListOfCoverNodes.Remove( 0, m_pListOfCoverNodes.Length );

    Super.PawnDied();
}

//------------------------------------------------------------------
// setFreed: freed an hostage. If he was a bait, he'll become a PERSO_Normal
//	
//------------------------------------------------------------------
function SetFreed( bool bFreed )
{
    #ifdefDEBUG if (bShowLog) logX( "setFreed: " $bFreed ); #endif

    m_pawn.m_bFreed = bFreed;

    m_bIgnoreBackupBump = false; // reset it
    if ( m_pawn.m_bFreed )
    {
        m_pawn.setFrozen( false );
        m_iNotGuardedSince = 0;
        m_iLastHearNoiseTime = 0;
    }
    else
    {
        //m_pawn.m_bCivilian = false;//MissionPack1 // MPF1
    }

    // if freed and a bait, the hostage will never be a bait for the rest of the game
    if ( m_pawn.m_bFreed && m_pawn.m_ePersonality == HPERSO_Bait )
    {
         m_pawn.m_ePersonality = HPERSO_Normal;
    }
}

//------------------------------------------------------------------
// SetPawnPosition
//	
//------------------------------------------------------------------
function SetPawnPosition( R6Hostage.EStartingPosition ePos )
{
    // if the default is a random pos, choose one
    if ( ePos == POS_Random )
    {
        if ( rand( 100 ) <= 50 )
        {
            ePos = POS_Kneel;
        }
        else
        {
            ePos = POS_Stand;
        }
    }

    m_pawn.m_ePosition = ePos;

    switch ( ePos )
    {
    case POS_Crouch:       m_pawn.gotoCrouch(); 
        break;

    case POS_Kneel:        m_pawn.gotoKneel();
        break;
    
    case POS_Foetus:       m_pawn.gotoFoetus(); 
        break;

    case POS_Prone:        m_pawn.gotoProne(); 
        break;

    default:
        m_pawn.gotoStand();
    }

    // logX( "SetPawnPosition: " $m_pawn.GetStateName()$ " ePos: " $ePos );
}

//------------------------------------------------------------------
// SetPace: set the pace and adjust it if wounded
//	
//------------------------------------------------------------------
function SetPace( R6Pawn.eMovementPace ePace )
{
	// if forced to stay in position
    if ( pawn.m_bTryToUnProne )
    {
		ePace = PACE_Prone;
    }
	else if ( pawn.bTryToUncrouch )
    {
        // if already running, 
        if ( m_pawn.m_eMovementPace == PACE_CrouchRun || ePace == PACE_CrouchRun ) 
        {
            ePace = PACE_CrouchRun;
        }
        else
        {
            ePace = PACE_CrouchWalk;
        }
    }
    
    m_pawn.m_eMovementPace = ePace;

    
    CheckPaceForInjury( m_pawn.m_eMovementPace ); 
}



//==============================================================
// SetStateGuarded: set the default value, his starting position 
//                  (kneel, foetus) of the pawn and set to Guarded
//                  state
function SetStateGuarded( R6Hostage.EStartingPosition ePos, int iHstSndEvent )
{
    if ( iHstSndEvent != m_mgr.HSTSNDEvent_None )
    {
        ProcessPlaySndInfo( iHstSndEvent );
    }
    
    ResetThreatInfo( "SetStateGuarded" );
    m_pawn.setFrozen( false );
    m_eTransitionPosition = ePos;
    gotoState( 'Guarded' );
}


//------------------------------------------------------------------
// SetStateFollowingPawn: set values for SetStateFollowingPawn and go
//	to that state
//------------------------------------------------------------------
function SetStateFollowingPawn( R6Pawn runTo, bool bFreed, int iHstSndEvent )
{
    if ( iHstSndEvent != m_mgr.HSTSNDEvent_None )
    {
        ProcessPlaySndInfo( iHstSndEvent );
    }

    setFreed(bFreed);
    m_pawnToFollow = R6Rainbow(runTo).Escort_GetPawnToFollow( true );
    m_bRunningToward = true;

    SetThreatState( 'FollowingPawn' );
    gotoState( m_threatInfo.m_state );
}


///////////////////////////////////////////////////////////////////////////
// Roll a random number adjusted by the personnality
function INT Roll(INT iMax)
{
    local INT iRoll;

    iRoll = Rand(iMax)+1;

    switch(m_pawn.m_ePersonality)
    {
        case HPERSO_Coward:
            iRoll += c_iCowardModifier;
            break;

        case HPERSO_Normal:
            iRoll += c_iNormalModifier;
            break;
        
        case HPERSO_Brave:
            iRoll += c_iBraveModifier;
            break;
    }

    if ( m_pawn.m_eHealth == HEALTH_Wounded ) 
    {   
        iRoll -= c_iWoundedModifier;
    }

    if ( (m_pawn.m_eEffectiveGrenade == GTYPE_TearGas) || (m_pawn.m_eEffectiveGrenade == GTYPE_FlashBang) )
    {
        iRoll -= c_iGasModifier;
    }

    if ( m_bDbgRoll )
    {
        log( "m_bDbgRoll: " $m_iDbgRoll );
        iRoll = m_iDbgRoll; 
    }

    iRoll = FClamp( iRoll, 0, 100 );

    return iRoll;
}

//------------------------------------------------------------------
// GetRandomTurn90: return a random turn left or right 90'
//	
//------------------------------------------------------------------
function Rotator GetRandomTurn90()
{
    local Rotator rRot;

    rRot = Pawn.Rotation;
 
    if ( rand(100) < 50 )
    {
        rRot.Yaw -= 16383;
    }
    else
    {
        rRot.Yaw += 16383;
    }

    return rRot;
}


/////////////////////////////////////////////////////////////////////////////
// CanReturnToNormalState: return true if the hostage can return to a normal 
//                         state. 
function bool CanReturnToNormalState()
{
    local R6Rainbow     aR6Rainbow;
    local R6Pawn        p;
    local INT           numFriend;
    local INT           numEnemy;

    numFriend = 0;
    numEnemy = 0;
    
    // visible actors from my location and based on my sight radius
    foreach VisibleCollidingActors( class'R6Pawn', p, pawn.sightRadius, m_pawn.location )
    {
        if ( m_pawn.IsEnemy(p) && p.isAlive() )
        {
            if ( p.isFighting() || p.m_bIsKneeling )

                return false;

            numEnemy++;
        }

        if ( m_pawn.IsFriend(p) && p.isAlive() )
        {
            if ( p.isFighting() )
                return false;

            numFriend++;            
        }
    }

    // check when the last time we heard a noise
    if ( Level.TimeSeconds < m_iLastHearNoiseTime + c_iCautiousLastHearNoiseTime )
    {
        return false;
    }

    // no more rainbow are visible OR no more active terrorist, can return to a normal state
    if ( numFriend == 0 || numEnemy == 0 )
    {
        return true;
    }
 
    return false;
}

//------------------------------------------------------------------
// ReturnToNormalState: when return to normal state he still could
//	be guarded or not
//------------------------------------------------------------------
function ReturnToNormalState( OPTIONAL bool bNoTimer )
{
    if ( IsGuarded( bNoTimer ) )
    {
        // go to kneel, not standing because transition looks weird
        // if in foetal, than standing and let's say the rainbow reappears,
        // the hostage will go standing up in 1 frame, than go foetal... looks to weird.
        SetStateGuarded( POS_Kneel, m_mgr.HSTSNDEvent_None );
    }
    else
    {
        GotoState( 'Freed' );
    }
}

//------------------------------------------------------------------
// SeePlayer: 
//	- inherited
//------------------------------------------------------------------
function SeePlayer( Pawn p )
{
    local R6Pawn seen;

    if ( m_bDbgIgnoreThreat )
        return;

    seen = R6Pawn(p);

    if ( rand(2) == 0 )
    {
        return;
    }

    if ( seen == none )
        return;

    // ignore dead or inactive
    if ( !seen.isAlive() || seen.m_bIsKneeling )
        return;

#ifdefDEBUG    
    if ( m_pawn.IsFriend(seen) )
    {
        if ( m_bDbgIgnoreRainbow )
            return;

        if ( m_pawn.m_bDontSeePlayer && seen.m_bIsPlayer )
            return;
    }
#endif

    if ( m_pawn.m_bCivilian )
    {   // MPF1
		m_lastSeenPawn = none;//MissionPack1
		return;

    }
    else if ( m_pawn.m_bFreed )
    {
        // if see a friend AND there's not already a pawn focused (gives priority to Terrorist)
        if ( m_pawn.IsFriend(seen) && m_lastSeenPawn == none )
        {
            m_lastSeenPawn = seen;
        }
        else if ( m_pawn.IsEnemy(seen) )
        {
            m_lastSeenPawn = seen;   
        }
    }
    else
    {
        if( m_lastSeenPawn != seen && m_pawn.IsFriend(seen) )
            m_vReactionDirection = seen.Location;

        m_lastSeenPawn = seen;
    }
}

//------------------------------------------------------------------
// SeePlayerMgr: called once in a while to manage the lastSeenPawn
//	This mgr allows to have some delay in the AI behavior of hostage.
//  So they don't react all at the same time on a SeePlayer
//------------------------------------------------------------------
function SeePlayerMgr()
{
    if ( !m_lastSeenPawn.isAlive() )
        return;

    ProcessThreat( m_lastSeenPawn, NOISE_None );

    m_lastSeenPawn = none;
}

//------------------------------------------------------------------
// HearNoise: HearNoise used when the hostage is freed, civilian and 
//  guarded by terro.
//	- inherited
//------------------------------------------------------------------
event HearNoise( float fLoudness, Actor noiseMaker, ENoiseType eType, optional ESoundType ESoundType )
{
    local Actor aGrenade;

    if( m_pawn.m_bDontHearPlayer && R6Pawn(NoiseMaker.Instigator).m_bIsPlayer )
        return;

    if ( m_bDbgIgnoreThreat )
        return;

    // if sound IS NOT a threat or grenade
    if ( m_pawn.m_bClassicMissionCivilian )
    {
        if ( !(eType == NOISE_Threat || eType == NOISE_Grenade || eType == NOISE_Dead ) || eType == NOISE_Investigate && ESoundType == SNDTYPE_Gunshot )
            return;
    }
    else
    {
        if ( !(eType == NOISE_Threat || eType == NOISE_Grenade || eType == NOISE_Dead ) )
            return;
    }

    if ( IsInTemporaryState() )
        return;

    m_iLastHearNoiseTime = level.TimeSeconds;

    //  shouldn't be like seeplayer that sometimes is not called / updated
    //  like when we are in a transition state... 
    ProcessThreat( noiseMaker, eType );
}

//------------------------------------------------------------------
// CanConsiderThreat: once a threat is detected and may have
//	an exception, this is where we check if the threat can be
//  consired by the R6hostageMgr::GetThreatInfoFromThreat
//------------------------------------------------------------------
function bool CanConsiderThreat( R6Pawn aPawn, Actor aThreat, name considerThreat )
{
    if (        considerThreat == 'IsEnemySound' )
    {
        return m_pawn.IsEnemy( aPawn );
    }
    else if (   considerThreat == 'CanSeeFriend' )
    {
        return !m_bForceToStayHere; // if forces to stay here, you don't see friend
    }

    m_pawn.LogWarning( "CanConsiderThreat: failed to find the threat=" $considerThreat );
    return false;
}

//------------------------------------------------------------------
// GetRainbowWhoEscortThisPawn: get the rainbow who will escort
//------------------------------------------------------------------
function R6Rainbow GetRainbowWhoEscortThisPawn( R6Pawn follow )
{
    if ( follow.m_ePawnType == PAWN_Rainbow )
    {
        return R6Rainbow( follow ).Escort_GetPawnToFollow( false );
    }
    else if ( follow.m_ePawnType == PAWN_Hostage )
    {
        return R6Hostage(follow).m_escortedByRainbow;
    }

    m_pawn.logWarning( "GetRainbowTeamFromPawn unknow type of pawn" $follow );
    return none;
}

//------------------------------------------------------------------
// Order_GotoExtraction
//	
//------------------------------------------------------------------
function Order_ProcessGotoExtraction( Actor aZone )
{
    #ifdefDEBUG if(bShowLog) logX( "Order_GotoExtraction: " $aZone.name ); #endif

    if ( m_pawn.m_bExtracted || !m_pawn.IsAlive() )
        return;
    
    ResetThreatInfo( "GotoExtraction" );
    m_pGotoToExtractionZone = aZone;
    m_vMoveToDest = aZone.Location;
    setFreed( true );
    m_bIgnoreBackupBump = true; // we don't want hostage to be disturbed by bump

    GotoState( 'GotoExtraction' );
}

//------------------------------------------------------------------
// Order_ProcessFollowMe: informs the team or has received the order to follow
//  the rainbow team. The hostage is added in the escorted team
//  which will set is m_pawnToFollow. 
//------------------------------------------------------------------
function Order_ProcessFollowMe( R6Pawn follow, bool bOrderedByRainbow )
{
    local R6Rainbow rainbowToFollow;

    #ifdefDEBUG if(bShowLog) logX( "Order_ProcessFollowMe: " $follow.name ); #endif

    ResetThreatInfo( "ProcessFollowMe" );
    //m_pawn.m_bCivilian = false; MissionPack1  // MPF1

    m_pawn.SetStandWalkingAnim( eStandWalkingAnim_scared, true );

    if (  m_pawn.m_ePersonality == HPERSO_Bait )
    {
        setFreed( true );
    }

    rainbowToFollow = GetRainbowWhoEscortThisPawn( follow );
    
    // remove me from the old rainbow list
    if ( m_pawn.m_escortedByRainbow != none && rainbowToFollow != m_pawn.m_escortedByRainbow )
    {
        m_pawn.m_escortedByRainbow.Escort_RemoveHostage( m_pawn, true );            
    }
    m_pawn.m_escortedByRainbow = rainbowToFollow;

    // add me in the list and this will set m_pawnToFollow, if it's impossible I'll stay here
    if ( m_pawn.m_escortedByRainbow.Escort_AddHostage( m_pawn, false, bOrderedByRainbow ) )
    {
        gotoState( 'FollowingPawn' );
    }
    else
    {
        Order_ProcessStayHere( false );
    }
}

//------------------------------------------------------------------
// StopFollowingPawn: reset all info regarding following a pawn
//	
//------------------------------------------------------------------
function StopFollowingPawn( bool bOrderedByRainbow )
{
    #ifdefDEBUG if(bShowLog) logX( "StopFollowingPawn bOrderedByRainbow=" $bOrderedByRainbow ); #endif

    m_pawn.SetStandWalkingAnim( eStandWalkingAnim_default, false );

    if ( m_pawn.m_escortedByRainbow == none )
        return; 

    m_pawn.m_escortedByRainbow.Escort_RemoveHostage( m_pawn, !m_pawn.isAlive(), bOrderedByRainbow ); // no feedback if i'm not alive
    m_pawnToFollow = none;
    m_bRunningToward = false;
}

//------------------------------------------------------------------
// Order_ProcessStayHere: the hostage received the order to stay
//  here, or it informs the team that he'll stay here
//------------------------------------------------------------------
function Order_ProcessStayHere( bool bOrderedByRainbow )
{
    #ifdefDEBUG if(bShowLog) logX( "Order_ProcessStayHere bOrderedByRainbow=" $bOrderedByRainbow ); #endif

    ResetThreatInfo( "ProcessStayHere" );
    StopMoving();

    m_bForceToStayHere = true;
    StopFollowingPawn( bOrderedByRainbow );
    
    GotoState( 'Freed' );
}

//------------------------------------------------------------------
// DispatchOrder: dispatch order for a eHostageCircumstantialAction
//------------------------------------------------------------------
function DispatchOrder( INT iOrder, OPTIONAL R6Pawn orderFrom )
{
    switch( iOrder )
    {
        case m_pawn.eHostageOrder.HOrder_ComeWithMe:
            Order_FollowMe( orderFrom, true );
            break;

        case m_pawn.eHostageOrder.HOrder_StayHere:  
            Order_StayHere( true );
            break;
        
        default:
            m_pawn.logWarning( "unknow eHostageCircumstantialAction " $iOrder );
    }
}


//------------------------------------------------------------------
// CanStopMoving: return true if I should stop moving. When moving
//	the hostage will try to catch up the group 
// bCheckIfShouldMove: when true, the pawn is asking if he needs to move
//------------------------------------------------------------------
function bool CanStopMoving( bool bCheckIfShouldMove )
{
    local R6HostageAI hostageAI;
    local INT iDistance;

    // the pawn might be dead
    if ( m_pawnToFollow == none )
        return true;

    if ( bCheckIfShouldMove )
    {
        iDistance = c_iDistanceMax;
    }
    else
    {
        iDistance = c_iDistanceCatchUp;
    }

    if ( m_bFollowIncreaseDistance || m_bSlowedPace || m_pawnToFollow.m_bIsClimbingLadder )
    {
        iDistance += iDistance/2;
    }

    // distance maximum is reached
    if ( VSize( m_pawnToFollow.location - pawn.Location ) < iDistance )
    {
        return true;
    }
    
    if ( m_pawnToFollow.m_eMovementPace == PACE_Prone )
    {
        if ( VSize( m_pawnToFollow.m_collisionBox.location - pawn.Location ) < iDistance )
        {
            return true;
        }
    }

    // if i'm the front guy
    if ( m_pawn.m_escortedByRainbow != none && m_pawn.m_escortedByRainbow.m_aEscortedHostage[0] == m_pawn )
    {
        if ( bCheckIfShouldMove )    
        {
            // update the list in case i'm no longer the front guy
            m_pawn.m_escortedByRainbow.Escort_UpdateCloserToLead();
    
            // if i'm still the closiest to front rainbow
            if ( m_pawn.m_escortedByRainbow.m_aEscortedHostage[0] == m_pawn )
            {
                // if(bShowLog) logX( "ShouldMove: catch up front guy" );
                return false; // catch up!
            }
            else
            {
                // if(bShowLog) logX( "ShouldMove: DON'T catch up front guy" );
                return true; // don't have to move
            }
        }
        else
        {
            return false;
        }
    }

    
    hostageAI = R6HostageAI(m_pawnToFollow.controller);
    if ( (hostageAI != none && hostageAI.moveTarget != none)    // if my front Pawn is moving, I should not stop
        || (bCheckIfShouldMove && !m_bRunningToward ) )         // OR (if checkShouldMove AND i'm running)
    {
        return false;
    }
    // if i'm close to someone
    else if ( m_pawn.m_escortedByRainbow != none &&
              m_pawn.m_escortedByRainbow.Escort_IsPawnCloseToMe( m_pawn, iDistance ) )
    {
        return true;
    }

    return false;
}


//------------------------------------------------------------------
// IsInCrouchedPosture: return truen so a crouchwalk anim will be played
//	when the pawn is bumped
//------------------------------------------------------------------
function bool IsInCrouchedPosture()
{
  return (    super.IsInCrouchedPosture() 
             || m_pawn.m_ePosition == POS_Kneel
             || m_pawn.m_ePosition == POS_Foetus 
           );
}

/////////////////////////////////////////////////////////////////////////
// IsGuarded: return true if the hostage is or can be guarded
//            Guarded here means that the hostage can see a terrorist. 
//            
//            *** costly function ***
function bool IsGuarded( OPTIONAL bool bNoTimer, OPTIONAL bool bMustSeeMe )
{
    local R6Pawn p;

    if ( m_pawn.m_ePersonality == HPERSO_Bait )
        return true;

    // logX( "IsGuarded: bNoTimer=" $bNoTimer$ " bMustSeeMe=" $bMustSeeMe );

    // visible actors from my location and based on my sight radius
    foreach VisibleCollidingActors( class'R6Pawn', p, pawn.sightRadius, m_pawn.location )
    {
        // if the pawn is still alive and active and not surrender
        if ( m_pawn.IsEnemy(p) && p.isAlive() && !p.m_bIsKneeling )
        {
            if ( bMustSeeMe )
            {
                if ( R6AIController( p.controller ) != none )
                {
                    if ( R6AIController( p.controller ).CanSee( pawn ) )
                    {
                        m_iNotGuardedSince = 0; // reset timer
                        return true;
                    }
                }
                else if ( CanSee( p ) ) // for human player. If I can see them
                {
                    m_iNotGuardedSince = 0; // reset timer
                    return true;
                }
            }
            else
            {
                m_iNotGuardedSince = 0; // reset timer
                return true;
            }
        }
    }

    // dont check the timer m_iNotGuardedSince
    if ( bNoTimer )
    {
        return false;
    }

    // if timer not yet started
    if ( m_iNotGuardedSince == 0 )
    {
        m_iNotGuardedSince = Level.TimeSeconds;
        GetRandomTweenNum( m_pawn.m_stayCautiousGuardedStateTime );
        #ifdefDEBUG if(bShowLog) logX( "guarded until " $(m_iNotGuardedSince + m_pawn.m_stayCautiousGuardedStateTime.m_fResult) ); #endif
    }
    // timer countdown... 
    else if ( m_iNotGuardedSince + m_pawn.m_stayCautiousGuardedStateTime.m_fResult < Level.TimeSeconds )
    {
        return false;
    }
    
    return true;
}


//------------------------------------------------------------------
// Guarded: default and base state for freed, prone, foetus, in shock,
//	frozen.
//------------------------------------------------------------------
state Guarded
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX("beginState"); #endif

        if ( m_pawn.m_escortedByRainbow != none ) // needed if debbuging
            StopFollowingPawn( false );

        // if he was running or following a pawn, it forces the hostage to stop
        StopMoving();
        Focus = none; 
        
        focalPoint = m_pawn.location + vector(m_pawn.Rotation); // if was turning, it forces to stop turning
        
        m_vReactionDirection = vect(0,0,0);
        m_iNotGuardedSince = 0;
        m_iWaitingTime = 0;

        setFreed( false );
        m_pawn.setFrozen( false );

        // if not kneeling or not having hands raised up
        if ( !(m_pawn.isKneeling() || m_pawn.isStandingHandUp()) )
        {
            SetPawnPosition( m_eTransitionPosition );   
        }
        
        SetTimer( 0.1, true );
        
        // if standing and not isStandingHandUp, force to raise hands now
        if ( m_pawn.m_ePosition == POS_Stand && !m_pawn.isStandingHandUp() )
        {   
            m_pawn.PlayWaiting();
        }

        m_iPlayReaction1 = 0; // used to play reaction
        m_lastSeenPawn = none;
        m_bForceToStayHere = false;
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) logX("EndState"); #endif
        
        SetTimer( 0, false );
    }

   
    function Timer()
    {
        if ( m_iWaitingTime >= 20 ) // every 2 sec check if he's free
        {
            if ( !IsGuarded() ) 
            {
                GotoState( 'Freed' );
            }
            m_iWaitingTime = 0;
        }
        m_iWaitingTime++;

        if ( m_lastSeenPawn != none )
            SeePlayerMgr();

        // play reaction animation
        if ( m_iPlayReaction1 != 0 )
        {
            if ( m_iPlayReaction1 >= m_iPlayReaction2 )
            {
                ProcessPlaySndInfo( m_mgr.HSTSNDEvent_HearShooting );
                m_pawn.PlayReaction();
                m_iPlayReaction1 = 0;
                m_iPlayReaction2 = 0;
            }
            else
            {
                m_iPlayReaction1++;
            }
        }
    }
}


/////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------
// Guarded_foetus: the hostage is scared and go in the foetus pos
//	
//------------------------------------------------------------------
state GoGuarded_Foetus
{
    ignores SeePlayer, HearNoise;

    function BeginState()
    {
        SetThreatState( 'Guarded_foetus' );
        ProcessPlaySndInfo(m_mgr.HSTSNDEvent_GoFoetal);
        GotoState( m_threatInfo.m_state );
    }
}

state Guarded_foetus extends Guarded
{
    ignores SeePlayer, HearNoise;
    
    /////////////////////////////////////////////////////////////////////////
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX( "beginState" ); #endif
        
        Focus = none; 
        StopMoving();

        // if not already in this pos
        if ( m_pawn.getStateName() != 'Foetus' );
            SetPawnPosition( POS_Foetus );    
    }

    /////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        if ( CanReturnToNormalState() )
        {
            GotoState( 'Guarded_foetus', 'end' );
        }
        else
        {
            GotoState( 'Guarded_foetus', 'begin' );
        }
    }

end:
    ResetThreatInfo( "foetus end" );
    SetTimer( 0, false );    // reset timer 
    
    // it helps to force to go to FREED if not guarded
    ReturnToNormalState( true );

begin:
    SetTimer( GetRandomTweenNum( m_pawn.m_stayInFoetusTime ), true );
    #ifdefDEBUG if (bShowLog) logX( " keep position for " $m_pawn.m_stayInFoetusTime.m_fResult ); #endif
}

/////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------
// Guarded_frozen : the hostage is frozen after seeing a rainbow 
//	
//------------------------------------------------------------------
state GoGuarded_frozen
{
    ignores SeePlayer, HearNoise;

    function BeginState()
    {
        ProcessPlaySndInfo(m_mgr.HSTSNDEvent_SeeRainbowBaitOrGoFrozen );
        
        GotoState('Guarded_frozen');
    }
}

state Guarded_frozen extends Guarded
{
    ignores SeePlayer, HearNoise;
    
    /////////////////////////////////////////////////////////////////////////
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX( "beginState" ); #endif
        
        StopMoving();
        Focus = none; 

        // if not yet frozen, do bleding of freeze anim
        if ( !m_pawn.m_bFrozen )
        {
            m_pawn.GotoFrozen();  // react immediatly
        }
    }

    /////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        m_pawn.setFrozen( false );
        GotoState( 'Guarded_foetus' );
    }

end:
    m_pawn.setFrozen( false );
    SetTimer( 0, false );    // reset timer 
    if ( CanReturnToNormalState() )
    {
        ReturnToNormalState();
    }
    else
    {
        gotoState( 'Guarded_foetus' );
    }
    
begin:
    SetTimer( GetRandomTweenNum( m_pawn.m_stayFrozenTime ), true );
    #ifdefDEBUG if (bShowLog) logX( " keep position for: "$m_pawn.m_stayFrozenTime.m_fResult ); #endif
}


/////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------
// Freed: freed from terrorist, In this state the hostage will surrender 
// when he will see a terrorist. When he will see a rainbow, he will
// run toward them
//------------------------------------------------------------------
state Freed 
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX( "beginState" ); #endif

        // if he was running or following a pawn, it forces the hostage to stop
        StopMoving();

        setFreed( true );
        m_lastSeenPawn = none;
        m_pawn.m_bAvoidFacingWalls = true;
        
        SetPawnPosition( POS_Crouch );
        m_iWaitingTime = GetRandomTweenNum( m_pawn.m_changeOrientationTween );
        m_iFacingTime = Level.TimeSeconds;
    }

    /////////////////////////////////////////////////////////////////////////
    function EndState()
    {
        SetTimer( 0, false );
        m_lastSeenPawn = none;
        m_iWaitingTime = 0;
        m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
    }

    /////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        if( m_iFacingTime + m_iWaitingTime < Level.TimeSeconds && !m_pawn.m_bPostureTransition )
        {
            m_iFacingTime = Level.TimeSeconds;
            m_iWaitingTime = GetRandomTweenNum( m_pawn.m_changeOrientationTween );
            ChangeOrientationTo( GetRandomTurn90() );
        }
        
        if ( m_lastSeenPawn != none )
            SeePlayerMgr();
    }
       
begin:
    // wait to be in the position crouch before being to do something else...
    while ( !(m_pawn.bWantsToCrouch && m_pawn.bIsCrouched) ) 
    {
        Sleep( 0.1 );
    }
    
    SetTimer( m_AITickTime.m_fResult, true );
}


//------------------------------------------------------------------
// SetStateFollowingPaceTransition: set the default value, his starting position 
//	
//------------------------------------------------------------------
function SetStatePaceTransition( R6Hostage.EStartingPosition ePos )
{
    m_eTransitionPosition = ePos;
    gotoState( 'FollowingPaceTransition' );
}

//------------------------------------------------------------------
// FollowingPaceTransition: stated used to allow smooth transition
//	from extrem posture (stand to prone, crouch to prone, prone to crouch
//------------------------------------------------------------------
state FollowingPaceTransition
{
    ignores NotifyBump, SeePlayer, HearNoise; 

    function BeginState()
    {
        #ifdefDEBUG if ( bShowLog ) logX( "beginState goto " $m_eTransitionPosition ); #endif
        StopMoving();
    }

begin:
    if ( m_pawn.m_bIsProne )
    {
        SetPawnPosition( POS_Crouch );
        Sleep(0.3);
        
        SetPace( PACE_CrouchWalk );

        if ( m_eTransitionPosition == POS_Stand )
        {
            SetPawnPosition( POS_Stand );
            Sleep( 0.3 );
            SetPace( PACE_Walk );
        }
    }
    else if ( m_eTransitionPosition == POS_Prone && !m_pawn.m_bIsProne )
    {
        if ( !m_pawn.bIsCrouched )
        {
            SetPawnPosition( POS_Crouch );
            Sleep(0.3);
        }

        SetPawnPosition( POS_Prone );
        Sleep(0.4);
        SetPace( PACE_Prone );
    }
    else
    {
        SetPawnPosition( m_eTransitionPosition );
    }

    R6SetMovement( m_pawn.m_eMovementPace );
    GotoState( 'FollowingPawn' );
}

//------------------------------------------------------------------
// SetMovementPace: set the current pace to be when following someone
// return true if are doing a transition thats requires to stop moving
//------------------------------------------------------------------
function bool SetMovementPace( bool bStartingToMove )
{
    local R6Pawn.eMovementPace  eOldMovementPace;
    local R6Pawn.eMovementPace  eNewMovementPace;
    local R6Pawn                follow;
    local bool                  bStopMoving;

    if ( m_pawnToFollow == none || m_pawn.m_bPostureTransition )
    {
        return false;
    }

    if ( m_bNeedToRunToCatchUp )
    {

        if ( m_pawn.m_eMovementPace == PACE_CrouchWalk || 
             m_pawn.m_eMovementPace == PACE_CrouchRun )
        {
            // if pawn i follow is not crouched and not prone, stand up
            if ( !m_pawnToFollow.bIsCrouched && !m_pawnToFollow.m_bIsProne  )
            {
                // we don't call SetStatePaceTransition( POS_Stand ) or SetPawnPosition( POS_Stand );
                // we want to stand up fastly and use the blend from crouch to stand
                m_pawn.m_ePosition = POS_Stand;
                m_pawn.setCrouch( false );
                SetPace( PACE_Run );
            }
            else if ( m_pawn.m_eMovementPace == PACE_CrouchWalk )
                SetPace( PACE_CrouchRun );
        }
        else if ( m_pawn.m_eMovementPace == PACE_Walk )
        {
            SetPace( PACE_Run );
        }
            
        return false;
    }

    if ( m_bRunningToward )
    {
        SetPace( PACE_Run );
        return false;
    }

    eOldMovementPace = m_pawn.m_eMovementPace;
    
    // if moving
    if ( moveTarget != none || bStartingToMove )
    {
        follow = m_pawnToFollow;
        m_iWaitingTime = 0;

        // make needed adjustments if leader is walking backwards or strafing... and i'm not prone
	    if ( !m_pawnToFollow.IsMovingForward() && !m_pawn.m_bIsProne )
	    {		
            if ( m_pawnToFollow.bIsWalking )
            {
			    m_bSlowedPace = true;
            }
		    else 
		    {
                follow = none; // set it to none so we don't update again his pace
			    if ( m_pawnToFollow.bIsCrouched )
			    {
				    m_bSlowedPace = true;	
                    SetPace( PACE_CrouchWalk ); 
   
			    }
			    else 
			    {
				    m_bSlowedPace = false;
                    SetPace( PACE_Walk ); 
			    }				
                
                return false; // don't stop and don't have to update anything else here
		    }	
	    }	
	    else
        {
		    m_bSlowedPace = false;
        }
    }
    // check the front hostage who leads to know what to do (ie: go prone, go crouch quicker)
    else if ( m_pawn.m_escortedByRainbow != none && 
              m_pawn.m_escortedByRainbow.m_aEscortedHostage[0] != none )
    {
        // i follow him, but can I see him?
        follow = m_pawnToFollow;

        m_iWaitingTime++;         
        if ( m_iWaitingTime >= m_pawn.m_waitingGoCrouchTween.m_fResult )
        {
            follow = none;

            // if not crouched and not prone (standing... go crouch)
            if ( !m_pawn.bIsCrouched && !m_pawn.m_bIsProne )
            {
                SetPawnPosition( POS_Crouch );
            }
        }
    }
    else
    {
        return false; // not normal, problem
    }

    if ( follow != none )
    {     // set the pace and adjust it if wounded
        SetPace( follow.m_eMovementPace ); 
    }

    // there's pace change...
    if ( eOldMovementPace != m_pawn.m_eMovementPace )
    {
        // 1- adjust extrem transition (ie: can't go prone if no crouched)
        // 1a- if wants to go prone AND not prone 
        if ( m_pawn.m_eMovementPace == PACE_Prone && !m_pawn.m_bIsProne )
        {
            SetPace( eOldMovementPace );
            SetStatePaceTransition( POS_Prone );
            return true;
        }
        // 1b- if he's prone AND wants to run, walk or go crouch
        else if ( m_pawn.m_bIsProne && m_pawn.m_eMovementPace != PACE_Prone )
        {
            if ( m_pawn.m_eMovementPace == PACE_CrouchRun || m_pawn.m_eMovementPace  == PACE_CrouchWalk )
            {
                SetPace( eOldMovementPace );
                SetStatePaceTransition( POS_Crouch );
            }
            else
            {
                SetPace( eOldMovementPace );
                SetStatePaceTransition( POS_Stand );
            }

            return true;
        }
        
        // 2- set the new pawn position
        if ( m_pawn.m_eMovementPace == PACE_CrouchWalk || m_pawn.m_eMovementPace == PACE_CrouchRun  )
        {
            SetPawnPosition( POS_Crouch );
            bStopMoving = true;
        }
        else if ( m_pawn.m_eMovementPace != PACE_Prone )
        {
            // we don't call SetPawnPosition( POS_Stand );
            // we want to stand up fastly and use the blend from crouch to stand
            m_pawn.m_ePosition = POS_Stand;
            m_pawn.setCrouch( false );
        }
        
        // 3- do I need to catch up 
        if ( m_pawn.m_eMovementPace == PACE_CrouchWalk || m_pawn.m_eMovementPace == PACE_Walk )
        {
            // if distance to start to to run is reached
            // AND not wounded (cannot run if wounded)
            if ( VSize( m_pawnToFollow.location - pawn.Location ) > c_iDistanceToStartToRun
                 && m_pawn.m_eHealth != HEALTH_Wounded )
            {
                m_bNeedToRunToCatchUp = true;

                if ( m_pawn.m_eMovementPace == PACE_CrouchWalk )
                {
                    SetPace( PACE_CrouchRun );
                }
                else 
                {
                    SetPace( PACE_Run );
                }
            }
        }

        // must be set after SetPawnPosition
        R6SetMovement( m_pawn.m_eMovementPace );

        return bStopMoving;
    }

    return false;
}



//------------------------------------------------------------------
// FollowPawnFailed
//	
//------------------------------------------------------------------
function FollowPawnFailed()
{
    ResetThreatInfo( "FollowPawnFailed" );
    Order_StayHere( false );
    ReturnToNormalState( true );
}


//------------------------------------------------------------------
// FollowingPawn: follow a pawn OR run towards a pawn.
//	if run: it will set the temporary escort team
//  if follow: every was previously set in RainbowOrdersToFollow 
//------------------------------------------------------------------
state FollowingPawn
{
    /////////////////////////////////////////////////////////////////////////
    function BeginState()
    {
		////////////////Begin MissionPack1  // MPF1
		if(m_pawn.m_bCivilian || m_pawn.m_bPoliceManMp1)
			CivInit();
		else
		{
		////////////////End MissionPack1
        #ifdefDEBUG if(bShowLog) logX( "begin. Following: " $m_pawnToFollow.name  ); #endif

        moveTarget = none;
        focus = none;
        m_lastSeenPawn = none;        

        setFreed( true );
        m_bSlowedPace = false;
        
        // cause problem after coming back from bumpbackup
        // m_pawn.m_eMovementPace = PACE_None; // force to update SetMovementPace
		}////////////////End MissionPack1
    }

    /////////////////////////////////////////////////////////////////////////
    function EndState()
    {
        #ifdefDEBUG if(bShowLog) logX( "endState" ); #endif
        setTimer( 0, false );
        focus = none; // his orientation won`t follow the FollowingPawn
    }

    /////////////////////////////////////////////////////////////////////////
    event bool NotifyBump(Actor other)
    {
        m_lastUpdatePaceTime = 0; // forces to stop moving ASAP
        m_bFollowIncreaseDistance = true;

        return Super.NotifyBump( other ); // R6AIController.NotifyBump
    }

    /////////////////////////////////////////////////////////////////////////
    // check if the AI must react differently when following of running toward a pawn
    function Timer()
    {
        local bool          bUpdateMove;
        local bool          bFound;
        local R6Pawn        p;
        local R6RainbowTeam team;
        local FLOAT         fSleep;
        local bool          bCanWalkTo;

        if ( m_lastSeenPawn != none )
            SeePlayerMgr();

        if (   m_bStopDoTransition || m_pawn.m_bPostureTransition || m_r6pawn.m_bIsClimbingLadder
            || (Physics == PHYS_Falling) || (Physics == PHYS_RootMotion) )
            return;

        // if it's time to update pace
        if ( Level.TimeSeconds - m_lastUpdatePaceTime > m_pawn.m_updatePaceTween.m_fResult )
        {
            if ( SetMovementPace( false ) )
            {
                // needs to stop and do a transition without moving
                m_bStopDoTransition = true;
                StopMoving();
                focus = none;
                return;
            }
            else
            {
                m_lastUpdatePaceTime = Level.TimeSeconds;
                GetRandomTweenNum( m_pawn.m_updatePaceTween );
            }
        }

        if ( m_pawnToFollow == none || moveTarget == none )
            return;

        bUpdateMove = false;

        // If running toward rainbow && if pawn to follow is no more 'active'
        if ( m_bRunningToward && !m_pawnToFollow.IsAlive() )
        {
            // not escorted yet, but get someone else
            m_pawnToFollow = R6Rainbow(m_pawnToFollow).Escort_FindRainbow(m_pawn);

            // not found, so no pawn to follow, stop this state
            if ( m_pawnToFollow == none )
            {
                m_bLatentFnStopped = true;
            }
            else
            {
                // fond a rainbow, but make sure who I have to follow
                m_pawnToFollow = R6Rainbow(m_pawnToFollow).Escort_GetPawnToFollow( true );
            }
            
            bUpdateMove = true;
        } 
        else
        {
            if ( CanStopMoving( false ) )
            {
                // if(bShowLog) log( "Moving::timer: STOP MOVING " $pawn.name  );
                bUpdateMove = true;
                m_bLatentFnStopped = true;
                m_lastUpdatePaceTime = Level.TimeSeconds;
                m_bNeedToRunToCatchUp = false;

                // if running toward and stop moving, we succeeded to join the rainbow
                if ( m_bRunningToward )
                {
                    m_bRunToRainbowSuccess = true;
                }
            }
            else 
            {
                // my target was changed (ie: the escort list was updated)
                if ( moveTarget.IsA('R6Pawn') && moveTarget != m_pawnToFollow )
                {
                    // if(bShowLog) log( "Moving::timer NEW pawn to follow " $pawn.name );
                    bUpdateMove = true;
                }
            } // if CanStopMoving
        } // if running toward rainbow
        
        if ( bUpdateMove )
        {
            moveTarget = none; // force to stop the moveToward and check what will be next thing 
                               // to do (stop, find the best path, run toward succeeded, move toward directly...)
        }
    } 

/////////////////////////////////////////////////////////////////
Begin:

    Sleep(RandRange(0.1,0.5)); // helps to desynchronized pawn

    // wait for transition to end
    while ( m_pawn.m_bPostureTransition ) 
        Sleep( 0.1 );

    if ( (m_bRunningToward && !m_pawn.isStanding()) 
        || m_pawn.m_ePosition == POS_Foetus 
        || m_pawn.m_ePosition == POS_Kneel
        || m_pawn.isStandingHandUp() )
    {
        SetPawnPosition( POS_Stand ); 
        
        while ( !m_pawn.m_bPostureTransition ) // wait for the anim transition to kick in
            Sleep( 0.1 );

        while ( m_pawn.m_bPostureTransition )   // wait to be in the position to move
            Sleep( 0.1 );
    }
    
    if ( m_bRunningToward ) 
    {
        m_pawn.m_escortedByRainbow = GetRainbowWhoEscortThisPawn( m_pawnToFollow );
    }

    m_bRunToRainbowSuccess = false;
    m_bNeedToRunToCatchUp = false;
    m_bStopDoTransition = false;

MovingSetDefault:
    m_lastUpdatePaceTime = Level.TimeSeconds;
    SetTimer( m_AITickTime.m_fMin, true );  
    m_pawn.bCanWalkOffLedges = m_pawn.default.bCanWalkOffLedges;

Moving:
    if ( m_bStopDoTransition ) // if have to do a transition (not every m_bPostureTransition need to be stopped)
    {
        Focus = none; 
        StopMoving();
        m_bStopDoTransition = false;

        while ( m_pawn.m_bPostureTransition ) 
        {   
            Sleep( 0.1 );
        }
    }

/// climbing ladder /////////////////////////////////////////////
WaitForClimbing:
    if ( m_pawn.m_Ladder != none )
    {
        StopMoving();
        disable('timer');

        // if FollowPawn is on the same ground as me OR if he's climbing
        if( (abs(m_pawnToFollow.location.z - pawn.Location.Z) < 80) || 
            m_pawnToFollow.m_bIsClimbingLadder )
        {        
            Sleep(0.5);

            // force to check if the rainbow leading the team has jumped off the ladder
            if ( m_pawn.m_escortedByRainbow != none ) 
                m_pawn.m_escortedByRainbow.Escort_UpdateCloserToLead();

            // check if we really need to climb
            if ( ActorReachable( m_pawnToFollow )  )
            {
                m_pawn.m_Ladder = none; // todop: to test: let the physic untouch remove the reference
                enable('timer');
                goto( 'EndClimbLadder' );
            }
            
            goto('WaitForClimbing');
        }
        else
        {
            // clear and fill the route cache so next time R6Ladder touch is called it will work!
            FindPathToward(m_pawnToFollow, true );

            // check if we really need to climb
            if ( !RouteCacheWithOtherLadder( m_pawn.m_Ladder  ) || 
                 ActorReachable( m_pawnToFollow )  )
            {
                m_pawn.m_Ladder = none;
                enable('timer');
                goto( 'EndClimbLadder' );
            }

            // go toward the ladder
            nextLabel = ''; // needed for R6Ladder.Touch: avoid to have a wrong label
            moveTarget = m_pawn.m_ladder;
            R6PreMoveToward(moveTarget, moveTarget, PACE_Walk);
            MoveToward(moveTarget);

            // we are on the spot
            if ( m_eMoveToResult == eMoveTo_success  )
            {
                if ( m_pawn.m_ladder  != none && !R6LadderVolume(m_pawn.m_ladder.MyLadder).IsAvailable(Pawn) )
                {
                    // logX( "IsSomeoneClimbing : step back..." );
                    FindNearbyWaitSpot(m_pawn.m_ladder, m_vTargetPosition); 
                    m_pawn.m_Ladder = none;

                    if ( m_pawn.bIsCrouched || m_pawn.m_bIsProne )
                        R6PreMoveTo(m_vTargetPosition, location, PACE_CrouchWalk);    
                    else
		                R6PreMoveTo(m_vTargetPosition, location, PACE_Walk);    

		            MoveToPosition(m_vTargetPosition, rotator(location - m_vTargetPosition));   
            		StopMoving();
                    Sleep(0.5);
                    Goto('WaitForClimbing');
                }

                // check if we trying to climb the ladder
                moveTarget = m_pawn.m_ladder;
                if ( CanClimbLadders(m_pawn.m_ladder) )
                {
                    nextState = GetStateName();
					GotoState('ApproachLadder');
                }
            }

            Sleep( 0.5 );
            goto( 'WaitForClimbing' );
        }
    } // if m_ladder != none
EndClimbLadder:

    if ( !CanStopMoving( true ) ) // check if should move
    {
        m_bFollowIncreaseDistance = false;
        m_lastUpdatePaceTime = Level.TimeSeconds;     
        if ( SetMovementPace( true ) )
        {
            // needs to stop and do a transition without moving
            m_bStopDoTransition = true;
            StopMoving();
            focus = none;
            goto('Moving');
        }

        //if(bShowLog) log ( "Catch up for " @pawn.name@ " of " @VSize(m_pawnToFollow.location - pawn.location)@ " max dist: " $m_iFollowPawnDistance );    
        m_bLatentFnStopped = false;

        // to prevent an npc from running into a wall
        // if targetPosition is not viewable (cannot be attained) NPC may be lagging too far behind... 
        //if ( !FastTrace(m_pawnToFollow.location, pawn.location) )  

        if ( !ActorReachable( m_pawnToFollow ) )
        {
            goto('Blocked');
        }
        else
            moveTarget = m_pawnToFollow;
    }
    else if ( m_bRunningToward ) // if I'm close to rainbow
    {
        m_bRunToRainbowSuccess = true;
        goto( 'endRunning');
    }

    if ( moveTarget != none )
    {
        moveTarget = m_pawnToFollow;
        destination = moveTarget.Location + normal(moveTarget.Location - pawn.Location) * -C_iKeepDistanceFromPawn;
        focus = none;
        focalPoint = moveTarget.Location;          
		MoveTo(destination);   

        // was forced to stop
        if ( m_bLatentFnStopped )
        {
            // no more pawn to follow (happens when running toward rainbow) OR succeeded running toward R6
            if ( m_pawnToFollow == none || m_bRunToRainbowSuccess )
            {
                goto('endRunning');
            }

            StopMoving();
        }
    }
    else
    {
        if ( m_pawnToFollow.m_bIsClimbingLadder )
        {
            // force to check if the rainbow leading the team has jumped off the ladder
            if ( m_pawn.m_escortedByRainbow != none ) 
                m_pawn.m_escortedByRainbow.Escort_UpdateCloserToLead();
            
            Sleep( 0.5 );
        }

        if ( !m_pawn.IsStationary() )
        {
            pawn.acceleration = vect(0,0,0);
            pawn.velocity = vect(0,0,0);
        }

        Sleep(m_AITickTime.m_fMin); // do nothing for 1/10th of a sec      
    }
    
    Goto('Moving');

/////////////////////////////////////////////////////////////////
Blocked:
/////////////////////////////////////////////////////////////////
    // logX( "Blocked... ");
    // if the pawn I'm following is below me or lower than me
    if ( MAXSTEPHEIGHT < abs( (m_pawnToFollow.location.Z - m_pawnToFollow.CollisionHeight)
                              - (m_pawn.location.Z - m_pawn.CollisionHeight)) )
    {
        // log( "bCanWalkOffLedges = true " );
        m_pawn.bCanWalkOffLedges = true;
    }

    moveTarget = none;
    if ( FindBestPathToward(m_pawnToFollow, true) )
    {       
        if ( moveTarget == m_pawnToFollow  )
        {
            destination = moveTarget.Location + normal(moveTarget.Location - pawn.Location) * -C_iKeepDistanceFromPawn;

            if ( PointReachable(destination) )
            {
                focus = none;
                focalPoint = moveTarget.Location;          
                MoveTo(destination);   
                StopMoving();
                moveTarget = none;
            }
            else
            {
                goto('UseMoveToward');
            }
        }
        else
        {
UseMoveToward:
            // logX( "BLOCKED: FindBestPathToward: " $moveTarget.name );
            SetTimer( 0, false ); 
            R6PreMoveToward(moveTarget, moveTarget, m_pawn.m_eMovementPace );
        
            // if far, run to catch up
            if ( VSize( m_pawnToFollow.location - pawn.Location ) > c_iDistanceToStartToRun
                 && m_pawn.m_eHealth != HEALTH_Wounded )
            {
                if ( m_pawn.m_eMovementPace == PACE_Walk )
                {
                    SetPace( PACE_Run );
                }
                else if ( m_pawn.m_eMovementPace == PACE_CrouchWalk || m_pawn.m_eMovementPace == PACE_Prone )
                {
                    SetPace( PACE_CrouchRun );
                }
            }

            MoveToward(moveTarget);             //moveTarget is set by FindBestPathToward()
        }
    }

    if ( m_pawn.m_Ladder != none )
        m_bool = actorReachable(  m_pawn.m_Ladder );
    else
        m_bool = actorReachable( m_pawnToFollow );

    // if none: I've reach the destination or it was set to none in Timer()
    if ( moveTarget == none && m_pawn.m_Ladder == none )
    {
        // give a try, move somewhere. 
        destination = m_pawnToFollow.Location + normal(m_pawnToFollow.Location - pawn.Location) * -C_iKeepDistanceFromPawn;
        MoveTo(destination);
        StopMoving();
		sleep(0.5);
		
        if ( !m_bool && FindPathTo( m_pawnToFollow.location, true ) == None )
            goto('Blocked'); 
        else
            goto('MovingSetDefault');
    }
    // if pawn still cannot see leader's position, stay in this block...
    else if ( !m_bool )
    {
        // manage the problem when an hostage is exactly on a r6ladder and try to reach
        // the other floor.
        if ( moveTarget != none && m_pawn.m_Ladder == none && moveTarget.IsA( 'R6Ladder' ) )
        {
            // todop: to test: let the physic untouch remove the reference
            //        maybe the m_ladder = none in state EndClimbingLadder should be removed
            // if the pawn is on the opposite r6ladder, move him away of this r6ladder so
            // all the logic of touch will work again
            if ( DistanceTo( moveTarget ) < 50 && 
                abs( moveTarget.Location.Z - pawn.Location.Z ) > 40 )
            {
                // logX( "blocked and unable to reach r6ladder. force it" );
                m_pawn.m_Ladder = R6Ladder(moveTarget).m_pOtherFloor;
                FindNearbyWaitSpot(R6Ladder(moveTarget).m_pOtherFloor, m_vTargetPosition); 
                m_pawn.m_Ladder = none;

                R6PreMoveTo(m_vTargetPosition, location, PACE_Walk );    
		        MoveToPosition(m_vTargetPosition, rotator(location - m_vTargetPosition));   
            	StopMoving();

                // force to check if the rainbow leading the team has jumped off the ladder
                if ( m_pawn.m_escortedByRainbow != none ) 
                    m_pawn.m_escortedByRainbow.Escort_UpdateCloserToLead();

            }
        }

        // logX( "BLOCKED: still blocked. MoveTarget=" $moveTarget.name );
        Goto('Blocked');
    }
    else 
    {
        // logX( "BLOCKED: pawn in view: move normal"  );
        moveTarget = m_pawnToFollow;
        Goto('MovingSetDefault');
    }

/////////////////////////////////////////////////////////////////
endRunning:
/////////////////////////////////////////////////////////////////
    // logX( "** endRunning **");
    if ( m_bRunningToward )
    {
        StopMoving();

        m_bRunningToward = false;
        if ( m_bRunToRainbowSuccess )
        {
            #ifdefDEBUG if(bShowLog) logX( "runningToward success"); #endif

            // will set the new state
            ResetThreatInfo( "runningToward success" );
            Order_FollowMe( m_pawnToFollow, false );   
        }
        else
        {
            #ifdefDEBUG if(bShowLog) logX( "runningToward failed" ); #endif
           
            ResetThreatInfo( "runningToward failed" );
            ReturnToNormalState( true );
        }
    }
}

//------------------------------------------------------------------
// CanOpenDoor: check if the pawn has the ability to open the door
//	ie: in case it's locked.
//------------------------------------------------------------------
event bool CanOpenDoor( R6IORotatingDoor door )
{
    // if the door is not locked
    return !door.m_bIsDoorLocked;
}

event OpenDoorFailed()
{
    #ifdefDEBUG if ( bShowLog ) logX( "OpenDoorFailed" ); #endif
    
    // general cases for the hostage, but some state have overwritted this event
    if ( m_pawn.m_bCivilian )              // if civilian
    {
        GotoState( 'CivStayHere' );    
    }
    else if ( m_pawn.m_bFreed )     // freed hostage
    {
        FollowPawnFailed();
    }
    else                            // guarded 
    {
        SetStateGuarded( POS_Kneel, m_mgr.HSTSNDEvent_None );
    }
}


//------------------------------------------------------------------
// SetStateRunForCover
//	
//------------------------------------------------------------------
function SetStateRunForCover( Pawn runAwayOfPawn, name successState, name failureState, Actor grenade )
{
    enemy = runAwayOfPawn;
    m_runAwayOfGrenade = grenade;

    m_runForCoverStateToGoOnSuccess = successState;
    m_runForCoverStateToGoOnFailure = failureState;

    if ( IsRunForCoverPossible( enemy )  )
    {
        // We play the same run for cover for hostage and civilian
        ProcessPlaySndInfo(m_mgr.HSTSNDEvent_RunForCover);
        SetThreatState( 'RunForCover' );
        GotoState( m_threatInfo.m_state );
    }
    else
    {
        ResetThreatInfo( "run for cover failed " );
        m_runAwayOfGrenade = none;
        GotoState( m_runForCoverStateToGoOnFailure );
    }
}

//------------------------------------------------------------------
// IsAwayOfGrenade: return true if away and approximatively safe of 
//   the grenade.
//------------------------------------------------------------------
function bool IsAwayOfGrenade( Actor grenade )
{
    // if far enough
    if ( VSize( pawn.location - grenade.location ) > c_iRunForCoverOfGrenadeMinDist )
    {
        return true;
    }

    // if there a fast trace
    if ( FastTrace( grenade.location) )
    {
        return false;
    }
    else
    {
        return true;
    }
}

//------------------------------------------------------------------
// IsRunForCoverPossible: return true if the hostage can run away and 
//  generate a path to run away of this enemy
//------------------------------------------------------------------
function bool IsRunForCoverPossible( Pawn runAwayOf )
{
    local Pawn aPreviousEnemy;
    local bool bResult;

    aPreviousEnemy = enemy;
    enemy = runAwayOf;
    bResult = MakePathToRun();
        
    enemy = aPreviousEnemy;

    return bResult;
}

//------------------------------------------------------------------
// RunForCover: 
//  exception when running away of grenade
//------------------------------------------------------------------
state RunForCover
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin. Eneny =" @Enemy.name ); #endif

        if ( !m_pawn.isStanding() )
            SetPawnPosition( POS_Stand );
        
        SetTimer( m_AITickTime.m_fResult, true );
        m_lastSeenPawn = none;        
        focus = none;
    }

    function EndState()
    {
        SetTimer( 0, false );
        m_runAwayOfGrenade = none;
    }

    function Timer()
    {
        if ( m_lastSeenPawn != none )
            SeePlayerMgr();
    }

    function StopRunForCover()
    {
        StopMoving();
        Enemy = none;
        m_runAwayOfGrenade = none;
        ResetThreatInfo( "StopRunForCover" );
    }
    
    function EnemyNotVisible()
    {
        // if (bShowLog) logX ( ": entered function EnemyNotVisible.  Time:" $ Level.TimeSeconds $ " Last seen: " $ LastSeenTime );

        if ( m_runAwayOfGrenade != none )
        {
            if ( IsAwayOfGrenade( m_runAwayOfGrenade ) )
            {   
                #ifdefDEBUG if(bShowLog) logX( "IsAwayOfGrenade" ); #endif
                StopRunForCover();
                GotoState( m_runForCoverStateToGoOnSuccess );
            }

            return;
        }

        // Not seen for at least X seconds, reset
       if ( Level.TimeSeconds - LastSeenTime > c_iEnemyNotVisibleTime )
       {
            // if my enemy can see me, continue to run
            if ( R6Pawn( Enemy ) != none && 
                 R6Pawn( Enemy ).controller != none &&
                 R6Pawn( Enemy ).controller.CanSee( pawn ) )
            {
                LastSeenTime = Level.TimeSeconds;
                return;
            }

            #ifdefDEBUG if(bShowLog) logX( "Not seen for at least " @c_iEnemyNotVisibleTime@ "seconds" ); #endif
            StopRunForCover();
            GotoState( m_runForCoverStateToGoOnSuccess );
        }
    }

    function bool IsRunForCoverSuccessfull()
    {
        local bool bResult;

        if ( m_runAwayOfGrenade != none )
        {
            // if i'm way of the grenade
            bResult = IsAwayOfGrenade( m_runAwayOfGrenade );
        }
        else if ( Enemy != none )
        {
            // if he cannot sees me
            bResult = !R6Pawn( Enemy ).controller.CanSee( pawn ); 
        }
        else
        {
            bResult = true;
        }

        return bResult;
    }

    event OpenDoorFailed()
    {
        StopRunForCover(); 
        gotoState( m_runForCoverStateToGoOnFailure );
    }

Begin:
    // wait to be in the position to move
    while ( m_pawn.m_bPostureTransition )
    {
        Sleep( 0.1 );
    }

    SetPace( PACE_Run );
    
ChooseDestination:
    if ( enemy == none )
    {
        StopRunForCover();
        GotoState( m_runForCoverStateToGoOnSuccess );
    }

    // Find a destination
    if( !IsRunForCoverPossible( enemy ) ) // if cannot run for cover
    {
        if ( IsRunForCoverSuccessfull() )
        {
            #ifdefDEBUG if(bShowLog) logX( "Nowhere to run... but i'm covered" ); #endif
            StopRunForCover(); // should be placed after IsRunForCoverPossible
            GotoState( m_runForCoverStateToGoOnSuccess );
        }
        else
        {
            #ifdefDEBUG if(bShowLog) logX( "Nowhere to run... failed" ); #endif
            StopRunForCover(); // should be placed after IsRunForCoverPossible
            gotoState( m_runForCoverStateToGoOnFailure );
        }
    }

RunToDestination:
    //  Move to it
    #ifdefDEBUG if (bShowLog) logX ( "label RunToDestination.  Goal = " $ RouteGoal ); #endif
    FollowPath( m_pawn.m_eMovementPace, 'ReturnToPath', false );
    Goto('ChooseDestination');

ReturnToPath:
    FollowPath( m_pawn.m_eMovementPace, 'ReturnToPath', true );
    Goto('ChooseDestination');
}


//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
// - inherited
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish()
{
    local R6Pawn aBumpPawn;

    aBumpPawn = R6Pawn(m_BumpedBy);

    // Check first if we are in this state from too long
    if( m_fLastBump + 4.0f < Level.TimeSeconds ) 
        return true;

	focus = none;	// to prevent npc from constantly turning to maintain focus on pawn he was bumped by

    if ( aBumpPawn.velocity == vect(0,0,0) )
        return true;

    if ( DistanceTo(m_BumpedBy) > c_iDistanceBumpBackUp )
        return true;

    if ( m_pawnToFollow != none &&
         DistanceTo( m_pawnToFollow ) > c_iDistanceCatchUp )
        return true;
    
    return false;
}

//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a 
//	return state (in m_bumpBackUpState_nextState)
// - inherited
//------------------------------------------------------------------
function BumpBackUpStateFinished()
{
    // default state if no state was specified in SetStateBumpBackUp
    SetStateGuarded( POS_Kneel, m_mgr.HSTSNDEvent_None );
}


//============================================================================
//	 ####    ####   ##  #    ####   ##       ####    ###    #   #   
//	##        ##    ##  #     ##    ##        ##    ##  #   ##  #   
//	##        ##    ##  #     ##    ##        ##    #####   # # #   
//	##        ##    ##  #     ##    ##        ##    ##  #   #  ##   
//	 ####    ####     ##     ####   #####    ####   ##  #   #   #   
//============================================================================

//------------------------------------------------------------------
// CivInit: initialization for the civilian
//------------------------------------------------------------------
function CivInit()
{
    local INT i;

    #ifdefDEBUG if (bShowLog) logX( "initialization for civilian" ); #endif

    if ( m_pawn.m_escortedByRainbow != none ) // needed if debbuging
        StopFollowingPawn( false );

    m_pawn.SetStandWalkingAnim( eStandWalkingAnim_default, true );

    m_pawn.m_eHandsUpType = HANDSUP_none; // needed if debbuging
    m_pawn.m_bCivilian = true;
    m_pawn.m_bClassicMissionCivilian = m_pawn.m_DZone.m_bClassicMissionCivilian;
    for ( i = 0; i < m_pawn.m_DZone.m_pListOfCoverNodes.Length; i++ )
        m_pListOfCoverNodes[i] = m_pawn.m_DZone.m_pListOfCoverNodes[i];
    m_pawn.setFrozen( false );

 // MPF1
    //setFreed( true );
	
	SetPawnPosition( m_pawn.m_ePosition );//MissionPack1

    // set state depending of the DZone (patrolArea, patrolPathNode, GuardPoint 
    switch ( m_pawn.m_eCivPatrol )
    {
	
    case CIVPATROL_Path:
        GotoState( 'CivPatrolPath' );
        break;

    case CIVPATROL_Area:
        GotoState( 'CivPatrolArea' );
        break;

    default: 
        GotoState( 'CivGuardPoint' ); 
    }
}

//------------------------------------------------------------------
// ResetThreatInfo
//	
//------------------------------------------------------------------
function ResetThreatInfo( string sz )
{
    #ifdefDEBUG if(bShowLog) logX( "ResetThreatInfo: " $sz ); #endif
    m_threatInfo = m_mgr.getDefaulThreatInfo();
}

//------------------------------------------------------------------
// SetThreatState:
//	
//------------------------------------------------------------------
function SetThreatState( name threatState )
{
    #ifdefDEBUG if(bShowLog) logX( "SetThreatState: " $threatState ); #endif
    m_threatInfo.m_state = threatState;
}

//------------------------------------------------------------------
// GetThreatGroupName
//	
//------------------------------------------------------------------
function name GetThreatGroupName()
{
    if ( m_pawn.m_bCivilian )
    {    // MPF1
        //return m_mgr.C_ThreatGroup_Civ;//MissionPack1
		if ( m_pawn.m_bClassicMissionCivilian )
			return m_mgr.C_ThreatGroup_Civ;
		else
			return m_mgr.C_ThreatGroup_HstBait;
    }
    else
    {
        if ( m_pawn.m_bFreed && m_pawn.m_escortedByRainbow != none )
            return m_mgr.c_ThreatGroup_HstEscorted;
        else if ( m_pawn.m_ePersonality == HPERSO_Bait )
            return m_mgr.C_ThreatGroup_HstBait;
        else if ( m_pawn.m_bFreed )
            return m_mgr.c_ThreatGroup_HstFreed;
        else
            return m_mgr.c_ThreatGroup_HstGuarded;
    }
}

//------------------------------------------------------------------
// ProcessThreat: process the possible threat. 
//------------------------------------------------------------------ 
/*
  When a new threat is detected, goto a state
  How threat ends?
    - when a state finish normaly       (ie: run for cover completed, play reaction)
    - when a state failed to continue   (ie: run for cover failed)
    - when interrupted:
        - new order: follow me/stay here/surrender
        - new threat: higher priority threat
    - change the current threat group (threat_freed/threat_guarded/threat_civilian/threat_bait)

  A threat can be suspended when a transition state is called:
    - climb object, ladder (many possible state), bump, open door,
    - ReactToGrenade, FollowingPaceTransition...
    
    To avoid any problem with those temp state, SeePlayer and 
    hearnoise should not update SeePlayerMgr and HearNoiseMgr...
*/
function ProcessThreat( Actor p, ENoiseType eType )
{
    local R6Pawn                    r6Pawn;
    local INT                       iDistanceFromThreat;
    local R6HostageMgr.ThreatInfo   threatInfo;
    local bool                      bNewThreat;
    local name                      stateName;
    local name                      groupName;

    groupName = GetThreatGroupName();
    if ( groupName  != m_threatGroupName )
    {
        ResetThreatInfo( "new threat group: " $groupName );
        m_threatGroupName = groupName;
    }
    if ( m_pawn.m_bClassicMissionCivilian )
    {
        if ( m_mgr.GetThreatInfoFromThreat( groupName, m_pawn, p, eType, threatInfo  ) )
        {
            m_threatInfo = threatInfo;
            bNewThreat = true;
        }
    }
    else
    {
        bNewThreat = false;

        // todop: check the runtime cost for optimization...
        if ( m_mgr.GetThreatInfoFromThreat( groupName, m_pawn, p, eType, threatInfo  ) )
        {
            // check if a new threat
            if ( threatInfo.m_iThreatLevel > m_threatInfo.m_iThreatLevel  )
            {
                #ifdefDEBUG if ( bShowLog || bThreatShowLog ) logX( " NEW THREAT: " $m_mgr.GetThreatName(threatInfo.m_id) ); #endif
                m_threatInfo = threatInfo;
                bNewThreat = true;
            }
        }
    }

    if ( bNewThreat )
    {
        stateName = m_mgr.GetReaction( groupName, m_threatInfo.m_iThreatLevel, Roll( 100 ) );

        // ignore if none
        
        if ( 'BaitPlayReaction' == stateName )
        {
            ProcessPlaySndInfo( m_mgr.HSTSNDEvent_SeeRainbowBaitOrGoFrozen );
            ResetThreatInfo( "BaitPlayReaction" );
        }
        else if ( 'GuardedPlayReaction' == stateName )
        {
            if ( m_iPlayReaction1 == 0 )
            {
                m_iPlayReaction1 = 1;
                m_iPlayReaction2 = RandRange(0,2);
            }
            ResetThreatInfo( "GuardedPlayReaction" );
        }
        else if ( 'HearShootingReaction' == stateName )
        {
            ProcessPlaySndInfo( m_mgr.HSTSNDEvent_HearShooting );
            ResetThreatInfo( "HearShootingReaction" );
        }
        else if ( stateName != m_mgr.m_noReactionName ) 
        {
            gotoState( stateName );
        }

        
    }
}


//------------------------------------------------------------------
// Civilian: base state for civilian
//	
//------------------------------------------------------------------
state Civilian
{ // MPF1
	ignores SeePlayer, HearNoise, SeePlayerMgr;//MissionPack1

    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif
        if ( m_pawn.m_bClassicMissionCivilian )
            Enable( 'HearNoise' );
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) logX( "end" ); #endif
        
        StopMoving();
    }
 // MPF1
	/*//MissionPack1 to avoid civilian following a Rainbow
    function SeePlayer( Pawn p )
    {
        Global.SeePlayer( p );
        
        if ( m_lastSeenPawn != none )
        {
            SeePlayerMgr();
        }
    }
	*/
}

//------------------------------------------------------------------
// CivPatrolArea: took from R6TerroristAI
//	- inherited
//------------------------------------------------------------------
state CivPatrolArea extends Civilian
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "beginState"); #endif
    }

Begin:
    SetPace( PACE_Walk );

AtDestination:
    m_vTargetPosition = m_pawn.m_DZone.FindRandomPointInArea();
    #ifdefDEBUG if(bShowLog) logX ( " at " $ Pawn.Location $ ", choose to wander to " $ m_vTargetPosition ); #endif

    MoveTarget = FindPathTo( m_vTargetPosition, true );
    if(MoveTarget!=None)
    {
        FollowPathTo( m_vTargetPosition, m_pawn.m_eMovementPace );
    }
    #ifdefDEBUG if (MoveTarget== None && bShowLog) logX( " at " $ Pawn.Location $ ", cannot find a path to " $ m_vTargetPosition ); #endif
    
    
    Sleep( GetRandomTweenNum( m_pawn.m_patrolAreaWaitTween ) );
    FinishAnim(); // wait for the anim to end before moving

    Goto('AtDestination');
}

//------------------------------------------------------------------
// CivGuardPoint: 
// - inherited	
//------------------------------------------------------------------
state CivGuardPoint extends Civilian
{  // MPF1
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "beginState"); #endif
        

        //SetPawnPosition( POS_Stand );

		if( m_pawn.m_bPoliceManMp1 && m_pawn.m_bPoliceManHasWeapon)//MissionPack1
		{
			//TEST: attach weapon
			m_pawn.ServerGivesWeaponToClient("R63rdWeapons.NormalSubMP5A4",1);
			// Get the primary Weapon
			m_pawn.SetToNormalWeapon();

			if(m_pawn.EngineWeapon==none)
				logX ( "No weapon!!!!");

			m_pawn.engineWeapon.GotoState('BringWeaponUp');
			m_pawn.PlayWeaponAnimation();
		}
    }

	function SeePlayer( Pawn p )//MissionPack1
	{
		local R6Pawn seen;
		if( m_pawn.m_bPoliceManMp1 && m_pawn.m_bPoliceManCanSeeRainbows)
		{
			seen = R6Pawn(p);
			if(seen == none)
				return;

			if(p.m_ePawnType==PAWN_Rainbow)
			{
				//m_pawn.PlayAnim('CrouchRainbow');
				m_pawn.PlayAnim(m_pawn.m_NocsSeeRainbowsName);
				GotoState('WaitForSomeTime');
			}
		}

    }


Begin:
    // Set the rotation of the Pawn to the rotation of the DZone
    ChangeOrientationTo( m_pawn.m_DZone.Rotation );
    FinishRotation();
}

 // MPF1
state WaitForSomeTime//MissionPack1
{
Begin:
	Sleep(RandRange(5,10));
	GotoState( 'CivGuardPoint' );

}

//------------------------------------------------------------------
// CivPatrolPath: took from R6TerroristAI
//	- inherited 	
//------------------------------------------------------------------
state CivPatrolPath extends Civilian
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "beginState"); #endif

        if( R6DZonePath(m_pawn.m_DZone) == None )
        {
            #ifdefDEBUG if(bShowLog) logX ( ": doesn't have a path zone" ); #endif
            GotoState('CivGuardPoint');
        }
    }

    function INT GetWaitingTime()
    {
        local INT iTemp;

        iTemp = GetRandomTweenNum( m_pawn.m_patrolAreaWaitTween ); 

        return Rand(iTemp+1) + iTemp; // 0 to iTemp + iTemp
    }

    function INT GetFacingTime()
    {
        local INT iTemp;

        iTemp = GetRandomTweenNum( m_pawn.m_changeOrientationTween );

        return Rand(iTemp+1) + iTemp; // 0 to iTemp + iTemp
    }

    function BOOL IsGoingBack()
    {
        return false;
    }
    

    function PickDestination()
    {
        local rotator       r;
        local INT           iDistance;

        r.Yaw     = Rand(32767)*2;
        iDistance = Rand(m_pawn.m_CurrentNode.m_fRadius);
        m_vTargetPosition = m_pawn.m_CurrentNode.Location + vector(r)*iDistance;
        #ifdefDEBUG if(bShowLog) logX( " goes to " $ m_pawn.m_CurrentNode $ " (" $ m_pawn.m_CurrentNode.Location $ ") but will go to " $ m_vTargetPosition ); #endif
    }

    event OpenDoorFailed()
    {
        #ifdefDEBUG if(bShowLog) logX( "CivPatrolPath::OpenDoorFailed" ); #endif
        
        m_pawn.m_CurrentNode = None;
        GotoState( 'CivPatrolPath' );   // restard this state
    }

    function SetToNextNode()
    {
        local R6DZonePathNode   firstnode;
        local R6DZonePath       path;
        local INT index;

        MoveTarget = None;
        firstnode = m_pawn.m_CurrentNode;
        path = R6DZonePath(m_pawn.m_DZone);
        while(MoveTarget==None)
        {
            // If path is not a cycling path and current node is the first or the last, reverse order
            if( !path.m_bCycle )
            {
                index = path.GetNodeIndex( m_pawn.m_CurrentNode );
                if( (index == 0) )
                {
                    m_pawn.m_bPatrolForward = true;
                    #ifdefDEBUG if(bShowLog) logX( " is to the beginning of path. turn back" ); #endif
                }
                if( index == (path.m_aNode.Length-1) )
                {
                    m_pawn.m_bPatrolForward = false;
                    #ifdefDEBUG if(bShowLog) logX( " is at the end of path. turn back" ); #endif
                }
            }

            // Get the next node
            if(m_pawn.m_bPatrolForward)
            {
                m_pawn.m_CurrentNode = path.GetNextNode(m_pawn.m_CurrentNode);
                #ifdefDEBUG if(bShowLog) logX( " got next node " $ m_pawn.m_CurrentNode ); #endif
            }
            else
            {
                m_pawn.m_CurrentNode = path.GetPreviousNode(m_pawn.m_CurrentNode);
                #ifdefDEBUG if(bShowLog) logX( " got previous node " $ m_pawn.m_CurrentNode ); #endif
            }

            // Check if it's the same as the fist one
            if( firstnode == m_pawn.m_CurrentNode )
            {
                #ifdefDEBUG if(bShowLog) logX ( " have not find a reachable node in path " $ m_pawn.m_DZone $ ".  Going to GuardPoint state" ); #endif
                GotoState('CivGuardPoint');
                return;
            }

            // Find path to the new node
            MoveTarget = FindPathToward( m_pawn.m_CurrentNode, true );
            #ifdefDEBUG if(bShowLog && MoveTarget==None) logX ( " at " $ Pawn.Location $": cannot find a path to node " $ m_pawn.m_CurrentNode $ " at " $ m_pawn.m_CurrentNode.Location ); #endif
        }
    }

Begin:
    if( m_pawn.m_CurrentNode == None )
    {
        #ifdefDEBUG if (bShowLog) logX ( ": No Current Node"); #endif

        m_pawn.m_CurrentNode = R6DZonePath(m_pawn.m_DZone).FindNearestNode( Pawn );
        #ifdefDEBUG if (bShowLog) logX ( ": Nearest node found: " $ m_pawn.m_CurrentNode ); #endif

        if (m_pawn.m_CurrentNode == None)
        {
            #ifdefDEBUG if(bShowLog) logX ( ": cannot find a nearest node for path " $ R6DZonePath(m_pawn.m_DZone) ); #endif
            GotoState('CivGuardPoint');
        }

        MoveTarget = FindPathToward( m_pawn.m_CurrentNode, true );
        if( MoveTarget==None )
        {
            #ifdefDEBUG if(bShowLog) logX ( " at " $ Pawn.Location $": cannot find a path to node " $ m_pawn.m_CurrentNode $ " at " $ m_pawn.m_CurrentNode.Location ); #endif
            SetToNextNode();
        }
    }
    SetPace( PACE_Walk );

FindPathToNode:
    PickDestination();

    FollowPathTo( m_vTargetPosition, m_pawn.m_eMovementPace );

ReachedTheNode:

    #ifdefDEBUG if(bShowLog) 
    {
        logX( name   $ " reached the node " $ m_pawn.m_CurrentNode
                    $ ".  Waiting:" $ m_pawn.m_CurrentNode.m_bWait
                    $ " Directional:" $ m_pawn.m_CurrentNode.bDirectional );
    } #endif

    if(m_pawn.m_CurrentNode.bDirectional)
    {
        // Turn in the right direction
        ChangeOrientationTo( GetRandomTurn90() );
        FinishRotation();
    }
    
    if(m_pawn.m_CurrentNode.m_bWait)
    {
        m_iWaitingTime = GetWaitingTime();
        m_iFacingTime = GetFacingTime();

        //if (bShowLog) logX ( " DefCon: " $ m_pawn.m_eDefCon $ " wait: " $ m_iWaitingTime $ " change: " $ m_iFacingTime );

        if(m_iFacingTime<m_iWaitingTime)
        {
            Sleep(m_iFacingTime);
            ChangeOrientationTo( GetRandomTurn90() );
            Sleep(m_iWaitingTime-m_iFacingTime);
            FinishRotation();
        }
        else
        {
            Sleep(m_iWaitingTime);
        }

        // Check chance of going back
        if(IsGoingBack())
        {
            #ifdefDEBUG if(bShowLog) logX ( ": is going back.  I repeat " $ name $ " is going back!!!" ); #endif
            m_pawn.m_bPatrolForward = !m_pawn.m_bPatrolForward;
        }
    }

    // Change the current node
    SetToNextNode();

    Focus =  m_pawn.m_CurrentNode;
    
    FinishAnim(); // wait for the anim to end before moving
//@@@rb    m_pawn.PlayTurning( IsFocusLeft() );
    FinishRotation();

    Goto('FindPathToNode');        
}


//------------------------------------------------------------------
// Order_ProcessSurrender: process the surrender order. Should not
//	be call externally of Order_Process
//------------------------------------------------------------------
function Order_ProcessSurrender( Pawn terro )
{
    local name stateName;

    m_terrorist = R6Terrorist(terro);

    #ifdefDEBUG if(bShowLog) logX( "Order_ProcessSurrender: " $Terro.name ); #endif

    if ( m_pawn.m_bCivilian || m_pawn.m_bPoliceManMp1)  // MPF1
    {  // MPF1
		/*//MissionPack1 to avoid a civilian to surrender
        m_mgr.GetThreatInfoFromThreatSurrender( terro, m_threatInfo );
        stateName = m_mgr.GetReaction( m_mgr.C_ThreatGroup_Civ, m_threatInfo.m_iThreatLevel, Roll( 100 ) );
        
        if ( stateName != m_mgr.m_noReactionName ) 
            gotoState( stateName  ); 
		*/ 
    }
    else
    {
        // if not following rainbow
        if ( m_pawn.m_escortedByRainbow == none )
        {
            ProcessPlaySndInfo( m_mgr.HSTSNDEvent_CivSurrender );
            R6TerroristAI(m_terrorist.controller).HostageSurrender( self );
        }
    }
}

//------------------------------------------------------------------
// SetStateEscorted
//	
//------------------------------------------------------------------
function SetStateEscorted( R6Pawn escort, vector destination, bool bSurrender  )
{
    #ifdefDEBUG if(bShowLog) logX( "SetStateEscorted by " $escort.name ); #endif
    
    m_escort      = escort;
    m_vMoveToDest = destination;
    
    m_pawn.setFrozen( false );
    if ( bSurrender )
    {
        SetThreatState( 'EscortedByEnemy' );
        setFreed( false );
    }

    m_bForceToStayHere = false; // allow hostage to run towards rainbow when no longer escorted
    SetPace( PACE_Walk );

    m_pawn.m_bEscorted = true;
    gotoState( 'EscortedByEnemy' );
}

function bool CivCheckCoverNode()
{
    local INT i;

    if ( m_pListOfCoverNodes.Length != 0 )
    {
        i = Rand( m_pListOfCoverNodes.Length );
        m_pCoverNode = m_pListOfCoverNodes[i];
        m_pListOfCoverNodes.Remove( i, 1 );
        CivGotoStateMovingTo( PACE_Run, m_pCoverNode );
        return true;
    }
    GotoState( 'CMCivStayKneel' );
    return false;
}

function CivGotoStateMovingTo( R6Pawn.eMovementPace ePace, optional Actor aMoveTarget )
{
    local vector vHitNormal;

    if ( aMoveTarget == none )
        GotoState( 'CMCivStayHere' );
    m_vMoveToDest = aMoveTarget.Location;
    m_pawn.m_eMovementPace = ePace;
    GotoState( 'CivMovingTo' );
}

//------------------------------------------------------------------
// EscortedByEnemy
//
//------------------------------------------------------------------
state EscortedByEnemy
{
    ignores SeePlayer, HearNoise;

    function beginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif
    }

    function endState()
    {
        #ifdefDEBUG if(bShowLog) logX( "end" ); #endif
        SetTimer( 0, false );

        m_pawn.SetStandWalkingAnim( eStandWalkingAnim_scared, false );
    }

    function EscortIsOver( bool bSuccess )
    {
        #ifdefDEBUG if(bShowLog) logX( "EscortIsOver success= " $bSuccess ); #endif

        m_pawn.m_bEscorted = false;
        m_escort = none;

        if ( m_terrorist != none )
        {
            R6TerroristAI( m_terrorist.controller ).EscortIsOver( self, bSuccess );
            m_terrorist = none;
        }

        ResetThreatInfo( "EscortIsOver" );
        if ( m_pawn.m_bFreed )
        {
            GotoState( 'Freed' );
        }
        else
        {
            // it's better to go kneel if in crouch posture 
            if ( IsInCrouchedPosture() )
                SetStateGuarded( POS_Kneel, m_mgr.HSTSNDEvent_None );
            else
                SetStateGuarded( POS_Stand, m_mgr.HSTSNDEvent_None );
        }
    }

    // todop: if escort is over? killed?
Begin:
    // wait to finish transition
    while ( m_pawn.m_bPostureTransition )
    {
        Sleep( 0.1 );
    }

    if ( m_pawn.isStandingHandUp() ) 
    {
        // when the hostage is standing & guarded and he's told to follow the terro
        m_pawn.m_eHandsUpType = HANDSUP_none;
        m_pawn.SetAnimTransition( m_mgr.ANIM_eStandHandUpToDown, '' );
    }
    else if ( !m_pawn.isStanding() )
    {
        SetPawnPosition( POS_Stand );
    }

    while ( m_pawn.m_bPostureTransition )
    {
        Sleep( 0.1 );
    }

    if ( m_vMoveToDest == Pawn.Location)
    {
        Goto('StartWaiting');
    }

    if ( m_escort.m_ePawnType == PAWN_Terrorist )
        m_pawn.SetStandWalkingAnim( eStandWalkingAnim_default, true );
    else
        m_pawn.SetStandWalkingAnim( eStandWalkingAnim_scared , true );

    MoveTarget = FindPathTo(m_vMoveToDest, true );
    if(MoveTarget==None)
    {
        #ifdefDEBUG if (bShowLog) logX ( ": cannot find a path to " $m_vMoveToDest$", wait here." ); #endif
        EscortIsOver( false );
    }

    FollowPathTo( m_vMoveToDest, m_pawn.m_eMovementPace );

StartWaiting:
    StopMoving();
    EscortIsOver( true );
}   


//------------------------------------------------------------------
// CivStayHere: the civilian as run away 
//	- inherited 
//------------------------------------------------------------------
state CivStayHere extends Civilian
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif
        StopMoving();
        ResetThreatInfo( "CivStayHere" );
    }
}

//------------------------------------------------------------------
// GoCivScareToDeath
//	- inherited 
//------------------------------------------------------------------
state GoCivScareToDeath
{
    ignores SeePlayer, HearNoise;
        
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif

        StopMoving();
        SetPawnPosition( POS_Foetus );
        m_bForceToStayHere = true;

        ProcessPlaySndInfo( m_mgr.HSTSNDEvent_GoFoetal );
        SetThreatState( 'CivScareToDeath' );
        GotoState( m_threatInfo.m_state );
		
    }
}

//------------------------------------------------------------------
// CivScareToDeath: Initialized by GoCivScareToDeath
//	
//------------------------------------------------------------------
state CivScareToDeath extends Civilian
{
    ignores SeePlayer, HearNoise;
        
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif
    }
Begin:
    Sleep( GetRandomTweenNum( m_scareToDeathTween ) );
    ResetThreatInfo( "CivScareToDeath is over" );

    m_bForceToStayHere = false;
    SetPawnPosition( POS_Kneel );
    gotoState('CivStayHere');
	
}

//------------------------------------------------------------------
// CivRunForCover
//------------------------------------------------------------------
state CivRunForCover
{
    function BeginState()
    {
    // MPF1		
        #ifdefDEBUG if(bShowLog) logX( "CivRunForCover" ); #endif
 
		//MissionPack1
        //SetStateRunForCover( m_threatInfo.m_pawn, 'CivStayHere', 'GoCivScareToDeath', m_threatInfo.m_actorExt  );
		if(m_pawn.m_bPoliceManMp1)
			gotoState('CivGuardPoint');//MissionPack1
		else if(m_pawn.m_bClassicMissionCivilian)
			CivCheckCoverNode();
		else
			gotoState('GoCivScareToDeath');//MissionPack1
    }
}

state CivMovingTo
{
    function BeginState()
    {
    }

Begin:
    m_iRandomNumber = 0;
    if ( VSize(m_vMoveToDest - Pawn.Location) < 10 )
        goto 'Exit';
    Focus = none;
    if ( !m_pawn.isStanding() )
        SetPawnPosition( POS_Stand );
    while ( m_pawn.m_bPostureTransition )
        Sleep( 0.1 );

PathFinding:
    if ( (m_pCoverNode != none && ActorReachable(m_pCoverNode)) || PointReachable(m_vMoveToDest) )
        goto 'EndPath';
    if ( m_pCoverNode != none )
        MoveTarget = FindPathToward( m_pCoverNode );
    else
        MoveTarget = FindPathTo( m_vMoveToDest, true );
    if ( MoveTarget == none )
    {
        Sleep( 0.5 );
        goto 'Exit';
    }
    if ( m_iRandomNumber == 0 )
    {
        m_iRandomNumber = 1;
        FocalPoint = MoveTarget.Location;
        FinishRotation();
    }
    Focus = none;
    R6PreMoveTo( MoveTarget.Location, MoveTarget.Location, m_pawn.m_eMovementPace );
    MoveToward( MoveTarget );
    if ( m_eMoveToResult == eMoveTo_failed )
        goto 'Exit';
    goto 'PathFinding';

EndPath:
    if ( m_iRandomNumber == 0 )
    {
        m_iRandomNumber = 1;
        FocalPoint = m_vMoveToDest;
        FinishRotation();
    }
    Focus = none;
    R6PreMoveTo( m_vMoveToDest, m_vMoveToDest, m_pawn.m_eMovementPace );
    if ( m_pCoverNode != none )
        MoveToward( m_pCoverNode );
    else
        MoveTo( m_vMoveToDest );

Exit:
    StopMoving();
    GotoState( 'CMCivStayHere' );
}

state CMCivStayKneel extends Civilian
{
    function BeginState()
    {
        StopMoving();
        m_pawn.m_bAvoidFacingWalls = true;
        SetPawnPosition( POS_Kneel );
        ResetThreatInfo( "CivStayHere" );
    }
}

state CMCivStayHere extends Civilian
{
    function BeginState()
    {
        StopMoving();
        m_pawn.m_bAvoidFacingWalls = true;
        SetPawnPosition( POS_Crouch );
        ResetThreatInfo( "CivStayHere" );
    }
}

//------------------------------------------------------------------
// CivRunTowardRainbow
//------------------------------------------------------------------
state CivRunTowardRainbow
{   
    function BeginState()
    { // MPF1
		////////////////Begin MissionPack1
		if(m_pawn.m_bCivilian || m_pawn.m_bPoliceManMp1)
			CivInit();
		else
		{
		////////////////End MissionPack1

        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif

        SetStateFollowingPawn( R6Pawn(m_threatInfo.m_pawn), true, m_mgr.HSTSNDEvent_CivRunTowardRainbow );
		}////////////////End MissionPack1
    }
}

//------------------------------------------------------------------
// CivSurrender: surrender to terrorist
//------------------------------------------------------------------
state CivSurrender 
{
    function BeginState()
    {
        // MPF1
		////////////////Begin MissionPack1
		if(m_pawn.m_bCivilian || m_pawn.m_bPoliceManMp1)
			CivInit();
		else
		{
		////////////////End MissionPack1
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif

        // look at my threat
        // focalPoint = m_threatInfo.m_pawn.location;
        if ( m_terrorist != none ) // was not ordered 
        {
            ProcessPlaySndInfo( m_mgr.HSTSNDEvent_CivSurrender );
            R6TerroristAI(m_terrorist.controller).HostageSurrender( self );
            // will call SetStateEscorted 
        }
        else
        {
            SetStateGuarded( POS_Random, m_mgr.HSTSNDEvent_CivSurrender );
        }
		}////////////////End MissionPack1

    }
}

//------------------------------------------------------------------
// Order_GetLog
//	
//------------------------------------------------------------------
function string Order_GetLog( OrderInfo info )
{
    local string szOutput;
    local string szOrder;
    local string szPawn;

    switch ( info.m_eOrder )
    {
        case HOrder_ComeWithMe:     szOrder = "follow";     break;
        case HOrder_StayHere:       szOrder = "stay";       break;
        case HOrder_Surrender:      szOrder = "surrender";  break;
        case HOrder_GotoExtraction: szOrder = "extraction"; break;
        default:                szOrder = "none";       break;
    }

    if ( info.m_pawn1 != none )
    {
        szPawn = ""$info.m_pawn1.name;
    }
    else
    {
        szPawn = "none";
    }

    szOutput = "Order: "$szOrder$" pawn: "$szPawn$" time: "$info.m_fTime;
    
    return szOutput;
}

//------------------------------------------------------------------
// Order_Pop: pop the first element and shift all the rest (FIFO queue)
//	
//------------------------------------------------------------------
function OrderInfo Order_Pop()
{
    local INT       i; 
    local INT       lastIndex; 
    local OrderInfo orderInfo;
    
    if ( m_iNbOrder == 0 )
    {
        return orderInfo;
        }

    // backup the first one
    orderInfo = m_aOrderInfo[0]; 

    // shift all info to the left
    lastIndex = ArrayCount(m_aOrderInfo) - 1;
    for ( i = 0; i < lastIndex; i++ )
    {
        m_aOrderInfo[i] = m_aOrderInfo[i+1];
    }

    // reset last one
    m_aOrderInfo[lastIndex].m_eOrder = m_pawn.eHostageOrder.HOrder_None;
    m_aOrderInfo[lastIndex].m_fTime  = 0;
    m_aOrderInfo[lastIndex].m_pawn1  = none;

    m_iNbOrder--;
            
    return orderInfo;
}

//------------------------------------------------------------------
// Order_Add: Add an order (FIFO). 
//  If there's one only
//	        
//------------------------------------------------------------------
function Order_Add( R6Hostage.eHostageOrder eOrder, R6Pawn aPawn, OPTIONAL bool bOrderedByRainbow, OPTIONAL actor anActor )
{
    local OrderInfo orderInfo;

    while ( m_iNbOrder >= ArrayCount(m_aOrderInfo) )
    {
        orderInfo = Order_Pop(); // pop the first element and keep the remaining ones
        #ifdefDEBUG if ( bShowLog ) logX( "skipped "$Order_GetLog( orderInfo ) ); #endif
    }

    m_aOrderInfo[ m_iNbOrder ].m_eOrder  = eOrder;
    m_aOrderInfo[ m_iNbOrder ].m_pawn1   = aPawn;
    m_aOrderInfo[ m_iNbOrder ].m_fTime   = Level.TimeSeconds;
    m_aOrderInfo[ m_iNbOrder ].m_bOrderedByRainbow = bOrderedByRainbow;
    m_aOrderInfo[ m_iNbOrder ].m_actor   = anActor;

    #ifdefDEBUG if ( bShowLog ) logX( "add "$Order_GetLog( m_aOrderInfo[ m_iNbOrder ] ) ); #endif
    m_iNbOrder++;

    if ( !m_pawn.m_bPostureTransition )
    {
        Order_Process();
    }
}

//------------------------------------------------------------------
// IsInTemporaryState: temporary state are states that need to be
//	over before doing anything else
//------------------------------------------------------------------
function bool IsInTemporaryState()
{
    return (   m_pawn.m_bPostureTransition 
            || m_r6pawn.m_bIsClimbingLadder
            || (Physics == PHYS_Falling) 
            || (Physics == PHYS_RootMotion)
            || isInState( 'BumpBackup')
            || isInState( 'OpenDoor')
            // || isInState( 'ClimbObject') // R6CLIMBABLEOBJECT
           );
}

//------------------------------------------------------------------
// Order_Process: process the queued Order (FIFO)
//	
//------------------------------------------------------------------
function Order_Process()
{
    local OrderInfo orderInfo;

    // don't process order if one of the condition below is true
    // MPF1
    //if ( m_iNbOrder == 0 || IsInTemporaryState() || m_pawn.m_bExtracted )
	if ( m_iNbOrder == 0 || IsInTemporaryState() || m_pawn.m_bExtracted || m_pawn.m_bCivilian)
    {
        return;
    }

    orderInfo = Order_Pop();

    #ifdefDEBUG if ( bShowLog ) logX( "process "$Order_GetLog( orderInfo ) ); #endif
    
    switch ( orderInfo.m_eOrder )
    {
        case HOrder_ComeWithMe:
            Order_ProcessFollowMe( orderInfo.m_pawn1, orderInfo.m_bOrderedByRainbow );
            break;

        case HOrder_StayHere:
            Order_ProcessStayHere( orderInfo.m_bOrderedByRainbow );
            break;
    
        case HOrder_Surrender:
            Order_ProcessSurrender( R6Terrorist(orderInfo.m_pawn1) );
            break;

        case HOrder_GotoExtraction:
            Order_ProcessGotoExtraction( orderInfo.m_actor );
            break;
    }
}

//------------------------------------------------------------------
// Order_GotoExtraction: order hostage to go to the extraction Zone
//	
//------------------------------------------------------------------
function Order_GotoExtraction( Actor aZone )
{
    Order_Add( HOrder_GotoExtraction, none, false, aZone );
}

//------------------------------------------------------------------
// Order_StayHere: Rainbow orders the hostage to stay here
//	
//------------------------------------------------------------------
function Order_StayHere( bool bOrderedByRainbow )
{
    Order_Add( HOrder_StayHere, none, bOrderedByRainbow );
}

//------------------------------------------------------------------
// Order_canFollowMe: return true if the hostage can follow
//	
//------------------------------------------------------------------
function bool Order_canFollowMe()
{
    return m_pawn.m_escortedByRainbow == none;
}

//------------------------------------------------------------------
// Order_FollowMe: Rainbows order to follow this pawn
//	
//------------------------------------------------------------------
function Order_FollowMe( R6Pawn aPawn, bool bOrderedByRainbow )
{
    Order_Add( HOrder_ComeWithMe, aPawn, bOrderedByRainbow );
}

//------------------------------------------------------------------
// Order_Surrender: Terrorist orders to surrender
//	
//------------------------------------------------------------------
function Order_Surrender( R6Pawn aPawn )
{
    Order_Add( HOrder_Surrender, aPawn );
}


state OpenDoor
{
    function SeePlayerMgr();
    function SeePlayer( Pawn p );
    event HearNoise( float fLoudness, Actor noiseMaker, ENoiseType eType, optional ESoundType ESoundType );
}

/* // R6CLIMBABLEOBJECT
state ClimbObject
{
    function SeePlayerMgr();
    function SeePlayer( Pawn p );
    event HearNoise( float fLoudness, Actor noiseMaker, ENoiseType eType, optional ESoundType ESoundType );
}
*/

//------------------------------------------------------------------
// CanClimbObject: look if the pawn can climb r6climbableObject
//	
//------------------------------------------------------------------
// R6CLIMBABLEOBJECT
/*
function bool CanClimbObject()
{
    local float fFollowZ;
    local float fPawnZ;

    // not freed, cannot climb 
    if ( !m_pawn.m_bFreed )
    {
        // todop: (what if escorted by terro?)
        return false;
    }

    if ( moveTarget != none )
    {
        // log( "CanClimbObject: moveTarget " $moveTarget );

        if ( moveTarget.IsA( 'R6ClimbablePoint' ) )
        {
            return true;
        }
    }
    else if ( m_pawnToFollow != none )
    {
        fFollowZ = m_pawnToFollow.Location.Z - m_pawnToFollow.CollisionHeight;
        fPawnZ = m_pawn.Location.Z - m_pawn.CollisionHeight;

        // log( "fFollowZ: " $fFollowZ$ " fPawnZ: " $fPawnZ );
        if ( fFollowZ - fPawnZ >= MAXSTEPHEIGHT )
        {
            return true;
        }
    }

    return Super.CanClimbObject();
}*/

//------------------------------------------------------------------
// RouteCacheWithOtherLadder
//	return true if the route cache has a the other r6ladder nav point
//------------------------------------------------------------------
function bool RouteCacheWithOtherLadder( r6ladder ladder )
{
    local INT i;
    local r6ladder testLadder;

    while ( i < 16 && RouteCache[i] != none )
    {
        testLadder = r6ladder( RouteCache[i] );
        if( testLadder != none && ladder.m_pOtherFloor == testLadder )
        {
            return true;
        }

        i++;
    }        

    return false;
}

//------------------------------------------------------------------
// CheckNeedToClimbLadder
//	
//------------------------------------------------------------------
function CheckNeedToClimbLadder()
{
    if ( m_pawnToFollow == none )
        return;

    // clear and fill the route cache so next time R6Ladder touch is called it will work!
    FindPathToward(m_pawnToFollow, true );

    // check if we really need to climb
    if ( (m_pawn.m_Ladder != none && !RouteCacheWithOtherLadder( m_pawn.m_Ladder )) ||
         ActorReachable( m_pawnToFollow )  )
    {
        m_pawn.m_Ladder = none;
        GotoState( nextState, nextLabel );   
    }
}

//------------------------------------------------------------------
// CanClimbLadder
//	
//------------------------------------------------------------------
function bool CanClimbLadders( R6Ladder ladder )
{
    local INT i;

    if ( !R6LadderVolume(ladder.MyLadder).IsAvailable(Pawn) )
    {
        return false;
    }

    // Check auto climbing flag and that it's our move target
    if ( m_pawn.m_bAutoClimbLadders  && MoveTarget == ladder  )
    {
        // Check if we want to go to the other end of that ladder
        while ( i < 16 && RouteCache[i] != none )
        {
            if ( RouteCache[i] == ladder.m_pOtherFloor )
            {
                
                return true;
            }
            i++;
        }        
    }

    // log( "CanClimbLadders: false MoveTarget=" $MoveTarget.name$ " ladder=" $ladder.name );
    return false;
}

function PlaySoundAffectedByGrenade(R6Pawn.EGrenadeType eType)
{
    switch(eType)
    {
        case GTYPE_TearGas:
            m_VoicesManager.PlayHostageVoices(m_pawn, HV_EntersGas);
            break;
        case GTYPE_Smoke:
            m_VoicesManager.PlayHostageVoices(m_pawn, HV_EntersSmoke);
            break;
    }
}

//------------------------------------------------------------------
// AIAffectedByGrenade()                                       
//------------------------------------------------------------------
function AIAffectedByGrenade(Actor aGrenade, R6Pawn.EGrenadeType eType)
{
    #ifdefDEBUG if(bShowLog) logX( " AIAffectedByGrenade from "$aGrenade); #endif

	if(eType == GTYPE_Smoke)
	{
		#ifdefDEBUG if(bShowLog) logX(" AIAffectedByGrenade() : eType == GTYPE_Smoke (no effect except visibility) "); #endif
	}
	else if(eType == GTYPE_TearGas)
    {
		#ifdefDEBUG if(bShowLog) logX(" AIAffectedByGrenade() : eType == GTYPE_TearGas "); #endif
        m_pawn.SetNextPendingAction( PENDING_Coughing );
	}
	else if(eType == GTYPE_FlashBang || eType == GTYPE_BreachingCharge)
	{
        #ifdefDEBUG if(bShowLog) logX(" AIAffectedByGrenade() : eType == GTYPE_FlashBang : aGrenade.Instigator = "$aGrenade.Instigator); #endif
        SetStateReactToGrenade( GetStateName() );
	}
}

//------------------------------------------------------------------
// PlaySoundDamage()                                       
//------------------------------------------------------------------
function PlaySoundDamage(Pawn instigatedBy)
{
    if (m_pawn.m_eHealth <= HEALTH_Wounded /*AS_MILAN*/&& !m_pawn.m_bPoliceManMp1 /*AS_MILAN*/)
    {
        ProcessPlaySndInfo( m_mgr.HSTSNDEvent_InjuredByRainbow );
    }
    
    if (m_pawn.IsFriend(instigatedBy) && m_bFirstTimeClarkComment)
    {
        if (m_pawn.m_eHealth <= HEALTH_Wounded)
        {
            m_bFirstTimeClarkComment = false;
            m_VoicesManager.PlayHostageVoices(R6Pawn(instigatedBy), HV_ClarkReprimand);
        }
    }
    else if (instigatedBy.Controller != none)
    {
        instigatedBy.Controller.PlaySoundInflictedDamage(m_pawn);
    }
}

//------------------------------------------------------------------
// SetStateReactToGrenade: set the default value
//	
//------------------------------------------------------------------
function SetStateReactToGrenade( name stateToReturn )
{
    if ( stateToReturn != 'ReactToGrenade' )
        m_reactToGrenadeStateToReturn = stateToReturn;
    
    gotoState( 'ReactToGrenade' );
}

//------------------------------------------------------------------
// ReactToGrenade
//------------------------------------------------------------------
state ReactToGrenade
{
    ignores SeePlayer, HearNoise;

    function BeginState()
    {
        #ifdefDEBUG if ( bShowLog ) logX( "beginState" ); #endif
    }

begin:
    Sleep(RandRange(0.1,0.3)); // helps to desynchronized pawn

    if ( m_pawn.m_eEffectiveGrenade == GTYPE_FlashBang || m_pawn.m_eEffectiveGrenade == GTYPE_BreachingCharge )
    {
        StopMoving();
        m_pawn.SetNextPendingAction( PENDING_Blinded );
        GetRandomTweenNum( m_stayBlindedTweenTime );
        Sleep( m_stayBlindedTweenTime.m_fResult );
        goto('end');
    }

end:
    GotoState( m_reactToGrenadeStateToReturn );
}


//------------------------------------------------------------------
// GoHstFreedButSeeEnemy
//------------------------------------------------------------------
state GoHstFreedButSeeEnemy
{
    function BeginState()
    {
        // it's better to go kneel if in crouch posture 
        if ( IsInCrouchedPosture() )
            SetStateGuarded( POS_Kneel, m_mgr.HSTSNDEvent_CivSurrender );
        else
            SetStateGuarded( POS_Stand, m_mgr.HSTSNDEvent_CivSurrender );

        ResetThreatInfo( "GoHstFreedButSeeEnemy" );
    }
}

//------------------------------------------------------------------
// GoHstRunTowardRainbow
//------------------------------------------------------------------
state GoHstRunTowardRainbow
{   
    function BeginState()
    {
        SetStateFollowingPawn( R6Pawn(m_threatInfo.m_pawn), true, m_mgr.HSTSNDEvent_HstRunTowardRainbow );
    }
}

//------------------------------------------------------------------
// GoHstRunForCover
//------------------------------------------------------------------
state GoHstRunForCover
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif
                // MPF1
		////////////////Begin MissionPack1
		if(m_pawn.m_bPoliceManMp1)
			CivInit();
		else
		{
		////////////////End MissionPack1

        SetFreed( true ); 
        SetStateRunForCover( m_threatInfo.m_pawn, 'Freed', 'Guarded_foetus', m_threatInfo.m_actorExt); 
		}////////////////End MissionPack1
    }
}

//------------------------------------------------------------------
// DbgHostage: state used to debug
//------------------------------------------------------------------
state DbgHostage
{
    ignores SeePlayer, HearNoise;

    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif
        
        StopMoving();
    }
}

//------------------------------------------------------------------
// SetStateExtracted: set the hostage in extracted state. no more or
//	- reset threat, orders
//------------------------------------------------------------------
function SetStateExtracted()
{
    m_pawn.m_bExtracted = true;
    m_iNbOrder = 0;
    ResetThreatInfo( "extracted" );

    if ( rand(2) == 1 || m_pawn.m_bCivilian )
        SetPawnPosition( POS_Stand );
    else
        SetPawnPosition( POS_Crouch );

    gotoState( 'Extracted' );
}




//------------------------------------------------------------------
// ProcessPlaySndInfo
//	
//------------------------------------------------------------------
function BOOL ProcessPlaySndInfo( int iSndEvent )
{
    local int  i, iSndIndex;
    local bool bPlay;
    
        // MPF1
	if ( m_pawn.m_bCivilian && (iSndEvent==6)) //MissionPack1
	{
		if(m_pawn.m_bPoliceManMp1)
			return true;
		iSndEvent=1;//	return false;
	}

    i = iSndEvent ;
    
    if ( m_aPlaySndInfo[i].m_iLastTime == 0 ) // never started
    {
        bPlay = true;
    }
    else if (  Level.TimeSeconds - m_aPlaySndInfo[i].m_iLastTime > m_aPlaySndInfo[i].m_iInBetweenTime  ) // never started
    {
        bPlay = true;
    }

    if ( bPlay )
    {
        m_aPlaySndInfo[i].m_iLastTime = Level.TimeSeconds;
        iSndIndex = m_mgr.GetHostageSndEvent( iSndEvent , m_pawn );
        m_VoicesManager.PlayHostageVoices( m_pawn, m_mgr.GetHostageVoices( iSndIndex ));
        #ifdefDEBUG if ( bShowLog ) logX( "PLAY VOICE:" $m_mgr.GetHostageVoices( iSndIndex ) ); #endif
    }
    else
    {
        #ifdefDEBUG if ( bShowLog ) logX( "SOUND IGNORED:" $m_mgr.GetHostageVoices( iSndIndex ) ); #endif
    }

    return bPlay;
}

//------------------------------------------------------------------
// GotoExtraction
//	run toward m_escort and ignore threats
//------------------------------------------------------------------
state GotoExtraction
{
    ignores SeePlayer, HearNoise /*, NotifyBump*/; // ignore threats and bump

    function BeginState()
    {
        #ifdefDEBUG if ( bShowLog ) logX( "begin" ); #endif

        if ( !m_pawn.isStanding() )
            SetPawnPosition( POS_Stand );

        focus = none;
    }

Begin:
    // wait to be in the position to move
    while ( m_pawn.m_bPostureTransition )
        Sleep( 0.1 );

    // give some time to be removed from the rainbow escort list
    if ( m_pawn.m_escortedByRainbow != none )
    {
        Sleep(0.3);
        StopFollowingPawn( false );
        m_pawn.SetStandWalkingAnim( eStandWalkingAnim_scared, true );
    }
    
RunToDestination:
    // logX( " RunToDestination: dist=" $VSize( Pawn.Location - m_vMoveToDest ) );
    // should be in the extraction zone...

    focus = none;
    if ( m_vMoveToDest != m_pGotoToExtractionZone.location )
        m_vMoveToDest = m_pGotoToExtractionZone.location;

    if ( VSize( Pawn.Location - m_vMoveToDest ) < 100 )
    {
        StopMoving();
        GotoState( 'Freed' );
    }

    SetPace( PACE_Run );
    m_vTargetPosition = m_vMoveToDest; 

    if ( PointReachable(m_vTargetPosition) )
    {
        //  Move to it
        #ifdefDEBUG  if (bShowLog) logX ( "PointReachable distance=" $VSize( Pawn.Location - m_vTargetPosition ) ); #endif

        focus = none;
        focalPoint = m_vTargetPosition;    
        MoveTo(m_vTargetPosition);   
        StopMoving();
        moveTarget = none;
    }
    else
    {
        MoveTarget = FindPathTo( m_vTargetPosition, true );
        if ( MoveTarget!=None )
        {
            //  Move to it
            #ifdefDEBUG  if (bShowLog) logX ( "label RunToDestination.  Goal = " $ RouteGoal$ " distance=" $VSize( Pawn.Location - m_vTargetPosition ) ); #endif
            FollowPath( m_pawn.m_eMovementPace, 'ReturnToPath', false );
        }
        else
        {
            #ifdefDEBUG if(bShowLog)  logX ( " at " $ Pawn.Location $ ", was unable to find a path to. distance=" $VSize( Pawn.Location - m_vMoveToDest )); #endif
		    R6PreMoveToward(m_pGotoToExtractionZone, m_pGotoToExtractionZone,  m_pawn.m_eMovementPace );
		    MoveToward(m_pGotoToExtractionZone);
		    Sleep(1.0);
        }
    }

    Goto('RunToDestination');

ReturnToPath:
    #ifdefDEBUG if(bShowLog) logX ( " ReturnToPath:" $ Pawn.Location $ "" ); #endif
    FollowPath( m_pawn.m_eMovementPace, 'ReturnToPath', true );
    Goto('RunToDestination');
}

//------------------------------------------------------------------
// Extracted
//	
//------------------------------------------------------------------
state Extracted
{
    ignores SeePlayer, R6DamageAttitudeTo, HearNoise, EnemyNotVisible;

    function BeginState()
    {
        #ifdefDEBUG if ( bShowLog ) logX( "begin" ); #endif
        m_pawn.m_bAvoidFacingWalls = true;
        focus = none;
        m_bIgnoreBackupBump = false;
    }

    function AIAffectedByGrenade(Actor aGrenade, R6Pawn.EGrenadeType eType)
    {
        // no effect
    }

    /////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        m_iWaitingTime = GetRandomTweenNum( m_pawn.m_changeOrientationTween );
        SetTimer( m_iWaitingTime, false );
        ChangeOrientationTo( GetRandomTurn90() );
    }
    
begin:
    Sleep( rand( 2 ) ); // give some time before stopping
    StopMoving();
    m_bForceToStayHere = true;
    StopFollowingPawn( false );
    m_iWaitingTime = GetRandomTweenNum( m_pawn.m_changeOrientationTween );
    SetTimer( m_iWaitingTime, false );
}

defaultproperties
{
     c_iDistanceMax=190
     c_iDistanceCatchUp=160
     c_iDistanceToStartToRun=350
     c_iCowardModifier=-40
     c_iBraveModifier=40
     c_iWoundedModifier=20
     c_iGasModifier=20
     c_iEnemyNotVisibleTime=5
     c_iCautiousLastHearNoiseTime=5
     c_iRunForCoverOfGrenadeMinDist=500
     m_bFirstTimeClarkComment=True
     m_AITickTime=(m_fMin=0.100000,m_fMax=0.500000)
     m_RunForCoverMinTween=(m_fMin=4.000000,m_fMax=6.000000)
     m_scareToDeathTween=(m_fMin=10.000000,m_fMax=14.000000)
     m_stayBlindedTweenTime=(m_fMin=2.800000,m_fMax=3.300000)
     c_iDistanceBumpBackUp=90
     bIsPlayer=True
}
