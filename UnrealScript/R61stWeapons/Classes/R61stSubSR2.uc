//===============================================================================
//  [R61stSubSR2] 
//===============================================================================

class R61stSubSR2 extends R61stPistolSR2;

function PostBeginPlay()
{
    LinkSkelAnim(MeshAnimation'R61stPistol_UKX.R61stPistolSR2A'); // NOTE: RECYCLING PISTOL ANIMS
    Super.PostBeginPlay();
    if(m_smGun == none)
    {
        m_smGun = spawn(class'R61stWeaponStaticMesh');
    }
     m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Subguns.R61stSubSR2Frame');
    AttachToBone(m_smGun, 'TagFrame'); 
}

defaultproperties
{
     Mesh=SkeletalMesh'R61stSub_UKX.R61stSubSR2'
}
