//=============================================================================
//  R6BreachingChargeUnit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/08 * Created by Rima Brek
//=============================================================================
class R6BreachingChargeUnit extends R6DemolitionsUnit;


//a bullet hit the demolition charge
function BOOL DestroyedByImpact()
{
    R6IORotatingDoor(owner).RemoveBreach(self);

    return Super.DestroyedByImpact();
}


function HurtPawns()
{
    local R6InteractiveObject anObject;
    local R6Pawn              aPawn;
    local R6Pawn              aPawnInstigator;
    local R6DemolitionsUnit   aDemoUnit;

    local FLOAT               fDistFromCharge;
    local vector              vExplosionMomentum;
    
    local vector              vDoorCenter;
    local vector              vActorDir;
    local vector              vFacingDir;
    local rotator             rDoorInit;
    local INT                 _iHealth;
    local INT                 _PawnsHurtCount;
    local BOOL                _bCompilingStats;
    
    local Controller          aC;
    local R6PlayerController  aPC;
    local FLOAT               fDistFromGrenade;
    local Actor               HitActor;
    local vector              vHitLocation;
    local vector              vHitNormal;

    aPawnInstigator = R6Pawn(Instigator);
    vDoorCenter = R6IORotatingDoor(owner).m_vVisibleCenter;
    _PawnsHurtCount = 0;
    _bCompilingStats = R6AbstractGameInfo(Level.Game).m_bCompilingStats;
    if(DrawScale3D.Y > 0)
        vFacingDir = vector(rotation) cross vect(0,0,-1);
    else
        vFacingDir = vector(rotation) cross vect(0,0,1);

    //Destroy demo units within range
    foreach VisibleCollidingActors( class'R6DemolitionsUnit', aDemoUnit, m_fKillBlastRadius, Location )
    {
        if(aDemoUnit != self)
            aDemoUnit.DestroyedByImpact();
    }

    R6IORotatingDoor(Owner).R6TakeDamage(m_iEnergy, 0, Instigator, vect(0,0,0), vFacingDir, 0);

    foreach CollidingActors( class'R6Pawn', aPawn, m_fExplosionRadius + 800.f, vDoorCenter )
    {   
        // check for friendly fire if multiplayer
        if( (Level.NetMode != NM_Standalone) 
            && ( (!aPawnInstigator.m_bCanFireFriends  && aPawnInstigator.IsFriend(aPawn))  
              || (!aPawnInstigator.m_bCanFireNeutrals && aPawnInstigator.IsNeutral(aPawn)) )
          )
              continue;

        // Don't affect dead pawns...
        if( aPawn.m_eHealth != HEALTH_Dead )
        {
            // Check with center and if not visible, check with eyes
            HitActor = aPawn.R6Trace(vHitLocation, vHitNormal, vDoorCenter, aPawn.Location, TF_Visibility|TF_LineOfFire|TF_SkipPawn);
            if(HitActor!=none)
                HitActor = aPawn.R6Trace(vHitLocation, vHitNormal, vDoorCenter, aPawn.Location + aPawn.EyePosition(), TF_Visibility|TF_LineOfFire|TF_SkipPawn);
            if(HitActor!=none)
                continue;

            // Distance from door
            fDistFromCharge = VSize( aPawn.Location - vDoorCenter );
            
            // todo : use center of door as the location of the blast
            // breaching charge explodes mainly towards its frontal hemisphere...
            vActorDir = Normal(aPawn.location - vDoorCenter);

            // Temporary momentum, quarter of distance from grenade...
            vExplosionMomentum = (aPawn.location - vDoorCenter) * 0.25f;

            if((vActorDir dot vFacingDir) < 0)
            {
                // for a pawn standing behind the explosion, there is no kill zone for the breaching charge only a hurt zone of .5m
                if(fDistFromCharge < m_fExplosionRadius * 0.5)
                {
                    if((aPawnInstigator != none) && !aPawnInstigator.IsFriend(aPawn))
                    {
                        _PawnsHurtCount++;
                        R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
                    }               
                    aPawn.R6TakeDamage( 0, m_iEnergy, Instigator, aPawn.Location, vExplosionMomentum, 0);
                }
                continue;           
            } 

            if(fDistFromCharge < m_fKillBlastRadius)
            {            
                // If a pawn is hit by a breach charge he dies.             
                // Should damage a specific body part (eBoneTarget) - need to be implemented in R6Pawn
                aPawn.ServerForceKillResult(4);  //Force R6TakeDamage to kill the pawn
                aPawn.R6TakeDamage( m_iEnergy, m_iEnergy, Instigator, aPawn.Location, vExplosionMomentum, 0);
                aPawn.ServerForceKillResult(0);  //Reset Kill to Normal
                if((aPawnInstigator != none) && !aPawnInstigator.IsFriend(aPawn))
                {       
                    _PawnsHurtCount++;
                    R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
                }
            
                #ifdefDEBUG if( bShowLog ) log( "Pawn " $ aPawn $ " was killed by a breaching charge !" ); #endif
            }
            else
            {
                if(fDistFromCharge <= m_fExplosionRadius)
                {
                    _iHealth = aPawn.m_eHealth;
                    DistributeDamage(aPawn, location);
                    if ((_iHealth != aPawn.m_eHealth) && (aPawnInstigator != none) && !aPawnInstigator.IsFriend(aPawn))
                    {
                        R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
                    }               
                }
                // The pawn is affected by the grenade, tell the pawn to do something about it.
                aPawn.AffectedByGrenade( Self, GTYPE_BreachingCharge );
            }
        }
    }

    if (_PawnsHurtCount==0)
    {
        R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
    }
    // Controller shake
    for( aC=Level.ControllerList; aC!=none; aC=aC.NextController )
    {
        if(aC.Pawn!=none && aC.Pawn.m_ePawnType==PAWN_Rainbow && aC.Pawn.IsAlive())
        {
            aPC = R6PlayerController(aC);
            if( aPC != none )
            {
                fDistFromGrenade = VSize( Location - aPC.Pawn.Location );
                if(fDistFromGrenade<m_fShakeRadius)
                {
                    aPC.R6Shake( 1.0f, m_fShakeRadius-fDistFromGrenade, 0.05f );
                    aPC.ClientPlaySound(m_sndEarthQuake, SLOT_SFX);
                }
            }
        }
    }
}

defaultproperties
{
     m_iNumberOfFragments=1
     m_sndExplosionSound=Sound'Gadget_BreachingCharge.Play_random_Breaching_Expl'
     m_pExplosionParticles=Class'R6SFX.R6BreachingChargeEffect'
     m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
     m_iEnergy=8000
     m_fExplosionRadius=200.000000
     m_fKillBlastRadius=100.000000
     m_szAmmoName="Breaching Charge"
     Physics=PHYS_None
     m_bDrawFromBase=True
     bCollideWorld=False
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdBreachingCharge'
}
