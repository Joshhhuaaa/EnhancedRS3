//===============================================================================
//  [R61stSubMac119] 
//===============================================================================

class R61stSubMac119 extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stSub_UKX.R61stSubMac119A'); // Recycle animations from the Pistol.
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
     m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Subguns.R61stSubMac119Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSub_UKX.R61stSubMac119'
}
