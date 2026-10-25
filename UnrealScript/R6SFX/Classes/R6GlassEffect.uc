//============================================================================//
// Class            R6GlassEffect 
// Description      Effects spawned when a bullet hit a Glass surface
//----------------------------------------------------------------------------//
//============================================================================//
class R6GlassEffect extends R6SFXWallHit;

defaultproperties
{
     bProjectOnlyFirst=True
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Glass'
     m_RicochetSound=Sound'Bullet_Impacts.Play_Impact_Glass'
     m_pSparksIn=Class'R6SFX.R6GlassImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.GlassHit.GlassHole001'
     m_DecalTexture(1)=Texture'R6SFX_T.GlassHit.GlassHole002'
     m_DecalTexture(2)=Texture'R6SFX_T.GlassHit.GlassHole003'
     m_DecalTexture(3)=Texture'R6SFX_T.GlassHit.GlassHole004'
     CullDistance=2000.000000
}
