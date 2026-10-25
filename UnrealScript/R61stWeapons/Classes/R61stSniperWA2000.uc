//===============================================================================
//  [R61stSniperWA2000] 
//===============================================================================

class R61stSniperWA2000 extends R61stSniperSSG3000;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stSniper_UKX.R61stSniperWA2000A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SniperRifles.R61stSniperWA2000Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSniper_UKX.R61stSniperWA2000'
}
