//===============================================================================
//  [R61stSubUzi] 
//===============================================================================

class R61stSubUzi extends R6AbstractFirstPersonWeapon;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stSub_UKX.R61stSubUziA');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
     m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Subguns.R61stSubUziFrame');
    AttachToBone(m_smGun, 'TagFrame');     
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSub_UKX.R61stSubUzi'
}
