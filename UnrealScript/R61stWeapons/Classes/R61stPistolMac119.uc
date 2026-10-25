//===============================================================================
//  [R61stPistolMac119] 
//===============================================================================

class R61stPistolMac119 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolMac119A');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolMac119Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolMac119'
}
