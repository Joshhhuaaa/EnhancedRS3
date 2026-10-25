//============================================================================//
// Class            R6FFSteamEffect
//============================================================================//
class R6FFSteamEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Pipe'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_Pipe'
     m_pSparksIn=Class'R6SFX.R6FFSteamImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.WallHit.HardMetalHole001'
     m_DecalTexture(1)=Texture'R6SFX_T.WallHit.HardMetalHole002'
     m_DecalTexture(2)=Texture'R6SFX_T.WallHit.HardMetalHole003'
     m_DecalTexture(3)=Texture'R6SFX_T.WallHit.HardMetalHole004'
}
