//===============================================================================
//  [R61stPistolP228] 
//===============================================================================

class R61stPistolP228 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolP228A');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolP228Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
    m_smGun2 = spawn(class'R61stWeaponStaticMesh');
    m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolP228Slide');
    AttachToBone(m_smGun2, 'TagSlide'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolP228'
}
