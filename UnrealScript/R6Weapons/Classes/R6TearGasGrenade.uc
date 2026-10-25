//=============================================================================
//  R6TearGasGrenade.uc : TearGas grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Joel Tremblay
//=============================================================================
class R6TearGasGrenade extends R6Grenade;

var FLOAT   m_fExpansionTime;       // Time needed to reach maximum radius
var FLOAT   m_fStartTime;           // Time at wich the explosion occured
var BOOL    m_bGrenadeExploded;

function Timer()
{
    local R6SmokeCloud pCloud;

    if(!m_bGrenadeExploded)
    {
        //When grenade exploded, start checking for characters around the grenade, for a certain period of time
        SetTimer(0.5,true);
        m_fStartTime = Level.TimeSeconds;

        // Create a smoke cloud
        if( m_eGrenadeType==GTYPE_Smoke )
        {
            pCloud = Spawn( class'R6Weapons.R6SmokeCloud',,, Location + vect(0,0,130), Rot(0,0,0) );
            pCloud.SetCloud( Self, 20, 500, 35 );
        }

        m_bGrenadeExploded = true;
        Explode();

        return;
    }

    HurtPawns();
}

simulated function Explode()
{
    local Light pEffectLight;
    local class<emitter> pExplosionParticles;

    pExplosionParticles = GetGrenadeEmitter();

    //Here this crap is done on server, not client.
    if(pExplosionParticles != none)
    {
        m_pEmmiter = Spawn(pExplosionParticles);
        m_pExplosionParticles=none;
        m_pExplosionParticlesLOW=none;
    }
    if(m_pExplosionLight != none)
    {
        pEffectLight = Spawn(m_pExplosionLight);
        m_pExplosionLight=none;
    }
    
    if(m_eGrenadeType==GTYPE_TearGas)
        bHidden=true;

    super.Explode();
}

simulated event Destroyed()
{
    Super.Destroyed();
}

function HurtPawns()
{
    local R6Pawn    aPawn;
    local FLOAT     fElapsedTime;
    local FLOAT     fVisibilityRadius;
    local FLOAT     fMessageRadius;
    
    fElapsedTime = Level.TimeSeconds - m_fStartTime;

    if( fElapsedTime > m_fDuration )
    {
        //Stop the timer, destroy the grenade
        SetTimer(0, false);
        SelfDestroy();
        return;
    }

    if(m_eGrenadeType == GTYPE_Smoke && Physics != PHYS_None)
    {
        if( m_pEmmiter != None )
            m_pEmmiter.SetLocation( Location );
    }

    if( fElapsedTime < m_fExpansionTime )
    {
        fElapsedTime = fElapsedTime/m_fExpansionTime;
        fMessageRadius = m_fKillBlastRadius + fElapsedTime * ( m_fExplosionRadius - m_fKillBlastRadius);
    }
    else
        fMessageRadius = m_fExplosionRadius;

    //Check if a character is in the radius
    foreach VisibleCollidingActors( class'R6Pawn', aPawn, fMessageRadius, Location+vect(0,0,125) )
    {
        // Don't affect dead pawns...
        if( aPawn.IsAlive() && !aPawn.m_bHaveGasMask )
        {
            // The pawn is affected by the grenade, tell the pawn to do something about it.
            aPawn.AffectedByGrenade( Self, m_eGrenadeType );

            // Blur effect
            if(m_eGrenadeType == GTYPE_TearGas)
            {
                // ensure replication
                if(aPawn.m_fRepDecrementalBlurValue == 300)
                    aPawn.m_fRepDecrementalBlurValue = 301;
                else
                    aPawn.m_fRepDecrementalBlurValue = 300;

                aPawn.m_fDecrementalBlurValue = aPawn.m_fRepDecrementalBlurValue;
            }
        }
    }
}

defaultproperties
{
     m_fExpansionTime=2.000000
     m_eExplosionSoundType=SNDTYPE_GrenadeImpact
     m_eGrenadeType=GTYPE_TearGas
     m_iNumberOfFragments=0
     m_fDuration=60.000000
     m_sndExplosionSound=Sound'Grenade_Gas.Play_GasGrenade_Expl'
     m_sndExplosionSoundStop=Sound'Grenade_Gas.Stop_Go_Gas_Silence'
     m_pExplosionParticles=Class'R6SFX.R6TearsGazGrenadeEffect'
     m_DmgPercentStand=(fHead=0.080000,fBody=0.500000,fArms=0.200000,fLegs=0.260000)
     m_DmgPercentCrouch=(fHead=0.120000,fBody=0.250000,fArms=0.320000,fLegs=0.500000)
     m_DmgPercentProne=(fHead=0.760000,fBody=0.020000,fArms=0.200000,fLegs=0.020000)
     m_iEnergy=0
     m_fKillStunTransfer=0.350000
     m_fExplosionRadius=400.000000
     m_fKillBlastRadius=100.000000
     m_fExplosionDelay=2.000000
     m_szAmmoName="Tear Gas Grenade"
     m_szBulletType="GRENADE"
     DrawScale=1.500000
     StaticMesh=StaticMesh'R63rdWeapons_SM.Grenades.R63rdGrenadeTearGas'
}
