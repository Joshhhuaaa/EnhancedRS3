//===============================================================================
//  [R61stShotgunM1] 
//===============================================================================

class R61stShotgunM1 extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stShotgun_UKX.R61stShotgunM1A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Shotguns.R61stShotgunM1Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stShotgun_UKX.R61stShotgunM1'
}
