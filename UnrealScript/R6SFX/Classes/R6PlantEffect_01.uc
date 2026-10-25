//============================================================================//
// Class            R6PlantEffect_01 
//============================================================================//
class R6PlantEffect_01 extends R6WallHit;

//#exec AUDIO IMPORT FILE="sounds\rsimpact\c_blmttk.wav" NAME="SoundMetalImpact" GROUP="ImpactSound"
//#exec AUDIO IMPORT FILE="sounds\rsimpact\c_blric1.wav" NAME="SoundRicochet" GROUP="RicochetSound"

defaultproperties
{
     m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Vegetal'
     m_RicochetSound=Sound'Bullet_Impacts.Play_Impact_Vegetal'
     m_pSparksIn=Class'R6SFX.R6PlantImpact_01'
}
