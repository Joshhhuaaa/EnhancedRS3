//===============================================================================
//  [R61stSniperPSG1] 
//===============================================================================

class R61stSniperPSG1 extends R61stSniperSSG3000;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stSniper_UKX.R61stSniperPSG1A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SniperRifles.R61stSniperPSG1Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSniper_UKX.R61stSniperPSG1'
}
