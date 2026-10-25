//============================================================================//
// Class            R6MetalFenceEffect 
// Description      Effects spawned when a bullet hit a metal wall
//----------------------------------------------------------------------------//
//============================================================================//
class R6MetalFenceEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_MetalFence'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_MetalFence'
     m_pSparksIn=Class'R6SFX.R6MetalImpact'
}
