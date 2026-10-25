//============================================================================//
// Class            R6WaterFootStep 
// Description      Effects spawned when a pawn walk in water.
//============================================================================//
class R6WaterFootStep extends R6FootStep;

#exec OBJ LOAD FILE="..\Textures\R6SFX_T.utx" PACKAGE=R6SFX_T

defaultproperties
{
     m_fDuration=2.000000
     m_fDurationDirty=120.000000
     m_fDirtyTime=10.000000
     m_DecalLeftFootTexture=Texture'R6SFX_T.FootStep.FootPrint_Left'
     m_DecalRightFootTexture=Texture'R6SFX_T.FootStep.FootPrint_Right'
     m_DecalLeftFootTextureDirty=Texture'R6SFX_T.FootStep.FootPrint_Left'
     m_DecalRightFootTextureDirty=Texture'R6SFX_T.FootStep.FootPrint_Right'
}
