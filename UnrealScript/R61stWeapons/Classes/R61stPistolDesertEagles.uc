//===============================================================================
//  [R61stPistolDesertEagles] 
//===============================================================================

class R61stPistolDesertEagles extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolDesertEaglesA');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolDesertEaglesFrame');
    AttachToBone(m_smGun, 'TagFrame'); 
    m_smGun2 = spawn(class'R61stWeaponStaticMesh');
    m_smGun2.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolDesertEaglesSlide');
    AttachToBone(m_smGun2, 'TagSlide'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolDesertEagles'
}
