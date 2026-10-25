//============================================================================//
// Class            R6PlatreEffect 
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Effects spawned when a bullet hit a metal wall
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6PlatreEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Concrete'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_Concrete'
     m_pSparksIn=Class'R6SFX.R6PlatreImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.WallHit.BulletHole000'
     m_DecalTexture(1)=Texture'R6SFX_T.WallHit.BulletHole001'
     m_DecalTexture(2)=Texture'R6SFX_T.WallHit.BulletHole003'
     m_DecalTexture(3)=Texture'R6SFX_T.WallHit.BulletHole004'
     m_DecalTexture(4)=Texture'R6SFX_T.WallHit.BulletHole005'
     m_DecalTexture(5)=Texture'R6SFX_T.WallHit.BulletHole006'
     m_DecalTexture(6)=Texture'R6SFX_T.WallHit.BulletHole007'
     m_DecalTexture(7)=Texture'R6SFX_T.WallHit.BulletHole009'
}
