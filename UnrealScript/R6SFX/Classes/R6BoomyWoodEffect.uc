//============================================================================//
// Class            R6BoomyWoodEffect
// Date             2001/05/08
// Description      Effects spawned when a bullet hit a Wood wall
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6BoomyWoodEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_BoomyWood'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_BoomyWood'
     m_pSparksIn=Class'R6SFX.R6WoodImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.WallHit.WoodHole001'
     m_DecalTexture(1)=Texture'R6SFX_T.WallHit.WoodHole002'
     m_DecalTexture(2)=Texture'R6SFX_T.WallHit.WoodHole003'
     m_DecalTexture(3)=Texture'R6SFX_T.WallHit.WoodHole004'
}
