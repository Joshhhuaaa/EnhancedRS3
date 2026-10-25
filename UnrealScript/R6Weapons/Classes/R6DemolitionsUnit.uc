//=============================================================================
//  R6DemolitionsUnit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/09 * Created by Rima Brek
//=============================================================================
class R6DemolitionsUnit extends R6Grenade;

var bool m_bExploding;

function Activate();
simulated function HitWall( vector HitNormal, actor Wall );
simulated function Landed( vector HitNormal );
simulated singular function Touch(Actor Other);
simulated function ProcessTouch(Actor Other, vector vHitLocation);

function Explode()
{
    m_bExploding = true;
	Super.Explode();
	SelfDestroy();
}

//a bullet hit the demolition charge
function BOOL DestroyedByImpact()
{
    Spawn(Class'R6SFX.R6BreakablePhone', none,, Location);
    m_Weapon.MyUnitIsDestroyed();
    m_bDestroyedByImpact=true;
    SelfDestroy();
    //Tell the player controller that he can't blow this thing anymore
    return true;
}

function DoorExploded()
{
    if(!m_bExploding)
        DestroyedByImpact();
}

function DistributeDamage(Actor anActor, vector vLocationOfExplosion)
{
    local INT                 iCurrentFragment;
    local FLOAT               fCurrentNumberOfFragments;

    local vector              vHit;
    local vector              vHitNormal;
    local vector              vExplosionMomentum;
	local vector			  vDamageLocation;
	
    local FLOAT               fDistFromGrenade;
	local eGrenadeBoneTarget  eBoneTarget;
	
    local FLOAT               fDamagePercent;
    local FLOAT               fEffectiveKillValue;
    local FLOAT               fEffectiveStunValue;

    local R6IORotatingDoor    pImADoor;

    fDistFromGrenade = VSize(anActor.Location - Location);
    fDamagePercent = 1.0 - ((fDistFromGrenade - m_fKillBlastRadius) / m_fEffectiveOutsideKillRadius);

    if(bShowLog) log( "Actor " $ anActor $ " was hit by a grenade.  Distance : " $ (fDistFromGrenade*0.01f));

	if (anActor.isA('R6Pawn'))
	{
        fCurrentNumberOfFragments = m_iNumberOfFragments * fDamagePercent;

        for(iCurrentFragment = 0; iCurrentFragment < fCurrentNumberOfFragments; iCurrentFragment++)
        {
			// If there is a line traceable between the grenade and the bone representing the hit location 
			//    The player gets damage using the following formula
			//    Effective Damage = Damage * (KillRadius - Distance) / (ZeroRadius - KillRadius)
			//    Apply the effective damage to the bone - Need to be implemented in R6Pawn
			eBoneTarget = HitRandomBodyPart( GetPawnPose(R6Pawn(anActor)) );
            
			switch( eBoneTarget )
			{
			case GBT_Head:      vDamageLocation = anActor.GetBoneCoords( 'R6 Head' ).Origin;       break;
			case GBT_Body:      vDamageLocation = anActor.GetBoneCoords( 'R6 Spine' ).Origin;      break;
			case GBT_LeftArm:   vDamageLocation = anActor.GetBoneCoords( 'R6 L ForeArm' ).Origin;  break;
			case GBT_RightArm:  vDamageLocation = anActor.GetBoneCoords( 'R6 R ForeArm' ).Origin;  break;
			case GBT_LeftLeg:   vDamageLocation = anActor.GetBoneCoords( 'R6 L Thigh' ).Origin;    break;
			case GBT_RightLeg:  vDamageLocation = anActor.GetBoneCoords( 'R6 R Thigh' ).Origin;    break;
			}

			// Distance from grenade
			fDistFromGrenade = VSize( vDamageLocation - vLocationOfExplosion );
			
			// Kill value
			fEffectiveKillValue = max(m_iEnergy * fDamagePercent, 0);

            if(fEffectiveKillValue != 0) 
            {
                // Stun value
			    fEffectiveStunValue = fEffectiveKillValue + (fEffectiveKillValue * m_fKillStunTransfer);

			    // Temporary momentum, quarter of distance from grenade...
			    vExplosionMomentum = vDamageLocation - vLocationOfExplosion;

			    // Should damage a specific body part (eBoneTarget) - need to be implemented in R6Pawn
			    anActor.R6TakeDamage( fEffectiveKillValue, fEffectiveStunValue, Instigator, vDamageLocation, vExplosionMomentum, 0);
            }
		}
    }
	else
	{
        pImADoor = R6IORotatingDoor(anActor);
        if(pImADoor != none)
        {
            vDamageLocation = pImADoor.m_vVisibleCenter;
        }
        else
        {
            vDamageLocation = anActor.Location;
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
		    vExplosionMomentum = vDamageLocation - vLocationOfExplosion;

            //if door was not destroyed, return 0.
		    anActor.R6TakeDamage( fEffectiveKillValue, 0, Instigator, vDamageLocation, vExplosionMomentum, 0);
        }
	}
}

defaultproperties
{
     m_DmgPercentStand=(fHead=0.080000,fBody=0.500000,fArms=0.200000,fLegs=0.260000)
     m_DmgPercentCrouch=(fHead=0.120000,fBody=0.250000,fArms=0.320000,fLegs=0.500000)
     m_DmgPercentProne=(fHead=0.760000,fBody=0.020000,fArms=0.200000,fLegs=0.020000)
     m_fKillStunTransfer=0.350000
     m_fExplosionDelay=0.000000
     m_szBulletType="DEMOLITIONS"
}
