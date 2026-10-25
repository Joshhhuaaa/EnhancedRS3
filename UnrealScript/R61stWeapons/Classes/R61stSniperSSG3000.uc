//===============================================================================
//  [R61stSniperSSG3000] 
//===============================================================================

class R61stSniperSSG3000 extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stSniper_UKX.R61stSniperSSG3000A');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
    m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.SniperRifles.R61stSniperSSG3000Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSniper_UKX.R61stSniperSSG3000'
}
