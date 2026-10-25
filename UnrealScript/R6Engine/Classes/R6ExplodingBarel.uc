//=============================================================================
//  R6ExplodingBarel : 
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//=============================================================================

class R6ExplodingBarel extends R6InteractiveObject
	placeable;

var(R6ActionObject) float           m_fExplosionRadius; // feel the sake
var(R6ActionObject) float           m_fKillBlastRadius; // killed by the bomb
var(R6ActionObject) int             m_iEnergy;
var                 Emitter         m_pEmmiter;
var                 class<Light>    m_pExplosionLight;

function INT R6TakeDamage(INT iKillValue, INT iStunValue, Pawn instigatedBy, vector vHitLocation, 
                          vector vMomentum, INT iBulletToArmorModifier, optional int iBulletGroup)
{
    local INT iDamage;

    if(m_bBroken)
        return 0;

    iDamage = Super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGroup);

    if(m_bBroken)
    {
        Instigator = instigatedBy;
        Explode();
    }

    return iDamage;
}
    
function Explode()
{
    local R6GrenadeDecal    GrenadeDecal;
    local rotator           GrenadeDecalRotation;
    local Light             pEffectLight;
    local vector            vDecalLoc;
    local float             fDistFromBarel;
    local Actor             aActor;
    local R6Pawn            pPawn;
    local R6InteractiveObject pIO;
    local R6PlayerController pPC;
    local INT               iKillResult;
   
    AmbientSound = none;
    m_bBroken = true;
    
    vDecalLoc = Location;
    vDecalLoc.Z -= 55; // lower the Z on the floor
    GrenadeDecal = Spawn(class'Engine.R6GrenadeDecal',,, vDecalLoc, GrenadeDecalRotation);

    m_pEmmiter = Spawn(class'R6SFX.R6explosiveDrum');
    m_pEmmiter.RemoteRole = ROLE_AutonomousProxy; // replicate this actor on all client
    m_pEmmiter.Role = ROLE_Authority;
    
    pEffectLight = Spawn(m_pExplosionLight);

    foreach CollidingActors(class'Actor', aActor, m_fExplosionRadius, Location)
    {
        pPawn = R6Pawn(aActor);
        if(pPawn != none)
        {
            if(pPawn.IsAlive())
            {
                if(FastTrace(Location, pPawn.Location))
                {
                    fDistFromBarel = VSize(pPawn.Location - Location);
                    if(fDistFromBarel <= m_fKillBlastRadius)
                        iKillResult = 4; //Force R6TakeDamage to kill the pawn
                    else
                        iKillResult = 2; //Force R6TakeDamage to wound the pawn

	                pPawn.ServerForceKillResult(iKillResult);  
	                pPawn.R6TakeDamage(m_iEnergy, m_iEnergy, Instigator, pPawn.Location, (pPawn.Location - Location) * 0.25f, 0);
	                pPawn.ServerForceKillResult(0);  //Reset Kill to Normal
                }

                if(pPawn.IsAlive())
                {
                    pPC = R6PlayerController(pPawn.Controller);
                    if(pPC != none)
                    {
                        fDistFromBarel = VSize(pPawn.Location - Location);
                        pPC.R6Shake(1.5f, m_fExplosionRadius - fDistFromBarel, 0.1f);
                    }
                }
            }
        }
        else
        {
            pIO = R6InteractiveObject(aActor);
            if(pIO != none)
            {
                if(!pIO.m_bBroken)
                {
                    fDistFromBarel = VSize(pIO.Location - Location);
                    if(fDistFromBarel <= m_fKillBlastRadius || FastTrace(Location, pIO.Location))
                        pIO.R6TakeDamage(m_iEnergy, m_iEnergy, Instigator, pIO.Location, (pIO.Location - Location) * 0.25f, 0);
                }
            }
        }
    }
    
    R6MakeNoise(SNDTYPE_Explosion);
}

defaultproperties
{
     m_iEnergy=3000
     m_fExplosionRadius=1000.000000
     m_fKillBlastRadius=500.000000
     m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
     m_iHitPoints=2000
     m_StateList(0)=(RandomMeshes=((fPercentage=100.000000,Mesh=StaticMesh'R6SFX_SM.Other.ExplosiveDrum_Broken')),ActorList=((ActorToSpawn=Class'R6SFX.R6Fire_C',HelperName="Flame")))
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'R6SFX_SM.Other.ExplosiveDrum'
}
