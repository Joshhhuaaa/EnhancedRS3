//=============================================================================
//  FlashBang.uc : Flashbang grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6FlashBang extends R6Grenade;

var float m_fBlindEffectRadius;

function HurtPawns()
{
    local R6Pawn              aPawn;
	local R6InteractiveObject anObject;

    local FLOAT               fDistFromFlashbang;
        
    local FLOAT               fEffectiveStunValue;
    local vector              vDamageLocation;
    local vector              vExplosionMomentum;

    local vector              vHitLocation;
    local vector              vHitNormal;
    local Actor               HitActor;

    foreach CollidingActors( class'R6Pawn', aPawn, m_fBlindEffectRadius, Location )
    {
        // Don't affect dead pawns...
        if( aPawn.m_eHealth != HEALTH_Dead )
        {
            HitActor = aPawn.R6Trace(vHitLocation, vHitNormal, Location, aPawn.Location + aPawn.EyePosition(), TF_TraceActors|TF_Visibility|TF_LineOfFire|TF_SkipPawn);
            if(HitActor == none)
            {
                // Distance from grenade
                fDistFromFlashbang = VSize( aPawn.Location - Location );
         
                fEffectiveStunValue = m_iEnergy * (1 - (fDistFromFlashbang / m_fBlindEffectRadius));
                // Temporary momentum, quarter of distance from grenade...
                vExplosionMomentum = (vDamageLocation - Location) * 0.25f;

                vDamageLocation = aPawn.GetBoneCoords( 'R6 Head' ).Origin;

                aPawn.ServerForceStunResult(4);
			    aPawn.R6TakeDamage( 0, fEffectiveStunValue, Instigator, vDamageLocation, vExplosionMomentum, 0);
                aPawn.ServerForceStunResult(0);

                // The pawn is affected by the grenade, tell the pawn to do something about it.
                aPawn.AffectedByGrenade( Self, GTYPE_FlashBang );
            }
        }
    }

	foreach VisibleCollidingActors( class'R6InteractiveObject', anObject, m_fExplosionRadius, Location )
	{
		if((anObject.m_bBreakableByFlashBang == true) && (anObject.m_iHitPoints > 0))
			anObject.R6TakeDamage( 1000, fEffectiveStunValue, Instigator, anObject.Location, vect(0,0,0), 0);
	}
}

defaultproperties
{
     m_fBlindEffectRadius=5000.000000
     m_eGrenadeType=GTYPE_FlashBang
     m_iNumberOfFragments=0
     m_sndExplosionSound=Sound'Grenade_FlashBang.Play_FlashBang_Expl'
     m_pExplosionParticles=Class'R6SFX.R6FlashBangEffect'
     m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
     m_iEnergy=4000
     m_fKillStunTransfer=0.350000
     m_fExplosionRadius=500.000000
     m_fExplosionDelay=2.000000
     m_szAmmoName="FlashBang Grenade"
     m_szBulletType="GRENADE"
     LifeSpan=2.000000
     DrawScale=1.500000
     StaticMesh=StaticMesh'R63rdWeapons_SM.Grenades.R63rdGrenadeFlashbang'
}
