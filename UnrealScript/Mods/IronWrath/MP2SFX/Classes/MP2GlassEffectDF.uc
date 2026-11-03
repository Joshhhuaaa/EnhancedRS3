class MP2GlassEffectDF extends R6SFXWallHit;

#exec OBJ LOAD FILE=..\Sounds\Bullet_Impacts.uax PACKAGE=Bullet_Impacts
#exec OBJ LOAD FILE=..\Textures\R6SFX_T.utx PACKAGE=R6SFX_T

defaultproperties
{
    m_bDoubleFace=true
    m_ImpactSound=Sound'Bullet_Impacts.Play_Impact_Glass'
    m_RicochetSound=Sound'Bullet_Impacts.Play_Impact_Glass'
    m_pSparksIn=Class'R6SFX.R6GlassImpact'
    m_DecalTexture[0]=Texture'R6SFX_T.GlassHit.GlassHole001'
    m_DecalTexture[1]=Texture'R6SFX_T.GlassHit.GlassHole002'
    m_DecalTexture[2]=Texture'R6SFX_T.GlassHit.GlassHole003'
    m_DecalTexture[3]=Texture'R6SFX_T.GlassHit.GlassHole004'
}
