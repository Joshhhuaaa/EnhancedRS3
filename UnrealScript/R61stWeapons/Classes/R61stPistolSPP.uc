//===============================================================================
//  [R61stPistolSPP] 
//===============================================================================

class R61stPistolSPP extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolSPPA');
    Super.PostBeginPlay();
    m_smGun = spawn(class'R61stWeaponStaticMesh');
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Pistols.R61stPistolSPPFrame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stPistol_UKX.R61stPistolSPP'
}
