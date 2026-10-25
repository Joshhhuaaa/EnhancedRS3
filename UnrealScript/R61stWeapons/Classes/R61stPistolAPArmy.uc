//===============================================================================
//  [R61stPistolAPArmy] 
//===============================================================================

class R61stPistolAPArmy extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolAPArmyA');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolAPArmyFrame');
    AttachToBone(m_smGun, 'TagFrame'); 
    m_smGun2 = spawn(class'R61stWeaponStaticMesh');
    m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolAPArmySlide');
    AttachToBone(m_smGun2, 'TagSlide'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolAPArmy'
}
