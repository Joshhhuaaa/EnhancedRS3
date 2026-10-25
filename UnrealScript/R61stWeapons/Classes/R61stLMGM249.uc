//===============================================================================
//  [R61stLMGM249] 
//===============================================================================

class R61stLMGM249 extends R61stLMGWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stLMG_UKX.R61stLMGM249A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.LMGs.R61stLMGM249Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     m_RWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG556Nato_RWing'
     m_2Wing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG556Nato_2Wing'
     m_LWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG556Nato_LWing'
     Mesh=SkeletalMesh'R61stLMG_UKX.R61stLMGM249'
}
