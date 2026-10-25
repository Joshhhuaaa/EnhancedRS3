//===============================================================================
//  [R61stPistolSR2] 
//===============================================================================

class R61stPistolSR2 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolSR2A'); // NOTE: RECYCLED BY R61stSubSR2
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolSR2Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolSR2'
}
