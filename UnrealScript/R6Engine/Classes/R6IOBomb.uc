//=============================================================================
//  R6IOBomb : This should allow action moves on the door
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6IOBomb extends R6IOObject
    native
	placeable;

var(Debug)  bool		bShowLog;

var vector  m_vOffset;
var FLOAT   m_fTimeOfExplosion;
var FLOAT   m_fTimeLeft;    // if 0, the bomb has unlimited time
var FLOAT   m_fRepTimeLeft; // time replicated and computed on the client. send by server every X sec.
var FLOAT   m_fLastLevelTime;
var BOOL    m_bExploded;   

var(R6ActionObject) string m_szIdentityID;          // msg shown:                 Bomb A 
var                 string m_szIdentity;          // msg shown:                 Bomb A 
var(R6ActionObject) string m_szMsgArmedID;          // msg shown when armed:      Bomb A was armed
var(R6ActionObject) string m_szMsgDisarmedID;       // msg shown when disarmed:   Bomb A was disarmed
var(R6ActionObject) string m_szMissionObjLocalization;  // set the loc file. if none, use the default one
var(R6ActionObject) FLOAT m_fDisarmBombTimeMin;   // Base time required to disarmed the bomb if they have 100%, will be affected by the kit later (Must be higher then 2 seconds)
var(R6ActionObject) FLOAT m_fDisarmBombTimeMax;   // Base time required to disarmed the bomb if they have 0%
var(R6ActionObject) Material m_ArmedTexture;

var(R6ActionObject) float m_fExplosionRadius; // feel the sake
var(R6ActionObject) float m_fKillBlastRadius; // killed by the bomb
var(R6ActionObject) int   m_iEnergy;

var Sound m_sndActivationBomb;
var Sound m_sndPlayBeepNormal;
var Sound m_sndStopBeepNormal;
var Sound m_sndPlayBeepFast;
var Sound m_sndStopBeepFast;
var Sound m_sndPlayBeepFaster;
var Sound m_sndStopBeepFaster;

var Sound m_sndExplosion;
var Sound m_sndEarthQuake;


const C_fBombTimerInterval = 0.1;

enum ESoundBeepBomb
{
    SBB_Normal,
    SBB_Fast,
    SBB_Faster
};

var ESoundBeepBomb m_eBeepState;
var emitter m_pEmmiter;
var class<light>   m_pExplosionLight;

replication
{
    reliable if (Role<ROLE_Authority)
        ArmBomb, DisarmBomb;

    reliable if (Role==ROLE_Authority)
        m_bExploded, m_fRepTimeLeft;
}

simulated function PostBeginPlay()
{
        
    Super.PostBeginPlay();

    if(Role == ROLE_Authority)
    {
        AddSoundBankName("Foley_Bomb");
    }
    StartBombSound();
    
    m_szIdentity = Localize("Game", m_szIdentityID, GetMissionObjLocFile() );
}

simulated function string GetMissionObjLocFile()
{
    if ( m_szMissionObjLocalization != "" )
        return m_szMissionObjLocalization;
    else
        return Level.m_szMissionObjLocalization;
}


//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    // default settings
    if ( m_bExploded ) // if it has previously exploded
        bHidden      = false;

    m_bExploded      = false;
    
    m_fTimeLeft      = 0;
    m_fRepTimeLeft   = 0;
    m_fLastLevelTime = 0;

    StopSoundBomb();

    if ( Level.NetMode != NM_Client )
    {
        if ( m_bIsActivated ) // if activated start bomb
        {
            ArmBomb( none );
        }
        else
            SetSkin( none, 0 );
    }

    // so client can update the time left localy
    if ( Level.NetMode == NM_Client )
    {
        SetTimer( C_fBombTimerInterval, true);
    }
}


simulated function BOOL CanToggle()
{
    if ( m_bExploded )
        return false;

    return Super.CanToggle();
}

simulated function FLOAT GetTimeLeft()
{
    if ( Level.NetMode == NM_Client )
        return m_fRepTimeLeft;
    else
        return m_fTimeLeft;
}

simulated function Timer()
{
    local int iRemaining;
    Super.Timer();

    // on the client
    if ( Level.NetMode == NM_Client )
    {
        if ( m_bIsActivated )
        {
            m_fRepTimeLeft -= C_fBombTimerInterval;
           
            if ( m_fRepTimeLeft < 0 ) // cap
                m_fRepTimeLeft = 0;
        }
    }
    else  // on the server
    {
        // the bomb was activated and had time left (ie: not unlimited time)
        if ( m_bIsActivated && m_fTimeLeft > 0 )
        {
            m_fTimeLeft -= Level.TimeSeconds - m_fLastLevelTime;

            iRemaining = m_fTimeLeft;

            ChangeSoundBomb();
            if ( iRemaining % 5 == 0) // every 5 sec, update m_fRepTimeLeft
                m_fRepTimeLeft = m_fTimeLeft;
            
            if (m_fTimeLeft <= 0)
            {
                DetonateBomb();
            }
        
            m_fLastLevelTime = Level.TimeSeconds;
        }
    }
}

//------------------------------------------------------------------
// ForceTimeLeft
//	
//------------------------------------------------------------------
function ForceTimeLeft( float fTime )
{
    m_fTimeLeft      = fTime;
    m_fRepTimeLeft   = fTime;
    m_fLastLevelTime = Level.TimeSeconds;
}

function ChangeSoundBomb()
{
    switch(m_eBeepState)
    {
        case SBB_Normal:
            if (m_fTimeLeft <= 20)
            {
                AmbientSound = m_sndPlayBeepFast;
                AmbientSoundStop = m_sndStopBeepFast;
                PlaySound(m_sndPlayBeepFast, SLOT_Ambient);
                m_eBeepState = SBB_Fast;
            }
            break;
        
        case SBB_Fast:
            if (m_fTimeLeft <= 10)
            {
                AmbientSound = m_sndPlayBeepFaster;
                AmbientSoundStop = m_sndStopBeepFaster;
                PlaySound(m_sndPlayBeepFaster, SLOT_Ambient);
                m_eBeepState = SBB_Faster;
            }
            break;
    }
}

//------------------------------------------------------------------
// DetonateBomb
//	will explode only if the bomb was activated
//------------------------------------------------------------------
simulated function DetonateBomb( OPTIONAL R6Pawn p )
{
    local R6GrenadeDecal    GrenadeDecal;
    local rotator           GrenadeDecalRotation;
    local Light             pEffectLight;
    local vector            vDecalLoc;
    local float             fKillBlastHalfRadius;
    local float             fDistFromBomb;
    local Actor             aActor;
    local R6Pawn            pPawn;
    local R6PlayerController pPC;
    local R6ActorSound      pBombSound;
   
    if ( !m_bIsActivated )
        return;

    if (bShowLog) log(" DetonateBomb: " $self );

    StopSoundBomb();
    m_bExploded  = true;
    bHidden      = true;
    
    vDecalLoc = Location;
    vDecalLoc.Z -= CollisionHeight - 2; // lower the Z on the floor
    GrenadeDecal = Spawn(class'Engine.R6GrenadeDecal',,, vDecalLoc, GrenadeDecalRotation);

    m_pEmmiter = Spawn(class'R6SFX.R6BombFX');
    m_pEmmiter.RemoteRole = ROLE_AutonomousProxy; // replicate this actor on all client
    m_pEmmiter.Role = ROLE_Authority;
    
    pEffectLight = Spawn(m_pExplosionLight);

    R6AbstractGameInfo(Level.Game).IObjectDestroyed(p, self);    
    
    // Exception for the io bomb, we want it to exlode and kill players
    R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath = true;
    
    pBombSound = Spawn(class'Engine.R6ActorSound',,, Location);
    if (pBombSound != none)
    {
        pBombSound.m_eTypeSound = SLOT_HeadSet;
        pBombSound.m_ImpactSound = m_sndExplosion;
    }

    fKillBlastHalfRadius = m_fKillBlastRadius/2.f;
    foreach CollidingActors( class'Actor', aActor, m_fExplosionRadius, Location )
    {
        fDistFromBomb = VSize( aActor.Location - Location);

        // - all actor in half the radius are killed
        if ( fDistFromBomb <= fKillBlastHalfRadius ) 
        {
            HurtActor( aActor );
        }
        // - all visible actor are damaged by the bomb
        else if ( fDistFromBomb <= m_fKillBlastRadius ) 
        {
            if ( FastTrace( Location, aActor.location ) )
                HurtActor( aActor );
        }

        if (fDistFromBomb > 3000)
           fDistFromBomb = 3000;  
    
        // - all pawn alive in the explosion radius are affected by the shake effect
        pPawn = R6Pawn(aActor);
        if( pPawn != none && pPawn.IsAlive() )
        {
            pPC = R6PlayerController(pPawn.Controller);
            if( pPC != none )
            {
                pPC.R6Shake( 1.5f, 3000.f - fDistFromBomb, 0.1f );
                pPC.ClientPlaySound(m_sndEarthQuake, SLOT_SFX);
            }
        }
    }

    R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath = false;
}



//------------------------------------------------------------------
// HurtActor
//	
//------------------------------------------------------------------
function HurtActor( Actor aActor )
{
    local vector vExplosionMomentum;
    local R6Pawn aPawn;

    if ( R6InteractiveObject( aActor ) != none && aActor != self )
    {
        vExplosionMomentum = (aActor.Location - Location) * 0.25f;
        R6InteractiveObject(aActor).R6TakeDamage( m_iEnergy, m_iEnergy, none, aActor.Location , vExplosionMomentum, 0);
        return;
    }

    aPawn = R6Pawn(aActor);

    if ( aPawn == none )
        return;

    // Don't affect dead pawns...
    if( aPawn.m_eHealth >= HEALTH_Incapacitated )
        return;

    // Temporary momentum, quarter of distance from grenade...
    vExplosionMomentum = (aPawn.Location - Location) * 0.25f;
	aPawn.ServerForceKillResult(4);  //Force R6TakeDamage to kill the pawn
    aPawn.m_bSuicideType = DEATHMSG_KILLED_BY_BOMB;
	aPawn.R6TakeDamage( m_iEnergy, m_iEnergy, aPawn, aPawn.Location , vExplosionMomentum, 0);
	aPawn.ServerForceKillResult(0);  //Reset Kill to Normal
}

simulated event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    local BOOL      bDisplayBombIcon;
	local vector	vActorDir;
	local vector    vFacingDir;
    local R6Pawn    aPawn;

    if (CanToggle() == false || !m_bRainbowCanInteract )
        return;

    Query.iHasAction = 0;
    aPawn = R6Pawn(playerController.pawn);

    if ( m_bIsActivated )
    {
        if ( aPawn.m_bCanDisarmBomb )
        {
            Query.iHasAction = 1;
            Query.textureIcon = Texture'R6ActionIcons.Disarm';
            Query.iPlayerActionID      = eDeviceCircumstantialAction.DCA_DisarmBomb;
            Query.iTeamActionID        = eDeviceCircumstantialAction.DCA_DisarmBomb;
            Query.iTeamActionIDList[0] = eDeviceCircumstantialAction.DCA_DisarmBomb;
        }
    }   
    else
    {
        if ( aPawn.m_bCanArmBomb )
        {
            Query.iHasAction = 1;
            Query.textureIcon = Texture'R6ActionIcons.ArmingBomb';
            Query.iPlayerActionID      = eDeviceCircumstantialAction.DCA_ArmBomb;
            Query.iTeamActionID        = eDeviceCircumstantialAction.DCA_ArmBomb;
            Query.iTeamActionIDList[0] = eDeviceCircumstantialAction.DCA_ArmBomb;
        }
    }
    Query.iTeamActionIDList[1] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[2] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[3] = eDeviceCircumstantialAction.DCA_None;

    // check if player is within interaction range
    if( fDistance < m_fCircumstantialActionRange )
    {
    	vFacingDir = vector(rotation);
        vFacingDir.Z = 0;
		vActorDir = Normal(location - playerController.Pawn.Location);
        vActorDir.Z = 0;
		if((vActorDir dot vFacingDir) > 0.4)
            Query.iInRange = 1;
        else
            Query.iInRange = 0;

    }
    else
    {
        Query.iInRange = 0;
    }

    Query.bCanBeInterrupted = true;
    Query.fPlayerActionTimeRequired = GetTimeRequired(R6PlayerController(playerController).m_pawn);
   
}

simulated function string R6GetCircumstantialActionString( INT iAction )
{
    switch( iAction )
    {
        case eDeviceCircumstantialAction.DCA_DisarmBomb:    return Localize("RDVOrder", "Order_DisarmBomb", "R6Menu");
        case eDeviceCircumstantialAction.DCA_ArmBomb:       return Localize("RDVOrder", "Order_ArmBomb", "R6Menu");
    }
	
    return "";
}


simulated function ToggleDevice(R6Pawn aPawn)
{
    if (CanToggle() == false)
        return;

    Super.ToggleDevice( aPawn );

    if ( m_bIsActivated )
    {
        if ( aPawn.m_bCanDisarmBomb )
        {
            m_eAnimToPlay=BA_DisarmBomb;
            DisarmBomb(aPawn);
			if(aPawn.m_bIsPlayer)
				R6PlayerController(aPawn.Controller).PlaySoundActionCompleted(m_eAnimToPlay);
        }
    }
    else
    {
        if ( aPawn.m_bCanArmBomb )
        {
            m_eAnimToPlay=BA_ArmBomb;
            ArmBomb( aPawn );
            R6PlayerController(aPawn.Controller).PlaySoundActionCompleted(m_eAnimToPlay);
        }
    }
}


simulated function BOOL ArmBomb( R6Pawn aPawn )
{
    // already exploded
    if ( m_bExploded )
         return false;

    // if activated by a pawn
    if ( m_bIsActivated && aPawn != none )
        return false;

    PlaySound(m_sndActivationBomb, SLOT_SFX);
    
    if (bShowLog) log("Arm BOMB " @Self);
    // Change the mesh o
    // Play Sound of the bomb
    m_bIsActivated   = true;

    StartBombSound();
    m_fLastLevelTime = Level.TimeSeconds;
    SetTimer(C_fBombTimerInterval, true);
    m_fRepTimeLeft = m_fTimeOfExplosion;
    m_fTimeLeft = m_fTimeOfExplosion;

    SetSkin( m_ArmedTexture, 0 );
    
    R6AbstractGameInfo(Level.Game).IObjectInteract(aPawn, Self);    
    return true;
}


simulated function BOOL DisarmBomb(R6Pawn aPawn)
{
    if ( m_bIsActivated == false || m_bExploded)
    {
        return false;
    }

    if (bShowLog) log("Disarm BOMB"@Self@"by pawn"@aPawn@"and his controller"@aPawn.controller);
    
    StopSoundBomb();

    // Change StaticMesh or other
    m_bIsActivated = false;
    SetSkin( none, 0 );
    SetTimer(0, false);
    m_fRepTimeLeft = 0;

    R6AbstractGameInfo(Level.Game).IObjectInteract(aPawn, Self);
    return true;
}

function StartBombSound()
{
    if (m_bIsActivated)
    {
        switch(m_eBeepState)
        {
            case SBB_Normal:
                AmbientSound = m_sndPlayBeepNormal;
                AmbientSoundStop = m_sndStopBeepNormal;
                PlaySound(m_sndPlayBeepNormal, SLOT_Ambient);
                break;
            case SBB_Fast:
                AmbientSound = m_sndPlayBeepFast;
                AmbientSoundStop = m_sndStopBeepFast;
                PlaySound(m_sndPlayBeepFast, SLOT_Ambient);
                break;
            case SBB_Faster:
                AmbientSound = m_sndPlayBeepFaster;
                AmbientSoundStop = m_sndStopBeepFaster;
                PlaySound(m_sndPlayBeepFaster, SLOT_Ambient);
                break;
        }
    }
    else
    {
        AmbientSound = none;
    }
}

function StopSoundBomb()
{
    if (m_bIsActivated)
    {
        switch(m_eBeepState)
        {
            case SBB_Normal:
                PlaySound(m_sndStopBeepNormal, SLOT_Ambient);
                break;
            case SBB_Fast:
                PlaySound(m_sndStopBeepFast, SLOT_Ambient);
                break;
            case SBB_Faster:
                PlaySound(m_sndStopBeepFaster, SLOT_Ambient);
                break;
        }
    }

    m_eBeepState = SBB_Normal;
    AmbientSound = none;
    AmbientSoundStop = none;
}

simulated function BOOL HasKit(R6Pawn aPawn)
{
    return R6Rainbow(aPawn).m_bHasDiffuseKit;       
}

simulated function FLOAT GetMaxTimeRequired()
{
    return m_fDisarmBombTimeMax;
}

simulated function FLOAT GetTimeRequired(R6Pawn aPawn)
{
    local FLOAT fDisarmingBombTime;

//    if (bShowLog) log("GetTimeRequired"@ m_fDisarmBombTimeMin @ aPawn @ aPawn.GetSkill(SKILL_Electronics));
    fDisarmingBombTime = m_fDisarmBombTimeMin + ((1 - aPawn.GetSkill(SKILL_Electronics)) * (m_fDisarmBombTimeMax-m_fDisarmBombTimeMin));

    if ( HasKit(aPawn) && ( fDisarmingBombTime - m_fGainTimeWithElectronicsKit > 0))
        fDisarmingBombTime -= m_fGainTimeWithElectronicsKit;

    return fDisarmingBombTime;
}

defaultproperties
{
     m_iEnergy=3000
     m_fDisarmBombTimeMin=4.000000
     m_fDisarmBombTimeMax=12.000000
     m_fExplosionRadius=10000.000000
     m_fKillBlastRadius=2000.000000
     m_sndActivationBomb=Sound'Foley_Bomb.Play_BombActivationBeep'
     m_sndPlayBeepNormal=Sound'Foley_Bomb.Play_Seq_BombBeep'
     m_sndStopBeepNormal=Sound'Foley_Bomb.Stop_Seq_BombBeep'
     m_sndPlayBeepFast=Sound'Foley_Bomb.Stop_Seq_BombBeep_Go'
     m_sndStopBeepFast=Sound'Foley_Bomb.Stop_Seq_BombBeepFast'
     m_sndPlayBeepFaster=Sound'Foley_Bomb.Stop_Seq_BombBeepFast_Go'
     m_sndStopBeepFaster=Sound'Foley_Bomb.Stop_SeqBombBeepFinal'
     m_sndExplosion=Sound'Foley_Bomb.Bomb_Explosion'
     m_sndEarthQuake=Sound'Foley_Bomb.Play_EarthQuake'
     m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
     m_vOffset=(Y=-70.000000)
     m_szIdentityID="BombA"
     m_szMsgArmedID="BombAArmed"
     m_szMsgDisarmedID="BombADisarmed"
     m_eAnimToPlay=BA_DisarmBomb
     m_StartSnd=Sound'Foley_Bomb.Play_Bomb_Defusing'
     m_InterruptedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defusing'
     m_CompletedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defused'
     m_bRainbowCanInteract=True
     m_fSoundRadiusActivation=5600.000000
     m_fCircumstantialActionRange=110.000000
}
