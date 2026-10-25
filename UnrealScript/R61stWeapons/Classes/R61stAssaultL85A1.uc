//===============================================================================
//  [R61stAssaultL85A1]
//===============================================================================

class R61stAssaultL85A1 extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stAssault_UKX.R61stAssaultL85A1A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.AssaultRifles.R61stAssaultL85A1Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stAssault_UKX.R61stAssaultL85A1'
}
