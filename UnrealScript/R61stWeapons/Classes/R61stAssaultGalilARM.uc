//===============================================================================
//  [R61stAssaultGalilARM] 
//===============================================================================

class R61stAssaultGalilARM extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stAssault_UKX.R61stAssaultGalilARMA');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultGalilARMFrame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stAssault_UKX.R61stAssaultGalilARM'
}
