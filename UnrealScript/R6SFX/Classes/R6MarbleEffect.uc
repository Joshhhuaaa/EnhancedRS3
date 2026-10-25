//============================================================================//
// Class            R6MarbleEffect 
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Effects spawned when a bullet hit a marble wall
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6MarbleEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Concrete'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_Concrete'
     m_pSparksIn=Class'R6SFX.R6MarbleImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.WallHit.BrickHole001'
     m_DecalTexture(1)=Texture'R6SFX_T.WallHit.BrickHole002'
     m_DecalTexture(2)=Texture'R6SFX_T.WallHit.BrickHole003'
     m_DecalTexture(3)=Texture'R6SFX_T.WallHit.BrickHole004'
}
