//============================================================================//
// Class            r6BloodEffect 
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Effects spawned when a bullet hit a Human Flesh
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6BloodEffect extends R6SFXWallHit;

defaultproperties
{
     m_bGoreLevelHigh=True
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Rainbow'
     m_pSparksIn=Class'R6SFX.R6BloodImpact'
}
