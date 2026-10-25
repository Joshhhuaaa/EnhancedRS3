//===============================================================================
//  [R61stSubMp5KPDW] 
//===============================================================================

class R61stSubMp5KPDW extends R6AbstractFirstPersonWeapon;


function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stSub_UKX.R61stSubMp5KPDWA');
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
     m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Subguns.R61stSubMp5KPDWFrame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSub_UKX.R61stSubMp5KPDW'
}
