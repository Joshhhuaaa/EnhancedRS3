//===============================================================================
//  [R61stLMGRPD] 
//===============================================================================

class R61stLMGRPD extends R61stLMGWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stLMG_UKX.R61stLMGRPDA');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.LMGs.R61stLMGRPDFrame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     m_RWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Russ_RWing'
     m_2Wing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Russ_2Wing'
     m_LWing=StaticMesh'R61stWeapons_SM.LMGs.R61stLMG762Russ_LWing'
     Mesh=SkeletalMesh'R61stLMG_UKX.R61stLMGRPD'
}
