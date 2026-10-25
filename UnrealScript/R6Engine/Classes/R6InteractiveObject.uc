//=============================================================================
//  R6InteractiveObject.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObject extends Actor
    native
    placeable;

//===========================================================================================================
//	 ####              #                                       #      ##                            
//	  ##              ##                                      ##                                    
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===========================================================================================================
var(R6Action)           FLOAT               m_fRadius;
var(R6Action)           FLOAT               m_fProbability;
var(R6Action)           FLOAT               m_fActionInterval;
var                     FLOAT               m_fTimeSinceAction;
var                     FLOAT               m_fTimeForNextSound;
var                     FLOAT               m_fTimerInterval;
var                     R6AIController      m_InteractionOwner;

var(R6Action)           Actor               m_RemoveCollisionFromActor;
var(R6Action)           NavigationPoint     m_Anchor;
var                     BOOL                m_bCollisionRemovedFromActor;

var                       BOOL              m_bOriginalCollideActors;
var                       BOOL              m_bOriginalBlockActors;
var                       BOOL              m_bOriginalBlockPlayers;
var                       BOOL              m_bPawnDied;
var (Debug)               BOOL              bShowLog;

var                       BOOL              m_bBroken;
var (R6ActionObject)      BOOL              m_bRainbowCanInteract; // true when AI and player can interact with the object

// ending actions
var(R6Action)           Name                m_vEndActionAnimName;
var(R6Action)           Actor               m_vEndActionGoto;

var                     INT                 m_iActionNumber;
var                     INT                 m_iActionIndex;
var(R6Action) editinline array<R6InteractiveObjectAction>   m_ActionList;
var                     R6InteractiveObjectAction           m_CurrentInteractiveObject;

var                     FLOAT               m_fPlayerCAStartTime;

// SeePlayer buffering
var                     Pawn                m_SeePlayerPawn;
// HearNoise buffering
var                     float               m_HearNoiseLoudness;
var                     Actor               m_HearNoiseNoiseMaker;
var                     ENoiseType          m_HearNoiseType;
var                     BOOL                m_bEndAction;

// save/reset
const                   c_iIObjectSkinMax = 4;
var                     Material            m_aOldSkins[c_iIObjectSkinMax];    // compared with the rep one
var                     Material            m_aRepSkins[c_iIObjectSkinMax];    // replicated skin
var                     array<Material>     sm_aSkins;      // save original skin
var                     StaticMesh          sm_staticMesh;

var(Display)            BOOL                m_bBlockCoronas;

// Replication specific
var                     FLOAT               m_fNetDamagePercentage;


//===========================================================================================================
//	#####                                           
//	 ## ##                                          
//	 ##  ##  ####   ##  ##   ####    ### ##  ####   
//	 ##  ##     ##  #######     ##  ##  ##  ##  ##  
//	 ##  ##  #####  #######  #####  ##  ##  ######  
//	 ## ##  ##  ##  ## # ## ##  ##   #####  ##      
//	#####    ### ## ##   ##  ### ##     ##   ####   
//	                                #####           
//===========================================================================================================
enum EInteractiveAction
{
    IA_PlayAnim,
    IA_LookAt
};

struct stRandomMesh
{
    var () FLOAT fPercentage;
    var () StaticMesh Mesh;
};

struct stRandomSkin
{
    var () FLOAT fPercentage;
    var () array<Material> Skin;
};

struct stSpawnedActor
{
    var () class<Actor> ActorToSpawn;
    var () string HelperName;
};

struct stDamageState
{
    var () FLOAT fDamagePercentage;
    var () array<stRandomMesh> RandomMeshes;
    var () array<stRandomSkin> RandomSkins;
    var () array<stSpawnedActor> ActorList;
    var () array<Sound> SoundList;
    var () Sound NewAmbientSound;
    var () Sound NewAmbientSoundStop;
};

var (R6Damage)  BOOL    m_bBreakableByFlashBang;
var (R6Damage)  FLOAT   m_fAIBreakNoiseRadius;
var (R6Damage)  INT     m_iHitPoints;               // Original Hit Points
var             INT     m_iCurrentHitPoints;        // Current Hit Points
var (R6Damage) array<stDamageState> m_StateList;
var             INT     m_iCurrentState;
var             R6Pawn  m_User;


var             Sound   sm_AmbientSound;
var             Sound   sm_AmbientSoundStop;

var(R6Attachments)      array<Actor>        m_AttachedActors;


replication
{
    unreliable if (Role == ROLE_Authority)
        m_aRepSkins, m_fNetDamagePercentage;
} 

//============================================================================
// function FirstPassReset - 
//============================================================================
simulated function FirstPassReset()
{
    m_User = none;
    m_InteractionOwner = none;
    m_SeePlayerPawn = none;
    m_HearNoiseNoiseMaker = none;
    m_bEndAction = false;
}

//------------------------------------------------------------------
// SaveOriginalData
//	
//------------------------------------------------------------------
simulated function SaveOriginalData()
{
    local int iSkin;

    if ( m_bResetSystemLog ) LogResetSystem( true );
    Super.SaveOriginalData();

    sm_staticMesh       = StaticMesh;

    if ( c_iIObjectSkinMax < Skins.Length  )
        log("WARNING c_iIObjectSkinMax < Skins.Length");

    for (iSkin = 0; iSkin < Skins.Length; iSkin++)
    {
        if ( iSkin > c_iIObjectSkinMax )
            break; 

        sm_aSkins[iSkin]   = Skins[iSkin];
        m_aOldSkins[iSkin] = Skins[iSkin];
        m_aRepSkins[iSkin] = Skins[iSkin];
    }

    sm_AmbientSound = AmbientSound;
    sm_AmbientSoundStop = AmbientSoundStop;

    m_fNetDamagePercentage = 100.0f;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    local INT i;

    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    AmbientSound = sm_AmbientSound;
    AmbientSoundStop = sm_AmbientSoundStop;
    
    if(m_fProbability!=0.0 && (Level.NetMode == NM_Standalone) || (Role == ROLE_Authority))
    {
        // interactions
        SetTimer(m_fTimerInterval, true);
        
        // damage
        m_iCurrentHitPoints = m_iHitPoints;
    }
   
    m_fNetDamagePercentage = 100.0f;
    m_iCurrentState = -1;
    m_fTimeSinceAction = 0.0;
    m_fTimeForNextSound = 9999999.0;
    m_InteractionOwner = none;
    m_bBroken = false;

    // if was interacting, reset his collision setting
    if(m_bCollisionRemovedFromActor)
    {
        //log("====="$m_RemoveCollisionFromActor$" gained back collisions (2) "$m_bOriginalCollideActors@m_bOriginalBlockActors@m_bOriginalBlockPlayers);
        m_RemoveCollisionFromActor.SetCollision(m_bOriginalCollideActors, m_bOriginalBlockActors, m_bOriginalBlockPlayers);
        m_bCollisionRemovedFromActor = false;
    }

    Skins.Remove( 0, Skins.Length ); // reset the skin
    for (i = 0; i < sm_aSkins.Length; i++)
    {
        Skins[i]       = sm_aSkins[i];
        m_aOldSkins[i] = Skins[i];
        m_aRepSkins[i] = Skins[i];
    }

    if ( StaticMesh != sm_staticMesh )
        ChangeStaticMesh( sm_staticMesh );
    
}

function PostBeginPlay()
{
    local int i;
    Super.PostBeginPlay();
    
    m_OutlineStaticMesh = StaticMesh;
    
    // attachments
    for(i=0; i<m_AttachedActors.Length; i++)
    {
        if(m_AttachedActors[i] != none)
        {
            m_AttachedActors[i].SetBase(self);
            m_AttachedActors[i].m_AttachedTo = self;
        }
    }
}

//------------------------------------------------------------------
// SetSkin: set the skin for local player and for replication
//	
//------------------------------------------------------------------
simulated function SetSkin( Material aSkin, INT iIndex )
{
    if ( iIndex > c_iIObjectSkinMax )
        return;

    Skins[iIndex]       = aSkin;
    m_aRepSkins[iIndex] = aSkin;

    // log( "SetSkin: " $self.name$" index=" $iIndex$ " aSkin=" $aSkin );
}

//------------------------------------------------------------------
// ChangeStaticMesh: set the StaticMesh
//	
//------------------------------------------------------------------
simulated function ChangeStaticMesh(StaticMesh SM)
{
    // change collision settings if necessary
    if(SM == none && StaticMesh != none)
        SetCollision(false, false, false);
    else if(SM != none && StaticMesh == none)
        SetCollision(default.bCollideActors, default.bBlockActors, default.bBlockPlayers);

    // set new StaticMesh
    SetStaticMesh(SM);
}

//===========================================================================================================
//	 ####              #                                       #      ##                            
//	  ##              ##                                      ##                                    
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===========================================================================================================
function FinishAction();

simulated function Timer()
{
    local R6Pawn P;

    m_fTimeSinceAction += m_fTimerInterval;

    if((Level.NetMode != NM_Standalone) && (Role != ROLE_Authority))
    {// just to be sure, but should not happen.
        return;
    }

    if(m_InteractionOwner != none)
    {// object is already interacted with.
        if(m_CurrentInteractiveObject != none && m_CurrentInteractiveObject.IsA('R6InteractiveObjectActionLoopAnim') ||
           m_CurrentInteractiveObject.IsA('R6InteractiveObjectActionLoopRandomAnim'))
        {
            if((m_CurrentInteractiveObject.m_eSoundToPlay != none) && (m_CurrentInteractiveObject.m_eSoundToPlayStop != none))
            {
                if(m_fTimeSinceAction > m_fTimeForNextSound)
                {
                    if(R6Pawn(m_InteractionOwner.Pawn) != none)
                        R6Pawn(m_InteractionOwner.Pawn).PlayVoices(m_CurrentInteractiveObject.m_eSoundToPlay, SLOT_Talk, 15);
                    m_fTimeForNextSound += RandRange(m_CurrentInteractiveObject.m_SoundRange.Min, m_CurrentInteractiveObject.m_SoundRange.Max);
                }
            }
        }

        return;
    }
    
    if((FRand() < m_fProbability) && (m_fTimeSinceAction >= m_fActionInterval))
    {
        foreach VisibleCollidingActors(class'R6Pawn', P, m_fRadius, Location)
        {
            if( R6AIController(P.Controller) != none &&
                R6AIController(P.Controller).CanInteractWithObjects(self))
            {
                m_fTimeSinceAction = 0.0;
                PerformAction(P);
                break;
            }
        }
    }
}

//------------------------------------------------------------------
// SetBroken
//  object is broken, so stop the timer.
//------------------------------------------------------------------
simulated function SetBroken()
{
    m_bBroken = true;
    StopInteraction();
    SetTimer(0.0, false);
}

function StopInteraction()
{
    if(Level.m_bIsResettingLevel)
        return;

    if(m_InteractionOwner != none)
    {
        m_InteractionOwner.PerformAction_StopInteraction();
        m_InteractionOwner.m_bCantInterruptIO = false;
        m_InteractionOwner.m_InteractionObject = none;
        m_InteractionOwner = none;
        m_bEndAction = false;

        if(m_bCollisionRemovedFromActor)
        {
            //log("====="$m_RemoveCollisionFromActor$" gained back collisions (1) "$m_bOriginalCollideActors@m_bOriginalBlockActors@m_bOriginalBlockPlayers);
            m_RemoveCollisionFromActor.SetCollision(m_bOriginalCollideActors, m_bOriginalBlockActors, m_bOriginalBlockPlayers);
            m_bCollisionRemovedFromActor = false;
        }
    }
}

function StopInteractionWithEndingActions()
{
    if(Level.m_bIsResettingLevel)
        return;

    // Prevent EndingActions to be called 2 times in a row
    if(!m_bEndAction)
    {
        m_bEndAction = true;
        m_iActionIndex = m_iActionNumber;
        FinishAction();
    }
}

function PerformAction(R6Pawn P)
{
    m_InteractionOwner = R6AIController(P.Controller);
    m_InteractionOwner.m_InteractionObject = self;

    m_iActionIndex = -1;
    m_iActionNumber = m_ActionList.Length;

    if(m_RemoveCollisionFromActor != none)
    {
        m_bOriginalCollideActors = m_RemoveCollisionFromActor.bCollideActors;
        m_bOriginalBlockActors = m_RemoveCollisionFromActor.bBlockActors;
        m_bOriginalBlockPlayers = m_RemoveCollisionFromActor.bBlockPlayers;
        //log("====="$m_RemoveCollisionFromActor$" lost collisions");
        m_RemoveCollisionFromActor.SetCollision(false, false, false);
        m_bCollisionRemovedFromActor = true;
    }

    GotoState('PA_ExecuteStartInteraction');
}

function SwitchToNextAction()
{
    m_iActionIndex++;

    if(m_iActionIndex >= m_iActionNumber)
    {
        GotoState('PA_ExecutePlayEnding');
        return;
    }

    m_CurrentInteractiveObject = m_ActionList[m_iActionIndex];

    if((m_CurrentInteractiveObject.m_eSoundToPlay != none) && (m_CurrentInteractiveObject.m_eSoundToPlayStop != none))
    {
        R6Pawn(m_InteractionOwner.Pawn).PlayVoices(m_CurrentInteractiveObject.m_eSoundToPlay, SLOT_Talk, 15);

        if(m_iActionIndex == 0)
            m_fTimeForNextSound = RandRange(m_CurrentInteractiveObject.m_SoundRange.Min, m_CurrentInteractiveObject.m_SoundRange.Max);
    }

    switch(m_CurrentInteractiveObject.m_eType)
    {
    case ET_LookAt:
        GotoState('PA_ExecuteLookAt');
        break;
    case ET_Goto:
        GotoState('PA_ExecuteGoto');
        break;
    case ET_PlayAnim:
        GotoState('PA_ExecutePlayAnim');
        break;
    case ET_LoopAnim:
        GotoState('PA_ExecuteLoopAnim');
        break;
    case ET_LoopRandomAnim:
        GotoState('PA_ExecuteLoopRandomAnim');
        break;
    case ET_ToggleDevice:
        GotoState('PA_ExecuteToggleDevice');
        break;
    }
}

state PA_Execute
{
    function FinishAction()
    {
        SwitchToNextAction();
    }
}

state PA_ExecuteStartInteraction extends PA_Execute
{
Begin:
    m_InteractionOwner.PerformAction_StartInteraction();
}

state PA_ExecuteLookAt extends PA_Execute
{
Begin:
    m_InteractionOwner.PerformAction_LookAt(R6InteractiveObjectActionLookAt(m_CurrentInteractiveObject).m_Target);
}

state PA_ExecuteGoto extends PA_Execute
{
Begin:
    m_InteractionOwner.PerformAction_Goto(R6InteractiveObjectActionGoto(m_CurrentInteractiveObject).m_Target);
}

state PA_ExecuteToggleDevice extends PA_Execute
{
    function ActionDetonateAllBombs()
    {
        local int i;
        local R6InteractiveObjectActionToggleDevice ioAction;
        
        ioAction = R6InteractiveObjectActionToggleDevice( m_CurrentInteractiveObject );

        while ( i < ioAction.m_aIOBombs.length )
        {
            ioAction.m_aIOBombs[i].DetonateBomb( R6Pawn(m_InteractionOwner.pawn) );
            ++i;
        }
    }

    function ActionToggleDevice()
    {
        local R6InteractiveObjectActionToggleDevice ioAction;

        ioAction = R6InteractiveObjectActionToggleDevice( m_CurrentInteractiveObject );

        if ( ioAction.m_iodevice != none )
            ioAction.m_iodevice.toggleDevice( R6Pawn(m_InteractionOwner.pawn) );
    }

Begin:
    ActionToggleDevice();
    ActionDetonateAllBombs();
    
    FinishAction();
}

state PA_ExecutePlayAnim extends PA_Execute
{
Begin:
    m_InteractionOwner.PerformAction_PlayAnim(R6InteractiveObjectActionPlayAnim(m_CurrentInteractiveObject).m_vAnimName);
}

state PA_ExecuteLoopAnim extends PA_Execute
{
Begin:
    m_InteractionOwner.PerformAction_LoopAnim(
        R6InteractiveObjectActionLoopAnim(m_CurrentInteractiveObject).m_vAnimName,
        RandRange(
            R6InteractiveObjectActionLoopAnim(m_CurrentInteractiveObject).m_LoopTime.Min,
            R6InteractiveObjectActionLoopAnim(m_CurrentInteractiveObject).m_LoopTime.Max
        )
    );
}

state PA_ExecuteLoopRandomAnim extends PA_Execute
{
    function FinishAction()
    {
        if(m_iActionIndex>=m_iActionNumber)
            SwitchToNextAction();
        else
            GotoState('PA_ExecuteLoopRandomAnim');
    }

Begin:
    m_InteractionOwner.PerformAction_PlayAnim( R6InteractiveObjectActionLoopRandomAnim(m_CurrentInteractiveObject).GetNextAnim() );
}

state PA_ExecutePlayEnding extends PA_Execute
{
    function FinishAction()
    {
        GotoState('PA_ExecuteGotoEnding');
    }

Begin:
    if(m_vEndActionAnimName != '')
    {
        m_InteractionOwner.PerformAction_PlayAnim(m_vEndActionAnimName);
    }
    else
    {
        FinishAction();
    }
}

state PA_ExecuteGotoEnding extends PA_Execute
{
    function FinishAction()
    {
        StopInteraction();
    }
    
Begin:
    if(m_vEndActionGoto != none)
    {
        m_InteractionOwner.R6SetMovement(PACE_Run);
        m_InteractionOwner.PerformAction_Goto(m_vEndActionGoto);
    }
    else
        FinishAction();
}


//===========================================================================================================
//	#####                                           
//	 ## ##                                          
//	 ##  ##  ####   ##  ##   ####    ### ##  ####   
//	 ##  ##     ##  #######     ##  ##  ##  ##  ##  
//	 ##  ##  #####  #######  #####  ##  ##  ######  
//	 ## ##  ##  ##  ## # ## ##  ##   #####  ##      
//	#####    ### ## ##   ##  ### ##     ##   ####   
//	                                #####           
//===========================================================================================================
function INT R6TakeDamage(INT iKillValue, INT iStunValue, Pawn instigatedBy, vector vHitLocation, 
                           vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGroup)
{
    local FLOAT fPercentage;
    
    if (m_bBroken)
        return 0;

    if((Level.NetMode == NM_Standalone) || (Role == ROLE_Authority))
    {
        if (bShowLog) log("m_iCurrentHitPoints = "$m_iCurrentHitPoints$" Damage: " $ iKillValue);
        m_iCurrentHitPoints = max(m_iCurrentHitPoints - iKillValue, 0);
        
        // Compute the percentage
        fPercentage = m_iCurrentHitPoints * 100 / m_iHitPoints;  
        
        if (bShowLog) log("New Hit Point = " $ m_iCurrentHitPoints $" Percentage: " $ fPercentage);
        SetNewDamageState(fPercentage);

        if( m_bBroken )
        {
            // Notify the game that the interactive object was destroyed
            R6AbstractGameInfo(Level.Game).IObjectDestroyed(instigatedBy, Self);

            // Make noise for AI
            Instigator = instigatedBy;
            R6MakeNoise2( m_fAIBreakNoiseRadius, NOISE_Threat, PAWN_All );
        }
    }
    
    if(m_bBulletGoThrough == true)
        return iKillValue;
    else
        return 0;
}

simulated event SetNewDamageState(FLOAT fPercentage)
{
    local INT iState;
    local INT iRandomMesh;
    local INT iRandomSkin;
    local INT iStateToUse;
    local FLOAT fRandValue;
    local INT iActor;
    local INT iSkin;
    local stDamageState stState;
    local vector vTagLocation;
    local rotator rTagRotator;
    local Actor SpawnedActor;

    // notify clients
    if(Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer)
        m_fNetDamagePercentage = fPercentage;

    iStateToUse = -1;
    for(iState = 0; iState < m_StateList.Length; iState++)
    {
        stState = m_StateList[iState];
        
        if((fPercentage <= stState.fDamagePercentage) && (stState.fDamagePercentage <= m_StateList[iState].fDamagePercentage))
        {
            iStateToUse = iState;
        }
    } 
    
    if (bShowLog) log("New State = " $ iState);
    
    if (iStateToUse == m_iCurrentState)
        return;

    // If it the last state, the object is broken
    if(iStateToUse==m_StateList.Length-1)
        SetBroken();
    
    if (iStateToUse != -1)
    {
        stState = m_StateList[iStateToUse];
        m_iCurrentState = iStateToUse;
    }
    
    // Pick a Random Number

    // Set the new Static Mesh
    fRandValue = FRand() * 100.0;
    if(stState.RandomMeshes.Length != 0)
    {
        for(iRandomMesh=0; iRandomMesh<stState.RandomMeshes.Length; iRandomMesh++)
        {
            fRandValue -= stState.RandomMeshes[iRandomMesh].fPercentage;
            if(fRandValue < 0)
            {
                ChangeStaticMesh(stState.RandomMeshes[iRandomMesh].Mesh);
                break;
            }
        }

        if(fRandValue > 0)
            ChangeStaticMesh(stState.RandomMeshes[stState.RandomMeshes.Length-1].Mesh);
    }

    if(stState.RandomSkins.Length != 0)
    {
        for(iRandomSkin=0; iRandomSkin<stState.RandomSkins.Length; iRandomSkin++)
        {
            fRandValue -= stState.RandomSkins[iRandomSkin].fPercentage;
            if(fRandValue < 0)
            {
                for(iSkin=0; iSkin<stState.RandomSkins[iRandomSkin].Skin.Length; iSkin++)
                    SetSkin(stState.RandomSkins[iRandomSkin].Skin[iSkin], iSkin);
                break;
            }
        }

        if(fRandValue > 0)
            for(iSkin=0; iSkin<stState.RandomSkins[stState.RandomSkins.Length-1].Skin.Length; iSkin++)
                SetSkin(stState.RandomSkins[stState.RandomSkins.Length-1].Skin[iSkin], iSkin);
    }

    if(Level.NetMode != NM_DedicatedServer)
    {
        // Spawn the actors
        for(iActor = 0; iActor < stState.ActorList.Length; iActor++)
        {
            if(stState.ActorList[iActor].ActorToSpawn == none)
                continue;

            if(stState.ActorList[iActor].HelperName != "")
                GetTagInformations( stState.ActorList[iActor].HelperName, vTagLocation, rTagRotator);

            SpawnedActor = Spawn(stState.ActorList[iActor].ActorToSpawn,,,Location + vTagLocation, Rotation + rTagRotator);

            if(SpawnedActor != none)
                SpawnedActor.RemoteRole = ROLE_None;
        }
    }

    if(Role == ROLE_Authority)
    {
        PlayInteractiveObjectSound(stState);
    }
}

function PlayInteractiveObjectSound(stDamageState stState)
{
    local INT iSound;

    for(iSound = 0; iSound < stState.SoundList.Length; iSound++)
    {
        PlaySound(stState.SoundList[iSound], SLOT_SFX);
    }
}

defaultproperties
{
     m_fRadius=128.000000
     m_fActionInterval=10.000000
     m_fTimerInterval=1.000000
     m_fAIBreakNoiseRadius=500.000000
     bNoDelete=True
     m_bUseR6Availability=True
     bAcceptsProjectors=True
     bAlwaysRelevant=True
     bSkipActorPropertyReplication=True
     bShadowCast=True
     bStaticLighting=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bPathColliding=True
     m_bForceStaticLighting=True
}
