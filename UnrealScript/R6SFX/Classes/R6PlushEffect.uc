//============================================================================//
// Class            R6PlushEffect 
// Description      Effects spawned when a bullet hit a Plush surface
//----------------------------------------------------------------------------//
//============================================================================//
class R6PlushEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_SandBag'
     m_RicochetSound=Sound'Bullet_Impacts.Play_Impact_SandBag'
     m_pSparksIn=Class'R6SFX.R6PlushImpact'
}
