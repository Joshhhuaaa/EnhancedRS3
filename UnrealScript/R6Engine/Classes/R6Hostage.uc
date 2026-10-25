//=============================================================================
//  R6Hostage.uc : This is the pawn class for all hostages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/11 * Created by Rima Brek
//=============================================================================
class R6Hostage extends R6Pawn
    notplaceable
    native
    abstract;

import class R6HostageMgr;
 
enum EHandsUpType
{
    HANDSUP_none,
    HANDSUP_kneeling,
    HANDSUP_standing
};

enum EStartingPosition
{
    POS_Stand,
    POS_Kneel,
    POS_Prone,
    POS_Foetus,
    POS_Crouch,
    POS_Random
};

enum ECivPatrolType
{
    CIVPATROL_None,
    CIVPATROL_Path,
    CIVPATROL_Area,
    CIVPATROL_Point
};

enum EStandWalkingAnim
{
    eStandWalkingAnim_default,
    eStandWalkingAnim_scared,
};

enum eHostageOrder 
{
    HOrder_None,
    HOrder_ComeWithMe,
    HOrder_StayHere,
    HOrder_Surrender,
    HOrder_GotoExtraction
    // ** if you add a new order, don't forget to reset the threat in the prpcess function
};

struct STRepHostageAnim
{
    var EStandWalkingAnim m_eRepStandWalkingAnim;
    var bool m_bRepPlayMoving;
};


// random time: keep a state
var(StayInThisState) RandomTweenNum         m_stayInFoetusTime;
var(StayInThisState) RandomTweenNum         m_stayFrozenTime;
var(StayInThisState) RandomTweenNum         m_stayProneTime;
var(StayInThisState) RandomTweenNum         m_stayCautiousGuardedStateTime;
var()                RandomTweenNum         m_patrolAreaWaitTween;
var()                RandomTweenNum         m_changeOrientationTween;
var()                RandomTweenNum         m_sightRadiusTween;
var()                RandomTweenNum         m_updatePaceTween;
var()                RandomTweenNum         m_waitingGoCrouchTween;

// initialized by the template
var                  string                 m_szUsedTemplate;
var (Personality)    EHostagePersonality    m_ePersonality;         // type of personality
var                  R6DeploymentZone       m_DZone;                // deployment zone
var                  BOOL                   m_bInitFinished;        // true when the initializing process of dzone is over
var                  bool                   m_bStartAsCivilian;     // start has a civilian
var                 bool                    m_bCivilian;                // true when civilian (faster than isInState('Civilian')
var (StartingPosition) EStartingPosition    m_ePosition;            // kneel or standing
var                  ECivPatrolType         m_eCivPatrol;           // type of patrol in the depZone

var                  R6DZonePathNode        m_currentNode;          // when in CivPatrolPath
var                  BOOL                   m_bPatrolForward;       // when in CivPatrolPath

// MPF1
var bool			m_bPoliceManMp1;// policeMan for MissionPack1 (ignores SeePlayer, HearNoise and QueryAction=0)
var bool			m_bPoliceManHasWeapon;
var bool			m_bPoliceManCanSeeRainbows;
var name			m_NocsWaitingName;//MissionPack1
var name			m_NocsSeeRainbowsName;//MissionPack1

var bool            m_bIsKneeling;
var bool            m_bIsFoetus;
var bool            m_bFrozen;          // frozen for kneeling/standing anim
var name            m_globalState;      // used to check if we are in the GotoState('')
var EHandsUpType    m_eHandsUpType;     // used to know if we have to play anim transition when hands are up/down
var R6HostageMgr    m_mgr;              // quick reference
var R6HostageAI     m_controller;       // quick reference
var bool            m_bReactionAnim;    // true when playing a reaction anim
var INT             m_iIndex;           // Used in the TerroristMgr to rapidely find an hostage already in the array
var INT             m_iPrisonierTeam;
var bool            m_bCrouchToScaredStandBegin; // true when play this anim

var       R6Rainbow             m_escortedByRainbow;
var       bool                  m_bFreed;                   // true when not guarded 
var       bool                  m_bEscorted;           // in escorte mode
var       bool                  m_bExtracted;          // true when enter an extration zone
var       bool                  m_bFeedbackExtracted;  // true when we process the feedback
var       bool                  m_bClassicMissionCivilian;

var byte m_bRepWaitAnimIndex;
var byte m_bSavedRepWaitAnimIndex;

var STRepHostageAnim m_eSavedRepHostageAnim;
var STRepHostageAnim m_eCurrentRepHostageAnim;

replication
{
    reliable if (Role == ROLE_Authority)
        m_eCurrentRepHostageAnim,m_bRepWaitAnimIndex,m_ePosition,m_escortedByRainbow,
        m_bFreed,m_bEscorted,m_bFrozen,m_bIsFoetus,m_bIsKneeling,m_bExtracted,m_eHandsUpType;
}

simulated function Tick(FLOAT fDeltaTime)
{
    if (Role<ROLE_Authority)
    {        
        if ( (m_eSavedRepHostageAnim.m_bRepPlayMoving != m_eCurrentRepHostageAnim.m_bRepPlayMoving) ||
             (m_eSavedRepHostageAnim.m_eRepStandWalkingAnim != m_eCurrentRepHostageAnim.m_eRepStandWalkingAnim ) 
           )
        {
            SetStandWalkingAnim(m_eCurrentRepHostageAnim.m_eRepStandWalkingAnim,m_eCurrentRepHostageAnim.m_bRepPlayMoving);
            m_eSavedRepHostageAnim = m_eCurrentRepHostageAnim;
        }

        if (m_bSavedRepWaitAnimIndex != m_bRepWaitAnimIndex)
        {
            m_bSavedRepWaitAnimIndex = m_bRepWaitAnimIndex;
            SetAnimInfo(m_bRepWaitAnimIndex);
        }
    }
    
    UpdateVisualEffects(fDeltaTime);
}

//------------------------------------------------------------------
// GetReticuleInfo
//	
//------------------------------------------------------------------
simulated event BOOL GetReticuleInfo( Pawn ownerReticule, OUT string szName )
{ 
    szName = "";

    return ownerReticule.isFriend( self ) || ownerReticule.isNeutral( self );
}

//============================================================================
// FinishInitialization - 
//============================================================================
event FinishInitialization()
{
    // Spawn the controller
    if(Controller!=None)
    {
        UnPossessed();
    }
	Controller = Spawn(ControllerClass);
    Controller.Possess( Self );

    // Sound setting 
    Controller.m_PawnRepInfo.m_PawnType = m_ePawnType;
    Controller.m_PawnRepInfo.m_bSex = bIsFemale;
    if (m_SoundRepInfo != none)
        m_SoundRepInfo.m_PawnRepInfo = Controller.m_PawnRepInfo;

    // Sound setting END


    m_controller = R6HostageAI(controller);
}

//------------------------------------------------------------------
// logAnim: special log for anim
//------------------------------------------------------------------
function logAnim( string sz )
{
   #ifdefDEBUG if ( bShowLog ) logX( "[ANIM] " $sz ); #endif
}

//------------------------------------------------------------------
// HasBumpPriority
//	
//------------------------------------------------------------------
function bool HasBumpPriority( R6Pawn bumpedBy )
{
    if ( !bumpedBy.m_bIsPlayer && R6AIController( bumpedBy.controller ).isInState( 'BumpBackUp' ) )
        return false; // help him move back
    
    if ( IsFriend( bumpedBy ) && !bumpedBy.IsStationary() )
        return false; // i don't have priority over a rainbow who his moving

    return true;
}

//------------------------------------------------------------------
// AnimEnd
//	inherited to detect a modification m_bPostureTransition
//------------------------------------------------------------------
simulated event AnimEnd(INT iChannel)
{
    local bool bPreviousPostureTransition;
    
    bPreviousPostureTransition = m_bPostureTransition;
	
    Super.AnimEnd( iChannel );

    // grenade reaction
    if( iChannel == C_iBaseAnimChannel )
	{		
        if ( physics != PHYS_RootMotion && !m_bPawnSpecificAnimInProgress )		
        {
			if ( m_eEffectiveGrenade == GTYPE_TearGas )
            {
                SetNextPendingAction( PENDING_Coughing );
            }
            else if ( m_eEffectiveGrenade == GTYPE_FlashBang || m_eEffectiveGrenade == GTYPE_BreachingCharge )
            {
                SetNextPendingAction( PENDING_Blinded );
            }
        }
	}
    else if((iChannel == C_iPawnSpecificChannel) && m_bPawnSpecificAnimInProgress)
	{
        #ifdefDEBUG logAnim( "anim end: set m_bPawnSpecificAnimInProgress = false" ); #endif
		m_bPawnSpecificAnimInProgress = false;	

        if ( m_eEffectiveGrenade == GTYPE_TearGas )
        {
            SetNextPendingAction( PENDING_Coughing );
        }
        else if ( m_eEffectiveGrenade == GTYPE_FlashBang || m_eEffectiveGrenade == GTYPE_BreachingCharge )
        {
            SetNextPendingAction( PENDING_Blinded );
        }
	}

    if ( bPreviousPostureTransition && !m_bPostureTransition )
    {
        #ifdefDEBUG logAnim( "transition: end" ); #endif

        if ( m_bCrouchToScaredStandBegin )
        {
            AnimNotify_CrouchToScaredStandEnd();
        }
	    m_bPostureTransition = false;
        m_bReactionAnim = false;
        R6ResetAnimBlendParams(C_iBaseBlendAnimChannel);

        // PlayAnim('Stand_nt', 1.0, 0.2, C_iBaseBlendAnimChannel);  
        // commented out: causing problem with after a posture transition
        //   the only purpose for doing this is to make sure that there is another 
        //   animation presetn in this channel, so that the next time it does not 
        //   ignore the tween time...
        PlayMoving();  // force to update all his animation played after the transition
        PlayWaiting(); // force to have a wait anim in the new posture.
    }
}

simulated event PlaySpecialPendingAction( EPendingAction eAction, INT iActionInt )
{
    if ( eAction == PENDING_HostageAnim )    
    {
        if ( Role != ROLE_Authority ) // the client
        {
            SetAnimInfo( m_iPendingActionInt[m_iLocalCurrentActionIndex] );
        }
    }
    else
    {
        Super.PlaySpecialPendingAction( eAction, iActionInt );
    }
}
//------------------------------------------------------------------
// SetAnimInfo: set the current anim to play based on his
//	properties. 
//------------------------------------------------------------------
simulated event SetAnimInfo( INT id )
{
    local R6HostageMgr.AnimInfo animInfo;

    if ( m_mgr == none )
        return;

    animInfo = m_mgr.GetAnimInfo(id);
    
    if ( animInfo.m_eGroupAnim == eGroupAnim_transition && m_bReactionAnim )
    {
        #ifdefDEBUG logAnim( "a reaction is played and starts a transition " ); #endif
    }
    // a transition is played AND NOT a new transition must be played, finish posture transition
    else if ( m_bPostureTransition && animInfo.m_eGroupAnim != eGroupAnim_transition  )
    {
        #ifdefDEBUG logAnim( "* WARNING * SetAnimInfo called when m_bPostureTransition was true (problem?)" ); #endif
        
        if ( Level.NetMode == NM_Client )
            m_bPostureTransition = false; // client should follow server update
        else
            return;
    }

    // set the anim for the client
    if ( Role == Role_Authority && Level.NetMode != NM_Standalone )
    {
        if ( animInfo.m_eGroupAnim == eGroupAnim_wait )
            m_bRepWaitAnimIndex = id;
        else
            SetNextPendingAction( PENDING_HostageAnim, id );
    }
    
    if ( animInfo.m_eGroupAnim == eGroupAnim_reaction || animInfo.m_eGroupAnim == eGroupAnim_transition )
    {
        #ifdefDEBUG logAnim( "transition: begin" ); #endif
        m_bPostureTransition = true;
        AnimBlendParams( C_iBaseBlendAnimChannel, 1.0, 0.3, 0.0); // 1= blendAlpha 0.3=rate
        PlayAnim( animInfo.m_name, 1.0, 0.2, C_iBaseBlendAnimChannel);
        m_bReactionAnim = animInfo.m_eGroupAnim == eGroupAnim_reaction;
    }
    else
    {
        // todop: it was disabled because of tween problem
        // if ( animInfo.m_ePlayType == ePlayType_Random )
        // {
        //     if ( rand( 2 ) == 1 ) // 1 out 2
        //     {
        //         fRate *= -1;
        //     }
        // }

        R6LoopAnim( animInfo.m_name ); // always loop anim to allow blending
    }
    #ifdefDEBUG logAnim( "play anim: "$animInfo.m_name ); #endif
}

//------------------------------------------------------------------
// SetAnimTransition: set the transition anim to play and to the next pawn 
// 	state to go when the transition is over.
// - First it looks if the transition exist in the Manager. This 
//   can be used we want to customize the anim transition. 
// - If not in the mgr, it check if it's anim of type transition.
//   If so, it will blend the current anim with the transition one.
// - If option 1 and 2 failed, it will set the anim and set the new pawn state   
//------------------------------------------------------------------
simulated function SetAnimTransition( INT iAnimToPlay, name pawnStateToGo )
{
    local R6HostageMgr.AnimInfo animInfo;

    SetAnimInfo( iAnimToPlay );
    if ( !m_bUseRagdoll )
        GotoState( pawnStateToGo );
}


//------------------------------------------------------------------
// Initialize the default value 
//------------------------------------------------------------------
simulated event PostBeginPlay()
{
    local INT i;

    if ( Level.Game != none  )
    {
        assert( default.m_iTeam == R6AbstractGameInfo(Level.Game).c_iTeamNumHostage );
    }

    m_globalState = GetStateName();
    Super.PostBeginPlay();
	SetPhysics(PHYS_Walking);

    AttachCollisionBox( 1 );
    m_mgr = R6HostageMgr( level.GetHostageMgr() );

}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    switch ( m_ePosition )
    {
    case POS_Crouch:
        GotoCrouch(); 
        break;
        
    case POS_Kneel:        
        GotoKneel();
        break;
        
    case POS_Foetus:       
        GotoFoetus(); 
        break;
        
    case POS_Prone:        
        GotoProne(); 
        break;
        
    default:
        GotoStand();
        break;
    }

}

//------------------------------------------------------------------
// may freeze when the hostage see a new terrorist or rainbow
//------------------------------------------------------------------
function setFrozen( bool bFreeze )
{
    #ifdefDEBUG if (bShowLog) logX( "setFrozen: "$bFreeze ); #endif
    m_bFrozen = bFreeze;
}

//------------------------------------------------------------------
// setCrouch
//------------------------------------------------------------------
function setCrouch( bool bIsCrouch )
{
    #ifdefDEBUG if(bShowLog) logX( "setCrouch: " $bIsCrouch$ "(bWantsToCrouch: " $bWantsToCrouch$ " bIsCrouched: " $bIsCrouched$ ")" ); #endif

    bWantsToCrouch = bIsCrouch;

    if ( bWantsToCrouch )
    {
        if ( Level.NetMode != NM_Client )
            m_eHandsUpType = HANDSUP_none;
    }
}

//------------------------------------------------------------------
// setProne
//------------------------------------------------------------------
function setProne( bool bIsProne )
{
    #ifdefDEBUG if(bShowLog) logX( "setProne: " $bIsProne ); #endif

    m_bWantsToProne = bIsProne;
}


//=============================================================================
// isStanding: return true if hostage is standing
//=============================================================================
function bool isStanding()
{
    return (getStateName() == m_globalState);
}

//=============================================================================
// isStandingHandUp: return true if hostage is standing with hands up 
//=============================================================================
function bool isStandingHandUp()
{
    return (m_eHandsUpType == HANDSUP_standing);
}


//=============================================================================
// isFoetus: return true if hostage is in foetus position
//=============================================================================
function bool isFoetus()
{
    return m_bIsFoetus;
}

//=============================================================================
// isKneeling: return true if hostage is kneeling
//=============================================================================
function bool isKneeling()
{
    return m_bIsKneeling;
}


//------------------------------------------------------------------
// R6TakeDamage: when wounded, will sets the HurtAnim
//	- inherited
//------------------------------------------------------------------
function INT R6TakeDamage( INT iKillValue, INT iStunValue, 
                            Pawn instigatedBy, vector vHitLocation, 
                            vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGoup)
{
    local eHealth ePreviousHealth;
    local INT iResult;
    local int iSndIndex;

    if ( m_bExtracted )
        return 0;

    ePreviousHealth = m_eHealth;
    iResult = Super.R6TakeDamage( iKillValue, iStunValue, instigatedBy, vHitLocation, 
                                  vMomentum, iBulletToArmorModifier, iBulletGoup);

    // is alive and shoot by a friend
    if ( ePreviousHealth != m_eHealth && eHealth.HEALTH_Wounded <= m_eHealth )
    {
        if ( m_controller != none ) 
            m_controller.SetMovementPace( false );
        
        if ( m_escortedByRainbow != none )
        {
            m_escortedByRainbow.Escort_UpdateTeamSpeed();
        }
        
        PlayMoving();
    }

    return iResult;
}

//------------------------------------------------------------------
// PlayWeaponAnimation
//	- inherited to avoid Access None and Wrong 
//------------------------------------------------------------------
function PlayWeaponAnimation()
{
	//MissionPack1 // MPF1
	if(m_bPoliceManMp1)// to become m_bPoliceManMp1
		Super.PlayWeaponAnimation();

}
function ResetWeaponAnimation()
{
}

//------------------------------------------------------------------
// SetStandWalkingAnim: set the current name for anim to play when
//	walking
//------------------------------------------------------------------

simulated function SetStandWalkingAnim( EStandWalkingAnim eAnim, bool bUpdatePlayMoving )
{
    #ifdefDEBUG if(bShowLog) logX( "SetStandWalkingAnim: " $eAnim ); #endif

    m_eCurrentRepHostageAnim.m_eRepStandWalkingAnim = eAnim;
    m_eCurrentRepHostageAnim.m_bRepPlayMoving = bUpdatePlayMoving;

    if ( eAnim == eStandWalkingAnim_default )
    {
        SetDefaultWalkAnim();
        m_fWalkingSpeed = 134.0; 
    }
    else 
    {
        m_standWalkForwardName  = 'ScaredStandWalkForward';
        m_standWalkBackName     = 'ScaredStandWalkBack';
        m_standWalkLeftName     = 'ScaredStandWalkLeft';
        m_standWalkRightName    = 'ScaredStandWalkRight';
        m_standTurnLeftName     = 'ScaredStandTurnLeft';
        m_standTurnRightName    = 'ScaredStandTurnRight';
        m_standDefaultAnimName  = 'ScaredStand_nt';
        
        m_standClimb64DefaultAnimName = 'ScaredStandClimb64Up';
        m_standClimb96DefaultAnimName = 'ScaredStandClimb96Up';
        
        m_fWalkingSpeed         = default.m_fWalkingSpeed;
    }

    // hurt anim
    m_hurtStandWalkLeftName  = m_standWalkLeftName;
    m_hurtStandWalkRightName = m_standWalkRightName;    

    // update MovementAnims
    if ( bUpdatePlayMoving )
        PlayMoving();
}

//------------------------------------------------------------------
// PlayReaction: if not frozen, play a reaction animation 
//	
//------------------------------------------------------------------
function PlayReaction()
{
    local INT result; 

    if ( m_bFrozen || m_bReactionAnim )
        return;

    if ( isStandingHandUp()  )
    {
        result = rand( 100 );
        
        if ( result < 33 )
        {
            SetAnimInfo( m_mgr.ANIM_eStandHandUpReact01 );
        }
        else if ( result < 66 )
        {
            SetAnimInfo( m_mgr.ANIM_eStandHandUpReact02 );
        }
        else
        {
            SetAnimInfo( m_mgr.ANIM_eStandHandUpReact03 );
        }
    }
}


//------------------------------------------------------------------
// PlayWaiting: play waiting animation randomly
//  - inherited
//------------------------------------------------------------------
simulated function PlayWaiting()
{
    local INT animIndex;
    local INT result;

    if ( m_bPostureTransition )
    {
        // logX( "PlayWaiting skipped because m_bPostureTransition is TRUE" );
        return;
    }

    if(physics == PHYS_Falling)	{		PlayFalling();				    return;	}
    if(m_bIsClimbingLadder) 	{		AnimateStoppedOnLadder();	    return; }

    if ( m_bIsKneeling )
    {
        result = rand( 100 );
        if ( m_bFrozen )
        {
            SetAnimInfo( m_mgr.ANIM_eKneelFreeze );
        }
        else // MPF1
		{
			if(m_bCivilian)//Begin MissionPack1
			{
				if(m_bPoliceManMp1)
				{
					R6LoopAnim(m_NocsWaitingName);

				}
				else
				{
					if( result < 50 ) 
					{
						SetAnimInfo( m_mgr.ANIM_eFoetusWait01 );
					}
					else 
					{
						SetAnimInfo( m_mgr.ANIM_eFoetusWait02 );
					}
				}

			}
			else
			{//End MissionPack1
				if ( result < 33 )
				{
					SetAnimInfo( m_mgr.ANIM_eKneelWait01 );
				}
				else if ( result < 66 )
				{
					SetAnimInfo( m_mgr.ANIM_eKneelWait02 );
				}
				else 
				{
					SetAnimInfo( m_mgr.ANIM_eKneelWait03 );
				}    
			}//MissionPack1
        }
        
        return;
    }
    else if ( m_bIsFoetus )
    {
        result = rand( 100 );
        
        if ( result < 50 )
        {
            SetAnimInfo( m_mgr.ANIM_eFoetusWait01 );
        }
        else 
        {
            SetAnimInfo( m_mgr.ANIM_eFoetusWait02 );
        }
        return;
    }
    else if ( m_bIsProne )
    {
        SetAnimInfo( m_mgr.ANIM_eProneWaitBreathe );
        return;
    }
    else if ( bWantsToCrouch || bIsCrouched ) // the transition might not be over
    {
        if (  bWantsToCrouch  &&  bIsCrouched ) // the transition might not be over
        {
            // Wait02 seems to cause problem with Crouch/Uncrouch
            if (  rand(5) < 1 ) 
            {
                SetAnimInfo( m_mgr.ANIM_eCrouchWait02 );
            }
            else
            {
                SetAnimInfo( m_mgr.ANIM_eCrouchWait01 );
            }
        }
        return;
    }

    if ( !m_bFreed ) // if guarded by terror
    {
        if ( m_bFrozen ) 
        {
            SetAnimInfo( m_mgr.ANIM_eStandHandUpFreeze );
            
            if ( Level.NetMode != NM_Client )
                m_eHandsUpType = HANDSUP_standing;
        }
        else
        {   // guarded: play waiting or transition to hands up anim

            // escorted by a terrorist
            if ( m_bEscorted )
            { // MPF1
				if(m_bPoliceManMp1)//Begin MissionPack1
				{
					R6LoopAnim(m_NocsWaitingName);

				}
				else//End MissionPack1
                SetAnimInfo( m_mgr.ANIM_eStandWaitShiftWeight );
            }
            // if hands are not raised 
            else if ( m_eHandsUpType == HANDSUP_none ) 
            {
                if ( m_bClassicMissionCivilian )
                    SetAnimTransition( m_mgr.ANIM_eScaredStandWait01, '' );
                else
                    SetAnimTransition( m_mgr.ANIM_eStandHandDownToUp, '' );
                if ( Level.NetMode != NM_Client )
                    m_eHandsUpType = HANDSUP_standing;
            }
            // hands are raised
            else if ( m_eHandsUpType == HANDSUP_standing )
            {  // MPF1
				if(m_bCivilian)//Begin MissionPack1
				{
					if ( m_bClassicMissionCivilian )
					{
						if( rand(100) < 50 )
							SetAnimInfo( m_mgr.ANIM_eStandWaitCough );
						else
							SetAnimInfo( m_mgr.ANIM_eStandWaitShiftWeight );
					}
					else
					{
						if( rand(100) < 60 ) 
						{
							SetAnimInfo( m_mgr.ANIM_eScaredStandWait02 );
						}
						else
						{
							SetAnimInfo( m_mgr.ANIM_eScaredStandWait01 );
						}				
					}

				}
				else//End MissionPack1
                SetAnimInfo( m_mgr.ANIM_eStandHandUpWait01  );
            }
        }
    }
    else
    {
        // my hands are up,
        if ( m_eHandsUpType == HANDSUP_standing )
        {
            SetAnimTransition( m_mgr.ANIM_eStandHandUpToDown, '' );
            
            if ( Level.NetMode != NM_Client )
                m_eHandsUpType = HANDSUP_none;
        }
        else if ( m_escortedByRainbow != none )
        {
            // climbing ladder anim are using the stand posture
            if ( Physics == PHYS_Ladder )
            {
                // sometimes this anim seems to tween with the root motion anim that climbs
                SetAnimInfo( m_mgr.ANIM_eStandWaitShiftWeight );
            }
            // Wait02 seems to cause problem with Crouch/Uncrouch
            else if ( rand(5) < 1 ) 
            {
                SetAnimTransition( m_mgr.ANIM_eScaredStandWait02, '' );
            }
            else
            {
                SetAnimTransition( m_mgr.ANIM_eScaredStandWait01, '' );                
            }
        }
        else 
        {
            if ( rand( 100 ) < 75 )
            {
                SetAnimInfo( m_mgr.ANIM_eStandWaitShiftWeight );
            }
            else
            {
                SetAnimInfo( m_mgr.ANIM_eStandWaitCough );
            }
        }
    }
}

//////////////////////////////////////////////
simulated event GotoStand()
{
    #ifdefDEBUG if (bShowLog) logX( "::GotoStand" ); #endif

    setCrouch( false );    
    GotoState('');
}

///////////////////////////////////////////////
simulated event GotoCrouch()
{
    #ifdefDEBUG if (bShowLog) logX( "::gotoCrouch" ); #endif

    GotoState( 'Crouching' );
}

//////////////////////////////////////////////
simulated event GotoKneel()
{
    #ifdefDEBUG if (bShowLog) logX( "::GotoKneel" ); #endif
    
    setCrouch( false );
    
    if ( Level.NetMode != NM_Client )
        m_eHandsUpType = HANDSUP_kneeling;
    
	if(m_bPoliceManMp1)//Begin MissionPack1  // MPF1
		GotoState('Kneeling');
	else//EndMissionPack1
    SetAnimTransition( m_mgr.ANIM_eStandToKneel, 'Kneeling' );
}

//////////////////////////////////////////////
simulated event GotoFoetus()
{
    #ifdefDEBUG if (bShowLog) logX( "::GotoFoetus" ); #endif

    setCrouch( false );
    
    if ( Level.NetMode != NM_Client )
        m_eHandsUpType = HANDSUP_none;

    SetAnimTransition( m_mgr.ANIM_eStandToFoetus, 'Foetus' );
}

//////////////////////////////////////////////
simulated event GotoProne()
{
    #ifdefDEBUG if (bShowLog) logX( "::GotoProne" ); #endif
 
    GotoState('Prone' );
}

/////////////////////////////////////////////
function GotoFrozen()
{
    setFrozen( true );
    SetAnimInfo( m_mgr.ANIM_eStandHandUpFreeze );
    
    if ( Level.NetMode != NM_Client )
        m_eHandsUpType = HANDSUP_standing;
}

//------------------------------------------------------------------
// AnimNotify_CrouchToScaredStandEnd
//	
//------------------------------------------------------------------
function AnimNotify_CrouchToScaredStandEnd()
{
    #ifdefDEBUG logAnim( "Notify CrouchToScaredStandEnd" ); #endif
    
    m_bCrouchToScaredStandBegin = false;
    setCrouch( false );
}

//------------------------------------------------------------------
// AnimNotify_CrouchToScaredStandBegin
//	
//------------------------------------------------------------------
function AnimNotify_CrouchToScaredStandBegin()
{
    #ifdefDEBUG logAnim( "Notify CrouchToScaredStandBegin" ); #endif
    
    m_bCrouchToScaredStandBegin = true;
}


//------------------------------------------------------------------
// PlayDuck
//	- inherited
//------------------------------------------------------------------
function PlayDuck()
{
    // inherited to do nothing...
}

//------------------------------------------------------------------
// PlayCrouchToProne
//	- inherited
//------------------------------------------------------------------
simulated function PlayCrouchToProne( OPTIONAL bool bForcedByClient )
{
    SetAnimInfo( m_mgr.ANIM_eCrouchToProne );
}
//------------------------------------------------------------------
// state Crouching
//	- inherited
//------------------------------------------------------------------
simulated state Crouching
{
    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif

        if ( m_bIsProne )
        {
            setProne( false );
        }
        
        if ( !bWantsToCrouch || !bIsCrouched )
        {
            setCrouch( true );
        }
    }

    simulated event GotoCrouch()
    {
    }

    simulated event GotoFoetus()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoFoetus" ); #endif
        SetAnimTransition( m_mgr.ANIM_eFoetus_nt, 'Foetus' );
        setCrouch( false );
    }

    simulated event GotoStand()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoStand" ); #endif
        SetAnimTransition( m_mgr.ANIM_eCrouchToScaredStand, '' );
        // the function AnimNotify_CrouchToScaredStandEnd will call setCrouch( false )
    }

    simulated event GotoProne()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoProne" ); #endif

        GotoState( 'Prone' );
    }

    simulated event GotoKneel()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoKneel" ); #endif

        SetAnimTransition( m_mgr.ANIM_eKneelWait01, 'Kneeling' );
    }
}

//------------------------------------------------------------------
// State kneeling: 
//	
//------------------------------------------------------------------
simulated state Kneeling
{
    /////////////////////////////////////////////////////////////////////////
    simulated function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX( "::BeginState" ); #endif

        m_bIsKneeling = true;

        if ( Level.NetMode != NM_Client )
            m_eHandsUpType = HANDSUP_kneeling;
        setCrouch( false );
    }

    simulated function EndState()
    {
        if ( Level.NetMode != NM_Client )
            m_eHandsUpType = HANDSUP_none;

        m_bIsKneeling = false;
    }

    /////////////////////////////////////////////////////////////////////////
    simulated function PlayReaction()
    {
        local INT result; 

        if ( m_bFrozen || m_bReactionAnim )
            return;

        result = rand( 100 );
    
        if ( result < 33 )
        {
            SetAnimInfo( m_mgr.ANIM_eKneelReact01 );
        }
        else if ( result < 66 )
        {
            SetAnimInfo( m_mgr.ANIM_eKneelReact02 );
        }
        else
        {
            SetAnimInfo( m_mgr.ANIM_eKneelReact03 );
        }
    }
    
    simulated function GotoFrozen()
    {
        setFrozen( true );
        SetAnimInfo( m_mgr.ANIM_eKneelFreeze );
    }

    //////////////////////////////////////////////
    simulated event GotoStand()
    {
        #ifdefDEBUG if (bShowLog) logX("::GotoStand"); #endif
        SetAnimTransition( m_mgr.ANIM_eKneelToStand, '' );
    }

    //////////////////////////////////////////////
    simulated event GotoKneel()
    {
    }

    //////////////////////////////////////////////
    simulated event GotoFoetus()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoFoestus" ); #endif

        SetAnimTransition( m_mgr.ANIM_eKneelToFoetus, 'Foetus' );
    }

    //////////////////////////////////////////////
    simulated event GotoProne()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoProne" ); #endif
        SetAnimTransition( m_mgr.ANIM_eKneelToProne, 'Prone' ); 
    }

    simulated event GotoCrouch()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoCrouch" ); #endif
        SetAnimTransition( m_mgr.ANIM_eKneelToCrouch, 'Crouching' );
    }
}


//------------------------------------------------------------------
// PlayProneToCrouch
//	- inherited
//------------------------------------------------------------------
simulated function PlayProneToCrouch( OPTIONAL bool bForcedByClient )
{
    SetAnimInfo( m_mgr.ANIM_eProneToCrouch );

    if ( Level.NetMode == NM_Client )
    {
        m_bWantsToProne = false;
        bWantsToCrouch  = true;
    }
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
simulated state Prone
{
    simulated function BeginState()
    {
        #ifdefDEBUG if(bShowLog) logX( "begin" ); #endif

        if ( !m_bWantsToProne || !m_bIsProne )
        {
            setProne( true );
        }
    }

    //////////////////////////////////////////////
    simulated event GotoStand()
    {
        #ifdefDEBUG if (bShowLog) logX("::GotoStand but go to crouch"); #endif
        SetAnimTransition( m_mgr.ANIM_eProneToCrouch, 'Crouching' );
    }

    //////////////////////////////////////////////
    simulated event GotoKneel()
    {
        #ifdefDEBUG if (bShowLog) logX("::GotoKneel do nothing..."); #endif
    }

    //////////////////////////////////////////////
    simulated event GotoFoetus()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoFoetus do nothing" ); #endif
    }

    //////////////////////////////////////////////
    simulated event GotoProne()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoProne" ); #endif
    }

    simulated event GotoCrouch()
    {
       #ifdefDEBUG if (bShowLog) logX( "::GotoCrouch" ); #endif
       GotoState( 'Crouching' );
    }

}

/*******************************************************************************/
// State foetus: 
//
//
simulated state Foetus
{
    simulated event GotoStand()
    {
        #ifdefDEBUG if (bShowLog) logX("::GotoStand"); #endif
        SetAnimTransition( m_mgr.ANIM_eFoetusToStand, '' );
    }

    simulated event GotoKneel()
    {
        #ifdefDEBUG if (bShowLog) logX("::GotoKneel"); #endif
        SetAnimTransition( m_mgr.ANIM_eFoetusToKneel, 'Kneeling' );
    }

    simulated event GotoFoetus()
    {
        #ifdefDEBUG if (bShowLog) logX("GotoFoetus"); #endif
    }
    
    simulated event GotoCrouch()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoCrouch" ); #endif
        SetAnimTransition( m_mgr.ANIM_eFoetusToCrouch, 'Crouching' );
    }

    //////////////////////////////////////////////
    simulated event GotoProne()
    {
        #ifdefDEBUG if (bShowLog) logX( "::GotoProne" ); #endif
        SetAnimTransition( m_mgr.ANIM_eFoetusToProne, 'Prone' ); 
    }

    simulated function BeginState()
    {
        #ifdefDEBUG if (bShowLog) logX( "::BeginState" ); #endif
        m_bIsFoetus = true;
    }

    simulated function EndState()
    {
        #ifdefDEBUG if (bShowLog) logX( "::EndState" ); #endif
        m_bIsFoetus = false;
    }

}

simulated function PlayCoughing()
{
    local name animName;

    #ifdefDEBUG logAnim( "PlayCoughing" ); #endif
    
    if ( m_bIsClimbingLadder )
    {
        return;
    }
    
    m_bPawnSpecificAnimInProgress = true;

    if ( m_bIsProne )
    {
        AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Pelvis' );
        animName = 'ProneGazed';
    }
    else
    {
        AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Spine2' );
        animName = 'Gazed';
    }

    PlayAnim( animName, 1, 0.5, C_iPawnSpecificChannel );

}

simulated function PlayBlinded()
{
    local name animName;
    
    if ( m_bIsClimbingLadder )
    {
        return;
    }

    #ifdefDEBUG logAnim( "PlayBlinded" ); #endif
    
    m_bPawnSpecificAnimInProgress = true;
        
    if ( m_bIsProne )
    {
        AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Pelvis' );
        animName = 'ProneBlinded';
    }
    else
    {
        AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Spine2' );
        animName = 'Blinded';
    }

    PlayAnim( animName, 1, 0.5, C_iPawnSpecificChannel );
}

//------------------------------------------------------------------
// CanBeAffectedByGrenade: return true if can be affected by the grenade 
//   at this moment
//------------------------------------------------------------------
simulated function bool CanBeAffectedByGrenade( Actor aGrenade, EGrenadeType eType )
{
    local bool bAffected;

    #ifdefDEBUG logAnim( "CanBeAffectedByGrenade" ); #endif

    bAffected = Super.CanBeAffectedByGrenade( aGrenade, eType );

    if ( !bAffected )
        return false;

    if ( isInState('foetus') || m_bPostureTransition )
        return false;
    
    return true;
}

simulated function PlayDoorAnim(R6IORotatingDoor door)
{
    local   bool    bOpensTowardsPawn;

    #ifdefDEBUG logAnim( "PlayDoorAnim" ); #endif

    m_bPawnSpecificAnimInProgress = true;
    AnimBlendParams( C_iPawnSpecificChannel, 1.0,,, 'R6 Spine2' );

	bOpensTowardsPawn = door.DoorOpenTowardsActor(self);

    // door opens towards pawn
    if(bOpensTowardsPawn)
		PlayAnim('StandDoorPull', 1.0, 0.2, C_iPawnSpecificChannel);
    else  // door opens away from pawn
		PlayAnim('StandDoorPush', 1.0, 0.2, C_iPawnSpecificChannel);
}


event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{ 
    if( !IsAlive() || m_bExtracted || IsEnemy( playerController.pawn ) || m_bClassicMissionCivilian )
    {
        Query.iHasAction = 0;
    }
    else
    {
        Query.iHasAction = 1;
        if (fDistance < m_fCircumstantialActionRange)
            Query.iInRange = 1;
        else
            Query.iInRange = 0;

        if( playerController.GameReplicationInfo.m_szGameTypeFlagRep == "RGM_LimitSeatsAdvMode" )
        {
            if( m_controller.Order_canFollowMe() )
            {
                if( R6PlayerController(playerController).m_pawn.m_aEscortedHostage[0] == none )
                {
                    Query.textureIcon = Texture'R6ActionIcons.HostageFollowMe';
                    Query.iPlayerActionID		= eHostageOrder.HOrder_ComeWithMe;
                    Query.iTeamActionID			= eHostageOrder.HOrder_ComeWithMe;
                    Query.iTeamActionIDList[0]	= eHostageOrder.HOrder_ComeWithMe;
                    Query.iTeamActionIDList[1]	= eHostageOrder.HOrder_None;
                    Query.iTeamActionIDList[2]	= eHostageOrder.HOrder_None;
                    Query.iTeamActionIDList[3]	= eHostageOrder.HOrder_None;
                }
                else
                    Query.iHasAction = 0;
            }
            else if( m_escortedByRainbow != R6PlayerController(playerController).m_pawn )
                Query.iHasAction = 0;
            else
            {
                Query.textureIcon = Texture'R6ActionIcons.HostageStayHere';
                Query.iPlayerActionID		= eHostageOrder.HOrder_StayHere;
                Query.iTeamActionID			= eHostageOrder.HOrder_StayHere;
                Query.iTeamActionIDList[0]	= eHostageOrder.HOrder_StayHere;
                Query.iTeamActionIDList[1]	= eHostageOrder.HOrder_None;
                Query.iTeamActionIDList[2]	= eHostageOrder.HOrder_None;
                Query.iTeamActionIDList[3]	= eHostageOrder.HOrder_None;
            }
        }
        else
        {
            if( m_controller.Order_canFollowMe() )
            {
                Query.textureIcon = Texture'R6ActionIcons.HostageFollowMe';
                Query.iPlayerActionID		= eHostageOrder.HOrder_ComeWithMe;
                Query.iTeamActionID			= eHostageOrder.HOrder_ComeWithMe;
                Query.iTeamActionIDList[0]	= eHostageOrder.HOrder_ComeWithMe;
            }
            else 
            {
                Query.textureIcon = Texture'R6ActionIcons.HostageStayHere';
                Query.iPlayerActionID		= eHostageOrder.HOrder_StayHere;
                Query.iTeamActionID			= eHostageOrder.HOrder_StayHere;
                Query.iTeamActionIDList[0]	= eHostageOrder.HOrder_StayHere;
            }

            Query.iTeamActionIDList[1] = eHostageOrder.HOrder_None;
            Query.iTeamActionIDList[2] = eHostageOrder.HOrder_None;
            Query.iTeamActionIDList[3] = eHostageOrder.HOrder_None;
        }
    }		
}

simulated function string R6GetCircumstantialActionString( INT iAction )
{
    switch( iAction )
    {
		case eHostageOrder.HOrder_ComeWithMe:  return Localize("RDVOrder", "Order_FollowMe", "R6Menu");
		case eHostageOrder.HOrder_StayHere:    return Localize("RDVOrder", "Order_StayHere", "R6Menu");
    }

    return "";
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone( R6AbstractExtractionZone zone )
{
	// MPF1
    if(!m_bCivilian && !m_bPoliceManMp1){//MissionPack1
		if ( m_controller != none )
		{
			m_controller.SetStateExtracted();
		}
	}//MissionPack1
}

//------------------------------------------------------------------
// ProcessBuildDeathMessage
//	
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage( Pawn Killer, OUT string szPlayerName )
{
    if ( Killer.m_ePawnType == PAWN_Rainbow )
    {
        if ( Level.Game != none )
        {
            if ( !(Level.Game.m_szGameTypeFlag == "RGM_LimitSeatsAdvMode") )
                m_bSuicideType = DEATHMSG_HOSTAGE_KILLEDBY;
            else
                m_bSuicideType = DEATHMSG_PRISONER_KILLEDBY;
        }
        else
            m_bSuicideType = DEATHMSG_HOSTAGE_KILLEDBY;
    }
    else if ( Killer.m_ePawnType == PAWN_Terrorist )
    {
        m_bSuicideType = DEATHMSG_HOSTAGE_KILLEDBYTERRO;
    }
    else
    {
        m_bSuicideType = DEATHMSG_HOSTAGE_DIED;
    }

    return true;    
}

//============================================================================
// vector EyePosition - 
//============================================================================
event vector EyePosition()
{
    local vector vEyeHeight;

    if(bIsCrouched)
        vEyeHeight.Z = 30;
    else if(m_bIsProne)
        vEyeHeight.Z = 0;
    else if(m_bIsKneeling)
        vEyeHeight.Z = 25;
    else if(m_bIsFoetus)
        vEyeHeight.Z = -60;
    else
        vEyeHeight.Z = 65;

    return vEyeHeight;
}

 // MPF1
///////////////////////////////
/////MissionPack1
//============================================================================
// SetToNormalWeapon - 
//============================================================================
function SetToNormalWeapon()
{
    // Get the primary Weapon
	EngineWeapon = GetWeaponInGroup(1);
    if(EngineWeapon==None)
    {
		logx("SetToNormalWeapon-No weapon!!!");
        EngineWeapon = GetWeaponInGroup(2);
    }
    EngineWeapon.RemoteRole = ROLE_SimulatedProxy;
    if(EngineWeapon!=none)
    {
        AttachWeapon(EngineWeapon, 'TagRightHand');

        EngineWeapon.WeaponInitialization( Self );
        m_pBulletManager.SetBulletParameter( EngineWeapon );
    }

    #ifdefDEBUG if(bShowLog) logX( " got the weapon " $ EngineWeapon ); #endif
}
/////MissionPack1
///////////////////////////////

defaultproperties
{
     m_ePersonality=HPERSO_Normal
     m_iIndex=-1
     m_bPatrolForward=True
     m_stayInFoetusTime=(m_fMin=5.000000,m_fMax=8.000000)
     m_stayFrozenTime=(m_fMin=1.000000,m_fMax=3.000000)
     m_stayProneTime=(m_fMin=3.000000,m_fMax=4.000000)
     m_stayCautiousGuardedStateTime=(m_fMin=7.000000,m_fMax=10.000000)
     m_patrolAreaWaitTween=(m_fMin=2.000000,m_fMax=4.000000)
     m_changeOrientationTween=(m_fMin=5.000000,m_fMax=15.000000)
     m_sightRadiusTween=(m_fMin=4000.000000,m_fMax=5000.000000)
     m_updatePaceTween=(m_fMin=1.500000,m_fMax=2.600000)
     m_waitingGoCrouchTween=(m_fMin=2.500000,m_fMax=4.000000)
     m_bAutoClimbLadders=True
     m_bAvoidFacingWalls=False
     m_fWalkingSpeed=250.000000
     m_fWalkingBackwardStrafeSpeed=100.000000
     m_fRunningSpeed=400.000000
     m_fRunningBackwardStrafeSpeed=320.000000
     m_fCrouchedWalkingSpeed=125.000000
     m_fCrouchedWalkingBackwardStrafeSpeed=100.000000
     m_fCrouchedRunningSpeed=250.000000
     m_fCrouchedRunningBackwardStrafeSpeed=250.000000
     m_standRunBackName="ScaredStandWalkBack"
     m_standWalkBackName="ScaredStandWalkBack"
     m_standFallName="ScaredStandFall"
     m_standLandName="ScaredStandLand"
     m_crouchFallName="crouchFall"
     m_crouchWalkForwardName="CrouchRunForward"
     m_standStairWalkUpName="StandStairWalkUp"
     m_standStairWalkUpBackName="StandStairWalkUp"
     m_standStairWalkDownName="StandStairWalkDown"
     m_standStairWalkDownBackName="StandStairWalkDown"
     m_standStairWalkDownRightName="StandWalkRight"
     m_standStairRunUpName="StandStairRunUp"
     m_standStairRunUpBackName="StandStairRunUp"
     m_standStairRunUpRightName="StandWalkRight"
     m_standStairRunDownName="StandStairRunDown"
     m_standStairRunDownBackName="StandStairRunDown"
     m_standStairRunDownRightName="StandWalkRight"
     m_crouchStairWalkDownName="CrouchStairWalkDown"
     m_crouchStairWalkDownBackName="CrouchStairWalkUp"
     m_crouchStairWalkDownRightName="CrouchWalkRight"
     m_crouchStairWalkUpName="CrouchStairWalkUp"
     m_crouchStairWalkUpBackName="CrouchStairWalkDown"
     m_crouchStairWalkUpRightName="CrouchWalkRight"
     m_crouchStairRunUpName="CrouchStairWalkUp"
     m_crouchStairRunDownName="CrouchStairWalkDown"
     m_crouchDefaultAnimName="Crouch_nt"
     m_standDefaultAnimName="Stand_nt"
     m_ePawnType=PAWN_Hostage
     m_bMakesTrailsWhenProning=True
     ControllerClass=Class'R6Engine.R6HostageAI'
     CollisionHeight=80.000000
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel17
         KConvulseSpacing=(Max=2.200000)
         KSkeleton="terroskel"
         KStartEnabled=True
         bHighDetailOnly=False
         KLinearDamping=0.500000
         KAngularDamping=0.500000
         KBuoyancy=1.000000
         KVelDropBelowThreshold=50.000000
         KFriction=0.600000
         KRestitution=0.300000
         KImpactThreshold=150.000000
         Name="KarmaParamsSkel17"
     End Object
     KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel17'
     RotationRate=(Yaw=45000)
}
