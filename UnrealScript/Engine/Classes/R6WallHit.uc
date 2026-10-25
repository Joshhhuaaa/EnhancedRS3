//============================================================================//
// Class            R6WallHit.uc 
// Created By       
// Date             
// Description      R6 base class for Wall effects. Includes: Decals, sparks
//    	 		    and smoke.
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/07	    Cyrille Lauzon: Added the new R6Decals, out effects are not
//									taken in account.
//============================================================================//

class R6WallHit extends R6DecalsBase
    native
    abstract;


var (Rainbow)sound m_ImpactSound;
var (Rainbow)sound m_ExitSound;
var (Rainbow)sound m_RicochetSound;

var (Rainbow)class<R6SFX> m_pSparksIn;

var (Rainbow)Array<Texture> m_DecalTexture;
var (Rainbow)ESoundType     m_eSoundType;
var BOOL                    m_bDoubleFace;
var (Rainbow)bool           m_bGoreLevelHigh;
var ()bool                  bProjectOnlyFirst;

var enum EHitType
{
	HIT_Impact,
    HIT_Ricochet,
	HIT_Exit,
} m_eHitType;

var BOOL m_bPlayEffectSound;  // if you want to Play Sound for the WallHit (espacially use for the shotgun).


replication
{
	unreliable if( Role==ROLE_Authority )
		m_bPlayEffectSound;
}

simulated function FirstPassReset()
{
    Destroy();
}

defaultproperties
{
     m_eSoundType=SNDTYPE_BulletImpact
     m_bPlayEffectSound=True
     bHidden=True
     bNetOptional=True
     m_bDeleteOnReset=True
     LifeSpan=5.000000
     CullDistance=1700.000000
     Texture=None
}
