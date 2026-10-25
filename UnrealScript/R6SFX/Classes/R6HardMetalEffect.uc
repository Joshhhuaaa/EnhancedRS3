//============================================================================//
// Class            R6HardMetalEffect 
// Description      Effects spawned when a bullet hit a metal wall
//----------------------------------------------------------------------------//
//============================================================================//
class R6HardMetalEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_HardMetal'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_HardMetal'
     m_pSparksIn=Class'R6SFX.R6MetalImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.WallHit.HardMetalHole001'
     m_DecalTexture(1)=Texture'R6SFX_T.WallHit.HardMetalHole002'
     m_DecalTexture(2)=Texture'R6SFX_T.WallHit.HardMetalHole003'
     m_DecalTexture(3)=Texture'R6SFX_T.WallHit.HardMetalHole004'
     CullDistance=1000.000000
}
