//============================================================================//
// Class            R6WaterEffect 
// Description      Effects spawned when a bullet hit a Water surface
//----------------------------------------------------------------------------//
//============================================================================//
class R6WaterEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Water'
     m_RicochetSound=Sound'Bullet_Impacts.Play_Impact_Water'
     m_pSparksIn=Class'R6SFX.R6WaterImpact'
}
