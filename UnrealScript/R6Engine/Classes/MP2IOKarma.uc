class MP2IOKarma extends R6InteractiveObject
    native
    placeable;

enum EReactionType
{
    RT_None,
    RT_Break,
    RT_Karma,
    RT_KarmaAndBreak
};

enum EZDRType
{
    ZDRT_None,
    ZDRT_Break
};

enum EZDRStat
{
    ZDRS_None,
    ZDRS_Contact
};

struct stZDRSound
{
    var() BYTE   m_eZDRGroupe;
    var() BYTE   m_eZDRSoundType;
    var() Sound  m_aZDRSound;
    var() Actor  m_aZDRActor;
    var() FLOAT  m_fZDRVolume;
};

struct stZDR
{
    var() BYTE                  m_eZDRType;
    var   BYTE                  m_eZDRStat;
    var() FLOAT                 m_fZDRRadius;
    var() vector                m_vZDRLocation;
    var() array<stZDRSound>     m_ZDRSoundList;
    var() INT                   m_iZDRDamageStat;
    var() FLOAT                 m_fZDRImpactInterval;
    var   FLOAT                 m_fZDRLastImpactTime;
};

struct stActorReactionState
{
    var() FLOAT fDamagePercentage;
    var() INT   iActorStat;
    var() Actor m_actor;
};

var() EReactionType m_eReactionType;
var EPhysics        SavePhysics;
var EReactionType   SaveReactionType;
var() BOOL  bCollideRagDoll;
var() BOOL  bUseSafeTimeWithLevel;
var() BOOL  bUseSafeTimeWithSM;
var() BOOL  bHideBefore;
var() BOOL  bHideAfter;
var() BOOL  bHideCollision;
var   BOOL  bSimulationActive;
var() BOOL  m_bOneTime;
var   BOOL  SavebCollideActors;
var   BOOL  SavebBlockActors;
var   BOOL  SavebBlockPlayers;
var() FLOAT m_fMaxSimAge;
var() FLOAT m_fLoseTime;
var   FLOAT m_fCurrentLoseTime;
var   FLOAT m_fCurrentSimAge;
var() FLOAT m_fZMin;
var() FLOAT m_fScaleStartLinVel;
var() FLOAT ImpactVolume;
var() FLOAT ImpactInterval;
var() array<stZDR>                  m_ZDRList;
var() array<Sound>                  ImpactSounds;
var() array<stActorReactionState>   m_ActorReactionList;
var vector  SaveLocation;
var rotator SaveRotation;
var transient FLOAT LastImpactTime;

native(4010) final function MP2IOKarmaAllNativeFct(INT WhatIdo, Actor _owner, optional FLOAT _var_int, optional FLOAT _var_float);

simulated function SaveOriginalData()
{
    Super.SaveOriginalData();
    SaveLocation = Location;
    SaveRotation = Rotation;
    SavePhysics = Physics;
    SaveReactionType = m_eReactionType;
    SavebCollideActors = bCollideActors;
    SavebBlockActors = bBlockActors;
    SavebBlockPlayers = bBlockPlayers;
}

simulated function ResetOriginalData()
{
    local INT i;

    Super.ResetOriginalData();
    SetLocation(SaveLocation);
    SetRotation(SaveRotation);
    m_eReactionType = SaveReactionType;
    SetCollision(SavebCollideActors, SavebBlockActors, SavebBlockPlayers);
    KSetBlockKarma(true);
    if(SavePhysics != Physics)
        SetPhysics(SavePhysics);

    if(bHideBefore)
        bHidden = true;
    else
        bHidden = false;

    KMP2IOKarmaAllNativeFct(0, none);
    m_fCurrentLoseTime = -1000.0;
    m_fCurrentSimAge = -1.0;
    bSimulationActive = false;
    Disable('Timer');
    Disable('Tick');
}

event ReinitSimulation(INT WhatIdo)
{
    ResetOriginalData();
}

event StopSimulation(INT WhatIdo)
{
    local BOOL bUseZmin;

    if(m_fZMin > -1000000.0)
        bUseZmin = true;
    else
        bUseZmin = false;

    if(m_bOneTime || WhatIdo == 2)
    {
        m_eReactionType = RT_None;
        SetPhysics(PHYS_None);
    }

    if(bSimulationActive)
        MP2IOKarmaAllNativeFct(0, none);

    if(bHideAfter && (WhatIdo == 1 && bUseZmin) || !bUseZmin)
    {
        SetCollision(false, false, false);
        KSetBlockKarma(false);
        m_eReactionType = RT_None;
        SetPhysics(PHYS_None);
        bHidden = true;
    }
    m_fCurrentSimAge = -1.0;
    bSimulationActive = false;
    KMP2IOKarmaAllNativeFct(1, none);
}

event StartSimulation(INT WhatIdo)
{
    if(!bSimulationActive)
    {
        MP2IOKarmaAllNativeFct(1, none, 1.0);
        SetPhysics(PHYS_Karma);
        KWake();
        if(bHideBefore)
            bHidden = false;
        bSimulationActive = true;
    }
    m_fCurrentSimAge = m_fMaxSimAge;
    if(m_bOneTime)
        m_eReactionType = RT_None;
}

event PreBeginPlay()
{
    local INT i;

    Super(Actor).PreBeginPlay();
    m_fCurrentSimAge = -1.0;
    m_fCurrentLoseTime = -1000.0;
    bSimulationActive = false;
    Disable('Timer');
    Disable('Tick');
}

simulated function Timer()
{
    Disable('Timer');
}

function Tick(FLOAT fDeltaTime)
{
    if(m_fCurrentLoseTime <= -100)
    {
        Disable('Tick');
    }
    else
    {
        m_fCurrentLoseTime = m_fCurrentLoseTime - fDeltaTime;
        if(m_fCurrentLoseTime < 0.0)
        {
            StartSimulation(0);
            Disable('Tick');
        }
    }
}

event KImpact(Actor Other, vector pos, vector impactVel, vector impactNorm)
{
    local INT numSounds;
    local INT soundNum;

    if(Level.TimeSeconds > LastImpactTime + ImpactInterval)
    {
        numSounds = ImpactSounds.Length;
        if(numSounds > 0)
            soundNum = Rand(numSounds);
    }

    if(Level.NetMode == NM_Standalone || Role == ROLE_Authority)
    {
    }
}

simulated event ZDRSetDamageState(INT iDamageStat, FLOAT fPercentage, vector ZDRLocation)
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

    if(iDamageStat >= m_StateList.Length && iDamageStat < 0)
    {
        log("there is no stat" $ iDamageStat $ "   " $ m_StateList.Length);
        return;
    }

    iStateToUse = -1;
    stState = m_StateList[iDamageStat];
    iStateToUse = iDamageStat;

    if (bShowLog) log("New State = " $ iState);

    if (iStateToUse == m_iCurrentState)
        return;

    if(iStateToUse==m_StateList.Length-1)
        SetBroken();

    if (iStateToUse != -1)
    {
        stState = m_StateList[iStateToUse];
        m_iCurrentState = iStateToUse;
    }

    fRandValue = FRand() * 100.0;
    if(stState.RandomMeshes.Length != 0)
    {
        for(iRandomMesh=0; iRandomMesh<stState.RandomMeshes.Length; iRandomMesh++)
        {
            fRandValue -= stState.RandomMeshes[iRandomMesh].fPercentage;
            if(fRandValue < 0)
            {
                ChangeStaticMesh(stState.RandomMeshes[iRandomMesh].Mesh);
                if(stState.RandomMeshes[iRandomMesh].Mesh == none)
                    StopSimulation(2);
                break;
            }
        }

        if(fRandValue > 0)
        {
            ChangeStaticMesh(stState.RandomMeshes[stState.RandomMeshes.Length-1].Mesh);
            if(stState.RandomMeshes[stState.RandomMeshes.Length-1].Mesh == none)
                StopSimulation(2);
        }
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
            {
                GetTagInformations( stState.ActorList[iActor].HelperName, vTagLocation, rTagRotator);
                SpawnedActor = Spawn(stState.ActorList[iActor].ActorToSpawn,,,Location + vTagLocation, Rotation + rTagRotator);
            }
            else
            {
                SpawnedActor = Spawn(stState.ActorList[iActor].ActorToSpawn,,,ZDRLocation, Rotation);
            }

            if(SpawnedActor != none)
                SpawnedActor.RemoteRole = ROLE_None;
        }
    }

    if(Role == ROLE_Authority)
    {
        PlayInteractiveObjectSound(stState);
    }
}

function INT R6TakeDamage(INT iKillValue, INT iStunValue, Pawn instigatedBy, vector vHitLocation, vector vMomentum, INT iBulletToArmorModifier, optional INT iBulletGroup)
{
    local eStunResult eStunFromTable;
    local INT iKillFromHit;
    local vector vBulletDirection;
    local INT iSndIndex;
    local BOOL bIsSilenced;
    local KarmaParams localkparams;
    local vector TearOffMomentum;
    local vector shotDir;
    local INT iActor;
    local stActorReactionState stState;
    local MP2IOKarma IOKarmaActor;

    m_iCurrentHitPoints = Max(m_iCurrentHitPoints - iKillValue, 0);
    log("currenyt" $ m_iCurrentHitPoints $ "  " $ iKillValue);
    if(m_iCurrentHitPoints > 0)
        return 0;

    TearOffMomentum = vMomentum;
    iStunValue = 1000;
    if(vMomentum == vect(0,0,0))
        return 1;

    vMomentum = Normal(vMomentum) * (iStunValue * 100);
    switch(m_eReactionType)
    {
        case RT_Karma:
        case RT_KarmaAndBreak:
            if(m_fScaleStartLinVel == 0.0)
                return 1;
            StartSimulation(0);
            vMomentum.X = m_fScaleStartLinVel * vMomentum.X;
            vMomentum.Y = m_fScaleStartLinVel * vMomentum.Y;
            vMomentum.Z = m_fScaleStartLinVel * vMomentum.Z;
            KAddImpulse(vMomentum, vHitLocation);
            if(m_eReactionType != RT_KarmaAndBreak)
                break;
        case RT_Break:
            Super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, TearOffMomentum, iBulletToArmorModifier, iBulletGroup);
            break;
    }

    for(iActor = 0; iActor < m_ActorReactionList.Length; iActor++)
    {
        stState = m_ActorReactionList[iActor];
        if(stState.m_actor != none)
        {
            if(stState.iActorStat == 0)
            {
                stState.m_actor.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, TearOffMomentum, iBulletToArmorModifier, iBulletGroup);
                continue;
            }

            IOKarmaActor = MP2IOKarma(stState.m_actor);
            if(IOKarmaActor != none && IOKarmaActor.m_eReactionType != RT_None)
            {
                if(IOKarmaActor.m_fLoseTime > 0.0)
                {
                    IOKarmaActor.m_fCurrentLoseTime = IOKarmaActor.m_fLoseTime;
                    IOKarmaActor.Enable('Tick');
                    continue;
                }
                IOKarmaActor.StartSimulation(0);
            }
        }
    }
}

defaultproperties
{
     bCollideRagDoll=True
     m_fMaxSimAge=10.000000
     m_fCurrentSimAge=-1.000000
     m_fZMin=-100000000.000000
     m_fScaleStartLinVel=1.000000
     m_bHandleRelativeProjectors=True
}
