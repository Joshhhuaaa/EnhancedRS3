//============================================================================//
// Class            R6SheetMetalEffect 
// Description      Effects spawned when a bullet hit a metal wall
//----------------------------------------------------------------------------//
//============================================================================//
class R6SheetMetalEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_SheetMetal'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_ResonMetal'
     m_pSparksIn=Class'R6SFX.R6SheetMetalImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.WallHit.BulletHole000'
     m_DecalTexture(1)=Texture'R6SFX_T.WallHit.BulletHole001'
     m_DecalTexture(2)=Texture'R6SFX_T.WallHit.BulletHole003'
     m_DecalTexture(3)=Texture'R6SFX_T.WallHit.BulletHole004'
     m_DecalTexture(4)=Texture'R6SFX_T.WallHit.BulletHole005'
     m_DecalTexture(5)=Texture'R6SFX_T.WallHit.BulletHole006'
     m_DecalTexture(6)=Texture'R6SFX_T.WallHit.BulletHole007'
     m_DecalTexture(7)=Texture'R6SFX_T.WallHit.BulletHole009'
     CullDistance=1000.000000
}
