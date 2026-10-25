//=============================================================================
//  R6NoiseMgr.uc : Store value for sound loudness of MakeNoise
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Created by Guillaume Borgia
//=============================================================================
class R6NoiseMgr extends R6AbstractNoiseMgr
	config(sound);

struct STSound
{
    var FLOAT               fSndDist;
    var Actor.ENoiseType    eType;
};

struct STPawnMovement
{
    var FLOAT               fStandSlow;
    var FLOAT               fStandFast;
    var FLOAT               fCrouchSlow;
    var FLOAT               fCrouchFast;
    var FLOAT               fProne;
    var Actor.ENoiseType    eType;
};

var config STSound m_SndBulletImpact;
var config STSound m_SndBulletRicochet;
var config STSound m_SndGrenadeImpact;
var config STSound m_SndGrenadeLike;
var config STSound m_SndExplosion;
var config STSound m_SndChoking;
var config STSound m_SndTalking;
var config STSound m_SndScreaming;
var config STSound m_SndReload;
var config STSound m_SndEquipping;
var config STSound m_SndDead;
var config STSound m_SndDoor;

var config STPawnMovement m_Rainbow;
var config STPawnMovement m_Terro;
var config STPawnMovement m_Hostage;

// debug
var	bool bShowLog;

//============================================================================
// Init - 
//============================================================================
function Init()
{
    SaveConfig();
}

//============================================================================
// MakeANoise - ESoundType
//============================================================================
function MakeANoise( Actor source, FLOAT fDist, Actor.ENoiseType eNoiseType, Actor.EPawnType ePawnType, Actor.ESoundType eSoundType )
{
#ifdefDEBUG
    if(bShowLog) log( source.name $ " MakeNoise pos: " $ 
            INT(source.Location.X) $ "," $ INT(source.Location.Y) $ "," $ INT(source.Location.Z) $ "," $
            " distance: " $ fDist $ " Noise: " $ eNoiseType $
            " Pawn: " $ ePawnType $ " Sound: " $ eSoundType $ " Time: " $ source.Level.TimeSeconds );
#endif // #ifdefDEBUG
    if(fDist>0.0f)
        source.MakeNoise( fDist, eNoiseType, ePawnType, eSoundType );
#ifdefDEBUG
    else
    {
        log(" WARNING!!! Actor " $ source $ " made a sound of radius " $ fDist $ "(" $ eNoiseType @ EPawnType @ ESoundType $ ")" );
    }
#endif // #ifdefDEBUG
}

//============================================================================
// R6MakeNoise - 
//============================================================================
event R6MakeNoise( Actor.ESoundType eSoundType, Actor source )
{
    local FLOAT             fDist;
    local R6AbstractPawn    aR6Pawn;
    local Actor.ENoiseType  eNoiseType;
    local Actor.EPawnType   ePawnType;
    local R6Weapons         srcWeapon;

    // The instigator must be a R6AbstractPawn
    aR6Pawn = R6AbstractPawn(source.Instigator);
    if(aR6Pawn != none )
    {
        ePawnType = aR6Pawn.m_ePawnType;

        switch(eSoundType)
        {
            // Check the gun for silenced or not
            case SNDTYPE_Gunshot:
                srcWeapon = R6Weapons(source);
                if(srcWeapon==None)
                    return;

                // Don't do another gunshot sound if the last was too close
                if( aR6Pawn.m_NextFireSound>aR6Pawn.Level.TimeSeconds )
                    return;

                aR6Pawn.m_NextFireSound = aR6Pawn.Level.TimeSeconds + 0.33f;
                fDist = srcWeapon.m_fFireSoundRadius*1.5;
                eNoiseType = NOISE_Investigate;
                break;
            // Impact, ricochet
            case SNDTYPE_BulletImpact:
                // Don't do another impact sound if the last was too close
                if( aR6Pawn.m_NextBulletImpact>aR6Pawn.Level.TimeSeconds )
                    return;
                
                aR6Pawn.m_NextBulletImpact = aR6Pawn.Level.TimeSeconds + 0.33f;
                fDist = m_SndBulletImpact.fSndDist;
                eNoiseType = m_SndBulletImpact.eType;
                break;
            // Grenade bouncing
            case SNDTYPE_GrenadeImpact:
                fDist = m_SndGrenadeImpact.fSndDist;
                eNoiseType = m_SndGrenadeImpact.eType;
				ePawnType = PAWN_All;			// rbrek 30 april 2002 - all pawn types should hear grenade impact
                break;
            // Grenade-like weapon bouncing (FalseHB, HeartBeatJammer,...)
            case SNDTYPE_GrenadeLike:
                fDist = m_SndGrenadeLike.fSndDist;
                eNoiseType = m_SndGrenadeLike.eType;
                break;
            // Various explosion (grenade, breach door)
            case SNDTYPE_Explosion:
                fDist = m_SndExplosion.fSndDist;
                eNoiseType = m_SndExplosion.eType;
                break;
            // Choking from gas
            case SNDTYPE_Choking:
                fDist = m_SndChoking.fSndDist;
                eNoiseType = m_SndChoking.eType;
                break;
            // Talking
            case SNDTYPE_Talking:
                fDist = m_SndTalking.fSndDist;
                eNoiseType = m_SndTalking.eType;
                break;
            // Talking louder :)
            case SNDTYPE_Screaming:
                fDist = m_SndScreaming.fSndDist;
                eNoiseType = m_SndScreaming.eType;
                break;
            // Reloading weapon
            case SNDTYPE_Reload:
                fDist = m_SndReload.fSndDist;
                eNoiseType = m_SndReload.eType;
                break;
            // Reloading weapon
            case SNDTYPE_Equipping:
                fDist = m_SndEquipping.fSndDist;
                eNoiseType = m_SndEquipping.eType;
                break;
            // When a pawn died
            case SNDTYPE_Dead:
                fDist = m_SndDead.fSndDist;
                eNoiseType = m_SndDead.eType;
				ePawnType = PAWN_All;			// rbrek 30 april 2002 - all pawn types should hear this noise
                break;
            // Opening and closing door
            case SNDTYPE_Door:
                fDist = m_SndDoor.fSndDist;
                eNoiseType = m_SndDoor.eType;
                break;
        }

        MakeANoise( source, fDist, eNoiseType, ePawnType, eSoundType );
    }
}

//============================================================================
// R6MakePawnMovementNoise - 
//============================================================================
event R6MakePawnMovementNoise( R6AbstractPawn pawn )
{
    local FLOAT             fDist;
    local Actor.EPawnType   ePawnType;
    local R6Pawn            aR6Pawn;
    local BOOL              bIsRunning;
    local STPawnMovement    pawnMove;
    local FLOAT             fStealth;

    aR6Pawn = R6Pawn(pawn);

    ePawnType = aR6Pawn.m_ePawnType;
    // Choose the right struct from pawn type
    if ( ePawnType == PAWN_Terrorist)
    {
        pawnMove = m_Terro;
    }
    else if ( ePawnType == PAWN_Rainbow )
    {
        pawnMove = m_Rainbow;
    }
    else
    {
        pawnMove = m_Hostage;
    }

    bIsRunning = aR6Pawn.IsRunning();

    // Choose the distance from stance and speed
    if(aR6Pawn.m_bIsProne)
    {
        fDist = pawnMove.fProne;
    }
    else if(aR6Pawn.bIsCrouched)
    {
        if(bIsRunning)
        {
            fDist = pawnMove.fCrouchFast;
        }
        else
        {
            fDist = pawnMove.fCrouchSlow;
        }
    }
    else // standing
    {
        if(bIsRunning)
        {
            fDist = pawnMove.fStandFast;
        }
        else
        {
            fDist = pawnMove.fStandSlow;
        }
    }

    // Adjust from pawn stealth
    fStealth = pawn.GetSkill( SKILL_Stealth );
    fStealth = Clamp( fStealth, 0.0f, 1.5f); // Max 1.5.  Terrorist can go higher than 1 on higher difficulty level
    fDist *= 1.25 - fStealth * 0.5;

    MakeANoise( pawn, fDist, pawnMove.eType, ePawnType, SNDTYPE_PawnMovement );
}

defaultproperties
{
     m_SndBulletImpact=(fSndDist=500.000000,eType=NOISE_Threat)
     m_SndBulletRicochet=(fSndDist=500.000000,eType=NOISE_Threat)
     m_SndGrenadeImpact=(fSndDist=700.000000,eType=NOISE_Grenade)
     m_SndGrenadeLike=(fSndDist=700.000000,eType=NOISE_Investigate)
     m_sndExplosion=(fSndDist=2500.000000,eType=NOISE_Threat)
     m_SndChoking=(fSndDist=1000.000000,eType=NOISE_Investigate)
     m_SndTalking=(fSndDist=1000.000000,eType=NOISE_Investigate)
     m_SndScreaming=(fSndDist=2000.000000,eType=NOISE_Investigate)
     m_SndReload=(fSndDist=500.000000,eType=NOISE_Investigate)
     m_SndEquipping=(fSndDist=600.000000,eType=NOISE_Investigate)
     m_SndDead=(fSndDist=600.000000,eType=NOISE_Dead)
     m_SndDoor=(fSndDist=1000.000000,eType=NOISE_Investigate)
     m_Rainbow=(fStandSlow=300.000000,fStandFast=800.000000,fCrouchSlow=400.000000,fCrouchFast=800.000000,fProne=600.000000,eType=NOISE_Investigate)
     m_Terro=(fStandSlow=1000.000000,fStandFast=1500.000000,fCrouchSlow=1500.000000,fCrouchFast=2000.000000,fProne=2000.000000,eType=NOISE_Investigate)
     m_Hostage=(fStandSlow=1000.000000,fStandFast=1500.000000,fCrouchSlow=1500.000000,fCrouchFast=2000.000000,fProne=2000.000000,eType=NOISE_Investigate)
}
