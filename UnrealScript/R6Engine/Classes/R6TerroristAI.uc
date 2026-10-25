//=============================================================================
//  R6TerroristAI.uc : This is the AI Controller class for all terrorists
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    2001/05/08   Added a basic default waiting state that cycles through 
//                 the 3 wait animations
//=============================================================================
class R6TerroristAI extends R6AIController
    native;

enum EAttackMode
{
    ATTACK_NotEngaged,
    ATTACK_AimedFire,
    ATTACK_SprayFire,
    ATTACK_SprayFireNoStop,     // Don't stop when enemy is not visible
    ATTACK_SprayFireMove        // When on SprayFireNoStop and received EnemyNotVisible.  Fire while walking
};

enum EReactionStatus        
{
    REACTION_HearAndSeeAll,     // Lower status include all higher status (this one include all)
    REACTION_SeeHostage,        // Dropped investigate sound
    REACTION_HearBullet,        // Dropped hostage reaction
    REACTION_SeeRainbow,        // Dropped bullet sound
    REACTION_Grenade,           // Dropped rainbow
    REACTION_HearAndSeeNothing  // Dropped all
};

enum EEventState
{
    EVSTATE_DefaultState, // Use default state
    EVSTATE_RunAway,      // In state RunAway
    EVSTATE_Attack,       // In state Attack
    EVSTATE_FindHostage,  // In state FindHostage
    EVSTATE_AttackHostage // In state AttackHostage
};

enum EFollowMode
{
    FMODE_Hostage,      // Escorting an hostage
    FMODE_Path          // Following a leader on a path
};

enum EEngageReaction
{
    EREACT_Random,
    EREACT_AimedFire,
    EREACT_SprayFire,
    EREACT_RunAway,
    EREACT_Surrender
};

// Constants
const C_MaxDistanceForActionSpot    = 2000; // Max distance for searching for action spot
const C_DefaultSearchTime           = 30;   // Default time for engage by sound
const C_HostageReactionSearchTime   = 15;   // Time to search when a hostage is seen in a anormal posture.
const C_HostageSearchTime           = 15;   // Time to search for a civilian when he become out of sight
const C_WaitingForEnemyTime         = 15;   // Time to wait 
const C_NumberOfNodeRemembered      = 10;   // Number of node remembered when choosing a new random node

var Array<R6TerroristAI>    m_listAvailableBackup;
var R6TerroristAI           m_TerroristLeader;
var INT                     m_iCurrentGroupID;
var R6Terrorist             m_pawn;
var R6TerroristMgr          m_Manager;
var R6TerroristVoices       m_VoicesManager;

// Variables used for threat reaction (SeePlayer and HearNoise)
var EEngageReaction m_eEngageReaction;
var EReactionStatus m_eReactionStatus;
var EEventState     m_eStateForEvent;
var BOOL            m_bHearInvestigate;
var BOOL            m_bSeeHostage;
var BOOL            m_bHearThreat;
var BOOL            m_bSeeRainbow;
var BOOL            m_bHearGrenade;

// Variable internally used for AI
var INT         m_iTerroristInGroup;            // Number of terrorist in group, for reaction check
var INT         m_iRainbowInCombat;             // Number of Rainbow in combat, for reaction check
var FLOAT       m_fWaitingTime;                 // Used in patrol when waiting at a noode
var FLOAT       m_fFacingTime;                  // Used in patrol when waiting at a noode
var EAttackMode m_eAttackMode;                  // In wich attack mode the terrorist is currently
var INT         m_iChanceToDetectShooter;       // Chance that the terrorist detect from where come the bullet,
                                                //   increase with each bullet detected
var vector      m_vThreatLocation;              // Where the terrorist think a threat is coming from
var R6ActionSpot m_pActionSpot;                 // Current cover spot of the terrorist
var FLOAT       m_fSearchTime;                  // Time that the terrorist stay in engaged by sound
var vector      m_vHostageReactionDirection;    // hostage reaction direction
var INT         m_iRandomNumber;                // Used in any place where I need a temporary random number
var INT         m_iStateVariable;               // Variable that can be used inside a state but not used between state

var NavigationPoint m_aLastNode[C_NumberOfNodeRemembered];  // Last ten node used by the terrorist

var R6Pawn      m_huntedPawn;                   // hunted pawn

// Hostage interaction
var R6Hostage               m_Hostage;
var R6HostageAI             m_HostageAI;
var R6DeploymentZone        m_ZoneToEscort;

// Follow pawn variable
var R6Pawn      m_PawnToFollow;
var FLOAT       m_fPawnDistance;
var EFollowMode m_eFollowMode;
var INT         m_iFollowYaw;
var FLOAT       m_fFollowDist;

// MovingTo variable
var actor       m_aMovingToDestination;
var vector      m_vMovingDestination;
var name        m_stateAfterMovingTo;
var name        m_labelAfterMovingTo;
var BOOL        m_bPreciseMove;         // Set to true for the pawn to walk as close as possible to destination
var BOOL        m_bCanFailMovingTo;
var string      m_sDebugString;
var R6Pawn      m_LastBumped;
var FLOAT       m_fLastBumpedTime;
var BYTE        m_wBadMoveCount;

var BOOL        m_bFireShort;

// Patrol path variable
var BOOL            m_bInPathMode;
var BOOL            m_bWaiting;
var R6DZonePath     m_path;
var R6DZonePathNode m_CurrentNode;
var name            m_PatrolCurrentLabel;
var Rotator         m_rStandRotation;

var vector          m_vSpawningPosition;
var Rotator         m_rSpawningRotation;

// Variable used for PlayVoices
var BOOL            m_bAlreadyHeardSound;
var BOOL            m_bHeardGrenade;

// For interrupted IO
var BOOL                m_bCalledForBackup;
var R6InteractiveObject m_TriggeredIO;

native(1820) final function NavigationPoint GetNextRandomNode();
native(1821) final function CallBackupForAttack( vector vDestination, R6Pawn.EMovementPace ePace );
native(1823) final function CallBackupForInvestigation( vector vDestination, R6Pawn.EMovementPace ePace );
native(1822) final function BOOL MakeBackupList();
native(1824) final function vector FindBetterShotLocation( Pawn pTarget );
native(1827) final function BOOL HaveAClearShot( vector vStart, Pawn pTarget );
native(1828) final function BOOL CallVisibleTerrorist();
native(1829) final function BOOL IsAttackSpotStillValid();


event PostBeginPlay()
{

    Super.PostBeginPlay();
    m_VoicesManager = R6TerroristVoices( R6AbstractGameInfo(level.game).GetTerroristVoicesMgr(Level.m_eTerroristVoices) );
}

//============================================================================
//===  STATE Test
//============================================================================
state Test
{
Begin:
    SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );
    m_rStandRotation = m_pawn.Rotation;
    goto('RandomRotation');

RandomRotation:
    m_rStandRotation.Yaw = rand(32767) * 4;
    logX( "Yaw: " $ m_rStandRotation.Yaw );
    ChangeOrientationTo( m_rStandRotation );
    Sleep(2);
    goto('RandomRotation');

Sequence:
    Sleep(2);
    goto('Sequence');
}

//============================================================================
// LogTerroState - 
//============================================================================
function LogTerroState()
{
    local R6PlayerController C; 

    foreach AllActors(class'R6PlayerController', C)
    {
        if( C.CheatManager!=none )
        {
            R6CheatManager(C.CheatManager).logTerro(m_pawn);
            break;
        }
    }
}

//============================================================================
// bool CanClimbLadders - 
//============================================================================
function BOOL CanClimbLadders( R6Ladder ladder )
{
    local INT i;
    local BOOL bResult;

    // Check auto climbing flag and that it's our move target
    if(m_pawn.m_bAutoClimbLadders && (MoveTarget==ladder || Pawn.Anchor==ladder))
    {
        // Check if we want to go to the other end of that ladder
        while( i < 16 && RouteCache[i] != none )
        {
            // Check if the other floor of the ladder is in our RouteCache
            if(RouteCache[i]==ladder.m_pOtherFloor)
                bResult = true;

            // If the other floor is in our RouteCache, make sure it's our next destination,
            // not a previous one (ie, ladder is not later in our RouteCache).
            if(bResult && RouteCache[i]==ladder)
                return false;
            i++;
        }        
    }
    
#ifdefDEBUG 
    if(bResult)
        if(bShowLog) logX("Don't want to climb " $ ladder.name );
    else
        if(bShowLog) logX("Want to climb " $ ladder.name );
#endif
        
    return bResult;
}

//============================================================================
// BOOL CanSafelyChangeState - 
//          Return true if a pawn can safely change state by event.
//          - Not in ladder
//          - Not in root motion
//          - Not with an uninterruptable interactive object
//============================================================================
function BOOL CanSafelyChangeState()
{
    return ( Pawn.IsAlive() && !m_bCantInterruptIO && Pawn.Physics!=PHYS_RootMotion && Pawn.Physics!=PHYS_Ladder && !m_pawn.m_bIsKneeling);
}

//============================================================================
// R6DamageAttitudeTo - 
//============================================================================
function R6DamageAttitudeTo(Pawn instigatedBy, eKillResult eKillFromTable, eStunResult eStunFromTable, vector vBulletMomentum)
{
    if(IsAnEnemy( R6Pawn(instigatedBy) ))
    {
        if( m_eReactionStatus<=REACTION_SeeRainbow )
            GotoStateEngageByThreat( instigatedBy.Location );
    }
    
    // Update weapon accuracy
    if(m_pawn.EngineWeapon!=none)
        m_pawn.EngineWeapon.SetAccuracyOnHit();
}

//============================================================================
// PlaySoundDamage - 
//============================================================================
function PlaySoundDamage(Pawn instigatedBy)
{
    m_VoicesManager.PlayTerroristVoices( m_pawn, TV_Wounded);

    switch(m_pawn.m_eHealth)
    {
        case HEALTH_Incapacitated:
        case HEALTH_Dead:
            if (instigatedBy.Controller != none)
                instigatedBy.Controller.PlaySoundInflictedDamage(m_pawn);
            break;
    }
}


//============================================================================
// SetReactionStatus - 
//============================================================================
function SetReactionStatus( EReactionStatus eNewStatus, EEventState eState )
{
    // Desactivate all message
    m_bHearInvestigate=false;
    m_bSeeHostage=false;
    m_bHearThreat=false;
    m_bSeeRainbow=false;
    m_bHearGrenade=false;

    if(eNewStatus<REACTION_HearAndSeeNothing)
    {
        Enable('HearNoise');
    }
    else
    {
        Disable('HearNoise');
    }

    if(eNewStatus<REACTION_Grenade)
    {
        Enable('SeePlayer');
    }
    else
    {
        Disable('SeePlayer');
    }    

    // Activate them from status
    switch(eNewStatus)                  // No break on purpose.  All condition include the others under them
    {
        case REACTION_HearAndSeeAll:
            m_bHearInvestigate=true;
        case REACTION_SeeHostage:
            m_bSeeHostage=true;
        case REACTION_HearBullet:
            m_bHearThreat=true;
        case REACTION_SeeRainbow:
            m_bSeeRainbow=true;         
        case REACTION_Grenade:          // From here, doesn't see anyone
            m_bHearGrenade=true;
        case REACTION_HearAndSeeNothing:// From here, doesn't hear anything (investigate, threat, grenade)
            break;
    }

    m_eReactionStatus = eNewStatus;

    // Setting of event EnemyNotVisible
    m_eStateForEvent = eState;
    if(m_eStateForEvent!=EVSTATE_DefaultState)
    {
        Enable('EnemyNotVisible');
    }
    else
    {
        Disable('EnemyNotVisible');
    }
}

//============================================================================
// ChangeDefcon - 
//============================================================================
function ChangeDefCon( R6Terrorist.EDefCon eNewDefCon )
{
    switch(eNewDefCon)
    {
        case DEFCON_1: m_pawn.RotationRate.Yaw = 70000; break;
        case DEFCON_2: m_pawn.RotationRate.Yaw = 60000; break;
        case DEFCON_3: m_pawn.RotationRate.Yaw = 50000; break;
        case DEFCON_4: m_pawn.RotationRate.Yaw = 40000; break;
        case DEFCON_5: m_pawn.RotationRate.Yaw = 30000; break;
    }

    m_pawn.m_eDefCon = eNewDefCon;
    if(eNewDefCon<=DEFCON_2)
        m_pawn.m_bWantsHighStance = true;
    else
        m_pawn.m_bWantsHighStance = false;
    
    m_pawn.PlayMoving();
}

//============================================================================
// SetActionSpot - 
//============================================================================
function SetActionSpot( R6ActionSpot pNewSpot )
{
    if(m_pActionSpot!=none)
        m_pActionSpot.m_pCurrentUser = none;

    m_pActionSpot = pNewSpot;

    if(m_pActionSpot!=none)
        m_pActionSpot.m_pCurrentUser = m_pawn;
}

//============================================================================
// SetEnemy - 
//============================================================================
function SetEnemy( Pawn newEnemy )
{
    #ifdefDEBUG if(bShowLog) logX("SetEnemy " $ newEnemy ); #endif
    Enemy = newEnemy;
    LastSeenTime = Level.TimeSeconds;
    if(Enemy!=none)
        LastSeenPos = Enemy.Location;
}

#ifdefDEBUG
function SetView()
{
    local R6PlayerController pc;

    foreach AllActors(class'R6PlayerController', pc)
    {
        pc.CheatManager.ViewActor( Pawn.name );
        break;
    }
}
#endif

//============================================================================
// INT GetKillingHostageChance - 
//============================================================================
function INT GetKillingHostageChance()
{
    local INT iChance;

    if(UseRandomHostage())
        iChance = 40;
    else
        iChance = m_pawn.m_DZone.m_HostageShootChance;

    if(m_pawn.m_iDiffLevel==1)
        iChance -= 20;
    if(m_pawn.m_iDiffLevel==3)
        iChance += 20;

    #ifdefDEBUG if(bShowLog) log("GetKillingHostageChance return " $ iChance ); #endif
    
    return iChance;
}

//============================================================================
// SeePlayer - 
//============================================================================
event SeePlayer(Pawn seen)
{
    local R6Pawn r6seen;
    local R6Hostage hostage;
    local R6HostageAI hostageAI;

    r6seen = R6Pawn(seen);
    if(r6seen == None)
        return;

    if( m_bSeeHostage && IsAnHostage( r6seen ) )
    {
        hostage = R6Hostage(r6seen);
        if( hostage.m_bClassicMissionCivilian == true )
            return;
    }

    if(m_eStateForEvent == EVSTATE_AttackHostage)
    {
        if(r6seen.IsAlive() && IsAnHostage( r6seen ) )
        {
            SetEnemy( r6seen );
            GotoStateAimedFire();
        }
        return;
    }

    // I see dead people
    if( !m_pawn.m_bHearNothing && !r6seen.IsAlive() )
    {
        if( CheckForInteraction() )
            return;

        if( !m_bAlreadyHeardSound )
        {
            #ifdefDEBUG if(bShowLog) logX("New dead pawn " $ r6seen.name ); #endif

            GotoSeeADead( r6seen.Location );
        }
    }

    // Seeing Rainbow
    if(m_bSeeRainbow && IsAnEnemy(r6seen))
    {
        #ifdefDEBUG if (bShowLog) logX ( "Have seen " $ r6seen.name $ ". Time:" $ Level.TimeSeconds ); #endif
        
        ReconThreatCheck( seen, NOISE_None );
        EngageBySight( r6seen );
    }
    // Seeing Hostage
    else if(m_bSeeHostage && IsAnHostage( r6seen ))
    {
        hostage = R6Hostage(r6seen);
        if(UseRandomHostage())
        {
            m_Hostage = hostage;
        }
        else
        {
            if(!IsAssigned( hostage ))
            {
                if(IsMyHostage( hostage ))
                {
                    #ifdefDEBUG if(bShowLog) logX( hostage.name $ " is my hostage, assign it." ); #endif
                    m_Manager.AssignHostageTo( hostage, Self );
                    m_VoicesManager.PlayTerroristVoices( m_pawn, TV_SeesSurrenderedHostage);
                }
                else
                {
                    m_VoicesManager.PlayTerroristVoices( m_pawn, TV_SeesFreeHostage);
                    GotoStateFindHostage( hostage );
                }
            }
            else
            {
                hostageAI = R6HostageAI(hostage.Controller);

                // look if the hostage has reacted to something and if I've not already got a reaction direction
                if ( hostageAI.m_vReactionDirection != vect(0,0,0) &&
                     m_vHostageReactionDirection == vect(0,0,0) )
                {
                    m_vHostageReactionDirection = hostageAI.m_vReactionDirection;
                    hostageAI.m_vReactionDirection = vect(0,0,0);
                    GotoPointAndSearch( m_vHostageReactionDirection, PACE_Walk, false,
                                        C_HostageReactionSearchTime, m_pawn.m_eDefCon  ); 
                }
            }
        }
    }
}

//============================================================================
// ReconThreatCheck - 
//============================================================================
function ReconThreatCheck( Actor aThreat, ENoiseType eType )
{
    local R6Pawn aPawn;

    aPawn = R6Pawn(aThreat);
    if ( eType == NOISE_None )
    {
        // SeePlayer check
        if(aPawn!=None && m_pawn.IsEnemy( aPawn ) )
        {
            R6AbstractGameInfo(Level.Game).PawnSeen( aPawn, m_pawn );
        }
    }
    else
    {
        // HearNoise check
        // Check that the sound is from a Rainbow's gun
        if ( eType == NOISE_Threat ||
             m_pawn.IsEnemy( aThreat.Instigator ) && aThreat.IsA('R6Weapon')  )
        {
            R6AbstractGameInfo(Level.Game).PawnHeard( aThreat.Instigator, m_pawn );
        }
    }
}

//============================================================================
// BOOL UseRandomHostage - 
//============================================================================
function BOOL UseRandomHostage()
{
    // If game type is hostage rescue (or terrorist hunt)
    return Level.GameTypeUseNbOfTerroristToSpawn( Level.Game.m_szGameTypeFlag );
}

//============================================================================
// AssignNearHostage - 
//============================================================================
function AssignNearHostage()
{
    local R6Hostage hostage;

    foreach VisibleCollidingActors( class'R6Hostage', hostage, 500, Pawn.Location )
    {
        m_Hostage = hostage;
    }
}

//============================================================================
// HearNoise - 
//============================================================================
event HearNoise( float Loudness, Actor NoiseMaker, ENoiseType eType, optional ESoundType ESoundType )
{
    local R6Hostage hostage;
    local R6Pawn    pPawn;

    if( m_pawn.m_bHearNothing || (m_pawn.m_bDontHearPlayer && R6Pawn(NoiseMaker.Instigator).m_bIsPlayer) )
        return;

    ReconThreatCheck( NoiseMaker, eType );

    #ifdefDEBUG if(bShowLog) logX( "Hear sound from " $ NoiseMaker.name $ " of type " $ eType $ " and loudness " $ Loudness ); #endif

    if( m_bHearInvestigate && eType==NOISE_Investigate)
    {
        // Check if it's a sound from a know hostage
        hostage = R6Hostage(NoiseMaker.Instigator);
        if( hostage != None )
        {
            if( IsAssigned( hostage ) )
                return;
        }

        if( !m_bAlreadyHeardSound )
        {
            m_bAlreadyHeardSound = true;
            m_VoicesManager.PlayTerroristVoices(m_pawn, TV_HearsNoize);
        }

        GotoPointAndSearch( NoiseMaker.Location, PACE_Walk, true, C_DefaultSearchTime, DEFCON_2 );
    }
    // If it's a bullet, react to threat, not to noise
    else if( m_bHearThreat && eType==NOISE_Threat)
    {
        if(m_iChanceToDetectShooter<80)
        {
            m_iChanceToDetectShooter += 20;
        }
        // Check if we detect shooter
        if((Rand(100)+1)<m_iChanceToDetectShooter)
        {
            EngageBySight( NoiseMaker.Instigator );
        }
        else
        {
            if(!IsInState('EngageByThreat'))
                GotoStateEngageByThreat( NoiseMaker.Instigator.Location );
        }
    }
    else if(m_bHearGrenade && eType==NOISE_Grenade)
    {
        // Check that noisemaker or instigator are in our field of view
        if( ShortestAngle2D( Rotator(NoiseMaker.Location-Pawn.Location).Yaw, Pawn.Rotation.Yaw ) < 16000 
         || ShortestAngle2D( Rotator(NoiseMaker.Instigator.Location-Pawn.Location).Yaw, Pawn.Rotation.Yaw ) < 16000 )
        {
            if(!m_bHeardGrenade)
            {
                m_VoicesManager.PlayTerroristVoices( m_pawn, TV_Grenade);
                m_bHeardGrenade = true;
            }
            ReactToGrenade( NoiseMaker.Location );
        }
    }
    else if(m_bHearInvestigate && eType==NOISE_Dead)
    {
        pPawn = R6Pawn(NoiseMaker.Instigator);
        if( pPawn!=none && !pPawn.m_bTerroSawMeDead )
        {
            pPawn.m_bTerroSawMeDead = true;
            GotoPointAndSearch( NoiseMaker.Location, PACE_Walk, true, C_DefaultSearchTime );
        }
        else
            ChangeDefCon(DEFCON_2);
    }
}

//============================================================================
// EnemyNotVisible - 
//============================================================================
event EnemyNotVisible()
{
    local vector vDir;
    local vector vTest;

    switch(m_eStateForEvent)
    {
        case EVSTATE_DefaultState:
            break;
            
        case EVSTATE_RunAway:
            #ifdefDEBUG if (bShowLog) logX ( "Enter function EnemyNotVisible.  Time:" $ Level.TimeSeconds $ " Last seen: " $ LastSeenTime $ " Enemy: " $ Enemy ); #endif

            // Not seen for at least 2 seconds
            if( Level.TimeSeconds - LastSeenTime > 2 && CanSafelyChangeState() )
            {
                GotoState('WaitForEnemy');
            }
            break;

        case EVSTATE_FindHostage:
            #ifdefDEBUG if (bShowLog) logX ( "Enter function EnemyNotVisible.  Time:" $ Level.TimeSeconds $ " Last seen: " $ LastSeenTime $ " Enemy: " $ Enemy ); #endif

            FocalPoint = LastSeenPos;
            GotoState('FindHostage', 'Pursues');
            break;

        case EVSTATE_Attack:
            if(m_eAttackMode == ATTACK_SprayFireMove)
                return;

            #ifdefDEBUG if (bShowLog) logX ( "Enter function EnemyNotVisible.  Attack mode: " $ m_eAttackMode $ " Time:" $ Level.TimeSeconds $ " Last seen: " $ LastSeenTime $ " Enemy: " $ Enemy ); #endif

            FocalPoint = LastSeenPos;
            Focus = none;
            if(m_eAttackMode == ATTACK_SprayFireNoStop && m_pawn.m_bAllowLeave)
            {
                // Move toward last seen position
                m_vMovingDestination = LastSeenPos;

                // If pawn not already there
                if( VSize(Pawn.Location-m_vMovingDestination) > Pawn.CollisionRadius*2 )
                {
                    if(pointReachable(m_vMovingDestination))
                    {
                        GotoState('Attack', 'SprayFireMove');
                    }
                    else
                    {
                        // Try to avoid a wall corner
                        vDir = Normal( m_vMovingDestination - m_pawn.Location );
                        vTest = (vDir cross vect(0,0,1)) * 200;
                        if(pointReachable(m_vMovingDestination + vTest))
                        {
                            m_vMovingDestination = m_vMovingDestination + vTest;
                            GotoState('Attack', 'SprayFireMove');
                        }
                        else if(pointReachable(m_vMovingDestination - vTest))
                        {
                            m_vMovingDestination = m_vMovingDestination - vTest;
                            GotoState('Attack', 'SprayFireMove');
                        }
                    }
                }
                return;
            }

            if(m_pawn.m_ePersonality==PERSO_Sniper)
            {
                GotoState('Sniping', 'LostTrackOfEnemy');
            }
            else
            {
                GotoStateLostSight( LastSeenPos );
            }
            break;

        default:
            #ifdefDEBUG if(bShowLog) logX( "Received enemy not visible for a state not defined: " $ m_eStateForEvent ); #endif
            Disable('EnemyNotVisible');
    }
}

//============================================================================
// state BumpBackUp - set the pawn engagement status at beginning of state
//============================================================================
function GotoBumpBackUpState( name returnState )
{
    if(!m_pawn.m_bIsKneeling && !CanSafelyChangeState())
        return;

    Super.GotoBumpBackUpState( returnState );
}


state BumpBackUp
{
ignores EnemyNotVisible;

    function BeginState()
    {
        SetReactionStatus( m_eReactionStatus, m_eStateForEvent );
        Super.BeginState();
    }
    function EndState()
    {
        Focus = none;
        Super.EndState();
    }
    function bool GetReacheablePoint( OUT vector vTarget, bool bNoFail )
    {
		local actor hitActor;
		local vector vHitLocation, vHitNormal;
		local vector vExtent;

		if(MoveRight())
			vTarget = Pawn.Location + (c_iDistanceBumpBackUp)*vector(rotator(m_vBumpedByVelocity) + rot(0,16384,0));
		else
			vTarget = Pawn.Location + (c_iDistanceBumpBackUp)*vector(rotator(m_vBumpedByVelocity) - rot(0,16384,0));
		
		vExtent.x = Pawn.CollisionRadius;
		vExtent.y = vExtent.y;
		vExtent.z = Pawn.CollisionHeight;
		hitActor = R6Trace(vHitLocation, vHitNormal, vTarget, Pawn.Location, TF_TraceActors|TF_Visibility, vExtent);
		if(hitActor != none)
			vTarget = vHitLocation + (c_iDistanceBumpBackUp)*vector(rotator(m_vBumpedByVelocity));
		return true;
	}
}

/* // R6CLIMBABLEOBJECT
state ClimbObject
{
ignores SeePlayer, HearNoise, NotifyBump; 
    
    function EndState()
    {
        Focus = none;
        Super.EndState();
    }
}
*/

state ApproachLadder
{
ignores SeePlayer, HearNoise;

    function BeginState()
    {
        SetReactionStatus( m_eReactionStatus, m_eStateForEvent );
        Super.BeginState();
    }

    function EndState()
    {
        Focus = none;
        Super.EndState();
    }
}

state WaitToClimbLadder
{
    function BeginState()
    {
        SetReactionStatus( m_eReactionStatus, m_eStateForEvent );
        Super.BeginState();
    }

    function EndState()
    {
        Focus = none;
        Super.EndState();
    }
}


//============================================================================
// SetGunDirection - 
//============================================================================
function SetGunDirection( Actor aTarget )
{
    local rotator rDirection;
    local vector  vDirection;
    local Coords  cTarget;
    local vector  vTarget;

    if( aTarget != none)
    {
        if(aTarget==Enemy)
        {
            vTarget = LastSeenPos;
        }
        else
        {
            cTarget = aTarget.GetBoneCoords('R6 Spine');
            vTarget = cTarget.Origin;
        }

        // Find the pitch between the gun and the target
        vDirection = vTarget - m_pawn.GetFiringStartPoint();
        rDirection = rotator(vDirection);

        m_pawn.m_wWantedAimingPitch = rDirection.Pitch/256;
        m_pawn.m_rFiringRotation = rDirection;
    }
    else
    {
        m_pawn.m_wWantedAimingPitch = 0;
        m_pawn.m_rFiringRotation = m_pawn.Rotation;
    }
}

//============================================================================
// IsAnEnemy - 
//============================================================================
function BOOL IsAnEnemy(R6Pawn other)
{
    if( m_pawn.m_bDontSeePlayer && other.m_bIsPlayer )
        return false;

    if ( m_pawn.IsEnemy( other ) && other.IsAlive() )
        return true;

    return false;
}

//============================================================================
// IsAnHostage - 
//============================================================================
function BOOL IsAnHostage(R6Pawn other)
{
    if( m_pawn.IsNeutral( other ) && other.IsAlive() )
        return true;

    return false;
}

//============================================================================
// BOOL IsAssigned - 
//============================================================================
function BOOL IsAssigned(R6Hostage hostage)
{
    return m_Manager.IsHostageAssigned( hostage );
}

//============================================================================
// BOOL IsMyHostage - 
//============================================================================
function BOOL IsMyHostage(R6Hostage hostage)
{
    local BOOL bResult;
    local R6DZonePoint zonePoint;
    local actor hitActor;
    local vector vHitLocation;
    local vector vHitNormal;

    zonePoint = R6DZonePoint(m_pawn.m_DZone);
    if(zonePoint!=none)
    {
        // Check if we see the hostage from our spawning point
        hitActor = m_pawn.R6Trace( vHitLocation, vHitNormal, hostage.Location, zonePoint.Location, TF_TraceActors|TF_Visibility );
        if(hitActor == hostage)
            bResult = true;
    }
    else
        bResult = m_pawn.m_DZone.IsPointInZone( m_pawn.Location ) && m_pawn.m_DZone.IsPointInZone( hostage.Location );

    return bResult;
}

//============================================================================
// StartFiring - 
//============================================================================
function StartFiring()
{
    if(!Pawn.m_bDroppedWeapon && Pawn.EngineWeapon!=none)
    {    
        if(!Pawn.EngineWeapon.HasAmmo())
            return;
        
        if(Enemy != None)
        {
            Target = Enemy;
        }
        
        bFire = 1;
        Pawn.EngineWeapon.GotoState('NormalFire');
    }

    m_pawn.PlayWeaponAnimation();
}

//============================================================================
// StopFiring - 
//============================================================================
function StopFiring()
{
    bFire = 0;
    m_pawn.PlayWeaponAnimation();
}

//============================================================================
// ReloadWeapon - 
//============================================================================
function AIReloadWeapon()
{
    Pawn.EngineWeapon.GotoState('');

    m_pawn.m_wWantedAimingPitch = 0;

    // if it's a machine gun, the terrorist doesn't reload.
    if(Pawn.EngineWeapon.m_eWeaponType==WT_LMG)
    {
        // Simply add some ammo
        Pawn.EngineWeapon.FullCurrentClip();
    }
    else
    {
        // Play reloading animation
        m_pawn.m_ePlayerIsUsingHands = HANDS_None;
        m_pawn.ServerSwitchReloadingWeapon(TRUE);
        m_pawn.ReloadWeapon();
    }
    m_pawn.PlayWeaponAnimation();
}

//============================================================================
// FLOAT GetMaxCoverDistance - Max distance that the pawn is willing to go
//                             to find a cover
//============================================================================
function FLOAT GetMaxCoverDistance()
{
    switch(m_pawn.m_ePersonality)
    {
        case PERSO_Coward:
            return 2000; break;
        case PERSO_DeskJockey:
            return 1600; break;
        case PERSO_Normal:
            return 1200; break;
        case PERSO_Hardened:
            return 800; break;
        case PERSO_SuicideBomber:
            return 400; break;
        case PERSO_Sniper:
            return 0; break;
    }
    return 0;
}

//============================================================================
// BOOL SetLowestSnipingStance - 
//    - If aTarget != none, return true if we see the pawn from a position
//    - I have assumed that from or animation the offset on Z from the ground
//      for the start firing point is prone 15, crouch 70 and standing 135
//============================================================================
function BOOL SetLowestSnipingStance( optional Actor aTarget )
{
    local vector vStart;
    local vector vTarget;

    vStart = m_pawn.Location;

    // Check if pawn can see at least at 5 meters when prone
    vStart.Z = m_pawn.Location.Z - m_pawn.CollisionHeight + 15;
    if( aTarget != none )
    {
        vTarget = aTarget.Location;
    }
    else
    {
        vTarget = vStart + vector(m_pawn.Rotation)*500;
    }
    if(FastTrace( vStart, vTarget ))
    {
        #ifdefDEBUG if(bShowLog) logX( "See from prone " $ vStart $ " to " $ vTarget $ "(Pawn at " $ m_pawn.Location $ " ) " ); #endif
        // Prone
        m_pawn.m_bWantsToProne = true;
        m_pawn.bWantsToCrouch = false;
        return true;
    }

    // Check if pawn can see at least at 5 meters when crouching
    vStart.Z = m_pawn.Location.Z - m_pawn.CollisionHeight + 70;
    if( aTarget != none )
    {
        vTarget = aTarget.Location;
    }
    else
    {
        vTarget = vStart + vector(m_pawn.Rotation)*500;
    }
    if(FastTrace( vStart, vTarget ))
    {
        #ifdefDEBUG if(bShowLog) logX( "See from crouch " $ vStart $ " to " $ vTarget $ "(Pawn at " $ m_pawn.Location $ " ) " ); #endif
        // Crouch
        m_pawn.m_bWantsToProne = false;
        m_pawn.bWantsToCrouch = true;
        return true;
    }

    #ifdefDEBUG if(bShowLog) logX( "Don't see from " $ vStart $ " to " $ vTarget $ "(Pawn at " $ m_pawn.Location $ " ) " ); #endif

    // Cannot see prone or crouch, so go for standing
    if( aTarget != none )
    {
        // Check if pawn can see target when standing
        vStart.Z = m_pawn.Location.Z - m_pawn.CollisionHeight + 135;
        vTarget = aTarget.Location;
        if(FastTrace( vStart, vTarget ))
        {
            #ifdefDEBUG if(bShowLog) logX( "See from standing " $ vStart $ " to " $ vTarget $ "(Pawn at " $ m_pawn.Location $ " ) " ); #endif
            // Crouch
            m_pawn.m_bWantsToProne = false;
            m_pawn.bWantsToCrouch = false;
            return true;
        }

        // If we got a target we cannot see, set lowest stance without target and return false
        return false;
    }

    // No target and we cannot see prone or crouch, so return standing
    m_pawn.m_bWantsToProne = false;
    m_pawn.bWantsToCrouch = false;
    return true;
}

//============================================================================
// ReactToGrenade - 
//============================================================================
function ReactToGrenade( vector vGrenadeLocation )
{
    local vector vDestination;
    local FLOAT  fDistance;
    local FLOAT  fTemp;
    local INT    i;
    local NavigationPoint aDest;

    ChangeDefCon( DEFCON_1 );

    // Get grenade distance
    if( VSize(m_pawn.Location - vGrenadeLocation) > 600 )
        return;

    // Find a random distance from 400 to 800 units (grenades have a radius of 600 units)
    fDistance = RandRange( 400, 1000 );

    // Find a random node far enough from here
    for(i=0; i<C_NumberOfNodeRemembered; i++)
        m_aLastNode[i] = none;

    aDest = GetNextRandomNode();
    i = 0;
    while( VSize(aDest.Location - vGrenadeLocation)<fDistance && i<10 )
    {
        i++;
        aDest = GetNextRandomNode();
    }

    SetReactionStatus( REACTION_Grenade, EVSTATE_DefaultState );
    m_aMovingToDestination = aDest;
    if(!IsInState('TransientStateCode'))
        GotoState( 'TransientStateCode', 'RunFromGrenade' );
}

function PlaySoundAffectedByGrenade(R6Pawn.EGrenadeType eType)
{
    switch(eType)
    {
        case GTYPE_TearGas:
            m_VoicesManager.PlayTerroristVoices(m_pawn, TV_CoughsGas);
            break;
        case GTYPE_Smoke:
            m_VoicesManager.PlayTerroristVoices(m_pawn, TV_CoughsSmoke);
            break;
    }
}

//============================================================================
// AIAffectedByGrenade - 
//============================================================================
function AIAffectedByGrenade( Actor aGrenade, R6Pawn.EGrenadeType eType )
{
    ChangeDefCon( DEFCON_2 );

    m_pawn.m_vGrenadeLocation = aGrenade.Location;

    #ifdefDEBUG if(bShowLog) logX("AIAffectedByGrenade from " $ aGrenade ); #endif
    if(eType==GTYPE_TearGas)
    {
        if(CanSafelyChangeState())
        {
            m_pawn.bWantsToCrouch = false;
            m_pawn.SetNextPendingAction( PENDING_Coughing );
            ReactToGrenade( m_pawn.m_vGrenadeLocation );
        }
    }
    else if(eType==GTYPE_FlashBang || eType==GTYPE_BreachingCharge)
    {
        if(!m_bCantInterruptIO && !CanSafelyChangeState())
            return;
        m_pawn.SetNextPendingAction( PENDING_Blinded );
        GotoState( 'TransientStateCode', 'RecoverFromFlash' );
    }
    else
    {
        if(CanSafelyChangeState())
        {
            // Smoke grenade
            ReactToGrenade( m_pawn.m_vGrenadeLocation );
        }
    }
}

//============================================================================
// TransientStateCode
//      State used when the AI want to execute some latent function
//      but doesn't need a new state
//============================================================================
state TransientStateCode
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( m_eReactionStatus, EVSTATE_DefaultState );
    }

Begin:
RunFromGrenade:
    StopMoving();
    switch(m_pawn.m_iDiffLevel)
    {
        case 1: Sleep(1); break;
        case 2: Sleep(0.5); break;
        case 3: break;
    }
    GotoStateMovingTo( "RunFromGrenade", PACE_Run, true, m_aMovingToDestination,, 'TransientStateCode', 'AfterRunFromGrenade', true );
AfterRunFromGrenade:
    m_bHeardGrenade = false; 
    if(Enemy==none)
        Sleep(3);

    Goto('ResumeAction');

RecoverFromFlash:
    Disable('HearNoise');
    Disable('SeePlayer');
    StopMoving();
    Sleep(5);
    if(m_bCantInterruptIO)
        CheckForInteraction();

ResumeAction:
    if(Enemy!=none)
        GotoState('Attack');
    else
        GotoStateNoThreat();
}

//============================================================================
//  #####  #####  #####    ###    ####   #####   ###   ####    
//  ##     ##     ##      ##  #   ## ##  ##     ##  #  ## ##   
//  #####  ####   ####    #####   ##  #  ####   #####  ##  #   
//     ##  ##     ##      ##  #   ## ##  ##     ##  #  ## ##   
//  #####  #####  #####   ##  #   ####   #####  ##  #  ####    
//============================================================================
function GotoSeeADead( vector vDeadLocation )
{
    m_vThreatLocation = vDeadLocation;
    GotoState('SeeADead');
}

state SeeADead
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
    }

    function EndState()
    {
        m_pawn.m_wWantedHeadYaw = 0;
    }

Begin:
    ChangeDefCon(DEFCON_2);
    // Search a fire spot
    SetActionSpot( FindPlaceToFire( none, m_vThreatLocation, C_MaxDistanceForActionSpot ) );

    // Go to action spot
    if(m_pActionSpot!=none)
        GotoStateMovingTo( "SeeADead:FireSpot", PACE_Run, true, m_pActionSpot,, 'SeeADead', 'AtSpot' );

AtSpot:
    StopMoving();
    if(m_pActionSpot!=none)
        ChangeOrientationTo( m_pActionSpot.Rotation );
    else
    {
        Focus = none;
        FocalPoint = m_vThreatLocation;
    }

    if(m_pActionSpot==none || m_pActionSpot.m_eFire==STAN_Crouching)
        Pawn.bWantsToCrouch = true;

    m_fSearchTime = Level.TimeSeconds + 30;

    #ifdefDEBUG if (bShowLog) logX ( "Wait at spot " $ m_pActionSpot ); #endif
Wait:
    // if the search time is elapsed, end search
    if(m_fSearchTime < Level.TimeSeconds)
    {
        GotoStateEngageBySound( m_vThreatLocation, PACE_Walk, 30 );
    }
    Sleep( RandRange( 1, 3 ) );
    m_pawn.m_wWantedHeadYaw = RandRange( -10000, 10000 )/256;
    Sleep( RandRange( 0.5, 1.5) );
    m_pawn.m_wWantedHeadYaw = 0;
    Goto('Wait');
}

//============================================================================
//  ####   ###   ####  #   #  #####    #####  #####   ###   ####   ####  ##  #   
//  ##  # ##  #   ##   ##  #   ##      ##     ##     ##  #  #   # ##     ##  #   
//  ####  ##  #   ##   # # #   ##      #####  ####   #####  ####  ##     #####   
//  ##    ##  #   ##   #  ##   ##         ##  ##     ##  #  ## #  ##     ##  #   
//  ##     ###   ####  #   #   ##      #####  #####  ##  #  ##  #  ####  ##  #   
//============================================================================
event GotoPointAndSearch(vector vDestination, R6Pawn.EMovementPace ePace, BOOL bCallBackup, OPTIONAL FLOAT fSearchTime, OPTIONAL R6Terrorist.EDefCon eNewDefCon )
{
    #ifdefDEBUG if(bShowLog) logX( "Enter event GotoPointAndSearch"); #endif
 
    if( !CanSafelyChangeState() )
        return;
 
    if(bCallBackup)
    {
        if(MakeBackupList())
            CallBackupForInvestigation( vDestination, ePace );
    }

    if(eNewDefCon!=DEFCON_0)
        ChangeDefCon( eNewDefCon );
    else
        ChangeDefCon( DEFCON_1 );

    if(fSearchTime==0)
        fSearchTime = C_DefaultSearchTime;

    GotoStateEngageBySound( vDestination, ePace, fSearchTime );
}

//============================================================================
// #   #  ###  ##  #  ####  #   #   ####   #####  ###     ###   ##### #####  ###   #### ##  #   
// ## ## ##  # ##  #   ##   ##  #  ##       ##   ##  #   ##  #   ##    ##   ##  # ##    ## #    
// # # # ##  # ##  #   ##   # # #  ## ##    ##   ##  #   #####   ##    ##   ##### ##    ###     
// #   # ##  # ##  #   ##   #  ##  ##  #    ##   ##  #   ##  #   ##    ##   ##  # ##    ## #    
// #   #  ###    ##   ####  #   #   ####    ##    ###    ##  #   ##    ##   ##  #  #### ##  #   
//============================================================================

//============================================================================
// GotoPointAndAttack - 
//============================================================================
event GotoPointToAttack(vector vDestination, actor pTarget )
{
    #ifdefDEBUG if(bShowLog) logX( "Enter event GotoPointToAttack"); #endif
 
    if( !CanSafelyChangeState() )
        return;

    if(m_InteractionObject != none)
    {
        m_bCalledForBackup = true;
        m_vThreatLocation = vDestination;
        Target = pTarget;
        m_InteractionObject.StopInteractionWithEndingActions();
        return;
    }

    if( CheckForInteraction() )
        return;

    // Stop any animation already playing
    m_pawn.m_bPawnSpecificAnimInProgress = false;

    ChangeDefCon( DEFCON_1 );
    m_vThreatLocation = vDestination;
    Target = pTarget;
    SetActionSpot(none);

    m_StateAfterInteraction = 'MovingToAttack';

    GotoState( 'MovingToAttack' );
}

state MovingToAttack
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_SeeRainbow, EVSTATE_DefaultState );
    }

Begin:
    if(m_pActionSpot==none)
        SetActionSpot( FindPlaceToFire( Target, m_vThreatLocation, C_MaxDistanceForActionSpot ) );
    
    if(m_pActionSpot!=none)
    {
        m_pActionSpot.m_pCurrentUser = m_pawn;
        GotoStateMovingTo( "MovingToAttackActionSpot", PACE_Run, true, m_pActionSpot,, 'MovingToAttack', 'AtActionSpot' );
    }
    else
        GotoStateMovingTo( "MovingToAttackThreat", PACE_Run, true,, m_vThreatLocation, 'MovingToAttack', 'AtPosition' );

AtActionSpot:
    MoveToPosition( m_pActionSpot.Location, rotator(Target.Location-m_pActionSpot.Location) );
    if( m_pActionSpot.m_eFire == STAN_Crouching )
        m_pawn.bWantsToCrouch = true;
    else
        m_pawn.bWantsToCrouch = false;
    Goto('Wait');

AtPosition:
    // Turn toward attack target
    FocalPoint = Target.Location;

Wait:
    Sleep(30);
    Sleep(RandRange(1,3));
    GotoStateEngageBySound( m_vThreatLocation, PACE_Walk, C_DefaultSearchTime );
}

//============================================================================
//  ##      ###    #####   #####   #####   ####    ####   ##  #   #####   
//  ##     ##  #   ##       ##     ##       ##    ##      ##  #    ##     
//  ##     ##  #   #####    ##     #####    ##    ## ##   #####    ##     
//  ##     ##  #      ##    ##        ##    ##    ##  #   ##  #    ##     
//  #####   ###    #####    ##     #####   ####    ####   ##  #    ##     
//============================================================================

//============================================================================
// GotoStateLostSight - 
//============================================================================
function GotoStateLostSight( vector vLastSeen )
{
    #ifdefDEBUG if(bShowLog) logX( "Enter function GotoStateLostSight"); #endif
 
    m_vThreatLocation = vLastSeen;

    GotoState( 'LostSight' );
}

state LostSight
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_SeeRainbow, EVSTATE_DefaultState );
    }

Begin:
    if(Enemy!=none)
    {
        m_vTargetPosition = FindBetterShotLocation( Enemy );
        R6PreMoveTo( m_vTargetPosition, Enemy.Location, PACE_Run );
        MoveTo( m_vTargetPosition, Enemy );
        Focus = none;
        FocalPoint = Enemy.Location;
        Goto( 'AtBetterLocation');
    }

AtBetterLocation:
Grenade:
    if( m_pawn.m_bHaveAGrenade )
    {
        if( m_pawn.m_DZone.m_bUseGrenade )
            GotoStateThrowingGrenade( 'LostSight', 'EndThrowingGrenade' );
    }

EndThrowingGrenade:
    SetActionSpot( FindPlaceToFire( none, m_vThreatLocation, C_MaxDistanceForActionSpot ) );
    
    if(m_pActionSpot!=none)
    {
        m_pActionSpot.m_pCurrentUser = m_pawn;
        GotoStateMovingTo( "LostSightActionSpot", PACE_Run, true, m_pActionSpot,, 'LostSight', 'AtActionSpot' );
    }

    // If no spot, stay here and kneel
    m_pawn.bWantsToCrouch = true;
    FocalPoint = m_vThreatLocation;
    Goto( 'Waiting' );

AtActionSpot:
    MoveToPosition( m_pActionSpot.Location, rotator(m_pActionSpot.Location - m_vThreatLocation) );
    if( m_pActionSpot.m_eFire == STAN_Crouching || m_pActionSpot.m_eCover == STAN_Crouching )
        m_pawn.bWantsToCrouch = true;
    else
        m_pawn.bWantsToCrouch = false;

Waiting:
    Sleep(RandRange(0,3));

    // Check for reload
	if( Pawn.EngineWeapon.NumberOfBulletsLeftInClip() < 0.5*Pawn.EngineWeapon.GetClipCapacity())
	{
        SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );

        AIReloadWeapon();
        while(m_pawn.m_bReloadingWeapon)
        {
            Sleep(0.1);
        }

        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
    }

    GotoStateEngageBySound( m_vThreatLocation, PACE_Run, C_DefaultSearchTime );
}

//============================================================================
//  ##### #   #   ####   ###    ####  #####    #####  ####   ####  ##  # #####   
//  ##    ##  #  ##     ##  #  ##     ##       ##      ##   ##     ##  #  ##     
//  ####  # # #  ## ##  #####  ## ##  ####     #####   ##   ## ##  #####  ##     
//  ##    #  ##  ##  #  ##  #  ##  #  ##          ##   ##   ##  #  ##  #  ##     
//  ##### #   #   ####  ##  #   ####  #####    #####  ####   ####  ##  #  ##     
//============================================================================
function EngageBySight( Pawn aPawn )
{
    #ifdefDEBUG if(bShowLog) logX("Enter function EngageBySight"); #endif
    SetEnemy( aPawn );
    Target = aPawn;
    GotoState('PrecombatAction');
}

function EEngageReaction GetEngageReaction( Pawn pEnemy, INT iNbTerro, INT iNbRainbow )
{
    local BOOL bOutnumbered;

    // Uncomment one line to force a reaction
    //return EREACT_AimedFire;    logX("Force reaction AimedFire");
    //return EREACT_SprayFire;    logX("Force reaction SprayFire");
    //return EREACT_RunAway;      logX("Force reaction RunAway");
    //return EREACT_Surrender;    logX("Force reaction Surrender");

    if(m_eEngageReaction != EREACT_Random )
    {
        return m_eEngageReaction;
    }

    if( Pawn.m_bDroppedWeapon || Pawn.EngineWeapon==none )
        return EREACT_Surrender;

    // Sniper always engage by aimed fire
    if( m_pawn.m_ePersonality == PERSO_Sniper )
    {
        return EREACT_AimedFire;
    }

    // Check terrorist reaction
    m_iRandomNumber = Rand(100)+1;  // 1 to 100

    #ifdefDEBUG
    if(bShowLog) logX( "GetEngageReaction. Nb Terro: " $ iNbTerro $ " Nb Rainbow: " $ iNbRainbow $
                        " Terro personality: " $ m_pawn.m_ePersonality $ " Random nb:" $ m_iRandomNumber );
    #endif

    switch(m_pawn.m_ePersonality)
    {
        case PERSO_Coward:          m_iRandomNumber -= 40;  break;
        case PERSO_DeskJockey:      m_iRandomNumber -= 20;  break;
        case PERSO_Normal:                                  break;
        case PERSO_Hardened:        m_iRandomNumber += 20;  break;
        case PERSO_SuicideBomber:   m_iRandomNumber += 40;  break;
    }

    // Check if outnumbered greater than 2 for 1
    if( (m_iTerroristInGroup+1)*2 < m_iRainbowInCombat )
    {
        #ifdefDEBUG if (bShowLog) logX ( "Outnumbered" ); #endif
        bOutnumbered = true;
    }

    // Return the choosen reaction
    if( bOutnumbered )
    {
        if(m_iRandomNumber>=81)
            return EREACT_AimedFire;    // 81-100
        if(m_iRandomNumber>=41)
            return EREACT_SprayFire;    // 41-80
        if(m_iRandomNumber>=11)
            return EREACT_RunAway;      // 11-40
        else
        {
            // Don't surrender if enemy is farther than 10m
            if(VSize(Pawn.Location-pEnemy.Location) < 1000 )
                return EREACT_Surrender;    //  1-10
            else
                return EREACT_RunAway;
        }
    }
    else
    {
        if(m_iRandomNumber>=61)
            return EREACT_AimedFire;    // 61-100
        if(m_iRandomNumber>=11)
            return EREACT_SprayFire;    // 11-60
        else
            return EREACT_RunAway;      //  1-10
    }

    return EREACT_Surrender;
}

function BOOL CheckForInteraction()
{
    local Actor aGoal;

    // Check for associated interactive object
    if( m_TriggeredIO != none )
    {
        m_bCantInterruptIO = true;
        SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );

        if(m_TriggeredIO.m_Anchor != none)
            aGoal = m_TriggeredIO.m_Anchor;
        else
            aGoal = m_TriggeredIO;

        GotoStateMovingTo( "InteractionObject", PACE_Run, false, aGoal,, 'PrecombatAction', 'InteractiveObject', true );
        return true;
    }

    // Check for associated hostage
    if( Pawn.m_bDroppedWeapon || m_pawn.EngineWeapon==none )
        return false;

    if( !UseRandomHostage() )
        m_hostage = m_pawn.m_DZone.GetClosestHostage( m_pawn.Location );

    if(m_Hostage!=none && !m_Hostage.m_bExtracted )
    {
        if( rand(100) < GetKillingHostageChance() )
        {
            // Attack closest hostage of the list
            #ifdefDEBUG if(bShowLog) logX("Attack hostage " $ Enemy.name ); #endif
            GotoStateAttackHostage( m_Hostage );
            return true;
        }
    }

    return false;
}

state PrecombatAction
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );
    }

Begin:
    m_pawn.m_bSkipTick = false;
    ChangeDefCon( DEFCON_1 );

    CheckForInteraction();
    Goto('AfterInteraction');

InteractiveObject:
    StopMoving();
    while(m_TriggeredIO.m_InteractionOwner != none)
    {
        if(!m_TriggeredIO.m_InteractionOwner.Pawn.IsAlive())
            m_TriggeredIO.m_InteractionOwner = none;
        else
            Sleep(0.5);
    }

    m_TriggeredIO.PerformAction( m_pawn );
    m_TriggeredIO = none;
    Sleep(1.0);
    if(Enemy==none)
        GotoStateNoThreat();

AfterInteraction:
    // If we are surrendered, go back to that state
    if(m_pawn.m_bIsKneeling || m_pawn.m_bIsUnderArrest)
        GotoState('Surrender');

    StopMoving();
    // Enemy variable setting
    LastSeenTime = Level.TimeSeconds;
    LastSeenPos = Enemy.Location;

    if( !Pawn.m_bDroppedWeapon && Pawn.EngineWeapon!=none )
    {
        // Check if already engaged
        if(m_eAttackMode!=ATTACK_NotEngaged)
        {
            #ifdefDEBUG if(bShowLog) logX( "Already engaged. AttackMode: " $ m_eAttackMode ); #endif
            if(m_eAttackMode==ATTACK_SprayFireMove)
                m_eAttackMode = ATTACK_SprayFireNoStop;
            GotoState('Attack');
        }
    }
    
    if(MakeBackupList())
    {
        if( AIPlayCallBackup( Enemy ) )
        {
            Sleep(1.0);
            CallBackupForAttack( Enemy.Location, PACE_Run );
            FinishAnim(m_pawn.C_iPawnSpecificChannel);
        }
        else
        {
            //Sleep(0.1);
            CallBackupForAttack( Enemy.Location, PACE_Run );
        }
    }

Grenade:
    if(m_pawn.m_bHaveAGrenade)
    {
        if( m_pawn.m_DZone.m_bUseGrenade )
        {
            if( Rand(100) + 1 < m_pawn.m_DZone.m_iChanceToUseGrenadeAtFirstReaction )
                GotoStateThrowingGrenade( 'PrecombatAction', 'Reaction' );
        }
    }

Reaction:
    // Ask Rainbow Pawn how many they are
    if( R6RainbowAI(Enemy.Controller) != none )
    {
        m_iRainbowInCombat = R6RainbowAI(Enemy.Controller).m_TeamManager.m_iMemberCount;
    }
    else if( R6PlayerController(Enemy.Controller) != none )
    {
        m_iRainbowInCombat = R6PlayerController(Enemy.Controller).m_TeamManager.m_iMemberCount;
    }
    #ifdefDEBUG 
    else
    {
        m_pawn.logWarning("Enemy doesn't have a R6RainbowAI controller or a R6PlayerController" );
    }
    #endif
    

    switch(GetEngageReaction( Enemy, m_iTerroristInGroup, m_iRainbowInCombat ))
    {
        case EREACT_AimedFire:
            PlayAttackVoices();
            GotoStateAimedFire();
            break;
        case EREACT_SprayFire:
            PlayAttackVoices();
            GotoStateSprayFire();
            break;
        case EREACT_RunAway:
            m_VoicesManager.PlayTerroristVoices(m_pawn, TV_RunAway);
            GotoState( 'RunAway' );
            break;
        case EREACT_Surrender:
            m_VoicesManager.PlayTerroristVoices(m_pawn, TV_Surrender);
            GotoState( 'Surrender' );
            break;
    }
}

//============================================================================
// PlayAttackVoices - 
//============================================================================
function PlayAttackVoices()
{
    local INT iAngle;

    // If angle is greater than 16000, they are face to face, yell
    if( ShortestAngle2D( Enemy.Rotation.Yaw, m_pawn.Rotation.Yaw ) > 13000 )
    {
        if (m_pawn.m_eDefCon >=  DEFCON_3)
            m_VoicesManager.PlayTerroristVoices(m_pawn, TV_SeesRainbow_LowAlert);
        else
            m_VoicesManager.PlayTerroristVoices(m_pawn, TV_SeesRainbow_HighAlert);
    }
}

//------------------------------------------------------------------
// PawnDied: called when the pawn is declared dead 
//------------------------------------------------------------------
function PawnDied()
{
    // If we are on a team following a path, inform the path that we died
    if(m_path!=None && !Level.m_bIsResettingLevel )
    {
        m_path.InformTerroTeam(INFO_Dead, Self);
    }

    Super.PawnDied();
} 

//============================================================================
//   ####    ###    #   #   #####    ####    ####
//  ##      ##  #   ##  #   ##        ##    ##   
//  ##      ##  #   # # #   ####      ##    ## ##
//  ##      ##  #   #  ##   ##        ##    ##  #
//   ####    ###    #   #   ##       ####    ####
///============================================================================
auto state Configuration
{
#ifdefDEBUG
    function BeginState()
    {
        if (bShowLog)
        {
            log( ": ==========================================");
            log( name $ ": enter STATE Configuration");
            log( ": ==========================================");
        }
    }
#endif

Begin:
    // Set the R6Terrorist pawn
    m_pawn = R6Terrorist(Pawn);
    m_pawn.m_controller = Self;
    #ifdefDEBUG if(bShowLog) logX( Self.Name $ " == " $ m_pawn.Name ); #endif
    
    // Set the manager
    m_Manager = R6TerroristMgr( level.GetTerroristMgr() );

    while( !m_pawn.m_bInitFinished )
    {
        #ifdefDEBUG if(bShowLog) logX( "Sleeping..."); #endif
        Sleep(0.5);
    }

    m_vSpawningPosition = m_pawn.Location;
    m_rSpawningRotation = m_pawn.Rotation;

    m_eEngageReaction = m_pawn.m_DZone.m_eEngageReaction;
    ChangeDefCon( m_pawn.m_eDefCon );

    // Some check for path validation
    if( m_pawn.m_eStrategy == STRATEGY_PatrolPath)
    {
        // Set m_path
        m_path = R6DZonePath(m_pawn.m_DZone);
        assert(m_path != None);

        if( m_path.m_aNode.Length < 2 )
        {
            #ifdefDEBUG m_pawn.logWarning( "Path " $ m_path.name $ " have " $ m_path.m_aNode.Length $ " nodes." ); #endif
            m_pawn.m_eStrategy = STRATEGY_GuardPoint;
        }
    }

    // Check for hostage assignment
    if(UseRandomHostage())
        AssignNearHostage();

    m_TriggeredIO = m_pawn.m_DZone.m_InteractiveObject;

    //GotoState('Test');
    GotoStateNoThreat();
}

//============================================================================
// AIPlayCallBackup - 
//   - Return true if we must wait for the end of the animation
//============================================================================
function BOOL AIPlayCallBackup( actor pEnemy )
{
    local INT iShootingChance;
    local INT iAnimID;

    // Check distance with enemy
    if( VSize( Pawn.Location - pEnemy.Location ) < 400 )
    {
        iShootingChance = 100;
    }
    else
    {
        switch(m_pawn.m_iDiffLevel)
        {
            case 1: iShootingChance = 50; break;
            case 2: iShootingChance = 70; break;
            case 3: iShootingChance = 90; break;
        }
    }

    if( rand(100) < iShootingChance )
        iAnimID = 0;            // 'StandYellAlarm'
    else
        iAnimID = 1;            // 'StandYellAlarmFireHandGun'

    m_pawn.SetNextPendingAction( PENDING_CallBackup, iAnimID );
    m_VoicesManager.PlayTerroristVoices( m_pawn, TV_Backup);

    if(iAnimID==0)
        return false;

    return true;
}

//============================================================================
// DispatchOrder - 
//============================================================================
function DispatchOrder( INT iOrder, R6Pawn pSource )
{
    #ifdefDEBUG if(bShowLog) logX( "DispatchOrder: " $ iOrder @ pSource.Name ); #endif

    switch( iOrder )
    {
        case m_pawn.ETerroristCircumstantialAction.CAT_Secure:
            SecureTerrorist( pSource );
            break;

        default:
            assert( false ); // unknow ETerroristCircumstantialAction
    }
}

//============================================================================
//   ####   ####    #####   #   #    ###    ####    #####   
//  ##      #   #   ##      ##  #   ##  #   ## ##   ##      
//  ## ##   ####    ####    # # #   #####   ##  #   ####    
//  ##  #   ## #    ##      #  ##   ##  #   ## ##   ##      
//   ####   ##  #   #####   #   #   ##  #   ####    #####   
//============================================================================
function GotoStateThrowingGrenade( name nNextState, name nNextLabel )
{
    NextState = nNextState;
    NextLabel = nNextLabel;
    GotoState('ThrowingGrenade');
}

state ThrowingGrenade
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );
        Focus = Enemy;
    }

    function EndState()
    {
        Focus = none;
        FocalPoint = Enemy.Location;
    }

    function CheckDistance()
    {
        local vector vDir;
        local FLOAT fDist;

        vDir = Enemy.Location - m_pawn.Location;

        // If farther than 1500 units, approach before throwing
        fDist = VSize(vDir);
        if( fDist > 1500 )
        {

            vDir = Normal(vDir);
            vDir = m_pawn.Location + vDir * (fDist-1400);

            GotoStateMovingTo( "ThrowingGrenade", PACE_Run, true,, vDir, 'ThrowingGrenade', 'Throw' );
        }
    }

    event bool NotifyBump(Actor other)
    {
        return true;
    }

begin:
    CheckDistance();

Throw:
    if( VSize(Enemy.Location-m_pawn.Location) > 1500 )
        Goto('Exit');

    Target = Enemy;
    StopMoving();
    if(m_pawn.bIsCrouched)
    {
        m_pawn.bWantsToCrouch = false;
        Sleep(0.1);
    }
    FinishRotation();
   
    // Throw a grenade
    m_pawn.SetToGrenade();
    m_pawn.PlayWeaponAnimation();
    m_pawn.SetNextPendingAction( PENDING_ThrowGrenade );
    FinishAnim( m_pawn.C_iPawnSpecificChannel );
    m_pawn.SetToNormalWeapon();
    m_pawn.PlayWeaponAnimation();

    // wait for grenade to explode...
    Sleep(2.0);

Exit:
    GotoState( NextState, NextLabel );
}

//============================================================================
//  #   #    ###      #####   ##  #   ####    #####    ###    #####   
//  ##  #   ##  #      ##     ##  #   #   #   ##      ##  #    ##     
//  # # #   ##  #      ##     #####   ####    ####    #####    ##     
//  #  ##   ##  #      ##     ##  #   ## #    ##      ##  #    ##     
//  #   #    ###       ##     ##  #   ##  #   #####   ##  #    ##     
//============================================================================
function GotoStateNoThreat()
{
    if( m_pawn.IsAlive() )
        GotoState('NoThreat');
    else
        GotoState('Dead');
}

state NoThreat
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
    }

Begin:
    // If we are surrendered, go back to that state
    if(m_pawn.m_bIsKneeling || m_pawn.m_bIsUnderArrest)
        GotoState('Surrender');
    
    Pawn.SetMovementPhysics();

    // Variables re-initialistion when there is no more threat
    m_eAttackMode = ATTACK_NotEngaged;
    m_pawn.m_bSprayFire = false;
    StopMoving();
    if(m_pawn.m_ePersonality != PERSO_Sniper)
    {
        m_pawn.bWantsToCrouch = false;
        m_pawn.m_bIsSniping   = false;
    }
    else
    {
        m_pawn.m_bIsSniping  = true;
        m_pawn.m_bCanProne   = true;
        m_pawn.m_bAllowLeave = false;   // A sniper cannot leave his area
    }
    m_pawn.m_bSkipTick      = true;
    m_pawn.m_bIsKneeling    = false;
    m_pawn.m_bIsUnderArrest = false;
    m_bAlreadyHeardSound    = false;

    m_TerroristLeader   = none;
    m_iCurrentGroupID   = 0;
    m_HostageAI         = none;
    SetEnemy( none );
    m_iChanceToDetectShooter = 0;
    SetActionSpot(none);

    if(!UseRandomHostage())
        m_Hostage = none;
    
    if(m_pawn.m_eDefCon <= DEFCON_2)
        ChangeDefCon( DEFCON_2 );

    for(m_iRandomNumber=0; m_iRandomNumber<C_NumberOfNodeRemembered; m_iRandomNumber++)
    {
        m_aLastNode[m_iRandomNumber] = none;        
    }

    // All initialisation should be done before we reach this point, because the InteractiveObject can
    // take control of the pawn will he is waiting for the game to start
    while( !level.Game.m_bGameStarted )
    {
        #ifdefDEBUG if(bShowLog) logX( "Sleeping..."); #endif
        Sleep(0.5);
    }
    
    // Check Ammo
    if( Pawn.m_bDroppedWeapon || Pawn.EngineWeapon==none || Pawn.EngineWeapon.GunIsFull() )
        Goto('ChooseState');

Reload:
    SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );
    #ifdefDEBUG if (bShowLog) logX( Pawn.EngineWeapon.NumberOfBulletsLeftInClip() $ "ammo left in clip, reload..." $ Pawn.EngineWeapon.GetNbOfClips() $ " clip left" ); #endif

    while( !(Pawn.EngineWeapon.GunIsFull()) )
    {
        Sleep(0.1);
        AIReloadWeapon();
        while(m_pawn.m_bReloadingWeapon)
        {
            Sleep(0.1);
        }
    }

    SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );

ChooseState:
    // Go to the correct starting state
    switch(m_pawn.m_eStrategy)
    {
        case STRATEGY_PatrolPath:
            GotoState('PatrolPath');
            break;
        case STRATEGY_PatrolArea:
            GotoState('PatrolArea');
            break;
        case STRATEGY_GuardPoint:
            GotoState('GuardPoint');
            break;
        case STRATEGY_Hunt:
            GotoState('HuntRainbow');
            break;
        case STRATEGY_Test:
            GotoState('Test');
    }
}

//============================================================================
//  #   #    ###    ##  #    ####   #   #    ####           #####    ###    
//  ## ##   ##  #   ##  #     ##    ##  #   ##               ##     ##  #   
//  # # #   ##  #   ##  #     ##    # # #   ## ##            ##     ##  #   
//  #   #   ##  #   ##  #     ##    #  ##   ##  #            ##     ##  #   
//  #   #    ###      ##     ####   #   #    ####            ##      ###    
//============================================================================

//============================================================================
// GotoStateMoveToDestination - 
//============================================================================
function GotoStateMovingTo( string sDebugString, R6Pawn.EMovementPace ePace, BOOL bCanFail, optional actor aMoveTarget, optional Vector vDestination, optional name stateAfter, optional name labelAfter, optional BOOL bDontCheckLeave, optional BOOL bPreciseMove )
{
    local vector vHitNormal;

    #ifdefDEBUG if(bShowLog) logX( "Enter function GotoStateMovingTo ("  $ sDebugString $ "). Destination:" $ vDestination $ " Target: " $ aMoveTarget $ " pace: " $ ePace $ " nextstate:" $ stateAfter $ " label:" $ labelAfter $ " CanFail: " $ bCanFail ); #endif

    if(aMoveTarget==none && vDestination==vect(0,0,0))
    {
        logX("Call to GotoStateMovingTo with no aMoveTarget or vDestination");
        GotoState( stateAfter, labelAfter );
    }
    
    CheckPaceForInjury(ePace);
    m_aMovingToDestination = aMoveTarget;
    if(m_aMovingToDestination!=none)
    {
        m_vMovingDestination = m_aMovingToDestination.Location;
    }
    else
    {
        // Put destination 80 unit above ground for easier navigation
        if(Trace( m_vMovingDestination, vHitNormal, vDestination - Vect(0,0,200), vDestination )!=none)
            m_vMovingDestination.Z += 80;
        else
            m_vMovingDestination = vDestination;
    }

    m_bCanFailMovingTo = bCanFail;
    m_pawn.m_eMovementPace = ePace;
    m_stateAfterMovingTo = stateAfter;
    m_labelAfterMovingTo = labelAfter;
    m_bPreciseMove = bPreciseMove;

    // If pawn not allowed to leave his area, check that the point is in it
    if( !bDontCheckLeave && !m_pawn.m_bAllowLeave && !m_pawn.m_DZone.IsPointInZone(m_vMovingDestination) )
    {
        #ifdefDEBUG if(bShowLog) logX( "Cannot go to " $ m_vMovingDestination $ ", point not in zone and not allowed to leave" ); #endif
        // Find closest replacement point in the zone
        if( R6DZoneRandomPoints(m_pawn.m_DZone) == none )
            m_vMovingDestination = m_pawn.m_DZone.FindClosestPointTo( m_vMovingDestination );
        else if( R6DZoneRandomPoints(m_pawn.m_DZone).m_bUseAllowLeave )
            m_vMovingDestination = m_vSpawningPosition;
        else
            m_vMovingDestination = m_pawn.m_DZone.FindClosestPointTo( m_vMovingDestination );
        #ifdefDEBUG if(bShowLog) logX( "Go to " $ m_vMovingDestination $ " instead." ); #endif
    }

    GotoState('MovingTo');
    m_sDebugString = sDebugString;
}

state MovingTo
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( m_eReactionStatus, m_eStateForEvent );
        if(m_pawn.m_eMovementPace==PACE_Run)
        {
            m_pawn.m_ePlayerIsUsingHands = HANDS_Both;
            m_pawn.PlayWeaponAnimation();
        }
    }

    function EndState()
    {
        if(m_pawn.m_eMovementPace==PACE_Run)
        {
            m_pawn.m_ePlayerIsUsingHands = HANDS_None;
            m_pawn.PlayWeaponAnimation();
        }
        SetTimer(0,false);
        m_pawn.m_wWantedHeadYaw = 0;
    }

    event bool NotifyBump(Actor other)
    {
        local R6Pawn aPawn;

        aPawn = R6Pawn(other);
        if(aPawn!=none)
        {
            if(aPawn.m_ePawnType == PAWN_Rainbow)
                GotoState('MovingTo', 'Exit');
            else if(aPawn.m_ePawnType == PAWN_Terrorist)
            {
                if(aPawn!=m_LastBumped)
                {
                    m_LastBumped = aPawn;
                    m_fLastBumpedTime = Level.TimeSeconds;
                }
                else
                {
                    if( Level.TimeSeconds >  m_fLastBumpedTime + 0.3f + RandRange(0.1f, 0.3f) )
                    {
                        if(m_bCanFailMovingTo && m_LastBumped.Velocity==vect(0,0,0))
                            GotoState('MovingTo', 'Exit');
                        else
                        {
                            if( m_bCantInterruptIO && R6TerroristAI(aPawn.Controller)!=none )
                                R6TerroristAI(aPawn.Controller).GotoBumpBackUpState(aPawn.Controller.GetStateName());
                            GotoState('MovingTo', 'WaitLastBumped');
                        }
                        return true;
                    }
                }
            }
        }

        return false;
    }

    function bool GetReacheablePoint( OUT vector vTarget )
    {
        local vector vDirection;
        local FLOAT fTemp;

        // Try back
        vDirection = Pawn.Location - m_LastBumped.Location;
        vDirection.Z = 0;
        vDirection = Normal(vDirection) * Pawn.CollisionRadius * 4;
        vTarget = Pawn.Location + vDirection;
        if( pointReachable( vTarget ) )
            return true;

        // Try left
        fTemp = -vDirection.X;
        vDirection.X = vDirection.Y;
        vDirection.Y = fTemp;
        vTarget = Pawn.Location + vDirection;
        if( pointReachable( vTarget ) )
            return true;

        // Try right
        vDirection.X = -vDirection.X;
        vDirection.Y = -vDirection.Y;
        vTarget = Pawn.Location + vDirection;
        if( pointReachable( vTarget ) )
            return true;

        return false;
    }

    event Timer()
    {
        m_iStateVariable++;

        switch(m_iStateVariable)
        {
            case 4:
                m_iStateVariable = 0;
            case 0:
            case 2:
                m_pawn.m_wWantedHeadYaw = 0;
                SetTimer( RandRange(1,2), false );
                break;
            case 1:
                m_pawn.m_wWantedHeadYaw = RandRange(3500, 10000)/256;
                SetTimer( RandRange(0.5, 1.5), false );
                break;
            case 3:
                m_pawn.m_wWantedHeadYaw = RandRange(-10000, -3500)/256;
                SetTimer( RandRange(0.5, 1.5), false );
                break;
        }
    }

Begin:
    // The first time, the pawn will turn toward is direction before moving
    m_iRandomNumber = 0;
    m_wBadMoveCount = 0;

    if ( VSize(m_vMovingDestination - Pawn.Location) < 10.0f )
        Goto('Exit');

    // Don't want to look around if running/walking crouch
    if(m_pawn.m_eMovementPace==PACE_Walk)
    {
        // m_iStateVariable is used to know where to look next.  Step are:
        //   0=straight, 1=left, 2=straight, 3=right
        if(rand(2)==0)
            m_iStateVariable = 0;
        else
            m_iStateVariable = 2;

        SetTimer( RandRange(1,2), false );
    }

    if( m_pawn.bWantsToCrouch )
    {
        m_pawn.bWantsToCrouch = false;
        // Let some time for the physics to start uncrouching
        Sleep(0.1);
    }
    m_iRandomNumber=0;

PathFinding:
    if( (m_aMovingToDestination!=none && actorReachable(m_aMovingToDestination))
        || pointReachable(m_vMovingDestination) )
    {
        goto('EndPath');
    }

    if(m_aMovingToDestination!=none)
        MoveTarget = findPathToward( m_aMovingToDestination );
    else
	    MoveTarget = FindPathTo( m_vMovingDestination, true );     

    if(MoveTarget == none)
    {
        #ifdefDEBUG
        if(m_aMovingToDestination!=none)
        {
            m_pawn.logWarning( "at " $ m_pawn.Location $ " cannot find a path to " $ m_aMovingToDestination
            $ " current anchor: " $ m_pawn.Anchor $ " (" $m_sDebugString$ ")" );
            m_sDebugString = "No path to " $ m_aMovingToDestination;
        }
        else
        {
            m_pawn.logWarning( "at " $ m_pawn.Location $ " cannot find a path to " $ m_vMovingDestination
            $ " current anchor: " $ m_pawn.Anchor $ " (" $m_sDebugString$ ")" );
            m_sDebugString = "No path to " $ m_vMovingDestination;
        }
        #endif
        Sleep(0.5);
        goto('Exit');
    }

    // If it's the first move and we are at low defcon, turn toward direction before starting
    if( m_iRandomNumber==0 && m_pawn.m_eDefCon > DEFCON_2 )
    {
        m_iRandomNumber = 1;
        FocalPoint = MoveTarget.Location;
        FinishRotation();
    }

    R6PreMoveTo( MoveTarget.Location, MoveTarget.Location, m_pawn.m_eMovementPace );
    moveToward( MoveTarget );
    if( m_eMoveToResult == eMoveTo_failed )
    {
        m_wBadMoveCount++;
        if(m_bCanFailMovingTo && m_wBadMoveCount>2)
            goto( 'Exit' );
    }
    else
        m_wBadMoveCount = 0;

    goto('PathFinding');

EndPath:
    // If it's the first move and we are at low defcon, turn toward direction before starting
    if( m_iRandomNumber==0 && m_pawn.m_eDefCon > DEFCON_2 )
    {
        m_iRandomNumber = 1;
        FocalPoint = m_vMovingDestination;
        FinishRotation();
    }

    R6PreMoveTo( m_vMovingDestination, m_vMovingDestination, m_pawn.m_eMovementPace );
    if(m_aMovingToDestination!=none)
        moveToward( m_aMovingToDestination );
    else
        MoveTo( m_vMovingDestination );

Exit:
    if(!m_bCanFailMovingTo)
    {
        // Check if we really are at destination
        if(m_aMovingToDestination!=none)
        {
            if( VSize(m_vMovingDestination - Pawn.Location) > Pawn.CollisionRadius + m_aMovingToDestination.CollisionRadius + 10.f )
                Goto('Begin');
        }
        else
        {
            if( VSize(m_vMovingDestination - Pawn.Location) > Pawn.CollisionRadius*2.f )
                Goto('Begin');
        }
    }
    StopMoving();
    GotoState( m_stateAfterMovingTo, m_labelAfterMovingTo );

WaitLastBumped:
    if( GetReacheablePoint(m_vTargetPosition) )
    {
        m_sDebugString = "Bumped away";
        R6PreMoveTo( m_vTargetPosition, m_vTargetPosition, m_pawn.m_eMovementPace );
        MoveTo( m_vTargetPosition );
    }
    StopMoving();
    if(MoveTarget!=none)
        FocalPoint = MoveTarget.Location;
    m_sDebugString = "WaitLastBumped";
    if(m_bCanFailMovingTo)
        Sleep( RandRange(0,2) );

    m_LastBumped = none;
    m_sDebugString = "";
    
    Goto('Begin');
}


//============================================================================
//  #####   ##  #   ####    #####    ###    #####   
//   ##     ##  #   #   #   ##      ##  #    ##     
//   ##     #####   ####    ####    #####    ##     
//   ##     ##  #   ## #    ##      ##  #    ##     
//   ##     ##  #   ##  #   #####   ##  #    ##     
//============================================================================
event GotoStateEngageByThreat( vector vThreathLocation )
{
    if( !CanSafelyChangeState() )
        return;

    m_vThreatLocation = vThreathLocation;
    m_fSearchTime = Level.TimeSeconds + 20;
    GotoState('EngageByThreat');
}

state EngageByThreat
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif

        SetReactionStatus( REACTION_SeeRainbow, EVSTATE_DefaultState );
    }
    function EndState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Exit STATE"); #endif

        m_pawn.bRotateToDesired = true;
        m_pawn.bPhysicsAnimUpdate = true;
        m_pawn.m_wWantedHeadYaw = 0;
    }

Begin:
    Sleep( RandRange(0.1, 0.2) );
    ChangeDefCon( DEFCON_1 );

    // Make a path to closest cover
    SetActionSpot( FindPlaceToTakeCover( m_vThreatLocation, C_MaxDistanceForActionSpot ) );
    if(m_pActionSpot!=none)
    {
        GotoStateMovingTo( "ThreatActionSpot", PACE_Run, true, m_pActionSpot,, 'EngageByThreat', 'ReachedCover');
    }
    else
    {
        #ifdefDEBUG if(bShowLog) logX("No cover spot.  Crouch and wait."); #endif
        if(!m_pawn.m_bPreventCrouching)
            Pawn.bWantsToCrouch = true;
        Focus = none;
        FocalPoint = m_vThreatLocation;
        StopMoving();
        SetReactionStatus( REACTION_HearBullet, EVSTATE_DefaultState );
        Goto('Wait');
    }

ReachedCover:
    if( m_pActionSpot.m_eCover!=STAN_None )
    {
        if( m_pActionSpot.m_eCover == STAN_Standing )
            m_r6pawn.bWantsToCrouch = false;
        else
            m_r6pawn.bWantsToCrouch = true;
    }
    else if( m_pActionSpot.m_eFire == STAN_Standing )
        m_r6pawn.bWantsToCrouch = false;
    else
        m_r6pawn.bWantsToCrouch = true;

    // Move to the exact location
    moveToPosition( m_pActionSpot.Location, m_pActionSpot.Rotation );
    Focus = none;
    FocalPoint = m_vThreatLocation;
    StopMoving();
    SetReactionStatus( REACTION_HearBullet, EVSTATE_DefaultState );

Wait:
    // if the search time is elapsed, end search
    if(m_fSearchTime < Level.TimeSeconds)
    {
        GotoStateNoThreat();
    }

    // Chance of looking around
    if(rand(3)==0)
    {
        m_pawn.m_wWantedHeadYaw = RandRange( -10000, 10000 )/256;
        Sleep( RandRange(1,2.5) );
    }
    m_pawn.m_wWantedHeadYaw = 0;
    Sleep( RandRange(1,5) );
    Goto('Wait');
}

//============================================================================
//  #####    ###    ##  #   #   #   ####    
//  ##      ##  #   ##  #   ##  #   ## ##   
//  #####   ##  #   ##  #   # # #   ##  #   
//     ##   ##  #   ##  #   #  ##   ## ##   
//  #####    ###    #####   #   #   ####    
//============================================================================
function GotoStateEngageBySound( vector vInvestigateDestination, R6Pawn.eMovementPace ePace, FLOAT fSearchTime )
{
    m_vThreatLocation = vInvestigateDestination;
    m_pawn.m_eMovementPace = ePace;
    m_fSearchTime = Level.TimeSeconds + fSearchTime;
    #ifdefDEBUG if (bShowLog) logX ( "Function GSEngageBySound. vThreat: " $ m_vThreatLocation $ ", pace: " $ m_pawn.m_eMovementPace $ ", time: " $ m_fSearchTime ); #endif
    GotoState('EngageBySound');
}

state EngageBySound
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE" ); #endif
        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
        m_pawn.m_bAvoidFacingWalls = true;
    }

    function EndState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "End STATE"); #endif
        m_vHostageReactionDirection = vect(0,0,0);
        m_pawn.m_wWantedHeadYaw = 0;
        m_pawn.m_bAvoidFacingWalls = false;
    }

    function vector ChooseARandomPoint()
    {
        SetActionSpot( FindInvestigationPoint( m_iCurrentGroupID, C_MaxDistanceForActionSpot ) );
        if( m_pActionSpot==none )
        {
            #ifdefDEBUG if(bShowLog) logX("Choose random: " $ m_pActionSpot $ " for group " $ m_iCurrentGroupID ); #endif
            return GetNextRandomNode().Location;
        }

        m_pActionSpot.m_iLastInvestigateID = m_iCurrentGroupID;
        return m_pActionSpot.Location;
    }

Begin:
    // Turn toward threat before doing anything else
    StopMoving();
    Focus = none;
    FocalPoint = m_vThreatLocation;
    FinishRotation();
    Sleep( RandRange(0.25, 0.5) );
    m_pawn.TurnAwayFromNearbyWalls();
    Sleep( RandRange(0.25, 1.0) );

    // if the search time is elapsed, end search
    if(m_fSearchTime < Level.TimeSeconds)
    {
        Goto('Exit');
    }

    if( !m_pawn.m_bAllowLeave )
    {
        Goto('GoCloserAndLook');
    }

    // Find the closest investigation point from the threat location
    SetActionSpot( FindInvestigationPoint( m_iCurrentGroupID, C_MaxDistanceForActionSpot, true, m_vThreatLocation ) );
    if( m_pActionSpot!= none )
    {
        #ifdefDEBUG if(bShowLog) logX("Choose first spot: " $ m_pActionSpot $ " for group " $ m_iCurrentGroupID ); #endif
        m_pActionSpot.m_iLastInvestigateID = m_iCurrentGroupID;
        GotoStateMovingTo( "SoundActionSpot", m_pawn.m_eMovementPace, true, m_pActionSpot,, 'EngageBySound', 'AtDestination' );
    }
    else
    {
        // Goto the m_vThreatLocation, set to the sound origin or the last position of
        // the enemy.  m_eMovementPace should be set before entering the function
        GotoStateMovingTo( "SoundThreatLocation", m_pawn.m_eMovementPace, true,, m_vThreatLocation, 'EngageBySound', 'AtDestination' );
    }

AtDestination:
    m_pawn.m_eMovementPace = PACE_Walk;
    //if(m_TerroristLeader != Self)
        Goto('AtRandomPoint');

WaitHere:
    // if the search time is elapsed, end search
    if(m_fSearchTime < Level.TimeSeconds)
    {
        Goto('Exit');
    }

    if(rand(4)==0)
    {
        ChangeOrientationTo( ChooseRandomDirection(50) );
        Sleep( RandRange(2,4) );
    }
    if(rand(2)==0)
    {
        m_pawn.m_wWantedHeadYaw = RandRange( -10000, 10000 )/256;
        Sleep( RandRange(1,2.5) );
        m_pawn.m_wWantedHeadYaw = 0;
    }
    Sleep( RandRange(1,4) );
    Goto('WaitHere');

ChooseDestination:
    // if the search time is elapsed, end search
    if(m_fSearchTime < Level.TimeSeconds)
    {
        Goto('Exit');
    }

    Destination = ChooseARandomPoint();
    #ifdefDEBUG if(bShowLog) logX ( "At " $ Pawn.Location $ ", choose to wander to " $ Destination ); #endif

    GotoStateMovingTo( "EBSRndPoint", m_pawn.m_eMovementPace, true,, Destination, 'EngageBySound', 'AtRandomPoint' );
    
AtRandomPoint:
    if(m_pActionSpot!=none)
        ChangeOrientationTo( m_pActionSpot.Rotation );
        
    if(rand(2)==0)
    {
        m_pawn.m_wWantedHeadYaw = RandRange( 5000, 10000 )/256;
        Sleep( RandRange(1,2.5) );
        m_pawn.m_wWantedHeadYaw = RandRange( -10000, -5000 )/256;
        Sleep( RandRange(1,2.5) );
    }
    else
    {
        m_pawn.m_wWantedHeadYaw = RandRange( -10000, -5000 )/256;
        Sleep( RandRange(1,2.5) );
        m_pawn.m_wWantedHeadYaw = RandRange( 5000, 10000 )/256;
        Sleep( RandRange(1,2.5) );
    }
    m_pawn.m_wWantedHeadYaw = 0;
    Goto('ChooseDestination');

GoCloserAndLook:
    // MovingTo will take care of moving the pawn closest possible to threat without leaving the area
    GotoStateMovingTo( "EBSThreatLoc", m_pawn.m_eMovementPace, true,, m_vThreatLocation, 'EngageBySound', 'AtClosest' );
AtClosest:
    // Turn toward threat, wait and return to no threat state
    FocalPoint = m_vThreatLocation;
    FinishRotation();
    Sleep( RandRange(3,5) );

Exit:
    GotoStateNoThreat();
}


//============================================================================
//  #####   ##  #   ####    ####    #####   #   #   ####    #####   ####    
//  ##      ##  #   #   #   #   #   ##      ##  #   ## ##   ##      #   #   
//  #####   ##  #   ####    ####    ####    # # #   ##  #   ####    ####    
//     ##   ##  #   ## #    ## #    ##      #  ##   ## ##   ##      ## #    
//  #####   #####   ##  #   ##  #   #####   #   #   ####    #####   ##  #   
//============================================================================
function SecureTerrorist( R6Pawn pOther )
{
    ChangeOrientationTo(rotator(pawn.location - pOther.location));
    SetEnemy( pOther );
    GotoState('Surrender', 'Secure');
}

state Surrender
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );
    }

    event GotoPointAndSearch(vector vDestination, R6Pawn.EMovementPace ePace, BOOL bCallBackup, OPTIONAL FLOAT fSearchTime, OPTIONAL R6Terrorist.EDefCon eNewDefCon );

    function EscortIsOver( R6HostageAI hostageAI, bool bSuccess )
    {
        #ifdefDEBUG if (bShowLog) logX(" Escort hostage but i've surrender ("$ hostageAI $"|"$ m_HostageAI $") is over, success:" $ bSuccess ); #endif
        m_Manager.RemoveHostageAssignment( m_Hostage );
    }

    function AIAffectedByGrenade( Actor aGrenade, R6Pawn.EGrenadeType eType )
    {
    }

Begin:
    StopMoving();
    FinishRotation();

    if(m_pawn.m_bIsUnderArrest || m_pawn.m_bIsKneeling)
        Stop;

    // Surrender
    m_pawn.m_bPreventWeaponAnimation = true;
    m_pawn.SetNextPendingAction( PENDING_Surrender );
    Sleep( 0.333 );
    // Drop weapon
    m_pawn.SetNextPendingAction( PENDING_DropWeapon );
    // Kneel
    FinishAnim(m_pawn.C_iPawnSpecificChannel);
    m_pawn.SetNextPendingAction( PENDING_Kneeling );
    while( !m_pawn.m_bIsKneeling )
    {
        Sleep( 1 );
    }
    R6AbstractGameInfo(Level.Game).RemoveTerroFromList( m_pawn );
    R6AbstractGameInfo(Level.Game).PawnSecure( m_pawn );
    Stop;

Secure:
    FinishRotation();
    m_pawn.m_bIsUnderArrest = true;
    R6AbstractGameInfo(Level.Game).PawnSecure( m_pawn );
    m_pawn.SetCollision(false, false, false );
    m_pawn.SetNextPendingAction( PENDING_Arrest );
}

//============================================================================
//  ####    ##  #   #   #            ###    #   #    ###    ##  #   
//  #   #   ##  #   ##  #           ##  #   #   #   ##  #   ##  #   
//  ####    ##  #   # # #           #####   # # #   #####    ###    
//  ## #    ##  #   #  ##           ##  #   #####   ##  #     ##    
//  ##  #   #####   #   #           ##  #    # #    ##  #     ##    
//============================================================================
state RunAway
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_RunAway );
    }

    // Ignore GotoPointToAttack in state RunAway
    event GotoPointToAttack(vector vDestination, actor pTarget )
    {
    }


Begin:
    if( Pawn.bIsCrouched )
    {
        m_pawn.bWantsToCrouch = false;
        // Let some time for the physics to start uncrouching
        Sleep(0.1);
    }

ChooseDestination:
    // Find a destination
    if(!MakePathToRun() || RouteGoal==none)
    {
        // Nowhere to run, spray fire
        GotoStateSprayFire();
    }
    GotoStateMovingTo( "AttackReloadCover", PACE_Run, true, RouteGoal,, 'RunAway', 'ChooseDestination');
    Goto('ChooseDestination');
}

//============================================================================
state WaitForEnemy
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_SeeRainbow, EVSTATE_DefaultState );
    }

    function EndState()
    {
        m_pawn.m_bAvoidFacingWalls = false;
        Focus = none;
        FocalPoint = Enemy.Location;
    }

    function SeePlayer(Pawn seen)
    {
        if(IsAnEnemy(R6Pawn(seen)))
        {
            #ifdefDEBUG if (bShowLog) logX ( "Enter function RunAway.SeePlayer.  See :" $ seen ); #endif
            SetEnemy( seen );
            // Choose an attack mode
            if(Rand(2)==0)
            {
                GotoStateSprayFire();
            }
            else
            {
                GotoStateAimedFire();
            }
        }
    }

    function Timer()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Function Timer"); #endif
        GotoStateNoThreat();
    }
    
Begin:
    // Wait for the enemy to bee in sight
    Focus = Enemy;
    FocalPoint = LastSeenPos;
    StopMoving();
    if(!m_pawn.m_bPreventCrouching)
        Pawn.bWantsToCrouch = true;
    SetTimer( 10, False );
    m_pawn.m_bAvoidFacingWalls = true;

Wait:
}

//============================================================================
//   ###    #####   #####    ###     ####   ##  #   
//  ##  #    ##      ##     ##  #   ##      ## #    
//  #####    ##      ##     #####   ##      ###     
//  ##  #    ##      ##     ##  #   ##      ## #    
//  ##  #    ##      ##     ##  #    ####   ##  #   
//============================================================================
function GotoStateAimedFire()
{
    m_eAttackMode = ATTACK_AimedFire;
    m_pawn.m_bSprayFire = false;
    GotoState( 'Attack' );
}

function GotoStateSprayFire()
{
    // If not already engaged, 50% chance of spray without stopping until clip is empty
    m_pawn.m_bSprayFire = true;
    if(m_eAttackMode==ATTACK_NotEngaged && Rand(2)==0)
        m_eAttackMode = ATTACK_SprayFireNoStop;
    else
        m_eAttackMode = ATTACK_SprayFire;
    GotoState( 'Attack' );
}

state Attack
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_Grenade, EVSTATE_Attack );

        // Should never happen.  Fix any occurence of this error
        if( Pawn.IsAlive() && (Pawn.m_bDroppedWeapon || Pawn.EngineWeapon==none) )
        {
            #ifdefDEBUG m_pawn.logWarning("Pawn enter state attack without a weapon.  Please report the bug!"); #endif
            m_pawn.ServerForceKillResult(4);
            m_pawn.R6TakeDamage( 1000, 1000, m_pawn, m_pawn.Location, vect(0,0,0), 0 );
            #ifdefDEBUG LogTerroState(); #endif
        }

        // 
        if(m_eAttackMode==ATTACK_NotEngaged)
        {
            #ifdefDEBUG if(bShowLog) logX ("Enter Attack state without Attack mode" ); #endif
            GotoStateNoThreat();
            return;
        }
        m_pawn.m_bEngaged = true;
        m_pawn.PlayWaiting();
        Focus = Enemy;
        m_sDebugString = "";
    }

    function EndState()
    {
        m_pawn.m_bEngaged = false;
        m_pawn.m_wWantedAimingPitch = 0;
        StopFiring();
        Focus = none;
        if(Enemy != none)
            FocalPoint = Enemy.Location;
        m_sDebugString = "";
    }

    function BOOL NeedToReload()
    {
        if( Pawn.EngineWeapon.NumberOfBulletsLeftInClip() == 0)
            return true;

        if( Pawn.EngineWeapon.m_eWeaponType==WT_LMG &&
            Pawn.EngineWeapon.NumberOfBulletsLeftInClip() < Pawn.EngineWeapon.GetClipCapacity() - 50 )
                return true;

        return false;
    }

    function FindNextEnemy()
    {
        local R6Pawn aPawn;

        if(Enemy != none)
            FocalPoint = Enemy.Location;
        SetEnemy( none );
        foreach VisibleCollidingActors(class'R6Pawn', aPawn, 5000, m_pawn.Location )
        {
            if( m_pawn.IsEnemy( aPawn ) && aPawn.IsAlive() )
            {
                SetEnemy( aPawn );
                Focus = Enemy;
                #ifdefDEBUG if(bShowLog) logX( "Enemy dead, find new enemy: " $ Enemy.name ); #endif
                return;
            }
        }
        #ifdefDEBUG if(bShowLog) logX( "Enemy dead, no other visible enemy." ); #endif

        if(m_eAttackMode==ATTACK_SprayFireNoStop)
        {
            if( pointReachable(LastSeenPos) )
            {
                m_vMovingDestination = LastSeenPos;
                GotoState('Attack', 'SprayFireMove' );
            }
        }
        else
            GotoStateLostSight( LastSeenPos );
    }

    event bool NotifyBump(Actor other)
    {
        return true;
    }

Begin:
    if(m_pawn.m_eEffectiveGrenade!=GTYPE_None)
        ReactToGrenade( m_pawn.m_vGrenadeLocation );

    m_sDebugString = "Begin";
    StopMoving();

    m_bFireShort = false;

    if(m_pActionSpot != none)
    {
        // 60% chance of short fire
        // 20% chance of normal fire (forget fire spot)
        // 20% chance of moving directly to fire spot
        m_iRandomNumber = Rand(100);
        if(m_iRandomNumber<60)
        {
            // Short fire
            m_bFireShort = true;
        }
        else if(m_iRandomNumber<80)
        {
            // Normal fire (forget fire spot)
            SetActionSpot( none );
        }
        else
        {
            // Move directly to fire spot
            Goto('MoveToFireSpot');
        }
    }

    // 33% chance that the terrorist crouch
    if( !m_pawn.m_bPreventCrouching && !Pawn.bIsCrouched && Rand(3)==0)  // 0 to 2
    {
        Pawn.bWantsToCrouch = true;
        // Let some time for the terrorist to crouch
        Sleep(0.1);
    }

    // We begin attack, turn toward enemy
    Target = Enemy;
    m_sDebugString = "FinishRotation2";
    FinishRotation();

///////
// Fire
///////
ReactionTime:
//    if(Level.NetMode==NM_Standalone)
//    {
        switch(m_pawn.m_iDiffLevel)
        {
            case 1: Sleep(1.0); break;
            case 2: Sleep(0.5); break;
            case 3:             break;
        }
//    }
//    else
//    {
//        switch(m_pawn.m_iDiffLevel)
//        {
//            case 1: Sleep(1.0); break;
//            case 2: Sleep(0.75);break;
//            case 3: Sleep(0.25);break;
//        }
//    }
    CallVisibleTerrorist();
Fire:
    if(m_eAttackMode != ATTACK_SprayFireNoStop || CanSee(Enemy) )
        Focus = Enemy;
    m_sDebugString = "Fire";
    // Check Ammo
    if( NeedToReload() )
    {
        Goto('Reload');
    }

    // If we are on SprayFireMove, only shoot in straight line
    if(m_eAttackMode==ATTACK_SprayFireMove)
    {
        #ifdefDEBUG if(bShowLog) logX("SprayFireMoving.  Location: " $ Pawn.Location $ " Destination: " $ m_vMovingDestination ); #endif
        SetGunDirection(none);
        if( VSize(Pawn.Location-Destination) < Pawn.CollisionRadius*2 )
        {
            StopMoving();
            m_eAttackMode = ATTACK_SprayFireNoStop;
        }
    }
    else
    {
        // Check if enemy is dead
        if( Enemy==none || !R6Pawn(Enemy).IsAlive() )
        {
            // A sniper doesn't move
            if( m_pawn.m_ePersonality == PERSO_Sniper )
                GotoStateNoThreat();
            else
                FindNextEnemy();
        }

        m_sDebugString = "CheckLineOfSight";
        // Check line of sight
        if( Enemy!=none && !HaveAClearShot(m_pawn.GetFiringStartPoint(), Enemy) )
        {
            if( m_pawn.m_ePersonality == PERSO_Sniper )
            {
                SetLowestSnipingStance( Enemy );
                Sleep(0.2);
                Goto('Fire');
            }
            else
            {
                m_vTargetPosition = FindBetterShotLocation( Enemy );
                R6PreMoveTo( m_vTargetPosition, Enemy.Location, PACE_Run );
                MoveTo( m_vTargetPosition, Enemy );
                FocalPoint = Enemy.Location;
                Goto( 'Fire');
            }
        }

        SetGunDirection(Enemy);
        while( Enemy!=none && Enemy.IsAlive() && m_pawn.m_wWantedAimingPitch != ((m_pawn.m_iCurrentAimingPitch&0xffff)/256) )
        {
            m_sDebugString = "SettingPitch";
            Sleep(0.05);
        }
    }

    // Check accuracy only in aimedfire
    if(m_eAttackMode==ATTACK_AimedFire)
    {
        while(!IsReadyToFire(Enemy))
        {
            m_sDebugString = "ReadyToFire";
            #ifdefDEBUG if(bShowLog) logX("Not ready to fire: current chance: " $ GetCurrentChanceToHit(Enemy) $ " needed: " $ (m_pawn.GetSkill(SKILL_SelfControl) * m_pawn.GetSkill(SKILL_SelfControl)) $ " MaxAngleError:" $ m_pawn.EngineWeapon.GetCurrentMaxAngle() ); #endif
            //#ifdefDEBUG if(bShowLog) logX("   Current yaw: " $ m_pawn.Rotation.Yaw $ " needed: " $ m_pawn.DesiredRotation.Yaw ); #endif
            Sleep(0.2);
        }
        //#ifdefDEBUG if(bShowLog) logX( "Chance to hit: " $ GetCurrentChanceToHit(Enemy) $ " (current max angle: " $ Pawn.EngineWeapon.GetCurrentMaxAngle() ); #endif
        //#ifdefDEBUG if(bShowLog) logX("   Current yaw: " $ m_pawn.Rotation.Yaw $ " needed: " $ m_pawn.DesiredRotation.Yaw ); #endif
    }

    // Fire
    if( m_pawn.m_eEffectiveGrenade == GTYPE_FlashBang
     || m_pawn.m_eEffectiveGrenade == GTYPE_BreachingCharge
     || m_pawn.m_eEffectiveGrenade == GTYPE_TearGas)
    {
        Sleep(0.5);
        Goto('ReactionTime');
    }

    m_sDebugString = "FinishRotation";
    FinishRotation();
    if(m_eAttackMode==ATTACK_AimedFire)
    {
        #ifdefDEBUG if (bShowLog) logX ( "Start aimed fire at " $  enemy $ ". " $ Pawn.EngineWeapon.NumberOfBulletsLeftInClip() $ " ammo left in clip. FireMode:" $ m_eAttackMode $ " Chance to hit: " $ GetCurrentChanceToHit(Enemy) $ " needed: " $ (m_pawn.GetSkill(SKILL_SelfControl) * m_pawn.GetSkill(SKILL_SelfControl)) $ " MaxAngleError:" $ m_pawn.EngineWeapon.GetCurrentMaxAngle() ); #endif
        StartFiring();
        m_sDebugString = "AimedFiring";
        if(Pawn.EngineWeapon.GetRateOfFire() == ROF_FullAuto)
            Sleep( RandRange(0.4, 1.0) );
        else
            Sleep(0.2);
        StopFiring();
    }
    else
    {
        #ifdefDEBUG if(bShowLog) logX ( "Start spray fire at " $  enemy $ ". " $ Pawn.EngineWeapon.NumberOfBulletsLeftInClip() $ " ammo left in clip. FireMode:" $ m_eAttackMode ); #endif
        // if not automatic mode, we must loop for each bullet or burst
        if( Pawn.EngineWeapon.GetRateOfFire() == ROF_FullAuto )
        {
            StartFiring();
            m_sDebugString = "FiringAuto";
            Sleep( RandRange( 0.2, 1.5 ) );
            StopFiring();
            SetGunDirection(Target);
            m_sDebugString = "StopFiring";
            Sleep( RandRange( 0, 0.5 ) );
        }
        else
        {
            // 2 to 5 "burst"
            m_iRandomNumber = rand(4)+2;
            while( m_iRandomNumber>0 )
            {
                StartFiring();
                m_sDebugString = "FiringSingle";
                Sleep( RandRange( 0.1, 0.2 ) );
                StopFiring();
                SetGunDirection(Target);
                m_iRandomNumber--;
            }
            m_sDebugString = "StopFiring2";
            Sleep( RandRange( 0, 0.5 ) );
        }
    }
    if(m_bFireShort)
    {
        m_bFireShort = false;
        Goto('MoveToFireSpot');
    }
    #ifdefDEBUG if (bShowLog) logX ( "End fire at " $  enemy $ ". " $ Pawn.EngineWeapon.NumberOfBulletsLeftInClip() $ " ammo left in clip." ); #endif

    Goto('ReactionTime');

/////////
// Reload
/////////
Reload:
    m_sDebugString = "Reload";
    #ifdefDEBUG if (bShowLog) logX( "No ammo left in clip, must reload..." $ Pawn.EngineWeapon.GetNbOfClips() $ " clip left" ); #endif
    SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );

    if(m_eAttackMode>ATTACK_SprayFire)
    {
        // Don't empty next clip too,
        m_eAttackMode = ATTACK_SprayFire;
    }

    // Check for cover
    if( m_pawn.m_ePersonality != PERSO_Sniper && Enemy != none )
    {
        #ifdefDEBUG if(bShowLog) logX( "Check for cover" ); #endif
        SetActionSpot( FindPlaceToTakeCover( Enemy.Location, GetMaxCoverDistance() ) );
        if(m_pActionSpot != none)
        {
            #ifdefDEBUG if(bShowLog) logX( "Find cover " $ m_pActionSpot $ " at " $ m_pActionSpot.Location ); #endif
            GotoStateMovingTo( "AttackReloadCover", PACE_Run, true, m_pActionSpot,, 'Attack', 'AtCover');
AtCover:
            SetReactionStatus( REACTION_HearAndSeeNothing, EVSTATE_DefaultState );
            MoveToPosition( m_pActionSpot.Location, m_pActionSpot.Rotation );
            Focus = Enemy;
            m_sDebugString = "FinishRotation3";
            FinishRotation();
        }
        if( !m_pawn.m_bPreventCrouching && !Pawn.bIsCrouched && Rand(2)==0 )
        {
            Pawn.bWantsToCrouch = true;
        }
    }

    Target = none;
    StopMoving();
    AIReloadWeapon();
    while(m_pawn.m_bReloadingWeapon)
    {
        m_sDebugString = "Reloading";
        Sleep(0.1);
    }
    #ifdefDEBUG if (bShowLog) logX( "End reloading " $ Pawn.EngineWeapon.GetNbOfClips() $ " clip left" ); #endif
    Target = Enemy;
    SetGunDirection(Target);
    m_sDebugString = "EndReloading";
    Sleep(0.4);

    SetReactionStatus( REACTION_Grenade, EVSTATE_Attack );
    Goto('Fire');

////////////////
// SprayFireMove
////////////////
SprayFireMove:
    m_sDebugString = "SprayFireMove";
    #ifdefDEBUG if(bShowLog) logX("SprayFireMove.  Location: " $ Pawn.Location $ " Destination: " $ m_vMovingDestination ); #endif
    SetReactionStatus( REACTION_SeeRainbow, EVSTATE_Attack );
    m_eAttackMode = ATTACK_SprayFireMove;
    if( VSize(m_vMovingDestination - m_pawn.Location) > 100.0f )
    {
        R6PreMoveTo( m_vMovingDestination, m_vMovingDestination, PACE_Walk );
        Pawn.setPhysics( PHYS_Walking );
        Destination = m_vMovingDestination;
        Pawn.Acceleration = Normal(Destination - Pawn.Location) * m_pawn.m_fWalkingSpeed;
    }
    Goto( 'Fire' );

////////////
// Fire spot
////////////
MoveToFireSpot:
    if( IsAttackSpotStillValid() )
        GotoStateMovingTo( "AttackFireSpot", PACE_Run, true, m_pActionSpot, m_vThreatLocation, 'Attack', 'AtFireSpot' );
    else
        Goto( 'Fire' );

AtFireSpot:
    MoveToPosition( m_pActionSpot.Location, rotator(m_pActionSpot.Location - Enemy.Location) );
    Focus = Enemy;
    if( m_pActionSpot.m_eFire == STAN_Crouching )
        m_pawn.bWantsToCrouch = true;
    Goto( 'Fire' );
}

function GotoStateAttackHostage( R6Pawn hostage )
{
    SetEnemy( hostage );
    m_eAttackMode = ATTACK_AimedFire;
    m_pawn.m_bSprayFire = false;
    GotoState('AttackHostage');
}

state AttackHostage extends Attack
{
Begin:
    if(R6Hostage(Enemy)==none || R6Hostage(Enemy).m_bExtracted)
        FindNextEnemy();

    if( !R6Pawn(Enemy).IsAlive() || CanSee(Enemy) )
        GotoStateAimedFire();

    SetReactionStatus( REACTION_SeeRainbow, EVSTATE_AttackHostage );

    // Find the hostage
    GotoStateMovingTo( "Chase hostage", PACE_Run, true, Enemy,, 'AttackHostage', 'Begin' );
}

//============================================================================
//   ####   ##  #    ###    ####    ####   ####    ###   ####   #   #  #####   
//  ##      ##  #   ##  #   #   #   ## ##  ##  #  ##  #   ##    ##  #   ##     
//  ## ##   ##  #   #####   ####    ##  #  ####   ##  #   ##    # # #   ##     
//  ##  #   ##  #   ##  #   ## #    ## ##  ##     ##  #   ##    #  ##   ##     
//   ####   #####   ##  #   ##  #   ####   ##      ###   ####   #   #   ##     
//============================================================================
state GuardPoint
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
    }

    function EndState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Exit STATE"); #endif
        m_pawn.m_wWantedHeadYaw = 0;
    }

Begin:
    // Go to starting location
    #ifdefDEBUG if(bShowLog) logX( "at " $ m_pawn.Location $", return to starting location at " $ m_pawn.m_DZone.Location $ ".  (Distance = " $ VSize(m_pawn.m_DZone.Location - m_pawn.Location) $ ", " $ 2*(m_pawn.CollisionRadius+m_pawn.CollisionHeight) $ ")"); #endif
    GotoStateMovingTo( "GuardPoint", PACE_Walk, true,, m_vSpawningPosition, 'GuardPoint', 'StartWaiting',, true );

StartWaiting:
    StopMoving();

    // Set the rotation of the Pawn to the rotation of the DZone
    ChangeOrientationTo( m_rSpawningRotation );
    FinishRotation();

    // If snipper, goto Sniping state
    if( m_pawn.m_ePersonality==PERSO_Sniper)
    {
        GotoState('Sniping');
    }

    // Set the stance accordingly to the DZone
    if( !m_pawn.m_bPreventCrouching && m_pawn.m_eStartingStance == STAN_Crouching )
    {
        Pawn.bWantsToCrouch = true;
    }
    else
    {
        Pawn.bWantsToCrouch = false;
    }
    
Waiting:
    // Looking around
    if(rand(3)==0)
    {
        // One out of three, look both side
        m_iRandomNumber = rand(2);
        if(m_iRandomNumber==0)
            m_iRandomNumber = -1;

        m_pawn.m_wWantedHeadYaw = RandRange( m_iRandomNumber*5000, m_iRandomNumber*10000 )/256;
        Sleep( RandRange(1,1.5) );
        m_iRandomNumber *= -1;
        m_pawn.m_wWantedHeadYaw = RandRange( m_iRandomNumber*5000, m_iRandomNumber*10000 )/256;
        Sleep( RandRange(1.25,1.75) );
    }
    else
    {
        // Look one side
        m_pawn.m_wWantedHeadYaw = RandRange( 5000, 10000 )/256;
        if(rand(2)==0)
            m_pawn.m_wWantedHeadYaw = -m_pawn.m_wWantedHeadYaw;
        Sleep( RandRange(1,1.5) );
    }

    // Looking straight
    m_pawn.m_wWantedHeadYaw = 0;
    Sleep( RandRange(2,6) );

    Goto('Waiting');
}

//============================================================================
//  #####  #   #  ####  ####   ####  #   #   ####   
//  ##     ##  #   ##   ##  #   ##   ##  #  ##      
//  #####  # # #   ##   ####    ##   # # #  ## ##   
//     ##  #  ##   ##   ##      ##   #  ##  ##  #   
//  #####  #   #  ####  ##     ####  #   #   ####   
//============================================================================
state Sniping
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
    }

#ifdefDEBUG 
    function EndState()
    {
        if (bShowLog) logX ( "Exit STATE");
    }
#endif

    event SeePlayer(Pawn seen)
    {
        local R6Pawn r6seen;

        r6seen = R6Pawn(seen);
        if(r6seen == None)
            return;

        // Seeing Rainbow
        if(m_bSeeRainbow && IsAnEnemy(r6seen))
        {
            #ifdefDEBUG if (bShowLog) logX ( "Have seen " $ r6seen.name $ ". Time:" $ Level.TimeSeconds ); #endif

            ReconThreatCheck( r6seen, NOISE_None );

            // If closer than 500 meter, stand up
            if(VSize(seen.Location-m_pawn.Location) < 500)
            {
                // 25% chance of standing up, 75% of crouching
                m_pawn.m_bWantsToProne = false;
                if(!m_pawn.m_bPreventCrouching && rand(4)!=0)
                {
                    m_pawn.bWantsToCrouch=true;
                }                
            }

            SetEnemy( r6seen );
            Target = Enemy;
        
            if(MakeBackupList())
                CallBackupForAttack( Enemy.Location, PACE_Run );

            ChangeDefCon(DEFCON_1);

            GotoStateAimedFire();
        }
    }

    event HearNoise( float Loudness, Actor NoiseMaker, ENoiseType eType, optional ESoundType ESoundType )
    {
        if( m_pawn.m_bDontHearPlayer && R6Pawn(NoiseMaker.Instigator).m_bIsPlayer )
            return;

        ReconThreatCheck( NoiseMaker, eType );

        // Ignore noise from hostage and neutral pawn
        if( m_pawn.isNeutral( NoiseMaker.Instigator ) )
            return;

        #ifdefDEBUG if(bShowLog) logX( "Hear sound from " $ NoiseMaker.name $ " of type " $ eType $ " and loudness " $ Loudness ); #endif

        if( m_bHearInvestigate && eType==NOISE_Investigate
            || m_bHearThreat && eType==NOISE_Threat )
        {
            GotoPointAndSearch( NoiseMaker.Location, PACE_Walk, true, C_DefaultSearchTime, DEFCON_2 );

            if( m_bHearThreat && eType==NOISE_Threat)
            {
                if(m_iChanceToDetectShooter<80)
                    m_iChanceToDetectShooter += 20;

                if( m_pawn.IsEnemy(NoiseMaker.Instigator) )
                {
                    // Check if we detect shooter
                    if((Rand(100)+1)<m_iChanceToDetectShooter)
                    {
                        SetEnemy( NoiseMaker.Instigator );
                        GotoStateAimedFire();
                    }
                }
            }
            else
            {
                // If noise close enough, turn toward direction of noise
                if(VSize(NoiseMaker.Location-m_pawn.Location) < 500 )
                {
                    // 25% chance of standing up, 75% of crouching
                    m_pawn.m_bWantsToProne = false;
                    if(!m_pawn.m_bPreventCrouching && rand(4)!=0)
                    {
                        m_pawn.bWantsToCrouch=true;
                    }                

                    FocalPoint = NoiseMaker.Location;
                    GotoState('Sniping', 'CheckBehind' );
                }
            }
        }
        else if(m_bHearGrenade && eType==NOISE_Grenade)
        {
            if(!m_bHeardGrenade)
            {
                m_VoicesManager.PlayTerroristVoices( m_pawn, TV_Grenade);
                m_bHeardGrenade = true;
            }
            ReactToGrenade( NoiseMaker.Location );
        }
    }

Begin:
    if( R6DZonePoint(m_pawn.m_DZone) == none )
    {
        SetLowestSnipingStance();
    }
    else
    {
        switch(R6DZonePoint(m_pawn.m_DZone).m_eStance)
        {
            case STAN_Standing:
                m_pawn.m_bWantsToProne = false;
                m_pawn.bWantsToCrouch = false;
                break;
            case STAN_Crouching:
                m_pawn.m_bWantsToProne = false;
                m_pawn.bWantsToCrouch = true;
                break;
            case STAN_Prone:
                m_pawn.m_bWantsToProne = true;
                m_pawn.bWantsToCrouch = false;
                break;
        }
    }
    Stop;

LostTrackOfEnemy:
    #ifdefDEBUG if(bShowLog) logX("Sniper lost track of enemy"); #endif
    Sleep(RandRange(3,7));
    ChangeOrientationTo( m_pawn.m_DZone.Rotation );
    FinishRotation();
    GotoStateNoThreat();

CheckBehind:
    #ifdefDEBUG if(bShowLog) logX("Sniper check behind"); #endif
    FinishRotation();
    Sleep(RandRange(1,3));
    ChangeOrientationTo( m_pawn.Rotation + rot(0,10000,0) );
    Sleep(RandRange(1,2));
    ChangeOrientationTo( m_pawn.Rotation + rot(0,-20000,0) );
    Sleep(RandRange(1,2));
    ChangeOrientationTo( m_pawn.m_DZone.Rotation );
    FinishRotation();
    GotoStateNoThreat();
}

//============================================================================
//  ##  #    ###    #####   #####    ###     ####   #####   
//  ##  #   ##  #   ##       ##     ##  #   ##      ##      
//  #####   ##  #   #####    ##     #####   ## ##   ####    
//  ##  #   ##  #      ##    ##     ##  #   ##  #   ##      
//  ##  #    ###    #####    ##     ##  #    ####   #####   
//============================================================================

//============================================================================
// HostageSurrender - Called from an hostage AI when that AI surrender
//============================================================================
function HostageSurrender( R6HostageAI hostageAI )
{
    local Vector vDestination;

    if( UseRandomHostage() )
        return;
    
    #ifdefDEBUG if(bShowLog) logX( "Hostage " $ hostageAI.name $ " surrender" ); #endif

    m_HostageAI = hostageAI;
    m_Hostage = hostageAI.m_pawn;
    m_Manager.AssignHostageTo( m_Hostage, Self );

    // Hostage surrender, escort him to a deployment zone
    m_ZoneToEscort = m_Manager.FindNearestZoneForHostage( m_pawn );
    if(m_ZoneToEscort==None)
    {
        #ifdefDEBUG if(bShowLog) logX("Cannot find a zone with terrorist and hostage"); #endif
        m_ZoneToEscort = m_pawn.m_DZone;
    }

    // Tell the hostage where to go
    vDestination = m_ZoneToEscort.FindRandomPointInArea();
    m_HostageAI.SetStateEscorted( m_pawn, vDestination, true );
    #ifdefDEBUG if(bShowLog) logX( "Escort hostage " $ m_Hostage.name $ " to " $ vDestination ); #endif

    GotoStateFollowPawn( R6Pawn(m_HostageAI.Pawn), FMODE_Hostage, 100 );
}

//============================================================================
// EscortIsOver - Called from the hostage AI when the escort is over
//============================================================================
function EscortIsOver( R6HostageAI hostageAI, bool bSuccess )
{
    #ifdefDEBUG if(bShowLog) logX("Escort hostage ("$ hostageAI $"|"$ m_HostageAI $") is over, success:" $ bSuccess ); #endif

    if ( bSuccess )
    {
        m_Manager.AssignHostageToZone( m_Hostage, m_ZoneToEscort );
        GotoStateNoThreat();
    }
    else
    {
        m_Manager.RemoveHostageAssignment( m_Hostage );
        GotoStateEngageBySound( m_Hostage.Location, PACE_Run, 10.f );
    }
}

//============================================================================
// GotoStateFindHostage - 
//============================================================================
function GotoStateFindHostage( R6Hostage hostage )
{
    m_Hostage = hostage;
    m_HostageAI = R6HostageAI(hostage.Controller);
    m_Manager.AssignHostageTo( hostage, Self );
    GotoState('FindHostage');
}

// Terrorist have seen a freed hostage or civilian
state FindHostage
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearBullet, EVSTATE_FindHostage );
    }

    function EndState()
    {
        Focus = none;
        FocalPoint = Enemy.Location;
    }

    event bool NotifyBump( Actor other )
    {
        if(other==Enemy)
        {
            GotoState( 'FindHostage', 'Begin' );
        }
        return Global.NotifyBump( other );
    }

Begin:
    StopMoving();
    SetEnemy( m_Hostage );
    LastSeenTime = Level.TimeSeconds;
    LastSeenPos = Enemy.Location;
    Focus = m_Hostage;

AskToSurrender:
    #ifdefDEBUG if(bShowLog) logX("Ask civilian to surrender"); #endif
    // Ask hostage to surrender.  If he does, he will send me a message
    m_HostageAI.Order_Surrender( m_pawn );

    // Play animation, let the time to the hostage to react
    Pawn.PlayAnim('StandYellAlarm');
    FinishAnim();

    // Check reaction of the terrorist
    m_iRandomNumber = Rand(100); // 0-99
    // m_iRandomNumber = 50;                   // TEMP!! Fix the result
    if( m_iRandomNumber < 50 )
    {
        Sleep( 2 );
        Goto('AskToSurrender');
    }
    else if( m_iRandomNumber < 90 )
    {
        Goto('Pursues');
    }
    else
    {
        Goto('AimedFire');
    }

Pursues:
    #ifdefDEBUG if(bShowLog) logX("Pursues civilian" @ m_HostageAI @ m_Hostage @ R6Pawn(m_HostageAI.Pawn).m_eHealth); #endif
    if( CanSee(m_Hostage) && m_Hostage.IsAlive() )
    {
        if(actorReachable(Enemy))
        {
            MoveTarget = Enemy;
        }
        else
        {
            MoveTarget = FindPathToward( Enemy );
        }

        if(moveTarget == none)
            Sleep(1.0);
        else
        {
            R6PreMoveTo( MoveTarget.Location, MoveTarget.Location, PACE_Run );
            MoveToward( MoveTarget );
        }

        // Reached destination, enemy still visible, start again.
        Goto('Pursues');
    }
    else // hostage not visible or dead, goto last seen pos and search
    {
        if(pointReachable(LastSeenPos))
        {
            Destination = LastSeenPos;
        }
        else
        {
            MoveTarget = FindPathTo( LastSeenPos );
            Destination = MoveTarget.Location;
        }
        R6PreMoveTo( Destination, Destination, PACE_Run );
        MoveTo( Destination );

        // Reached destination, enemy not visible, goto EngageBySound state
        GotoStateEngageBySound( LastSeenPos, PACE_Run, C_HostageSearchTime );
    }

AimedFire:
    #ifdefDEBUG if(bShowLog) logX("Aimed fire on civilian"); #endif

    // Fire on civilian
    GotoStateAimedFire();
}

//============================================================================
//  #####   ###   ##     ##      ###   #   #   
//  ##     ##  #  ##     ##     ##  #  #   #   
//  ####   ##  #  ##     ##     ##  #  # # #   
//  ##     ##  #  ##     ##     ##  #  #####   
//  ##      ###   #####  #####   ###    # #    
//
// if iYaw == 0, always approach the following pawn in straight line
//        in front : 32768
//        left : 16384 + 49151 : right
//            behind : 0
//============================================================================
function GotoStateFollowPawn( R6Pawn followedpawn, EFollowMode eMode, FLOAT fDist, optional INT iYaw )
{
    m_PawnToFollow = followedpawn;
    m_eFollowMode = eMode;
    m_fFollowDist = fDist;
    m_iFollowYaw = iYaw;
    #ifdefDEBUG if(bShowLog) logX("FollowPawn:" $ followedpawn $ " Dist:" $ fDist $ " Yaw: " $ iYaw $ " mode:" $ eMode ); #endif
    GotoState('FollowPawn');
}

state FollowPawn
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( m_eReactionStatus, m_eStateForEvent );
        //m_pawn.PawnTrackActor( m_PawnToFollow, false );
    }

    function EndState()
    {
        #ifdefDEBUG if(bShowLog) logX ( "Exit STATE" ); #endif
        //m_pawn.R6ResetLookDirection();
        Focus = none;
    }

    function vector GetFollowDestination()
    {
        local FLOAT     fDist;
        local vector    vDir;
        local vector    vTargetPos;
        local rotator   rOrientation;

        if(m_iFollowYaw==0)
        {
            vTargetPos = m_PawnToFollow.Location + Normal(Pawn.Location - m_PawnToFollow.Location) * m_fFollowDist;
        }
        else
        {
            rOrientation.Yaw = m_PawnToFollow.Rotation.Yaw + m_iFollowYaw ;
            vTargetPos = m_PawnToFollow.Location - vector(rOrientation) * m_fFollowDist;
        }

        FindSpot( vTargetPos );
        return vTargetPos;
    }

Begin:
Moving:
    // Check that the pawn we follow is still alive
    if( !m_PawnToFollow.IsAlive() )
    {
        // Followed pawn is dead, go back to no threat
        GotoStateNoThreat();
    }

    // Get the distance to go and if close enough, don't move
    m_fPawnDistance = DistanceTo(m_PawnToFollow);

    if( m_fPawnDistance < m_fFollowDist + Pawn.CollisionRadius )
    {
        StopMoving();

        // If in path mode and the leader is waiting, then we are on target too
        if(m_eFollowMode==FMODE_Path && R6Terrorist(m_PawnToFollow).m_controller.m_bWaiting)
        {
            GotoState( 'PatrolPath', 'ReachedNode' );
        }

        Sleep(0.2);
        goto('Moving');
    }

    m_vMovingDestination = GetFollowDestination();

    m_pawn.m_eMovementPace = PACE_Walk;
    if(!pointReachable(m_vMovingDestination))
    {
        //m_pawn.m_eMovementPace = PACE_Run;
        MoveTarget = FindPathTo( m_vMovingDestination );
        if(MoveTarget!=none)
        {
            m_vMovingDestination = MoveTarget.Location;
        }
    }

    if( m_fPawnDistance > 500.f )
    {
        m_pawn.m_eMovementPace = PACE_Run;
    }

    R6PreMoveTo(m_vMovingDestination, m_vMovingDestination, m_pawn.m_eMovementPace);
    MoveTo(m_vMovingDestination);
    goto('Moving');
}

//============================================================================
//  ####    ###   #####  ####     ###    ##       ###    ####    #####    ###    
//  ##  #  ##  #   ##    #   #   ##  #   ##      ##  #   #   #   ##      ##  #   
//  ####   #####   ##    ####    ##  #   ##      #####   ####    ####    #####   
//  ##     ##  #   ##    ## #    ##  #   ##      ##  #   ## #    ##      ##  #   
//  ##     ##  #   ##    ##  #    ###    #####   ##  #   ##  #   #####   ##  #   
//============================================================================
state PatrolArea
{
    function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX ( "Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
        m_pawn.m_bAvoidFacingWalls = true;
    }

    function EndState()
    {
        m_pawn.m_wWantedHeadYaw = 0;
        m_pawn.m_bAvoidFacingWalls = false;
    }

Begin:
    m_pawn.m_eMovementPace = PACE_Walk;

ChooseDestination:
    m_vTargetPosition = m_pawn.m_DZone.FindRandomPointInArea();
    GotoStateMovingTo( "PatrolArea", PACE_Walk, true,, m_vTargetPosition, 'PatrolArea', 'AtDestination' );

AtDestination:
    // Chance of looking around
    if(rand(3)!=0)
    {
        if(rand(2)==0)
        {
            m_pawn.m_wWantedHeadYaw = RandRange( 5000, 10000 )/256;
            Sleep( RandRange(1,2.5) );
            m_pawn.m_wWantedHeadYaw = RandRange( -10000, -5000 )/256;
            Sleep( RandRange(1,2.5) );
        }
        else
        {
            m_pawn.m_wWantedHeadYaw = RandRange( -10000, -5000 )/256;
            Sleep( RandRange(1,2.5) );
            m_pawn.m_wWantedHeadYaw = RandRange( 5000, 10000 )/256;
            Sleep( RandRange(1,2.5) );
        }
        m_pawn.m_wWantedHeadYaw = 0;
    }
    Sleep( RandRange(1,2) );

    Goto('ChooseDestination');
}

//============================================================================
//  ####    ###   #####  ####    ###   ##      ####    ###   #####  ##  #
//  ##  #  ##  #   ##    #   #  ##  #  ##      ##  #  ##  #   ##    ##  #
//  ####   #####   ##    ####   ##  #  ##      ####   #####   ##    #####
//  ##     ##  #   ##    ## #   ##  #  ##      ##     ##  #   ##    ##  #
//  ##     ##  #   ##    ##  #   ###   #####   ##     ##  #   ##    ##  #
//============================================================================

// Random decision function
function FLOAT GetWaitingTime()
{
    local FLOAT fTemp;
    
    // Get the minimum time (the max is 2 times the min)
    switch(m_pawn.m_eDefCon)
    {
        case DEFCON_1: fTemp = 1; break;
        case DEFCON_2: fTemp = 2; break;
        case DEFCON_3: fTemp = 3; break;
        case DEFCON_4: fTemp = 4; break;
        case DEFCON_5: fTemp = 5; break;
    }
    
    return RandRange(fTemp, fTemp+fTemp);
}

function FLOAT GetFacingTime()
{
    local INT fTemp;
    
    // Get the minimum time (the max is 2 times the min)
    switch(m_pawn.m_eDefCon)
    {
        case DEFCON_1: fTemp = 1; break;
        case DEFCON_2: fTemp = 2; break;
        case DEFCON_3: fTemp = 3; break;
        case DEFCON_4: fTemp = 4; break;
        case DEFCON_5: fTemp = 5; break;
    }
    
    return RandRange(fTemp, fTemp+fTemp);
}

function BOOL IsGoingBack()
{
    local INT iTemp;

    switch(m_pawn.m_eDefCon)
    {
        case DEFCON_1: iTemp = 30; break;
        case DEFCON_2: iTemp = 25; break;
        case DEFCON_3: iTemp = 20; break;
        case DEFCON_4: iTemp = 10; break;
        case DEFCON_5: iTemp =  0; break;
    }

    return (Rand(100)+1) < iTemp;  // 1 to 100
}

function Rotator ChooseRandomDirection( int iLookBackChance  )
{
    local INT iTemp;

    // Get the chance of looking back (in percentage)
    switch(m_pawn.m_eDefCon)
    {
        case DEFCON_1: iTemp = 25; break;
        case DEFCON_2: iTemp = 20; break;
        case DEFCON_3: iTemp = 15; break;
        case DEFCON_4: iTemp = 10; break;
        case DEFCON_5: iTemp =  5; break;
    }

    return Super.ChooseRandomDirection( iTemp );
}

// Sent messages
function ReachedTheNode()
{
    m_bWaiting = true;
    m_path.InformTerroTeam(INFO_ReachNode, Self);
}

function FinishedWaiting()
{
    m_bWaiting = true;
    m_path.InformTerroTeam(INFO_FinishWaiting, Self);
}

// Callback
function GotoNode( vector vPosition )
{
    m_bWaiting = false;
    GotoStateMovingTo( "GotoNode", PACE_Walk, true,, vPosition, 'PatrolPath', 'ReachedNode', true );
}

function FollowLeader( R6Terrorist leader, vector vOffset )
{
    // positive vOffset.X means in front of the followed pawn
    #ifdefDEBUG if(bShowLog) logX( "FollowPawn " $ leader $ "from " $ vOffset $ " (Size:" $ VSize(vOffset) $ ", Pitch, Yaw, Roll:" $ rotator(vOffset) $ ")" ); #endif
    m_bWaiting = false;
    GotoStateFollowPawn( leader, FMODE_Path, VSize(vOffset), rotator(vOffset).Yaw );
}

function WaitAtNode( FLOAT fWaitingTime, FLOAT fFacingTime, Rotator rOrientation )
{
    m_bWaiting = false;
    m_fWaitingTime = fWaitingTime;
    m_fFacingTime = fFacingTime;
    m_rStandRotation = rOrientation;
    GotoState('PatrolPath', 'WaitingAtNode');
}

state PatrolPath
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX ("Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
    }

    function EndState()
    {
        m_pawn.m_wWantedHeadYaw = 0;
        m_pawn.m_bAvoidFacingWalls = false;
        m_pawn.ClearChannel( m_pawn.C_iPawnSpecificChannel );
    }

Begin:
    if(m_PatrolCurrentLabel != '')
        Goto(m_PatrolCurrentLabel);

    FinishedWaiting();
    Stop;

ReachedNode:
    m_PatrolCurrentLabel = 'ReachedNode';
    ReachedTheNode();
    Stop;

WaitingAtNode:
    m_PatrolCurrentLabel = 'WaitingAtNode';

    StopMoving();
    ChangeOrientationTo( m_rStandRotation );
    FinishRotation();
    if(m_CurrentNode.bDirectional)
    {
        m_pawn.m_wWantedAimingPitch = m_CurrentNode.Rotation.Pitch/256;
    }
    else
    {
        m_pawn.m_bAvoidFacingWalls = true;
    }

    // Check if we must play a special animation on this node
    if(m_CurrentNode.m_AnimToPlay!='')
    {
        if( rand(100) < m_CurrentNode.m_AnimChance )
        {
            if (m_CurrentNode.m_SoundToPlay != none)
                m_pawn.PlayVoices(m_CurrentNode.m_SoundToPlay, SLOT_Talk, 15);

            m_pawn.m_szSpecialAnimName = m_CurrentNode.m_AnimToPlay;
            m_pawn.SetNextPendingAction( PENDING_SpecialAnim );
            FinishAnim( m_pawn.C_iPawnSpecificChannel );
        }
    }    

    // If DEFCON 1 or 2, 50% of crouching
    if(m_fWaitingTime>0 && m_pawn.m_eDefCon <= DEFCON_2 )
    {
        if(!m_pawn.m_bPreventCrouching && rand(2)==0)
            m_pawn.bWantsToCrouch = true;
    }

    if(m_fFacingTime<m_fWaitingTime)
    {
        Sleep(m_fFacingTime);
        m_pawn.m_wWantedAimingPitch = 0;
        ChangeOrientationTo( ChooseRandomDirection( -1 ) );
        Sleep(m_fWaitingTime-m_fFacingTime);
        FinishRotation();
    }
    else
    {
        // if not a directional node, chance of looking around.
        if(!m_CurrentNode.bDirectional && rand(3)!=0)
        {
            if(rand(2)==0)
            {
                m_pawn.m_wWantedHeadYaw = RandRange( 5000, 10000 )/256;
                Sleep( m_fWaitingTime/3 );
                m_pawn.m_wWantedHeadYaw = RandRange( -10000, -5000 )/256;
                Sleep( m_fWaitingTime/3 );
            }
            else
            {
                m_pawn.m_wWantedHeadYaw = RandRange( -10000, -5000 )/256;
                Sleep( m_fWaitingTime/3 );
                m_pawn.m_wWantedHeadYaw = RandRange( 5000, 10000 )/256;
                Sleep( m_fWaitingTime/3 );
            }
            m_pawn.m_wWantedHeadYaw = 0;

            Sleep(m_fWaitingTime/3);
        }
        else
        {
            Sleep(m_fWaitingTime);
        }

        m_pawn.m_wWantedAimingPitch = 0;
    }

    FinishedWaiting();
    m_pawn.m_bAvoidFacingWalls = false;
    m_pawn.bWantsToCrouch = false;
}

//============================================================================
//  ##  #   ##  #   #   #   #####   
//  ##  #   ##  #   ##  #    ##     
//  #####   ##  #   # # #    ##     
//  ##  #   ##  #   #  ##    ##     
//  ##  #   #####   #   #    ##     
//============================================================================
state HuntRainbow
{
    function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX ("Enter STATE"); #endif
        SetReactionStatus( REACTION_HearAndSeeAll, EVSTATE_DefaultState );
    }

    function R6Pawn GetClosestEnemy()
    {
        local R6Pawn aEnemy;
        local R6Pawn aClosestEnemy;
        local FLOAT fDist;
        local FLOAT fBestDist;

        foreach DynamicActors( class'R6Pawn', aEnemy )
        {
            if( m_pawn.IsEnemy( aEnemy ) && aEnemy.IsAlive())
            {
                fDist = VSize(aEnemy.Location - Pawn.Location);
                if( fDist<fBestDist || fBestDist == 0 )
                {
                    fBestDist = fDist;
                    aClosestEnemy = aEnemy;
                }
            }
        }

        return aClosestEnemy;
    }

begin:
FindNewEnemy:
    
    // if hunted pawn was killed    
    if ( m_huntedPawn != none && !m_huntedPawn.IsAlive() )
    {
        m_huntedPawn  = none;
    }
    
    if ( m_huntedPawn == none )
        SetEnemy( GetClosestEnemy() );  // Find closest enemy
    else
        SetEnemy( m_huntedPawn );       // set the primary target to kill

    #ifdefDEBUG if(bShowLog) logX("Hunting enemy: " $ Enemy ); #endif

NextNode:
    // Find next node to enemy
    if( R6Pawn(Enemy)!=none && R6Pawn(Enemy).IsAlive() )
    {
        MoveTarget = FindPathToward( Enemy );
        if(MoveTarget!=none)
        {
            #ifdefDEBUG if(bShowLog) logX("Moving to : " $ MoveTarget ); #endif
            GotoStateMovingTo( "HuntRainbow", PACE_Walk, true, MoveTarget,, 'HuntRainbow', 'NextNode', true );
        }
    }

    #ifdefDEBUG if(bShowLog) logX("Enemy (" $ Enemy $ ") not valid, or not able to move toward." ); #endif
    Sleep(1);
    goto('FindNewEnemy');
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
    // if the pawn is not already interacting with another object, and he is still alive and active
    if( m_InteractionObject == none && 
        m_pawn != none &&
        m_pawn.IsAlive() && 
        m_eReactionStatus == REACTION_HearAndSeeAll && 
        m_pawn.m_eDefCon >= DEFCON_3 &&
        m_pawn.m_eStrategy != STRATEGY_Hunt )
    {
        return true;
    }

    return false;
}

function PerformAction_StopInteraction()
{
    #ifdefDEBUG if(bShowLog) logX("PerformStopInteraction: " $ m_InteractionObject @ m_bCantInterruptIO ); #endif
    
    if(  m_bCalledForBackup
      || m_InteractionObject.m_SeePlayerPawn != none
      || m_InteractionObject.m_HearNoiseNoiseMaker != none )
    {
        ChangeDefCon( DEFCON_2 );
    }

    Super.PerformAction_StopInteraction();

    if(m_bCalledForBackup && !m_bCantInterruptIO)
    {
        m_bCalledForBackup = false;
        m_InteractionObject = none;
        GotoPointToAttack( m_vThreatLocation, Target );
    }
}

state PA_PlayAnim
{
    function EndState()
    {
        m_pawn.SetNextPendingAction( PENDING_StopSpecialAnim );
        Super.EndState();
    }
Begin:
    m_pawn.m_szSpecialAnimName = m_AnimName;
    m_pawn.SetNextPendingAction( PENDING_SpecialAnim );
    FinishAnim( m_pawn.C_iPawnSpecificChannel );

    AnimBlendToAlpha( m_pawn.C_iPawnSpecificChannel, 0.0, 0.5 );
    m_pawn.m_ePlayerIsUsingHands = HANDS_None;
    m_pawn.PlayWeaponAnimation();
    m_pawn.m_bPawnSpecificAnimInProgress = false;

    m_InteractionObject.FinishAction();
}

state PA_LoopAnim
{
    function BeginState()
    {
        m_fSearchTime = Level.TimeSeconds + m_fLoopAnimTime;
        Super.BeginState();
    }

    function EndState()
    {
        m_pawn.SetNextPendingAction( PENDING_StopSpecialAnim );
        Super.EndState();
    }
Begin:
    m_pawn.m_szSpecialAnimName = m_AnimName;
    m_pawn.SetNextPendingAction( PENDING_LoopSpecialAnim );

    if(m_fLoopAnimTime != 0.0f)
        Sleep(m_fLoopAnimTime);
    else
        Stop;

    m_InteractionObject.FinishAction();
}

//============================================================================
// defaultproperties
//============================================================================

defaultproperties
{
     bIsPlayer=True
}
