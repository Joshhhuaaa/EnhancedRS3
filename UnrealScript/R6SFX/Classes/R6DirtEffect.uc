//============================================================================//
// Class            R6DirtEffect 
// Description      Effects spawned when a bullet hit a Dirt surface
//----------------------------------------------------------------------------//
//============================================================================//
class R6DirtEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_GenDirt'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_Dirt'
     m_pSparksIn=Class'R6SFX.R6DirtImpact'
}
