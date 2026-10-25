//===============================================================================
//  [R61stAssaultAK47] 
//===============================================================================

class R61stAssaultAK47 extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stAssault_UKX.R61stAssaultAK47A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultAK47Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stAssault_UKX.R61stAssaultAK47'
}
