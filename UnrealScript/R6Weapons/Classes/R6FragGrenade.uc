//=============================================================================
//  R6FragGrenade.uc : Normal frag grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6FragGrenade extends R6Grenade;

var			FLOAT		m_fTimerCounter;

function Activate()
{
    if(m_fExplosionDelay != 0)
    {
		m_fTimerCounter = 0.f;
        SetTimer(0.2, true);
    }
}

simulated event Timer()
{
	local	R6RainbowAI	rainbowAI;
	local	Controller	aController;
	local	R6Pawn		aGrenadeOwner;
	local	FLOAT		fDangerZone;

	m_fTimerCounter += 0.2f;
	if(m_fTimerCounter >= m_fExplosionDelay)
    {
		Explode();
		SelfDestroy();
	}
	else
	{
		aGrenadeOwner = R6Pawn(Owner.Owner);
		if((aGrenadeOwner != none) && (aGrenadeOwner.m_ePawnType == PAWN_Rainbow))
			fDangerZone = m_fKillBlastRadius;
		else
			fDangerZone = m_fExplosionRadius;

		// inform RainbowAI of a live grenade	
	    for(aController=Level.ControllerList; aController!=none; aController=aController.NextController)
		{
			rainbowAI = R6RainbowAI(aController);
			if(rainbowAI == none || rainbowAI.pawn == none)
				continue;

			if(VSize(location - rainbowAI.pawn.location) < fDangerZone)
			{					
				if( (velocity == vect(0,0,0)) || (location.z < rainbowAI.pawn.location.z))
					rainbowAI.FragGrenadeInProximity(location, m_fExplosionDelay - m_fTimerCounter, fDangerZone);
			}	
		}
	}
}

function Explode()
{
    local R6SmokeCloud pCloud;
    
    pCloud = Spawn( class'R6Weapons.R6SmokeCloud',,, Location + vect(0,0,125), Rot(0,0,0) );
    pCloud.SetCloud( Self, 1.5, 150, 4 );
    
	SetTimer(0, false);
	Super.Explode();
}

function HurtPawns()
{
    local R6InteractiveObject anObject;
    local R6DemolitionsUnit   aDemoUnit;
    local R6Pawn              aPawn;
    local R6Pawn              aPawnInstigator;
    local eGrenadeBoneTarget  eBoneTarget;
    local R6IORotatingDoor    pImADoor;

    local FLOAT               fDistFromGrenade;
        
    local FLOAT               fDamagePercent;    //percent between the kill blast radius and the explosion radius
    local FLOAT               fEffectiveKillValue;
    local FLOAT               fEffectiveStunValue;
    local vector              vDamageLocation;
    local vector              vExplosionMomentum;

    local INT                 iCurrentFragment;
    local FLOAT               fCurrentNumberOfFragments;
    local INT                 _iHealth;
    local INT                 _PawnsHurtCount;
    local BOOL                _bCompilingStats;

    local Controller          aC;
    local R6PlayerController  aPC;

    aPawnInstigator = R6Pawn(Instigator);
    _bCompilingStats = R6AbstractGameInfo(Level.Game).m_bCompilingStats;
        
    //Destroy demo units within range
    foreach VisibleCollidingActors( class'R6DemolitionsUnit', aDemoUnit, m_fKillBlastRadius, Location )
    {
        aDemoUnit.DestroyedByImpact();
    }
	
    foreach VisibleCollidingActors(class'R6InteractiveObject', anObject, m_fExplosionRadius, Location )
	{
        fDistFromGrenade = VSize(anObject.Location - Location);
		if( fDistFromGrenade <= m_fExplosionRadius )
		{
            pImADoor = R6IORotatingDoor(anObject);
            if(pImADoor != none)
            {
                vDamageLocation = pImADoor.m_vVisibleCenter;
            }
            else
            {
                vDamageLocation = anObject.Location;
            }

	        // Kill value
            if(fDistFromGrenade < m_fKillBlastRadius)
            {
		        fEffectiveKillValue = max(m_iEnergy, 0);
            }
            else
            {
                fEffectiveKillValue = max(m_iEnergy * fDamagePercent, 0);
            }

            if(fEffectiveKillValue != 0)
            {
		        // Temporary momentum, quarter of distance from grenade...
		        vExplosionMomentum = vDamageLocation - Location;

                //if (anObject is destroyed) AND (Grenade did not blow a door already) AND (a door was destroyed)
		        anObject.R6TakeDamage( fEffectiveKillValue, 0, Instigator, vDamageLocation, vExplosionMomentum, 0 );
	        }
		}
	}

    foreach CollidingActors( class'R6Pawn', aPawn, m_fExplosionRadius, Location )
    {
		// check for friendly fire if multiplayer
        if( (Level.NetMode != NM_Standalone && aPawnInstigator.m_ePawnType==PAWN_Rainbow
			 && !(R6PlayerController(aPawn.Controller) != none && R6AbstractGameInfo(Level.Game).m_bFriendlyFire == true))
			&& ( (!aPawnInstigator.m_bCanFireFriends  && aPawnInstigator.IsFriend(aPawn))  
			     || (!aPawnInstigator.m_bCanFireNeutrals && aPawnInstigator.IsNeutral(aPawn)) )
		  )
		  	  continue;
        
        // Don't affect dead pawns...
        if( aPawn.m_eHealth != HEALTH_Dead )
        {
            if( aPawn.PawnCanBeHurtFrom(Location) )
            {
                // Distance from grenade
                fDistFromGrenade = VSize( aPawn.Location - Location );
         
                // If the pawn is inside the kill radius... kill him
                if( fDistFromGrenade <= m_fKillBlastRadius )
                {
                    // Temporary momentum, quarter of distance from grenade...
                    vExplosionMomentum = (aPawn.Location - Location) * 0.25f;

				    // Should damage a specific body part (eBoneTarget) - need to be implemented in R6Pawn
				    aPawn.ServerForceKillResult(4);  //Force R6TakeDamage to kill the pawn
				    aPawn.R6TakeDamage( m_iEnergy, m_iEnergy, Instigator, aPawn.Location , vExplosionMomentum, 0);
				    aPawn.ServerForceKillResult(0);  //Reset Kill to Normal
                    if((aPawnInstigator != none) && !aPawnInstigator.IsFriend(aPawn))
                    {
                        _PawnsHurtCount++;
                        R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
                    }               
                
                    if( bShowLog ) log( "Pawn " $ aPawn $ " was killed by a grenade !" );
                }
                // If not killed, add it to a list of damaged pawns.  This has to 
                // be done because we need to do a trace to the bone that will be
                // hit, and Trace can't be used inside of a VisibleCollidingActors loop.
                else
                {
                    fDamagePercent = 1.0 - ((fDistFromGrenade - m_fKillBlastRadius) / m_fEffectiveOutsideKillRadius);

                    if( bShowLog )log( "Actor " $ aPawn $ " was hit by a grenade.  Distance : " $ (fDistFromGrenade*0.01f) $" % : "$ fDamagePercent);
        
                    fCurrentNumberOfFragments = m_iNumberOfFragments * fDamagePercent;

                    for(iCurrentFragment = 0; iCurrentFragment < fCurrentNumberOfFragments; iCurrentFragment++)
                    {
				        // If there is a line traceable between the grenade and the bone representing the hit location 
				        //    The player gets damage using the following formula
				        //    Effective Damage = Damage * (KillRadius - Distance) / (ZeroRadius - KillRadius)
				        //    Apply the effective damage to the bone - Need to be implemented in R6Pawn
				        eBoneTarget = HitRandomBodyPart( GetPawnPose(aPawn) );
            
				        switch( eBoneTarget )
				        {
				        case GBT_Head:      vDamageLocation = aPawn.GetBoneCoords( 'R6 Head' ).Origin;       break;
				        case GBT_Body:      vDamageLocation = aPawn.GetBoneCoords( 'R6 Spine' ).Origin;      break;
				        case GBT_LeftArm:   vDamageLocation = aPawn.GetBoneCoords( 'R6 L ForeArm' ).Origin;  break;
				        case GBT_RightArm:  vDamageLocation = aPawn.GetBoneCoords( 'R6 R ForeArm' ).Origin;  break;
				        case GBT_LeftLeg:   vDamageLocation = aPawn.GetBoneCoords( 'R6 L Thigh' ).Origin;    break;
				        case GBT_RightLeg:  vDamageLocation = aPawn.GetBoneCoords( 'R6 R Thigh' ).Origin;    break;
				        }

				        // Distance from grenade
				        fDistFromGrenade = VSize( vDamageLocation - Location );
    
				        // Kill value
    			        fEffectiveKillValue = max(m_iEnergy * fDamagePercent, 0);

                        if(fEffectiveKillValue != 0) 
                        {
                            // Stun value
				            fEffectiveStunValue = fEffectiveKillValue + (fEffectiveKillValue * m_fKillStunTransfer);

				            // Temporary momentum, quarter of distance from grenade...
				            vExplosionMomentum = vDamageLocation - Location;

				            // Should damage a specific body part (eBoneTarget) - need to be implemented in R6Pawn
                            _iHealth = aPawn.m_eHealth;
				            aPawn.R6TakeDamage( fEffectiveKillValue, fEffectiveStunValue, Instigator, vDamageLocation, vExplosionMomentum, 0);
                            if ((_iHealth != aPawn.m_eHealth) && (aPawnInstigator != none) && !aPawnInstigator.IsFriend(aPawn))
                            {
                                _PawnsHurtCount++;
                                R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
                            }
                        }
			        }
                }
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
     m_sndExplodeMetal=Sound'Grenade_Frag.Play_random_Frag_Expl_Metal'
     m_sndExplodeWater=Sound'Grenade_Frag.Play_Frag_Expl_Water'
     m_sndExplodeAir=Sound'Grenade_Frag.Play_Frag_Expl_Air'
     m_sndExplodeDirt=Sound'Grenade_Frag.Play_random_Frag_Expl_Dirt'
     m_pExplosionParticles=Class'R6SFX.R6FragGrenadeEffect'
     m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
     m_GrenadeDecalClass=Class'R6Engine.R6GrenadeDecal'
     m_DmgPercentStand=(fHead=0.080000,fBody=0.500000,fArms=0.200000,fLegs=0.260000)
     m_DmgPercentCrouch=(fHead=0.120000,fBody=0.250000,fArms=0.320000,fLegs=0.500000)
     m_DmgPercentProne=(fHead=0.760000,fBody=0.020000,fArms=0.200000,fLegs=0.020000)
     m_iEnergy=3000
     m_fKillStunTransfer=0.350000
     m_fExplosionRadius=500.000000
     m_fKillBlastRadius=300.000000
     m_fExplosionDelay=2.500000
     m_szAmmoName="Fragmentation Grenade"
     m_szBulletType="GRENADE"
     LifeSpan=2.700000
     DrawScale=1.500000
     StaticMesh=StaticMesh'R63rdWeapons_SM.Grenades.R63rdGrenadeHE'
}
