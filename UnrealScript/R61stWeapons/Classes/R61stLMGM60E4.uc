//===============================================================================
//  [R61stLMGM60E4] 
//===============================================================================

class R61stLMGM60E4 extends R61stLMGWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stLMG_UKX.R61stLMGM60E4A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.LMGs.R61stLMGM60E4Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     m_RWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_RWing'
     m_2Wing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_2Wing'
     m_LWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Nato_LWing'
     Mesh=SkeletalMesh'R61stLMG_UKX.R61stLMGM60E4'
}
