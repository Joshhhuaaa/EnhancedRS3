//===============================================================================
//  [R61stShotgunUSAS12]  
//===============================================================================

class R61stShotgunUSAS12 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stShotgun_UKX.R61stShotgunUSAS12A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunUSAS12Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
    if(m_smGun2 == none)
    {
        m_smGun2 = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunUSAS12Magazine');
    AttachToBone(m_smGun2, 'TagMagazine'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stShotgun_UKX.R61stShotgunUSAS12'
}
