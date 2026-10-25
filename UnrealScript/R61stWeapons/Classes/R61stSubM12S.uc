//===============================================================================
//  [R61stSubM12S] 
//===============================================================================

class R61stSubM12S extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stSub_UKX.R61stSubM12SA');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
     m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Subguns.R61stSubM12SFrame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSub_UKX.R61stSubM12S'
}
