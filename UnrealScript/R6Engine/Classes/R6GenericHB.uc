class R6GenericHB extends R6InteractiveObject
    abstract
    native;

var BOOL    m_bFirstImpact;
var Sound   m_ImpactSound;		// Sound made when projectile hits something.
var Sound   m_ImpactGroundSound;
var Sound   m_ImpactWaterSound;


simulated function SetSpeed(FLOAT fSpeed)
{
    Velocity = fSpeed * vector(Rotation);
    Acceleration = vector(Rotation) * 50;
    SetDrawType(DT_StaticMesh);
}

simulated event HitWall( vector HitNormal, actor Wall )
{
    local vector    vTraceEnd;
    local rotator   rotGrenade;
    local FLOAT     fOldHeight;
	local vector    vHitLocation, vHitNormal;
    local actor     pHit;
    local material  HitMaterial;

    // Check if it's an InteractiveObject that bullet pass through
    if (Wall != none)
    {
		if((Instigator != none) && (Instigator.m_CollisionBox == Wall))
		{
			vTraceEnd = Location + 10*normal(velocity);
			SetLocation(vTraceEnd, true);
			return;
		}
        
		if( Wall.m_bBulletGoThrough && Wall.IsA( 'R6InteractiveObject' ) )
        {
            Wall.R6TakeDamage( 10000, 10000, Instigator, Wall.Location , Velocity, 0);
            vTraceEnd = Location - 10*HitNormal;
            SetLocation(vTraceEnd, true);
            Velocity *= 0.5;
            return;
        }
    }
        
    DesiredRotation = RotRand();

    // The grenade will bounce off the wall with 33% of it's original velocity
    Velocity = 0.33 * MirrorVectorByNormal( Velocity, HitNormal );

    // FRand() only affect visual here... does not modify any position
    RotationRate.Yaw   = 1000*VSize(Velocity) * FRand() - 500*VSize(Velocity);
    RotationRate.Pitch = 1000*VSize(Velocity) * FRand() - 500*VSize(Velocity);
    RotationRate.Roll  = 1000*VSize(Velocity) * FRand() - 500*VSize(Velocity);

    if( Velocity.Z > 400 )      // Max falling speed
    {
        Velocity.Z = 400;
    }
    else if ( VSize(Velocity) < 50 )
    {
        SetPhysics(PHYS_None);
        bBounce = false;
    }


    // Play a sound on client

	if (m_bFirstImpact)
	{
        m_bFirstImpact =  false;
        if ( Level.NetMode != NM_DedicatedServer )
        {
	        // Set a sound by default
	        m_ImpactSound = m_ImpactGroundSound;

	        pHit = Trace(vHitLocation, vHitNormal, Location - vect(0,0,40), Location, false,, HitMaterial);

	        if ((HitMaterial != none) && ((HitMaterial.m_eSurfIdForSnd == SURF_WaterPuddle) || (HitMaterial.m_eSurfIdForSnd == SURF_DeepWater)))
	        {
		        m_ImpactSound = m_ImpactWaterSound;
	        }
	        PlaySound( m_ImpactSound, SLOT_SFX);
        }
    }
	R6MakeNoise( SNDTYPE_GrenadeLike );
}


simulated function Landed( vector HitNormal )
{
     HitWall( HitNormal, None );
}

simulated singular function Touch(Actor Other)
{
}

simulated function ProcessTouch(Actor Other, vector vHitLocation)
{
    HitWall( vHitLocation, Other);
}

defaultproperties
{
     m_bFirstImpact=True
     m_ImpactGroundSound=Sound'Foley_CommonGrenade.Play_Grenades_GroundImpacts'
     m_iHitPoints=1
     m_bBlockCoronas=True
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     bNoDelete=False
     bSkipActorPropertyReplication=False
     bCollideWorld=True
     bProjTarget=True
     m_bPawnGoThrough=True
     bFixedRotationDir=True
}
