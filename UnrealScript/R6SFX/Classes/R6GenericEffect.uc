//============================================================================//
// Class            R6GenericEffect 
// Created By       Carl Lavoie
// Date             05/05/2002
// Description      Effects spawned when a bullet hit a generic stuff
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6GenericEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Concrete'
     m_RicochetSound=Sound'Bullet_Riccochets.Play_Ricco_Concrete'
     m_pSparksIn=Class'R6SFX.R6GenericImpact'
     m_DecalTexture(0)=Texture'R6SFX_T.WallHit.GenericHole001'
     m_DecalTexture(1)=Texture'R6SFX_T.WallHit.GenericHole002'
     m_DecalTexture(2)=Texture'R6SFX_T.WallHit.GenericHole003'
}
