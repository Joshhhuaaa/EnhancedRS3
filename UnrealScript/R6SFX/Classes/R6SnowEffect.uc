//============================================================================//
// Class            r6snoweffect 
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Effects spawned when a bullet hit a metal wall
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6SnowEffect extends R6SFXWallHit;

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Snow'
     m_RicochetSound=Sound'Bullet_Impacts.Play_Impact_Snow'
     m_pSparksIn=Class'R6SFX.R6SnowImpact'
}
