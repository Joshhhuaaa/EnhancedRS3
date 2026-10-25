//===============================================================================
//  [R61stAssaultM14] 
//===============================================================================

class R61stAssaultM14 extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stAssault_UKX.R61stAssaultM14A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultM14Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stAssault_UKX.R61stAssaultM14'
}
