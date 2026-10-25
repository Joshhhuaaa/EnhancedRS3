//============================================================================//
// Class            R6HardWoodEffect 
// Description      Effects spawned when a bullet hit a Wood wall
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6HardWoodEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_HardWood'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_HardWood'
     m_pSparksIn=Class'R6SFX.R6WoodImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.WallHit.WoodHole001'
     m_DecalTexture(1)=Texture'R6SFX_T.WallHit.WoodHole002'
     m_DecalTexture(2)=Texture'R6SFX_T.WallHit.WoodHole003'
     m_DecalTexture(3)=Texture'R6SFX_T.WallHit.WoodHole004'
     CullDistance=1000.000000
}
