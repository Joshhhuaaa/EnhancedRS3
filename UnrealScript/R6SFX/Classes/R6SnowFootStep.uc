//============================================================================//
// Class            R6SnowFootStep 
// Description      Effects spawned when a pawn walk on snow
//============================================================================//
class R6SnowFootStep extends R6FootStep;

#exec OBJ LOAD FILE="..\Textures\R6SFX_T.utx" PACKAGE=R6SFX_T

defaultproperties
{
     m_fDurationDirty=30.000000
     m_fDirtyTime=10.000000
     m_DecalLeftFootTexture=Texture'R6SFX_T.FootStep.snow_footsteps_l'
     m_DecalRightFootTexture=Texture'R6SFX_T.FootStep.snow_footsteps_r'
     m_DecalLeftFootTextureDirty=Texture'R6SFX_T.FootStep.FootPrint_Left'
     m_DecalRightFootTextureDirty=Texture'R6SFX_T.FootStep.FootPrint_Right'
}
