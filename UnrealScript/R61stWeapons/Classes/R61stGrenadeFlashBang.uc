//===============================================================================
//  [R61stGrenadeFlashBang] 
//===============================================================================

class R61stGrenadeFlashBang extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stGrenade_UKX.R61stGrenadeA');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Grenades.R61stGrenadeFlashBang');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stGrenade_UKX.R61stGrenade'
}
